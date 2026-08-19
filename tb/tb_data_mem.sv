module tb_data_mem;

    logic        clk;

    logic        mem_write;
    logic        mem_read;

    logic [31:0] addr;
    logic [31:0] write_data;
    logic [1:0] mem_size;
    logic       mem_unsigned;

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
        .mem_size     (mem_size),
        .mem_unsigned (mem_unsigned),

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

        mem_size     = 2'b10;  // word
        mem_unsigned = 1'b0;


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
        // LB - positive byte
        // address 33 is byte offset +1 from address 32
        // memory[32] currently contains 123 = 0x0000007B
        // =====================================================

        addr      = 32'd33;
        mem_size  = 2'b00;      // byte
        mem_read  = 1'b1;

        #1;

        if (read_data !== 32'h00000000)
            $fatal(
                "LB positive byte failed: got %h",
                read_data
            );

        mem_read = 1'b0;


        // =====================================================
        // Prepare a word containing bytes:
        // address 36:
        //   +0 = 0x7F
        //   +1 = 0x80
        // =====================================================

        addr       = 32'd36;
        write_data = 32'h0000807F;
        mem_size   = 2'b10;      // word
        mem_write  = 1'b1;

        @(posedge clk);
        #1;

        mem_write = 1'b0;


        // =====================================================
        // LB 0x7F
        // =====================================================

        addr      = 32'd36;
        mem_size  = 2'b00;
        mem_read  = 1'b1;

        #1;

        if (read_data !== 32'h0000007F)
            $fatal(
                "LB 0x7F failed: got %h",
                read_data
            );

        mem_read = 1'b0;


        // =====================================================
        // LB 0x80
        // Must sign-extend to FFFFFF80
        // =====================================================

        addr      = 32'd37;
        mem_size  = 2'b00;
        mem_read  = 1'b1;

        #1;

        if (read_data !== 32'hFFFFFF80)
            $fatal(
                "LB 0x80 sign extension failed: got %h",
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