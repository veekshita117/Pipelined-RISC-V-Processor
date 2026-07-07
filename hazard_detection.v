// hazard_detection.v
module hazard_detection(
    input        ex_MemRead,
    input  [4:0] ex_rd,
    input  [4:0] id_rs1,
    input  [4:0] id_rs2,
    output reg   stall_pc,
    output reg   stall_if_id,
    output reg   flush_id_ex
);
    always @(*) begin
        if (ex_MemRead &&
            ((ex_rd == id_rs1) || (ex_rd == id_rs2)) &&
            (ex_rd != 5'd0)) begin
            stall_pc    = 1'b1;
            stall_if_id = 1'b1;
            flush_id_ex = 1'b1;
        end else begin
            stall_pc    = 1'b0;
            stall_if_id = 1'b0;
            flush_id_ex = 1'b0;
        end
    end
endmodule
