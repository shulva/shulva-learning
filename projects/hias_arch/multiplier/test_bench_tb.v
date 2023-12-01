module test_bench_tb;
  reg  clk;
  reg  rst;
  reg  a;
  reg  b;
  reg  c;
  
  initial
  begin
    rst <= 1'b1;
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    #1000000 $finish;
  end

  
  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end

  test_bench t1(
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .c(c));
endmodule
