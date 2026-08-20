module cpu (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pc
);

    logic [31:0] next_pc;

    logic [31:0] instruction;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [3:0] alu_control;
    logic        reg_write;
    logic        valid;

    // NEW: immediate and ALU source control
    logic [31:0] immediate;
    logic        alu_src;

    logic [31:0] read_data1;
    logic [31:0] read_data2;

    logic [31:0] alu_result;

    // ALU second operand
    logic [31:0] alu_b;

    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic [1:0] mem_size;
    logic       mem_unsigned;

    logic [31:0] memory_read_data;
    logic [31:0] writeback_data;

    logic        branch;
    logic [2:0]  branch_type;

    logic        take_branch;
    logic [31:0] control_target;

    logic jump;
    logic jalr;

    logic        alu_a_pc;
    logic        alu_a_zero;
    logic [31:0] alu_a;

    localparam BR_BEQ  = 3'b000;
    localparam BR_BNE  = 3'b001;
    localparam BR_BLT  = 3'b010;
    localparam BR_BGE  = 3'b011;
    localparam BR_BLTU = 3'b100;
    localparam BR_BGEU = 3'b101;

    always_comb begin
        if (alu_a_pc)
            alu_a = pc;
        else if (alu_a_zero)
            alu_a = 32'b0;
        else
            alu_a = read_data1;
    end

    // =========================================================
    // ALU second operand
    // =========================================================

    assign alu_b = alu_src ? immediate : read_data2;

    // =========================================================
    // Writeback MUX
    // =========================================================

    assign writeback_data =
        jump       ? pc + 32'd4 :
        mem_to_reg ? memory_read_data :
                     alu_result;


    // =========================================================
    // PC
    // =========================================================

    pc pc_unit (
        .clk     (clk),
        .reset   (reset),
        .next_pc (next_pc),
        .pc      (pc)
    );


    // For now, always move to the next instruction
    assign next_pc =
    jump        ? control_target :
    take_branch ? control_target :
                  pc + 32'd4;

    // =========================================================
    // Instruction Memory
    // =========================================================

    instr_mem instruction_memory (
        .addr        (pc),
        .instruction (instruction)
    );


    // =========================================================
    // Decoder
    // =========================================================

    decoder instruction_decoder (
        .instruction (instruction),

        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),

        .alu_control (alu_control),

        // NEW
        .immediate   (immediate),
        .alu_src     (alu_src),

        .reg_write   (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .mem_size     (mem_size),
        .mem_unsigned (mem_unsigned),
        .valid        (valid),
        .branch      (branch),
        .branch_type (branch_type),
        .jump         (jump),
        .jalr        (jalr),
        .alu_a_pc    (alu_a_pc),
        .alu_a_zero  (alu_a_zero)
    );

    assign control_target =
        jalr ? ((read_data1 + immediate) & 32'hFFFFFFFE) :
               (pc + immediate);

    assign take_branch =
    branch &&
    (
        ((branch_type == BR_BEQ)  && (read_data1 == read_data2)) ||
        ((branch_type == BR_BNE)  && (read_data1 != read_data2)) ||
        ((branch_type == BR_BLT)  && ($signed(read_data1) < $signed(read_data2))) ||
        ((branch_type == BR_BGE)  && ($signed(read_data1) >= $signed(read_data2))) ||
        ((branch_type == BR_BLTU) && (read_data1 < read_data2)) ||
        ((branch_type == BR_BGEU) && (read_data1 >= read_data2))
    );


    // =========================================================
    // Register File
    // =========================================================

    regfile register_file (
        .clk        (clk),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),

        .write_data (writeback_data),
        .write_en   (reg_write),

        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );


    // =========================================================
    // ALU
    // =========================================================

    alu arithmetic_logic_unit (
        .a(alu_a),

        // MUX output
        .b           (alu_b),

        .alu_control (alu_control),
        .result      (alu_result)
    );

    // =========================================================
    // Data Memory
    // =========================================================

    data_mem data_memory (
        .clk        (clk),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .addr       (alu_result),
        .write_data (read_data2),
        .mem_size     (mem_size),
        .mem_unsigned (mem_unsigned),
        .read_data  (memory_read_data)
    );

endmodule