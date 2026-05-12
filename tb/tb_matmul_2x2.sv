`timescale 1ns/1ps

module tb_matmul_2x2;

    localparam DATA_WIDTH = 8;
    localparam RESULT_WIDTH = (2*DATA_WIDTH)+1;

    logic signed [DATA_WIDTH-1:0] a00, a01, a10, a11;
    logic signed [DATA_WIDTH-1:0] b00, b01, b10, b11;

    logic signed [RESULT_WIDTH-1:0] c00, c01, c10, c11;

    matmul_2x2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESULT_WIDTH(RESULT_WIDTH)
    ) dut (
        .a00(a00), .a01(a01), .a10(a10), .a11(a11),
        .b00(b00), .b01(b01), .b10(b10), .b11(b11),
        .c00(c00), .c01(c01), .c10(c10), .c11(c11)
    );

    initial begin
        $dumpfile("waveforms/matmul_2x2.vcd");
        $dumpvars(0, tb_matmul_2x2);

        // A = [1 2]
        //     [3 4]
        a00 = 8'sd1; a01 = 8'sd2;
        a10 = 8'sd3; a11 = 8'sd4;

        // B = [5 6]
        //     [7 8]
        b00 = 8'sd5; b01 = 8'sd6;
        b10 = 8'sd7; b11 = 8'sd8;

        #10;

        $display("C = [%0d %0d; %0d %0d]", c00, c01, c10, c11);

        if (c00 == 19 && c01 == 22 && c10 == 43 && c11 == 50) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
            $display("Expected C = [19 22; 43 50]");
        end

        $finish;
    end

endmodule
