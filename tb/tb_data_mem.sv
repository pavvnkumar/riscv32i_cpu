module tb_data_mem;

    logic        clk;

    logic        mem_write;
    logic        mem_read;

    logic [31:0] addr;
    logic [31:0] write_data;

    logic [31:0] read_data;


    // =========================================================
    // DUT
    // =========================================================

    data_mem dut (
        .clk        (clk),

        .mem_write  (mem_write),
        .mem_read   (mem_read),

        .addr       (addr),
        .write_data (write_data),

        .read_data  (read_data)
    );


    // =========================================================
    // Clock
    // =========================================================

    always #5 clk = ~clk;


    // =========================================================
    // Test
    // =========================================================

    initial begin

        clk        = 1'b0;

        mem_write  = 1'b0;
        mem_read   = 1'b0;

        addr       = 32'b0;
        write_data = 32'b0;


        // =====================================================
        // WRITE
        // memory address 32
        // =====================================================

        addr       = 32'd32;
        write_data = 32'd123;
        mem_write  = 1'b1;

        @(posedge clk);
        #1;

        mem_write = 1'b0;


        // =====================================================
        // READ
        // =====================================================

        mem_read = 1'b1;

        #1;

        if (read_data !== 32'd123)
            $fatal(
                "READ after WRITE failed: got %0d",
                read_data
            );

        mem_read = 1'b0;


        // =====================================================
        // WRITE second address
        // =====================================================

        addr       = 32'd64;
        write_data = 32'hAAAAAAAA;
        mem_write  = 1'b1;

        @(posedge clk);
        #1;

        mem_write = 1'b0;


        // =====================================================
        // READ second address
        // =====================================================

        mem_read = 1'b1;

        #1;

        if (read_data !== 32'hAAAAAAAA)
            $fatal(
                "Second address read failed: got %h",
                read_data
            );

        mem_read = 1'b0;


        // =====================================================
        // Verify first address was not changed
        // =====================================================

        addr      = 32'd32;
        mem_read  = 1'b1;

        #1;

        if (read_data !== 32'd123)
            $fatal(
                "Memory address isolation failed: got %0d",
                read_data
            );

        mem_read = 1'b0;


        // =====================================================
        // PASSED
        // =====================================================

        $display("");
        $display("==============================");
        $display(" DATA MEMORY TEST PASSED");
        $display("==============================");

        $display("memory[32] = %0d", 32'd123);
        $display("memory[64] = %h", 32'hAAAAAAAA);

        $display("==============================");
        $display("");

        $finish;

    end

endmodule