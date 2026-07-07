// pipeline_regs.v
module if_id_reg(
    input         clk,
    input         reset,
    input         stall,
    input         flush,
    input  [31:0] if_instr,
    input  [63:0] if_pc_plus4,
    output reg [31:0] id_instr,
    output reg [63:0] id_pc_plus4
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_instr    <= 32'd0;
            id_pc_plus4 <= 64'd0;
        end else if (flush) begin
            id_instr    <= 32'd0;
            id_pc_plus4 <= 64'd0;
        end else if (!stall) begin
            id_instr    <= if_instr;
            id_pc_plus4 <= if_pc_plus4;
        end
    end
endmodule


module id_ex_reg(
    input         clk,
    input         reset,
    input         flush,
    input         id_RegWrite,
    input         id_MemRead,
    input         id_MemWrite,
    input         id_Branch,
    input         id_ALUSrc,
    input         id_MemtoReg,
    input  [1:0]  id_ALUOp,
    input  [63:0] id_read_data1,
    input  [63:0] id_read_data2,
    input  [63:0] id_immediate,
    input  [63:0] id_pc_plus4,
    input  [4:0]  id_rs1,
    input  [4:0]  id_rs2,
    input  [4:0]  id_rd,
    input  [2:0]  id_funct3,
    input  [6:0]  id_funct7,
    output reg        ex_RegWrite,
    output reg        ex_MemRead,
    output reg        ex_MemWrite,
    output reg        ex_Branch,
    output reg        ex_ALUSrc,
    output reg        ex_MemtoReg,
    output reg [1:0]  ex_ALUOp,
    output reg [63:0] ex_read_data1,
    output reg [63:0] ex_read_data2,
    output reg [63:0] ex_immediate,
    output reg [63:0] ex_pc_plus4,
    output reg [4:0]  ex_rs1,
    output reg [4:0]  ex_rs2,
    output reg [4:0]  ex_rd,
    output reg [2:0]  ex_funct3,
    output reg [6:0]  ex_funct7
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ex_RegWrite   <= 1'b0;
            ex_MemRead    <= 1'b0;
            ex_MemWrite   <= 1'b0;
            ex_Branch     <= 1'b0;
            ex_ALUSrc     <= 1'b0;
            ex_MemtoReg   <= 1'b0;
            ex_ALUOp      <= 2'b00;
            ex_read_data1 <= 64'd0;
            ex_read_data2 <= 64'd0;
            ex_immediate  <= 64'd0;
            ex_pc_plus4   <= 64'd0;
            ex_rs1        <= 5'd0;
            ex_rs2        <= 5'd0;
            ex_rd         <= 5'd0;
            ex_funct3     <= 3'd0;
            ex_funct7     <= 7'd0;
        end else begin
            ex_RegWrite   <= id_RegWrite;
            ex_MemRead    <= id_MemRead;
            ex_MemWrite   <= id_MemWrite;
            ex_Branch     <= id_Branch;
            ex_ALUSrc     <= id_ALUSrc;
            ex_MemtoReg   <= id_MemtoReg;
            ex_ALUOp      <= id_ALUOp;
            ex_read_data1 <= id_read_data1;
            ex_read_data2 <= id_read_data2;
            ex_immediate  <= id_immediate;
            ex_pc_plus4   <= id_pc_plus4;
            ex_rs1        <= id_rs1;
            ex_rs2        <= id_rs2;
            ex_rd         <= id_rd;
            ex_funct3     <= id_funct3;
            ex_funct7     <= id_funct7;
        end
    end
endmodule
module ex_mem_reg(
    input         clk,
    input         reset,
    input         ex_RegWrite,
    input         ex_MemRead,
    input         ex_MemWrite,
    input         ex_Branch,
    input         ex_MemtoReg,
    input  [63:0] ex_alu_result,
    input  [63:0] ex_write_data,
    input  [63:0] ex_branch_target,
    input         ex_zero,
    input  [4:0]  ex_rd,
    output reg        mem_RegWrite,
    output reg        mem_MemRead,
    output reg        mem_MemWrite,
    output reg        mem_Branch,
    output reg        mem_MemtoReg,
    output reg [63:0] mem_alu_result,
    output reg [63:0] mem_write_data,
    output reg [63:0] mem_branch_target,
    output reg        mem_zero,
    output reg [4:0]  mem_rd
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_RegWrite      <= 1'b0;
            mem_MemRead       <= 1'b0;
            mem_MemWrite      <= 1'b0;
            mem_Branch        <= 1'b0;
            mem_MemtoReg      <= 1'b0;
            mem_alu_result    <= 64'd0;
            mem_write_data    <= 64'd0;
            mem_branch_target <= 64'd0;
            mem_zero          <= 1'b0;
            mem_rd            <= 5'd0;
        end else begin
            mem_RegWrite      <= ex_RegWrite;
            mem_MemRead       <= ex_MemRead;
            mem_MemWrite      <= ex_MemWrite;
            mem_Branch        <= ex_Branch;
            mem_MemtoReg      <= ex_MemtoReg;
            mem_alu_result    <= ex_alu_result;
            mem_write_data    <= ex_write_data;
            mem_branch_target <= ex_branch_target;
            mem_zero          <= ex_zero;
            mem_rd            <= ex_rd;
        end
    end
endmodule

module mem_wb_reg(
    input         clk,
    input         reset,
    input         mem_RegWrite,
    input         mem_MemtoReg,
    input  [63:0] mem_read_data,
    input  [63:0] mem_alu_result,
    input  [4:0]  mem_rd,
    output reg        wb_RegWrite,
    output reg        wb_MemtoReg,
    output reg [63:0] wb_read_data,
    output reg [63:0] wb_alu_result,
    output reg [4:0]  wb_rd
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_RegWrite   <= 1'b0;
            wb_MemtoReg   <= 1'b0;
            wb_read_data  <= 64'd0;
            wb_alu_result <= 64'd0;
            wb_rd         <= 5'd0;
        end else begin
            wb_RegWrite   <= mem_RegWrite;
            wb_MemtoReg   <= mem_MemtoReg;
            wb_read_data  <= mem_read_data;
            wb_alu_result <= mem_alu_result;
            wb_rd         <= mem_rd;
        end
    end
endmodule
