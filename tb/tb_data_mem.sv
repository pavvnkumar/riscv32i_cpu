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

        // ========================================
        // LB / LBU byte-load verification
        // ========================================

        // Store 0x0000007F
        write_data   = 32'h0000007F;
        addr         = 32'h00000010;
        mem_write    = 1'b1;

        @(posedge clk);
        #1;

        mem_write = 1'b0;


        // ----------------------------------------
        // LB 0x7F -> 0x0000007F
        // ----------------------------------------

        mem_read     = 1'b1;
        mem_size     = 2'b00;
        mem_unsigned = 1'b0;
        addr         = 32'h00000010;

        #1;

        if (read_data !== 32'h0000007F)
            $fatal("LB 0x7F failed: %h", read_data);


        // ----------------------------------------
        // LBU 0x7F -> 0x0000007F
        // ----------------------------------------

        mem_unsigned = 1'b1;

        #1;

        if (read_data !== 32'h0000007F)
            $fatal("LBU 0x7F failed: %h", read_data);


        // ----------------------------------------
        // Store 0x00000080
        // ----------------------------------------

        mem_read   = 1'b0;
        mem_write  = 1'b1;
        write_data = 32'h00000080;
        addr       = 32'h00000014;

        @(posedge clk);
        #1;

        mem_write = 1'b0;


        // ----------------------------------------
        // LB 0x80 -> 0xFFFFFF80
        // ----------------------------------------

        mem_read     = 1'b1;
        mem_unsigned = 1'b0;
        addr         = 32'h00000014;

        #1;

        if (read_data !== 32'hFFFFFF80)
            $fatal("LB 0x80 sign extension failed: %h", read_data);


        // ----------------------------------------
        // LBU 0x80 -> 0x00000080
        // ----------------------------------------

        mem_unsigned = 1'b1;

        #1;

        if (read_data !== 32'h00000080)
            $fatal("LBU 0x80 zero extension failed: %h", read_data);

        mem_read = 1'b0;

        $display("LB/LBU byte-load tests PASSED");

        // ========================================
        // LH / LHU halfword-load verification
        // ========================================

        // Store 0x0000807F
        //
        // memory[address]:
        //   +0,+1 = 0x807F
        //   +2,+3 = 0x0000
        //
        // Therefore:
        //   LH  -> FFFF807F
        //   LHU -> 0000807F

        write_data    = 32'h0000807F;
        addr          = 32'h00000018;
        mem_size      = 2'b10;      // word
        mem_unsigned  = 1'b0;
        mem_write     = 1'b1;

        @(posedge clk);
        #1;

        mem_write = 1'b0;


        // ----------------------------------------
        // LH 0x807F -> 0xFFFF807F
        // ----------------------------------------

        mem_read     = 1'b1;
        mem_size     = 2'b01;       // halfword
        mem_unsigned = 1'b0;
        addr         = 32'h00000018;

        #1;

        if (read_data !== 32'hFFFF807F)
            $fatal(
                "LH sign extension failed: got %h",
                read_data
            );


        // ----------------------------------------
        // LHU 0x807F -> 0x0000807F
        // ----------------------------------------

        mem_unsigned = 1'b1;

        #1;

        if (read_data !== 32'h0000807F)
            $fatal(
                "LHU zero extension failed: got %h",
                read_data
            );

        mem_read = 1'b0;

        $display("LH/LHU halfword-load tests PASSED");

        // ========================================
        // SB / SH / SW write verification
        // ========================================

        // ----------------------------------------
        // SW baseline
        // ----------------------------------------

        mem_read     = 1'b0;
        mem_write    = 1'b1;
        mem_size     = 2'b10;
        write_data   = 32'hAABBCCDD;
        addr         = 32'h00000020;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'hAABBCCDD)
            $fatal(
                "SW write failed: dut.memory[8] = %h",
                dut.memory[8]
            );


        // ----------------------------------------
        // SB at byte 0
        // AABBCCDD -> AABBCC11
        // ----------------------------------------

        mem_write  = 1'b1;
        mem_size   = 2'b00;
        write_data = 32'h00000011;
        addr       = 32'h00000020;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'hAABBCC11)
            $fatal(
                "SB byte 0 failed: dut.memory[8] = %h",
                dut.memory[8]
            );


        // ----------------------------------------
        // SB at byte 1
        // AABBCC11 -> AABB2211
        // ----------------------------------------

        mem_write  = 1'b1;
        mem_size   = 2'b00;
        write_data = 32'h00000022;
        addr       = 32'h00000021;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'hAABB2211)
            $fatal(
                "SB byte 1 failed: dut.memory[8] = %h",
                dut.memory[8]
            );


        // ----------------------------------------
        // SB at byte 2
        // AABB2211 -> AA332211
        // ----------------------------------------

        mem_write  = 1'b1;
        mem_size   = 2'b00;
        write_data = 32'h00000033;
        addr       = 32'h00000022;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'hAA332211)
            $fatal(
                "SB byte 2 failed: dut.memory[8] = %h",
                dut.memory[8]
            );


        // ----------------------------------------
        // SB at byte 3
        // AA332211 -> 44332211
        // ----------------------------------------

        mem_write  = 1'b1;
        mem_size   = 2'b00;
        write_data = 32'h00000044;
        addr       = 32'h00000023;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'h44332211)
            $fatal(
                "SB byte 3 failed: dut.memory[8] = %h",
                dut.memory[8]
            );


        // ----------------------------------------
        // SH at lower halfword
        // 44332211 -> 44335566
        // ----------------------------------------

        mem_write  = 1'b1;
        mem_size   = 2'b01;
        write_data = 32'h00005566;
        addr       = 32'h00000020;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'h44335566)
            $fatal(
                "SH lower halfword failed: dut.memory[8] = %h",
                dut.memory[8]
            );


        // ----------------------------------------
        // SH at upper halfword
        // 44335566 -> 77885566
        // ----------------------------------------

        mem_write  = 1'b1;
        mem_size   = 2'b01;
        write_data = 32'h00007788;
        addr       = 32'h00000022;

        @(posedge clk);
        #1;

        mem_write = 1'b0;

        if (dut.memory[8] !== 32'h77885566)
            $fatal(
                "SH upper halfword failed: dut.memory[8] = %h",
                dut.memory[8]
            );

        $display("SB/SH/SW write tests PASSED");


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