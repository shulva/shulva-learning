`timescale 1ns / 100ps
module test_bench_tb;
  reg clk;
  reg rst;
  reg [12:0] a;
  reg [23:0] b;
  reg [23:0] c;

  reg [31:0] d;
  reg [31:0] f;
  wire [31:0] e;
  wire g;


  wire [25:0] pp [12:0];
  wire [23:0] final;
  wire out;
  wire carry;
  wire [9:0] cout;

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
    d   <= 32'h40ae0000;
    f   <= 32'hbec00000;

    while (1) begin
      #5 clk <= ~clk;
    end
  end
 
  divider di(.input_a(d),.input_b(f),.start(1'b1),.output_z(e),.clk(clk),.rst(rst));

endmodule
