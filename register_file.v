module register_file(
    input         clk,
    input         reset,
    input  [4:0]  read_reg1,
    input  [4:0]  read_reg2,
    input  [4:0]  write_reg,
    input  [63:0] write_data,
    input         reg_write_en,
    output [63:0] read_data1,
    output [63:0] read_data2
);
    reg [63:0] regs [0:31];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 64'd0;
        end else begin
            if (reg_write_en && write_reg != 5'd0)
                regs[write_reg] <= write_data;
        end
    end

    assign read_data1 = (read_reg1 == 5'd0) ? 64'd0 :
                        (reg_write_en && write_reg == read_reg1 && write_reg != 5'd0) ? write_data :
                        regs[read_reg1];

    assign read_data2 = (read_reg2 == 5'd0) ? 64'd0 :
                        (reg_write_en && write_reg == read_reg2 && write_reg != 5'd0) ? write_data :
                        regs[read_reg2];
endmodule