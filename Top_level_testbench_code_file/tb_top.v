`timescale 1ns / 1ps

module tb_Single_Cycle_Processor();

    // Inputs
    reg clk;
    reg reset;
    reg uart_rx;

    // Outputs
    wire uart_tx;

    // Instantiate the Unit Under Test (UUT)
    Single_Cycle_Processor uut (
        .clk(clk), 
        .reset(reset), 
        .uart_rx(uart_rx), 
        .uart_tx(uart_tx)
    );

    // Clock generation (100MHz -> 10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // --- UART Helper Task ---
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // 1. Start Bit (Drive Low)
            uart_rx = 1'b0;
            #104160;
            
            // 2. Data Bits (LSB First)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #104160;
            end
            
            // 3. Stop Bit (Drive High)
            uart_rx = 1'b1;
            #104160;
            
            // Small gap between bytes to simulate real serial transmission separation
            #20000;
        end
    endtask

    // Stimulus process
    initial begin
        // Initialize Inputs
        uart_rx = 1'b1; // Idle state is High
        reset = 1'b1;

        // This prevents the race condition and allows address 0x0 to execute properly.
        #105;
        reset = 1'b0;
        
        #200; // Let the processor settle a bit and step into its code cleanly
        
        $display("[TB] Sending 4 Bytes to form a 32-bit Word...");

        // Send 4 bytes to fill your 32-bit rx_word (0xDEADBEEF)
        send_uart_byte(8'hEF); // Byte 0 -> maps to rx_word[7:0]
        send_uart_byte(8'hBE); // Byte 1 -> maps to rx_word[15:8]
        send_uart_byte(8'hAD); // Byte 2 -> maps to rx_word[23:16]
        send_uart_byte(8'hDE); // Byte 3 -> maps to rx_word[31:24]

        $display("[TB] All bytes sent. Watching processor execution and TX response...");
        

        #5000000;  
        
        $display("Simulation Timeout reached.");
        $finish;
    end

    // Monitor Block
    always @(posedge clk) begin
        if (!reset) begin
            #1; 
          
        end
    end

    // Waveform Generation
    initial begin
        $dumpfile("processor_waves.vcd");
        $dumpvars(0, tb_Single_Cycle_Processor);
    end

endmodule
