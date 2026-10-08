`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: K SREE SAI VENKAT
// 
// Create Date: 16.04.2025 16:31:27
// Design Name: 
// Module Name: event_marker
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

module event_marker 
#(parameter counter_width = 4, wait_time = 10)       // externally overridden, syntax to instantiate mentioned at EOF
(
    input  wire clk     ,
    input  wire rst     ,  // Active high reset
    input  wire start   ,

    output reg  pulse
);

reg [counter_width - 1 : 0] wait_counter;

always@(posedge clk) begin

    if (rst) begin
        pulse        <= 0;
        wait_counter <= 0;
    end

    else if(start) begin
        if(wait_counter == wait_time) begin
            pulse <= 1;
            wait_counter <= 0;
        end
        else begin
            pulse <= 0;
            wait_counter <= wait_counter + 1;
        end
    end

    else begin
        pulse <= 0;
        wait_counter <= 0;
    end

end

endmodule


//event_marker #(
//    .counter_width  (4),
//    .wait_time      (10)
//)
//event_marker_inst(
//    .clk    (clk    ),
//    .rst    (rst    ),
//    .start  (start  ),
//    .pulse  (pulse  )
//);