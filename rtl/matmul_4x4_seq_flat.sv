module matmul_4x4_seq_flat #(
    parameter DATA_WIDTH = 8,
    parameter RESULT_WIDTH = (2*DATA_WIDTH)+4
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic signed [(16*DATA_WIDTH)-1:0] A_flat,
    input  logic signed [(16*DATA_WIDTH)-1:0] B_flat,
    output logic signed [(16*RESULT_WIDTH)-1:0] C_flat,
    output logic done
);

    localparam int MATRIX_DIM = 4;
    localparam int PRODUCT_WIDTH = 2 * DATA_WIDTH;

    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        DONE
    } state_t;

    state_t state;

    logic [1:0] row_idx;
    logic [1:0] col_idx;
    logic [1:0] k_idx;
    logic signed [RESULT_WIDTH-1:0] acc;

    logic signed [DATA_WIDTH-1:0] a_val;
    logic signed [DATA_WIDTH-1:0] b_val;
    logic signed [PRODUCT_WIDTH-1:0] product;
    logic signed [RESULT_WIDTH-1:0] product_ext;
    logic signed [RESULT_WIDTH-1:0] next_acc;

    always_comb begin
        a_val = A_flat[((row_idx*MATRIX_DIM+k_idx)*DATA_WIDTH) +: DATA_WIDTH];
        b_val = B_flat[((k_idx*MATRIX_DIM+col_idx)*DATA_WIDTH) +: DATA_WIDTH];
        product = a_val * b_val;
        product_ext = {{(RESULT_WIDTH-PRODUCT_WIDTH){product[PRODUCT_WIDTH-1]}}, product};
        next_acc = acc + product_ext;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            row_idx <= 2'd0;
            col_idx <= 2'd0;
            k_idx   <= 2'd0;
            acc     <= '0;
            C_flat  <= '0;
            done    <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;

                    if (start) begin
                        row_idx <= 2'd0;
                        col_idx <= 2'd0;
                        k_idx   <= 2'd0;
                        acc     <= '0;
                        C_flat  <= '0;
                        state   <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    if (k_idx == 2'd3) begin
                        C_flat[((row_idx*MATRIX_DIM+col_idx)*RESULT_WIDTH) +: RESULT_WIDTH] <= next_acc;
                        acc <= '0;
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

                    if (!start) begin
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
