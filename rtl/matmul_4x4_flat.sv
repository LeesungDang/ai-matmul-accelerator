module matmul_4x4_flat #(
    parameter DATA_WIDTH = 8,
    parameter RESULT_WIDTH = (2*DATA_WIDTH)+2
)(
    input  logic signed [(16*DATA_WIDTH)-1:0] A_flat,
    input  logic signed [(16*DATA_WIDTH)-1:0] B_flat,
    output logic signed [(16*RESULT_WIDTH)-1:0] C_flat
);

    integer acc;
    integer a_val;
    integer b_val;

    always_comb begin
        C_flat = '0;

        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                acc = 0;

                for (int k = 0; k < 4; k++) begin
                    a_val = $signed(A_flat[((i*4+k)*DATA_WIDTH) +: DATA_WIDTH]);
                    b_val = $signed(B_flat[((k*4+j)*DATA_WIDTH) +: DATA_WIDTH]);
                    acc = acc + (a_val * b_val);
                end

                C_flat[((i*4+j)*RESULT_WIDTH) +: RESULT_WIDTH] = acc[RESULT_WIDTH-1:0];
            end
        end
    end

endmodule
