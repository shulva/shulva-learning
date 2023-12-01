module test_bench(clk, rst,a,b,c);
  input  clk;
  input  rst;

  multiplier m1(.input_a(a),.input_b(b),.clk(clk),.rst(rst),output_z(c));

endmodule
