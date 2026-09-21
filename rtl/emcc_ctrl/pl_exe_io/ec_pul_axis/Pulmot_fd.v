/////////////////////////// INCLUDE /////////////////////////////

////////////////////////////////////////////////////////////////
//
//  Module  : Pulmot_fd
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2019/12/4
//
////////////////////////////////////////////////////////////////
// 
//  Description: Drive function for servo motor or step motor
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// DEFINE /////////////////////////////

/////////////////////////// MODULE //////////////////////////////
module Pulmot_fd
(
    input                   clk                // clock input, 100MHz
   ,input                   reset              // reset input, active low
   
   ,input  wire             i_bv_pulse_start   // behavior interface: start input
   ,input  wire [31:0]      i_bv_pulse_period  // behavior interface: pulse period, @10ns
   ,input  wire [31:0]      i_bv_pulse_number  // behavior interface: pulse number
   ,input  wire             i_bv_pulse_dir     // behavior interface: pulse direction
   ,input  wire             i_abort
   ,input  wire             i_pause            // synchronous hold when USE_PAUSE=1
   ,output wire             o_bv_pulse_busy    // includes the complete final pulse period
   ,output wire             o_bv_pulse_done    // behavior interface: done output

   ,input  wire             i_dv_ready         // drive interface: ready input
   ,input  wire             i_dv_inp           // drive interface: in place input
   ,input  wire             i_dv_phase_a       // drive interface: encoder feedback phase a
   ,input  wire             i_dv_phase_b       // drive interface: encoder feedback phase b
   ,input  wire             i_dv_phase_z       // drive interface: encoder feedback phase z
   ,output wire             o_dv_pulse_p       // drive interface: pulse output positice
   ,output wire             o_dv_pulse_n       // drive interface: pulse output negative
);

   ///////////////// PARAMETER ////////////////
   parameter PR_PA13 = 8'h11;
   parameter PR_PA14 = 1'b1;
   parameter P_PERIOD_MIN = 100;
   parameter USE_ABORT = 0;
   parameter USE_PAUSE = 0; // preserve standalone callers without a pause connection

   ////////////////// ARCH ////////////////////
   
   ////////////////// Pulse Generate
   reg  [31:0]    r_pulse_period;
   reg  [31:0]    r_pulse_number;
   reg            r_pulse_dir;
   reg  [31:0]    r_pulse_count;  // counter in one pulse
   reg  [31:0]    r_pulse_idx;    // pulse index
   reg            r_pulse_pn;
   
   always@(posedge clk) begin
      if(reset) begin
         r_pulse_period <= P_PERIOD_MIN;
         r_pulse_number <= 0;
         r_pulse_dir <= 1'b0;
         r_pulse_count <= 0;
         r_pulse_idx <= 0;
         r_pulse_pn <= 1'b0;
      end else if(USE_ABORT && i_abort) begin
         r_pulse_number <= 0;
         r_pulse_idx <= 0;
         r_pulse_count <= 0;
         r_pulse_pn <= 1'b0;
      end else if(!USE_PAUSE || !i_pause) begin
         if(r_pulse_idx < r_pulse_number) begin
            r_pulse_count <= r_pulse_count + 1'b1;
            if(r_pulse_count >= (r_pulse_period-1)) begin
               r_pulse_count <= 0;
            end
         end

         if(r_pulse_idx < r_pulse_number) begin
            if(r_pulse_count >= (r_pulse_period-1)) begin
               r_pulse_idx <= r_pulse_idx + 1'b1;
            end
            r_pulse_pn <= (r_pulse_count < (r_pulse_period>>1));
         end
         
         if(i_bv_pulse_start && !o_bv_pulse_busy) begin
            r_pulse_period <= (i_bv_pulse_period < 2) ? 2 : i_bv_pulse_period;
            r_pulse_count <= 0;
            r_pulse_number <= i_bv_pulse_number;
            r_pulse_dir <= i_bv_pulse_dir;
            r_pulse_idx <= 0;
         end
      end
   end
   
   generate
      if(PR_PA13==8'h01) begin
         assign o_dv_pulse_p = r_pulse_pn;
         assign o_dv_pulse_n = PR_PA14 ? ~r_pulse_dir : r_pulse_dir;
      end else if(PR_PA13==8'h11) begin
         assign o_dv_pulse_p = ~r_pulse_pn;
         assign o_dv_pulse_n = PR_PA14 ? r_pulse_dir : ~r_pulse_dir;
      end
   endgenerate
      
   assign o_bv_pulse_busy = (r_pulse_idx < r_pulse_number);
   assign o_bv_pulse_done = o_bv_pulse_busy && (r_pulse_count >= r_pulse_period-1) && (!USE_PAUSE || !i_pause);

endmodule