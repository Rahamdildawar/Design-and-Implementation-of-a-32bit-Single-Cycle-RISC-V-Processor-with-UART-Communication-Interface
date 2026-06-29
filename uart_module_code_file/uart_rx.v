`timescale 1ns / 1ps
module UART_RX(
    input             clk,
    input             reset,
    input             rx,
    output reg [31:0] rx_data,
    output reg        rx_done
);
    parameter CLKS_PER_BIT = 10416;
    parameter HALF_BIT     = CLKS_PER_BIT / 2;

    parameter IDLE  = 3'd0;
    parameter START = 3'd1;
    parameter DATA  = 3'd2;
    parameter STOP  = 3'd3;

    reg [2:0]  state;
    reg [13:0] clk_count;
    reg [2:0]  bit_index;
    reg [1:0]  byte_index;
    reg [7:0]  rx_shift;
    reg [31:0] rx_word;

    always @(posedge clk) begin
        if (reset) begin
            state      <= IDLE;
            rx_done    <= 1'b0;
            clk_count  <= 14'd0;
            bit_index  <= 3'd0;
            byte_index <= 2'd0;
            rx_shift   <= 8'd0;
            rx_word    <= 32'd0;
            rx_data    <= 32'd0;
        end
        else begin
            case (state)

                IDLE: begin
                    rx_done   <= 1'b0;
                    clk_count <= 14'd0;
                    bit_index <= 3'd0;
                    if (rx == 1'b0)
                        state <= START;
                end

                START: begin
                    if (clk_count < HALF_BIT - 1)
                        clk_count <= clk_count + 14'd1;
                    else begin
                        clk_count <= 14'd0;
                        if (rx == 1'b0)
                            state <= DATA;
                        else
                            state <= IDLE;  // Noise filter
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 14'd1;
                    else begin
                        clk_count           <= 14'd0;
                        rx_shift[bit_index] <= rx;
                        if (bit_index < 3'd7)
                            bit_index <= bit_index + 3'd1;
                        else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 14'd1;
                    else begin
                        clk_count <= 14'd0;

                        // Capture the byte into our assembly buffer
                        case (byte_index)
                            2'd0: rx_word[7:0]   <= rx_shift;
                            2'd1: rx_word[15:8]  <= rx_shift;
                            2'd2: rx_word[23:16] <= rx_shift;
                            2'd3: rx_word[31:24] <= rx_shift;
                            default: ;
                        endcase

                        // Frame Tracking
                        if (byte_index < 2'd3) begin
                            byte_index <= byte_index + 2'd1;
                        end
                        else begin
                            byte_index <= 2'd0;
                            rx_done    <= 1'b1;
                            rx_data    <= {rx_shift, rx_word[23:16], rx_word[15:8], rx_word[7:0]};
                        end
                        
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule