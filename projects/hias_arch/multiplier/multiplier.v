module multiplier(
  input_a,
  input_b,
  output_z
  clk,
  rst
);

  input clk;
  input rst;
  assign output_z = input_a & input_b;

endmodule
