module tb_instr_mem;

    localparam int MEM_SIZE = 4096;

    logic [31:0] addr;
    logic [31:0] instruction;

    logic [7:0] expected_mem [0:MEM_SIZE-1];

    integer image_bytes;
    integer test_addr;
    logic [31:0] expected_instruction;

    instr_mem dut (
        .addr        (addr),
        .instruction (instruction)
    );

    initial begin

    // Mark unused image space as unknown before loading the program.
    for (int i = 0; i < MEM_SIZE; i = i + 1)
        expected_mem[i] = 8'hxx;

    // Load the same generated program image used by instr_mem.
    $readmemh("programs/cpu_test.hex", expected_mem);

        // Determine the number of bytes present in the image.
        image_bytes = 0;

        while (
            image_bytes < MEM_SIZE &&
            expected_mem[image_bytes] !== 8'hxx
        ) begin
            image_bytes = image_bytes + 1;
        end

        // Program image must contain complete 32-bit instructions.
        if ((image_bytes == 0) || ((image_bytes % 4) != 0))
            $fatal(
                "Invalid program image size: %0d bytes",
                image_bytes
            );

        // Compare every instruction in the generated image.
        for (test_addr = 0;
             test_addr < image_bytes;
             test_addr = test_addr + 4) begin

            addr = test_addr;
            #1;

            expected_instruction = {
                expected_mem[test_addr + 3],
                expected_mem[test_addr + 2],
                expected_mem[test_addr + 1],
                expected_mem[test_addr]
            };

            if (instruction !== expected_instruction)
                $fatal(
                    "Instruction memory mismatch at 0x%08h: got %08h, expected %08h",
                    test_addr,
                    instruction,
                    expected_instruction
                );

        end

        $display("");
        $display("========================================");
        $display("INSTRUCTION MEMORY TEST PASSED");
        $display("Checked %0d instructions (%0d bytes)",
                 image_bytes / 4,
                 image_bytes);
        $display("========================================");
        $display("");

        $finish;
    end

endmodule