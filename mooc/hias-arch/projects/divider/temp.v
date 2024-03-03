
  reg [25:0] reg_x;
  reg [23:0] reg_a;
  reg [23:0] reg_b;
  reg [2:0] count;
  reg start_test = 1'b1;

  wire [49:0] axi = reg_x*reg_a;
  wire [49:0] bxi = reg_x*reg_b;

  wire [25:0] b_2m = ~bxi[48:23] +1'b1;
  wire [51:0] x52 = reg_x*b_2m;

  wire [23:0] frac;
  assign frac = axi[48:25] + |axi[24:0]; // 24位，没有round的空间了，想要可以在final之前再加

  always @ (posedge clk) begin
    if (start_test) begin
      reg_a <= frac_a;
      reg_b <= frac_b;
      reg_x <= {2'b1,x0,16'b0};
      count <= 0;
      start_test<= 1'b0;
    end
    else begin
      reg_x <= x52[50:25];
      count <= count + 3'b1;
    end
  end
