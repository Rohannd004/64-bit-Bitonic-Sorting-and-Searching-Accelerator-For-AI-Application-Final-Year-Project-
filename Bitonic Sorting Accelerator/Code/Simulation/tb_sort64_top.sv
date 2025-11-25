`timescale 1ns/1ps

module tb_sort64_top_direction;

  localparam int WIDTH = 32;

  logic                    direction;
  logic [64*WIDTH-1:0]     in_bus;
  logic [64*WIDTH-1:0]     out_bus;

  // DUT
  sort64_top #(.WIDTH(WIDTH)) dut (
    .direction(direction),
    .in_bus(in_bus),
    .out_bus(out_bus)
  );

  // Print 64 elements in one line
  task automatic print64(input logic [64*WIDTH-1:0] bus);
    for (int i = 0; i < 64; i++)
      $write("%0d ", bus[i*WIDTH +: WIDTH]);
    $display("");
  endtask

  // Golden sort
  task automatic golden_sort(input int inp[0:63], output int outp[0:63]);
    outp = inp;
    for (int a = 0; a < 64; a++)
      for (int b = a + 1; b < 64; b++)
        if (outp[a] > outp[b]) begin
          int t = outp[a];
          outp[a] = outp[b];
          outp[b] = t;
        end
  endtask

  initial begin
    int seq[0:63];
    int golden[0:63];

    $display("\n======== 64-ELEMENT ASC/DESC TEST ========\n");

    // Generate test data
    for (int i = 0; i < 64; i++) begin
      seq[i] = (i * 13 + 5) % 251 + 1;
      in_bus[i*WIDTH +: WIDTH] = seq[i];
    end

    //==========================================================
    // 1) ASCENDING TEST
    //==========================================================
    direction = 1'b0;   // ascending
    #20;

    $display("\nASCENDING (direction = 0):");
    print64(out_bus);

    // Golden ascending
    golden_sort(seq, golden);

    $display("Golden Ascending:");
    for (int i = 0; i < 64; i++) $write("%0d ", golden[i]);
    $display("");

    //==========================================================
    // 2) DESCENDING TEST
    //==========================================================
    direction = 1'b1;   // descending
    #20;

    $display("\nDESCENDING (direction = 1):");
    print64(out_bus);

    $display("Golden Descending:");
    for (int i = 0; i < 64; i++) $write("%0d ", golden[63 - i]);
    $display("");

    $display("\n============================================\n");

    $finish;
  end

endmodule
