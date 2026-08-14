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

            // NOP
            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule