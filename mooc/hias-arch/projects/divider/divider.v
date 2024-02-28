module divider(
    input [31:0] input_a,
    input [31:0] input_b,
    input start,
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

  wire [9:0] exp = {2'b0,input_a[30:23]}-{2'b0,input_b[30:23]}+128-1;

  wire [23:0] temp_frac_a = a_expo_is_00?{input_a[22:0],1'b0}:{1'b1,input_a[22:0]};
  wire [23:0] temp_frac_b = b_expo_is_00?{input_b[22:0],1'b0}:{1'b1,input_b[22:0]};

  wire [23:0] frac_a,frac_b;
  wire [4:0] move_exp_a,move_exp_b;

  shift shift_a(temp_frac_a,frac_a,move_exp_a);
  shift shift_b(temp_frac_b,frac_b,move_exp_b);

  wire sign = input_a[31]^input_b[31];

  wire [9:0] new_exp = exp - move_exp_a + move_exp_b;


// -------------------------
  reg [25:0] reg_x;
  reg [23:0] reg_a;
  reg [23:0] reg_b;
  reg [2:0] count;
  reg start_test = 1'b1;

  wire [49:0] axi = reg_x*reg_a;
  wire [49:0] bxi = reg_x*reg_b;

  wire [25:0] b_2m = ~bxi[48:23] +1'b1;
  wire [51:0] x52 = reg_x*b_2m;
  
  wire  [7:0] x0 = rom(frac_b[22:19]);
  

  wire [23:0] frac;
  assign frac = axi[48:25] + |axi[24:0];

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

  wire [23:0] frac_end = frac[23]?frac:{frac[22:0],1'b0}; // a-f24/b-f24 --> 1.xxxx or 0.1xxxxx
  wire [9:0] new_exp_end = frac[23]?new_exp:new_exp-1;

  assign output_z[31] = sign;
  assign output_z[30:23] = new_exp_end[7:0];
  assign output_z[22:0] = frac_end[22:0];

// rom -------------------------
  function [7:0] rom;
    input [3:0] b;
    case (b)
      4'h0: rom = 8'hff; 4'h1: rom = 8'hdf;
      4'h2: rom = 8'hc3; 4'h3: rom = 8'haa;
      4'h4: rom = 8'h93; 4'h5: rom = 8'h7f;
      4'h6: rom = 8'h6d; 4'h7: rom = 8'h5c;
      4'h8: rom = 8'h4d; 4'h9: rom = 8'h3f;
      4'ha: rom = 8'h33; 4'hb: rom = 8'h27;
      4'hc: rom = 8'h1c; 4'hd: rom = 8'h12;
      4'he: rom = 8'h08; 4'hf: rom = 8'h00;
    endcase
  endfunction

endmodule
