module paritycheck (input8, output8, output4);
input [7:0] input8;
output [8:0] output8;
wire [3:0] input4;
output [4:0] output4;
assign input4 = {input8[6], input8[4], input8[2], input8[0]};
Parity Bit8(.a(input8), .b(output8));
Parity Bit4(.a(input4), .b(output4));
endmodule

module Parity(a, b);
parameter size = 8;
input [size-1:0] a;
output [size:0] b;

wire acount;

assign acount = a[7] ^ a[6] ^ a[5] ^ a[4] ^ a[3] ^ a[2] ^ a[1] ^ a[0];
assign b = (acount == 1)?{1'b1,a}:{1'b0,a};
endmodule