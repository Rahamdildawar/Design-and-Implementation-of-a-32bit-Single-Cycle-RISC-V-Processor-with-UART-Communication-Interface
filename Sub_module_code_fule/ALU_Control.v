`timescale 1ns / 1ps
module ALU_Control(
    input  [1:0]  ALUOp,
    input  [2:0]  funct3,
    input  [6:0]  funct7,
    output reg [3:0] ALUCtrl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtrl = 4'b0000; // ADD
            2'b01: ALUCtrl = 4'b0001; // SUB
            2'b10: begin
                case (funct3)
                    3'b000:  ALUCtrl = funct7 ? 4'b0001 : 4'b0000;
                    3'b111:  ALUCtrl = 4'b0010; // AND
                    3'b110:  ALUCtrl = 4'b0011; // OR
                    3'b100:  ALUCtrl = 4'b0100; // XOR
                    3'b010:  ALUCtrl = 4'b0101; // SLT
                    default: ALUCtrl = 4'b0000;
                endcase
            end
            default: ALUCtrl = 4'b0000;
        endcase
    end
endmodule