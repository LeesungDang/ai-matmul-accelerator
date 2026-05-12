`timescale 1ns/1ps

module tb_matmul_4x4_random;

    localparam DATA_WIDTH = 8;
    localparam RESULT_WIDTH = (2*DATA_WIDTH)+2;
    localparam NUM_TESTS = 10;

    logic signed [DATA_WIDTH-1:0] A [4][4];
    logic signed [DATA_WIDTH-1:0] B [4][4];
    logic signed [RESULT_WIDTH-1:0] C [4][4];

    integer expected_C [4][4];
    integer file;
    integer scan_result;
    integer temp_value;
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

        file = $fopen("python/matmul4_vectors.mem", "r");

        if (file == 0) begin
            $display("ERROR: could not open python/matmul4_vectors.mem");
            $finish;
        end

        errors = 0;

        for (int t = 0; t < NUM_TESTS; t++) begin

            // Read A matrix
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    A[i][j] = temp_value;
                end
            end

            // Read B matrix
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    B[i][j] = temp_value;
                end
            end

            // Read expected C matrix
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    expected_C[i][j] = temp_value;
                end
            end

            #10;

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    if (C[i][j] !== expected_C[i][j]) begin
                        $display("TEST %0d FAILED at C[%0d][%0d]: expected %0d, got %0d",
                                 t, i, j, expected_C[i][j], C[i][j]);
                        errors++;
                    end
                end
            end
        end

        $fclose(file);

        if (errors == 0) begin
            $display("RANDOMIZED 4x4 MATMUL TESTS PASSED");
        end else begin
            $display("RANDOMIZED 4x4 MATMUL TESTS FAILED with %0d errors", errors);
        end

        $finish;
    end

endmodule
