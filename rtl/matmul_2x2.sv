module matmul_2x2 #(
    parameter DATA_WIDTH = 8,
    parameter RESULT_WIDTH = (2*DATA_WIDTH)+1
)(
    input  logic signed [DATA_WIDTH-1:0] a00,
    input  logic signed [DATA_WIDTH-1:0] a01,
    input  logic signed [DATA_WIDTH-1:0] a10,
    input  logic signed [DATA_WIDTH-1:0] a11,

    input  logic signed [DATA_WIDTH-1:0] b00,
    input  logic signed [DATA_WIDTH-1:0] b01,
    input  logic signed [DATA_WIDTH-1:0] b10,
    input  logic signed [DATA_WIDTH-1:0] b11,

    output logic signed [RESULT_WIDTH-1:0] c00,
    output logic signed [RESULT_WIDTH-1:0] c01,
    output logic signed [RESULT_WIDTH-1:0] c10,
    output logic signed [RESULT_WIDTH-1:0] c11
);

    always_comb begin
        c00 = (a00 * b00) + (a01 * b10);
        c01 = (a00 * b01) + (a01 * b11);
        c10 = (a10 * b00) + (a11 * b10);
        c11 = (a10 * b01) + (a11 * b11);
    end

endmodule
