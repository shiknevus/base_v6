`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/22 13:09:17
// Design Name: 
// Module Name: counter_xms
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter_xms #(
     parameter  TIME_1MS_TIMER  =  100000
    ,parameter  SIMULATION_SOFT  =  0
)(
    input   wire  clk     ,
    input   wire  rst_n   ,
    
    output  reg   o_time_1ms_vld,
    output  reg   o_time_10ms_vld,
    output  reg   o_time_100ms_vld,
    output  reg   o_time_1s_vld
);

    reg time_1ms_vld  ;
    reg time_10ms_vld ;
    reg time_100ms_vld;
    reg time_1s_vld   ;
    
   generate
   if (SIMULATION_SOFT==1)begin

    always @(*)begin
        #0.05 
        o_time_1ms_vld   = ~clk ;
        o_time_10ms_vld  = ~clk ;
        o_time_100ms_vld = ~clk ;
        o_time_1s_vld    = ~clk ;
    end

   end else begin
   
   always @(*)begin
        o_time_1ms_vld   = time_1ms_vld   ;
        o_time_10ms_vld  = time_10ms_vld  ;
        o_time_100ms_vld = time_100ms_vld ;
        o_time_1s_vld    = time_1s_vld    ;
    end
   
   reg [16:0] cnt_time_1ms;
   always @ (posedge clk)
   begin
      if(!rst_n) begin
         cnt_time_1ms <= 'b0 ;
         time_1ms_vld <= 'b0 ;
      end
      else begin
        if(cnt_time_1ms < TIME_1MS_TIMER - 1) begin
           cnt_time_1ms <= cnt_time_1ms + 1 ;
           time_1ms_vld <= 'b0 ;
        end
        else begin
           cnt_time_1ms <= 'b0 ;
           time_1ms_vld <= 'b1 ;
        end
      end
   end
   
   
   reg [3:0] cnt_time_10ms;
   always @ (posedge clk)
   begin
      if(!rst_n) begin
         cnt_time_10ms <= 'b0 ;
         time_10ms_vld <= 'b0 ;
      end
      else begin
        if(cnt_time_10ms < 'd10) begin
           cnt_time_10ms <= cnt_time_10ms + time_1ms_vld ;
           time_10ms_vld <= 'b0 ;
        end
        else begin
           cnt_time_10ms <= 'b0 ;
           time_10ms_vld <= 'b1 ;
        end
      end
   end
   
   
   reg [3:0] cnt_time_100ms;
   always @ (posedge clk)
   begin
      if(!rst_n) begin
         cnt_time_100ms <= 'b0 ;
         time_100ms_vld <= 'b0 ;
      end
      else begin
        if(cnt_time_100ms < 'd10) begin
           cnt_time_100ms <= cnt_time_100ms + time_10ms_vld ;
           time_100ms_vld <= 'b0 ;
        end
        else begin
           cnt_time_100ms <= 'b0 ;
           time_100ms_vld <= 'b1 ;
        end
      end
   end
   
   
   reg [3:0] cnt_time_1s;
   always @ (posedge clk)
   begin
      if(!rst_n) begin
         cnt_time_1s <= 'b0 ;
         time_1s_vld <= 'b0 ;
      end
      else begin
        if(cnt_time_1s < 'd10) begin
           cnt_time_1s <= cnt_time_1s + time_100ms_vld ;
           time_1s_vld <= 'b0 ;
        end
        else begin
           cnt_time_1s <= 'b0 ;
           time_1s_vld <= 'b1 ;
        end
      end
   end
   
   end
   endgenerate
    
    
    
endmodule
