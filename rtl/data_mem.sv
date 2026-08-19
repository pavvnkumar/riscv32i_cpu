module data_mem (
    input  logic        clk,

    input  logic        mem_write,
    input  logic        mem_read,

    input  logic [31:0] addr,
    input  logic [31:0] write_data,

    input logic [1:0] mem_size,
    input logic       mem_unsigned,

    output logic [31:0] read_data
);

    logic [31:0] memory [0:255];


    // Read
    always_comb begin

        read_data = 32'b0;

        if (mem_read) begin

            case (mem_size)

                2'b10: begin
                    // LW
                    read_data = memory[addr[9:2]];
                end

                2'b00: begin
                    // LB
                    case (addr[1:0])

                        2'b00:
                            read_data = {{24{memory[addr[9:2]][7]}},
                                         memory[addr[9:2]][7:0]};

                        2'b01:
                            read_data = {{24{memory[addr[9:2]][15]}},
                                         memory[addr[9:2]][15:8]};

                        2'b10:
                            read_data = {{24{memory[addr[9:2]][23]}},
                                         memory[addr[9:2]][23:16]};

                        2'b11:
                            read_data = {{24{memory[addr[9:2]][31]}},
                                         memory[addr[9:2]][31:24]};

                    endcase
                end

                default: begin
                    read_data = 32'b0;
                end

            endcase

        end

    end


    // Write
    always_ff @(posedge clk) begin

        if (mem_write)
            memory[addr[9:2]] <= write_data;

    end

endmodule