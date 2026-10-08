`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: K SREE SAI VENKAT
// 
// Create Date: 16.04.2025 17:31:00
// Design Name: 
// Module Name: tb_event_marker
// Project Name: 
// Target Devices: Artix 7
// Tool Versions: 2023.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_event_marker;

	reg clk;
	reg rst;
	reg start;

	wire pulse;

event_marker #(
    .counter_width  (4),
    .wait_time      (10)
)
event_marker_inst(
    .clk    (clk    ),
    .rst    (rst    ),
    .start  (start  ),
    .pulse  (pulse  )
);

always #5 clk = ~clk;	//100MHz clock

initial begin
	
	clk 	= 0;
	rst 	= 0;
	start 	= 0;
	
	#10;
	rst 	= 1;
	#100;
	rst 	= 0;
	
	
	#1000;
	start = 1;
	#90;
	start = 0;
	
	#100;
	start = 1;
	#110;
	start = 0;
	
end

endmodule