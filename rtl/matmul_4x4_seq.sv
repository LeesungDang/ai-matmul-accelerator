module matmul_4x4_seq #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = (2*DATA_WIDTH)+4
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic signed [DATA_WIDTH-1:0] A [4][4],
    input  logic signed [DATA_WIDTH-1:0] B [4][4],
    output logic signed [ACC_WIDTH-1:0] C [4][4],
    output logic done
);

    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        DONE
    } state_t;

    state_t state;

    logic [1:0] row_idx;
    logic [1:0] col_idx;
    logic [1:0] k_idx;
    logic signed [ACC_WIDTH-1:0] acc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            row_idx <= 2'd0;
            col_idx <= 2'd0;
            k_idx   <= 2'd0;
            acc     <= '0;
            done    <= 1'b0;

            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    C[i][j] <= '0;
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;

                    if (start) begin
                        row_idx <= 2'd0;
                        col_idx <= 2'd0;
                        k_idx   <= 2'd0;
                        acc     <= '0;

                        for (int i = 0; i < 4; i++) begin
                            for (int j = 0; j < 4; j++) begin
                                C[i][j] <= '0;
                            end
                        end

                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    logic signed [ACC_WIDTH-1:0] product;
                    logic signed [ACC_WIDTH-1:0] next_acc;

                    product = A[row_idx][k_idx] * B[k_idx][col_idx];
                    next_acc = acc + product;

                    if (k_idx == 2'd3) begin
                        C[row_idx][col_idx] <= next_acc;
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
