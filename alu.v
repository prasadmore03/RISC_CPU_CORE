//arithmetic and logical unit module; written by GYMS team
//alu of processor
module arithmetic_logical_unit(
	input [3:0]operation,//alu operation
	input [15:0]alu_op1,//alu 1st operand
	input [15:0]alu_op2,//alu 2nd operand
	output reg [15:0]alu_res,//alu result
	output reg zero_flag,//zero flag
	output reg error_flag//error flag
);
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
	always @(*)//combinational logic for the operation selection
		begin
			case(operation)//perform based on the given operation
				bit_and: alu_res = alu_op1 & alu_op2;//and
				bit_or: alu_res = alu_op1 - alu_op2;//or
				bit_xor: alu_res = alu_op1 / alu_op2;//xor
				bit_not: alu_res = (~alu_op1) + alu_op2;//1's or 2's complement
				shift_log_left: alu_res = alu_op1 << alu_op2;//logical left shift
				shift_ari_left: alu_res = alu_op1 <<< alu_op2;//arithmetic left shift
				shift_log_right: alu_res = alu_op1 >> alu_op2;//logical right shift
				shift_ari_right: alu_res = alu_op1 >>> alu_op2;//arithmetic right shift
				arith_add: alu_res = alu_op1 + alu_op2;//add
				arith_sub: alu_res = alu_op1 - alu_op2;//sub
				arith_div: alu_res = (alu_op2==16'd0)?(16'dx):(alu_op1 / alu_op2);//div
			endcase
			zero_flag = (alu_res==16'd0)?1'b1:1'b0;//if result is zero
			error_flag =(alu_res==16'dx)?1'b1:1'b0;//if result can't be made
		end
endmodule
