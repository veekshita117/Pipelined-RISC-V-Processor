// alu.v
module full_adder(input a, b, cin, output sum, cout);
    wire axorb, aandb, axorb_and_cin;
    xor(axorb, a, b);
    xor(sum, axorb, cin);
    and(aandb, a, b);
    and(axorb_and_cin, axorb, cin);
    or(cout, aandb, axorb_and_cin);
endmodule

module op_add(input [63:0] a, b, output [63:0] res, output cout, output ovf);
    wire [64:0] c;
    assign c[0] = 1'b0;
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin : add_loop
            full_adder fa(a[i], b[i], c[i], res[i], c[i+1]);
        end
    endgenerate
    assign cout = c[64];
    xor(ovf, c[63], c[64]);
endmodule

module op_sub(input [63:0] a, b, output [63:0] res, output cout, output ovf);
    wire [63:0] b_inv;
    wire [64:0] c;
    genvar i;
    generate
        for(i=0; i<64; i=i+1) xor(b_inv[i], b[i], 1'b1);
        assign c[0] = 1'b1;
        for(i=0; i<64; i=i+1) begin : sub_loop
            full_adder fa(a[i], b_inv[i], c[i], res[i], c[i+1]);
        end
    endgenerate
    assign cout = c[64];
    xor(ovf, c[63], c[64]);
endmodule

module op_and(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate for(i=0; i<64; i=i+1) and(res[i], a[i], b[i]); endgenerate
endmodule

module op_or(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate for(i=0; i<64; i=i+1) or(res[i], a[i], b[i]); endgenerate
endmodule

module alu(
    input  [63:0] input1,
    input  [63:0] input2,
    input  [3:0]  control_signal,
    output reg [63:0] result,
    output zero_flag
);
    wire [63:0] w_add, w_sub, w_and, w_or;
    wire c_add, o_add, c_sub, o_sub;

    op_add u1(.a(input1), .b(input2), .res(w_add), .cout(c_add), .ovf(o_add));
    op_sub u2(.a(input1), .b(input2), .res(w_sub), .cout(c_sub), .ovf(o_sub));
    op_and u3(.a(input1), .b(input2), .res(w_and));
    op_or  u4(.a(input1), .b(input2), .res(w_or));

    always @(*) begin
        case(control_signal)
            4'b0000: result = w_add;
            4'b0110: result = w_or;
            4'b0111: result = w_and;
            4'b1000: result = w_sub;
            default: result = 64'd0;
        endcase
    end
    assign zero_flag = (result == 64'd0) ? 1'b1 : 1'b0;
endmodule
