`timescale 1ns/1ps
//==============================================================
// bitonic_merge64.sv
// Merges 64 elements using bitonic merge + direction control
// Input must be bitonic:
//   Left 32 ascending
//   Right 32 descending
//==============================================================

module bitonic_merge64 #(
    parameter int WIDTH = 32
)(
    input  logic                   direction,      // 0 = asc, 1 = desc
    input  logic [64*WIDTH-1:0]    in_bus,
    output logic [64*WIDTH-1:0]    out_bus
);

    localparam int N = 64;

    logic [WIDTH-1:0] stage [0:N-1];
    logic [WIDTH-1:0] data  [0:N-1];

    // load
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++)
            assign data[gi] = in_bus[gi*WIDTH +: WIDTH];
    endgenerate

    integer k, j, i;

    always_comb begin
        // init
        for (i = 0; i < N; i++)
            stage[i] = data[i];

        // bitonic merge loop
        for (k = N; k > 1; k = k >> 1) begin
            for (j = k >> 1; j > 0; j = j >> 1) begin
                for (i = 0; i < N; i++) begin
                    int ix = i ^ j;

                    if (ix > i) begin
                        if (stage[i] > stage[ix]) begin
                            logic [WIDTH-1:0] t;
                            t = stage[i];
                            stage[i] = stage[ix];
                            stage[ix] = t;
                        end
                    end
                end
            end
        end
    end

    // apply direction: reverse if descending
    generate
        for (gi = 0; gi < N; gi++) begin
            assign out_bus[gi*WIDTH +: WIDTH] =
                (direction == 1'b0) ?
                    stage[gi] :
                    stage[N-1-gi];
        end
    endgenerate

endmodule
