// data_memory.v
module data_memory(
    input         clk,
    input  [63:0] address,
    input  [63:0] write_data,
    input         MemRead,
    input         MemWrite,
    output reg [63:0] read_data
);
    reg [7:0] mem [0:1023];
    integer k;
    initial begin
        for (k = 0; k < 1024; k = k + 1)
            mem[k] = 8'd0;
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            mem[address]   <= write_data[63:56];
            mem[address+1] <= write_data[55:48];
            mem[address+2] <= write_data[47:40];
            mem[address+3] <= write_data[39:32];
            mem[address+4] <= write_data[31:24];
            mem[address+5] <= write_data[23:16];
            mem[address+6] <= write_data[15:8];
            mem[address+7] <= write_data[7:0];
        end
    end

    always @(*) begin
        if (MemRead)
            read_data = {mem[address],   mem[address+1], mem[address+2], mem[address+3],
                         mem[address+4], mem[address+5], mem[address+6], mem[address+7]};
        else
            read_data = 64'd0;
    end
endmodule
