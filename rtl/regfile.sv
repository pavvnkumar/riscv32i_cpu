module regfile (
    input  logic        clk,

    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,

    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    input  logic        write_en,

    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [0:31];

    initial begin
        for (int i = 0; i < 32; i++)
            registers[i] = 32'd0;

        registers[6] = 32'd10;
        registers[7] = 32'd20;
    end

    always_comb begin
        if (rs1 == 5'd0)
            read_data1 = 32'd0;
        else
            read_data1 = registers[rs1];

        if (rs2 == 5'd0)
            read_data2 = 32'd0;
        else
            read_data2 = registers[rs2];
    end

    always_ff @(posedge clk) begin
        if (write_en && (rd != 5'd0))
            registers[rd] <= write_data;
    end

endmodule