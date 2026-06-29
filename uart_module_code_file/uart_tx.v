`timescale 1ns / 1ps
module UART_TX(
    input         clk,
    input         reset,
    input         tx_start,
    input  [31:0] tx_data,
    output reg    tx,
    output reg    tx_done
);
    parameter CLKS_PER_BIT = 10416;

    parameter IDLE      = 3'd0;
    parameter LOAD_BYTE = 3'd1;
    parameter START     = 3'd2;
    parameter DATA      = 3'd3;
    parameter STOP      = 3'd4;

    reg [2:0]  state;
    reg [13:0] clk_count;
    reg [2:0]  bit_index;
    reg [1:0]  byte_index;
    reg [7:0]  tx_shift;
    reg [31:0] tx_word;

    always @(posedge clk) begin
        if (reset) begin
            state      <= IDLE;
            tx         <= 1'b1;
            tx_done    <= 1'b0;
            clk_count  <= 14'd0;
            bit_index  <= 3'd0;
            byte_index <= 2'd0;
            tx_shift   <= 8'd0;
            tx_word    <= 32'd0;
        end
        else begin
            case (state)

                IDLE: begin
                    tx         <= 1'b1;
                    tx_done    <= 1'b0;
                    clk_count  <= 14'd0;
                    bit_index  <= 3'd0;
                    byte_index <= 2'd0;
                    tx_shift   <= 8'd0;
                    if (tx_start) begin
                        tx_word <= tx_data;
                        state   <= LOAD_BYTE;
                    end
                end

                LOAD_BYTE: begin
                    case (byte_index)
                        2'd0: tx_shift <= tx_word[7:0];
                        2'd1: tx_shift <= tx_word[15:8];
                        2'd2: tx_shift <= tx_word[23:16];
                        2'd3: tx_shift <= tx_word[31:24];
                        default: tx_shift <= 8'd0;
                    endcase
                    clk_count <= 14'd0;
                    state     <= START;
                end

                START: begin
                    tx <= 1'b0; // Start Bit
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 14'd1;
                    else begin
                        clk_count <= 14'd0;
                        state     <= DATA;
                    end
                end

                DATA: begin
                    tx <= tx_shift[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 14'd1;
                    else begin
                        clk_count <= 14'd0;
                        if (bit_index < 3'd7)
                            bit_index <= bit_index + 3'd1;
                        else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1; // Stop Bit
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 14'd1;
                    else begin
                        clk_count <= 14'd0;
                        if (byte_index < 2'd3) begin
                            byte_index <= byte_index + 2'd1;
                            state      <= LOAD_BYTE; 
                        end
                        else begin
                            byte_index <= 2'd0;
                            tx_done    <= 1'b1;
                            state      <= IDLE;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                    tx    <= 1'b1;
                end

            endcase
        end
    end
endmodule