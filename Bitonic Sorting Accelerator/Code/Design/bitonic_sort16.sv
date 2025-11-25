`timescale 1ns/1ps
//==============================================================
// bitonic_sort16.sv (Canonical Batcher Bitonic Sorter, Ascending)
// Supports 16 × WIDTH-bit elements
//==============================================================

module bitonic_sort16 #(
    parameter int N = 16,
    parameter int WIDTH = 32
)(
    input  logic [N*WIDTH-1:0] in_bus,
    output logic [N*WIDTH-1:0] out_bus
);

    // Expand flattened input to array
    logic [WIDTH-1:0] data [0:N-1];
    logic [WIDTH-1:0] stage [0:N-1];

    // load input
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin
            assign data[gi] = in_bus[gi*WIDTH +: WIDTH];
        end
    endgenerate

    //==========================================================
    // Batcher Bitonic Sorting Network (Compact K/J loops)
    //==========================================================
    integer k, j, i;
    logic dir;

    always_comb begin
        // initial stage = input
        for (i = 0; i < N; i++)
            stage[i] = data[i];

        // bitonic sort loops
        for (k = 2; k <= N; k = k << 1) begin
            for (j = k >> 1; j > 0; j = j >> 1) begin
                for (i = 0; i < N; i++) begin
                    int ix = i ^ j;      // partner index

                    if (ix > i) begin
                        // upward or downward depending on block
                        dir = ((i & k) == 0);

                        if (dir) begin
                            if (stage[i] > stage[ix]) begin
                                logic [WIDTH-1:0] t;
                                t = stage[i];
                                stage[i] = stage[ix];
                                stage[ix] = t;
                            end
                        end
                        else begin
                            if (stage[i] < stage[ix]) begin
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
    end

    // pack output
    generate
        for (gi = 0; gi < N; gi++) begin
            assign out_bus[gi*WIDTH +: WIDTH] = stage[gi];
        end
    endgenerate

endmodule
