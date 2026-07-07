// immediate_gen.v
module immediate_gen(
    input  [31:0] instruction,
    output reg [63:0] immediate
);
    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    always @(*) begin
        case (opcode)
            7'b0010011,
            7'b0000011: begin
                immediate = {{52{instruction[31]}}, instruction[31:20]};
            end
            7'b0100011: begin
                immediate = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin
                immediate = {{51{instruction[31]}}, instruction[31], instruction[7],
                              instruction[30:25], instruction[11:8], 1'b0};
            end
            default: immediate = 64'd0;
        endcase
    end
endmodule
