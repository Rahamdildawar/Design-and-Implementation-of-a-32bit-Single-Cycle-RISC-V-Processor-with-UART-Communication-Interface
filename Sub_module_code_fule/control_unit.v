`timescale 1ns / 1ps
module control_Unit(
    input  [6:0] opcode,
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        ImmSrc,
    output reg        MemWrite,
    output reg        MemRead,
    output reg        MemToReg,
    output reg        Branch,
    output reg        JAL,
    output reg        JALR,
    output reg [1:0]  ALUOp
);
    always @(*) begin
        // Safe defaults 
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        ImmSrc   = 1'b0;
        MemWrite = 1'b0;
        MemRead  = 1'b0;
        MemToReg = 1'b0;
        Branch   = 1'b0;
        JAL      = 1'b0;
        JALR     = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            7'b0010011: begin // I-type ADDI
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ImmSrc   = 1'b1;
                ALUOp    = 2'b10;
            end
            7'b0000011: begin // LW
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ImmSrc   = 1'b1;
                MemRead  = 1'b1;
                MemToReg = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b0100011: begin // SW
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ImmSrc   = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b1100011: begin // BEQ
                Branch   = 1'b1;
                ALUOp    = 2'b01;
                ImmSrc   = 1'b1;
            end
            7'b1101111: begin // JAL
                RegWrite = 1'b1;
                JAL      = 1'b1;
                ImmSrc   = 1'b1;
            end
            7'b1100111: begin // JALR
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                JALR     = 1'b1;
                ALUOp    = 2'b00;
            end
            default: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemWrite = 1'b0;
                MemRead  = 1'b0;
                MemToReg = 1'b0;
                Branch   = 1'b0;
                JAL      = 1'b0;
                JALR     = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end
endmodule