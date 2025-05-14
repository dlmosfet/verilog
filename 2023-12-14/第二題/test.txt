module test(clk, rst, IRDA_RXD, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK);

input clk, rst;		//clk 50MHz
input IRDA_RXD;
output VGA_HS, VGA_VS;
output reg [7:0] VGA_R,VGA_G,VGA_B;
output VGA_BLANK_N,VGA_CLOCK;

reg VGA_HS, VGA_VS;
reg[10:0] counterHS;
reg[9:0] counterVS;
reg [2:0] valid;
reg clk25M;

reg [12:0] X,Y;

parameter H_FRONT = 16;										// state E
parameter H_SYNC  = 96;										// state B
parameter H_BACK  = 48;										// state C
parameter H_ACT   = 640;									// state D
parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

parameter V_FRONT = 11;										// state S
parameter V_SYNC  = 2;										// state P
parameter V_BACK  = 32;										// state Q
parameter V_ACT   = 480;									// state R
parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;
assign VGA_SYNC_N = 1'b0;
assign VGA_BLANK_N = ~((counterHS<H_BLANK)||(counterVS<V_BLANK));
assign VGA_CLOCK = ~clk25M;

parameter radius=10'd30;

always@(posedge clk)
	clk25M = ~clk25M;

	
	
	  wire            IR_READY;
    wire    [31:0]  IR_DATA;

    IR_RECEIVE IR(  .iCLK(clk), .iRST_n(rst),
                    .iIRDA(IRDA_RXD), .oDATA_READY(IR_READY), .oDATA(IR_DATA));

// DON'T MOVE
always@(posedge clk25M)
begin
	if(!rst) 
		counterHS <= 0;
	else begin
	
		if(counterHS == H_TOTAL) 
			counterHS <= 0;
		else 
			counterHS <= counterHS + 1'b1;
		
		if(counterHS == H_FRONT-1)
			VGA_HS <= 1'b0;
		if(counterHS == H_FRONT + H_SYNC -1)
			VGA_HS <= 1'b1;
			
		if(counterHS >= H_BLANK)							// record X position
			X <= counterHS-H_BLANK;
		else
			X <= 0;	
	end
end

// DON'T MOVE
always@(posedge clk25M)
begin
	if(!rst) 
		counterVS <= 0;
	else begin
	
		if(counterVS == V_TOTAL) 
			counterVS <= 0;
		else if(counterHS == H_TOTAL) 
			counterVS <= counterVS + 1'b1;
			
		if(counterVS == V_FRONT-1)
			VGA_VS <= 1'b0;
		if(counterVS == V_FRONT + V_SYNC -1)
			VGA_VS <= 1'b1;
		if(counterVS >= V_BLANK)							// record Y position
			Y <= counterVS-V_BLANK;
		else
			Y <= 0;
	end
end

reg [23:0]color[4:0];

always@(posedge clk25M,negedge IR_READY, negedge rst)
begin
	if (!rst) begin
		{VGA_R,VGA_G,VGA_B}<=0;
   end
	else 
	begin
	case (IR_DATA[23:16])
					8'h01 : begin	
					if(X <=360 && X >=280 && Y <= 300 && Y >= 180) begin
			          {VGA_R,VGA_G,VGA_B}<=color[0]; 
		         end  else begin
						{VGA_R,VGA_G,VGA_B}<=color[4]; 
					end
	
					end
					8'h02 : begin
					if(X+Y>=560 && X-Y<=80 && Y <=280) 
					begin
						{VGA_R,VGA_G,VGA_B}<=color[0]; 
						end
					else begin
						{VGA_R,VGA_G,VGA_B}<=color[4];
						end
					end
					8'h03 : begin
						if((((320-X)**4'd2)+((240-Y)**4'd2))<=(radius**4'd2)) begin
						{VGA_R,VGA_G,VGA_B}<=color[0];
					  end else begin
						{VGA_R,VGA_G,VGA_B}<=color[4]; 
					end
					end 
					8'h04 : begin
						if((X <=320 && X >=280 && Y >= 320 && Y <= 400)||(X+Y>=560 && X-Y<=80 && Y <=280) || (X+Y>=20'd600 && (X-Y+20'd100)<=(20'd140) && Y <=20'd320 )) 
					begin
						{VGA_R,VGA_G,VGA_B}<=color[0]; 
						end  else begin
						{VGA_R,VGA_G,VGA_B}<=color[4];
						end
					end
			  endcase 
   end
end




always@(posedge clk,negedge rst)begin
	if(!rst)begin
		color[0]<=24'h000000;//
		color[1]<=24'h000000;//
		color[2]<=24'h000000;//
		color[3]<=24'h000000;//
		color[4]<=24'h000000;//
	end else begin
		color[0]<=24'h0000ff;//blue
		color[1]<=24'h00ff00;//green
		color[2]<=24'hff0000;//red
		color[3]<=24'hffffff;//
		color[4]<=24'h000000;//
	end
end


endmodule
