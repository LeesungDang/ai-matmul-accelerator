module matmul_2x2_array #(
    parameter DATA_WIDTH = 8,
    parameter RESULT_WIDTH = (2*DATA_WIDTH)+1
)(
    input  logic signed [DATA_WIDTH-1:0] A [2][2],
    input  logic signed [DATA_WIDTH-1:0] B [2][2],
    output logic signed [RESULT_WIDTH-1:0] C [2][2]
);

    always_comb begin
        C[0][0] = (A[0][0] * B[0][0]) + (A[0][1] * B[1][0]);
        C[0][1] = (A[0][0] * B[0][1]) + (A[0][1] * B[1][1]);
        C[1][0] = (A[1][0] * B[0][0]) + (A[1][1] * B[1][0]);
        C[1][1] = (A[1][0] * B[0][1]) + (A[1][1] * B[1][1]);
    end

endmodule
