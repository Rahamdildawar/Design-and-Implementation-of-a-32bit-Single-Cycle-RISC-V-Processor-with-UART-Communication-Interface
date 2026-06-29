`timescale 1ns / 1ps
module register_File(
    input         clk,
    input         WE3,
    input  [4:0]  A1, A2, A3,
    input  [31:0] WD3,
    output [31:0] RD1, RD2
);
    reg [31:0] regs[0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'd0;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (WE3 && (A3 != 5'd0))
            regs[A3] <= WD3;
    end

    // Asynchronous read - x0 always 0
    assign RD1 = (A1 == 5'd0) ? 32'd0 : regs[A1];
    assign RD2 = (A2 == 5'd0) ? 32'd0 : regs[A2];

endmodule