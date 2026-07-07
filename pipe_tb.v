// pipe_tb.v

`include "processor.v"
module pipe_tb;
    reg clk, reset;
    integer cycle_count;
    integer fd;
    integer i;
    processor DUT(
        .clk(clk),
        .reset(reset)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    reg halted;
    initial begin
        cycle_count = 0;
        halted      = 0;
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;
        while (!halted) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            if (DUT.if_instr == 32'h00000000)
                halted = 1;

            if (cycle_count >= 100000) begin
                $display("TIMEOUT at cycle %0d", cycle_count);
                halted = 1;
            end
        end
        cycle_count = cycle_count + 1;
        fd = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1) begin
            if (i == 0)
                $fdisplay(fd, "%016h", 64'd0);
            else
                $fdisplay(fd, "%016h", DUT.RF.regs[i]);
        end
        $fdisplay(fd, "%0d", cycle_count);
        $fclose(fd);
        $finish;
    end
endmodule