`timescale 1ns/1ps

module tb_bitonic16;

  localparam int N = 16;
  localparam int WIDTH = 32;

  logic [N*WIDTH-1:0] in_bus;
  logic [N*WIDTH-1:0] out_bus;

  // DUT: Direct instantiation (no top module needed)
  bitonic_sort16 #(
    .N(N),
    .WIDTH(WIDTH)
  ) dut (
    .in_bus(in_bus),
    .out_bus(out_bus)
  );

  // Helper to print 16 packed values
  task automatic print16(input logic [N*WIDTH-1:0] bus);
    for (int i = 0; i < N; i++)
      $write("%0d ", bus[i*WIDTH +: WIDTH]);
    $display("");
  endtask

  initial begin
    $display("======== Bitonic Sort16 Test (Option-B) ========");

    // Example scrambled vector
    in_bus = {
      32'd6,  32'd14, 32'd4,  32'd9,
      32'd17, 32'd2,  32'd3,  32'd15,
      32'd8,  32'd25, 32'd10, 32'd1,
      32'd7,  32'd19, 32'd5,  32'd12
    };

    $display("Input:");
    print16(in_bus);

    #5; // allow combinational propagation

    $display("Sorted Output:");
    print16(out_bus);

    $display("================================================");
    $finish;
  end

endmodule
