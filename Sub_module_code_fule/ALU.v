`timescale 1ns / 1ps
module ALU(
    input  [31:0] A, B,
    input  [3:0]  ALUCtrl,
    output reg [31:0] Result,
    output        Zero
);
    always @(*) begin
        case (ALUCtrl)
            4'b0000: Result = A + B;
            4'b0001: Result = A - B;
            4'b0010: Result = A & B;
            4'b0011: Result = A | B;
            4'b0100: Result = A ^ B;
            4'b0101: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            default: Result = 32'd0;
        endcase
    end

    assign Zero = (Result == 32'd0) ? 1'b1 : 1'b0;

endmodule