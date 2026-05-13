module matmul_4x4_mmio (
    input  logic clk,
    input  logic rst,
    input  logic wr_en,
    input  logic rd_en,
    input  logic [7:0] addr,
    input  logic signed [31:0] wr_data,
    output logic signed [31:0] rd_data,
    output logic done
);

    localparam logic [7:0] CTRL_ADDR = 8'h00;
    localparam logic [7:0] A_BASE    = 8'h10;
    localparam logic [7:0] A_LAST    = 8'h4c;
    localparam logic [7:0] B_BASE    = 8'h50;
    localparam logic [7:0] B_LAST    = 8'h8c;
    localparam logic [7:0] C_BASE    = 8'h90;
    localparam logic [7:0] C_LAST    = 8'hcc;
    localparam int MATRIX_DIM        = 4;
    localparam int ACC_WIDTH         = 32;

    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        DONE
    } state_t;

    state_t state;

    logic signed [7:0]  A [0:3][0:3];
    logic signed [7:0]  B [0:3][0:3];
    logic signed [31:0] C [0:3][0:3];

    logic [1:0] row_idx;
    logic [1:0] col_idx;
    logic [1:0] k_idx;
    logic signed [ACC_WIDTH-1:0] acc;

    logic start_pulse;
    logic signed [15:0] product;
    logic signed [31:0] product_ext;
    logic signed [31:0] next_acc;

    function automatic logic addr_in_range(
        input logic [7:0] addr_value,
        input logic [7:0] base_addr,
        input logic [7:0] last_addr
    );
        addr_in_range = (addr_value >= base_addr) && (addr_value <= last_addr) && (addr_value[1:0] == 2'b00);
    endfunction

    function automatic logic [1:0] mmio_row(
        input logic [7:0] addr_value,
        input logic [7:0] base_addr
    );
        logic [5:0] offset_words;
        begin
            offset_words = (addr_value - base_addr) >> 2;
            mmio_row = offset_words[5:2];
        end
    endfunction

    function automatic logic [1:0] mmio_col(
        input logic [7:0] addr_value,
        input logic [7:0] base_addr
    );
        logic [5:0] offset_words;
        begin
            offset_words = (addr_value - base_addr) >> 2;
            mmio_col = offset_words[1:0];
        end
    endfunction

    assign product = A[row_idx][k_idx] * B[k_idx][col_idx];
    assign product_ext = {{16{product[15]}}, product};
    assign next_acc = acc + product_ext;
    assign start_pulse = wr_en && (addr == CTRL_ADDR) && wr_data[0];

    always @(*) begin
        rd_data = 32'sd0;

        if (rd_en) begin
            if (addr == CTRL_ADDR) begin
                rd_data = {30'd0, done, 1'b0};
            end else if (addr_in_range(addr, A_BASE, A_LAST)) begin
                rd_data = {{24{A[mmio_row(addr, A_BASE)][mmio_col(addr, A_BASE)][7]}},
                           A[mmio_row(addr, A_BASE)][mmio_col(addr, A_BASE)]};
            end else if (addr_in_range(addr, B_BASE, B_LAST)) begin
                rd_data = {{24{B[mmio_row(addr, B_BASE)][mmio_col(addr, B_BASE)][7]}},
                           B[mmio_row(addr, B_BASE)][mmio_col(addr, B_BASE)]};
            end else if (addr_in_range(addr, C_BASE, C_LAST)) begin
                rd_data = C[mmio_row(addr, C_BASE)][mmio_col(addr, C_BASE)];
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            row_idx <= 2'd0;
            col_idx <= 2'd0;
            k_idx   <= 2'd0;
            acc     <= 32'sd0;
            done    <= 1'b0;

            for (int i = 0; i < MATRIX_DIM; i++) begin
                for (int j = 0; j < MATRIX_DIM; j++) begin
                    A[i][j] <= 8'sd0;
                    B[i][j] <= 8'sd0;
                    C[i][j] <= 32'sd0;
                end
            end
        end else begin
            if (wr_en && addr_in_range(addr, A_BASE, A_LAST)) begin
                A[mmio_row(addr, A_BASE)][mmio_col(addr, A_BASE)] <= wr_data[7:0];
            end

            if (wr_en && addr_in_range(addr, B_BASE, B_LAST)) begin
                B[mmio_row(addr, B_BASE)][mmio_col(addr, B_BASE)] <= wr_data[7:0];
            end

            case (state)
                IDLE: begin
                    done <= 1'b0;

                    if (start_pulse) begin
                        row_idx <= 2'd0;
                        col_idx <= 2'd0;
                        k_idx   <= 2'd0;
                        acc     <= 32'sd0;
                        done    <= 1'b0;

                        for (int i = 0; i < MATRIX_DIM; i++) begin
                            for (int j = 0; j < MATRIX_DIM; j++) begin
                                C[i][j] <= 32'sd0;
                            end
                        end

                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    if (k_idx == 2'd3) begin
                        C[row_idx][col_idx] <= next_acc;
                        acc <= 32'sd0;
                        k_idx <= 2'd0;

                        if (col_idx == 2'd3) begin
                            col_idx <= 2'd0;

                            if (row_idx == 2'd3) begin
                                state <= DONE;
                            end else begin
                                row_idx <= row_idx + 2'd1;
                            end
                        end else begin
                            col_idx <= col_idx + 2'd1;
                        end
                    end else begin
                        acc <= next_acc;
                        k_idx <= k_idx + 2'd1;
                    end
                end

                DONE: begin
                    done <= 1'b1;

                    if (start_pulse) begin
                        row_idx <= 2'd0;
                        col_idx <= 2'd0;
                        k_idx   <= 2'd0;
                        acc     <= 32'sd0;
                        done    <= 1'b0;

                        for (int i = 0; i < MATRIX_DIM; i++) begin
                            for (int j = 0; j < MATRIX_DIM; j++) begin
                                C[i][j] <= 32'sd0;
                            end
                        end

                        state <= COMPUTE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
