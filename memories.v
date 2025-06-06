//memories and register file modules; written by GYMS team
//instruction memory of processor
module instr_memory(
	input [7:0]program_counter,//program counter
	output [15:0]instruction//instruction
);
	reg [15:0]instruction_memory[0:255];//instruction memory of 256 words each of 16 bits
	/*initial
		begin
			$readmemb("instruction_file.bin",instruction_memory);//read the memory file
		end*/
	assign instruction = instruction_memory[program_counter];//instruction assignment
endmodule
//data memory of processor
module data_memory(
	input clock,//processor clock
	input mem_signal_write,//write signal
	input [7:0]mem_addr_rw,//shared address
	input [15:0]mem_data_write,//write data
	output [15:0]mem_data_read//read data
);
	reg [15:0]data_memory[0:255];//data memory of 256 words each of 16 bits
	integer i;
	initial
		begin
			for(i=0;i<256;i=i+1)
				data_memory[i] <= 16'd0;//initialising memory words as zeroes
		end
	always@(posedge clock)//sequential logic for writing to memory
		begin
			if(mem_signal_write)//writing
				data_memory[mem_addr_rw] <= mem_data_write;//write assignment
		end
	assign mem_data_read = (~mem_signal_write)?data_memory[mem_addr_rw]:16'dx;//read assignment
endmodule
//register file of processor
module register_file(
	input clock,//clock of processor
	input reg_signal_write,//write signal
	input [3:0]reg_addr_write,//write address
	input [3:0]reg_addr_read1,//read address 1
	input [3:0]reg_addr_read2,//read address 2
	input [15:0]reg_data_write,//write data
	output [15:0]reg_data_read1,//read data 1
	output [15:0]reg_data_read2//read data 2
);
	reg [15:0]register_file[0:15];//register file
	integer i;
	initial
		begin
			for(i=0;i<16;i=i+1)
				register_file[i] <= 16'd0;//initialising register words as zeroes
		end
	always@(posedge clock)//sequential logic for writing to register file
		begin
			if(reg_signal_write)//writing
				register_file[reg_addr_write] <= reg_data_write;//write assignment
		end
	assign reg_data_read1 = register_file[reg_addr_read1];//read assignment 1
	assign reg_data_read2 = register_file[reg_addr_read2];//read assignment 2
endmodule
