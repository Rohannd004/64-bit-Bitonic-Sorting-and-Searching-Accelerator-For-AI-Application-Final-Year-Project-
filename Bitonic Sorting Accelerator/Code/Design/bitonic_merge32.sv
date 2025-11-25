`timescale 1ns/1ps
//==============================================================
// bitonic_merge32.sv
// Merges 32 elements using canonical bitonic merge network
// Input must be a bitonic sequence:
//   Left 16 ascending
//   Right 16 descending (reverse of a sorted block)
//==============================================================

module bitonic_merge32 #(
    parameter int WIDTH = 32
)(
    input  logic [32*WIDTH-1:0] in_bus,
    output logic [32*WIDTH-1:0] out_bus
);

    localparam int N = 32;

    logic [WIDTH-1:0] stage [0:N-1];
    logic [WIDTH-1:0] data  [0:N-1];

    // load input
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++)
            assign data[gi] = in_bus[gi*WIDTH +: WIDTH];
    endgenerate

    integer k, j, i;
    logic dir;

    always_comb begin
        // stage = initial data
        for (i = 0; i < N; i++)
            stage[i] = data[i];

        // bitonic merge loops
        for (k = N; k > 1; k = k >> 1) begin
            for (j = k >> 1; j > 0; j = j >> 1) begin
                for (i = 0; i < N; i++) begin
                    int ix = i ^ j;

                    if (ix > i) begin
                        // always ascending merge
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

    // pack output
    generate
        for (gi = 0; gi < N; gi++)
            assign out_bus[gi*WIDTH +: WIDTH] = stage[gi];
    endgenerate

endmodule
