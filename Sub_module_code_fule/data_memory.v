`timescale 1ns / 1ps
module Data_Memory(
    input         clk,
    input         WE,
    input         RE,
    input  [31:0] A,
    input  [31:0] WD,
    output [31:0] RD,

    output        uart_mem_we,
    output        uart_mem_re,
    output [31:0] uart_mem_addr,
    output [31:0] uart_mem_wdata,
    input  [31:0] uart_mem_rdata
);
    reg [7:0] mem[0:255];    // byte wide - byte addressable

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 8'h00;
    end

    // UART address detect
    wire is_uart = (A[31:8] == 24'hFFFF00);

    assign uart_mem_we    = WE & is_uart;
    assign uart_mem_re    = RE & is_uart;
    assign uart_mem_addr  = A;
    assign uart_mem_wdata = WD;

    // Write 
    always @(posedge clk) begin
        if (WE && !is_uart) begin
            mem[A]   <= WD[7:0];
            mem[A+1] <= WD[15:8];
            mem[A+2] <= WD[23:16];
            mem[A+3] <= WD[31:24];
        end
    end

    // Read 
    assign RD = is_uart  ? uart_mem_rdata :
                RE       ? {mem[A+3], mem[A+2], mem[A+1], mem[A]} :
                           32'd0;

endmodule