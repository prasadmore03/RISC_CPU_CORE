//datapath module; written by GYMS team
//datapath of processor
`include "memories.v"
`include "alu.v"

module datapath(
	input clock,//processor clock
	input reset,//processor reset
	input mem_signal_write,//mem write signal
	input reg_signal_write,//reg write signal
	output [3:0]opcode,//opcode
	output zero_flag,//zero flag; triggers if resultant=0
	output error_flag//error flag; triggers if resulant=x or division by zero
);
	//classification of instructions
	parameter mem_data_inst = 3'b000,//ldm,stm
		  reg_data_inst = 3'b001,//ldr,mov
		  andor_inst = 3'b010,//and,or
		  notxor_inst = 3'b011,//not,xor
		  shift_inst = 3'b100,//shl,shr
		  addsub_inst = 3'b101,//add,sub
		  div_inst = 3'b110;//div
	//classification of operations
	parameter bit_and = 4'b0000,//and
		  bit_or = 4'b0001,//or
		  bit_xor = 4'b0010,//xor
		  bit_not = 4'b0011,//not
		  shift_log_left = 4'b0100,//logic shift left
		  shift_ari_left = 4'b0101,//arith shift left
		  shift_log_right = 4'b0110,//logic shift right
		  shift_ari_right = 4'b0111,//arith shift right
		  arith_add = 4'b1000,//add
		  arith_sub = 4'b1001,//sub
		  arith_div = 4'b1010;//div
	//data memory read-write ports
	reg [7:0]mem_addr_rw;//shared address
	reg [15:0]mem_data_write;//write data
	wire [15:0]mem_data_read;//read data
	//register file read-write ports
	reg [3:0]reg_addr_write;//write address
	reg [3:0]reg_addr_read1;//1st read address
	reg [3:0]reg_addr_read2;//2nd read address
	reg [15:0]reg_data_write;//write data
	wire [15:0]reg_data_read1;//1st read data
	wire [15:0]reg_data_read2;//2nd read data
	//instruction memory ports
	reg [7:0]program_counter;//program counter
	wire [15:0]instruction;//instruction extracted
	//arithmetic and logical unit (alu) ports
	reg [3:0]operation;//alu operation
	reg [15:0]alu_op1;//alu 1st operand
	reg [15:0]alu_op2;//alu 2nd operand
	wire [15:0]alu_res;//alu result
	//stages of pipelining
	//IF = instruction fetch
	//ID = instruction decode
	//EX = execute operation
	//MEM = memory access
	//WB = write back registers
	//pipelining registers between IF and ID stages
	reg [7:0]IF_ID_program_counter;
	reg [15:0]IF_ID_instruction;
	//pipelining registers between ID and EX stages
	reg [3:0]ID_EX_reg_addr_write;
	reg [3:0]ID_EX_reg_addr_read1;
	reg [3:0]ID_EX_reg_addr_read2;
	reg [3:0]ID_EX_operation;
	reg [15:0]ID_EX_reg_data_write;
	reg [15:0]ID_EX_reg_data_read1;
	reg [15:0]ID_EX_reg_data_read2;
	reg [15:0]ID_EX_alu_op1;
	reg [15:0]ID_EX_alu_op2;
	//pipelining registers between EX and MEM stages
	reg EX_MEM_mem_signal_write;
	reg [3:0]EX_MEM_reg_addr_write;
	reg [15:0]EX_MEM_alu_res;
	reg [15:0]EX_MEM_reg_data_write;
	reg [15:0]EX_MEM_mem_data_write;
	//pipelining registers between MEM and WB stages
	reg MEM_WB_reg_signal_write;
	reg [3:0]MEM_WB_reg_addr_write;
	reg [15:0]MEM_WB_reg_data_write;
	//instruction fetch stage
	always@(posedge clock)//sequential logic for extracting instructions
		begin
			if(reset)//synchronous reset; and if high
				program_counter <= 8'd0;//initialise program counter
			else
				program_counter <= program_counter + 8'd1;//continue incrementing
		end
	//instantiating instruction memory
	instr_memory IM(
			.program_counter(program_counter),
			.instruction(instruction)
	);
	assign opcode = instruction[15:12];//opcode from the instruction
	//intermediate between IF and ID stages
	always @(posedge clock)//sequential logic for moving these into registers
		begin
			IF_ID_instruction <= instruction;
			IF_ID_program_counter <= program_counter;
		end
	//instruction decode stage
	always@(*)//combinational logic to decode data from instruction
		begin
			//initialisation of reg values
			mem_addr_rw = 8'd0;
			reg_addr_write = 4'd0;
			reg_addr_read1 = 4'd0;
			reg_addr_read2 = 4'd0;
			reg_data_write = 16'd0;
			mem_data_write = 16'd0;
			operation = 4'd0;
			alu_op1 = 16'd0;
			alu_op2 = 16'd0;
			//consider the instruction classification
			case(opcode[3:1])
				//includes ldm and stm
				mem_data_inst: begin
					mem_addr_rw = instruction[7:0];//address allocation
					if(~opcode[0])//if ldm
						begin
							reg_addr_write = instruction[11:8];//write to this register
							reg_data_write = mem_data_read;//write this data from memory
						end
					else//if stm
						begin
							reg_addr_read1 = instruction[11:8];//read from this register
							mem_data_write = reg_data_read1;//write this data to memory
						end
					end
				//includes ldr and mov
				reg_data_inst: begin
					reg_addr_write = instruction[11:8];//write to this register
					if(~opcode[0])//if ldr
						begin
							reg_data_write = {8'd0,instruction[7:0]};//write this data from instruction
						end
					else//mov
						begin
							reg_addr_read1 = instruction[7:4];//read from this register
							reg_data_write = reg_data_read1;//write this data from register
						end
					end
				//includes and,or,add,sub
				andor_inst,addsub_inst: begin
					reg_addr_read1 = instruction[7:4];//read from this register
					reg_addr_read2 = instruction[3:0];//read from this register too
					reg_addr_write = instruction[11:8];//write to this register
					alu_op1 = reg_data_read1;//move this data to alu
					alu_op2 = reg_data_read2;//move this data to alu too
					reg_data_write = alu_res;//write this data to register
					if(opcode[3:1]==andor_inst)
						operation = (~opcode[0])? bit_and : bit_or;//operation is and or or
					else if(opcode[3:1]==addsub_inst)
						operation = (~opcode[0])? arith_add : arith_sub;//operation is add or sub
					end
				//includes not,xor,div
				notxor_inst,div_inst: begin
					reg_addr_write = instruction[11:8];//write to this register
					reg_addr_read1 = instruction[7:4];//read from this register
					alu_op1 = reg_data_read1;//move this data to alu
					if(~opcode[0])//if xor or div
						begin
							reg_addr_read2 = instruction[3:0];//read from this register too
							alu_op2 = reg_data_read2;//move this data to alu too
							if(opcode[3:1]==notxor_inst)
								operation = bit_xor;//operation is xor
							else if((opcode[3:1]==div_inst) && (~opcode[0]))
								operation = arith_div;//operation is div
						end
					else if((opcode[3:1]==notxor_inst) && (opcode[0]))//if not
						begin
							operation = bit_not;//operation is not
							if(instruction[3:0]==4'b1111)//2's complement condition
								alu_op2 = 16'd1;
							else if(instruction[3:0]==4'b0000)//1's complement condition
								alu_op2 = 16'd0;
						end
					end
				//includes shl and shr
				shift_inst: begin
					reg_addr_write = instruction[11:8];//write to this register
					reg_addr_read1 = instruction[7:4];//read from this register
					alu_op1 = reg_data_read1;//move this data to alu
					alu_op2 = {14'd0,instruction[1:0]};//move this data to alu too
					if(instruction[3:2]==2'b00)//logical shift
						begin
							if(~opcode[0])
								operation = shift_log_left;//operation is logical shift left
							else
								operation = shift_log_right;//operation is logical shift right
						end
					else if(instruction[3:2]==2'b11)//arithmetic shift
						begin
							if(~opcode[0])
								operation = shift_ari_left;//operation is arithmetic shift left
							else
								operation = shift_ari_right;//operation is arithmetic shift right
						end
					end
			endcase
		end
	//intermediate between ID and EX stages
	always@(posedge clock)//sequential logic for moving these into registers
		begin
			ID_EX_reg_addr_write <= reg_addr_write;
			ID_EX_reg_addr_read1 <= reg_addr_read1;
			ID_EX_reg_addr_read2 <= reg_addr_read2;
			ID_EX_operation <= operation;
			ID_EX_reg_data_write <= reg_data_write;
			ID_EX_reg_data_read1 <= reg_data_read1;
			ID_EX_reg_data_read2 <= reg_data_read2;
			ID_EX_alu_op1 <= alu_op1;
			ID_EX_alu_op2 <= alu_op2;
		end
	//execute stage
	//instantiating arithmetic and logical unit (alu)
	arithmetic_logical_unit ALU(
			.operation(ID_EX_operation),
			.alu_op1(ID_EX_alu_op1),
			.alu_op2(ID_EX_alu_op2),
			.alu_res(alu_res),
			.zero_flag(zero_flag),
			.error_flag(error_flag)
	);
	//intermediate between EX and MEM stages
	always@(posedge clock)
		begin
			EX_MEM_mem_signal_write <= mem_signal_write;
			EX_MEM_mem_data_write <= mem_data_write;
			EX_MEM_reg_addr_write <= ID_EX_reg_addr_write;
			EX_MEM_reg_data_write <= ID_EX_reg_data_write;
			EX_MEM_alu_res <= alu_res;
		end
	//memory access stage
	//instantiating data memory
	data_memory DM(
			.clock(clock),
			.mem_signal_write(EX_MEM_mem_signal_write),
			.mem_addr_rw(mem_addr_rw),
			.mem_data_read(mem_data_read),
			.mem_data_write(EX_MEM_mem_data_write)
	);
	//intermediate between MEM and WB stages
	always@(posedge clock)
		begin
			MEM_WB_reg_addr_write <= EX_MEM_reg_addr_write;
			MEM_WB_reg_signal_write <= reg_signal_write;
			//reg_data_write has two different results: alu_res or reg_data_write
			if((opcode[3:1]==mem_data_inst && opcode[0]) || opcode[3:1]==mem_data_inst)
				MEM_WB_reg_data_write <= EX_MEM_reg_data_write;//push thee reg_write_data
			else
				MEM_WB_reg_data_write <= EX_MEM_alu_res;//push the alu result

		end
	//write back registers stage
	//instantiating register file
	register_file RF(
			.clock(clock),
			.reg_signal_write(MEM_WB_reg_signal_write),
			.reg_addr_write(MEM_WB_reg_addr_write),
			.reg_data_write(MEM_WB_reg_data_write),
			.reg_addr_read1(reg_addr_read1),
			.reg_addr_read2(reg_addr_read2),
			.reg_data_read1(reg_data_read1),
			.reg_data_read2(reg_data_read2)
	);
endmodule
