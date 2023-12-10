`timescale 1ns / 100ps

module test_bench_tb;
  reg clk;
  reg rst;
  reg [23:0] a;
  reg [23:0] b;
  reg [23:0] c;
  wire [47:8] d;
  wire [47:8] f;
  wire [7:0] g;

  initial begin
    rst <= 1'b1;
    #10 rst <= 1'b0;
  end


  initial begin
    #1000 $finish;
  end

  initial begin
    $dumpfile("wave.vcd");  //生成的vcd文件名称
    $dumpvars(0, test_bench_tb);  //tb模块名称
  end

  initial begin
    clk <= 1'b0;
    a   <= 1'b1;
    b   <= 3'b011;
    while (1) begin
      #5 clk <= ~clk;
      #5 a <= ~a;
      #5 b <= ~b;
    end
  end

  wallace_tree_24x24 t1 (a,b,d,f,g);
endmodule
