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

                2'b01: begin
                    // Halfword load: LH or LHU

                    case (addr[1])

                        1'b0: begin
                            if (mem_unsigned)
                                read_data = {16'b0, memory[addr[9:2]][15:0]};
                            else
                                read_data = {{16{memory[addr[9:2]][15]}},
                                             memory[addr[9:2]][15:0]};
                        end

                        1'b1: begin
                            if (mem_unsigned)
                                read_data = {16'b0, memory[addr[9:2]][31:16]};
                            else
                                read_data = {{16{memory[addr[9:2]][31]}},
                                             memory[addr[9:2]][31:16]};
                        end

                    endcase
                end

                2'b00: begin
                    // Byte load: LB or LBU

                    case (addr[1:0])

                        2'b00: begin
                            if (mem_unsigned)
                                read_data = {24'b0, memory[addr[9:2]][7:0]};
                            else
                                read_data = {{24{memory[addr[9:2]][7]}},
                                             memory[addr[9:2]][7:0]};
                        end

                        2'b01: begin
                            if (mem_unsigned)
                                read_data = {24'b0, memory[addr[9:2]][15:8]};
                            else
                                read_data = {{24{memory[addr[9:2]][15]}},
                                             memory[addr[9:2]][15:8]};
                        end

                        2'b10: begin
                            if (mem_unsigned)
                                read_data = {24'b0, memory[addr[9:2]][23:16]};
                            else
                                read_data = {{24{memory[addr[9:2]][23]}},
                                             memory[addr[9:2]][23:16]};
                        end

                        2'b11: begin
                            if (mem_unsigned)
                                read_data = {24'b0, memory[addr[9:2]][31:24]};
                            else
                                read_data = {{24{memory[addr[9:2]][31]}},
                                             memory[addr[9:2]][31:24]};
                        end

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

        if (mem_write) begin

            case (mem_size)

                2'b10: begin
                    // SW
                    memory[addr[9:2]] <= write_data;
                end

                2'b01: begin
                    // SH
                    if (addr[1] == 1'b0)
                        memory[addr[9:2]][15:0] <= write_data[15:0];
                    else
                        memory[addr[9:2]][31:16] <= write_data[15:0];
                end

                2'b00: begin
                    // SB
                    case (addr[1:0])

                        2'b00:
                            memory[addr[9:2]][7:0] <= write_data[7:0];

                        2'b01:
                            memory[addr[9:2]][15:8] <= write_data[7:0];

                        2'b10:
                            memory[addr[9:2]][23:16] <= write_data[7:0];

                        2'b11:
                            memory[addr[9:2]][31:24] <= write_data[7:0];

                    endcase
                end

                default: begin
                    // No write
                end

            endcase

        end

    end

endmodule