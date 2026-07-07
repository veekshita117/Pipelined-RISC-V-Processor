module forwarding_unit(
    input  [4:0] ex_rs1,
    input  [4:0] ex_rs2,
    input        mem_RegWrite,
    input  [4:0] mem_rd,
    input        wb_RegWrite,
    input  [4:0] wb_rd,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @(*) begin
        if (mem_RegWrite && (mem_rd != 5'd0) && (mem_rd == ex_rs1))
            ForwardA = 2'b10;
        else if (wb_RegWrite && (wb_rd != 5'd0) && (wb_rd == ex_rs1))
            ForwardA = 2'b01;
        else
            ForwardA = 2'b00;

        if (mem_RegWrite && (mem_rd != 5'd0) && (mem_rd == ex_rs2))
            ForwardB = 2'b10;
        else if (wb_RegWrite && (wb_rd != 5'd0) && (wb_rd == ex_rs2))
            ForwardB = 2'b01;
        else
            ForwardB = 2'b00;
    end
endmodule