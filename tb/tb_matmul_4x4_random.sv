`timescale 1ns/1ps

module tb_matmul_4x4_random;

    localparam DATA_WIDTH = 8;
    localparam RESULT_WIDTH = (2*DATA_WIDTH)+2;
    localparam NUM_TESTS = 10;
    localparam VALUES_PER_TEST = 48;

    logic signed [DATA_WIDTH-1:0] A [4][4];
    logic signed [DATA_WIDTH-1:0] B [4][4];
    logic signed [RESULT_WIDTH-1:0] C [4][4];

    integer vectors [0:(NUM_TESTS*VALUES_PER_TEST)-1];
    integer idx;
    integer errors;

    matmul_4x4 #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESULT_WIDTH(RESULT_WIDTH)
    ) dut (
        .A(A),
        .B(B),
        .C(C)
    );

    initial begin
        $dumpfile("waveforms/matmul_4x4_random.vcd");
        $dumpvars(0, tb_matmul_4x4_random);

        $readmemh("python/matmul4_vectors.mem", vectors);

        errors = 0;

        for (int t = 0; t < NUM_TESTS; t++) begin
            idx = t * VALUES_PER_TEST;

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    A[i][j] = vectors[idx];
                    idx++;
                end
            end

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    B[i][j] = vectors[idx];
                    idx++;
                end
            end

            #10;

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    if (C[i][j] !== vectors[idx]) begin
                        $display("TEST %0d FAILED at C[%0d][%0d]: expected %0d, got %0d",
                                 t, i, j, vectors[idx], C[i][j]);
                        errors++;
                    end
                    idx++;
                end
            end
        end

        if (errors == 0) begin
            $display("RANDOMIZED 4x4 MATMUL TESTS PASSED");
        end else begin
            $display("RANDOMIZED 4x4 MATMUL TESTS FAILED with %0d errors", errors);
        end

        $finish;
    end

endmodule
