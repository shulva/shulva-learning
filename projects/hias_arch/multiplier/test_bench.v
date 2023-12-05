module test_bench (
    input [31:0] input_a,
    input [31:0] input_b,
    output [31:0] output_z,
    input clk,
    input rst
);

  unpack un1 (
      .input_a(input_a),
      .input_b(input_b),
      .clk(clk),
      .rst(rst),
      .output_z(output_z)
  );

endmodule
