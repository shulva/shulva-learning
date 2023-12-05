`default_nettype none
;
module unpack (
    input [31:0] input_a,
    input [31:0] input_b,
    output [31:0] output_z,
    input clk,
    input rst
);
  /*
    sign  | exponent | fraction
    1bit  |  8bits   |  23bits
    */

  wire sign_a;
  wire sign_b;

  wire [7:0] exponent_a;
  wire [7:0] exponent_b;
  wire [7:0] exponent_sum;

  wire [22:0] fraction_a;
  wire [22:0] fraction_b;

  assign sign_a = input_a[31];
  assign sign_b = input_b[31];

  assign exponent_a = input_a[30:23];
  assign exponent_b = input_b[30:23];

  assign fraction_a = input_a[22:0];
  assign fraction_b = input_b[22:0];

  assign exponent_sum = exponent_a + exponent_b - 127;  // sub the bias:127 in ieee

endmodule


