module tb_decoder;

    logic [31:0] instruction;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [3:0] alu_control;

    logic [31:0] immediate;
    logic        alu_src;

    logic        reg_write;
    logic        valid;

    logic mem_read;
    logic mem_write;
    logic mem_to_reg;


    decoder dut (
        .instruction (instruction),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .alu_control (alu_control),
        .immediate   (immediate),
        .alu_src     (alu_src),
        .reg_write   (reg_write),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .mem_to_reg  (mem_to_reg),
        .valid       (valid)
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

        // =====================================================
        // ADD x5, x6, x7
        // =====================================================

        instruction = 32'h007302B3;

        #1;

        if (rs1 !== 5'd6)
            $fatal("ADD rs1 failed");

        if (rs2 !== 5'd7)
            $fatal("ADD rs2 failed");

        if (rd !== 5'd5)
            $fatal("ADD rd failed");

        if (alu_control !== ALU_ADD)
            $fatal("ADD ALU control failed");

        if (alu_src !== 1'b0)
            $fatal("ADD should use register operand");

        if (reg_write !== 1'b1)
            $fatal("ADD reg_write failed");

        if (valid !== 1'b1)
            $fatal("ADD valid failed");


        // =====================================================
        // ADDI x5, x6, 10
        // =====================================================

        instruction = 32'h00A30293;

        #1;

        if (rs1 !== 5'd6)
            $fatal("ADDI rs1 failed: got %0d", rs1);

        if (rd !== 5'd5)
            $fatal("ADDI rd failed: got %0d", rd);

        if (immediate !== 32'd10)
            $fatal(
                "ADDI immediate failed: got %h",
                immediate
            );

        if (alu_control !== ALU_ADD)
            $fatal("ADDI ALU control failed");

        if (alu_src !== 1'b1)
            $fatal("ADDI should use immediate");

        if (reg_write !== 1'b1)
            $fatal("ADDI reg_write failed");

        if (valid !== 1'b1)
            $fatal("ADDI valid failed");


        // =====================================================
        // ADDI x8, x6, -1
        // =====================================================

        instruction = 32'hFFF30413;

        #1;

        if (rs1 !== 5'd6)
            $fatal("ADDI negative rs1 failed");

        if (rd !== 5'd8)
            $fatal("ADDI negative rd failed");

        if (immediate !== 32'hFFFFFFFF)
            $fatal(
                "ADDI negative immediate failed: got %h",
                immediate
            );

        if (alu_control !== ALU_ADD)
            $fatal("ADDI negative ALU control failed");

        if (alu_src !== 1'b1)
            $fatal("ADDI negative alu_src failed");

        if (reg_write !== 1'b1)
            $fatal("ADDI negative reg_write failed");

        if (valid !== 1'b1)
            $fatal("ADDI negative valid failed");


        // =====================================================
        // SLT x17, x6, x7
        // =====================================================

        instruction = 32'h007328B3;

        #1;

        if (rs1 !== 5'd6)
            $fatal("SLT rs1 failed: got %0d", rs1);

        if (rs2 !== 5'd7)
            $fatal("SLT rs2 failed: got %0d", rs2);

        if (rd !== 5'd17)
            $fatal("SLT rd failed: got %0d", rd);

        if (alu_control !== ALU_SLT)
            $fatal("SLT alu_control failed: got %h", alu_control);

        if (alu_src !== 1'b0)
            $fatal("SLT alu_src failed: got %b", alu_src);

        if (reg_write !== 1'b1)
            $fatal("SLT reg_write failed");

        if (valid !== 1'b1)
            $fatal("SLT valid failed");


        // =====================================================
        // SLTI x18, x6, 25
        // =====================================================

        instruction = 32'h01932913;

        #1;

        if (rs1 !== 5'd6)
            $fatal("SLTI rs1 failed: got %0d", rs1);

        if (rd !== 5'd18)
            $fatal("SLTI rd failed: got %0d", rd);

        if (immediate !== 32'd25)
            $fatal(
                "SLTI immediate failed: got %h",
                immediate
            );

        if (alu_control !== ALU_SLT)
            $fatal(
                "SLTI alu_control failed: got %h",
                alu_control
            );

        if (alu_src !== 1'b1)
            $fatal("SLTI alu_src failed: got %b", alu_src);

        if (reg_write !== 1'b1)
            $fatal("SLTI reg_write failed");

        if (valid !== 1'b1)
            $fatal("SLTI valid failed");

        // =================================
        // SLTU
        // SLTU x19, x6, x7
        // =================================

        instruction = 32'h007339B3;

        #1;

        if (rs1 !== 5'd6)
            $fatal("SLTU rs1 failed: got %0d", rs1);

        if (rs2 !== 5'd7)
            $fatal("SLTU rs2 failed: got %0d", rs2);

        if (rd !== 5'd19)
            $fatal("SLTU rd failed: got %0d", rd);

        if (alu_control !== ALU_SLTU)
            $fatal("SLTU alu_control failed: got %h", alu_control);

        if (alu_src !== 1'b0)
            $fatal("SLTU alu_src failed: got %b", alu_src);

        if (reg_write !== 1'b1)
            $fatal("SLTU reg_write failed");

        if (valid !== 1'b1)
            $fatal("SLTU valid failed");

        $display("SLTU : rs1=%0d rs2=%0d rd=%0d",
                 rs1, rs2, rd);

        // =================================
        // SLL
        // SLL x19, x6, x7
        // =================================

        instruction = 32'h007319B3;

        #1;

        if (rs1 !== 5'd6)
            $fatal("SLL rs1 failed: got %0d", rs1);

        if (rs2 !== 5'd7)
            $fatal("SLL rs2 failed: got %0d", rs2);

        if (rd !== 5'd19)
            $fatal("SLL rd failed: got %0d", rd);

        if (alu_control !== ALU_SLL)
            $fatal(
                "SLL alu_control failed: got %h",
                alu_control
            );

        if (alu_src !== 1'b0)
            $fatal("SLL alu_src failed: got %b", alu_src);

        if (reg_write !== 1'b1)
            $fatal("SLL reg_write failed");

        if (valid !== 1'b1)
            $fatal("SLL valid failed");

        $display(
            "SLL  : rs1=%0d rs2=%0d rd=%0d",
            rs1, rs2, rd
        );

        // =================================
        // SRL
        // SRL x23, x6, x7
        // =================================

        instruction = 32'h00735BB3;

        #1;

        if (rs1 !== 5'd6)
            $fatal("SRL rs1 failed: got %0d", rs1);

        if (rs2 !== 5'd7)
            $fatal("SRL rs2 failed: got %0d", rs2);

        if (rd !== 5'd23)
            $fatal("SRL rd failed: got %0d", rd);

        if (alu_control !== ALU_SRL)
            $fatal(
                "SRL alu_control failed: got %h",
                alu_control
            );

        if (alu_src !== 1'b0)
            $fatal("SRL alu_src failed: got %b", alu_src);

        if (reg_write !== 1'b1)
            $fatal("SRL reg_write failed");

        if (valid !== 1'b1)
            $fatal("SRL valid failed");

        $display(
            "SRL  : rs1=%0d rs2=%0d rd=%0d",
            rs1, rs2, rd
        );

        // =================================
        // SRA
        // SRA x24, x6, x7
        // =================================
        
        instruction = 32'h40735C33;
        
        #1;
        
        if (rs1 !== 5'd6)
            $fatal("SRA rs1 failed: got %0d", rs1);
        
        if (rs2 !== 5'd7)
            $fatal("SRA rs2 failed: got %0d", rs2);
        
        if (rd !== 5'd24)
            $fatal("SRA rd failed: got %0d", rd);
        
        if (alu_control !== ALU_SRA)
            $fatal(
                "SRA alu_control failed: got %h",
                alu_control
            );
        
        if (alu_src !== 1'b0)
            $fatal("SRA alu_src failed: got %b", alu_src);
        
        if (reg_write !== 1'b1)
            $fatal("SRA reg_write failed");
        
        if (valid !== 1'b1)
            $fatal("SRA valid failed");
        
        $display(
            "SRA  : rs1=%0d rs2=%0d rd=%0d",
            rs1, rs2, rd
        );


        // =================================
        // LW x5, 8(x6)
        // =================================

        instruction = 32'h00832283;

        #1;

        if (rs1 !== 5'd6)
            $fatal("LW rs1 failed: got %0d", rs1);

        if (rd !== 5'd5)
            $fatal("LW rd failed: got %0d", rd);

        if (immediate !== 32'd8)
            $fatal("LW immediate failed: got %0d", immediate);

        if (alu_control !== ALU_ADD)
            $fatal("LW ALU control failed");

        if (alu_src !== 1'b1)
            $fatal("LW alu_src failed");

        if (mem_read !== 1'b1)
            $fatal("LW mem_read failed");

        if (mem_write !== 1'b0)
            $fatal("LW mem_write failed");

        if (mem_to_reg !== 1'b1)
            $fatal("LW mem_to_reg failed");

        if (reg_write !== 1'b1)
            $fatal("LW reg_write failed");

        if (valid !== 1'b1)
            $fatal("LW valid failed");

        $display("LW   : rs1=%0d imm=%0d rd=%0d",
                 rs1, immediate, rd);

        
        // =================================
        // SW x7, 12(x6)
        // =================================

        instruction = 32'h00732623;

        #1;

        if (rs1 !== 5'd6)
            $fatal("SW rs1 failed: got %0d", rs1);

        if (rs2 !== 5'd7)
            $fatal("SW rs2 failed: got %0d", rs2);

        if (immediate !== 32'd12)
            $fatal("SW immediate failed: got %0d", immediate);

        if (alu_control !== ALU_ADD)
            $fatal("SW ALU control failed");

        if (alu_src !== 1'b1)
            $fatal("SW alu_src failed");

        if (mem_read !== 1'b0)
            $fatal("SW mem_read failed");

        if (mem_write !== 1'b1)
            $fatal("SW mem_write failed");

        if (mem_to_reg !== 1'b0)
            $fatal("SW mem_to_reg failed");

        if (reg_write !== 1'b0)
            $fatal("SW reg_write should be 0");

        if (valid !== 1'b1)
            $fatal("SW valid failed");

        $display("SW   : rs1=%0d rs2=%0d imm=%0d",
                 rs1, rs2, immediate);


        // =====================================================
        // PASS
        // =====================================================

        $display("");
        $display("==============================");
        $display("DECODER TEST PASSED");
        $display("==============================");

        $display("ADD  : rs1=6 rs2=7 rd=5");
        $display("ADDI : rs1=6 imm=10 rd=5");
        $display("ADDI : rs1=6 imm=-1 rd=8");
        $display("SLT  : rs1=6 rs2=7 rd=17");
        $display("SLTI : rs1=6 imm=25 rd=18");
        $display("SLTU : rs1=6 rs2=7 rd =19");

        $display("==============================");
        $display("");

        $finish;

    end

endmodule