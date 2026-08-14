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

    assign alu_b = alu_src ? immediate : read_data2;


    // PC
    pc pc_unit (
        .clk     (clk),
        .reset   (reset),
        .next_pc (next_pc),
        .pc      (pc)
    );


    // For now, always move to the next instruction
    assign next_pc = pc + 32'd4;


    // Instruction memory
    instr_mem instruction_memory (
        .addr        (pc),
        .instruction (instruction)
    );


    // Decoder
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
        .valid        (valid)
    );


    // Register File
    regfile register_file (
        .clk        (clk),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),

        .write_data (alu_result),
        .write_en   (reg_write),

        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );


    // ALU
    alu arithmetic_logic_unit (
        .a           (read_data1),

        // MUX output
        .b           (alu_b),

        .alu_control (alu_control),
        .result      (alu_result)
    );

endmodule