`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/06/29 22:38:46
// Design Name: 
// Module Name: proactive_beh
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

module proactive_beh_slv_pul_axis#(
    parameter                 	BHA_NUM = 2   		//Number of active behaviors
   ,parameter        [31:0]     IO_MAP  = 32'h0700_0000	//slave io map (ABI v2 w13), default all remote
)(
    input                       clk_i
    ,input                      rst_i
    ,input                      i_time_1ms_vld      //ms pulse
    ,input                      i_time_1s_vld       //s pulse

    ,input      [BHA_NUM-1:0]   pre_sta_allow   	//Pre - sufficient condition satisfied signal. 0: Not satisfied. 1: Satisfied.
    ,input      [BHA_NUM-1:0]   post_sta_allow  	//Post - sufficient condition satisfied signal

	,input						a_en				//A enable
    ,input      [7:0]           a_bhv_id
    ,input                      a_bhv_vld
    ,input      [19:0]          a_tx_ot
    ,input      [31:0]          a_tx_result_rpt	
	,input						a_tx_result_vld
    ,output		                ec_cha_st
    ,output reg [7:0]           a_tx_id
    ,output reg	[7:0]           a_alm_num

	,output reg [7:0]      		a_bhv_id_r
	,output	reg	[31:0]			state_monitor_o
    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response


//----------------------------------------------------- user logic begin -----------------------------------------------------//
    ,input					    i_servo_ready       //servo ready
    ,input					    i_servo_done        //servo move done
    ,input					    i_axis_limf         //axis limit forward
    ,input					    i_axis_zero          //axis origin
    ,input					    i_axis_limb         //axis limit backward
    ,input					    i_emerge_stop_signal//emergency stop signal

   	,input  	                i_pause			    //motor pause (B channel beh 100)
   	,input  	                i_stop			    //motor stop (B channel beh 103)


    ,input      [4:0]           cur_slv_board_id    //current slave board id
    ,input      [4:0]           slv_board_id        //slave board id
    ,input						pul_motor_r_flag    //pul motor ready flag
    ,input						pul_motor_flag      //pul motor flag
    ,output wire [31:0] 			m2s_pulm_msg        //message  master to slave
    ,input 		[31:0] 			s2m_pulm_msg       	//message  slave to master
	//io port end
	//for post check start
    ,output wire                action_busy
    ,output wire                action_done
    ,output wire                action_error
    //for post check start end
	//register start
	,input						i_drive_on    	//enable servo
	,input						i_drive_reset 	//reset servo

	,input		[ 0:0]			rserv_dir         	//servo direction
	,input		[31:0]			rserv_step_pulse 	//servo step pulse
	,input		[31:0]			rserv_target_pulse	//servo target pulse
	,input		[31:0]			rcfg_home_spd     	//home speed
	,input		[31:0]			rcfg_home_acc     	//home acceleration
	,input		[31:0]			rcfg_home_dec     	//home deceleration
	,input		[31:0]			rcfg_jog_spd      	//jog speed
	,input		[31:0]			rcfg_jog_acc      	//jog acceleration
	,input		[31:0]			rcfg_jog_dec      	//jog deceleration
	,input		[31:0]			rcfg_move_spd     	//move speed
	,input		[31:0]			rcfg_move_acc     	//move acceleration
	,input		[31:0]			rcfg_move_dec     	//move deceleration
	,input		[31:0]			rcfg_spd_max      	//maximum speed
	,input		[31:0]			rcfg_acc_max      	//maximum acceleration
	,input		[31:0]			rcfg_dec_max      	//maximum deceleration
	,input		[31:0]			rcfg_touch_dec     	//home org touch deceleration
	,input		[31:0]			rcfg_touch_spd     	//home creep speed after org touch
	,input		[31:0]			rcfg_s_time = 32'd0	//S-curve jerk time ms, 0 = T-curve
	,input signed [31:0]		rcfg_pos_max = 32'sd0	// signed upper soft limit
	,input signed [31:0]		rcfg_pos_min = 32'sd0	// signed lower soft limit

	,output wire signed [31:0]			r_pf_abspos //postion
	,output wire						dv_alarm //remote drive alm
	,output wire				o_soft_lim_f
	,output wire				o_soft_lim_b

    ,input wire i_home_completed
    ,input wire i_drive_enabled
    ,input wire [31:0]          i_wheel_spd         //signed pulse/s (PARAM38) -> m2s word9
    ,input wire                 i_wheel_vld         //PARAM38 write strobe
    ,output wire [31:0]         dbg_s2m_o       // {s2m frame cnt, s2m word10}
    ,output wire [31:0]         dbg_ctl_o       // {m2s frame cnt, stop_frame_cnt, ctrl flags}
    ,output wire [31:0]         dbg_m2s_w0_o    // m2s word0 being sent
    ,output wire [31:0]         dbg_s2m_w0_o    // slave echo of received word0
    ,output wire [31:0]         dbg_s2m_w12_o   // slave debug words 12..15
    ,output wire [31:0]         dbg_s2m_w13_o
    ,output wire [31:0]         dbg_s2m_w14_o
    ,output wire [31:0]         dbg_s2m_w15_o
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );




    wire       seq_busy;
    wire       seq_done;
    wire       seq_error;
    wire       seq_accepted;
    wire [7:0] seq_alm;
    wire       link_ready;
    wire       abi_bad;
    wire [31:0] st_s1;
    reg        seq_owned;       // current behavior started the sequencer
    reg pulse_done_latched;
    wire is_move = (a_bhv_id_r == 3) || (a_bhv_id_r == 21);
    wire is_motion = is_move || (a_bhv_id_r == 1) || (a_bhv_id_r == 2) || (a_bhv_id_r == 20);
    wire wheel_active = st_s1[6];   // slave velocity mode owns pulse
    wire limits_enabled = rcfg_pos_max > rcfg_pos_min;
    wire target_over_f = is_move && limits_enabled && ($signed(rserv_target_pulse) > rcfg_pos_max);
    wire target_over_b = is_move && limits_enabled && ($signed(rserv_target_pulse) < rcfg_pos_min);
    wire [7:0] launch_alarm = !link_ready ? (abi_bad ? 8'd123 : 8'd119) :
                              !dv_alarm ? 8'd108 :
                              !i_servo_ready ? 8'd113 :
                              !i_drive_enabled ? 8'd115 :
                              wheel_active ? 8'd118 :
                              target_over_f ? 8'd111 : target_over_b ? 8'd112 :
                              (is_move && !i_home_completed) ? 8'd114 : 8'd0;
    wire launch_fault = is_motion && (launch_alarm != 0);
    wire launch_ok = !launch_fault && !i_stop && i_emerge_stop_signal;
    //108 Drive alarm
    //109 Forward limit
    //110 Backward limit
    //111 Forward soft limit
    //112 Backward soft limit
    //113 Servo not ready
    //114 Move not homed
    //115 Drive disabled
    //118 Handwheel active
    //119 Slave link down
    //123 Slave ABI mismatch

    reg [7:0]    	curr_state;
	reg [7:0]    	curr_state_1d;
    reg [7:0]    	next_state;

    reg         	timout;
    reg [19:0]   	timout_cnt;
	
	reg [7:0]		ack_beh_id;
	reg [7:0]		ack_tx_id;
	reg [7:0]		ack_tx_result;
	reg	[7:0]		ack_ps_alart_num;
	reg				action_issued;
	wire			slv_stop_ready;
	wire	[7:0]	alert_next;
	
	
	//State machine state
	localparam  S_IDLE          = 8'd0; 	//idle
    localparam  S_BHA_PRE_DET	= 8'd1; 	//Pre-condition check
	localparam	S_READY_10		= 8'd2;		//ready
    localparam  S_READY_10_ACK  = 8'd3; 	//ready ok/no ok
	localparam	S_EXE			= 8'd5;		//Action execute
    localparam  S_BHA_POST_DET  = 8'd7; 	//Post-condition check
    localparam  S_SUCC_30       = 8'd8; 	//success
    localparam  S_SUCC_30_ACK	= 8'd9; 	//success ack
	localparam 	S_ALERT_40		= 8'd10;	//Alert
	localparam 	S_ALERT_40_ACK	= 8'd11;	//Alert ack
	localparam 	S_ACT_END_1		= 8'd12;
	localparam 	S_ACT_END_2		= 8'd13;
	localparam 	S_SLV_STOP_WAIT	= 8'd14;	//hold m2s stop until slave idle
	
    localparam  IRQ_OK          = 8'h51;	//ps ack:OK
    localparam  IRQ_NO_OK       = 8'h52;	//ps ack:NO OK
	
	//state monitor
	reg [7:0]	curr_state_m1;
	reg [7:0]	curr_state_m2;
	reg [7:0]	curr_state_m3;
	
    always @(posedge clk_i) 
	begin
        if (rst_i)begin
			curr_state_m1 <= 8'b0;
			curr_state_m2 <= 8'b0;
			curr_state_m3 <= 8'b0;
			state_monitor_o <= 32'b0;
			end
        else if ((curr_state != curr_state_m1) && (curr_state != S_ACT_END_1) && (curr_state != S_ACT_END_2)) begin
            curr_state_m1 <= curr_state;
            curr_state_m2 <= curr_state_m1;
            curr_state_m3 <= curr_state_m2;
			state_monitor_o <= {curr_state_m3,curr_state_m2,curr_state_m1, curr_state};
		end
    end
	
	always@(posedge clk_i)begin
	if(rst_i)begin
		ack_beh_id 	 	<=	8'd0;
		ack_tx_id	 	<=	8'd0;
		ack_tx_result	<=	8'd0;
		ack_ps_alart_num<=	8'd0;
	end else if(a_tx_result_vld)begin
		ack_beh_id 		<= 	a_tx_result_rpt[31:24];
		ack_tx_id		<= 	a_tx_result_rpt[23:16];
		ack_tx_result	<= 	a_tx_result_rpt[15:8];
		ack_ps_alart_num<=	a_tx_result_rpt[7:0];
	end else if(curr_state == S_IDLE)begin
		ack_beh_id 		<= 	8'd0;
		ack_tx_id		<= 	8'd0;
		ack_tx_result	<= 	8'd0;
		ack_ps_alart_num<=	8'd0;
	end else begin
		ack_beh_id 		<= 	ack_beh_id 	  ;
		ack_tx_id		<= 	ack_tx_id	  ;
		ack_tx_result	<= 	ack_tx_result  ;
		ack_ps_alart_num<=	ack_ps_alart_num;
		end
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
    reg			a_bhv_vld_r;
    reg	[1:0]	latch_sta;
	
	 //Current behavior number
    always@(posedge clk_i)begin
        if(rst_i)begin
            a_bhv_id_r <= 8'd0;
			a_bhv_vld_r <= 1'b0;
			latch_sta <= 0;
		end else 
			case(latch_sta)
				0:begin
					if(a_en && ((a_bhv_id >= 8'd1) && (a_bhv_id <= BHA_NUM)) && a_bhv_vld)begin
						a_bhv_id_r <= a_bhv_id;	//latch
						a_bhv_vld_r <= 1'b1;
						latch_sta <= 1;
					end else begin
						a_bhv_id_r <= 8'd0;
						a_bhv_vld_r <= 1'b0;
						latch_sta <= 0;
					end
				end
				1:begin
					a_bhv_id_r <= a_bhv_id_r;
					a_bhv_vld_r <= 1'b0;
					latch_sta <= 2;
				end
				2:begin
					if(curr_state == S_ACT_END_1)begin
						a_bhv_id_r <= 8'd0;
						a_bhv_vld_r <= 1'b0;
						latch_sta <= 0;
					end else begin
						a_bhv_id_r <= a_bhv_id_r;
						a_bhv_vld_r <= 1'b0;
						latch_sta <= 2;
					end
				end
				default:begin
					a_bhv_id_r <= 8'd0;
				    a_bhv_vld_r <= 1'b0;
					latch_sta <= 0;
				end
			endcase
		end
	
//------------------------------------------- FSM begin => Control 10/20/30/40 interrupt -----------------------------------------------//

	reg match_10;
	reg match_30;
	reg match_40;
	
	always @(posedge clk_i) begin
    if(rst_i) begin
        match_10 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
    end else if(curr_state == S_READY_10_ACK)
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == a_bhv_id_r);
	else begin
		match_10 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
	end
	end
    

    always @(posedge clk_i) begin
        if (rst_i)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end
	
    always @(*) begin			
        case (curr_state)	
            S_IDLE: begin			//curr_state = 0
               if (a_en && a_bhv_vld_r)	//behavior start
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end

            S_BHA_PRE_DET: begin	//curr_state = 1
				if(pre_sta_allow[a_bhv_id_r - 1'b1]) begin
					next_state = S_READY_10;
				end else if(timout) begin
					next_state = alert_next;			
				end else begin
					next_state = S_BHA_PRE_DET;
				end
            end

            S_READY_10: begin  		//curr_state = 2    					
				next_state = S_READY_10_ACK;				//Send 10 interrupt
            end

			S_READY_10_ACK: begin	//curr_state = 3
				if(match_10) 								//Transaction 10 Acknowledged OK
                    next_state = S_EXE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = alert_next;
                else
                    next_state = S_READY_10_ACK;
			end
			
			S_EXE:begin				//curr_state = 5								
				next_state = S_BHA_POST_DET;
			end
			
			
            S_BHA_POST_DET: begin	//curr_state = 7
				if(post_sta_allow[a_bhv_id_r - 1'b1] && (!is_motion || action_done) && !action_error && !timout) begin
                    	next_state = S_SUCC_30;
				end else if(timout | action_error) begin
                            next_state = alert_next;
				end else begin
					next_state = S_BHA_POST_DET;
				end
            end

            S_SUCC_30: begin		//curr_state = 8					
				next_state = S_SUCC_30_ACK;					//Send Interrupt 30
            end
			
			S_SUCC_30_ACK:begin		//curr_state = 9
				if(match_30)    							//30 response success
                    next_state = S_ACT_END_1;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = alert_next;
                else
                    next_state = S_SUCC_30_ACK;
			end

			// Stop the slave before IRQ 40 so PS sees a settled axis.
			S_SLV_STOP_WAIT:begin
				if(slv_stop_ready || timout)	// timeout exit, add by szzhang 20261012
					next_state = S_ALERT_40;
				else
					next_state = S_SLV_STOP_WAIT;
			end

            S_ALERT_40: begin		//curr_state = 10					
				next_state = S_ALERT_40_ACK;				//Send Interrupt 40
            end
			
			S_ALERT_40_ACK:begin	//curr_state = 11
				if(match_40 || timout) 						//40 Interrupt response
                    next_state = S_ACT_END_1;
                else
                    next_state = S_ALERT_40_ACK;
			end
			
			S_ACT_END_1:begin
				next_state = S_ACT_END_2;
			end
			
			S_ACT_END_2:begin
				next_state = S_IDLE;
			end
			
            default: begin
                next_state = S_IDLE;
            end

        endcase

		if((i_stop | ~i_emerge_stop_signal | launch_fault) && (curr_state > S_IDLE && curr_state < S_ALERT_40))
            next_state = alert_next;
    end
	
//----------------------------------------------------------- FSM end ------------------------------------------------------//

    //Channel A busy signal
	assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 30 40
    always@(posedge clk_i)begin
        if(rst_i || !a_en)
            a_tx_id <= 8'd0;
		else if(curr_state == S_IDLE)
			a_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        else if(curr_state == S_SUCC_30)
            a_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            a_tx_id <= 8'd40;
        else
            a_tx_id <= a_tx_id;
    end

    always@(posedge clk_i)begin
        if(rst_i || !a_en)
            irq_o <= 1'b0;
		else if(irq_ack_i)    		//interrupt arbiter receives the interrupt.
            irq_o <= 1'b0;
        else if(curr_state == S_READY_10)
            irq_o <= 1'b1;
		else if(curr_state == S_SUCC_30)
			irq_o <= 1'b1;
		else if(curr_state == S_ALERT_40)
			irq_o <= 1'b1;
        else
            irq_o <= irq_o;
    end

	wire w_soft_lim_f;
	wire w_soft_lim_b;
	wire w_sw_move;
	wire w_sw_fault;
    always @(posedge clk_i) begin
        if(rst_i || curr_state == S_IDLE) a_alm_num <= 0;
        else if(curr_state < S_ALERT_40 && (next_state == alert_next) && next_state != curr_state) begin
            if(is_motion && !link_ready) a_alm_num <= abi_bad ? 8'd123 : 8'd119; // Slave link
            else if(is_motion && !dv_alarm) a_alm_num <= 8'd108;     // Drive alarm
            else if(is_motion && !i_servo_ready) a_alm_num <= 8'd113;  // Servo not ready
            else if(seq_accepted && i_axis_limf) a_alm_num <= 8'd109;  // Forward limit
            else if(seq_accepted && i_axis_limb) a_alm_num <= 8'd110;  // Backward limit
            else if(i_stop) a_alm_num <= 8'd106;                       // Stop warning
            else if(!i_emerge_stop_signal) a_alm_num <= 8'd107;        // Emergency stop
            else if(launch_fault) a_alm_num <= launch_alarm;           // Launch fault
            else if(seq_owned && seq_error && seq_alm != 0)
                a_alm_num <= seq_alm;                                  // Slave/sequence alarm
            else if(curr_state == S_BHA_POST_DET && action_error)
                a_alm_num <= (a_bhv_id_r == 1) ? 8'd120 : is_move ? 8'd122 : 8'd121;
            else if(ack_tx_result == IRQ_NO_OK) a_alm_num <= ack_ps_alart_num; // PS alarm
            else if(curr_state == S_BHA_PRE_DET) a_alm_num <= 8'd100;  // Pre-check timeout
            else if(curr_state == S_READY_10_ACK) a_alm_num <= 8'd101; // Ready ACK timeout
            else if(curr_state == S_BHA_POST_DET) a_alm_num <= pulse_done_latched ? 8'd116 : 8'd102;
            else if(curr_state == S_SUCC_30_ACK) a_alm_num <= 8'd103;  // Success ACK timeout
            else a_alm_num <= 8'd105;
        end
    end
    // stop
    // emergency stop, add by szzhang 20260914
    // alarm, add by szzhang 20260916
    // HW +limit
    // HW -limit
    // SW +limit
    // SW -limit

    //Timeout count
    always@(posedge clk_i)begin
        if(rst_i || !a_en)
            timout_cnt <= 20'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 20'd0;
		else if(i_pause && curr_state < S_ALERT_40)	// pause must not block alarm-path timeouts
			timout_cnt <= timout_cnt;
        else if(timout_cnt > a_tx_ot)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
		else
			timout_cnt <= timout_cnt;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt > a_tx_ot)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
	
//==============================================================================================================================//
//----------------------------------------------------- user logic begin -----------------------------------------------------//
//==============================================================================================================================//
// behavior flags in S_EXE

		reg        action_alarm;
		reg [3:0]  stop_frame_cnt;

		// Slave board ABI v2 lives in pul_axis_link_if; behaviors are segment
		// sequences in pul_axis_seq (doc/pul_axis_seg_abi_v2.md).
		function [31:0] eff;
		    input [31:0] v, d;
		    eff = (v == 32'd0) ? d : v;
		endfunction
		wire [31:0] spd_max_eff   = eff(rcfg_spd_max,   32'd175000);	// defaults as v1 slave
		wire [31:0] acc_max_eff   = eff(rcfg_acc_max,   32'd875000);
		wire [31:0] dec_max_eff   = eff(rcfg_dec_max,   32'd875000);
		wire [31:0] touch_dec_eff = eff(rcfg_touch_dec, 32'd87500);
		wire [31:0] touch_spd_eff = eff(rcfg_touch_spd, 32'd2000);
		wire        is_home = (a_bhv_id_r == 8'd1);
		wire        is_jog  = (a_bhv_id_r == 8'd2) || (a_bhv_id_r == 8'd20);
		wire [31:0] seg_spd = eff(is_home ? rcfg_home_spd : is_move ? rcfg_move_spd : rcfg_jog_spd, 32'd8750);
		wire [31:0] seg_acc = eff(is_home ? rcfg_home_acc : is_move ? rcfg_move_acc : rcfg_jog_acc, 32'd175000);
		wire [31:0] seg_dec = eff(is_home ? rcfg_home_dec : is_move ? rcfg_move_dec : rcfg_jog_dec, 32'd175000);

		wire        ctl_stop = i_stop | ~i_emerge_stop_signal | ~a_en | action_alarm;
		wire        soft_en  = limits_enabled && i_home_completed && !is_home && !is_jog;
		wire [31:0] cfg_opt  = {rcfg_s_time[15:0], 8'd0, 6'd0, (rcfg_s_time[15:0] != 0) && !is_home, soft_en};

		// command channel: sequencer while busy, else handwheel VEL
		wire        seq_cmd_req;
		wire [3:0]  seq_cmd_op;
		wire [31:0] seq_cmd_arg, seq_cmd_spd, seq_cmd_acc, seq_cmd_dec, seq_cmd_evt, seq_cmd_evt_dec, seq_cmd_lim_dec;
		wire        cmd_rdy, cmd_ack, cmd_timeout;
		wire [3:0]  cmd_result;
		wire        rx_commit;
		wire [31:0] st_s0, st_fault, st_io, st_s12, st_s13;
		wire [31:0] st_pos;
		wire [31:0] link_m2s_word0;
		wire        link_m2s_frame_start;
		wire [15:0] s2m_frm_cnt;
		wire [11:0] m2s_frm_cnt;

		reg  [31:0] wheel_spd_r;
		reg         wheel_pend;
		reg         wheel_lock;
		wire        wheel_req = wheel_pend && cmd_rdy && !seq_busy;
		always@(posedge clk_i) begin
		    if(rst_i) begin
		        wheel_spd_r <= 32'd0; wheel_pend <= 1'b0; wheel_lock <= 1'b0;
		    end else begin
		        if(wheel_req) wheel_pend <= 1'b0;
		        if(ctl_stop && (wheel_active || wheel_pend)) begin
		            wheel_lock <= 1'b1;            // stop: hold until a 0 write
		            wheel_pend <= 1'b0;
		        end else if(i_wheel_vld) begin
		            if(i_wheel_spd == 32'd0) wheel_lock <= 1'b0;
		            if((i_wheel_spd == 32'd0 || !wheel_lock) && !(ec_cha_st && is_motion && !wheel_active)) begin
		                wheel_spd_r <= i_wheel_spd;
		                wheel_pend  <= 1'b1;
		            end
		        end
		    end
		end

		pul_axis_link_if pul_axis_link_if_u0(
		    .clk_i                 (clk_i),
		    .rst_i                 (rst_i),
		    .i_time_1ms_vld        (i_time_1ms_vld),
		    .cmd_req               (seq_cmd_req | wheel_req),
		    .cmd_op                (seq_busy ? seq_cmd_op      : 4'd3),
		    .cmd_arg               (seq_busy ? seq_cmd_arg     : wheel_spd_r),
		    .cmd_spd               (seq_busy ? seq_cmd_spd     : spd_max_eff),
		    .cmd_acc               (seq_busy ? seq_cmd_acc     : eff(rcfg_jog_acc, 32'd175000)),
		    .cmd_dec               (seq_busy ? seq_cmd_dec     : eff(rcfg_jog_dec, 32'd175000)),
		    .cmd_evt               (seq_busy ? seq_cmd_evt     : 32'd0),
		    .cmd_evt_dec           (seq_busy ? seq_cmd_evt_dec : 32'd0),
		    .cmd_lim_dec           (seq_busy ? seq_cmd_lim_dec : 32'd0),
		    .cmd_rdy               (cmd_rdy),
		    .cmd_ack               (cmd_ack),
		    .cmd_result            (cmd_result),
		    .cmd_timeout           (cmd_timeout),
		    .ctl_son               (~i_drive_on),       // b_son active low
		    .ctl_rst               (~i_drive_reset),    // b_reset active low
		    .ctl_pause             (i_pause),
		    .ctl_stop              (ctl_stop),
		    .ctl_qstop             (1'b0),
		    .ctl_ext_abort         (~i_servo_ready),
		    .io_limf               (i_axis_limf),
		    .io_limb               (i_axis_limb),
		    .io_org                (i_axis_zero),
		    .cfg_spd_max           (spd_max_eff),
		    .cfg_acc_max           (acc_max_eff),
		    .cfg_dec_max           (dec_max_eff),
		    .cfg_soft_max          (rcfg_pos_max),
		    .cfg_soft_min          (rcfg_pos_min),
		    .cfg_io_map            (IO_MAP),
		    .cfg_opt               (cfg_opt),
		    .link_ready            (link_ready),
		    .abi_bad               (abi_bad),
		    .rx_commit             (rx_commit),
		    .st_s0                 (st_s0),
		    .st_s1                 (st_s1),
		    .st_fault              (st_fault),
		    .st_pos                (st_pos),
		    .st_io                 (st_io),
		    .st_s12                (st_s12),
		    .st_s13                (st_s13),
		    .cur_slv_board_id      (cur_slv_board_id),
		    .slv_board_id          (slv_board_id),
		    .pul_motor_r_flag      (pul_motor_r_flag),
		    .pul_motor_flag        (pul_motor_flag),
		    .m2s_pulm_msg          (m2s_pulm_msg),
		    .s2m_pulm_msg          (s2m_pulm_msg),
		    .m2s_frame_start_o     (link_m2s_frame_start),
		    .m2s_word0_o           (link_m2s_word0),
		    .s2m_frame_count_o     (s2m_frm_cnt),
		    .m2s_frame_count_o     (m2s_frm_cnt)
		);

		pul_axis_seq pul_axis_seq_u0(
		    .clk_i                 (clk_i),
		    .rst_i                 (rst_i),
		    .i_start               (curr_state == S_EXE && launch_ok && is_motion),
		    .i_abort               (ctl_stop),
		    .i_cancel              (curr_state == S_ACT_END_1),
		    .i_bhv                 (a_bhv_id_r),
		    .i_dir                 (rserv_dir),
		    .i_step                (rserv_step_pulse),
		    .i_target              (rserv_target_pulse),
		    .i_spd                 (seg_spd),
		    .i_acc                 (seg_acc),
		    .i_dec                 (seg_dec),
		    .i_touch_spd           (touch_spd_eff),
		    .i_touch_dec           (touch_dec_eff),
		    .i_dec_max             (dec_max_eff),
		    .cmd_req               (seq_cmd_req),
		    .cmd_op                (seq_cmd_op),
		    .cmd_arg               (seq_cmd_arg),
		    .cmd_spd               (seq_cmd_spd),
		    .cmd_acc               (seq_cmd_acc),
		    .cmd_dec               (seq_cmd_dec),
		    .cmd_evt               (seq_cmd_evt),
		    .cmd_evt_dec           (seq_cmd_evt_dec),
		    .cmd_lim_dec           (seq_cmd_lim_dec),
		    .cmd_rdy               (cmd_rdy),
		    .cmd_ack               (cmd_ack),
		    .cmd_result            (cmd_result),
		    .cmd_timeout           (cmd_timeout),
		    .rx_commit             (rx_commit),
		    .st_s1                 (st_s1),
		    .st_fault              (st_fault),
		    .st_io                 (st_io),
		    .o_busy                (seq_busy),
		    .o_done                (seq_done),
		    .o_error               (seq_error),
		    .o_accepted            (seq_accepted),
		    .o_alm                 (seq_alm)
		);

		assign r_pf_abspos = st_pos;
		assign dv_alarm    = st_io[3];	// slave drive alarm input, 1 = normal

		wire w_soft_lim_en = (rcfg_pos_max > rcfg_pos_min) && (a_bhv_id_r != 8'd1);
		assign w_soft_lim_f = w_soft_lim_en && (r_pf_abspos >= rcfg_pos_max);
		assign w_soft_lim_b = w_soft_lim_en && (r_pf_abspos <= rcfg_pos_min);
		assign o_soft_lim_f = w_soft_lim_f;
		assign o_soft_lim_b = w_soft_lim_b;
		assign w_sw_move  = (a_bhv_id_r == 8'd3) || (a_bhv_id_r == 8'd21);
		assign w_sw_fault = target_over_f | target_over_b;

		always@(posedge clk_i) begin
		    if(rst_i || (curr_state == S_IDLE))
		        seq_owned <= 1'b0;
		    else if(curr_state == S_EXE && launch_ok && is_motion)
		        seq_owned <= 1'b1;
		end

        reg done_latched;

        always @(posedge clk_i) begin
            if(rst_i || a_bhv_vld_r || curr_state == S_EXE) begin
                done_latched <= 0;
                pulse_done_latched <= 0;
            end else begin
                if(seq_owned && seq_done) pulse_done_latched <= 1;
                if(seq_owned && seq_done && i_servo_done && !action_error)
                    done_latched <= 1;
                if(action_error) done_latched <= 0;
            end
        end
		assign action_busy  = seq_busy | st_s1[15];
		assign action_done  = done_latched;
		assign action_error = (seq_owned & seq_error) | w_sw_fault;
		reg stop_status_idle;
        always @(posedge clk_i) begin
            if(rst_i || curr_state != S_SLV_STOP_WAIT) stop_status_idle <= 0;
            else if(rx_commit && stop_frame_cnt >= 2)
                stop_status_idle <= !st_s1[15];
        end
        assign slv_stop_ready = stop_status_idle;
		assign alert_next     = action_issued ? S_SLV_STOP_WAIT : S_ALERT_40;

		always@(posedge clk_i) begin
		    if(rst_i || (curr_state == S_IDLE))
		        action_issued <= 1'b0;
		    else if(curr_state == S_EXE && launch_ok)
		        action_issued <= 1'b1;
		end

		always@(posedge clk_i) begin
		    if(rst_i || (curr_state == S_IDLE) || (curr_state == S_EXE))
		        stop_frame_cnt <= 4'd0;
		    else if(curr_state == S_SLV_STOP_WAIT) begin
		        if(link_m2s_frame_start && (stop_frame_cnt != 4'hF))
		            stop_frame_cnt <= stop_frame_cnt + 1'b1;
		    end
		end

		always@(posedge clk_i) begin
		    if(rst_i || !a_en)
		        action_alarm <= 1'b0;
		    else if(curr_state == S_EXE && launch_ok)
		        action_alarm <= 1'b0;
		    else if((curr_state == S_ALERT_40) || (curr_state == S_SLV_STOP_WAIT))
		        action_alarm <= 1'b1;
		    else if(curr_state == S_IDLE)
		        action_alarm <= 1'b0;
		    else
		        action_alarm <= action_alarm;
		end

		// Debug frame counts are sourced from the link module; behavior keeps
		// only the stop-wait timeout latch.
		reg stop_wait_to;
		always@(posedge clk_i) begin
		    if(rst_i)
		        stop_wait_to <= 1'b0;
		    else if(a_bhv_vld_r)
		        stop_wait_to <= 1'b0;
		    else if(curr_state == S_SLV_STOP_WAIT && timout && !slv_stop_ready)
		        stop_wait_to <= 1'b1;
		end

		assign dbg_s2m_o = {s2m_frm_cnt, st_s1[15:0]};
		assign dbg_m2s_w0_o = link_m2s_word0;
		assign dbg_s2m_w0_o = st_s0;
		assign dbg_s2m_w12_o = st_s12;
		assign dbg_s2m_w13_o = st_s13;
		assign dbg_s2m_w14_o = st_fault;
		assign dbg_s2m_w15_o = st_s1;
		assign dbg_ctl_o = {m2s_frm_cnt, stop_frame_cnt,
		                    i_pause, i_stop, i_emerge_stop_signal, a_en,
		                    stop_wait_to, timout, link_ready, action_issued,
		                    seq_busy, action_alarm, seq_accepted, done_latched,
		                    pulse_done_latched, stop_status_idle, latch_sta};
//==============================================================================================================================//
//----------------------------------------------------- user logic end -------------------------------------------------------//
//==============================================================================================================================//

endmodule
