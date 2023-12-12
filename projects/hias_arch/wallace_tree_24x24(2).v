module wallace_tree_24x24(
  input clk    ,
  input rst    ,
  input [25:0] partial_product1     , // partial products
  input [25:0] partial_product2     ,
  input [25:0] partial_product3     ,
  input [25:0] partial_product4     ,
  input [25:0] partial_product5     ,
  input [25:0] partial_product6     ,
  input [25:0] partial_product7     ,
  input [25:0] partial_product8     ,
  input [25:0] partial_product9     ,
  input [25:0] partial_product10     ,
  input [25:0] partial_product11     ,
  input [25:0] partial_product12     ,
  input [25:0] partial_product13     ,

  output [23:0] final
);

  wire [25:0] pp1_wire ;
  wire [25:0] pp2_wire ;
  wire [25:0] pp3_wire ;
  wire [25:0] pp4_wire ;
  wire [25:0] pp5_wire ;
  wire [25:0] pp6_wire ;
  wire [25:0] pp7_wire ;
  wire [25:0] pp8_wire ;
  wire [25:0] pp9_wire ;
  wire [25:0] pp10_wire ;
  wire [25:0] pp11_wire ;
  wire [25:0] pp12_wire ;
  wire [25:0] pp13_wire ;

  parameter zero = 1'b0;

  assign pp1_wire = partial_product1;
  assign pp2_wire = partial_product2;
  assign pp3_wire = partial_product3;
  assign pp4_wire = partial_product4;
  assign pp5_wire = partial_product5;
  assign pp6_wire = partial_product6;
  assign pp7_wire = partial_product7;
  assign pp8_wire = partial_product8;
  assign pp9_wire = partial_product9;
  assign pp10_wire = partial_product10;
  assign pp11_wire = partial_product11;
  assign pp12_wire = partial_product12;
  assign pp13_wire = partial_product13;

  wire [29:0] c1_1_3;
  wire [29:0] s1_1_3;

  assign s1_1_3[0] = pp1_wire[0];
  assign s1_1_3[1] = pp1_wire[1];
  assign c1_1_3[0] = 1'b0;
  assign c1_1_3[1] = 1'b0;

  half_adder l1_1_3_2(pp1_wire[2],pp2_wire[0],s1_1_3[2],c1_1_3[2]);
  half_adder l1_1_3_3(pp1_wire[3],pp2_wire[1],s1_1_3[3],c1_1_3[3]);

  genvar k;
  generate
    for(k=4;k<26;k=k+1) begin: l1_1_3
      full_adder l1_1_3(pp1_wire[k],pp2_wire[k-2],pp3_wire[k-4],s1_1_3[k],c1_1_3[k]);
    end
  endgenerate

      full_adder l1_1_3_26(pp1_wire[25],pp2_wire[24],pp3_wire[22],s1_1_3[26],c1_1_3[26]);
      full_adder l1_1_3_27(pp1_wire[25],pp2_wire[25],pp3_wire[23],s1_1_3[27],c1_1_3[27]);
      full_adder l1_1_3_28(pp1_wire[25],pp2_wire[25],pp3_wire[24],s1_1_3[28],c1_1_3[28]);
      full_adder l1_1_3_29(pp1_wire[25],pp2_wire[25],pp3_wire[25],s1_1_3[29],c1_1_3[29]);

  wire  [29:0] c1_4_6;
  wire [29:0] s1_4_6;

  assign s1_4_6[0] = pp4_wire[0];
  assign s1_4_6[1] = pp4_wire[1];
  assign c1_4_6[0] = 1'b0;
  assign c1_4_6[1] = 1'b0;

  half_adder l1_4_6_2(pp4_wire[2],pp5_wire[0],s1_4_6[2],c1_4_6[2]);
  half_adder l1_4_6_3(pp4_wire[3],pp5_wire[1],s1_4_6[3],c1_4_6[3]);

  generate
    for(k=4;k<26;k=k+1) begin: l1_4_6
      full_adder l1_4_6(pp4_wire[k],pp5_wire[k-2],pp6_wire[k-4],s1_4_6[k],c1_4_6[k]);
    end
  endgenerate

      full_adder l1_4_6_26(pp4_wire[25],pp5_wire[24],pp6_wire[22],s1_4_6[26],c1_4_6[26]);
      full_adder l1_4_6_27(pp4_wire[25],pp5_wire[25],pp6_wire[23],s1_4_6[27],c1_4_6[27]);
      full_adder l1_4_6_28(pp4_wire[25],pp5_wire[25],pp6_wire[24],s1_4_6[28],c1_4_6[28]);
      full_adder l1_4_6_29(pp4_wire[25],pp5_wire[25],pp6_wire[25],s1_4_6[29],c1_4_6[29]);

  wire  [29:0] c1_7_9;
  wire [29:0] s1_7_9;

  assign s1_7_9[0] = pp7_wire[0];
  assign s1_7_9[1] = pp7_wire[1];
  assign c1_7_9[0] = 1'b0;
  assign c1_7_9[1] = 1'b0;

  half_adder l1_7_9_2(pp7_wire[2],pp8_wire[0],s1_7_9[2],c1_7_9[2]);
  half_adder l1_7_9_3(pp7_wire[3],pp8_wire[1],s1_7_9[3],c1_7_9[3]);

  generate
    for(k=4;k<26;k=k+1) begin: l1_7_9
      full_adder l1_7_9(pp7_wire[k],pp8_wire[k-2],pp9_wire[k-4],s1_7_9[k],c1_7_9[k]);
    end
  endgenerate

      full_adder l1_7_9_26(pp7_wire[25],pp8_wire[24],pp9_wire[22],s1_7_9[26],c1_7_9[26]);
      full_adder l1_7_9_27(pp7_wire[25],pp8_wire[25],pp9_wire[23],s1_7_9[27],c1_7_9[27]);
      full_adder l1_7_9_28(pp7_wire[25],pp8_wire[25],pp9_wire[24],s1_7_9[28],c1_7_9[28]);
      full_adder l1_7_9_29(pp7_wire[25],pp8_wire[25],pp9_wire[25],s1_7_9[29],c1_7_9[29]);

  wire  [29:0] c1_10_12;
  wire [29:0] s1_10_12;

  assign s1_10_12[0] = pp10_wire[0];
  assign s1_10_12[1] = pp10_wire[1];
  assign c1_10_12[0] = 1'b0;
  assign c1_10_12[1] = 1'b0;

  half_adder l1_10_12_2(pp10_wire[2],pp11_wire[0],s1_10_12[2],c1_10_12[2]);
  half_adder l1_10_12_3(pp10_wire[3],pp11_wire[1],s1_10_12[3],c1_10_12[3]);

  generate
    for(k=4;k<26;k=k+1) begin: l1_10_12
      full_adder l1_10_12(pp10_wire[k],pp11_wire[k-2],pp12_wire[k-4],s1_10_12[k],c1_10_12[k]);
    end
  endgenerate

      full_adder l1_10_12_26(pp10_wire[25],pp11_wire[24],pp12_wire[22],s1_10_12[26],c1_10_12[26]);
      full_adder l1_10_12_27(pp10_wire[25],pp11_wire[25],pp12_wire[23],s1_10_12[27],c1_10_12[27]);
      full_adder l1_10_12_28(pp10_wire[25],pp11_wire[25],pp12_wire[24],s1_10_12[28],c1_10_12[28]);
      full_adder l1_10_12_29(pp10_wire[25],pp11_wire[25],pp12_wire[25],s1_10_12[29],c1_10_12[29]);

  //lever1------------------------------------------------------------
  //
  //
  wire [35:0] c2_1_3;
  wire [35:0] s2_1_3;

  assign s2_1_3[0]   = s1_1_3[0];
  assign c2_1_3[0]   = 1'b0;

  half_adder l2_1_3_1(s1_1_3[1],c1_1_3[0],s2_1_3[1],c2_1_3[1]);
  half_adder l2_1_3_2(s1_1_3[2],c1_1_3[1],s2_1_3[2],c2_1_3[2]);
  half_adder l2_1_3_3(s1_1_3[3],c1_1_3[2],s2_1_3[3],c2_1_3[3]);
  half_adder l2_1_3_4(s1_1_3[4],c1_1_3[3],s2_1_3[4],c2_1_3[4]);
  half_adder l2_1_3_5(s1_1_3[5],c1_1_3[4],s2_1_3[5],c2_1_3[5]);

  generate
    for(k=6;k<30;k=k+1) begin: l2_1_3
      full_adder l2_1_3(s1_1_3[k],c1_1_3[k-1],s1_4_6[k-6],s2_1_3[k],c2_1_3[k]);
    end
  endgenerate

      full_adder l2_1_3_30(s1_1_3[29],c1_1_3[29],s1_4_6[24],s2_1_3[30],c2_1_3[30]);
      full_adder l2_1_3_31(s1_1_3[29],c1_1_3[29],s1_4_6[25],s2_1_3[31],c2_1_3[31]);
      full_adder l2_1_3_32(s1_1_3[29],c1_1_3[29],s1_4_6[26],s2_1_3[32],c2_1_3[32]);
      full_adder l2_1_3_33(s1_1_3[29],c1_1_3[29],s1_4_6[27],s2_1_3[33],c2_1_3[33]);
      full_adder l2_1_3_34(s1_1_3[29],c1_1_3[29],s1_4_6[28],s2_1_3[34],c2_1_3[34]);
      full_adder l2_1_3_35(s1_1_3[29],c1_1_3[29],s1_4_6[29],s2_1_3[35],c2_1_3[35]);

  wire [35:0] c2_4_6;
  wire [35:0] s2_4_6;


  assign s2_4_6[0]   = c1_4_6[0];
  assign s2_4_6[1]   = c1_4_6[1];
  assign s2_4_6[2]   = c1_4_6[2];
  assign s2_4_6[3]   = c1_4_6[3];
  assign s2_4_6[4]   = c1_4_6[4];

  assign c2_4_6[0]   = 1'b0;
  assign c2_4_6[1]   = 1'b0;
  assign c2_4_6[2]   = 1'b0;
  assign c2_4_6[3]   = 1'b0;
  assign c2_4_6[4]   = 1'b0;

  half_adder l2_4_6_5(c1_4_6[5],s1_7_9[0],s2_4_6[5],c2_4_6[5]);

  generate
    for(k=6;k<30;k=k+1) begin: l2_4_6
      full_adder l2_4_6(c1_4_6[k],s1_7_9[k-5],c1_7_9[k-6],s2_4_6[k],c2_4_6[k]);
    end
  endgenerate

      full_adder l2_4_6_30(c1_4_6[29],c1_7_9[25],s1_7_9[24],s2_4_6[30],c2_4_6[30]);
      full_adder l2_4_6_31(c1_4_6[29],c1_7_9[26],s1_7_9[25],s2_4_6[31],c2_4_6[31]);
      full_adder l2_4_6_32(c1_4_6[29],c1_7_9[27],s1_7_9[26],s2_4_6[32],c2_4_6[32]);
      full_adder l2_4_6_33(c1_4_6[29],c1_7_9[28],s1_7_9[27],s2_4_6[33],c2_4_6[33]);
      full_adder l2_4_6_34(c1_4_6[29],c1_7_9[29],s1_7_9[28],s2_4_6[34],c2_4_6[34]);
      full_adder l2_4_6_35(c1_4_6[29],c1_7_9[29],s1_7_9[29],s2_4_6[35],c2_4_6[35]);

  wire [29:0] c2_7_9;
  wire [29:0] s2_7_9;

  assign s2_7_9[0]   = s1_10_12[0];
  assign c2_7_9[0]   = 1'b0;

  half_adder l2_7_9_1(s1_10_12[1],c1_10_12[0],s2_7_9[1],c2_7_9[1]);
  half_adder l2_7_9_2(s1_10_12[2],c1_10_12[1],s2_7_9[2],c2_7_9[2]);
  half_adder l2_7_9_3(s1_10_12[3],c1_10_12[2],s2_7_9[3],c2_7_9[3]);
  half_adder l2_7_9_4(s1_10_12[4],c1_10_12[3],s2_7_9[4],c2_7_9[4]);
  half_adder l2_7_9_5(s1_10_12[5],c1_10_12[4],s2_7_9[5],c2_7_9[5]);

  generate
    for(k=6;k<30;k=k+1) begin: l2_7_9
      full_adder l2_7_9(s1_10_12[k],c1_10_12[k-1],pp13_wire[k-6],s2_7_9[k],c2_7_9[k]);
    end
  endgenerate
//lever2------------------------------------------------------------
//
  
  wire  [42:0] s3_1_3;
  wire [42:0] c3_1_3;

  assign s3_1_3[0] = s2_1_3[0];
  assign c3_1_3[0] = 1'b0;

  half_adder l3_1_3_1(s2_1_3[1],c2_1_3[0],s3_1_3[1],c3_1_3[1]);
  half_adder l3_1_3_2(s2_1_3[2],c2_1_3[1],s3_1_3[2],c3_1_3[2]);
  half_adder l3_1_3_3(s2_1_3[3],c2_1_3[2],s3_1_3[3],c3_1_3[3]);
  half_adder l3_1_3_4(s2_1_3[4],c2_1_3[3],s3_1_3[4],c3_1_3[4]);
  half_adder l3_1_3_5(s2_1_3[5],c2_1_3[4],s3_1_3[5],c3_1_3[5]);
  half_adder l3_1_3_6(s2_1_3[6],c2_1_3[5],s3_1_3[6],c3_1_3[6]);
  half_adder l3_1_3_7(s2_1_3[7],c2_1_3[6],s3_1_3[7],c3_1_3[7]);
  half_adder l3_1_3_8(s2_1_3[8],c2_1_3[7],s3_1_3[8],c3_1_3[8]);
  half_adder l3_1_3_9(s2_1_3[9],c2_1_3[8],s3_1_3[9],c3_1_3[9]);
  half_adder l3_1_3_10(s2_1_3[10],c2_1_3[9],s3_1_3[10],c3_1_3[10]);
  half_adder l3_1_3_11(s2_1_3[11],c2_1_3[10],s3_1_3[11],c3_1_3[11]);

  generate
    for(k=12;k<36;k=k+1) begin: l3_1_3
      full_adder l3_1_3(s2_1_3[k],c2_1_3[k-1],s2_4_6[k-12],s3_1_3[k],c3_1_3[k]);
    end
  endgenerate

      full_adder l3_1_3_36(s2_1_3[35],c2_1_3[35],s2_4_6[24],s3_1_3[36],c3_1_3[36]);
      full_adder l3_1_3_37(s2_1_3[35],c2_1_3[35],s2_4_6[25],s3_1_3[37],c3_1_3[37]);
      full_adder l3_1_3_38(s2_1_3[35],c2_1_3[35],s2_4_6[26],s3_1_3[38],c3_1_3[38]);
      full_adder l3_1_3_39(s2_1_3[35],c2_1_3[35],s2_4_6[27],s3_1_3[39],c3_1_3[39]);
      full_adder l3_1_3_40(s2_1_3[35],c2_1_3[35],s2_4_6[28],s3_1_3[40],c3_1_3[40]);
      full_adder l3_1_3_41(s2_1_3[35],c2_1_3[35],s2_4_6[29],s3_1_3[41],c3_1_3[41]);
      full_adder l3_1_3_42(s2_1_3[35],c2_1_3[35],s2_4_6[30],s3_1_3[42],c3_1_3[42]);

  wire [34:0] s3_4_6;
  wire [34:0] c3_4_6;

  assign s3_4_6[0]   = c2_4_6[0];
  assign s3_4_6[1]   = c2_4_6[1];
  assign s3_4_6[2]   = c2_4_6[2];
  assign s3_4_6[3]   = c2_4_6[3];
  assign s3_4_6[4]   = c2_4_6[4];
  assign s3_4_6[5]   = c2_4_6[5];

  assign c3_4_6[0]   = 1'b0;
  assign c3_4_6[1]   = 1'b0;
  assign c3_4_6[2]   = 1'b0;
  assign c3_4_6[3]   = 1'b0;
  assign c3_4_6[4]   = 1'b0;
  assign c3_4_6[5]   = 1'b0;

  half_adder l2_4_6_6(c2_4_6[6],s2_7_9[0],s3_4_6[6],c3_4_6[6]);

  generate
    for(k=7;k<31;k=k+1) begin: l3_4_6
      full_adder l3_4_6(c2_4_6[k],s2_7_9[k-6],c2_7_9[k-7],s3_4_6[k],c3_4_6[k]);
    end
  endgenerate

      full_adder l3_4_6_31(c2_4_6[30],s2_7_9[25],c2_7_9[24],s3_4_6[31],c3_4_6[31]);
      full_adder l3_4_6_32(c2_4_6[30],s2_7_9[26],c2_7_9[25],s3_4_6[32],c3_4_6[32]);
      full_adder l3_4_6_33(c2_4_6[30],s2_7_9[27],c2_7_9[26],s3_4_6[33],c3_4_6[33]);
      full_adder l3_4_6_34(c2_4_6[30],s2_7_9[28],c2_7_9[27],s3_4_6[34],c3_4_6[34]);

//lever3------------------------------------------------------------

  wire [47:0] s4_1_3 ;
  wire [47:0] c4_1_3 ;

  assign s4_1_3[0] = s3_1_3[0];
  assign c4_1_3[0] = 1'b0;

  generate
    for(k=1;k<19;k=k+1) begin: l4_1_3_half
      half_adder l4_1_3_half(s3_1_3[k],c3_1_3[k-1],s4_1_3[k],c4_1_3[k]);
    end
  endgenerate

  generate
    for(k=19;k<43;k=k+1) begin: l4_1_3
      full_adder l4_1_3(s3_1_3[k],c3_1_3[k-1],s3_4_6[k-19],s4_1_3[k],c4_1_3[k]);
    end
  endgenerate

    full_adder l4_1_3_43(s3_1_3[42],c3_1_3[42],s3_4_6[24],s4_1_3[43],c4_1_3[43]);
    full_adder l4_1_3_44(s3_1_3[42],c3_1_3[42],s3_4_6[25],s4_1_3[44],c4_1_3[44]);
    full_adder l4_1_3_45(s3_1_3[42],c3_1_3[42],s3_4_6[26],s4_1_3[45],c4_1_3[45]);
    full_adder l4_1_3_46(s3_1_3[42],c3_1_3[42],s3_4_6[27],s4_1_3[46],c4_1_3[46]);
    full_adder l4_1_3_47(s3_1_3[42],c3_1_3[42],s3_4_6[28],s4_1_3[47],c4_1_3[47]);

  //lever4------------------------------------------------------------

  wire [47:0] s5_1_3 ;
  wire [47:0] c5_1_3 ;

  assign s5_1_3[0] = s4_1_3[0];
  assign c5_1_3[0] = 1'b0;

  generate
    for(k=1;k<20;k=k+1) begin: l5_1_3_half
      half_adder l5_1_3_half(s4_1_3[k],c4_1_3[k-1],s5_1_3[k],c5_1_3[k]);
    end
  endgenerate

  generate
    for(k=20;k<48;k=k+1) begin: l5_1_3
      full_adder l5_1_3(s4_1_3[k],c4_1_3[k-1],c3_4_6[k-20],s5_1_3[k],c5_1_3[k]);
    end
  endgenerate

  //lever5------------------------------------------------------------
  
  cla_24_adder s6(s5_1_3[23:0],{c5_1_3[22:0],1'b0},final[23:0]);

endmodule
