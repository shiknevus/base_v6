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
    ,output reg [31:0] 			m2s_pulm_msg        //message  master to slave
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
	,input		[31:0]			rcfg_touch_spd     	//home clamp speed
	,input signed [31:0]		rcfg_pos_max = 32'sd0	// signed upper soft limit
	,input signed [31:0]		rcfg_pos_min = 32'sd0	// signed lower soft limit

	,output wire signed [31:0]			r_pf_abspos //postion
	,output wire						dv_alarm //remote drive alm
	,output wire				o_soft_lim_f
	,output wire				o_soft_lim_b

    ,input wire i_home_completed
    ,input wire i_drive_enabled
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );




    wire       slv_action_error;
    reg        action_accepted;
    reg [31:0] s2m_10tmp;
    reg pulse_done_latched;
    wire is_move = (a_bhv_id_r == 3) || (a_bhv_id_r == 21);
    wire is_motion = is_move || (a_bhv_id_r == 1) || (a_bhv_id_r == 2) || (a_bhv_id_r == 20);
    wire limits_enabled = rcfg_pos_max > rcfg_pos_min;
    wire target_over_f = is_move && limits_enabled && ($signed(rserv_target_pulse) > rcfg_pos_max);
    wire target_over_b = is_move && limits_enabled && ($signed(rserv_target_pulse) < rcfg_pos_min);
    wire [7:0] launch_alarm = !dv_alarm ? 8'd108 :
                              !i_servo_ready ? 8'd113 :
                              !i_drive_enabled ? 8'd115 :
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
               if (a_en && ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM)) && a_bhv_vld_r)	//behavior start
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
				if(slv_stop_ready)
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
            if(is_motion && !dv_alarm) a_alm_num <= 8'd108;          // Drive alarm
            else if(is_motion && !i_servo_ready) a_alm_num <= 8'd113;  // Servo not ready
            else if(action_accepted && i_axis_limf) a_alm_num <= 8'd109;  // Forward limit
            else if(action_accepted && i_axis_limb) a_alm_num <= 8'd110;  // Backward limit
            else if(i_stop) a_alm_num <= 8'd106;                       // Stop warning
            else if(!i_emerge_stop_signal) a_alm_num <= 8'd107;        // Emergency stop
            else if(launch_fault) a_alm_num <= launch_alarm;           // Launch fault
            else if(action_accepted && slv_action_error && s2m_10tmp[15:8] != 0)
                a_alm_num <= s2m_10tmp[15:8];                         // Slave alarm
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
		else if(i_pause)
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

		reg        action_son;
		reg        action_start;
		reg        action_alarm;
		reg        action_ack_base;

		reg [3:0]  stop_frame_cnt;

		// m2s/s2m multi-cycle state machines
		reg [3:0]  m2s_state;
		reg [3:0]  s2m_state;
		reg [31:0] slv_beat_cnt;
		reg        action_beat;
		reg        pul_motor_flag_d1;
		reg        pul_motor_flag_d2;
		reg [31:0] s2m_0tmp;

		reg [31:0] s2m_11tmp;

		wire       slv_action_busy;
		wire       slv_action_done;

		wire       slv_action_ack;
		wire       o_dv_dir;
		wire       o_dv_son;
		wire       o_dv_reset;



		always@(posedge clk_i) begin
		    if(rst_i) begin
		        slv_beat_cnt <= 32'd0;
		        action_beat  <= 1'b0;
		    end else begin
		        slv_beat_cnt <= slv_beat_cnt + 1'b1;
		        if(slv_beat_cnt >= 2000000) begin  
		            slv_beat_cnt <= 32'd0;
		            action_beat  <= ~action_beat;
		        end
		    end
		end

		always @(posedge clk_i) begin
		    if (rst_i) begin
		        m2s_state    <= 4'd0;
		        m2s_pulm_msg <= 32'd0;
		    end else begin
		        case (m2s_state)
		            4'd0:  m2s_pulm_msg <= {
											8'd0, 
											a_bhv_id_r,
		                                    i_servo_ready,
                                            i_servo_done,
                                            i_home_completed,
											i_drive_on,
		                                    i_drive_reset, 
											rserv_dir,
		                                    1'b0, 
											i_pause,
		                                     i_stop|(~i_emerge_stop_signal)|(!a_en),
											action_beat,
		                                    i_axis_zero,
											i_axis_limb,
		                                    i_axis_limf, 
											1'b0,
		                                    action_start,
											action_alarm
											};
		            4'd1:  m2s_pulm_msg <= rserv_step_pulse;
		            4'd2:  m2s_pulm_msg <= rserv_target_pulse;
		            4'd3:  m2s_pulm_msg <= rcfg_home_spd;
		            4'd4:  m2s_pulm_msg <= rcfg_home_acc;
		            4'd5:  m2s_pulm_msg <= rcfg_home_dec;
		            4'd6:  m2s_pulm_msg <= rcfg_jog_spd;
		            4'd7:  m2s_pulm_msg <= rcfg_jog_acc;
		            4'd8:  m2s_pulm_msg <= rcfg_jog_dec;
		            4'd9:  m2s_pulm_msg <= rcfg_move_spd;
		            4'd10: m2s_pulm_msg <= rcfg_move_acc;
		            4'd11: m2s_pulm_msg <= rcfg_move_dec;
		            4'd12: m2s_pulm_msg <= rcfg_spd_max;
		            4'd13: m2s_pulm_msg <= rcfg_acc_max;
		            4'd14: m2s_pulm_msg <= rcfg_dec_max;
		            4'd15: m2s_pulm_msg <= rcfg_touch_spd;
		            default: m2s_pulm_msg <= 32'd0;
		        endcase
		        if ((m2s_state == 4'd0) && pul_motor_r_flag)
		            m2s_state <= 4'd1;
		        else if (m2s_state != 4'd0)
		            m2s_state <= (m2s_state == 4'd15) ? 4'd0 : m2s_state + 1'b1;
		    end
		end

		always@(posedge clk_i) begin
		    if(rst_i) begin
		        pul_motor_flag_d1 <= 1'b0;
		        pul_motor_flag_d2 <= 1'b0;
		        s2m_state <= 4'd0;
		        s2m_0tmp  <= 32'd0;
		        s2m_10tmp <= 32'd0;
		        s2m_11tmp <= 32'd0;
		    end else begin
		        pul_motor_flag_d1 <= pul_motor_flag & (cur_slv_board_id == slv_board_id);
		        pul_motor_flag_d2 <= pul_motor_flag_d1;

		        if(pul_motor_flag_d2) begin
		        // Re-align status sampling at the base-address response.
		        s2m_0tmp  <= s2m_pulm_msg;
		        s2m_state <= 4'd1;
		        end else begin
		        	case(s2m_state)
		            	0: begin
		            	    s2m_state <= 4'd0;
		            	end
		            	1,2,3,4,5,6,7,8,9: s2m_state <= s2m_state + 1'b1;  
		            	10: begin
		            	    s2m_10tmp <= s2m_pulm_msg;
		            	    s2m_state <= 4'd11;
		            	end
		            	11: begin
		            	    s2m_11tmp <= s2m_pulm_msg;
		            	    s2m_state <= 4'd12;
		            	end
		            	12,13,14: s2m_state <= s2m_state + 1'b1;            
		            	default: s2m_state <= 4'd0;
		        	endcase
		        end
			end
		end
		assign {dv_alarm, slv_action_error, slv_action_done, slv_action_busy} = s2m_10tmp[3:0];
		assign slv_action_ack = s2m_10tmp[7];
		assign r_pf_abspos  = s2m_11tmp;

		wire w_soft_lim_en = (rcfg_pos_max > rcfg_pos_min) && (a_bhv_id_r != 8'd1);
		assign w_soft_lim_f = w_soft_lim_en && (r_pf_abspos >= rcfg_pos_max);
		assign w_soft_lim_b = w_soft_lim_en && (r_pf_abspos <= rcfg_pos_min);
		assign o_soft_lim_f = w_soft_lim_f;
		assign o_soft_lim_b = w_soft_lim_b;
		assign w_sw_move  = (a_bhv_id_r == 8'd3) || (a_bhv_id_r == 8'd21);
		assign w_sw_fault = target_over_f | target_over_b;

        reg done_latched;

        always @(posedge clk_i) begin
            if(rst_i || a_bhv_vld_r || curr_state == S_EXE) begin
                done_latched <= 0;
                pulse_done_latched <= 0;
            end else begin
                if(s2m_10tmp[6] && action_accepted) pulse_done_latched <= 1;
                if(slv_action_done && action_accepted && !action_error)
                    done_latched <= 1;
                if(action_error) done_latched <= 0;
            end
        end
		assign action_busy  = slv_action_busy;
		assign action_done  = done_latched;
		assign action_error = (slv_action_error & action_accepted) | w_sw_fault;
		reg stop_status_idle;
        always @(posedge clk_i) begin
            if(rst_i || curr_state != S_SLV_STOP_WAIT) stop_status_idle <= 0;
            else if(s2m_state == 12 && stop_frame_cnt >= 2)
                stop_status_idle <= !slv_action_busy;
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
		        if((m2s_state == 4'd0) && pul_motor_r_flag && (stop_frame_cnt != 4'hF))
		            stop_frame_cnt <= stop_frame_cnt + 1'b1;
		    end
		end

		always@(posedge clk_i) begin
		    if(rst_i || !a_en) begin
		        action_start     <= 1'b0;
		        action_ack_base  <= 1'b0;
		        action_accepted  <= 1'b0;
		    end
		    else if(curr_state == S_EXE && launch_ok) begin
		        action_start    <= 1'b1;
		        action_ack_base <= slv_action_ack;
		        action_accepted <= 1'b0;
		    end
		    else if(curr_state == S_BHA_POST_DET) begin
		        if(!action_accepted && (slv_action_ack != action_ack_base)) begin
		            action_start    <= 1'b0;
		            action_accepted <= 1'b1;
		        end
		    end
		    else begin
		        action_start    <= 1'b0;
		        action_accepted <= 1'b0;
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
//==============================================================================================================================//
//----------------------------------------------------- user logic end -------------------------------------------------------//
//==============================================================================================================================//

endmodule
