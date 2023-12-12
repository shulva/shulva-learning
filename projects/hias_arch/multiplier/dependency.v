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

module cla_adder (
  input [3:0] a,
  input [3:0] b,
  input cin,
  output [3:0] sum,
  output carry
);

  wire p0,p1,p2,p3,g0,g1,g2,g3,c0,c1,c2,c3,c4;

  assign p0=(a[0]^b[0]);
  assign p1=(a[1]^b[1]);
  assign p2=(a[2]^b[2]);
  assign p3=(a[3]^b[3]);

  assign g0=(a[0]&b[0]);
  assign g1=(a[1]&b[1]);
  assign g2=(a[2]&b[2]);
  assign g3=(a[3]&b[3]);

  assign c0=cin;
  assign c1=g0|(p0&c0);
  assign c2=g1|(p1&g0)|(p1&p0&c0);
  assign c3=g2|(p2&g1)|(p2&p1&g0)|(p1&p1&p0&c0);
  assign c4=g3|(p3&g2)|(p3&p2&g1)|(p3&p2&p1&g0)|(p3&p2&p1&p0&c0);

  assign sum[0] = p0^c0;
  assign sum[1] = p1^c1;
  assign sum[2] = p2^c2;
  assign sum[3] = p3^c3;
  assign carry = c4;

endmodule

module cla_24_adder (
  input wire [23:0] a,
  input wire [23:0] b,
  output wire [23:0] c
);

  wire [4:0] connect_cla;

  cla_adder cla_1(a[3:0],b[3:0],1'b0,c[3:0],connect_cla[0]);
  cla_adder cla_2(a[7:4],b[7:4],connect_cla[0],c[7:4],connect_cla[1]);
  cla_adder cla_3(a[11:8],b[11:8],connect_cla[1],c[11:8],connect_cla[2]);
  cla_adder cla_4(a[15:12],b[15:12],connect_cla[2],c[15:12],connect_cla[3]);
  cla_adder cla_5(a[19:16],b[19:16],connect_cla[3],c[19:16],connect_cla[4]);
  cla_adder cla_6(a[23:20],b[23:20],connect_cla[4],c[23:20],);

endmodule
