`timescale 1ns / 1ps

module decoder(
    input  [31:0] instr,
    output [6:0]  opcode,  
    output reg [2:0] fun3,
    output reg [6:0] fun7,
    output reg [31:0] imm,
    output reg [4:0] rd,
    output reg [4:0] rs1,  
    output reg [4:0] rs2   
);

    assign opcode = instr[6:0];

    // Correct opcodes parameters
    parameter R_TYPE = 7'b0110011;
    parameter I_TYPE = 7'b0010011;
    parameter LOAD   = 7'b0000011; 
    parameter S_TYPE = 7'b0100011; 
    parameter B_TYPE = 7'b1100011;
    parameter JAL    = 7'b1101111;
    parameter JALR   = 7'b1100111;
    parameter LUI    = 7'b0110111;
    parameter AUIPC  = 7'b0010111;

    always @(*) begin
        // default values
        rd   = 5'b0;
        rs1  = 5'b0;
        rs2  = 5'b0;
        fun3 = 3'b0;
        fun7 = 7'b0;
        imm  = 32'b0;

        case(opcode)
            R_TYPE: begin
                rd   = instr[11:7];
                fun3 = instr[14:12];
                rs1  = instr[19:15];
                rs2  = instr[24:20];
                fun7 = instr[31:25];
            end

            I_TYPE, LOAD, JALR: begin 
                rd   = instr[11:7];
                fun3 = instr[14:12];
                rs1  = instr[19:15];
                imm  = {{20{instr[31]}}, instr[31:20]};
            end

            S_TYPE: begin
                fun3 = instr[14:12];
                rs1  = instr[19:15];
                rs2  = instr[24:20];
                imm  = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            B_TYPE: begin
                fun3 = instr[14:12];
                rs1  = instr[19:15];
                rs2  = instr[24:20];
                imm  = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            JAL: begin
                rd  = instr[11:7];
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            LUI, AUIPC: begin
                rd  = instr[11:7];
                imm = {instr[31:12], 12'b0};
            end
            
            default: begin
                rd   = 5'b0;
                imm  = 32'b0;
            end
        endcase
    end
endmodule