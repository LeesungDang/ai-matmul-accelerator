`timescale 1ns/1ps

module tb_matmul_4x4_mmio_random;

    localparam int NUM_TESTS = 10;
    localparam logic [7:0] CTRL_ADDR = 8'h00;
    localparam logic [7:0] A_BASE    = 8'h10;
    localparam logic [7:0] B_BASE    = 8'h50;
    localparam logic [7:0] C_BASE    = 8'h90;

    logic clk;
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [7:0] addr;
    logic signed [31:0] wr_data;
    logic signed [31:0] rd_data;
    logic done;

    integer expected_C [0:3][0:3];
    integer file;
    integer scan_result;
    integer temp_value;
    integer read_value;
    integer errors;

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

    task automatic reset_dut;
        begin
            rst = 1'b1;
            wr_en = 1'b0;
            rd_en = 1'b0;
            addr = 8'h00;
            wr_data = 32'sd0;
            @(posedge clk);
            @(posedge clk);
            rst = 1'b0;
        end
    endtask

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
        rst = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        addr = 8'h00;
        wr_data = 32'sd0;

        $dumpfile("waveforms/matmul_4x4_mmio_random.vcd");
        $dumpvars(0, tb_matmul_4x4_mmio_random);

        file = $fopen("python/matmul4_vectors.mem", "r");
        if (file == 0) begin
            $display("ERROR: could not open python/matmul4_vectors.mem");
            $finish;
        end

        errors = 0;

        for (int t = 0; t < NUM_TESTS; t++) begin
            reset_dut();

            // Read and write A through MMIO.
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    if (scan_result != 1) begin
                        $display("ERROR: failed to read A for test %0d at [%0d][%0d]", t, i, j);
                        $finish;
                    end
                    mmio_write(A_BASE + ((i * 4 + j) * 4), temp_value);
                end
            end

            // Read and write B through MMIO.
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    scan_result = $fscanf(file, "%d", temp_value);
                    if (scan_result != 1) begin
                        $display("ERROR: failed to read B for test %0d at [%0d][%0d]", t, i, j);
                        $finish;
                    end
                    mmio_write(B_BASE + ((i * 4 + j) * 4), temp_value);
                end
            end

            // Read expected C matrix.
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

            mmio_write(CTRL_ADDR, 32'sd1);

            wait (done == 1'b1);
            @(posedge clk);

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    mmio_read(C_BASE + ((i * 4 + j) * 4), read_value);
                    if (read_value !== expected_C[i][j]) begin
                        $display("TEST %0d FAILED at C[%0d][%0d]: expected %0d, got %0d",
                                 t, i, j, expected_C[i][j], read_value);
                        errors++;
                    end
                end
            end

            mmio_read(CTRL_ADDR, read_value);
            if (read_value[1] !== 1'b1) begin
                $display("TEST %0d FAILED: done bit was not set in control register", t);
                errors++;
            end
        end

        $fclose(file);

        if (errors == 0) begin
            $display("RANDOMIZED 4x4 MMIO MATMUL TESTS PASSED");
        end else begin
            $display("RANDOMIZED 4x4 MMIO MATMUL TESTS FAILED with %0d errors", errors);
            $finish;
        end

        $finish;
    end

endmodule
