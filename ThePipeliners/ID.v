// Author:  David Mateo, R. Scott Carson
// Instruction Decode Stage
// This module is the top level module representing the ID stage.
module ID(
	// Output //
	p0, 
	p1, 
	shamt, 
	func, 
	src1sel, 
	hlt, 
	imm8, 
	we_rf, 
	we_mem, 
	re_mem, 
	wb_sel, 
	dst_addr_new, 
	j_pc,
	j_ctrl,
	// Input
	instr, 
	pc, 
	clk, 
	rst_n, 
	dst_data_WB, 
	dst_addr_WB, 
	we_WB,
	hlt_WB
	);
	
	// Inputs //
	input [15:0] instr, pc, dst_data_WB;
	input [3:0] dst_addr_WB;
	input clk, rst_n, we_WB, hlt_WB;
	
	// Outputs //
 	output [15:0] p0, p1, j_pc;
	output [7:0] imm8;
	output [3:0] shamt, dst_addr_new;
	output [2:0] func;
	output hlt, src1sel;
	output re_mem, we_mem, wb_sel, j_ctrl, we_rf;
	
	// Local Wires //
	wire [15:0] dst_data;
	wire [3:0] p0_addr, p1_addr, dst_addr;
	wire re0, re1, we;
	
	// Relevant Opcodes
	localparam jalOp = 4'b1101;
	localparam jrOp = 4'b1110;
	
	I_DECODE inst_decoder(	//Inputs
							.instr(instr),
							.PC(pc),
							// Outputs
							.p0_addr(p0_addr),
							.re0(re0),
							.p1_addr(p1_addr),
							.re1(re1),
							.dst_addr(dst_addr_new),
							.we_rf(we_rf),
							.hlt(hlt),
							.src1sel(src1sel),
							.shamt(shamt),
							.func(func),
							.imm8(imm8),
							.re_mem(re_mem),
							.we_mem(we_mem),
							.wb_sel(wb_sel)
						);
						
	rf regF(
				// Output
				.p0(p0), 
				.p1(p1), 
				// Input
				.clk(clk), 
				.p0_addr(p0_addr), 
				.p1_addr(p1_addr), 
				.re0(re0), 
				.re1(re1), 
				.dst_addr(dst_addr_WB), 
				.dst(dst_data_WB), 
				.we(we_WB), 
				.hlt(hlt_WB)
			);

	// The Jump logic below is necessary because as soon as we know 
	// that we're jumping, we want to process it immediately without
	// sending it through the EX stage and beyond.  This makes it so no
	// flushes are necessary on jumps.		
	assign j_ctrl = ((instr[15:12] == jalOp)||(instr[15:12] == jrOp));
	assign j_pc = 	(instr[15:12] == jalOp) ? (pc+instr[11:0]):
					(instr[15:12] == jrOp) 	? p0:
											  16'hxxxx;	

	// Arguably, this statement could be in WB, but I decided to put it here.
	assign dst_data = (instr[15:12] == jalOp)	?	(pc+1)	:	dst_data_WB;

	// The following line is duplicated inside of instr_decode but I copied it here too.
	// I didn't remove the other one because unsure if it's necessary, but it has
	// no bearing on this dst_addr.
	assign dst_addr = (instr[15:12] == jalOp)	? 	4'b1111	:	dst_addr_WB;

	// If it's a jal, we want to be able to write to R15 right away.
	assign we 		= (instr[15:12] == jalOp)	? 	1'b1 	:	we_WB;

endmodule