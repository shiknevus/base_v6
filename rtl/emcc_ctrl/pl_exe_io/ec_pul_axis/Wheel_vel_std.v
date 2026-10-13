/////////////////////////// MODULE //////////////////////////////
// handwheel velocity follower, PARAM38 write = signed pulse/s, add by szzhang 20261013
module Wheel_vel_std #(
    parameter BASE_REFCLK = 156_250_000,
    parameter WDT_MS      = 200,                   // no write -> target 0
    parameter PW_CLK      = BASE_REFCLK/500_000,   // pulse low cap 2us
    parameter DIR_SETUP   = BASE_REFCLK/200_000    // dir setup/hold 5us
)
(
    input                   clk
   ,input                   reset

   ,input  wire             i_tick_1ms
   ,input  wire             i_vld           // PARAM38 write strobe
   ,input  wire [31:0]      i_spd           // signed pulse/s
   ,input  wire             i_allow         // other motion idle
   ,input  wire             i_hold          // pause: target 0
   ,input  wire             i_stop          // quick decel + lock
   ,input  wire             i_abort         // zero speed now + lock
   ,input  wire [31:0]      i_acc
   ,input  wire [31:0]      i_dec
   ,input  wire [31:0]      i_qdec
   ,input  wire [31:0]      i_spd_max
   ,input  wire             i_dir_init      // current dir line
   ,input  wire             i_lim_f         // hw limit: zero speed, block dir
   ,input  wire             i_lim_b
   ,input  wire             i_blk_f         // soft limit: jog decel, block dir
   ,input  wire             i_blk_b
   ,output wire             o_active        // owns pulse/dir lines
   ,output wire             o_pulse         // idle high, active low
   ,output wire             o_dir
);

   localparam DIR_POS = 1'b1;
   localparam W       = 56;
   localparam [63:0] CLK64 = BASE_REFCLK;
   localparam [W-1:0] FULL = CLK64*CLK64;      // speed scaled by clk: one pulse
   localparam [W-1:0] HALF = FULL >> 1;
   localparam [31:0] SPD_CAP = 32'h007F_FFFF;

   reg  [31:0]   r_spd;
   reg           r_lock;                       // after stop/abort: wait 0 write or wdt
   reg  [15:0]   wdt_cnt;
   reg           r_quick;
   reg  [W-1:0]  mag;                          // |v| * BASE_REFCLK
   reg           dir;
   reg  [W:0]    phase;
   reg           pls_low;
   reg  [15:0]   pw_cnt;
   reg  [15:0]   hold_cnt;
   reg  [15:0]   setup_cnt;
   reg  [W-1:0]  tgt;
   reg           tgt_dir;

   assign o_active = (r_spd != 0) || (mag != 0) || pls_low || (hold_cnt != 0) || (setup_cnt != 0);

   // command
   wire          wdt_out = (wdt_cnt >= WDT_MS);
   always@(posedge clk) begin
      if(reset) begin
         r_spd   <= 32'd0;
         r_lock  <= 1'b0;
         wdt_cnt <= WDT_MS;
      end else begin
         if(i_vld) wdt_cnt <= 16'd0;
         else if(i_tick_1ms && !wdt_out) wdt_cnt <= wdt_cnt + 1'b1;

         if(i_stop | i_abort) begin
            r_spd  <= 32'd0;
            r_lock <= 1'b1;
         end else if(i_vld) begin
            if(i_spd == 0) r_lock <= 1'b0;
            if(!r_lock && (o_active || i_allow)) r_spd <= i_spd;
         end else if(wdt_out) begin
            r_spd  <= 32'd0;
            r_lock <= 1'b0;
         end
      end
   end

   // target
   wire          t_dir  = ~r_spd[31];
   wire [31:0]   t_abs  = r_spd[31] ? (~r_spd + 1'b1) : r_spd;
   wire [31:0]   t_max  = (i_spd_max > SPD_CAP) ? SPD_CAP : i_spd_max;
   wire [31:0]   t_cap  = (t_abs > t_max) ? t_max : t_abs;
   wire          t_blk  = (t_dir == DIR_POS) ? (i_lim_f | i_blk_f) : (i_lim_b | i_blk_b);
   always@(posedge clk) begin
      if(reset) begin
         tgt     <= {W{1'b0}};
         tgt_dir <= DIR_POS;
      end else begin
         tgt     <= (i_hold || t_blk) ? {W{1'b0}} : t_cap[22:0] * CLK64;
         tgt_dir <= t_dir;
      end
   end

   // velocity ramp
   wire          hit_lim = (mag != 0) && (dir == DIR_POS ? i_lim_f : i_lim_b);
   wire [31:0]   dec_now = r_quick ? i_qdec : i_dec;
   wire          quiet   = !pls_low && (hold_cnt == 0);

   always@(posedge clk) begin
      if(reset || mag == 0) r_quick <= 1'b0;
      else if(i_stop)       r_quick <= 1'b1;
   end

   always@(posedge clk) begin
      if(reset) begin
         mag       <= {W{1'b0}};
         dir       <= DIR_POS;
         setup_cnt <= 16'd0;
      end else if(!o_active) begin
         mag       <= {W{1'b0}};
         dir       <= i_dir_init;
         setup_cnt <= 16'd0;
      end else begin
         if(setup_cnt != 0) setup_cnt <= setup_cnt - 1'b1;
         if(i_abort || hit_lim)
            mag <= {W{1'b0}};
         else if(mag == 0) begin
            if(tgt != 0 && tgt_dir != dir) begin
               if(quiet) begin                      // reverse only at rest
                  dir       <= tgt_dir;
                  setup_cnt <= DIR_SETUP;
               end
            end else if(tgt != 0 && setup_cnt == 0)
               mag <= (i_acc < tgt) ? i_acc : tgt;
         end else if(tgt == 0 || tgt_dir != dir)
            mag <= (mag > dec_now) ? mag - dec_now : {W{1'b0}};
         else if(mag > tgt)
            mag <= (mag > tgt + dec_now) ? mag - dec_now : tgt;
         else if(mag < tgt)
            mag <= (mag + i_acc < tgt) ? mag + i_acc : tgt;
      end
   end

   // pulse: phase accumulator, low = min(half period, PW_CLK)
   wire [W:0] ph_sum = phase + mag;
   always@(posedge clk) begin
      if(reset || !o_active) begin
         phase   <= {(W+1){1'b0}};
         pls_low <= 1'b0;
         pw_cnt  <= 16'd0;
      end else begin
         if(pls_low) begin
            pw_cnt <= pw_cnt + 1'b1;
            if(pw_cnt >= PW_CLK-1 || phase >= HALF) pls_low <= 1'b0;
         end
         if(mag == 0 && tgt_dir != dir)
            phase <= {(W+1){1'b0}};                // restart after reverse
         else if(ph_sum >= FULL) begin
            phase   <= ph_sum - FULL;
            pls_low <= 1'b1;
            pw_cnt  <= 16'd0;
         end else
            phase <= ph_sum;
      end
   end

   always@(posedge clk) begin
      if(reset)             hold_cnt <= 16'd0;
      else if(pls_low)      hold_cnt <= DIR_SETUP;
      else if(hold_cnt != 0) hold_cnt <= hold_cnt - 1'b1;
   end

   assign o_pulse = ~pls_low;
   assign o_dir   = dir;

endmodule
