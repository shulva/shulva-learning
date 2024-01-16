module divider(
    input [31:0] input_a,
    input [31:0] input_b,
    output [31:0] output_z,
    input clk,
    input rst
);

  wire a_expo_is_ff= &input_a[30:23]; //exp=ff
  wire b_expo_is_ff= &input_b[30:23];

  wire a_expo_is_00= ~|input_a[30:23]; //exp=00
  wire b_expo_is_00= ~|input_b[30:23];

  wire a_frac_is_00 = ~|input_a[22:0];
  wire b_frac_is_00 = ~|input_b[22:0];

  wire a_is_inf=a_expo_is_ff&a_frac_is_00;
  wire b_is_inf=b_expo_is_ff&b_frac_is_00;

  wire a_is_nan=a_expo_is_ff& ~a_frac_is_00;
  wire b_is_nan=b_expo_is_ff& ~b_frac_is_00;

  wire a_is_0 =a_expo_is_00&a_frac_is_00;
  wire b_is_0 =b_expo_is_00&b_frac_is_00;

  wire s_is_inf=a_is_inf|b_is_inf;
  wire s_is_nan=a_is_nan|(a_is_inf&b_is_0)|b_is_nan|(b_is_inf&a_is_0);

  wire [8:0] exp = {1'b0,input_a[30:23]}-{1'b0,input_b[30:23]}-128+1;
  wire sign = input_a[31]^input_b[31];

  wire [23:0] frac_a = {~a_expo_is_00,input_a[22:0]};
  wire [23:0] frac_b = {~b_expo_is_00,input_b[22:0]};

  reg [23:0] x;
  reg [23:0] y;
  reg [23:0] r;
  reg [23:0] x_loop;
  reg [2:0] count = 3'b0;
  reg ready_y = 1'b0;
  reg start = 1'b1;


  wire [25:0] partial_product [12:0];
  wire [47:0] partial_product_extend [12:0];
  wire [47:0] z_sum;
  wire [47:0] z_carry;
  wire [9:0] z_out;
  wire [47:0] temp_sum;
  wire [23:0] sum_high;
  wire temp_carry;

  assign sum_high  = temp_sum[46:23];

  booth_24x24 booth(1'b0,1'b0,x_loop,r,
    partial_product[0],partial_product[1],partial_product[2],partial_product[3],partial_product[4],
    partial_product[5],partial_product[6],partial_product[7],partial_product[8],partial_product[9],
    partial_product[10],partial_product[11],partial_product[12]);

    assign partial_product_extend[0] = {{22{partial_product[0][25]}},partial_product[0]};
    assign partial_product_extend[1] = {{22{partial_product[1][25]}},partial_product[1]}<<2;
    assign partial_product_extend[2] = {{22{partial_product[2][25]}},partial_product[2]}<<4;
    assign partial_product_extend[3] = {{22{partial_product[3][25]}},partial_product[3]}<<6;
    assign partial_product_extend[4] = {{22{partial_product[4][25]}},partial_product[4]}<<8;
    assign partial_product_extend[5] = {{22{partial_product[5][25]}},partial_product[5]}<<10;
    assign partial_product_extend[6] = {{22{partial_product[6][25]}},partial_product[6]}<<12;
    assign partial_product_extend[7] = {{22{partial_product[7][25]}},partial_product[7]}<<14;
    assign partial_product_extend[8] = {{22{partial_product[8][25]}},partial_product[8]}<<16;
    assign partial_product_extend[9] = {{22{partial_product[9][25]}},partial_product[9]}<<18;
    assign partial_product_extend[10] = {{22{partial_product[10][25]}},partial_product[10]}<<20;
    assign partial_product_extend[11] = {{22{partial_product[11][25]}},partial_product[11]}<<22;
    assign partial_product_extend[12] = {{22{partial_product[12][25]}},partial_product[12]}<<24;

  wallace_tree_24 wallace(clk,rst,partial_product_extend[0],partial_product_extend[1],partial_product_extend[2],partial_product_extend[3],
    partial_product_extend[4],partial_product_extend[5],partial_product_extend[6],partial_product_extend[7],partial_product_extend[8],
    partial_product_extend[9],partial_product_extend[10],partial_product_extend[11],partial_product_extend[12],
    10'b0000000000,z_carry,z_sum,z_out);

  cla_48_adder cla(z_sum,z_carry<<1,1'b0,temp_sum,temp_carry);

  always @(posedge clk) begin

    if(start) begin
      x <= frac_a>>1;
      y <= frac_b>>1;

      x_loop <= frac_a>>1;
      r <= ~(frac_b>>1)+1'b1;
      ready_y <= 1'b1;
      start <= 1'b0;
    end

    if(start == 1'b0) begin
      if (ready_y == 1'b0 ) begin
        x_loop <= x;
        y <= sum_high;
        r <= ~sum_high+1'b1;
        ready_y <= 1'b1;
      end
      else if (ready_y == 1'b1) begin
        x_loop <= y;
        x <= sum_high;
        ready_y <= 1'b0;
      end
    end
    count <= count + 1'b1 ;

  end

endmodule
