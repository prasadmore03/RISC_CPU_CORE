//processor module; written by GYMS team
//combined datapath and controller of processor
`include "controller.v"
`include "datapath.v"
module processor(
	input clock,//processor clock
	input reset,//processor reset
	output zero_flag,//zero flag; triggers if resultant==0
	output error_flag//error flag; triggers if resulant=x or division by zero
);
	wire mem_signal_write;//data memory write signal
	wire reg_signal_write;//register file write signal
	wire [3:0]opcode;//opcode
	//instantiating the datapath
	datapath DATA(
			.clock(clock),
			.reset(reset),
			.mem_signal_write(mem_signal_write),
			.reg_signal_write(reg_signal_write),
			.opcode(opcode),
			.zero_flag(zero_flag),
			.error_flag(error_flag)
	);
	//instantiating the controller
	controller CONTROL(
			.opcode(opcode),
			.mem_signal_write(mem_signal_write),
			.reg_signal_write(reg_signal_write)
	);
endmodule
