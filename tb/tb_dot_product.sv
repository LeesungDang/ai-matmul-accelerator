`timescale 1ns/1ps

module tb_dot_product;

    localparam DATA_WIDTH = 8;
    localparam VECTOR_LEN = 4;

    logic signed [DATA_WIDTH-1:0] a [VECTOR_LEN];
    logic signed [DATA_WIDTH-1:0] b [VECTOR_LEN];
    logic signed [(2*DATA_WIDTH)+2:0] result;

    dot_product #(
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_LEN(VECTOR_LEN)
    ) dut (
        .a(a),
        .b(b),
        .result(result)
    );

    initial begin
        $dumpfile("waveforms/dot_product.vcd");
        $dumpvars(0, tb_dot_product);

        a[0] = 8'sd1;  b[0] = 8'sd5;
        a[1] = 8'sd2;  b[1] = 8'sd6;
        a[2] = 8'sd3;  b[2] = 8'sd7;
        a[3] = 8'sd4;  b[3] = 8'sd8;

        #10;

        $display("Dot product result = %0d", result);

        if (result == 70) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: expected 70, got %0d", result);
        end

        $finish;
    end

endmodule
