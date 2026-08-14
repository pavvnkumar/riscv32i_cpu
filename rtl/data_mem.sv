module data_mem (
    input  logic        clk,

    input  logic        mem_write,
    input  logic        mem_read,

    input  logic [31:0] addr,
    input  logic [31:0] write_data,

    output logic [31:0] read_data
);

    logic [31:0] memory [0:255];


    // Read
    always_comb begin

        if (mem_read)
            read_data = memory[addr[9:2]];
        else
            read_data = 32'b0;

    end


    // Write
    always_ff @(posedge clk) begin

        if (mem_write)
            memory[addr[9:2]] <= write_data;

    end

endmodule