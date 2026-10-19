/////////////////////////// MODULE //////////////////////////////
// pulse-axis segment executor, ABI v2 (doc/pul_axis_seg_abi_v2.md)
module slv_seg_exec
#(
    parameter CLK_HZ      = 100_000_000
   ,parameter BEAT_TO_CLK = CLK_HZ/5          // 200ms heartbeat timeout
)
(
    input                    clk
   ,input                    reset
   ,input  wire              i_frame_end       // write strobe of m2s word15
   ,input  wire [511:0]      i_m2s             // m2s word k at [32k+31:32k]
   ,input  wire              i_link_lost       // no rx on fiber
   ,input  wire [95:0]       i_di              // local board DI
   ,input  wire              i_dv_ok           // drive alarm input, 1 = normal
   ,output wire [511:0]      o_s2m
   ,output wire              o_pulse
   ,output wire              o_dir
   ,output wire              o_son             // active low
   ,output wire              o_rst             // active low
);

   localparam [15:0] MAGIC   = 16'h5A7E;
   localparam [7:0]  ABI_MAJ = 8'd2;
   localparam [7:0]  ABI_MIN = 8'd0;
   localparam [31:0] CAP     = 32'h0000_003F;
   localparam [31:0] CONT    = 32'h7FFF_FFFF;
   localparam        DIR_POS = 1'b1;

   localparam [3:0] OP_NOP = 4'd0, OP_REL = 4'd1, OP_ABS = 4'd2, OP_VEL = 4'd3,
                    OP_STOP = 4'd4, OP_SETPOS = 4'd5, OP_CLR = 4'd6;
   localparam [3:0] RS_OK = 4'd0, RS_BLOCK = 4'd1, RS_FAULT = 4'd2, RS_UNSUP = 4'd3,
                    RS_PARAM = 4'd4, RS_SOFT = 4'd5, RS_BUSY = 4'd6, RS_NOPOS = 4'd7;
   localparam [3:0] EC_NONE = 4'd0, EC_TARGET = 4'd1, EC_TRIG = 4'd2, EC_STOP = 4'd3,
                    EC_QSTOP = 4'd4, EC_FAULT = 4'd5, EC_OPSTOP = 4'd6;

   ////////////////// frame shadow
   reg  [31:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;
   reg         fe_d;
   reg         frm_vld;
   reg         frm_seen;
   always @(posedge clk) begin
      if(reset) begin
         fe_d <= 1'b0; frm_vld <= 1'b0; frm_seen <= 1'b0;
         {w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15} <= 512'd0;
      end else begin
         fe_d    <= i_frame_end;
         frm_vld <= fe_d;
         if(fe_d) begin   // word15 lands one cycle after its strobe
            frm_seen <= 1'b1;
            {w15,w14,w13,w12,w11,w10,w9,w8,w7,w6,w5,w4,w3,w2,w1,w0} <= i_m2s;
         end
      end
   end

   wire        magic_ok  = frm_seen && (w15[31:16] == MAGIC) && (w15[15:8] == ABI_MAJ);
   wire [7:0]  cmd_seq   = w0[31:24];
   wire [3:0]  cmd_op    = w0[23:20];
   wire        ctl_son   = w0[15];
   wire        ctl_rst   = w0[14];
   wire        ctl_beat  = w0[13];
   wire        ctl_pause = w0[12];
   wire        ctl_stop  = w0[11];
   wire        ctl_qstop = w0[10];
   wire        ext_abort = w0[9];

   ////////////////// heartbeat
   reg         beat_d;
   reg  [31:0] beat_cnt;
   reg         beat_to;
   always @(posedge clk) begin
      if(reset || !magic_ok) begin
         beat_d <= ctl_beat; beat_cnt <= 32'd0; beat_to <= 1'b0;
      end else if(beat_d != ctl_beat) begin
         beat_d <= ctl_beat; beat_cnt <= 32'd0; beat_to <= 1'b0;
      end else if(!beat_to) begin
         beat_cnt <= beat_cnt + 1'b1;
         if(beat_cnt >= BEAT_TO_CLK - 1) beat_to <= 1'b1;
      end
   end
   wire link_ok = magic_ok && !i_link_lost && !beat_to;

   ////////////////// command sequence: first frame after (re)link only syncs
   reg         seq_sync;
   reg  [7:0]  seq_last;
   reg         cmd_new;
   always @(posedge clk) begin
      cmd_new <= 1'b0;
      if(reset || !link_ok) begin
         seq_sync <= 1'b0;
      end else if(frm_vld) begin
         seq_last <= cmd_seq;
         if(!seq_sync)                   seq_sync <= 1'b1;
         else if(cmd_seq != seq_last)    cmd_new  <= 1'b1;
      end
   end

   ////////////////// io map
   wire [6:0] idx_f = w13[6:0];
   wire [6:0] idx_b = w13[13:7];
   wire [6:0] idx_o = w13[20:14];
   wire di_f = (idx_f < 7'd96) ? i_di[idx_f] : 1'b0;
   wire di_b = (idx_b < 7'd96) ? i_di[idx_b] : 1'b0;
   wire di_o = (idx_o < 7'd96) ? i_di[idx_o] : 1'b0;
   wire limf = w13[24] ? w0[5] : (di_f ^ w13[21]);
   wire limb = w13[25] ? w0[6] : (di_b ^ w13[22]);
   wire org  = w13[26] ? w0[7] : (di_o ^ w13[23]);

   function [31:0] clamp;
      input [31:0] v, mx;
      clamp = (mx != 0 && v > mx) ? mx : v;
   endfunction

   wire [31:0] dec_max_eff = (w10 != 0) ? w10 : w4;

   ////////////////// position
   reg  signed [31:0] abspos;
   reg                pos_valid;
   reg                abspos_set;
   reg                pulse_d;
   wire               o_pulse_rise = o_pulse && !pulse_d;
   wire               soft_en = w14[0] && pos_valid;
   wire signed [31:0] soft_max = w11;
   wire signed [31:0] soft_min = w12;
   wire               soft_f = soft_en && (abspos >= soft_max);
   wire               soft_b = soft_en && (abspos <= soft_min);

   ////////////////// segment state
   reg         seg_active;
   reg         seg_started;
   reg         seg_dir;
   reg         seg_cont;
   reg  [31:0] seg_pulse;
   reg  [31:0] seg_spd, seg_acc, seg_dec, seg_evt_dec, seg_lim_dec;
   reg  [6:0]  seg_evt;
   reg         pos_start;
   reg         stop_req;
   reg         abort_req;
   reg         q_evt, q_lim, q_max;
   reg  [31:0] seg_cnt;

   reg  [7:0]  ack_seq;
   reg  [3:0]  ack_op;
   reg  [3:0]  result;
   reg         st_done, st_error, st_trig;
   reg  [3:0]  trig_cause;
   reg  [3:0]  end_cause;
   reg  [10:0] fault;
   reg  signed [31:0] cappos;

   wire        pos_busy, pos_done, pos_error;
   wire        pul_busy;
   wire        vel_active;

   wire        lim_fwd  = seg_dir ? limf : limb;
   wire        lim_evt  = seg_dir ? seg_evt[2] : seg_evt[3];
   wire        trg_now  = (seg_evt[0] && org) || (seg_evt[1] && !org);

   ////////////////// velocity mode control
   reg         vel_vld;
   reg  [31:0] vel_spd;
   reg  [31:0] vel_acc, vel_dec;
   reg  [31:0] vel_ms;
   reg         vel_wdt_hit;
   reg         ctl_stop_d;
   wire [31:0] vel_wdt_ms = (w14[15:8] == 0) ? 32'd1000 : w14[15:8] * 10;
   reg  [31:0] ms_cnt;
   reg         tick_1ms;
   always @(posedge clk) begin
      if(reset || ms_cnt == CLK_HZ/1000 - 1) ms_cnt <= 32'd0;
      else                                   ms_cnt <= ms_cnt + 1'b1;
      tick_1ms <= (ms_cnt == CLK_HZ/1000 - 1);
   end

   ////////////////// command decode
   wire signed [32:0] rel_end = {abspos[31], abspos} + {w1[31], w1};
   wire signed [32:0] abs_dif = {w1[31], w1} - {abspos[31], abspos};
   wire        cmd_dir   = (cmd_op == OP_ABS) ? !abs_dif[32] : !w1[31];
   wire [32:0] abs_mag   = abs_dif[32] ? -abs_dif : abs_dif;
   wire [31:0] rel_mag   = w1[31] ? (~w1 + 1'b1) : w1;
   wire [31:0] cmd_pulse = (cmd_op == OP_ABS) ? abs_mag[31:0] : rel_mag;
   wire        cmd_cont  = (cmd_op == OP_REL) && (rel_mag >= CONT);
   wire signed [32:0] cmd_end = (cmd_op == OP_ABS) ? $signed({w1[31], w1}) : rel_end;
   wire signed [32:0] soft_max33 = soft_max;
   wire signed [32:0] soft_min33 = soft_min;
   wire        cmd_lim   = cmd_dir ? (limf && !w5[2]) : (limb && !w5[3]);
   wire        cmd_soft  = soft_en && !cmd_cont && (cmd_pulse != 0) &&
                           ((cmd_end > soft_max33) || (cmd_end < soft_min33));
   wire        evt_bad   = ((w5[0] || w5[1]) && w5[5:4] == 2'd0 && w6 == 0) ||
                           ((w5[2] || w5[3]) && w7 == 0);
   wire        blocked   = ctl_stop || ctl_qstop || ctl_pause;
   wire        hw_fault  = !i_dv_ok || ext_abort || (limf && limb) || !ctl_son;
   wire        is_seg_op = (cmd_op == OP_REL) || (cmd_op == OP_ABS);

   ////////////////// main control
   always @(posedge clk) begin
      if(reset) begin
         seg_active <= 1'b0; seg_started <= 1'b0; pos_start <= 1'b0;
         seg_dir <= DIR_POS; seg_cont <= 1'b0; seg_pulse <= 32'd0;
         seg_spd <= 0; seg_acc <= 0; seg_dec <= 0; seg_evt_dec <= 0; seg_lim_dec <= 0; seg_evt <= 0;
         stop_req <= 1'b0; abort_req <= 1'b0; q_evt <= 1'b0; q_lim <= 1'b0; q_max <= 1'b0;
         ack_seq <= 8'd0; ack_op <= 4'd0; result <= RS_OK;
         st_done <= 1'b0; st_error <= 1'b0; st_trig <= 1'b0; trig_cause <= 4'd0; end_cause <= EC_NONE;
         fault <= 11'd0; cappos <= 32'sd0; seg_cnt <= 32'd0;
         abspos_set <= 1'b0;
         vel_vld <= 1'b0; vel_spd <= 32'd0; vel_acc <= 32'd0; vel_dec <= 32'd0;
         vel_ms <= 32'd0; vel_wdt_hit <= 1'b0; ctl_stop_d <= 1'b0;
      end else begin
         pos_start  <= 1'b0;
         vel_vld    <= 1'b0;
         abspos_set <= 1'b0;
         ctl_stop_d <= ctl_stop;

         // command
         if(cmd_new) begin
            ack_seq <= cmd_seq;
            ack_op  <= cmd_op;
            result  <= RS_OK;
            case(cmd_op)
               OP_NOP: ;
               OP_REL, OP_ABS: begin
                  if(seg_active || vel_active || pos_busy) result <= RS_BUSY;
                  else if(blocked)                         result <= RS_BLOCK;
                  else if(hw_fault || cmd_lim) begin
                     result <= RS_FAULT;
                     if(!i_dv_ok)              fault[0] <= 1'b1;
                     if(cmd_lim &&  cmd_dir)   fault[1] <= 1'b1;
                     if(cmd_lim && !cmd_dir)   fault[2] <= 1'b1;
                     if(limf && limb)          fault[3] <= 1'b1;
                     if(ext_abort)             fault[8] <= 1'b1;
                  end
                  else if(cmd_op == OP_ABS && !pos_valid)  result <= RS_NOPOS;
                  else if(w2 == 0 || w3 == 0 || w4 == 0 || evt_bad) result <= RS_PARAM;
                  else if(cmd_soft) begin
                     result <= RS_SOFT;
                     if(cmd_end > soft_max33) fault[6] <= 1'b1;
                     else                                   fault[7] <= 1'b1;
                  end
                  else begin
                     fault      <= 11'd0;
                     st_done    <= 1'b0; st_error <= 1'b0; st_trig <= 1'b0;
                     trig_cause <= 4'd0; end_cause <= EC_NONE;
                     seg_dir    <= cmd_dir;
                     seg_cont   <= cmd_cont;
                     seg_pulse  <= cmd_cont ? CONT : cmd_pulse;
                     seg_spd    <= clamp(w2, w8);
                     seg_acc    <= clamp(w3, w9);
                     seg_dec    <= clamp(w4, w10);
                     seg_evt_dec<= clamp(w6, w10);
                     seg_lim_dec<= clamp(w7, w10);
                     seg_evt    <= w5[6:0];
                     stop_req   <= 1'b0; abort_req <= 1'b0;
                     q_evt <= 1'b0; q_lim <= 1'b0; q_max <= 1'b0;
                     seg_cnt    <= 32'd0;
                     if(cmd_pulse == 0) begin
                        st_done   <= 1'b1;
                        end_cause <= EC_TARGET;
                     end else begin
                        seg_active  <= 1'b1;
                        seg_started <= 1'b0;
                        pos_start   <= 1'b1;
                     end
                  end
               end
               OP_VEL: begin
                  if(seg_active || pos_busy)               result <= RS_BUSY;
                  else if(blocked)                         result <= RS_BLOCK;
                  else if(hw_fault) begin
                     result <= RS_FAULT;
                     if(!i_dv_ok)     fault[0] <= 1'b1;
                     if(limf && limb) fault[3] <= 1'b1;
                     if(ext_abort)    fault[8] <= 1'b1;
                  end
                  else if(w3 == 0 || w4 == 0)              result <= RS_PARAM;
                  else begin
                     if(!vel_active) begin
                        fault <= 11'd0;
                        st_done <= 1'b0; st_error <= 1'b0; st_trig <= 1'b0;
                        trig_cause <= 4'd0; end_cause <= EC_NONE;
                     end
                     vel_acc <= clamp(w3, w9);
                     vel_dec <= clamp(w4, w10);
                     vel_spd <= w1;
                     vel_vld <= 1'b1;
                     vel_ms  <= 32'd0;
                     vel_wdt_hit <= 1'b0;
                  end
               end
               OP_STOP: begin
                  if(seg_active) begin
                     stop_req <= 1'b1;
                     if(end_cause == EC_NONE) end_cause <= EC_OPSTOP;
                  end
                  if(vel_active) begin
                     vel_spd <= 32'd0;
                     vel_vld <= 1'b1;
                  end
               end
               OP_SETPOS: begin
                  if(seg_active || vel_active || pos_busy) result <= RS_BUSY;
                  else abspos_set <= 1'b1;
               end
               OP_CLR: fault <= 11'd0;
               default: result <= RS_UNSUP;
            endcase
         end

         // running segment
         if(seg_active) begin
            if(pos_busy) seg_started <= 1'b1;
            if(o_pulse_rise) seg_cnt <= seg_cnt + 1'b1;

            if(!st_trig && trg_now) begin
               st_trig    <= 1'b1;
               trig_cause <= {2'b00, seg_evt[1] && !org, seg_evt[0] && org};
               if(seg_evt[6]) cappos <= abspos;
               if(end_cause == EC_NONE) end_cause <= EC_TRIG;
               case(seg_evt[5:4])
                  2'd0:    q_evt     <= 1'b1;
                  2'd1:    stop_req  <= 1'b1;
                  default: abort_req <= 1'b1;
               endcase
            end

            if(lim_fwd) begin
               if(lim_evt) begin
                  if(!st_trig) begin
                     st_trig    <= 1'b1;
                     trig_cause <= seg_dir ? 4'b0100 : 4'b1000;
                     if(seg_evt[6]) cappos <= abspos;
                  end
                  if(end_cause == EC_NONE) end_cause <= EC_TRIG;
                  q_lim <= 1'b1;
               end else begin
                  abort_req <= 1'b1;
                  if(seg_dir) fault[1] <= 1'b1; else fault[2] <= 1'b1;
                  end_cause <= EC_FAULT;
               end
            end
            if(limf && limb)  begin abort_req <= 1'b1; fault[3] <= 1'b1; end_cause <= EC_FAULT; end
            if(!i_dv_ok)      begin abort_req <= 1'b1; fault[0] <= 1'b1; end_cause <= EC_FAULT; end
            if(ext_abort)     begin abort_req <= 1'b1; fault[8] <= 1'b1; end_cause <= EC_FAULT; end
            if(!ctl_son)      begin abort_req <= 1'b1;                   end_cause <= EC_FAULT; end
            if(beat_to)       begin q_max <= 1'b1; fault[4] <= 1'b1; end_cause <= EC_FAULT; end
            if(i_link_lost)   begin q_max <= 1'b1; fault[5] <= 1'b1; end_cause <= EC_FAULT; end
            if(!magic_ok)     begin q_max <= 1'b1; fault[10] <= 1'b1; end_cause <= EC_FAULT; end
            if(seg_cont && (seg_dir ? soft_f : soft_b)) begin
               q_max <= 1'b1;
               if(seg_dir) fault[6] <= 1'b1; else fault[7] <= 1'b1;
               end_cause <= EC_FAULT;
            end
            if(ctl_qstop) begin
               q_max <= 1'b1;
               if(end_cause == EC_NONE || end_cause == EC_TRIG) end_cause <= EC_QSTOP;
            end
            if(ctl_stop) begin
               stop_req <= 1'b1;
               if(end_cause == EC_NONE || end_cause == EC_TRIG) end_cause <= EC_STOP;
            end

            if(seg_started && !pos_busy && !pul_busy && !pos_start) begin
               seg_active <= 1'b0;
               stop_req <= 1'b0; abort_req <= 1'b0;
               q_evt <= 1'b0; q_lim <= 1'b0; q_max <= 1'b0;
               if(end_cause == EC_NONE || end_cause == EC_TRIG) begin
                  st_done <= 1'b1;
                  if(end_cause == EC_NONE) end_cause <= EC_TARGET;
               end else
                  st_error <= 1'b1;
            end
         end

         // velocity mode supervision
         if(vel_active) begin
            if(tick_1ms && !vel_wdt_hit) begin
               vel_ms <= vel_ms + 1'b1;
               if(vel_ms + 1 >= vel_wdt_ms) begin
                  vel_wdt_hit <= 1'b1;
                  vel_spd <= 32'd0;
                  vel_vld <= 1'b1;
               end
            end
            if(ctl_stop && !ctl_stop_d) begin
               vel_spd <= 32'd0;
               vel_vld <= 1'b1;
            end
            if(!i_dv_ok)      fault[0] <= 1'b1;
            if(ext_abort)     fault[8] <= 1'b1;
            if(limf && limb)  fault[3] <= 1'b1;
            if(beat_to)       fault[4] <= 1'b1;
            if(i_link_lost)   fault[5] <= 1'b1;
            if(!magic_ok)     fault[10] <= 1'b1;
            if(o_dir == DIR_POS ? limf : limb) begin
               if(o_dir == DIR_POS) fault[1] <= 1'b1; else fault[2] <= 1'b1;
            end
         end
      end
   end

   ////////////////// positioner
   wire [31:0] qdec = q_max ? dec_max_eff : q_lim ? seg_lim_dec : seg_evt_dec;
   wire        hard_abort = abort_req;
   wire        pos_qstop  = q_evt || q_lim || q_max;
   wire        pos_pause  = ctl_pause && !stop_req && !pos_qstop && !hard_abort;

   wire         rc_start;
   wire [31:0]  rc_period;
   wire [31:0]  rc_number;
   wire         rc_dir;
   wire         rc_done;
   wire [31:0]  pos_dbg;
   wire         pm_pulse;
   wire         pm_dir;
   wire [31:0]  pg_period;

   Positioner_std #(.USE_ABORT(1), .BASE_REFCLK(CLK_HZ)) pos_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      .i_pf_spd       ( seg_spd            ),
      .i_pf_acc       ( seg_acc            ),
      .i_pf_dec       ( seg_dec            ),
      .i_pf_mode      ( seg_cont ? 32'h00 : 32'h01 ),
      .i_pf_start     ( pos_start          ),
      .i_pf_stop      ( stop_req           ),
      .i_pf_dir       ( seg_dir            ),
      .i_pf_pulse     ( seg_pulse          ),
      .i_quickstop    ( pos_qstop          ),
      .i_quickstop_dec( qdec               ),
      .i_abort        ( hard_abort         ),
      .i_pause        ( pos_pause          ),
      .o_pf_done      ( pos_done           ),
      .o_pf_error     ( pos_error          ),
      .o_pf_busy      ( pos_busy           ),
      .o_pulse_start  ( rc_start           ),
      .o_pulse_period ( rc_period          ),
      .o_pulse_number ( rc_number          ),
      .o_pulse_dir    ( rc_dir             ),
      .i_pulse_busy   ( pul_busy           ),
      .i_pulse_done   ( rc_done            ),
      .o_dbg          ( pos_dbg            )
   );

   Pulmot_fd #(.USE_PAUSE(1), .USE_ABORT(1)) pul_u
   (
      .clk              ( clk          ),
      .reset            ( reset        ),
      .i_bv_pulse_start ( rc_start     ),
      .i_bv_pulse_period( rc_period    ),
      .i_bv_pulse_number( rc_number    ),
      .i_bv_pulse_dir   ( rc_dir       ),
      .o_bv_pulse_done  ( rc_done      ),
      .o_bv_pulse_busy  ( pul_busy     ),
      .i_abort          ( hard_abort   ),
      .i_pause          ( 1'b0         ),
      .i_dv_ready       ( 1'b0         ),
      .i_dv_inp         ( 1'b0         ),
      .i_dv_phase_a     ( 1'b0         ),
      .i_dv_phase_b     ( 1'b0         ),
      .i_dv_phase_z     ( 1'b0         ),
      .o_dv_pulse_p     ( pm_pulse     ),
      .o_dv_pulse_n     ( pm_dir       ),
      .o_dbg_period     ( pg_period    )
   );

   ////////////////// velocity engine
   wire wv_pulse, wv_dir;
   Wheel_vel_std #(.BASE_REFCLK(CLK_HZ), .WDT_MS(16'hFFFF)) vel_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      .i_tick_1ms     ( tick_1ms           ),
      .i_vld          ( vel_vld            ),
      .i_spd          ( vel_spd            ),
      .i_allow        ( !seg_active && !pos_busy ),
      .i_hold         ( ctl_pause          ),
      .i_stop         ( ctl_qstop || beat_to || i_link_lost || !magic_ok ),
      .i_abort        ( !i_dv_ok || ext_abort || !ctl_son || (limf && limb) ),
      .i_acc          ( vel_acc            ),
      .i_dec          ( vel_dec            ),
      .i_qdec         ( (w10 != 0) ? w10 : vel_dec ),
      .i_spd_max      ( (w8 != 0) ? w8 : 32'hFFFF_FFFF ),
      .i_dir_init     ( pm_dir             ),
      .i_lim_f        ( limf               ),
      .i_lim_b        ( limb               ),
      .i_blk_f        ( soft_f             ),
      .i_blk_b        ( soft_b             ),
      .o_active       ( vel_active         ),
      .o_pulse        ( wv_pulse           ),
      .o_dir          ( wv_dir             )
   );

   assign o_pulse = vel_active ? wv_pulse : pm_pulse;
   assign o_dir   = vel_active ? wv_dir   : pm_dir;
   assign o_son   = (magic_ok && ctl_son) ? 1'b0 : 1'b1;
   assign o_rst   = (magic_ok && ctl_rst) ? 1'b0 : 1'b1;

   ////////////////// absolute position
   always @(posedge clk) pulse_d <= reset ? 1'b1 : o_pulse;
   always @(posedge clk) begin
      if(reset) begin
         abspos    <= 32'sd0;
         pos_valid <= 1'b0;
      end else if(abspos_set) begin
         abspos    <= w1;
         pos_valid <= 1'b1;
      end else if(o_pulse_rise)
         abspos <= (o_dir == DIR_POS) ? abspos + 1'b1 : abspos - 1'b1;
   end

   ////////////////// debug counters
   reg [7:0] dbg_cmd_cnt, dbg_rej_cnt, dbg_seg_cnt;
   reg       cmd_new_d;
   always @(posedge clk) begin
      cmd_new_d <= cmd_new;
      if(reset) begin
         dbg_cmd_cnt <= 8'd0; dbg_rej_cnt <= 8'd0; dbg_seg_cnt <= 8'd0;
      end else begin
         if(cmd_new)   dbg_cmd_cnt <= dbg_cmd_cnt + 1'b1;
         if(pos_start) dbg_seg_cnt <= dbg_seg_cnt + 1'b1;
         if(cmd_new_d && result != RS_OK) dbg_rej_cnt <= dbg_rej_cnt + 1'b1;
      end
   end

   ////////////////// s2m
   wire        busy = seg_active || vel_active;
   wire [31:0] s1 = {ack_seq, ack_op, result,
                     busy, st_done, st_error, st_trig, trig_cause,
                     ctl_pause && busy, vel_active, pos_valid, link_ok && seq_sync,
                     end_cause};
   wire [31:0] s5 = {24'd0, (w13[26:24] == 3'b000), !o_rst, o_dir, !o_son, i_dv_ok, org, limb, limf};
   wire [31:0] s12 = {pos_dbg[8:0], seg_active, seg_started, vel_active, stop_req, abort_req,
                      q_evt, q_lim, q_max, pos_busy, pul_busy, ctl_pause, ctl_stop, ctl_qstop,
                      seq_sync, link_ok, beat_to, magic_ok, i_link_lost, limf, limb, org, seg_dir, seg_cont};
   wire [31:0] s13 = {dbg_cmd_cnt, dbg_rej_cnt, dbg_seg_cnt, seq_last};

   assign o_s2m = {
      {MAGIC, ABI_MAJ, ABI_MIN},     // s15
      CAP,                           // s14
      s13,                           // s13
      s12,                           // s12
      32'd0, 32'd0, 32'd0, 32'd0,    // s11..s8
      seg_cnt,                       // s7
      {9'd0, pos_dbg[31:9]},         // s6 current speed
      s5,                            // s5
      cappos,                        // s4
      abspos,                        // s3
      {21'd0, fault},                // s2
      s1,                            // s1
      w0                             // s0
   };

endmodule
