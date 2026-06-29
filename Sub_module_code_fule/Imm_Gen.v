`timescale 1ns / 1ps
module Imm_Gen(
    input  [31:0] instr,
    output reg [31:0] ImmExt
);
    wire [6:0] opcode;
    assign opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011: // I-type ADDI
                ImmExt = {{20{instr[31]}}, instr[31:20]};

            7'b0000011: // I-type LW
                ImmExt = {{20{instr[31]}}, instr[31:20]};

            7'b1100111: // I-type JALR
                ImmExt = {{20{instr[31]}}, instr[31:20]};

            7'b0100011: // S-type SW
                ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            7'b1100011: // B-type BEQ
                ImmExt = {{19{instr[31]}}, instr[31],
                           instr[7], instr[30:25],
                           instr[11:8], 1'b0};

            7'b1101111: // J-type JAL
                ImmExt = {{11{instr[31]}}, instr[31],
                           instr[19:12], instr[20],
                           instr[30:21], 1'b0};

            default:
                ImmExt = 32'd0;
        endcase
    end
endmodule