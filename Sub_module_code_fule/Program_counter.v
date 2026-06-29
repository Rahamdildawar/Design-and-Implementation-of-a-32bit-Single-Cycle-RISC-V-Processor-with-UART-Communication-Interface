`timescale 1ns / 1ps
module Program_counter(
    input        clk,
    input        reset,
    input  [31:0] PC_Next,
    output reg [31:0] PC_Out
);
    always @(posedge clk) begin
        if (reset)
            PC_Out <= 32'd0;
        else
            PC_Out <= PC_Next;
    end
endmodule