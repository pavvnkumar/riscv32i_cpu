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

        $display("================================");
        $display("");


        $finish;

    end

endmodule