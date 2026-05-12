module dot_product #(
    parameter DATA_WIDTH = 8,
    parameter VECTOR_LEN = 4
)(
    input  logic signed [DATA_WIDTH-1:0] a [VECTOR_LEN],
    input  logic signed [DATA_WIDTH-1:0] b [VECTOR_LEN],
    output logic signed [(2*DATA_WIDTH)+2:0] result
);

    always_comb begin
        result = '0;

        for (int i = 0; i < VECTOR_LEN; i++) begin
            result += a[i] * b[i];
        end
    end

endmodule
