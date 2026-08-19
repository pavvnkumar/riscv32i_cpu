module decoder (
    input  logic [31:0] instruction,

    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,

    output logic [3:0]  alu_control,

    output logic [31:0] immediate,
    output logic        alu_src,

    output logic        reg_write,
    output logic        valid,

    output logic mem_read,
    output logic mem_write,
    output logic mem_to_reg,
    output logic [1:0]  mem_size,
    output logic        mem_unsigned,

    output logic        branch,
    output logic [2:0]  branch_type,

    output logic        jump,
    output logic        jalr

    );

    localparam logic [6:0] OPCODE_RTYPE = 7'b0110011;

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

    localparam BR_BEQ  = 3'b000;
    localparam BR_BNE  = 3'b001;
    localparam BR_BLT  = 3'b010;
    localparam BR_BGE  = 3'b011;
    localparam BR_BLTU = 3'b100;
    localparam BR_BGEU = 3'b101;

    always_comb begin

        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd  = instruction[11:7];

        alu_control = ALU_ADD;
        immediate   = 32'b0;
        alu_src     = 1'b0;
        reg_write   = 1'b0;
        valid       = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        mem_size     = 2'b10;
        mem_unsigned = 1'b0;
        branch      = 1'b0;
        branch_type = 3'b000;
        jump = 1'b0;
        jalr = 1'b0;

        if (instruction[6:0] == OPCODE_RTYPE) begin

            case (instruction[14:12])

                3'b000: begin

                    if (instruction[31:25] == 7'b0000000) begin
                        // ADD
                        alu_control = ALU_ADD;
                        reg_write   = 1'b1;
                        valid       = 1'b1;
                    end

                    else if (instruction[31:25] == 7'b0100000) begin
                        // SUB
                        alu_control = ALU_SUB;
                        reg_write   = 1'b1;
                        valid       = 1'b1;
                    end

                end

                3'b111: begin
                    // AND
                    alu_control = ALU_AND;
                    reg_write   = 1'b1;
                    valid       = 1'b1;
                end

                3'b110: begin
                    // OR
                    alu_control = ALU_OR;
                    reg_write   = 1'b1;
                    valid       = 1'b1;
                end

                3'b100: begin
                    // XOR
                    alu_control = ALU_XOR;
                    reg_write   = 1'b1;
                    valid       = 1'b1;
                end
                3'b010: begin
                    // SLT

                    alu_control = ALU_SLT;
                    reg_write   = 1'b1;
                    valid       = 1'b1;
                end

                3'b011: begin
                    // SLTU
                    alu_control = ALU_SLTU;
                    reg_write   = 1'b1;
                    valid       = 1'b1;
                end

                3'b001: begin
                    // SLL
                    if (instruction[31:25] == 7'b0000000) begin
                        alu_control = ALU_SLL;
                        reg_write   = 1'b1;
                        valid       = 1'b1;
                    end
                end

                3'b101: begin
                    
                    if (instruction[31:25] == 7'b0000000) begin
                        // SRL
                        alu_control = ALU_SRL;
                        reg_write   = 1'b1;
                        valid       = 1'b1;
                    end

                    else if (instruction[31:25] == 7'b0100000) begin
                        // SRA
                        alu_control = ALU_SRA;
                        reg_write   = 1'b1;
                        valid       = 1'b1;
                    end
                end

                default: begin
                    valid = 1'b0;
                end

            endcase

        end

        else if (instruction[6:0] == 7'b0010011) begin

            case (instruction[14:12])

                3'b000: begin
                // ADDI

                    alu_control = ALU_ADD;

                    immediate = {{20{instruction[31]}},
                                instruction[31:20]};

                    alu_src   = 1'b1;
                    reg_write = 1'b1;
                    valid     = 1'b1;
                end

                3'b100: begin
                // XORI

                    alu_control = ALU_XOR;

                    immediate = {{20{instruction[31]}},
                                instruction[31:20]};

                    alu_src   = 1'b1;
                    reg_write = 1'b1;
                    valid     = 1'b1;
                end

                3'b110: begin
                // ORI

                    alu_control = ALU_OR;

                    immediate = {{20{instruction[31]}},
                                instruction[31:20]};

                    alu_src   = 1'b1;
                    reg_write = 1'b1;
                    valid     = 1'b1;
                end

                3'b111: begin
                // ANDI

                    alu_control = ALU_AND;

                    immediate = {{20{instruction[31]}},
                                instruction[31:20]};

                    alu_src   = 1'b1;
                    reg_write = 1'b1;
                    valid     = 1'b1;
                end

                3'b010: begin
                    // SLTI

                    alu_control = ALU_SLT;

                    immediate = {{20{instruction[31]}},
                                instruction[31:20]};

                    alu_src   = 1'b1;
                    reg_write = 1'b1;
                    valid     = 1'b1;
                end

                default: begin
                    valid = 1'b0;
                end

            endcase

        end

        else if (instruction[6:0] == 7'b0000011) begin

            // Loads

            immediate = {{20{instruction[31]}},
                         instruction[31:20]};

            alu_control = ALU_ADD;
            alu_src     = 1'b1;
            mem_read    = 1'b1;
            mem_to_reg  = 1'b1;
            reg_write   = 1'b1;
            valid       = 1'b1;

            case (instruction[14:12])

                3'b000: begin
                    // LB
                    mem_size     = 2'b00;
                    mem_unsigned = 1'b0;
                end

                3'b010: begin
                    // LW
                    mem_size     = 2'b10;
                    mem_unsigned = 1'b0;
                end

                default: begin
                    valid = 1'b0;
                end

            endcase

        end

        else if (instruction[6:0] == 7'b0100011) begin
        
            // SW

            if (instruction[14:12] == 3'b010) begin
            
                alu_control = ALU_ADD;

                immediate = {{20{instruction[31]}},
                             instruction[31:25],
                             instruction[11:7]};

                alu_src   = 1'b1;
                mem_write = 1'b1;
                reg_write = 1'b0;
                valid     = 1'b1;

            end

        end

        else if (instruction[6:0] == 7'b1100011) begin

            // BEQ

            if (instruction[14:12] == 3'b000) begin
                        
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

                branch      = 1'b1;
                branch_type = BR_BEQ;
                valid       = 1'b1;

            end

            // BNE
            else if (instruction[14:12] == 3'b001) begin
            
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

                branch      = 1'b1;
                branch_type = BR_BNE;
                valid       = 1'b1;

            end

            // BLT

            else if (instruction[14:12] == 3'b100) begin

                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

                branch      = 1'b1;
                branch_type = BR_BLT;
                valid       = 1'b1;

            end

            // BGE

            else if (instruction[14:12] == 3'b101) begin

                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

                branch      = 1'b1;
                branch_type = BR_BGE;
                valid       = 1'b1;

            end

            else if (instruction[14:12] == 3'b110) begin
                // BLTU

                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

                branch      = 1'b1;
                branch_type = BR_BLTU;
                valid       = 1'b1;

            end

            else if (instruction[14:12] == 3'b111) begin

                // BGEU
            
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};
            
                branch      = 1'b1;
                branch_type = BR_BGEU;
                valid       = 1'b1;
            
            end

        end
        else if (instruction[6:0] == 7'b1101111) begin

            // JAL

            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};

            reg_write = 1'b1;
            jump      = 1'b1;
            valid     = 1'b1;

        end

        else if (instruction[6:0] == 7'b1100111) begin

            // JALR
        
            if (instruction[14:12] == 3'b000) begin
            
                immediate = {{20{instruction[31]}},
                             instruction[31:20]};
        
                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                valid     = 1'b1;
        
            end
        
        end


            end

endmodule