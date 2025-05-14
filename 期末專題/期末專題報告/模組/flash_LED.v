module flash_LED (
  input [40:0] counter_ch,
  input [1:0] st,
  input clk,
  output reg [17:0] led
);

  reg [26:0] clk_count;
  reg [17:0] led_out = 18'b1; 

  parameter speed1 = 40'd25000000,
            speed2 = 40'd10000000,
            speed3 = 40'd4000000,
            speed4 = 40'd1000000;

  always @(posedge clk) begin
    if (st == 2'd2) begin
      led_out <= 18'b0;
      led <= led_out;
      clk_count <= 1'b0;
    end else begin
      clk_count <= clk_count + 1;

      if ((clk_count == counter_ch) && (st == 1'b1)) begin
        clk_count <= 1'b0;

        case(counter_ch)
          speed1: led_out <= {led_out[0], led_out[16:1]};
          speed2: led_out <= {led_out[16:0], led_out[17]};
          speed3: led_out <= {led_out[17:4], led_out[3:0] + 1};
          speed4: led_out <= {led_out[17:14] + 1, led_out[13:0]};
          default: led_out <= led_out; 
        endcase

        led <= led_out; 
    end
  end
  end
endmodule
