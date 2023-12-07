
module wallace_tree (
    input [23:0] a,
    input [23:0] b,
    output [47:0] multi_product,
    input clk
);

  reg [31:0] a;
  reg [31:0] b;

  always @(a or b) begin
    a = {8'b0, a};
    b = {8'b0, b};
  end

endmodule
