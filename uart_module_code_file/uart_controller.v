`timescale 1ns / 1ps
module UART_Controller(
    input        clk,
    input        reset,

    // Processor interface
    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input        mem_we,
    input        mem_re,
    output reg [31:0] mem_rdata,

    // Physical pins
    output        uart_tx,
    input         uart_rx,

    // Status outputs
    output        tx_done,
    output        rx_done,
    output [31:0] rx_data_out
);
    parameter UART_TX_ADDR   = 32'hFFFF0000;
    parameter UART_RX_ADDR   = 32'hFFFF0004;
    parameter UART_STAT_ADDR = 32'hFFFF0008;

    // Internal signals
    wire [31:0] rx_data;
    wire        tx_done_pulse;
    wire        rx_done_pulse;

    reg        tx_start;
    reg [31:0] tx_data;

    // Sticky done flags
    reg tx_done_sticky;
    reg rx_done_sticky;

    // TX trigger + sticky flag logic
    always @(posedge clk) begin
        if (reset) begin
            tx_start       <= 1'b0;
            tx_data        <= 32'd0;
            tx_done_sticky <= 1'b0;
            rx_done_sticky <= 1'b0;
        end
        else begin
            tx_start <= 1'b0;

            // Set sticky flags on hardware done pulses
            if (tx_done_pulse) tx_done_sticky <= 1'b1;
            if (rx_done_pulse) rx_done_sticky <= 1'b1;

            // Processor writes 32-bit word -> trigger TX & clear old TX done flag
            if (mem_we && mem_addr == UART_TX_ADDR) begin
                tx_data        <= mem_wdata;
                tx_start       <= 1'b1;
                tx_done_sticky <= 1'b0; // Cleared because a new transmission started
            end

            // Processor reads RX Data -> clear the RX done flag
            if (mem_re && mem_addr == UART_RX_ADDR) begin
                rx_done_sticky <= 1'b0; // Cleared because data was successfully consumed
            end
        end
    end

    // Read mux
    always @(*) begin
        mem_rdata = 32'd0;
        if (mem_re) begin
            if (mem_addr == UART_RX_ADDR)
                mem_rdata = rx_data;
            else if (mem_addr == UART_STAT_ADDR)
                mem_rdata = {30'd0, rx_done_sticky, tx_done_sticky};
        end
    end

    assign rx_data_out = rx_data;
    assign tx_done     = tx_done_sticky;
    assign rx_done     = rx_done_sticky;

    // 32-bit TX instance
    UART_TX uart_tx_inst (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (uart_tx),
        .tx_done  (tx_done_pulse)
    );

    // 32-bit RX instance
    UART_RX uart_rx_inst (
        .clk     (clk),
        .reset   (reset),
        .rx      (uart_rx),
        .rx_data (rx_data),
        .rx_done (rx_done_pulse)
    );

endmodule