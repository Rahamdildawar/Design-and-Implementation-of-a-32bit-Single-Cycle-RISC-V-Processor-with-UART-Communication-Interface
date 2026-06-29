`timescale 1ns / 1ps

module Single_Cycle_Processor(
    input  clk,
    input  reset,
    input  uart_rx,
    output uart_tx
);
    // Wires
    wire [31:0] PC_Out, PC_Next, PC_Plus4;
    wire [31:0] PC_JAL, PC_JALR, PC_Branch;
    wire [31:0] Instr;
    wire [31:0] RD1, RD2;
    wire [31:0] ALU_B;
    wire [31:0] ALU_Result;
    wire [31:0] ReadData;       
    wire [31:0] ram_rdata;      
    wire [31:0] WD3;
    wire        Zero;

    // Decoder output wires 
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] ImmExt;

    // Control signals 
    wire        RegWrite, ALUSrc, ImmSrc;
    wire        MemWrite, MemRead;
    wire        MemToReg, Branch;
    wire        JAL, JALR;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUCtrl;
    wire        BranchTaken;

    // UART wires
    wire        uart_mem_we, uart_mem_re;
    wire [31:0] uart_mem_rdata;
    wire        tx_done, rx_done;
    wire [31:0] rx_data_out;

    //PC Logic
    assign PC_Plus4    = PC_Out + 32'd4;
    assign PC_JAL      = PC_Out + ImmExt;
    assign PC_JALR     = (RD1   + ImmExt) & (~32'd1); // Align to 2-byte boundary
    assign PC_Branch   = PC_Out + ImmExt;
    assign BranchTaken = Branch & Zero;

    //PC_Next Multiplexer
    assign PC_Next = JALR        ? PC_JALR    :
                     JAL          ? PC_JAL     :
                     BranchTaken  ? PC_Branch  :
                                    PC_Plus4;

    //Write-back MUX
    assign WD3 = (JAL | JALR) ? PC_Plus4  :
                  MemToReg    ? ReadData  : // Receives the multiplexed RAM/UART data
                                ALU_Result;

    //ALU B input MUX
    assign ALU_B = ALUSrc ? ImmExt : RD2;

    wire is_uart_addr = (ALU_Result[31:16] == 16'hFFFF);

    // Route write/read enables
    wire ram_we  = MemWrite && !is_uart_addr;
    wire ram_re  = MemRead  && !is_uart_addr;

    assign uart_mem_we    = MemWrite && is_uart_addr;
    assign uart_mem_re    = MemRead  && is_uart_addr;
    assign ReadData = (is_uart_addr) ? uart_mem_rdata : ram_rdata;


    //Instantiations
    Program_counter pc_reg (
        .clk     (clk),
        .reset   (reset),
        .PC_Next (PC_Next),
        .PC_Out  (PC_Out)
    );

    Instruction_Memory imem (
        .A  (PC_Out),
        .RD (Instr)
    );

    decoder idec (
        .instr  (Instr),
        .opcode (opcode),
        .rd     (rd),
        .fun3   (funct3),
        .rs1    (rs1),
        .rs2    (rs2),
        .fun7   (funct7),
        .imm    (ImmExt)
    );

    control_Unit cu (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ImmSrc   (ImmSrc),
        .ALUSrc   (ALUSrc),
        .MemWrite (MemWrite),
        .MemRead  (MemRead),
        .MemToReg (MemToReg),
        .Branch   (Branch),
        .JAL      (JAL),
        .JALR     (JALR),
        .ALUOp    (ALUOp)
    );

    register_File rf (
        .clk  (clk),
        .WE3  (RegWrite),
        .A1   (rs1),
        .A2   (rs2),
        .A3   (rd),
        .WD3  (WD3),
        .RD1  (RD1),
        .RD2  (RD2)
    );
    
    Imm_Gen IMM(
        .instr(Instr),
        .ImmExt(ImmExt)
    );
    
    ALU_Control ac (
        .ALUOp   (ALUOp),
        .funct3  (funct3),
        .funct7  (funct7),
        .ALUCtrl (ALUCtrl)
    );

    ALU alu (
        .A       (RD1),
        .B       (ALU_B),
        .ALUCtrl (ALUCtrl),
        .Result  (ALU_Result),
        .Zero    (Zero)
    );

    Data_Memory dmem (
        .clk            (clk),
        .WE             (ram_we),           
        .RE             (ram_re),           
        .A              (ALU_Result),
        .WD             (RD2),
        .RD             (ram_rdata),       
        .uart_mem_we    (),
        .uart_mem_re    (),
        .uart_mem_addr  (),
        .uart_mem_wdata (),
        .uart_mem_rdata ()
    );

    UART_Controller uart_ctrl (
        .clk         (clk),
        .reset       (reset),
        .mem_addr    (ALU_Result),      
        .mem_wdata   (RD2),              
        .mem_we      (uart_mem_we),      
        .mem_re      (uart_mem_re),      
        .mem_rdata   (uart_mem_rdata),
        .uart_tx     (uart_tx),
        .tx_done     (tx_done),
        .uart_rx     (uart_rx),
        .rx_done     (rx_done),
        .rx_data_out (rx_data_out)
    );

endmodule