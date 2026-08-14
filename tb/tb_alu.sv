module tb_alu;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_control;
    logic [31:0] result;

    alu dut (
        .a           (a),
        .b           (b),
        .alu_control (alu_control),
        .result      (result)
    );

    localparam logic [3:0] ALU_ADD = 4'b0000;
    localparam logic [3:0] ALU_SUB = 4'b0001;
    localparam logic [3:0] ALU_AND = 4'b0010;
    localparam logic [3:0] ALU_OR  = 4'b0011;
    localparam logic [3:0] ALU_XOR = 4'b0100;
    localparam logic [3:0] ALU_SLT = 4'b0101;
    localparam logic [3:0] ALU_SLTU = 4'b0110;
    localparam logic [3:0] ALU_SLL = 4'b0111;
    localparam logic [3:0] ALU_SRL = 4'b1000;
    localparam logic [3:0] ALU_SRA = 4'b1001;

    initial begin

        // -------------------------
        // ADD
        // -------------------------
        a = 32'd10;
        b = 32'd20;
        alu_control = ALU_ADD;

        #1;

        if (result !== 32'd30)
            $fatal("ADD failed: got %h", result);


        // -------------------------
        // SUB
        // -------------------------
        a = 32'd20;
        b = 32'd5;
        alu_control = ALU_SUB;

        #1;

        if (result !== 32'd15)
            $fatal("SUB failed: got %h", result);


        // -------------------------
        // AND
        // -------------------------
        a = 32'hF0F0F0F0;
        b = 32'h0FF00FF0;
        alu_control = ALU_AND;

        #1;

        if (result !== 32'h00F000F0)
            $fatal("AND failed: got %h", result);


        // -------------------------
        // OR
        // -------------------------
        a = 32'hF0F00000;
        b = 32'h00000FF0;
        alu_control = ALU_OR;

        #1;

        if (result !== 32'hF0F00FF0)
            $fatal("OR failed: got %h", result);


        // -------------------------
        // XOR
        // -------------------------
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        alu_control = ALU_XOR;

        #1;

        if (result !== 32'hFFFFFFFF)
            $fatal("XOR failed: got %h", result);

        // -------------------------
        // SLT: 20 < 25 → 1
        // -------------------------
        a = 32'd20;
        b = 32'd25;
        alu_control = ALU_SLT;

        #1;

        if (result !== 32'd1)
            $fatal("SLT 20 < 25 failed: got %h", result);


        // -------------------------
        // SLT: 20 < 10 → 0
        // -------------------------
        a = 32'd20;
        b = 32'd10;
        alu_control = ALU_SLT;

        #1;

        if (result !== 32'd0)
            $fatal("SLT 20 < 10 failed: got %h", result);


        // -------------------------
        // SLT signed: -1 < 5 → 1
        // -------------------------
        a = 32'hFFFFFFFF;
        b = 32'd5;
        alu_control = ALU_SLT;

        #1;

        if (result !== 32'd1)
            $fatal("SLT -1 < 5 failed: got %h", result);

        // -------------------------
        // SLTU
        // -------------------------
        
        // 20 < 5 → false
        a = 32'd20;
        b = 32'd5;
        alu_control = ALU_SLTU;
        
        #1;
        
        if (result !== 32'd0)
            $fatal("SLTU 20 < 5 failed: got %h", result);
        
        
        // 5 < 20 → true
        a = 32'd5;
        b = 32'd20;
        alu_control = ALU_SLTU;
        
        #1;
        
        if (result !== 32'd1)
            $fatal("SLTU 5 < 20 failed: got %h", result);
        
        
        // Important signed vs unsigned test
        // FFFFFFFF = 4294967295 unsigned
        // 5 = 5
        // 4294967295 < 5 → false
        
        a = 32'hFFFFFFFF;
        b = 32'd5;
        alu_control = ALU_SLTU;
        
        #1;
        
        if (result !== 32'd0)
            $fatal("SLTU unsigned test failed: got %h", result);
        
        
        // Boundary test
        // 0 < FFFFFFFF → true
        
        a = 32'd0;
        b = 32'hFFFFFFFF;
        alu_control = ALU_SLTU;
        
        #1;
        
        if (result !== 32'd1)
            $fatal("SLTU boundary test failed: got %h", result);

        // -------------------------
        // SLL
        // -------------------------

        // 5 << 1 = 10

        a = 32'd5;
        b = 32'd1;
        alu_control = ALU_SLL;

        #1;

        if (result !== 32'd10)
            $fatal(
                "SLL 5 << 1 failed: got %h",
                result
            );


        // 5 << 2 = 20

        a = 32'd5;
        b = 32'd2;
        alu_control = ALU_SLL;

        #1;

        if (result !== 32'd20)
            $fatal(
                "SLL 5 << 2 failed: got %h",
                result
            );


        // 1 << 31 = 0x80000000

        a = 32'd1;
        b = 32'd31;
        alu_control = ALU_SLL;

        #1;

        if (result !== 32'h80000000)
            $fatal(
                "SLL 1 << 31 failed: got %h",
                result
            );


        // Only lower 5 bits of b are used.
        // b = 32 means b[4:0] = 0
        // Therefore 1 << 32 behaves as 1 << 0.

        a = 32'd1;
        b = 32'd32;
        alu_control = ALU_SLL;

        #1;

        if (result !== 32'd1)
            $fatal(
                "SLL shift amount masking failed: got %h",
                result
            );

        // -------------------------
        // SRL
        // -------------------------

        // 20 >> 1 = 10

        a = 32'd20;
        b = 32'd1;
        alu_control = ALU_SRL;

        #1;

        if (result !== 32'd10)
            $fatal(
                "SRL 20 >> 1 failed: got %h",
                result
            );


        // 20 >> 2 = 5

        a = 32'd20;
        b = 32'd2;
        alu_control = ALU_SRL;

        #1;

        if (result !== 32'd5)
            $fatal(
                "SRL 20 >> 2 failed: got %h",
                result
            );


        // Test logical zero-fill
        //
        // 0x80000000 >> 1
        // = 0x40000000

        a = 32'h80000000;
        b = 32'd1;
        alu_control = ALU_SRL;

        #1;

        if (result !== 32'h40000000)
            $fatal(
                "SRL zero-fill failed: got %h",
                result
            );


        // Maximum shift amount
        //
        // 0xFFFFFFFF >> 31
        // = 1

        a = 32'hFFFFFFFF;
        b = 32'd31;
        alu_control = ALU_SRL;

        #1;

        if (result !== 32'd1)
            $fatal(
                "SRL maximum shift failed: got %h",
                result
            );

        // -------------------------
        // SRA
        // -------------------------

        // 20 >>> 1 = 10

        a = 32'd20;
        b = 32'd1;
        alu_control = ALU_SRA;

        #1;

        if (result !== 32'd10)
            $fatal(
                "SRA 20 >>> 1 failed: got %h",
                result
            );


        // Negative value
        //
        // 0x80000000 >>> 1
        // = 0xC0000000

        a = 32'h80000000;
        b = 32'd1;
        alu_control = ALU_SRA;

        #1;

        if (result !== 32'hC0000000)
            $fatal(
                "SRA sign extension failed: got %h",
                result
            );


        // Negative value shifted by 4
        //
        // 0x80000000 >>> 4
        // = 0xF8000000

        a = 32'h80000000;
        b = 32'd4;
        alu_control = ALU_SRA;

        #1;

        if (result !== 32'hF8000000)
            $fatal(
                "SRA shift-by-4 failed: got %h",
                result
            );


        $display("SRA TEST PASSED");


        $display("SRL TEST PASSED");


        $display("SLL TEST PASSED");
        
        
        $display("SLTU TEST PASSED");    


        $display("ALU R-TYPE + SLT TEST PASSED");

        $finish;

    end

endmodule