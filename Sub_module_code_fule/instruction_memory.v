`timescale 1ns / 1ps

module Instruction_Memory(
    input  [31:0] A,
    output [31:0] RD
);
    
    reg [7:0] mem[0:1023]; 
    integer i;
    
 initial begin   
            // Initialize memory with zeros
            for (i = 0; i < 1024; i = i + 1) mem[i] = 8'h00;
    
            // ADDI x1, x0, 10
            mem[0] = 8'h93; 
            mem[1] = 8'h00; 
            mem[2] = 8'hA0; 
            mem[3] = 8'h00;
            
            //ADDI x2, x0, 5
            mem[4] = 8'h13; 
            mem[5] = 8'h01; 
            mem[6] = 8'h50; 
            mem[7] = 8'h00;
    
            //ADD x3, x1, x2
            mem[8]  = 8'hB3; 
            mem[9]  = 8'h81; 
            mem[10] = 8'h20; 
            mem[11] = 8'h00;
    
            //SUB x3, x1, x2
            mem[12] = 8'hB3; 
            mem[13] = 8'h81; 
            mem[14] = 8'h20; 
            mem[15] = 8'h40;
    
            //SW x3, 0(x0)
            mem[16] = 8'h23; 
            mem[17] = 8'h20; 
            mem[18] = 8'h30; 
            mem[19] = 8'h00;
    
            //LW x4, 0(x0)
            mem[20] = 8'h03; 
            mem[21] = 8'h22; 
            mem[22] = 8'h00; 
            mem[23] = 8'h00;
    
            //JAL x1, +12 -> Jumps straight to 0x24 (dec 36)
            mem[24] = 8'hEF; 
            mem[25] = 8'h00; 
            mem[26] = 8'hC0; 
            mem[27] = 8'h00;
    
            //JALR Return Target (NOP)
            mem[28] = 8'h13; 
            mem[29] = 8'h00; 
            mem[30] = 8'h00; 
            mem[31] = 8'h00;
    
            //Empty/NOP space
            mem[32] = 8'h13; 
            mem[33] = 8'h00; 
            mem[34] = 8'h00; 
            mem[35] = 8'h00;
    
            //Target of JAL -> ADDI x5, x0, 0x41 ('A')
            mem[36] = 8'h93; 
            mem[37] = 8'h02; 
            mem[38] = 8'h10; 
            mem[39] = 8'h04;
    
            //JALR x2, x1, 0 -> Jump back to 0x1C (dec 28)
            mem[40] = 8'h67; 
            mem[41] = 8'h81; 
            mem[42] = 8'h00; 
            mem[43] = 8'h00;
            
            //LUI x6, 0xFFFF0
            mem[44] = 8'h37; 
            mem[45] = 8'h03; 
            mem[46] = 8'hFF; 
            mem[47] = 8'hFF;
    
            //SW x5, 0(x6)
            mem[48] = 8'h23; 
            mem[49] = 8'h20; 
            mem[50] = 8'h53; 
            mem[51] = 8'h00;
    
            //LW x7, 8(x6)
            mem[52] = 8'h83; 
            mem[53] = 8'h23; 
            mem[54] = 8'h83; 
            mem[55] = 8'h00;
    
            //ANDI x7, x7, 1
            mem[56] = 8'h93; 
            mem[57] = 8'hF3; 
            mem[58] = 8'h13; 
            mem[59] = 8'h00;
    
            //BEQ x7, x0, -8 -> Jump back to 0x34 (dec 52)
            mem[60] = 8'hE3; 
            mem[61] = 8'h0c; 
            mem[62] = 8'h03; 
            mem[63] = 8'hfe;
    
            //LW x8, 4(x6)
            mem[64] = 8'h03; 
            mem[65] = 8'h24; 
            mem[66] = 8'h43; 
            mem[67] = 8'h00;
        end

    assign RD = (A < 1024) ? {mem[A+3], mem[A+2], mem[A+1], mem[A]} : 32'h00000013;

endmodule