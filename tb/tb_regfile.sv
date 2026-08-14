module tb_regfile;

    logic        clk;

    logic [4:0]  rs1;
    logic [4:0]  rs2;

    logic [4:0]  rd;
    logic [31:0] write_data;
    logic        write_en;

    logic [31:0] read_data1;
    logic [31:0] read_data2;

    regfile dut (
        .clk        (clk),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (write_data),
        .write_en   (write_en),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );
    

    initial begin

        clk = 0;

        // Read x0 and x0
        rs1 = 5'd0;
        rs2 = 5'd0;

        #1;

        if (read_data1 !== 32'd0)
            $fatal("x0 read failed");

        if (read_data2 !== 32'd0)
            $fatal("x0 read failed");

        // Write 10 to x6
        rd = 5'd6;
        write_data = 32'd10;
        write_en = 1;

        #9;

        // Write 20 to x7
        rd = 5'd7;
        write_data = 32'd20;

        #10;

        write_en = 0;

        // Read x6 and x7
        rs1 = 5'd6;
        rs2 = 5'd7;

        #1;

        if (read_data1 !== 32'd10)
            $fatal("x6 read failed: got %d", read_data1);

        if (read_data2 !== 32'd20)
            $fatal("x7 read failed: got %d", read_data2);

        // Try to write to x0
        rd = 5'd0;
        write_data = 32'd999;
        write_en = 1;

        #10;

        write_en = 0;

        rs1 = 5'd0;

        #1;

        if (read_data1 !== 32'd0)
            $fatal("x0 was modified!");

        $display("Register File test PASSED");

        $finish;
    end

    always #5 clk = ~clk;

endmodule