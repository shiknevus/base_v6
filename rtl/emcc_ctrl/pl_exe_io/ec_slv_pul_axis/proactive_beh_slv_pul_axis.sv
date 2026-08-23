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
//   FSM & behavior numbering aligned with master proactive_beh_pul_axis.
//   Drive control replaced by m2s/s2m message protocol to slave board.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module proactive_beh_slv_pul_axis#(
    parameter                 	BHA_NUM 		= 8   //Number of active behaviors
)(
    input                       clk_i
    ,input                      rst_i
    ,input                      i_time_1ms_vld      //ms pulse
    ,input                      i_time_1s_vld       //s pulse

    ,input      [BHA_NUM-1:0]   pre_sta_allow   //Pre - sufficient condition satisfied signal. 0: Not satisfied. 1: Satisfied.
    ,input      [BHA_NUM-1:0]   post_sta_allow  //Post - sufficient condition satisfied signal

		,input      [7:0]           ec_id
		,input						a_en			//A enable
    ,input      [7:0]           a_bhv_id
    ,input                      a_bhv_vld
    ,input      [19:0]          a_tx_ot
    ,input      [31:0]          a_tx_result_rpt
		,input						a_tx_result_vld
    ,output		                ec_cha_st
    ,output reg [7:0]           a_tx_id
    ,output reg	[7:0]           a_alm_num
		//io port start
    ,input						i_servo_notok       //servo not ok
    ,input						i_servo_stop        //servo stop
    ,input						i_axis_limf         //axis limit forward
    ,input						i_axis_org          //axis origin
    ,input						i_axis_limb         //axis limit backward
    ,input						i_emerge_stop_signal//emergency stop signal
    ,input						i_safe_status       //safe status
    ,input						i_axis_point        //axis in position
    ,input						i_axis_reset        //axis reset

    ,input						cur_slv_board_id    //current slave board id
    ,input						slv_board_id        //slave board id
    ,input						pul_motor_r_flag    //pul motor ready flag
    ,input						pul_motor_flag      //pul motor flag
    ,output reg [31:0] 			m2s_pulm_msg        //message  master to slave
    ,input 		[31:0] 			s2m_pulm_msg       	//message  slave to master
		//io port end
		//register start
		,input		[ 0:0]			rctrl_drive_on    	//enable servo
		,input		[ 0:0]			rctrl_drive_reset 	//reset servo
		,input		[ 0:0]			rctrl_resume      	//resume servo
		,input		[ 0:0]			rctrl_pause       	//pause servo
		,input		[ 0:0]			rctrl_quickstop   	//quick stop
		,input		[ 0:0]			rcfg_pf_mode     	//position feedback mode
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
		,input		[31:0]			rcfg_qs_dec       	//quick stop deceleration
		,input		[31:0]			rcfg_timedly      	//timedly time
		,input		[31:0]			rcfg_touch_spd    	//home touch/creep speed
		//register end
		//user logic master-aligned start
		,input						i_pause				//motor pause (B channel)
		,input						i_stop				//motor stop (B channel)
		,output wire				action_busy
		,output wire				action_done
		,output wire				action_error
		,output reg [7:0]			a_bhv_id_r
		//user logic master-aligned end
    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response
		,output reg [31:0]			state_monitor_o
    );

		reg	[7:0]		curr_state;
		reg [7:0]    	curr_state_1d;
    reg [7:0]    	next_state;

    reg         	timout;
    reg [19:0]   	timout_cnt;

		reg [7:0]		ack_beh_id;
		reg [7:0]		ack_tx_id;
		reg [7:0]		ack_tx_result;
		reg	[7:0]		ack_ps_alart_num;

		//State machine state (same as master)
		localparam  S_IDLE          = 8'd0; 	//idle
    localparam  S_BHA_PRE_DET	= 8'd1; 	//Pre-condition check
		localparam	S_READY_10		= 8'd2;		//ready
    localparam  S_READY_10_ACK  = 8'd3; 	//ready ok/no ok
    localparam  S_EXE_20     	= 8'd4; 	//Action begin
		localparam	S_EXE			= 8'd5;		//Action execute
    localparam  S_EXE_20_ACK	= 8'd6;		//Action end
    localparam  S_BHA_POST_DET  = 8'd7; 	//Post-condition check
    localparam  S_SUCC_30       = 8'd8; 	//success
    localparam  S_SUCC_30_ACK	= 8'd9; 	//success ack
		localparam 	S_ALERT_40		= 8'd10;	//Alert
		localparam 	S_ALERT_40_ACK	= 8'd11;	//Alert ack

    localparam  IRQ_OK          = 8'h51;	//ps ack:OK
    localparam  IRQ_NO_OK       = 8'h52;	//ps ack:NO OK

		//state monitor
		reg [7:0] curr_state_m1;
		reg [7:0] curr_state_m2;
		reg [7:0] curr_state_m3;
    always @(posedge clk_i)
		begin
        if (rst_i)begin
				curr_state_m1 <= 8'b0;
				curr_state_m2 <= 8'b0;
				curr_state_m3 <= 8'b0;
				state_monitor_o <= 32'b0;
				end
        else if (curr_state != curr_state_m1) begin
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

    reg			a_bhv_vld_r;

    //Current behavior number (same as master)
    always@(posedge clk_i)begin
        if(rst_i)begin
            a_bhv_id_r <= 8'd0;
				a_bhv_vld_r <= 1'b0;
        end else if(a_en && ((a_bhv_id >= 8'd1) && (a_bhv_id <= BHA_NUM)) && a_bhv_vld)begin
            a_bhv_id_r <= a_bhv_id;
				a_bhv_vld_r <= a_bhv_vld;
        end else if(curr_state == S_IDLE && curr_state_1d != curr_state)begin
            a_bhv_id_r <= 8'd0;
				a_bhv_vld_r <= 1'b0;
        end else begin
            a_bhv_id_r <= a_bhv_id_r;
				a_bhv_vld_r <= 1'b0;
        end
    end

	//------------------------------------------- FSM begin (same as master) -----------------------------------------------//

		reg match_10;
		//reg match_20;
		reg match_30;
		reg match_40;

		always @(posedge clk_i) begin
	    if(rst_i)
			begin
	        	match_10 <= 1'b0;
				//match_20 <= 1'b0;
				match_30 <= 1'b0;
				match_40 <= 1'b0;
	    	end
		else if(curr_state == S_READY_10_ACK)
	        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == a_bhv_id_r);
		else if(curr_state == S_SUCC_30_ACK)
			match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == a_bhv_id_r);
		else if(curr_state == S_ALERT_40_ACK)
			match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == a_bhv_id_r);
		else
			begin
				match_10 <= 1'b0;
				match_30 <= 1'b0;
				match_40 <= 1'b0;
			end
		end

		always@(posedge clk_i)begin
		if(rst_i)
			curr_state_1d <= 8'd0;
		else
			curr_state_1d <= curr_state;
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
                    next_state = S_ALERT_40;
					end else begin
                    next_state = S_BHA_PRE_DET;
					end
            end

            S_READY_10: begin  		//curr_state = 2
					next_state = S_READY_10_ACK;				//Send 10 interrupt
            end

				S_READY_10_ACK: begin	//curr_state = 3
					if(match_10) 								//Transaction 10 Acknowledged OK
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
				end

            S_EXE_20: begin			//curr_state = 4
					next_state = S_EXE;							//Send 20 interrupt
            end

				S_EXE:begin				//curr_state = 5
						next_state = S_BHA_POST_DET;
				end

            S_BHA_POST_DET: begin	//curr_state = 7
					if(post_sta_allow[a_bhv_id_r - 1'b1]) begin
                    	next_state = S_SUCC_30;
					end else if(timout | action_error) begin
                            next_state = S_ALERT_40;
					end else begin
						next_state = S_BHA_POST_DET;
					end
            end

            S_SUCC_30: begin		//curr_state = 7
					next_state = S_SUCC_30_ACK;					//Send Interrupt 30
            end

				S_SUCC_30_ACK:begin		//curr_state = 8
					if(match_30)    							//30 response success
                    next_state = S_IDLE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
				end

            S_ALERT_40: begin		//curr_state = 9
					next_state = S_ALERT_40_ACK;				//Send Interrupt 40
            end

				S_ALERT_40_ACK:begin	//curr_state = 10
					if(match_40 || timout) 						//40 Interrupt response
                    next_state = S_IDLE;
                else
                    next_state = S_ALERT_40_ACK;
				end

            default: begin
                next_state = S_IDLE;
            end

        endcase
        // interrupt: i_stop forces A FSM to ALERT_40 (same as master)
        if(i_stop && curr_state != S_IDLE)
            next_state = S_ALERT_40;
    end

	//----------------------------------------------------------- FSM end ------------------------------------------------------//

    //Channel A busy signal
		assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 20 30 40 (same as master)
    always@(posedge clk_i)begin
        if(rst_i || !a_en)
				a_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        else if(curr_state == S_SUCC_30)
            a_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            a_tx_id <= 8'd40;
			else if(curr_state == S_IDLE || curr_state == S_BHA_PRE_DET)
				a_tx_id <= 8'd0;
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

    always@(posedge clk_i)begin
        if(rst_i || !a_en)
            a_alm_num <= 8'd0;
        else if(i_stop && curr_state != S_IDLE)
            a_alm_num <= 8'd156;   // stop (same as master)
        else if(curr_state == S_BHA_PRE_DET && timout)
            a_alm_num <= 8'd151;
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)
            a_alm_num <= ack_ps_alart_num;
        else if(curr_state == S_READY_10_ACK && timout)
            a_alm_num <= 8'd152;
			else if(curr_state == S_BHA_POST_DET && timout)
            a_alm_num <= 8'd153;
			else if(curr_state == S_BHA_POST_DET && action_error)
            a_alm_num <= 8'd155;
			else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)
				a_alm_num <= ack_ps_alart_num;
			else if(curr_state == S_SUCC_30_ACK && timout)
            a_alm_num <= 8'd154;
			else if(curr_state == S_IDLE)
				a_alm_num <= 8'd0;
        else
            a_alm_num <= a_alm_num;
    end


    //Timeout count (same as master)
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 20'd0;
			else if(!a_en)
				timout_cnt <= 20'd0;
			else if(curr_state != curr_state_1d)
				timout_cnt <= 20'd0;
			else if(i_pause)
				timout_cnt <= timout_cnt;
        else if(timout_cnt >= a_tx_ot-1)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
			else
				timout_cnt <= timout_cnt;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt >= a_tx_ot-1)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end


		//===============================================================================================================
		//------------------------------------------------ user logic start ---------------------------------------------
		//===============================================================================================================
		// Behavior numbering (aligned with master ec_pul_axis):
		//   1 = HOME
		//   2 = JOG
		//   3 = MOVE
		//  20 = JOG [safe]
		//  21 = MOVE [safe]
		//  30 = GETPOS

		//===============================================================================================================
		//----------------------- m2s/s2m message protocol to slave board ------------------------------------------------
		//===============================================================================================================

		reg        action_son;
		reg        action_start;
		reg        action_alarm;
		reg [7:0]  action_delay_cnt;

		// m2s/s2m multi-cycle state machines
		reg [3:0]  m2s_state;
		reg [3:0]  s2m_state;
		reg [31:0] slv_beat_cnt;
		reg        action_beat;
		reg        pul_motor_flag_d1;
		reg        pul_motor_flag_d2;
		reg [31:0] s2m_0tmp;
		reg [31:0] s2m_10tmp;

		wire       dv_alarm;
		wire       o_dv_dir;
		wire       o_dv_son;
		wire       o_dv_reset;

		assign o_dv_reset = rctrl_drive_reset;
		assign o_dv_son   = rctrl_drive_on;  // SON/SOFF handled by B channel

		assign {dv_alarm, action_error, action_done, action_busy} = s2m_10tmp[3:0];
		assign o_dv_dir = s2m_0tmp[0];

		always@(posedge clk_i) begin
		    if(rst_i) begin
		        slv_beat_cnt <= 32'd0;
		        action_beat  <= 1'b0;
		    end else begin
		        slv_beat_cnt <= slv_beat_cnt + 1'b1;
		        if(slv_beat_cnt >= 2000000) begin  // 20ms @ 100MHz
		            slv_beat_cnt <= 32'd0;
		            action_beat  <= ~action_beat;
		        end
		    end
		end

		always@(posedge clk_i) begin
		    if(rst_i) begin
		        m2s_pulm_msg <= 32'd0;
		        m2s_state    <= 4'd0;
		    end else begin
		        case(m2s_state)
		            0: begin  // control word: status + behavior ID
		                if(pul_motor_r_flag) begin
		                    m2s_pulm_msg <= {8'd0, a_bhv_id_r, 8'd0,
		                                     1'b0,              // i_axis_point (not available)
		                                     action_beat,
		                                     i_axis_org,
		                                     i_axis_limb,
		                                     i_axis_limf,
		                                     action_son,
		                                     action_start,
		                                     action_alarm};
		                    m2s_state <= 4'd1;
		                end
		            end
		            1 : begin m2s_pulm_msg <= rserv_step_pulse;                    m2s_state <= 4'd2;  end
		            2 : begin m2s_pulm_msg <= rserv_target_pulse;                  m2s_state <= 4'd3;  end
		            3 : begin m2s_pulm_msg <= {rcfg_home_spd, rcfg_move_spd};      m2s_state <= 4'd4;  end
		            4 : begin m2s_pulm_msg <= {12'd0, rctrl_drive_reset, o_dv_son,
		                                       rcfg_pf_mode, rserv_dir, rcfg_jog_spd};
		                                                                           m2s_state <= 4'd5;  end
		            5 : begin m2s_pulm_msg <= {rcfg_home_acc, rcfg_home_dec};      m2s_state <= 4'd6;  end
		            6 : begin m2s_pulm_msg <= {rcfg_jog_acc,  rcfg_jog_dec};       m2s_state <= 4'd7;  end
		            7 : begin m2s_pulm_msg <= {rcfg_move_acc, rcfg_move_dec};      m2s_state <= 4'd8;  end
		            8 : begin m2s_pulm_msg <= {rcfg_acc_max,  rcfg_dec_max};       m2s_state <= 4'd9;  end
		            9 : begin m2s_pulm_msg <= {rcfg_spd_max,  rcfg_qs_dec};        m2s_state <= 4'd10; end
		            10: begin m2s_pulm_msg <= rcfg_timedly;                        m2s_state <= 4'd11; end
		            11: begin m2s_pulm_msg <= 32'd0;                               m2s_state <= 4'd12; end
		            12: begin m2s_pulm_msg <= 32'd0;                               m2s_state <= 4'd13; end
		            13: begin m2s_pulm_msg <= 32'd0;                               m2s_state <= 4'd14; end
		            14: begin m2s_pulm_msg <= 32'd0;                               m2s_state <= 4'd0;  end
		            default: begin m2s_pulm_msg <= 32'd0;                          m2s_state <= 4'd0;  end
		        endcase
		    end
		end

		always@(posedge clk_i) begin
		    pul_motor_flag_d1 <= pul_motor_flag & (cur_slv_board_id == slv_board_id);
		    pul_motor_flag_d2 <= pul_motor_flag_d1;

		    if(rst_i) begin
		        s2m_state <= 4'd0;
		        s2m_0tmp  <= 32'd0;
		        s2m_10tmp <= 32'd0;
		    end else begin
		        case(s2m_state)
		            0: begin
		                if(pul_motor_flag_d2) begin
		                    s2m_0tmp  <= s2m_pulm_msg;
		                    s2m_state <= 4'd1;
		                end
		            end
		            1,2,3,4,5,6,7,8,9: s2m_state <= s2m_state + 1'b1;   // pipeline delay
		            10: begin
		                s2m_10tmp <= s2m_pulm_msg;
		                s2m_state <= 4'd11;
		            end
		            11,12,13,14: s2m_state <= s2m_state + 1'b1;          // pipeline delay
		            default: s2m_state <= 4'd0;
		        endcase
		    end
		end

		// action_son/action_start: enable servo, then start motion after 10ms delay
		always@(posedge clk_i) begin
		    if(rst_i || !a_en) begin
		        action_son       <= 1'b0;
		        action_start     <= 1'b0;
		        action_delay_cnt <= 8'd0;
		    end
		    else if(curr_state == S_EXE) begin
		        action_son <= rctrl_drive_on;
		        if(action_son) begin
		            if(action_busy) begin
		                action_start     <= 1'b0;
		                action_delay_cnt <= action_delay_cnt;
		            end else if(action_delay_cnt == 10) begin
		                action_start     <= 1'b1;
		                action_delay_cnt <= action_delay_cnt;
		            end else begin
		                action_start     <= action_start;
		                action_delay_cnt <= action_delay_cnt + i_time_1ms_vld;
		            end
		        end else begin
		            action_start     <= 1'b0;
		            action_delay_cnt <= 8'd0;
		        end
		    end
		    else begin
		        action_son       <= 1'b0;
		        action_start     <= 1'b0;
		        action_delay_cnt <= 8'd0;
		    end
		end

		always@(posedge clk_i) begin
		    if(rst_i || !a_en)
		        action_alarm <= 1'b0;
		    else if(curr_state == S_EXE)
		        action_alarm <= 1'b0;
		    else if(curr_state == S_ALERT_40)
		        action_alarm <= 1'b1;
		    else if(curr_state == S_IDLE)
		        action_alarm <= 1'b0;
		    else
		        action_alarm <= action_alarm;
		end

		//===============================================================================================================
		//------------------------------------------------ user logic start ---------------------------------------------
		//===============================================================================================================

endmodule