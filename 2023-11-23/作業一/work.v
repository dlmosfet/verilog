module work(sw, clk, reset, contin, led_out);
input [1:0] sw;
input reset, contin, clk;
output [17:0] led_out;

reg [17:0] led_out;
reg [26:0] count;
reg [1:0] state;
reg clk5hz = 0;
reg c = 0;
reg [26:0] clk_count;
reg [1:0] sww;

always @(posedge clk)
begin
	if(reset == 0)
	begin
		led_out <= 18'b000000000000000001;
	end
	else
	begin
		if (contin == 0)
		begin
			sww <= sw;
		end
		if(clk_count == 50000000)
		begin
			clk_count <= 1;
			if(contin == 0 || state == 1)
			begin
				state<=1;
				case(sww)
					2'b00: led_out[17:0] <= {led_out[0], led_out[16:1]};
					2'b01: led_out[17:0] <= {led_out[16:0], led_out[17]};
					2'b10: led_out[17:0] <= {led_out[17:4], led_out[3:0] + 1};
					2'b11: led_out[17:0] <= {led_out[17:14] + 1, led_out[13:0]};
					default: led_out[17:0] <= 18'b000000000000000000;
				endcase
			end
			else if(contin == 1)
			begin
				state <= 1;
			end
			else
			begin
				state <= 1;
			end
		end
		else
		begin
			clk_count <= clk_count + 1;
		end
	end
end
endmodule
