module tb_cpu;

    logic        clk;
    logic        reset;
    logic [31:0] pc;


    cpu dut (
        .clk   (clk),
        .reset (reset),
        .pc    (pc)
    );


    // ==============================
    // Clock
    // ==============================

    always #5 clk = ~clk;


    // ==============================
    // Test
    // ==============================

    initial begin

        clk   = 1'b0;
        reset = 1'b1;


        // ==========================
        // Reset
        // ==========================

        #10;

        reset = 1'b0;


        // ==========================
        // Initial register values
        // ==========================

        dut.register_file.registers[6]  = 32'd20;
        dut.register_file.registers[7]  = 32'd5;
        dut.register_file.registers[20] = 32'hFFFFFFFF;
        dut.register_file.registers[25] = 32'd0;
        dut.register_file.registers[26] = 32'd0;
        dut.register_file.registers[27] = 32'd0;
        dut.register_file.registers[28] = 32'd0;
        dut.register_file.registers[30] = 32'd0;
        dut.register_file.registers[31] = 32'd0;


        // ==========================
        // Execute 14 instructions
        // ==========================

        repeat (19) begin
            @(posedge clk);
            #1;
        end


        // ==========================
        // Check results
        // ==========================

        // if (dut.register_file.registers[5] !== 32'd30)
        //     $fatal(
        //         "ADDI failed: x5 = %0d",
        //         dut.register_file.registers[5]
        //     );


        if (dut.register_file.registers[8] !== 32'd19)
            $fatal(
                "ADDI negative failed: x8 = %0d",
                dut.register_file.registers[8]
            );


        if (dut.register_file.registers[9] !== 32'd25)
            $fatal(
                "ADD failed: x9 = %0d",
                dut.register_file.registers[9]
            );


        if (dut.register_file.registers[10] !== 32'd15)
            $fatal(
                "SUB failed: x10 = %0d",
                dut.register_file.registers[10]
            );


        if (dut.register_file.registers[11] !== 32'd4)
            $fatal(
                "AND failed: x11 = %0d",
                dut.register_file.registers[11]
            );


        if (dut.register_file.registers[12] !== 32'd21)
            $fatal(
                "OR failed: x12 = %0d",
                dut.register_file.registers[12]
            );


        if (dut.register_file.registers[13] !== 32'd17)
            $fatal(
                "XOR failed: x13 = %0d",
                dut.register_file.registers[13]
            );


        if (dut.register_file.registers[14] !== 32'd17)
            $fatal(
                "XORI failed: x14 = %0d",
                dut.register_file.registers[14]
            );


        if (dut.register_file.registers[15] !== 32'd21)
            $fatal(
                "ORI failed: x15 = %0d",
                dut.register_file.registers[15]
            );


        if (dut.register_file.registers[16] !== 32'd4)
            $fatal(
                "ANDI failed: x16 = %0d",
                dut.register_file.registers[16]
            );


        // SLT x17, x6, x7
        // 20 < 5 → false

        if (dut.register_file.registers[17] !== 32'd0)
            $fatal(
                "SLT failed: x17 = %0d",
                dut.register_file.registers[17]
            );


        // SLTI x18, x6, 25
        // 20 < 25 → true

        if (dut.register_file.registers[18] !== 32'd1)
            $fatal(
                "SLTI failed: x18 = %0d",
                dut.register_file.registers[18]
            );


        // SLTU x19, x6, x7
        // 20 < 5 → false

        if (dut.register_file.registers[19] !== 32'd0)
            $fatal(
                "SLTU failed: x19 = %0d",
                dut.register_file.registers[19]
            );


        // SLTU x21, x20, x7
        // FFFFFFFF < 5 unsigned → false

        if (dut.register_file.registers[21] !== 32'd0)
            $fatal(
                "SLTU boundary test failed: x21 = %h",
                dut.register_file.registers[21]
            );

        // SLL
        if (dut.register_file.registers[22] !== 32'd640)
            $fatal(
                "SLL failed: x22 = %0d",
                dut.register_file.registers[22]
            );

        // SRL
        if (dut.register_file.registers[23] !== 32'd0)
            $fatal(
                "SRL failed: x23 = %0d",
                dut.register_file.registers[23]
            );
        
        if (dut.register_file.registers[24] !== 32'd0)
            $fatal(
                "SRA failed: x24 = %0d",
                dut.register_file.registers[24]
            );

        if (dut.register_file.registers[5] !== 32'd5)
            $fatal(
                "LW failed: x5 = %0d",
                dut.register_file.registers[5]
            );

        // ==============================
        // BEQ not-taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000050)
            $fatal(
                "BEQ not-taken failed: PC = %h",
                pc
            );

        $display(
            "BEQ not taken: x6 != x7, PC = %h",
            pc
        );


        // ==============================
        // BEQ taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000058)
            $fatal(
                "BEQ taken failed: PC = %h",
                pc
            );

        $display(
            "BEQ taken: x6 == x6, PC = %h",
            pc
        );


        // ==============================
        // BNE taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000060)
            $fatal(
                "BNE taken failed: PC = %h",
                pc
            );

        $display(
            "BNE taken: x6 != x7, PC = %h",
            pc
        );

        // ==============================
        // BLT not-taken
        // ==============================
        
        @(posedge clk);
        #1;
        
        if (pc !== 32'h00000064)
            $fatal(
                "BLT not-taken failed: PC = %h",
                pc
            );
        
        $display(
            "BLT not taken: x6 < x7 is false, PC = %h",
            pc
        );

        // ==============================
        // BLT taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h0000006C)
            $fatal(
                "BLT taken failed: PC = %h",
                pc
            );

        $display(
            "BLT taken: x7 < x6 is true, PC = %h",
            pc
        );

        // ==============================
        // BGE not taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000070)
            $fatal(
                "BGE not-taken failed: PC = %h",
                pc
            );

        $display(
            "BGE not taken: x7 >= x6 is false, PC = %h",
            pc
        );


        // ==============================
        // BGE taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000078)
            $fatal(
                "BGE taken failed: PC = %h",
                pc
            );

        $display(
            "BGE taken: x6 >= x7 is true, PC = %h",
            pc
        );

        // ==============================
        // BLTU not taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h0000007C)
            $fatal(
                "BLTU not-taken failed: PC = %h",
                pc
            );

        $display(
            "BLTU not taken: x20 < x7 is false, PC = %h",
            pc
        );


        // ==============================
        // BLTU taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000084)
            $fatal(
                "BLTU taken failed: PC = %h",
                pc
            );

        $display(
            "BLTU taken: x7 < x6 is true, PC = %h",
            pc
        );

        // ==============================
        // BGEU taken
        // ==============================

        $display(
                "BGEU CHECK: PC=%h INSTR=%h branch=%b type=%b rs1=%0d rs2=%0d rd1=%h rd2=%h take=%b",
                pc,
                dut.instruction,
                dut.branch,
                dut.branch_type,
                dut.rs1,
                dut.rs2,
                dut.read_data1,
                dut.read_data2,
                dut.take_branch
        );

        @(posedge clk);
        #1;

        

        if (pc !== 32'h0000008C)
            $fatal(
                "BGEU taken failed: PC = %h",
                pc
            );

        $display(
            "BGEU taken: x20 >= x7 is true, PC = %h",
            pc
        );


        // ==============================
        // BGEU not taken
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000090)
            $fatal(
                "BGEU not-taken failed: PC = %h",
                pc
            );

        $display(
            "BGEU not taken: x7 >= x6 is false, PC = %h",
            pc
        );

                // ==============================
        // JAL
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h00000098)
            $fatal(
                "JAL target failed: PC = %h",
                pc
            );

        if (dut.register_file.registers[25] !== 32'h00000094)
            $fatal(
                "JAL link failed: x25 = %h",
                dut.register_file.registers[25]
            );

        if (dut.register_file.registers[26] !== 32'd0)
            $fatal(
                "JAL skipped instruction executed: x26 = %0d",
                dut.register_file.registers[26]
            );

        $display(
            "JAL: target=0x%h link=0x%h skipped_x26=%0d",
            pc,
            dut.register_file.registers[25],
            dut.register_file.registers[26]
        );


        // ==============================
        // JAL target instruction
        // ==============================

        @(posedge clk);
        #1;

        if (dut.register_file.registers[27] !== 32'd42)
            $fatal(
                "JAL target instruction failed: x27 = %0d",
                dut.register_file.registers[27]
            );

        $display(
            "JAL target executed: x27 = %0d",
            dut.register_file.registers[27]
        );

        // ==============================
        // JALR
        // ==============================

        @(posedge clk);
        #1;

        if (pc !== 32'h000000A0)
            $fatal(
                "JALR setup failed: PC = %h",
                pc
            );

        @(posedge clk);
        #1;

        if (pc !== 32'h000000A8)
            $fatal(
                "JALR target failed: PC = %h",
                pc
            );

        if (dut.register_file.registers[30] !== 32'h000000A4)
            $fatal(
                "JALR link failed: x30 = %h",
                dut.register_file.registers[30]
            );

        if (dut.register_file.registers[31] !== 32'd0)
            $fatal(
                "JALR skipped instruction executed: x31 = %0d",
                dut.register_file.registers[31]
            );

        $display(
            "JALR: target=0x%h link=0x%h skipped_x31=%0d",
            pc,
            dut.register_file.registers[30],
            dut.register_file.registers[31]
        );

        @(posedge clk);
        #1;

        if (dut.register_file.registers[27] !== 32'd55)
            $fatal(
                "JALR target instruction failed: x27 = %0d",
                dut.register_file.registers[27]
            );

        $display(
            "JALR target executed: x27 = %0d",
            dut.register_file.registers[27]
        );

        // ==============================
        // LB
        // ==============================

        // Wait until CPU reaches LB at 0xB4
        wait (dut.pc == 32'h000000B4);
        @(posedge clk);
        #1;

        if (dut.register_file.registers[29] !== 32'h0000007F)
            $fatal(
                "LB positive failed: x29 = %h",
                dut.register_file.registers[29]
            );

        $display(
            "LB positive: x29 = %h",
            dut.register_file.registers[29]
        );


        // Wait until CPU reaches LB at 0xC0
        wait (dut.pc == 32'h000000C0);
        @(posedge clk);
        #1;

        if (dut.register_file.registers[30] !== 32'hFFFFFF80)
            $fatal(
                "LB sign extension failed: x30 = %h",
                dut.register_file.registers[30]
            );

        $display(
            "LB sign extension: x30 = %h",
            dut.register_file.registers[30]
        );


        // ==============================
        // LBU positive
        // ==============================

        // Wait until CPU reaches LBU at 0xC4
        wait (dut.pc == 32'h000000C4);
        @(posedge clk);
        #1;

        if (dut.register_file.registers[31] !== 32'h0000007F)
            $fatal(
                "LBU positive failed: x31 = %h",
                dut.register_file.registers[31]
            );

        $display(
            "LBU positive: x31 = %h",
            dut.register_file.registers[31]
        );


        // ==============================
        // LBU unsigned high-bit byte
        // ==============================

        // Wait until CPU reaches LBU at 0xC8
        wait (dut.pc == 32'h000000C8);
        @(posedge clk);
        #1;

        if (dut.register_file.registers[28] !== 32'h00000080)
            $fatal(
                "LBU unsigned failed: x28 = %h",
                dut.register_file.registers[28]
            );

        $display(
            "LBU unsigned: x28 = %h",
            dut.register_file.registers[28]
        );

        // ==============================
        // SLLI
        // ==============================

        wait (dut.pc == 32'h000000D4);
        #1;

        if (dut.register_file.registers[5] !== 32'h00008000)
            $fatal(
                "SLLI failed: x5 = %h",
                dut.register_file.registers[5]
            );

        $display(
            "SLLI: x5 = %h",
            dut.register_file.registers[5]
        );

        // ==============================
        // LH
        // ==============================

        // LH at 0xDC commits when PC advances to 0xE0
        wait (dut.pc == 32'h000000E0);
        #1;

        if (dut.register_file.registers[16] !== 32'hFFFF807F)
            $fatal(
                "LH sign extension failed: x16 = %h",
                dut.register_file.registers[16]
            );

        $display(
            "LH sign extension: x16 = %h",
            dut.register_file.registers[16]
        );


        // ==============================
        // LHU
        // ==============================

        // Wait until CPU reaches LHU at 0xE0
        // LHU at 0xE0 commits when PC advances to 0xE4
        wait (dut.pc == 32'h000000E4);
        #1;

        if (dut.register_file.registers[18] !== 32'h0000807F)
            $fatal(
                "LHU zero extension failed: x18 = %h",
                dut.register_file.registers[18]
            );

        $display(
            "LHU zero extension: x18 = %h",
            dut.register_file.registers[18]
        );

        // ==============================
        // SLTIU
        // ==============================

        // SLTIU is at 0xE8
        wait (dut.pc == 32'h000000E8);
        @(posedge clk);
        #1;

        if (dut.register_file.registers[19] !== 32'd1)
            $fatal(
                "SLTIU failed: x19 = %h",
                dut.register_file.registers[19]
            );

        $display(
            "SLTIU: x19 = %h",
            dut.register_file.registers[19]
        );

        // ==============================
        // SRLI
        // ==============================

        // SRLI at 0xF4 commits when PC advances to 0xF8
        wait (dut.pc == 32'h000000F8);
        #1;

        if (dut.register_file.registers[5] !== 32'h7FFFFFFF)
            $fatal(
                "SRLI failed: x5 = %h",
                dut.register_file.registers[5]
            );

        $display(
            "SRLI: x5 = %h",
            dut.register_file.registers[5]
        );


        // ==============================
        // SRAI
        // ==============================

        // SRAI at 0xFC commits when PC advances to 0x100
        wait (dut.pc == 32'h00000100);
        #1;

        if (dut.register_file.registers[5] !== 32'hFFFFFFFF)
            $fatal(
                "SRAI failed: x5 = %h",
                dut.register_file.registers[5]
            );

        $display(
            "SRAI: x5 = %h",
            dut.register_file.registers[5]
        );


        // ==========================
        // Passed
        // ==========================

        $display("");
        $display("================================");
        $display(" RV32I CPU REGRESSION PASSED");
        $display("================================");

        $display("x5  = %0d  (ADDI)",
                 dut.register_file.registers[5]);

        $display("x8  = %0d  (ADDI -1)",
                 dut.register_file.registers[8]);

        $display("x9  = %0d  (ADD)",
                 dut.register_file.registers[9]);

        $display("x10 = %0d  (SUB)",
                 dut.register_file.registers[10]);

        $display("x11 = %0d  (AND)",
                 dut.register_file.registers[11]);

        $display("x12 = %0d  (OR)",
                 dut.register_file.registers[12]);

        $display("x13 = %0d  (XOR)",
                 dut.register_file.registers[13]);

        $display("x14 = %0d  (XORI)",
                 dut.register_file.registers[14]);

        $display("x15 = %0d  (ORI)",
                 dut.register_file.registers[15]);

        $display("x16 = %0d  (ANDI)",
                 dut.register_file.registers[16]);

        $display("x17 = %0d  (SLT)",
                 dut.register_file.registers[17]);

        $display("x18 = %0d  (SLTI)",
                 dut.register_file.registers[18]);

        $display("x19 = %0d  (SLTU 20 < 5)",
                 dut.register_file.registers[19]);

        $display("x21 = %0d  (SLTU FFFFFFFF < 5)",
                 dut.register_file.registers[21]);
        
        $display("x22 = %0d  (SLL)",
                 dut.register_file.registers[22]);

        $display("x23 = %0d  (SRL)",
                 dut.register_file.registers[23]);

        $display("x24 = %0d  (SRA)",
                 dut.register_file.registers[24]);
        
        $display("x5  = %0d  (LW)",
                 dut.register_file.registers[5]);

        $display("x29 = %h  (LB 0x7F)",
                 dut.register_file.registers[29]);

        $display("x30 = %h  (LB 0x80 sign-extended)",
                 dut.register_file.registers[30]);

        $display("x31 = %h  (LBU 0x7F)",
                 dut.register_file.registers[31]);

        $display("x28 = %h  (LBU 0x80 zero-extended)",
                 dut.register_file.registers[28]);

        $display("x16 = %h  (LH 0x807F sign-extended)",
                 dut.register_file.registers[16]);

        $display("x18 = %h  (LHU 0x807F zero-extended)",
                 dut.register_file.registers[18]);

        $display("================================");
        $display("");


        $finish;

    end

endmodule