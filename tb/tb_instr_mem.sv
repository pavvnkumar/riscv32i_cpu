module tb_instr_mem;

    logic [31:0] addr;
    logic [31:0] instruction;

    instr_mem dut (
        .addr        (addr),
        .instruction (instruction)
    );


    initial begin

        // =================================
        // ADDI x5, x6, 10
        // =================================

        addr = 32'h00000000;
        #1;

        if (instruction !== 32'h00A30293)
            $fatal(
                "Address 0x00 failed: got %h",
                instruction
            );


        // =================================
        // ADDI x8, x6, -1
        // =================================

        addr = 32'h00000004;
        #1;

        if (instruction !== 32'hFFF30413)
            $fatal(
                "Address 0x04 failed: got %h",
                instruction
            );


        // =================================
        // ADD x9, x6, x7
        // =================================

        addr = 32'h00000008;
        #1;

        if (instruction !== 32'h007304B3)
            $fatal(
                "Address 0x08 failed: got %h",
                instruction
            );


        // =================================
        // SUB x10, x6, x7
        // =================================

        addr = 32'h0000000C;
        #1;

        if (instruction !== 32'h40730533)
            $fatal(
                "Address 0x0C failed: got %h",
                instruction
            );


        // =================================
        // AND x11, x6, x7
        // =================================

        addr = 32'h00000010;
        #1;

        if (instruction !== 32'h007375B3)
            $fatal(
                "Address 0x10 failed: got %h",
                instruction
            );


        // =================================
        // OR x12, x6, x7
        // =================================

        addr = 32'h00000014;
        #1;

        if (instruction !== 32'h00736633)
            $fatal(
                "Address 0x14 failed: got %h",
                instruction
            );


        // =================================
        // XOR x13, x6, x7
        // =================================

        addr = 32'h00000018;
        #1;

        if (instruction !== 32'h007346B3)
            $fatal(
                "Address 0x18 failed: got %h",
                instruction
            );


        // =================================
        // XORI x14, x6, 5
        // =================================

        addr = 32'h0000001C;
        #1;

        if (instruction !== 32'h00534713)
            $fatal(
                "Address 0x1C failed: got %h",
                instruction
            );


        // =================================
        // ORI x15, x6, 5
        // =================================

        addr = 32'h00000020;
        #1;

        if (instruction !== 32'h00536793)
            $fatal(
                "Address 0x20 failed: got %h",
                instruction
            );


        // =================================
        // ANDI x16, x6, 5
        // =================================

        addr = 32'h00000024;
        #1;

        if (instruction !== 32'h00537813)
            $fatal(
                "Address 0x24 failed: got %h",
                instruction
            );


        // =================================
        // SLT x17, x6, x7
        // =================================

        addr = 32'h00000028;
        #1;

        if (instruction !== 32'h007328B3)
            $fatal(
                "Address 0x28 failed: got %h",
                instruction
            );


        // =================================
        // SLTI x18, x6, 25
        // =================================

        addr = 32'h0000002C;
        #1;

        if (instruction !== 32'h01932913)
            $fatal(
                "Address 0x2C failed: got %h",
                instruction
            );


        // =================================
        // SLTU x19, x6, x7
        // =================================

        addr = 32'h00000030;
        #1;

        if (instruction !== 32'h007339B3)
            $fatal(
                "Address 0x30 failed: got %h",
                instruction
            );


        // =================================
        // SLTU x21, x20, x7
        // =================================

        addr = 32'h00000034;
        #1;

        if (instruction !== 32'h007A3AB3)
            $fatal(
                "Address 0x34 failed: got %h",
                instruction
            );


        // =================================
        // SLL x22, x6, x7
        // =================================

        addr = 32'h00000038;
        #1;

        if (instruction !== 32'h00731B33)
            $fatal(
                "Address 0x38 failed: got %h",
                instruction
            );


        // =================================
        // SRL x23, x6, x7
        // =================================

        addr = 32'h0000003C;
        #1;

        if (instruction !== 32'h00735BB3)
            $fatal(
                "Address 0x3C failed: got %h",
                instruction
            );


        // =================================
        // SRA x24, x6, x7
        // =================================

        addr = 32'h00000040;
        #1;

        if (instruction !== 32'h40735C33)
            $fatal(
                "Address 0x40 failed: got %h",
                instruction
            );


        // =================================
        // Default / NOP
        // =================================

        addr = 32'h00000044;
        #1;

        if (instruction !== 32'h00000013)
            $fatal(
                "Default NOP failed: got %h",
                instruction
            );


        // =================================
        // PASS
        // =================================

        $display("");
        $display("==============================");
        $display("INSTRUCTION MEMORY TEST PASSED");
        $display("==============================");
        $display("");

        $finish;

    end

endmodule