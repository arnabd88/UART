`include "testbench.sv"
module top ();

logic PCLK, BR_CLK;
always #5 PCLK = ~PCLK;
always #5 BR_CLK = ~BR_CLK;


	testbench u_testbench(.PCLK(PCLK), .BR_CLK(BR_CLK));

endmodule
