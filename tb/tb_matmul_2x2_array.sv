`timescale 1ns/1ps

module tb_matmul_2x2_array;

    localparam DATA_WIDTH = 8;
    localparam RESULT_WIDTH = (2*DATA_WIDTH)+1;

    logic signed [DATA_WIDTH-1:0] A [2][2];
    logic signed [DATA_WIDTH-1:0] B [2][2];
    logic signed [RESULT_WIDTH-1:0] C [2][2];

    matmul_2x2_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESULT_WIDTH(RESULT_WIDTH)
    ) dut (
        .A(A),
        .B(B),
        .C(C)
    );

    initial begin
        $dumpfile("waveforms/matmul_2x2_array.vcd");
        $dumpvars(0, tb_matmul_2x2_array);

        A[0][0] = 8'sd1; A[0][1] = 8'sd2;
        A[1][0] = 8'sd3; A[1][1] = 8'sd4;

        B[0][0] = 8'sd5; B[0][1] = 8'sd6;
        B[1][0] = 8'sd7; B[1][1] = 8'sd8;

        #10;

        $display("C = [%0d %0d; %0d %0d]",
                 C[0][0], C[0][1], C[1][0], C[1][1]);

        if (C[0][0] == 19 && C[0][1] == 22 &&
            C[1][0] == 43 && C[1][1] == 50) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
            $display("Expected C = [19 22; 43 50]");
        end

        $finish;
    end

endmodule
