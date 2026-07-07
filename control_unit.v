// control_unit.v
module control_unit(
    input  [6:0] opcode,
    output reg   RegWrite,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   Branch,
    output reg   ALUSrc,
    output reg   MemtoReg,
    output reg [1:0] ALUOp
);
    always @(*) begin
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            7'b0110011: begin 
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b10;
            end
            7'b0010011: begin 
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                ALUOp    = 2'b11;
            end
            7'b0000011: begin 
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b0100011: begin 
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b1100011: begin 
                Branch   = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b01;
            end
            default: begin
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end
endmodule
