`timescale 1ns / 100ps
module test_bench_tb;
  reg clk;
  reg rst;
  reg [23:0] a;
  reg [23:0] b;
  reg [23:0] c;
  wire [7:0] g;

  wire [25:0] pp [12:0];
  wire [23:0] final;

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
    a   <= 136;
    b   <= 136;

    while (1) begin
      #5 clk <= ~clk;
    end
  end

  booth_24x24 t1 (1'b0,1'b0,a,b,pp[0],pp[1],pp[2],pp[3],pp[4],pp[5],pp[6],pp[7],pp[8],pp[9],pp[10],pp[11],pp[12]);
  wallace_tree_24x24 t2(clk,rst,pp[0],pp[1],pp[2],pp[3],pp[4],pp[5],pp[6],pp[7],pp[8],pp[9],pp[10],pp[11],pp[12],final[23:0]);
endmodule
