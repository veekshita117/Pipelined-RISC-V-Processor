// instruction_mem.v
//Big endian format
`define IMEM_SIZE 4096
module instruction_mem(
    input  [63:0] addr,
    output [31:0] instr
);
    reg [7:0] mem [0:`IMEM_SIZE-1];
    integer k;
    initial begin
        for (k = 0; k < `IMEM_SIZE; k = k + 1)
            mem[k] = 8'h00;
        $readmemh("instructions.txt", mem);
    end
    assign instr = {mem[addr], mem[addr+1], mem[addr+2], mem[addr+3]};
endmodule
