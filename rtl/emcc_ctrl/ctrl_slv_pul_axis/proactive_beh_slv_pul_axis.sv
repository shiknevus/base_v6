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
    parameter                 	BHA_NUM 		= 2   //Number of active behaviors
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
    //for post check start
    ,output                     action_busy
    ,output                     action_done
    ,output                     action_error
    //for post check start end
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
	,input		[15:0]			rcfg_home_spd     	//home speed
	,input		[15:0]			rcfg_home_acc     	//home acceleration
	,input		[15:0]			rcfg_home_dec     	//home deceleration
	,input		[15:0]			rcfg_jog_spd      	//jog speed
	,input		[15:0]			rcfg_jog_acc      	//jog acceleration
	,input		[15:0]			rcfg_jog_dec      	//jog deceleration
	,input		[15:0]			rcfg_move_spd     	//move speed
	,input		[15:0]			rcfg_move_acc     	//move acceleration
	,input		[15:0]			rcfg_move_dec     	//move deceleration
	,input		[15:0]			rcfg_spd_max      	//maximum speed
	,input		[15:0]			rcfg_acc_max      	//maximum acceleration
	,input		[15:0]			rcfg_dec_max      	//maximum deceleration
	,input		[15:0]			rcfg_qs_dec       	//quick stop deceleration
	,input		[31:0]			rcfg_timedly      	//timedly time
	//register end
    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response
	,output reg [31:0]			state_monitor_o
	,output     [31:0]			dbg_o			//debug: link/frame/action status
    );

    reg  [7:0]      a_bhv_id_r;

	reg	[7:0]		curr_state;
	reg [7:0]    	curr_state_1d;
    reg [7:0]    	next_state;

    reg         	timout;
    reg [19:0]   	timout_cnt;
	
	reg [7:0]		ack_beh_id;
	reg [7:0]		ack_tx_id;
	reg [7:0]		ack_tx_result;
	reg	[7:0]		ack_ps_alart_num;
	


	localparam  S_IDLE          = 8'h00;
    localparam  S_BHA_PRE_DET	= 8'h01; 
	localparam	S_READY_10		= 8'h02;
    localparam  S_READY_10_ACK  = 8'h03; 
    localparam  S_EXE_20     	= 8'h04; 
	localparam	S_EXE			= 8'h05;

    // localparam  S_EXE_20_ACK	= 8'h06; 
    localparam  S_BHA_POST_DET  = 8'h07; 
    localparam  S_SUCC_30       = 8'h08; 
    localparam  S_SUCC_30_ACK	= 8'h09; 
	localparam 	S_ALERT_40		= 8'h0a;
	localparam 	S_ALERT_40_ACK	= 8'h0b;

    localparam  IRQ_OK          = 8'h51;
    localparam  IRQ_NO_OK       = 8'h52;
	
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
	
    //Current behavior number
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
	
//------------------------------------------- FSM begin => Control 10/20/30/40 interrupt -----------------------------------------------//

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
		//match_20 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == a_bhv_id_r);
	else 
		begin
			match_10 <= 1'b0;
			//match_20 <= 1'b0;
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

    always @(*) begin			
        case (curr_state)	
            S_IDLE: begin			//curr_state = 0
                if (a_en && ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM)) && a_bhv_vld_r)	//behavior start
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end

            S_BHA_PRE_DET:
			begin	//1
                if(pre_sta_allow[a_bhv_id_r - 1'b1])
                    next_state = S_READY_10;
                else
                    next_state = S_ALERT_40;		//pre not met: reject immediately (via a_pre_sta_allow)
            end

            S_READY_10: 
			begin  //2      						//Send 10 interrupt
				next_state = S_READY_10_ACK;
            end

			S_READY_10_ACK: 
			begin	//3
				if(match_10) 								//Transaction 10 Acknowledged OK
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end

            S_EXE_20: begin		//4							//Send 20 interrupt
				next_state = S_EXE;
            end
						
			S_EXE:
			begin		//5								//active Execution
					next_state = S_BHA_POST_DET;
			end
			
            S_BHA_POST_DET:
			begin	//7
				if(post_sta_allow[a_bhv_id_r - 1'b1])
                	next_state = S_SUCC_30;
                else if(timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_BHA_POST_DET;
            end

            S_SUCC_30: begin		//8						//Send Interrupt 30
				next_state = S_SUCC_30_ACK;
            end
			
			S_SUCC_30_ACK:begin	//9
				if(match_30)    							//30 response success
                    next_state = S_IDLE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
			end

            S_ALERT_40: begin		//a					//Send Interrupt 40
				next_state = S_ALERT_40_ACK;
            end
			
			S_ALERT_40_ACK:begin	//b
				if(match_40 || timout) 						//40 response
                    next_state = S_IDLE;
                else
                    next_state = S_ALERT_40_ACK;
			end

            default: begin
                next_state = S_IDLE;
            end

        endcase
    end
	
//----------------------------------------------------------- FSM end ------------------------------------------------------//

    //Channel A busy signal
	assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 20 30 40
    always@(posedge clk_i)begin
        if(rst_i || !a_en)
			a_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        //else if(curr_state == S_EXE_20)
        //    a_tx_id <= 8'd20;
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
		//else if(curr_state == S_EXE_20)
		//	irq_o <= 1'b1;
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
        else if(curr_state == S_BHA_PRE_DET && !pre_sta_allow[a_bhv_id_r - 1'b1])	//pre not met: rejected immediately
            a_alm_num <= 8'd101;
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 10 ps response error
            a_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)						//For Transaction 10, waiting for the ps response timed out.
            a_alm_num <= 8'd108;    
		//else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 20 has a ps response error.
        //    a_alm_num <= ack_ps_alart_num;    
        //else if(curr_state == S_EXE_20_ACK && timout)						//For Transaction 20, waiting for the ps response timed out.
        //    a_alm_num <= 8'd103;    
		else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40)			//The execution of Behavior 1 failed.
				a_alm_num <= 8'd109;   
		else if(curr_state_1d == S_BHA_POST_DET && curr_state == S_ALERT_40)//The post - full inspection is not met.
				a_alm_num <= 8'd116;    
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 30 has a ps response error.
			a_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)						//For Transaction 30, waiting for the ps response timed out.
            a_alm_num <= 8'd123;
		else if(curr_state == S_IDLE)
			a_alm_num <= 8'd0;
        else
            a_alm_num <= a_alm_num;
    end
	

    //Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 20'd0;
		else if(!a_en)
			timout_cnt <= 20'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 20'd0;
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

// Internal motion control signals
reg        action_son;
reg        action_start;
reg        get_point_flag;
reg        son_bhv_flag;
reg        soff_bhv_flag;
reg        reset_bhv_flag;
reg        action_alarm;
reg [15:0] servo_delay_ms;
reg        act_done_d1;
reg        servo_stop_timeout;
reg [15:0] servo_stop_timeout_cnt_ms;

wire       dv_alarm;
wire       o_dv_dir;
wire       o_dv_son;
wire       o_dv_reset;
wire       servo_work_error;

// m2s/s2m multi-cycle state machines
reg [3:0]  m2s_state;
reg [3:0]  s2m_state;
reg [31:0] slv_beat_cnt;
reg        action_beat;
reg        pul_motor_flag_d1;
reg        pul_motor_flag_d2;
reg [31:0] s2m_0tmp;
reg [31:0] s2m_10tmp;

localparam P_EN_EFF  = 1'b0;  // servo enable active low
localparam P_RST_EFF = 1'b0;  // servo reset active low

assign o_dv_reset = reset_bhv_flag ? 1'b1 : 1'b0;
assign o_dv_son   = action_son;

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
            4 : begin m2s_pulm_msg <= {12'd0, o_dv_reset, o_dv_son,
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

// behavior flags in S_EXE 
always@(posedge clk_i) begin
    if(rst_i || !a_en) begin
        action_start    <= 1'b0;
        get_point_flag  <= 1'b0;
        son_bhv_flag    <= 1'b0;
        soff_bhv_flag   <= 1'b0;
        reset_bhv_flag  <= 1'b0;
    end
    else if(curr_state == S_EXE) begin
        if (a_bhv_id_r == 8'd1)      action_start   <= 1'b1;   // Home search
        else if(a_bhv_id_r == 8'd2)  action_start   <= 1'b1;   // Move 0
        else if(a_bhv_id_r == 8'd3)  action_start   <= 1'b1;   // JOG
        else if(a_bhv_id_r == 8'd4)  action_start   <= 1'b1;   // Move abs
        else if(a_bhv_id_r == 8'd5)  get_point_flag <= 1'b1;   // Get point
        else if(a_bhv_id_r == 8'd6)  son_bhv_flag   <= 1'b1;   // S-on servo
        else if(a_bhv_id_r == 8'd7)  soff_bhv_flag  <= 1'b1;   // S-off servo
        else if(a_bhv_id_r == 8'd8)  reset_bhv_flag <= 1'b1;   // Reset servo
    end
    else begin
        action_start    <= 1'b0;
        get_point_flag  <= 1'b0;
        son_bhv_flag    <= 1'b0;
        soff_bhv_flag   <= 1'b0;
        reset_bhv_flag  <= 1'b0;
    end
end

// servo enable 
always@(posedge clk_i) begin
    if(rst_i || !a_en)
        action_son <= 1'b0;
    else if(soff_bhv_flag)
        action_son <= 1'b0;
    else if(son_bhv_flag)
        action_son <= 1'b1;
end

always@(posedge clk_i) begin
    act_done_d1 <= action_done;
    if(rst_i || !a_en) begin
        servo_delay_ms <= 16'd0;
    end else begin
        if(action_son) begin
            if(action_busy) begin
                if(i_servo_stop)
                    servo_delay_ms <= servo_delay_ms + i_time_1ms_vld;
                else
                    servo_delay_ms <= 16'd0;
            end
        end else begin
            servo_delay_ms <= 16'd0;
        end
    end
end

always@(posedge clk_i) begin
    if(rst_i || !a_en) begin
        servo_stop_timeout        <= 1'd0;
        servo_stop_timeout_cnt_ms <= 16'd0;
    end else begin
        if(action_son & act_done_d1) begin
            if(servo_stop_timeout_cnt_ms < 5000) begin
                servo_stop_timeout_cnt_ms <= servo_stop_timeout_cnt_ms + i_time_1ms_vld;
                servo_stop_timeout        <= 1'b0;
            end else begin
                servo_stop_timeout_cnt_ms <= servo_stop_timeout_cnt_ms;
                servo_stop_timeout        <= 1'b1;
            end
        end else begin
            servo_stop_timeout        <= 1'b0;
            servo_stop_timeout_cnt_ms <= 16'd0;
        end
    end
end

assign servo_work_error = (((a_bhv_id_r == 8'd1) & (servo_delay_ms >= 5000)) |
                           ((a_bhv_id_r >= 8'd2 && a_bhv_id_r <= 8'd4) & (servo_delay_ms >= 1000))) ? 1'b1 : 1'b0;

always@(posedge clk_i) begin
    if(rst_i || !a_en)
        action_alarm <= 1'b0;
    else if(curr_state == S_EXE)
        action_alarm <= 1'b0;
    else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40)
        action_alarm <= 1'b1;
    else if(curr_state == S_IDLE)
        action_alarm <= 1'b0;
end

//debug readback (PS reads via PARAM53):
// [31]    action_beat        (link heartbeat, 20ms toggle)
// [30:27] s2m_state          (receiver 0-14 loop = receiving frames)
// [26:23] m2s_state          (sender 0-14 loop = sending frames)
// [22]    pul_motor_flag_d2  (s2m frame flag, synced)
// [21]    pul_motor_r_flag   (m2s frame trigger)
// [20:17] s2m_10tmp[3:0]     (slave status word {alarm,error,done,busy})
// [16]    action_son         (servo enable state)
// [15:0]  reserved
assign dbg_o = {action_beat, s2m_state, m2s_state, pul_motor_flag_d2, pul_motor_r_flag,
                s2m_10tmp[3:0], action_son, 16'd0};
endmodule
