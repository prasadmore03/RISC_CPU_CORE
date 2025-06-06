`timescale 1ns / 1ps

module tb_processor;
    // Declare inputs to the processor
    reg clock;
    reg reset;
    // Declare outputs from the processor
    wire zero_flag;
    wire error_flag;
	reg [15:0]instruction_memory[0:255];
    // Instantiate the processor module
    processor uut (
        .clock(clock),
        .reset(reset),
        .zero_flag(zero_flag),
        .error_flag(error_flag)
    );

    // Clock generation
    always begin
        #5 clock = ~clock;  // Generate clock with 10ns period
    end

    // Testbench logic
    initial begin
        // Initialize signals
        clock = 0;
        reset = 0;
	$dumpfile("xyz.vcd");
    	$dumpvars;
        // Display the results on the terminal
        $display("Starting the simulation...");

        // Reset the processor
        reset = 1;
        #10;  // Wait for 10 ns
        reset = 0;
        
        // Load instructions from the binary file
        $readmemb("output.bin", uut.DATA.IM.instruction_memory);

        // Run the simulation for a certain number of cycles
        /*repeat (20) begin
            #10 uut.program_counter = program_counter + 1; // Increment program counter
            #10;  // Wait for the next clock cycle
        end*/

        // End the simulation
        $display("Simulation Finished.");
        #1000 $finish;
    end

    // Monitor the output signals (optional)
    initial begin
        $monitor("Time = %0t, Zero Flag = %b, Error Flag = %b", $time, zero_flag, error_flag);
    end
endmodule

