module score(clk,st,HEX0,HEX1,HEX2,HEX3);
input clk;
input [1:0]st;
output reg [6:0] HEX0,HEX1,HEX2,HEX3;
reg [40:0] rt = 40'd0;
reg [3:0] HE0,HE1,HE2,HE3;
reg [40:0] clk1_counter;


always@(posedge clk)begin
if(st==2'd2)begin
 rt<=40'd0;
 HE0<=40'd0;
 HE1<=40'd0;
 HE2<=40'd0;
 HE3<=40'd0;
 HEX0<=40'd0;
 HEX1<=40'd0;
 HEX2<=40'd0;
 HEX3<=40'd0;
 clk1_counter <=40'd0;

end else if(clk1_counter > 5000000 && st==2'd1)begin
 rt=rt+40'd1;
 HE0<=rt%10;
 HE1<=(rt/10)%10;
 HE2<=(rt/100)%10;
 HE3<=(rt/1000)%10;
 HEX0<=NAT(HE0);
 HEX1<=NAT(HE1);
 HEX2<=NAT(HE2);
 HEX3<=NAT(HE3);
 clk1_counter <=40'd0;
 end else begin
 clk1_counter <=clk1_counter +40'd1;
 end
end

function [6:0] NAT;
input  [3:0] CT;

 case(CT)
      4'b0000: NAT =~7'b0111111;  //0
		4'b0001: NAT =~7'b0000110;  //1
		4'b0010: NAT =~7'b1011011;  //2
		4'b0011: NAT =~7'b1001111;  //3
		4'b0100: NAT =~7'b1100110;  //4
		4'b0101: NAT =~7'b1101101;  //5
		4'b0110: NAT =~7'b1111101;  //6
		4'b0111: NAT =~7'b0100111;  //7
		4'b1000: NAT =~7'b1111111;  //8
		4'b1001: NAT =~7'b1101111;  //9
		4'b1010: NAT =~7'b1110111;  //10
		4'b1011: NAT =~7'b1111111;  //11
		4'b1100: NAT =~7'b1011000;  //12
		4'b1101: NAT =~7'b1011110;  //13
		4'b1110: NAT =~7'b1111001;  //14
		4'b1111: NAT =~7'b1110001;  //15
		default: NAT =~7'b0000000;
	endcase

endfunction
endmodule