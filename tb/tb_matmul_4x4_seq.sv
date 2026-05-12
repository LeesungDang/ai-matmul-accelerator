`timescale 1ns/1ps

module tb_matmul_4x4_seq;

    localparam DATA_WIDTH = 8;
    localparam ACC_WIDTH = (2*DATA_WIDTH)+4;

    logic clk;
    logic rst;
    logic start;
    logic done;

    logic signed [DATA_WIDTH-1:0] A [4][4];
    logic signed [DATA_WIDTH-1:0] B [4][4];
    logic signed [ACC_WIDTH-1:0] C [4][4];

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
        rst = 1'b1;
        start = 1'b0;

        $dumpfile("waveforms/matmul_4x4_seq.vcd");
        $dumpvars(0, tb_matmul_4x4_seq);

        // A =
        // [1  2  3  4]
        // [5  6  7  8]
        // [9  10 11 12]
        // [13 14 15 16]
        A[0][0] = 8'sd1;  A[0][1] = 8'sd2;  A[0][2] = 8'sd3;  A[0][3] = 8'sd4;
        A[1][0] = 8'sd5;  A[1][1] = 8'sd6;  A[1][2] = 8'sd7;  A[1][3] = 8'sd8;
        A[2][0] = 8'sd9;  A[2][1] = 8'sd10; A[2][2] = 8'sd11; A[2][3] = 8'sd12;
        A[3][0] = 8'sd13; A[3][1] = 8'sd14; A[3][2] = 8'sd15; A[3][3] = 8'sd16;

        // B =
        // [17 18 19 20]
        // [21 22 23 24]
        // [25 26 27 28]
        // [29 30 31 32]
        B[0][0] = 8'sd17; B[0][1] = 8'sd18; B[0][2] = 8'sd19; B[0][3] = 8'sd20;
        B[1][0] = 8'sd21; B[1][1] = 8'sd22; B[1][2] = 8'sd23; B[1][3] = 8'sd24;
        B[2][0] = 8'sd25; B[2][1] = 8'sd26; B[2][2] = 8'sd27; B[2][3] = 8'sd28;
        B[3][0] = 8'sd29; B[3][1] = 8'sd30; B[3][2] = 8'sd31; B[3][3] = 8'sd32;

        #12;
        rst = 1'b0;

        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

        wait (done == 1'b1);
        @(posedge clk);

        $display("C =");
        for (int i = 0; i < 4; i++) begin
            $display("[%0d %0d %0d %0d]", C[i][0], C[i][1], C[i][2], C[i][3]);
        end

        if (
            C[0][0] == 250 && C[0][1] == 260 && C[0][2] == 270 && C[0][3] == 280 &&
            C[1][0] == 618 && C[1][1] == 644 && C[1][2] == 670 && C[1][3] == 696 &&
            C[2][0] == 986 && C[2][1] == 1028 && C[2][2] == 1070 && C[2][3] == 1112 &&
            C[3][0] == 1354 && C[3][1] == 1412 && C[3][2] == 1470 && C[3][3] == 1528
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
