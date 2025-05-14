module VGA(clk, rst, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK, SW2, SW3, key3, ledg);

input clk, rst;		//clk 50MHz
input [1:0] SW2; //
input [2:0] SW3; //
input key3;
output VGA_HS, VGA_VS;
output reg [7:0] VGA_R,VGA_G,VGA_B;
output VGA_BLANK_N,VGA_CLOCK;
output reg ledg;

reg VGA_HS, VGA_VS;
reg[10:0] counterHS;
reg[9:0] counterVS;
reg [2:0] valid;
reg clk25M;
reg [1:0] sww2;
reg [2:0] sww3;
reg checkcolor;
reg [26:0] clk_count;

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

always@(posedge clk)
	clk25M = ~clk25M;

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

reg [23:0]color[3:0];
reg [23:0] color0, color1, color2, color3;

always@(posedge clk25M)
begin
	if (!rst) 
	begin
		{VGA_R,VGA_G,VGA_B}<=0;
   end
	else 
	begin
		if(X < 320 && Y < 240) begin
			{VGA_R,VGA_G,VGA_B}<=color[0]; 
		end else if(X < 320 && Y >= 240) begin
			{VGA_R,VGA_G,VGA_B}<=color[1];
		end else if(X >= 320 && Y < 240) begin
			{VGA_R,VGA_G,VGA_B}<=color[2];
		end else begin
			{VGA_R,VGA_G,VGA_B}<=color[3];
		end
   end
end

always@(posedge clk,negedge rst)begin
	if(!rst)begin
		color[0]<=24'h000000;//
		color[1]<=24'h000000;//
		color[2]<=24'h000000;//
		color[3]<=24'h000000;//
		checkcolor <= 0;
		//sww2 <= 2'b00;
		sww3 <= 3'b000;
		ledg <= 0;
	end 
	else begin
		/*ledg <= 0;
		if (key3 == 0) begin
			
			ledg <= 1'b1;
			//sww3 <= SW3;
		end*/
		
		if (key3 == 0) begin
			if (clk_count == 500) begin
				clk_count <= 1;
				sww2 <= SW2;
			end
			else begin
				clk_count <= clk_count + 1;
			end
			//sww2 <= SW2;
		end
		
			case (sww2)
				2'b00: color[0]<=24'h0000ff;//blue
				2'b01: color[1]<=24'h00ff00;//green
				2'b10: color[2]<=24'hff0000;//red
				2'b11: begin
					if (key3 == 1) begin
						/*if (clk_count == 5000) begin
							clk_count <= 1;
							sww3 <= SW3;
						end
						else begin
							clk_count <= clk_count + 1;
						end*/
						sww3 <= SW3;
					end
					if (key3 == 1) begin
						case (sww3)
							3'b000: begin
								color[3] <= 24'h000000; 
								checkcolor <= 1;
							end
							3'b001: begin
								color[3] <= 24'h0000ff; 
								checkcolor <= 1;
							end
							3'b010: begin
								color[3] <= 24'h00ff00; 
								checkcolor <= 1;
							end
							3'b011: begin
								color[3] <= 24'h00ffff; 
								checkcolor <= 1;
							end
							3'b100: begin
								color[3] <= 24'hff0000; 
								checkcolor <= 1;
							end
							3'b101: begin
								color[3] <= 24'hff00ff; 
								checkcolor <= 1;
							end
							3'b110: begin
								color[3] <= 24'hffff00; 
								checkcolor <= 1;
							end
							3'b111: begin
								color[3] <= 24'hffffff; 
								checkcolor <= 1;
							end
							default: begin
								checkcolor <= 0;
							end
						endcase
					end
					
					if (checkcolor == 1) begin
						if (clk_count == 50000000) begin
							clk_count <= 1;
							if (sww2[0] == 1'b1) begin
								
								/*color0 <= color[0];
								color[3] <= color0;
								color1 <= color[1];
								color[0] <= color1;
								color2 <= color[2];
								color[1] <= color2;
								color3 <= color[3];
								color[2] <= color3;
								color[3] <= color0;*/
								
								/*color[0] <= color[0];
								color[1] <= color[1];
								color[2] <= color[2];
								color[3] <= color[3];*/
								
								
								//color3 <= color[3];
								color[0] <= color[1];
								color[1] <= color[2];
								color[2] <= color[3];
								color[3] <= color[0];
								
								//color[0] <= color[1];
								//color[3] <= color[2];
								//color[2] <= color[0];
							end
							else if (sww2[0] == 1'b0) begin
								color[0] <= color[0];
								color[1] <= color[1];
								color[2] <= color[2];
								color[3] <= color[3];
								
								/*color3 <= color[3];
								color[0] <= color[1];
								color[1] <= color[2];
								color[2] <= color3;
								color[3] <= color[0];*/
							end
							else begin
								color[0] <= 24'h000000;
								color[1] <= 24'h000000;
								color[2] <= 24'h000000;
								color[3] <= 24'h000000;
							end
						end
						else begin
							clk_count <= clk_count + 1;
						end
						
					end
					
				end
				default: begin
					color[0]<=24'h000000;//
					color[1]<=24'h000000;//
					color[2]<=24'h000000;//
					color[3]<=24'h000000;//
				end
			endcase
	end
end

endmodule

