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
   
   ,output reg signed [31:0]  r_pf_abspos
   ,input  wire [7:0]       cur_beha
   ,input  wire             rctrl_drive_on
   ,input  wire             rctrl_drive_reset
   ,input  wire             rserv_dir
   ,input  wire             rcfg_pf_mode
   ,input  wire [31:0]      rserv_step_pulse
   ,input  wire [31:0]      rserv_target_pulse   
   ,input  wire [15:0]      rcfg_home_spd
   ,input  wire [15:0]      rcfg_home_acc
   ,input  wire [15:0]      rcfg_home_dec
   ,input  wire [15:0]      rcfg_jog_spd
   ,input  wire [15:0]      rcfg_jog_acc
   ,input  wire [15:0]      rcfg_jog_dec
   ,input  wire [15:0]      rcfg_move_spd
   ,input  wire [15:0]      rcfg_move_acc
   ,input  wire [15:0]      rcfg_move_dec
   ,input  wire [15:0]      rcfg_spd_max
   ,input  wire [15:0]      rcfg_acc_max
   ,input  wire [15:0]      rcfg_dec_max
   ,input  wire [15:0]      rcfg_qs_dec
   ,input  wire [31:0]      rcfg_timedly

   ,input  wire             i_axis_limf     //forward limit
   ,input  wire             i_axis_limb     //backward limit
   ,input  wire             i_axis_org
   ,input  wire             i_axis_point
   ,input  wire             i_axis_abspos0
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

   reg          act_busy;
   reg          act_done;
   reg          act_error;
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
  
   Pulmot_fd Pulmot_fd00
   (
      .clk              ( clk                    ),
      .reset            ( reset                  ),
      
      .i_bv_pulse_start ( o_rc_pulse_start       ),
      .i_bv_pulse_period( o_rc_pulse_period      ),
      .i_bv_pulse_number( o_rc_pulse_number      ),
      .i_bv_pulse_dir   ( o_rc_pulse_dir         ),
      .o_bv_pulse_done  ( i_rc_pulse_done        ),

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
   wire [31:0]  pos_quickstop_dec = rcfg_qs_dec;
   reg          pos_quickstop;
   reg  [31:0]  pos_pf_mode;
   reg          pos_pf_start;
   reg          pos_pf_stop;
   reg          pos_pf_dir;
   reg  [31:0]  pos_pf_pulse;
   wire         pos_pf_busy;
   wire         pos_pf_done;
   wire         pos_pf_error;

   Positioner_std	pos_u
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
      .o_pf_done      ( pos_pf_done        ),
      .o_pf_error     ( pos_pf_error       ),
      .o_pf_busy      ( pos_pf_busy        ),
      .o_pulse_start  ( o_rc_pulse_start   ),
      .o_pulse_period ( o_rc_pulse_period  ),
      .o_pulse_number ( o_rc_pulse_number  ),
      .o_pulse_dir    ( o_rc_pulse_dir     ),
      .i_pulse_done   ( i_rc_pulse_done    )
   );
   
   ////////////////// HOME
   wire         home_start;
   reg          home_stop;
   wire         home_busy;
   wire         home_done;
   wire         home_error;
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
      
      .i_drv_son      ( action_son         ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( i_axis_org         ),
      .i_pf_spd       ( rcfg_home_spd      ),
      .i_pf_acc       ( rcfg_home_acc      ),
      .i_pf_dec       ( rcfg_home_dec      ),
      .i_pf_dir       ( DIR_NEG            ),
      .i_start        ( home_start    	   ),
      .i_stop         ( home_stop          ),
      .o_busy         ( home_busy          ),
      .o_done         ( home_done          ),
      .o_error        ( home_error         ),
      .o_pf_spd       ( home_pf_spd        ),
      .o_pf_acc       ( home_pf_acc        ),
      .o_pf_dec       ( home_pf_dec        ),
      .o_pf_pulse     ( home_pf_pulse      ),
      .o_pf_dir       ( home_pf_dir        ),
      .o_pf_start     ( home_pf_start      ),
      .o_pf_stop      ( home_pf_stop       ),
      .o_pf_quickstop ( home_pf_quickstop  ),
      .i_pf_busy      ( pos_pf_busy        ),
      .i_pf_done      ( pos_pf_done        )
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
      
      .i_drv_son      ( action_son         ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( i_axis_org         ),
      .i_pf_spd       ( rcfg_jog_spd       ),
      .i_pf_acc       ( rcfg_jog_acc       ),
      .i_pf_dec       ( rcfg_jog_dec       ),
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
      
      .i_drv_son      ( action_son         ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( i_axis_org         ),
      .i_abspos       ( r_pf_abspos        ),
      .i_pf_spd       ( rcfg_move_spd      ),
      .i_pf_acc       ( rcfg_move_acc      ),
      .i_pf_dec       ( rcfg_move_dec      ),
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
  assign home_start = (action_son & action_start & cur_beha==1) ? 1'b1 : 1'b0;
  assign jog_start  = (action_son & action_start & ((cur_beha==2)||(cur_beha==20))) ? 1'b1 : 1'b0;
  assign move_start = (action_son & action_start & ((cur_beha==3)||(cur_beha==21))) ? 1'b1 : 1'b0;

  always @(posedge clk)begin
      case(cur_beha)
              1: begin
                  act_busy  <= home_busy;
                  act_done  <= home_done;
                  act_error <= home_error;
                  home_stop <= (action_alarm | beat_timeout | action_flag);
              end
              2, 20: begin  // JOG (regular & safe)
                  act_busy  <= jog_busy;
                  act_done  <= jog_done;
                  act_error <= jog_error;
                  jog_stop  <= (action_alarm | beat_timeout | action_flag);
              end
              3, 21: begin  // MOVE (regular & safe)
                  act_busy  <= move_busy;
                  act_done  <= move_done;
                  act_error <= move_error;
                  move_stop <= (action_alarm | beat_timeout | action_flag);
              end
              30: begin  // GETPOS: no motion, claim done immediately
                  act_busy  <= 1'b0;
                  act_done  <= action_start;
                  act_error <= 1'b0;
              end
              default: begin
                  act_busy <= 1'b0;
                  act_done <= 1'b0;
                  act_error <= 1'b0;
              end
          endcase
      end

  always@* begin
      case(cur_beha)
              1: begin
                  pos_pf_spd   <= home_pf_spd > rcfg_spd_max ? rcfg_spd_max : home_pf_spd;
                  pos_pf_acc   <= home_pf_acc > rcfg_acc_max ? rcfg_acc_max : home_pf_acc;
                  pos_pf_dec   <= home_pf_dec > rcfg_dec_max ? rcfg_dec_max : home_pf_dec;
                  pos_pf_mode  <= rcfg_pf_mode ? 8'h10 : 8'h00;
                  pos_pf_pulse <= home_pf_pulse;
                  pos_pf_start <= home_pf_start;
                  pos_pf_stop  <= home_pf_stop;
                  pos_pf_dir   <= home_pf_dir;
                  pos_quickstop<= home_pf_quickstop;
              end
              2, 20: begin
                  pos_pf_spd   <= jog_pf_spd > rcfg_spd_max ? rcfg_spd_max : jog_pf_spd;
                  pos_pf_acc   <= jog_pf_acc > rcfg_acc_max ? rcfg_acc_max : jog_pf_acc;
                  pos_pf_dec   <= jog_pf_dec > rcfg_dec_max ? rcfg_dec_max : jog_pf_dec;
                  pos_pf_mode  <= rcfg_pf_mode ? 8'h11 : 8'h01;
                  pos_pf_pulse <= jog_pf_pulse;
                  pos_pf_start <= jog_pf_start;
                  pos_pf_stop  <= jog_pf_stop;
                  pos_pf_dir   <= jog_pf_dir;
                  pos_quickstop<= jog_pf_quickstop;
              end
              3, 21: begin
                  pos_pf_spd   <= move_pf_spd > rcfg_spd_max ? rcfg_spd_max : move_pf_spd;
                  pos_pf_acc   <= move_pf_acc > rcfg_acc_max ? rcfg_acc_max : move_pf_acc;
                  pos_pf_dec   <= move_pf_dec > rcfg_dec_max ? rcfg_dec_max : move_pf_dec;
                  pos_pf_mode  <= rcfg_pf_mode ? 8'h11 : 8'h01;
                  pos_pf_pulse <= move_pf_pulse;
                  pos_pf_start <= move_pf_start;
                  pos_pf_stop  <= move_pf_stop;
                  pos_pf_dir   <= move_pf_dir;
                  pos_quickstop<= move_pf_quickstop;
              end
              default: begin  // 30: no motion
                  pos_pf_spd   <= 0;
                  pos_pf_acc   <= 0;
                  pos_pf_dec   <= 0;
                  pos_pf_mode  <= 0;
                  pos_pf_pulse <= 0;
                  pos_pf_start <= 1'b0;
                  pos_pf_stop  <= 1'b0;
                  pos_pf_dir   <= 1'b0;
                  pos_quickstop<= 1'b0;
              end
          endcase
  end
   
   ////////////////// Absolute Position (Pulse)
  always@(posedge clk) begin
      if(reset) begin
          r_pf_abspos <= 0;
      end else if(action_son) begin
          if(i_axis_abspos0 | (home_done & ~home_busy & ~home_error)) begin
              r_pf_abspos <= 0;
          end else if(i_rc_pulse_done) begin
              r_pf_abspos <= (o_rc_pulse_dir==DIR_POS) ? r_pf_abspos + 1'b1 : r_pf_abspos - 1'b1;
          end
      end
  end

endmodule




