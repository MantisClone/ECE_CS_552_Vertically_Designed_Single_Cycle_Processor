module cpu(hlt, clk, rst_n);

input clk, rst_n;
output hlt;


/************************ IF *************************************************/

// IF stage wires
wire [15:0] instr_IF_ID_EX;
wire [15:0] pc_IF_ID_EX_MEM_WB, alt_pc_IF;
wire alt_pc_ctrl_IF;


// Instantiate IF
IF instruction_fetch(	
	// Output
	.instr(instr_IF_ID_EX),
	.pc(pc_IF_ID_EX_MEM_WB),
	// Input
	.clk(clk),
	.rst_n(rst_n),
	.hlt(hlt),
	.alt_pc_ctrl(alt_pc_ctrl_IF),
	.alt_pc(alt_pc_IF)
	);
	
	assign alt_pc_ctrl_IF = (j_ctrl_ID || b_ctrl_EX);
	assign alt_pc_IF = 	(j_ctrl_ID) ? j_pc_ID:
						(b_ctrl_EX) ? b_pc_EX:
										16'hxxxx;
	
/************************ IF *************************************************/
	
	
	
	
// IF_ID Flip Flop ////////////////////////////////////////////////////////////
IF_ID IF_ID_FF(
	// Output
	.instr_ID(instr_ID_EX),
	.pc_ID(pc_ID_EX_MEM_WB),
	// Inputs
	.instr_IF(instr_IF_ID_EX),
	.pc_IF(pc_IF_ID_EX_MEM_WB),
	.clk(clk),
	.rst_n(rst_n),
	.stall(stall)
	);
///////////////////////////////////////////////////////////////////////////////



/************************ ID *************************************************/

// ID stage wires
wire [15:0] instr_ID_EX;
wire [15:0]pc_ID_EX_MEM_WB, j_pc_ID;
wire [15:0] p0_ID_EX, p1_ID_EX;
wire [7:0] imm8_ID_EX;
wire [3:0] shamt_ID_EX;
wire [2:0] func_ID_EX;
wire we_mem_ID_EX_MEM, re_mem_ID_EX_MEM, wb_sel_ID_EX_MEM_WB, src1sel_ID_EX,
	we_rf_ID_EX_MEM_WB, j_ctrl_ID;

// Instantiate ID
ID instruction_decode(	
	// Output
	.p0(p0_ID_EX),
	.p1(p1_ID_EX),
	.shamt(shamt_ID_EX),
	.func(func_ID_EX),
	.src1sel(src1sel_ID_EX),
	.hlt(hlt),
	.imm8(imm8_ID_EX),
	.we_rf(we_rf_ID_EX_MEM_WB),
	.we_mem(we_mem_ID_EX_MEM),
	.re_mem(re_mem_ID_EX_MEM),
	.wb_sel(wb_sel_ID_EX_MEM_WB),
	.dst_addr_new(dst_addr_ID_EX_MEM_WB),
	.j_pc(j_pc_ID),
	.j_ctrl(j_ctrl_ID),
	// Input
	.instr(instr_ID_EX),
	.pc(pc_ID_EX_MEM_WB),
	.clk(clk),
	.rst_n(rst_n),
	.dst(wb_data_WB),
	.dst_addr(dst_addr_WB)
	.we_WB(we_rf_WB);
	);
	
/************************ ID *************************************************/
	
	
	
// ID_EX Flip Flop ////////////////////////////////////////////////////////////
ID_EX ID_EX_FF(
	// Output
	.p0_EX(p0_EX),
	.p1_EX(p1_EX),
	.shamt_EX(shamt_EX),
	.func_EX(func_EX),
	.imm8_EX(imm8_EX),
	.we_rf_EX(we_rf_EX_MEM_WB),
	.we_mem_EX(we_mem_EX_MEM),
	.re_mem_EX(re_mem_EX_MEM),
	.wb_sel_EX(wb_sel_EX_MEM_WB),
	.src1sel_EX(src1sel_EX),
	.instr_EX(instr_EX),
	.pc_EX(pc_EX_MEM_WB),
	// Input
	.p0_ID(p0_ID_EX),
	.p1_ID(p1_ID_EX),
	.shamt_ID(shamt_ID_EX),
	.func_ID(func_ID_EX),
	.imm8_ID(imm8_ID_EX),
	.we_rf_ID(we_rf_ID_EX_MEM_WB);
	.we_mem_ID(we_mem_ID_EX_MEM),
	.re_mem_ID(re_mem_ID_EX_MEM),
	.wb_sel_ID(wb_sel_ID_EX_MEM_WB),
	.src1sel_ID(src1sel_ID_EX),
	.clk(clk),
	.rst_n(rst_n),
	.stall(stall)
	);
///////////////////////////////////////////////////////////////////////////////



/************************ EX *************************************************/

// EX stage wires
wire [15:0] p0_EX, p1_EX, jump_reg_EX, instr_EX, pc_EX_MEM_WB, b_pc_EX;
wire [7:0] imm8_EX;
wire [3:0] shamt_EX;
wire [2:0] func_EX;
wire src1sel_EX, we_mem_EX_MEM, re_mem_EX_MEM, wb_sel_EX_MEM_WB, we_rf_EX_MEM_WB;
wire N_EX_MEM, Z_EX_MEM, V_EX_MEM, b_ctrl_EX;


// Instantiate EX
EX execution(
	// Output
	.dst(alu_result_EX_MEM_WB),
	.N(N_EX_MEM),
	.Z(Z_EX_MEM),
	.V(V_EX_MEM),
	.br_pc(b_pc_EX),
	.br_ctrl(b_ctrl_EX),
	// Input
	.clk(clk),
	.rst_n(rst_n),
	.func(func_EX),
	.shamt(shamt_EX),
	.src1sel(src1sel_EX),
	.p0(p0_EX),
	.imm8(imm8_EX),
	.p1(p1_EX)
	);
	
assign sdata_EX_MEM = p0_EX;

/************************ EX *************************************************/


	
// EX_MEM Flip Flop ///////////////////////////////////////////////////////////
EX_MEM EX_MEM_FF(
	// Outputs
	.sdata_MEM(sdata_MEM),
	.we_rf_MEM(we_rf_MEM_WB),
	.we_mem_MEM(we_mem_MEM),
	.re_mem_MEM(re_mem_MEM),
	.alu_result_MEM(alu_result_MEM_WB),
	.wb_sel_MEM(wb_sel_MEM_WB),
	.pc_MEM(pc_MEM_WB),
	//Inputs
	.sdata_EX(sdata_EX_MEM),
	.we_rf_EX(we_rf_EX_MEM_WB),
	.we_mem_EX(we_mem_EX_MEM),
	.re_mem_EX(re_mem_EX_MEM),
	.alu_result_EX(alu_result_EX_MEM_WB),
	.wb_sel_EX(wb_sel_EX_MEM_WB),
	.pc_EX(pc_EX_MEM_WB),
	.clk(clk),
	.rst_n(rst_n),
	.stall(stall)
	);
///////////////////////////////////////////////////////////////////////////////



/************************ MEM *************************************************/

// MEM stage wires
wire wb_sel_MEM_WB, we_rf_MEM_WB, we_mem_MEM, re_mem_MEM;
wire [15:0] alu_result_MEM_WB, sdata_MEM, pc_MEM_WB, ldata_MEM_WB;

MEM memory(
	// Output
	.ldata(ldata_MEM_WB),
	//.alu_result(alu_result_MEM_WB),
	// Input
	.sdata(sdata_MEM),
	.re_mem(re_mem_MEM),
	.we_mem(we_mem_MEM),
	.clk(clk),
	.addr(addr_mem_MEM),
	);
	
assign addr_mem_MEM = alu_result_MEM_WB;
	
/************************ MEM *************************************************/



// MEM_WB Flip Flop ///////////////////////////////////////////////////////////
MEM_WB MEM_WB_FF(
	// Outputs
	.ldata_WB(ldata_WB),
	.alu_result_WB(alu_result_WB),
	.we_rf_WB(we_rf_WB),
	.wb_sel_WB(wb_sel_WB),
	.pc_WB(pc_WB),
	// Inputs
	.ldata_MEM(ldata_MEM_WB),
	.alu_result_MEM(alu_result_MEM_WB),
	.we_rf_MEM(we_rf_MEM_WB),
	.wb_sel_MEM(wb_sel_MEM_WB),
	.pc_MEM(pc_MEM_WB),
	.clk(clk),
	.rst_n(rst_n),
	.stall(stall)
	);
///////////////////////////////////////////////////////////////////////////////



/************************ WB *************************************************/
wire [15:0] wb_data_WB, pc_WB, alu_result_WB, ldata_WB;
wire we_rf_WB;

WB write_back(
	// Output
	.wb_data(wb_data_WB),
	// Input
	.pc_jal(pc_WB),
	.wb_sel(wb_sel_WB),
	.rd_data(ldata_WB),
	.alu_result(alu_result_WB)
	);
	
/************************ WB *************************************************/

endmodule