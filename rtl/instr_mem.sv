module instr_mem #(
    parameter string PROGRAM_FILE = "programs/cpu_test.hex",
    parameter int MEM_SIZE = 4096
) (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

    logic [7:0] mem [0:MEM_SIZE-1];

    initial begin
        $readmemh(PROGRAM_FILE, mem);
    end

    always_comb begin
        instruction = {
            mem[addr + 32'd3],
            mem[addr + 32'd2],
            mem[addr + 32'd1],
            mem[addr]
        };
    end

endmodule