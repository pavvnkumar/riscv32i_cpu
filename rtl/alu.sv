module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_control,
    output logic [31:0] result
);

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

    always_comb begin

        case (alu_control)

            ALU_ADD:
                result = a + b;

            ALU_SUB:
                result = a - b;

            ALU_AND:
                result = a & b;

            ALU_OR:
                result = a | b;

            ALU_XOR:
                result = a ^ b;

            ALU_SLT: begin
                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            end

            ALU_SLTU: begin
                result = (a < b) ? 32'd1 : 32'd0;
            end

            ALU_SLL: begin
                result = a << b[4:0];
            end

            ALU_SRL: begin
                result = a >> b[4:0];
            end

            ALU_SRA: begin
                result = $signed(a) >>> b[4:0];
            end

            default:
                result = 32'b0;

        endcase

    end

endmodule