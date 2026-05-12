`timescale 1ns/1ps

module tb_matmul_4x4_seq_random;

    localparam DATA_WIDTH = 8;
    localparam ACC_WIDTH = (2*DATA_WIDTH)+4;
    localparam NUM_TESTS = 10;

    logic clk;
    logic rst;
    logic start;
    logic done;

    logic signed [DATA_WIDTH-1:0] A [4][4];
    logic signed [DATA_WIDTH-1:0] B [4][4];
    logic signed [ACC_WIDTH-1:0] C [4][4];

    integer expected_C [4][4];
    integer file;
    integer scan_result;
    integer temp_value;
    integer errors;

    matmul_4x4_seq #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        start = 1'b0;

        $dumpfile("waveforms/matmul_4x4_seq_random.vcd");
        $dumpvars(0, tb_matmul_4x4_seq_random);

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
                    if (scan_result != 1) begin
                        $display("ERROR: failed to read A for test %0d at [%0d][%0d]", t, i, j);
                        $finish;
                    end
                    A[i][j] = temp_value;
                end
            end

            // Read B matrix
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    if (scan_result != 1) begin
                        $display("ERROR: failed to read B for test %0d at [%0d][%0d]", t, i, j);
                        $finish;
                    end
                    B[i][j] = temp_value;
                end
            end

            // Read expected C matrix
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    if (scan_result != 1) begin
                        $display("ERROR: failed to read expected C for test %0d at [%0d][%0d]", t, i, j);
                        $finish;
                    end
                    expected_C[i][j] = temp_value;
                end
            end

            // Reset the DUT for each test case.
            rst = 1'b1;
            @(posedge clk);
            @(posedge clk);
            rst = 1'b0;

            // Pulse start for one clock cycle.
            @(posedge clk);
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            wait (done == 1'b1);
            @(posedge clk);

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
            $display("RANDOMIZED 4x4 SEQUENTIAL MATMUL TESTS PASSED");
        end else begin
            $display("RANDOMIZED 4x4 SEQUENTIAL MATMUL TESTS FAILED with %0d errors", errors);
        end

        $finish;
    end

endmodule
