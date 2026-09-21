/////////////////////////// INCLUDE /////////////////////////////

////////////////////////////////////////////////////////////////
//
//  Module  : slv_pul_axis
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2023/01/13
//
////////////////////////////////////////////////////////////////
//
//  Description:
//     behavior mapping (aligned with master ec_pul_axis):
//       1 = HOME
//       2 = JOG
//       3 = MOVE
//      20 = JOG [safe]
//      21 = MOVE [safe]
//      30 = GETPOS
//
//     Receives cur_beha from m2s message (proactive_beh_slv_pul_axis)
//     and executes the corresponding motion.
//
////////////////////////////////////////////////////////////////
//
//  Revision: 1.1 — behavior numbering aligned with ec_pul_axis

/////////////////////////// DEFINE /////////////////////////////

/////////////////////////// MODULE //////////////////////////////
module slv_pul_axis
#(
    parameter  P_MODULE_ID    = 8'd7
)
(
    input                    clk
   ,input                    reset

   ,input  wire             action_flag 
   ,input  wire             action_alarm
   ,input  wire             action_start
   ,input  wire             action_son
   ,input  wire             action_beat
   ,output wire             device_alarm
   ,output wire             device_beat
   ,output wire             action_error
   ,output wire             action_busy
   ,output wire             action_done
   ,output wire             pulse_done
   ,output wire             action_ack
   
   ,output reg signed [31:0]  r_pf_abspos
   ,input  wire [7:0]       cur_beha
   ,input  wire             rctrl_drive_on
   ,input  wire             rctrl_drive_reset
   ,input  wire             rserv_dir
   ,input  wire             rcfg_pf_mode
   ,input  wire [31:0]      rserv_step_pulse
   ,input  wire [31:0]      rserv_target_pulse   
   ,input  wire [31:0]      rcfg_home_spd
   ,input  wire [31:0]      rcfg_home_acc
   ,input  wire [31:0]      rcfg_home_dec
   ,input  wire [31:0]      rcfg_jog_spd
   ,input  wire [31:0]      rcfg_jog_acc
   ,input  wire [31:0]      rcfg_jog_dec
   ,input  wire [31:0]      rcfg_move_spd
   ,input  wire [31:0]      rcfg_move_acc
   ,input  wire [31:0]      rcfg_move_dec
   ,input  wire [31:0]      rcfg_spd_max
   ,input  wire [31:0]      rcfg_acc_max
   ,input  wire [31:0]      rcfg_dec_max
   ,input  wire [31:0]      rcfg_touch_spd

   ,input  wire             i_axis_limf     //forward limit
   ,input  wire             i_axis_limb     //backward limit
   ,input  wire             i_axis_zero
   ,input  wire             i_axis_abspos0
   ,input  wire             i_pause
   ,input  wire             i_servo_ready
   ,input  wire             i_servo_done
   ,input  wire             i_home_valid
   ,output reg [7:0]         alarm_code
   ,input  wire             i_device_alarm
   ,output wire             o_device_pulse
   ,output wire             o_device_dir
   ,output wire             o_device_reset
   ,output wire             o_device_son 
);
   
   ///////////////// PARAMETER ////////////////
    localparam P_SPD_MIN    	  = 32'd5000;      // pulse/s
    localparam DIR_POS  	      = 1'b1;
    localparam DIR_NEG    	      = 1'b0;
    localparam P_EN_EFF     	  = 1'b0;
    localparam P_RST_EFF    	  = 1'b0;

    wire [31:0] home_spd_eff  = (rcfg_home_spd == 32'b0 ) ? 32'd1000000 : rcfg_home_spd  ;
    wire [31:0] home_acc_eff  = (rcfg_home_acc == 32'b0 ) ? 32'd2500000 : rcfg_home_acc  ;
    wire [31:0] home_dec_eff  = (rcfg_home_dec == 32'b0 ) ? 32'd2500000 : rcfg_home_dec  ;
    wire [31:0] jog_spd_eff   = (rcfg_jog_spd  == 32'b0 ) ? 32'd1000000 : rcfg_jog_spd   ;
    wire [31:0] jog_acc_eff   = (rcfg_jog_acc  == 32'b0 ) ? 32'd2500000 : rcfg_jog_acc   ;
    wire [31:0] jog_dec_eff   = (rcfg_jog_dec  == 32'b0 ) ? 32'd2500000 : rcfg_jog_dec   ;
    wire [31:0] move_spd_eff  = (rcfg_move_spd == 32'b0 ) ? 32'd1000000 : rcfg_move_spd  ;
    wire [31:0] move_acc_eff  = (rcfg_move_acc == 32'b0 ) ? 32'd2500000 : rcfg_move_acc  ;
    wire [31:0] move_dec_eff  = (rcfg_move_dec == 32'b0 ) ? 32'd2500000 : rcfg_move_dec  ;
    wire [31:0] spd_max_eff   = (rcfg_spd_max  == 32'b0 ) ? 32'd4000000 : rcfg_spd_max   ;
    wire [31:0] acc_max_eff   = (rcfg_acc_max  == 32'b0 ) ? 32'd10000000: rcfg_acc_max   ;
    wire [31:0] dec_max_eff   = (rcfg_dec_max  == 32'b0 ) ? 32'd10000000: rcfg_dec_max   ;
    wire [31:0] touch_spd_eff = (rcfg_touch_spd== 32'b0 ) ? 32'd5000    : rcfg_touch_spd ;

   reg motion_done_latched;
   reg          act_busy;
   reg          act_done;
   reg          act_error;
   reg          action_start_d;
   reg          action_ack_r;
   reg          beat_timeout;
   reg [31:0]   slv_beat_cnt;
   reg          action_beat_d;
   
   assign o_device_son = rctrl_drive_on ? P_EN_EFF : ~P_EN_EFF;
   assign o_device_reset = rctrl_drive_reset ? P_RST_EFF : ~P_RST_EFF;
   assign device_alarm = i_device_alarm;
   assign device_beat = ~action_flag & action_beat;
   assign action_busy = act_busy;
   assign action_error = act_error;
   assign action_done = (act_done & ~act_error) ? 1'b1 : 1'b0;
   assign action_ack = action_ack_r;
   assign pulse_done = motion_done_latched && !act_error;
   wire action_start_pulse = action_start & ~action_start_d;
   wire drive_ok = i_device_alarm && i_servo_ready;
   wire is_move = cur_beha == 3 || cur_beha == 21;
   wire start_ok = drive_ok && action_son && (!is_move || i_home_valid);
   wire stop_request = action_alarm || beat_timeout || action_flag || !action_son;
   wire hard_abort;
   wire motion_pause = i_pause && !stop_request && !hard_abort;

   always @(posedge clk)begin
       if(reset)begin
           slv_beat_cnt  <= 0;
           action_beat_d <= 1'b0;
           beat_timeout  <= 1'b0;
       end else if(action_beat_d != action_beat) begin
           slv_beat_cnt  <= 0;
           action_beat_d <= action_beat;
           beat_timeout  <= 1'b0;
       end else if(~beat_timeout) begin
           slv_beat_cnt <= slv_beat_cnt + 1'b1;
           action_beat_d <= action_beat;
           if(slv_beat_cnt == 20000000) begin  //200ms
               beat_timeout <= 1'b1;
           end
       end
   end

   wire         o_rc_pulse_start;
   wire [31:0]  o_rc_pulse_period;
   wire [31:0]  o_rc_pulse_number;
   wire         o_rc_pulse_dir;
   wire         i_rc_pulse_done;
   wire         i_rc_dbestop;
   wire         i_rc_pulse_busy;
  
   Pulmot_fd #(.USE_PAUSE(1), .USE_ABORT(1)) Pulmot_fd00
   (
      .clk              ( clk                    ),
      .reset            ( reset                  ),
      
      .i_bv_pulse_start ( o_rc_pulse_start ),
      .i_bv_pulse_period( o_rc_pulse_period      ),
      .i_bv_pulse_number( o_rc_pulse_number      ),
      .i_bv_pulse_dir   ( o_rc_pulse_dir         ),
      .o_bv_pulse_done  ( i_rc_pulse_done        ),
      .o_bv_pulse_busy  ( i_rc_pulse_busy ),
      .i_abort          ( hard_abort ),
      .i_pause          ( 1'b0 ),

      .i_dv_ready       ( 1'b0                   ),
      .i_dv_inp         ( 1'b0                   ),
      .i_dv_phase_a     ( 1'b0                   ),
      .i_dv_phase_b     ( 1'b0                   ),
      .i_dv_phase_z     ( 1'b0                   ),
      .o_dv_pulse_p     ( o_device_pulse         ),
      .o_dv_pulse_n     ( o_device_dir           )
   );
  
  ////////////////// Positioner
   reg  [31:0]  pos_pf_spd;
   reg  [31:0]  pos_pf_acc;
   reg  [31:0]  pos_pf_dec;
   wire home_pf_touchstop;
   wire [32:0] touch_dec_2x = {home_dec_eff, 1'b0};
   wire [31:0] pos_quickstop_dec = home_pf_touchstop ?
       ((touch_dec_2x > {1'b0,dec_max_eff}) ? dec_max_eff : touch_dec_2x[31:0]) : dec_max_eff;
   reg          pos_quickstop;
   reg  [31:0]  pos_pf_mode;
   reg          pos_pf_start;
   reg          pos_pf_stop;
   reg          pos_pf_dir;
   reg  [31:0]  pos_pf_pulse;
   wire         pos_pf_busy;
   wire         pos_pf_done;
   wire         pos_pf_error;

   assign hard_abort = !drive_ok || (i_axis_limf && pos_pf_dir) || (i_axis_limb && !pos_pf_dir);
   Positioner_std #(.USE_ABORT(1), .BASE_REFCLK(100_000_000)) pos_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      .i_pf_spd       ( pos_pf_spd         ),
      .i_pf_acc       ( pos_pf_acc         ),
      .i_pf_dec       ( pos_pf_dec         ),
      .i_pf_mode      ( pos_pf_mode        ),
      .i_pf_start     ( pos_pf_start       ),
      .i_pf_stop      ( pos_pf_stop        ),
      .i_pf_dir       ( pos_pf_dir         ),
      .i_pf_pulse     ( pos_pf_pulse       ),
      .i_quickstop    ( pos_quickstop      ),
      .i_quickstop_dec( pos_quickstop_dec  ),
      .i_abort        ( hard_abort ),
      .i_pause        ( motion_pause            ),
      .o_pf_done      ( pos_pf_done        ),
      .o_pf_error     ( pos_pf_error       ),
      .o_pf_busy      ( pos_pf_busy        ),
      .o_pulse_start  ( o_rc_pulse_start   ),
      .o_pulse_period ( o_rc_pulse_period  ),
      .o_pulse_number ( o_rc_pulse_number  ),
      .o_pulse_dir    ( o_rc_pulse_dir     ),
      .i_pulse_busy   ( i_rc_pulse_busy ),
      .i_pulse_done   ( i_rc_pulse_done    )
   );
   
   ////////////////// HOME
   wire         home_start;
   reg          home_stop;
   wire         home_busy;
   wire         home_done;
   wire         home_error;
   wire         home_limit_recover;
   wire [31:0]  home_pf_spd;
   wire [31:0]  home_pf_acc;
   wire [31:0]  home_pf_dec;
   wire [31:0]  home_pf_pulse;
   wire         home_pf_dir;
   wire         home_pf_start;
   wire         home_pf_stop;
   wire         home_pf_quickstop;

   Home_fa_std
   home_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      
      .i_drv_son      ( drive_ok         ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( i_axis_zero         ),
      .i_pf_spd       ( home_spd_eff       ),
      .i_pf_acc       ( home_acc_eff       ),
      .i_pf_dec       ( home_dec_eff       ),
      .i_pf_dir       ( DIR_NEG            ),
      .i_start        ( home_start    	   ),
      .i_stop         ( home_stop          ),
      .o_busy         ( home_busy          ),
      .o_done         ( home_done          ),
      .o_error        ( home_error         ),
      .o_limit_recover( home_limit_recover ),
      .o_pf_spd       ( home_pf_spd        ),
      .o_pf_acc       ( home_pf_acc        ),
      .o_pf_dec       ( home_pf_dec        ),
      .o_pf_pulse     ( home_pf_pulse      ),
      .o_pf_dir       ( home_pf_dir        ),
      .o_pf_start     ( home_pf_start      ),
      .o_pf_stop      ( home_pf_stop       ),
      .o_pf_quickstop ( home_pf_quickstop  ),
      .o_pf_touchstop ( home_pf_touchstop ),
      .i_pf_busy      ( pos_pf_busy        ),
      .i_pf_done      ( pos_pf_done        ),
      .i_spd_min      ( touch_spd_eff      )
   );
   
   ////////////////// JOG
   wire         jog_start;
   reg          jog_stop;
   wire         jog_busy;
   wire         jog_done;
   wire         jog_error;
   wire [31:0]  jog_pf_spd;
   wire [31:0]  jog_pf_acc;
   wire [31:0]  jog_pf_dec;   
   wire [31:0]  jog_pf_pulse;  
   wire         jog_pf_dir;
   wire         jog_pf_start;
   wire         jog_pf_stop;
   wire         jog_pf_quickstop;
   
   Jog_fa_std	jog_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      
      .i_drv_son      ( drive_ok               ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( i_axis_zero         ),
      .i_pf_spd       ( jog_spd_eff        ),
      .i_pf_acc       ( jog_acc_eff        ),
      .i_pf_dec       ( jog_dec_eff        ),
      .i_pf_pulse     ( rserv_step_pulse   ),
      .i_pf_dir       ( rserv_dir          ),
      .i_start        ( jog_start   	   ),
      .i_stop         ( jog_stop           ),
      .o_busy         ( jog_busy           ),
      .o_done         ( jog_done           ),
      .o_error        ( jog_error          ),
      .o_pf_spd       ( jog_pf_spd         ),
      .o_pf_acc       ( jog_pf_acc         ),
      .o_pf_dec       ( jog_pf_dec         ),
      .o_pf_pulse     ( jog_pf_pulse       ),
      .o_pf_dir       ( jog_pf_dir         ),
      .o_pf_start     ( jog_pf_start       ),
      .o_pf_stop      ( jog_pf_stop        ),
      .o_pf_quickstop ( jog_pf_quickstop   ),
      .i_pf_busy      ( pos_pf_busy        ),
      .i_pf_done      ( pos_pf_done        )
   );
   
   ////////////////// MOVE
   wire         move_start;
   reg          move_stop;
   wire         move_busy;
   wire         move_done;
   wire         move_error;
   wire [31:0]  move_pf_spd;
   wire [31:0]  move_pf_acc;
   wire [31:0]  move_pf_dec;  
   wire [31:0]  move_pf_pulse;   
   wire         move_pf_dir;
   wire         move_pf_start;
   wire         move_pf_stop;
   wire         move_pf_quickstop;

   Move_fa_std	move_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      
      .i_drv_son      ( drive_ok         ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( i_axis_zero         ),
      .i_abspos       ( r_pf_abspos        ),
       .i_pf_spd      ( move_spd_eff       ),
       .i_pf_acc      ( move_acc_eff       ),
       .i_pf_dec      ( move_dec_eff       ),
      .i_pf_pulse     ( rserv_target_pulse ),
      .i_start        ( move_start     	   ),
      .i_stop         ( move_stop          ),
      .o_busy         ( move_busy          ),
      .o_done         ( move_done          ),
      .o_error        ( move_error         ),
      .o_pf_spd       ( move_pf_spd        ),
      .o_pf_acc       ( move_pf_acc        ),
      .o_pf_dec       ( move_pf_dec        ),
      .o_pf_pulse     ( move_pf_pulse      ),
      .o_pf_dir       ( move_pf_dir        ),
      .o_pf_start     ( move_pf_start      ),
      .o_pf_stop      ( move_pf_stop       ),
      .o_pf_quickstop ( move_pf_quickstop  ),
      .i_pf_busy      ( pos_pf_busy        ),
      .i_pf_done      ( pos_pf_done        )
   );

  //behavior mapping (aligned with master ec_pul_axis):
  //  1=HOME  2=JOG  3=MOVE  20=JOG[safe]  21=MOVE[safe]  30=GETPOS
  assign home_start = (start_ok & !stop_request & action_start_pulse & (cur_beha==1)) ? 1'b1 : 1'b0;
  assign jog_start  = (start_ok & !stop_request & action_start_pulse & ((cur_beha==2)||(cur_beha==20))) ? 1'b1 : 1'b0;
  assign move_start = (start_ok & !stop_request & action_start_pulse & ((cur_beha==3)||(cur_beha==21))) ? 1'b1 : 1'b0;

  always @(posedge clk)begin
      if(reset) begin
          act_busy      <= 1'b0;
          act_done      <= 1'b0;
          act_error     <= 1'b0;
          action_start_d<= 1'b0;
          action_ack_r  <= 1'b0;
          motion_done_latched <= 0;
          alarm_code <= 0;
          home_stop     <= 1'b0;
          jog_stop      <= 1'b0;
          move_stop     <= 1'b0;
      end else begin
          action_start_d <= action_start;
          if(action_start_pulse) begin
              act_done  <= 1'b0;
              act_error <= 1'b0;
              action_ack_r <= ~action_ack_r;
              motion_done_latched <= 0;
              alarm_code <= 0;
              if(!start_ok || stop_request) begin
                  act_error <= 1;
                  alarm_code <= !i_device_alarm ? 108 : !i_servo_ready ? 113 :
                                !action_son ? 115 : !i_home_valid && is_move ? 114 : 106;
              end
          end
          case(cur_beha)
              1: begin
                  act_busy  <= home_busy;
                  if(home_done)  motion_done_latched <= 1'b1;
                  if(home_error) begin act_error <= 1'b1; if(alarm_code == 0) alarm_code <= 120; end
                  home_stop <= stop_request;
                  jog_stop  <= 1'b0;
                  move_stop <= 1'b0;
              end
              2, 20: begin  // JOG (regular & safe)
                  act_busy  <= jog_busy;
                  if(jog_done)  motion_done_latched <= 1'b1;
                  if(jog_error) begin act_error <= 1'b1; if(alarm_code == 0) alarm_code <= i_axis_limf ? 109 : i_axis_limb ? 110 : 121; end
                  jog_stop  <= stop_request;
                  home_stop <= 1'b0;
                  move_stop <= 1'b0;
              end
              3, 21: begin  // MOVE (regular & safe)
                  act_busy  <= move_busy;
                  if(move_done)  motion_done_latched <= 1'b1;
                  if(move_error) begin act_error <= 1'b1; if(alarm_code == 0) alarm_code <= i_axis_limf ? 109 : i_axis_limb ? 110 : 122; end
                  move_stop <= stop_request;
                  home_stop <= 1'b0;
                  jog_stop  <= 1'b0;
              end
              30: begin  // GETPOS: no motion, claim done immediately
                  act_busy  <= 1'b0;
                  if(action_start_pulse) act_done <= 1'b1;
                  home_stop <= 1'b0;
                  jog_stop  <= 1'b0;
                  move_stop <= 1'b0;
              end
              default: begin
                  act_busy <= 1'b0;
                  home_stop <= 1'b0;
                  jog_stop  <= 1'b0;
                  move_stop <= 1'b0;
              end
          endcase
          act_busy <= home_busy || jog_busy || move_busy || pos_pf_busy || i_rc_pulse_busy;
          if(!action_start_pulse) begin
              if(motion_done_latched && i_servo_done && !act_error)
                  act_done <= 1;
              if(act_busy && ((hard_abort && (!drive_ok || cur_beha != 1 || !home_limit_recover)) ||
                              beat_timeout || action_flag)) begin
                  act_error <= 1;
                  act_done <= 0;
                  if(alarm_code == 0)
                      alarm_code <= !i_device_alarm ? 108 : !i_servo_ready ? 113 :
                                    i_axis_limf ? 109 : i_axis_limb ? 110 :
                                    beat_timeout ? 117 : 119;
              end
          end
      end
  end

  always@* begin
      case(cur_beha)
              1: begin
                  pos_pf_spd   <= home_pf_spd > spd_max_eff ? spd_max_eff : home_pf_spd;
                  pos_pf_acc   <= home_pf_acc > acc_max_eff ? acc_max_eff : home_pf_acc;
                  pos_pf_dec   <= home_pf_dec > dec_max_eff ? dec_max_eff : home_pf_dec;
                  pos_pf_mode   = 32'h00;   // home
                  pos_pf_pulse <= home_pf_pulse;
                  pos_pf_start <= home_pf_start;
                  pos_pf_stop  <= home_pf_stop;
                  pos_pf_dir   <= home_pf_dir;
                  pos_quickstop<= home_pf_quickstop;
              end
              2, 20: begin
                  pos_pf_spd   <= jog_pf_spd > spd_max_eff ? spd_max_eff : jog_pf_spd;
                  pos_pf_acc   <= jog_pf_acc > acc_max_eff ? acc_max_eff : jog_pf_acc;
                  pos_pf_dec   <= jog_pf_dec > dec_max_eff ? dec_max_eff : jog_pf_dec;
                  pos_pf_mode   = 32'h01;   // jog
                  pos_pf_pulse <= jog_pf_pulse;
                  pos_pf_start <= jog_pf_start;
                  pos_pf_stop  <= jog_pf_stop;
                  pos_pf_dir   <= jog_pf_dir;
                  pos_quickstop<= jog_pf_quickstop;
              end
              3, 21: begin
                  pos_pf_spd   <= move_pf_spd > spd_max_eff ? spd_max_eff : move_pf_spd;
                  pos_pf_acc   <= move_pf_acc > acc_max_eff ? acc_max_eff : move_pf_acc;
                  pos_pf_dec   <= move_pf_dec > dec_max_eff ? dec_max_eff : move_pf_dec;
                  pos_pf_mode   = 32'h01;   // move
                  pos_pf_pulse <= move_pf_pulse;
                  pos_pf_start <= move_pf_start;
                  pos_pf_stop  <= move_pf_stop;
                  pos_pf_dir   <= move_pf_dir;
                  pos_quickstop<= move_pf_quickstop;
              end
              default: begin  // 30: no motion
                  pos_pf_spd   <= 32'b0;
                  pos_pf_acc   <= 32'b0;
                  pos_pf_dec   <= 32'b0;
                  pos_pf_mode  <= 32'b0;
                  pos_pf_pulse <= 32'b0;
                  pos_pf_start <= 1'b0 ;
                  pos_pf_stop  <= 1'b0 ;
                  pos_pf_dir   <= 1'b0 ;
                  pos_quickstop<= 1'b0 ;
              end
          endcase
  end
   
// absolute position tracking
reg home_pos_reset;
always@(posedge clk) begin
    if(reset || home_busy)
        home_pos_reset <= 1'b0;
    else if(home_done & ~home_busy & ~home_error)
        home_pos_reset <= 1'b1;
    else 
        home_pos_reset <= home_pos_reset;
end

   reg pulse_d;
   always @(posedge clk) pulse_d <= reset ? 1'b1 : o_device_pulse;
   wire pulse_rise = o_device_pulse && !pulse_d;
   ////////////////// Absolute Position (Pulse)
  always@(posedge clk) begin
      if(reset) begin
        r_pf_abspos <= 32'd0;
        end
     else begin
        if(home_done & ~home_busy & ~home_error & ~home_pos_reset)
            r_pf_abspos <= 32'd0;
        else if(pulse_rise)
            r_pf_abspos <= (o_device_dir == DIR_POS) ? r_pf_abspos + 1'b1 : r_pf_abspos - 1'b1;
        else
            r_pf_abspos <= r_pf_abspos;
        end
  end

endmodule




