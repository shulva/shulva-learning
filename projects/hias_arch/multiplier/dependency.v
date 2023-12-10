module half_adder (
    input  a,
    input  b,
    output s0,
    output c0
);
  assign s0 = a ^ b;
  assign c0 = a & b;
endmodule

module full_adder (
    input  a,
    input  b,
    input  cin,
    output s0,
    output c0
);
  assign s0 = a ^ b ^ cin;
  assign c0 = (a & b) | (b & cin) | (a & cin);
endmodule
