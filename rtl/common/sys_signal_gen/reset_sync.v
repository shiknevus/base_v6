/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
// Creat Date:    2017.3.27
// Design Name:   reset_sync.v
// Module Name:   sys_signal_gen.v
// Project Name:  idc_xxxx
// Target Devices:cycloneV
// Tool versions:
//                QuartusII15.1
// Dependencies:
//
// Revision:V1.4.1 This module is used to generate the reset signals 
//                 corresponding to the clock domain  
//
/////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module reset_sync
(
  input                           clk,
  input                           rst_async_n,  //active low
  output  reg                     rst_sync = 1'b0 //active hign
);
/////////////////////////////////////////////////////////     
//                  synchronizer                     //
/////////////////////////////////////////////////////////     
  reg rst_q1;
  always @(posedge clk or negedge rst_async_n)
  begin
    if(!rst_async_n)
    begin
      rst_q1 <= 1'b1;
    end
    else
    begin
      rst_q1 <= 1'b0;
    end
  end

  reg rst_q2;
  always @(posedge clk or negedge rst_async_n)
  begin
    if(!rst_async_n)
    begin
      rst_q2 <= 1'b1;
    end
    else
    begin
      rst_q2 <= rst_q1;
    end
  end
  
  always @(posedge clk)
  begin
    rst_sync <= rst_q2;
  end
endmodule
