library verilog;
use verilog.vl_types.all;
entity work1 is
    port(
        clk_in          : in     vl_logic;
        clk_out         : out    vl_logic;
        reset           : in     vl_logic
    );
end work1;
