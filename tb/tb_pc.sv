module tb_pc;

    logic        clk;
    logic        reset;
    logic [31:0] next_pc;
    logic [31:0] pc;

    pc dut (
        .clk     (clk),
        .reset   (reset),
        .next_pc (next_pc),
        .pc      (pc)
    );

    initial begin
        clk     = 0;
        reset   = 1;
        next_pc = 32'h00000000;

        #10;

        // Release reset
        reset   = 0;

        // First next PC
        next_pc = 32'h00000004;

        #10;

        if (pc !== 32'h00000004)
            $fatal("PC test failed: expected 4, got %h", pc);

        // Second next PC
        next_pc = 32'h00000008;

        #10;

        if (pc !== 32'h00000008)
            $fatal("PC test failed: expected 8, got %h", pc);

        $display("PC test PASSED");

        $finish;
    end

    always #5 clk = ~clk;

endmodule
