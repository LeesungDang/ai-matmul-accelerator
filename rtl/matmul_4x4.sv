module matmul_4x4 #(
    parameter DATA_WIDTH = 8,
    parameter RESULT_WIDTH = (2*DATA_WIDTH)+2
)(
    input  logic signed [DATA_WIDTH-1:0] A [4][4],
    input  logic signed [DATA_WIDTH-1:0] B [4][4],
    output logic signed [RESULT_WIDTH-1:0] C [4][4]
);

    integer acc;

    always_comb begin
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                acc = 0;

                for (int k = 0; k < 4; k++) begin
                    acc = acc + (integer'(A[i][k]) * integer'(B[k][j]));
                end

                C[i][j] = acc;
            end
        end
    end

endmodule
