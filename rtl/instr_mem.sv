module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

    always_comb begin

        case (addr)

            // ADDI x5, x6, 10
            32'h00000000:
                instruction = 32'h00A30293;

            // ADDI x8, x6, -1
            32'h00000004:
                instruction = 32'hFFF30413;

            // ADD x9, x6, x7
            32'h00000008:
                instruction = 32'h007304B3;

            // SUB x10, x6, x7
            32'h0000000C:
                instruction = 32'h40730533;

            // AND x11, x6, x7
            32'h00000010:
                instruction = 32'h007375B3;

            // OR x12, x6, x7
            32'h00000014:
                instruction = 32'h00736633;

            // XOR x13, x6, x7
            32'h00000018:
                instruction = 32'h007346B3;

            // XORI x14, x6, 5
            32'h0000001C:
                instruction = 32'h00534713;

            // ORI x15, x6, 5
            32'h00000020:
                instruction = 32'h00536793;

            // ANDI x16, x6, 5
            32'h00000024:
                instruction = 32'h00537813;

            // SLT x17, x6, x7
            32'h00000028:
                instruction = 32'h007328B3;

            // SLTI x18, x6, 25
            32'h0000002C:
                instruction = 32'h01932913;

            // SLTU x19, x6, x7
            32'h00000030:
                instruction = 32'h007339B3;

            // SLTU x21, x20, x7
            32'h00000034:
                instruction = 32'h007A3AB3;

            // SLL x22, x6, x7
            32'h00000038:
                instruction = 32'h00731B33;
            
            // SRL x23, x6, x7
            32'h0000003C:
                instruction = 32'h00735BB3;

            // SRA x24, x6, x7
            32'h00000040:
                instruction = 32'h40735C33;

            // SW x7, 12(x6)
            32'h00000044:
                instruction = 32'h00732623;
            
            // LW x5, 12(x6)
            32'h00000048:
                instruction = 32'h00C32283;

            // BEQ x6, x7, +8
            32'h0000004C:
                instruction = 32'h00730463;
            
            // BEQ x6, x6, +8
            32'h00000050:
                instruction = 32'h00630463;

            // BNE x6, x7, +8
            32'h00000058:
                instruction = 32'h00731463;

            // BLT x6, x7, +8
            32'h00000060:
                instruction = 32'h00734463;

            // BLT x7, x6, +8
            32'h00000064:
                instruction = 32'h0063C463;

            // BGE x7, x6, +8
            // 5 >= 20 → not taken
            32'h0000006C:
                instruction = 32'h0063D463;

            // BGE x6, x7, +8
            // 20 >= 5 → taken
            32'h00000070:
                instruction = 32'h00735463;

            // BLTU x20, x7, +8
            // 0xFFFFFFFF < 5 → false unsigned
            32'h00000078:
                instruction = 32'h007A6463;
            
            // BLTU x7, x6, +8
            // 5 < 20 → true unsigned
            32'h0000007C:
                instruction = 32'h0063E463;

            // BGEU x20, x7, +8
            // 0xFFFFFFFF >= 5 → true unsigned
            32'h00000084:
                instruction = 32'h007A7463;

            // BGEU x7, x6, +8
            // 5 >= 20 → false unsigned
            32'h0000008C:
                instruction = 32'h0063F463;

            // NOP
            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule