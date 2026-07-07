`include "pc.v"
`include "instruction_mem.v"
`include "pipeline_regs.v"
`include "control_unit.v"
`include "register_file.v"
`include "immediate_gen.v"
`include "alu_control.v"
`include "alu.v"
`include "forwarding_unit.v"
`include "hazard_detection.v"
`include "data_memory.v"

module processor(
    input clk,
    input reset
);

wire        mem_RegWrite;
wire [4:0]  mem_rd;
wire [63:0] mem_alu_result;
wire        mem_MemRead;
wire        mem_MemWrite;
wire        mem_MemtoReg;
wire [63:0] mem_write_data;

wire        wb_RegWrite;
wire [4:0]  wb_rd;
wire        wb_MemtoReg;
wire [63:0] wb_read_data;
wire [63:0] wb_alu_result;
wire [63:0] wb_write_data;
assign wb_write_data = wb_MemtoReg ? wb_read_data : wb_alu_result;

wire        ex_MemRead;
wire [4:0]  ex_rd;

wire        ex_Branch_out;
wire        ex_zero;
wire [63:0] ex_branch_target;

wire branch_taken;
assign branch_taken = ex_Branch_out & ex_zero;

wire stall_pc, stall_if_id, flush_id_ex;

wire flush_if_id_sig = branch_taken;
wire flush_id_ex_sig = flush_id_ex | branch_taken;

wire [63:0] pc_out;
wire [63:0] pc_plus4;
wire [63:0] pc_next;
wire [31:0] if_instr;

assign pc_plus4 = pc_out + 64'd4;
assign pc_next  = branch_taken ? ex_branch_target : pc_plus4;

pc PC(
    .clk(clk),
    .reset(reset),
    .stall(stall_pc),
    .pc_in(pc_next),
    .pc_out(pc_out)
);

instruction_mem IMEM(
    .addr(pc_out),
    .instr(if_instr)
);

wire [31:0] id_instr;
wire [63:0] id_pc_plus4;

if_id_reg IF_ID(
    .clk(clk),
    .reset(reset),
    .stall(stall_if_id),
    .flush(flush_if_id_sig),
    .if_instr(if_instr),
    .if_pc_plus4(pc_plus4),
    .id_instr(id_instr),
    .id_pc_plus4(id_pc_plus4)
);

wire [4:0]  id_rs1    = id_instr[19:15];
wire [4:0]  id_rs2    = id_instr[24:20];
wire [4:0]  id_rd     = id_instr[11:7];
wire [2:0]  id_funct3 = id_instr[14:12];
wire [6:0]  id_funct7 = id_instr[31:25];

wire id_RegWrite, id_MemRead, id_MemWrite, id_Branch, id_ALUSrc, id_MemtoReg;
wire [1:0] id_ALUOp;

control_unit CU(
    .opcode(id_instr[6:0]),
    .RegWrite(id_RegWrite),
    .MemRead(id_MemRead),
    .MemWrite(id_MemWrite),
    .Branch(id_Branch),
    .ALUSrc(id_ALUSrc),
    .MemtoReg(id_MemtoReg),
    .ALUOp(id_ALUOp)
);

wire [63:0] id_read_data1, id_read_data2;

register_file RF(
    .clk(clk),
    .reset(reset),
    .read_reg1(id_rs1),
    .read_reg2(id_rs2),
    .write_reg(wb_rd),
    .write_data(wb_write_data),
    .reg_write_en(wb_RegWrite),
    .read_data1(id_read_data1),
    .read_data2(id_read_data2)
);

wire [63:0] id_immediate;
immediate_gen IMM(
    .instruction(id_instr),
    .immediate(id_immediate)
);

hazard_detection HDU(
    .ex_MemRead(ex_MemRead),
    .ex_rd(ex_rd),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),
    .stall_pc(stall_pc),
    .stall_if_id(stall_if_id),
    .flush_id_ex(flush_id_ex)
);

wire        ex_RegWrite, ex_MemWrite, ex_ALUSrc, ex_MemtoReg;
wire [1:0]  ex_ALUOp;
wire [63:0] ex_read_data1, ex_read_data2, ex_immediate, ex_pc_plus4;
wire [4:0]  ex_rs1, ex_rs2;
wire [2:0]  ex_funct3;
wire [6:0]  ex_funct7;

id_ex_reg ID_EX(
    .clk(clk),
    .reset(reset),
    .flush(flush_id_ex_sig),
    .id_RegWrite(id_RegWrite),
    .id_MemRead(id_MemRead),
    .id_MemWrite(id_MemWrite),
    .id_Branch(id_Branch),
    .id_ALUSrc(id_ALUSrc),
    .id_MemtoReg(id_MemtoReg),
    .id_ALUOp(id_ALUOp),
    .id_read_data1(id_read_data1),
    .id_read_data2(id_read_data2),
    .id_immediate(id_immediate),
    .id_pc_plus4(id_pc_plus4),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),
    .id_rd(id_rd),
    .id_funct3(id_funct3),
    .id_funct7(id_funct7),
    .ex_RegWrite(ex_RegWrite),
    .ex_MemRead(ex_MemRead),
    .ex_MemWrite(ex_MemWrite),
    .ex_Branch(ex_Branch_out),
    .ex_ALUSrc(ex_ALUSrc),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_ALUOp(ex_ALUOp),
    .ex_read_data1(ex_read_data1),
    .ex_read_data2(ex_read_data2),
    .ex_immediate(ex_immediate),
    .ex_pc_plus4(ex_pc_plus4),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .ex_rd(ex_rd),
    .ex_funct3(ex_funct3),
    .ex_funct7(ex_funct7)
);

wire [1:0] ForwardA, ForwardB;

forwarding_unit FWU(
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .mem_RegWrite(mem_RegWrite),
    .mem_rd(mem_rd),
    .wb_RegWrite(wb_RegWrite),
    .wb_rd(wb_rd),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

wire [63:0] alu_input_a;
assign alu_input_a = (ForwardA == 2'b10) ? mem_alu_result :
                     (ForwardA == 2'b01) ? wb_write_data  :
                                           ex_read_data1;

wire [63:0] ex_rs2_forwarded;
assign ex_rs2_forwarded = (ForwardB == 2'b10) ? mem_alu_result :
                          (ForwardB == 2'b01) ? wb_write_data  :
                                                ex_read_data2;

wire [63:0] alu_input_b;
assign alu_input_b = ex_ALUSrc ? ex_immediate : ex_rs2_forwarded;

wire [3:0] alu_ctrl;
alu_control ALUCTRL(
    .ALUOp(ex_ALUOp),
    .funct3(ex_funct3),
    .funct7(ex_funct7),
    .alu_ctrl(alu_ctrl)
);

wire [63:0] ex_alu_result;

alu ALU(
    .input1(alu_input_a),
    .input2(alu_input_b),
    .control_signal(alu_ctrl),
    .result(ex_alu_result),
    .zero_flag(ex_zero)
);

assign ex_branch_target = (ex_pc_plus4 - 64'd4) + ex_immediate;

wire [63:0] ex_store_data;
assign ex_store_data = ex_rs2_forwarded;

wire mem_branch_unused, mem_zero_unused;
wire [63:0] mem_branch_target_unused;

ex_mem_reg EX_MEM(
    .clk(clk),
    .reset(reset),
    .ex_RegWrite(ex_RegWrite),
    .ex_MemRead(ex_MemRead),
    .ex_MemWrite(ex_MemWrite),
    .ex_Branch(ex_Branch_out),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_alu_result(ex_alu_result),
    .ex_write_data(ex_store_data),
    .ex_branch_target(ex_branch_target),
    .ex_zero(ex_zero),
    .ex_rd(ex_rd),
    .mem_RegWrite(mem_RegWrite),
    .mem_MemRead(mem_MemRead),
    .mem_MemWrite(mem_MemWrite),
    .mem_Branch(mem_branch_unused),
    .mem_MemtoReg(mem_MemtoReg),
    .mem_alu_result(mem_alu_result),
    .mem_write_data(mem_write_data),
    .mem_branch_target(mem_branch_target_unused),
    .mem_zero(mem_zero_unused),
    .mem_rd(mem_rd)
);

wire [63:0] mem_read_data;

data_memory DMEM(
    .clk(clk),
    .address(mem_alu_result),
    .write_data(mem_write_data),
    .MemRead(mem_MemRead),
    .MemWrite(mem_MemWrite),
    .read_data(mem_read_data)
);

mem_wb_reg MEM_WB(
    .clk(clk),
    .reset(reset),
    .mem_RegWrite(mem_RegWrite),
    .mem_MemtoReg(mem_MemtoReg),
    .mem_read_data(mem_read_data),
    .mem_alu_result(mem_alu_result),
    .mem_rd(mem_rd),
    .wb_RegWrite(wb_RegWrite),
    .wb_MemtoReg(wb_MemtoReg),
    .wb_read_data(wb_read_data),
    .wb_alu_result(wb_alu_result),
    .wb_rd(wb_rd)
);

endmodule