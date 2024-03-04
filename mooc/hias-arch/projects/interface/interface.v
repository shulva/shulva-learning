module commonAlu (
  input wire clk,
  input wire rst,
  input wire data_ready,//要进行运算的数据是否准备就绪的标记
  input wire [31:0] x, //操作数A
  input wire [31:0] y, //操作数B
  input wire [3:0] ctrl, //功能函数，选择执行具体的哪一项功能
  input wire [4:0] save_no_in, //保留站号
  input wire [4:0] rd_rob_in, //结果影响到的ROB
  output reg done,  //运算器操作的完成信号
  output reg [4:0] save_no_out,
  output reg [4:0] rd_rob_out,
  output reg signed [31:0] result//运算器的执行效果
);


  wire [31:0] result_div,result_mul;
  wire [31:0] input_a_div,input_b_div,input_a_mul,input_b_mul;

  wire busy_div;
  wire exception_mul;

  divider div(input_a,input_b,data_ready,clk,rst,data_ready,result_div,busy_div,done);
  multiplier mul(clk,data_ready,rst,input_a,input_b,result_mul,exception_mul);

  always @(*) begin
    save_no_out <= save_no_in;
    rd_rob_out <= save_no_out;
  end

  always @(*) begin
    if (ctrl == 4'b0010)//乘法
      input_a_mul <= x;
      input_b_mul <= y;
      result <=result_mul;
    end
    else if (ctrl == 4'b0011) //除法
      input_a_div <= x;
      input_b_div <= y;
      result <=result_div;
    end
  end

endmodule
