`timescale 1ns/1ps

module tb_matmul_4x4_mmio;

    logic clk;
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [7:0] addr;
    logic signed [31:0] wr_data;
    logic signed [31:0] rd_data;
    logic done;

    integer expected_C [0:3][0:3];
    integer read_value;

    matmul_4x4_mmio dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .done(done)
    );

    always #5 clk = ~clk;

    task automatic mmio_write(
        input logic [7:0] write_addr,
        input logic signed [31:0] write_data
    );
        begin
            @(negedge clk);
            addr = write_addr;
            wr_data = write_data;
            wr_en = 1'b1;
            rd_en = 1'b0;
            @(negedge clk);
            wr_en = 1'b0;
            addr = 8'h00;
            wr_data = 32'sd0;
        end
    endtask

    task automatic mmio_read(
        input logic [7:0] read_addr,
        output integer value
    );
        begin
            @(negedge clk);
            addr = read_addr;
            wr_en = 1'b0;
            rd_en = 1'b1;
            #1;
            value = rd_data;
            @(negedge clk);
            rd_en = 1'b0;
            addr = 8'h00;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        addr = 8'h00;
        wr_data = 32'sd0;

        $dumpfile("waveforms/matmul_4x4_mmio.vcd");
        $dumpvars(0, tb_matmul_4x4_mmio);

        expected_C[0][0] = 250;  expected_C[0][1] = 260;  expected_C[0][2] = 270;  expected_C[0][3] = 280;
        expected_C[1][0] = 618;  expected_C[1][1] = 644;  expected_C[1][2] = 670;  expected_C[1][3] = 696;
        expected_C[2][0] = 986;  expected_C[2][1] = 1028; expected_C[2][2] = 1070; expected_C[2][3] = 1112;
        expected_C[3][0] = 1354; expected_C[3][1] = 1412; expected_C[3][2] = 1470; expected_C[3][3] = 1528;

        repeat (2) @(negedge clk);
        rst = 1'b0;

        // Write A matrix through MMIO.
        mmio_write(8'h10, 32'sd1);   mmio_write(8'h14, 32'sd2);   mmio_write(8'h18, 32'sd3);   mmio_write(8'h1c, 32'sd4);
        mmio_write(8'h20, 32'sd5);   mmio_write(8'h24, 32'sd6);   mmio_write(8'h28, 32'sd7);   mmio_write(8'h2c, 32'sd8);
        mmio_write(8'h30, 32'sd9);   mmio_write(8'h34, 32'sd10);  mmio_write(8'h38, 32'sd11);  mmio_write(8'h3c, 32'sd12);
        mmio_write(8'h40, 32'sd13);  mmio_write(8'h44, 32'sd14);  mmio_write(8'h48, 32'sd15);  mmio_write(8'h4c, 32'sd16);

        // Write B matrix through MMIO.
        mmio_write(8'h50, 32'sd17);  mmio_write(8'h54, 32'sd18);  mmio_write(8'h58, 32'sd19);  mmio_write(8'h5c, 32'sd20);
        mmio_write(8'h60, 32'sd21);  mmio_write(8'h64, 32'sd22);  mmio_write(8'h68, 32'sd23);  mmio_write(8'h6c, 32'sd24);
        mmio_write(8'h70, 32'sd25);  mmio_write(8'h74, 32'sd26);  mmio_write(8'h78, 32'sd27);  mmio_write(8'h7c, 32'sd28);
        mmio_write(8'h80, 32'sd29);  mmio_write(8'h84, 32'sd30);  mmio_write(8'h88, 32'sd31);  mmio_write(8'h8c, 32'sd32);

        // Start the accelerator.
        mmio_write(8'h00, 32'sd1);

        wait (done == 1'b1);
        @(posedge clk);

        $display("C =");
        for (int i = 0; i < 4; i++) begin
            $write("[");
            for (int j = 0; j < 4; j++) begin
                mmio_read(8'h90 + ((i*4+j) * 4), read_value);
                $write("%0d", read_value);
                if (j != 3) begin
                    $write(" ");
                end

                if (read_value !== expected_C[i][j]) begin
                    $display("]");
                    $display("TEST FAILED: C[%0d][%0d] expected %0d got %0d",
                             i, j, expected_C[i][j], read_value);
                    $finish;
                end
            end
            $display("]");
        end

        mmio_read(8'h00, read_value);
        if (read_value[1] !== 1'b1) begin
            $display("TEST FAILED: done bit was not set in control register");
            $finish;
        end

        $display("TEST PASSED");
        $finish;
    end

endmodule
