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

module proactive_beh_pul_axis#(
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
    ,input                      irq_ack_i       	//Interrupt response pulse


//----------------------------------------------------- user logic begin -----------------------------------------------------//
    ,input					    i_servo_ready       //servo ready
    ,input					    i_servo_done        //servo move done
    ,input					    i_axis_limf         //axis limit forward
    ,input					    i_axis_zero          //axis origin
    ,input					    i_axis_limb         //axis limit backward
    ,input					    i_emerge_stop_signal//emergency stop signal

   	,input  	                i_dv_alarm			//drive alarm
   	,input  	                i_pause			    //motor pause (B channel beh 100)
   	,input  	                i_stop			    //motor stop (B channel beh 103)
   	,output wire                o_dv_pulse			//axi pulse
   	,output wire                o_dv_dir			//axis dir
    //io port end
    //for post check start
    ,output reg                 action_busy
    ,output reg                 action_done
    ,output reg                 action_error
    //for post check start end
	//register start
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

	,output reg signed [31:0]			r_pf_abspos //postion
	,output wire				o_soft_lim_f		// 1 = abspos >= max pos
	,output wire				o_soft_lim_b		// 1 = abspos <= min pos

    ,input wire                 i_home_completed
    ,input wire                 i_drive_enabled
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );




    wire pos_pf_busy;
    wire i_rc_pulse_busy;
    reg motion_done_latched;
    wire is_move = (a_bhv_id_r == 3) || (a_bhv_id_r == 21);
    wire is_motion = is_move || (a_bhv_id_r == 1) || (a_bhv_id_r == 2) || (a_bhv_id_r == 20);
    wire limits_enabled = rcfg_pos_max > rcfg_pos_min;
    wire target_over_f = is_move && limits_enabled && ($signed(rserv_target_pulse) > rcfg_pos_max);
    wire target_over_b = is_move && limits_enabled && ($signed(rserv_target_pulse) < rcfg_pos_min);
    wire [7:0] launch_alarm = !i_dv_alarm ? 8'd108 :
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
	
	//State machine state
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
	localparam 	S_ACT_END_1		= 8'd12;
	localparam 	S_ACT_END_2		= 8'd13;
    localparam  S_STOP_WAIT     = 8'd14;

    reg action_issued;

    wire [7:0] alert_next = action_issued ? S_STOP_WAIT : S_ALERT_40;
    always @(posedge clk_i) begin
        if(rst_i || curr_state == S_IDLE) action_issued <= 1'b0;
        else if(curr_state == S_EXE && launch_ok) action_issued <= 1'b1;
    end
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
    reg	[7:0]	sta1;
	 //Current behavior number
    always@(posedge clk_i)begin
        if(rst_i)begin
            a_bhv_id_r <= 8'd0;
			a_bhv_vld_r <= 1'b0;
			sta1 <= 0;
		end else 
			case(sta1)
				0:begin
					if(a_en && ((a_bhv_id >= 8'd1) && (a_bhv_id <= BHA_NUM)) && a_bhv_vld)begin
						a_bhv_id_r <= a_bhv_id;
						a_bhv_vld_r <= 1'b1;
						sta1 <= 1;
					end else begin
						a_bhv_id_r <= 8'd0;
						a_bhv_vld_r <= 1'b0;
						sta1 <= 0;
					end
				end
				1:begin
					a_bhv_id_r <= a_bhv_id_r;
					a_bhv_vld_r <= 1'b0;
					sta1 <= 2;
				end
				2:begin
					if(curr_state == S_ACT_END_1)begin
						a_bhv_id_r <= 8'd0;
						a_bhv_vld_r <= 1'b0;
						sta1 <= 0;
					end else begin
						a_bhv_id_r <= a_bhv_id_r;
						a_bhv_vld_r <= 1'b0;
						sta1 <= 2;
					end
				end
				default:begin
					a_bhv_id_r <= 8'd0;
				    a_bhv_vld_r <= 1'b0;
					sta1 <= 0;
				end
			endcase
    end
	
//------------------------------------------- FSM begin => Control 10/20/30/40 interrupt -----------------------------------------------//

	reg match_10;
	//reg match_20;
	reg match_30;
	reg match_40;
	
	always @(posedge clk_i) begin
    if(rst_i) begin
        match_10 <= 1'b0;
		//match_20 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
    end else if(curr_state == S_READY_10_ACK)
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == a_bhv_id_r);
		//match_20 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == a_bhv_id_r);
	else begin
		match_10 <= 1'b0;
		//match_20 <= 1'b0;
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
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = alert_next;
                else
                    next_state = S_READY_10_ACK;
			end

            S_EXE_20: begin			//curr_state = 4						
				next_state = S_EXE;							//Send 20 interrupt
            end
			
			S_EXE:begin				//curr_state = 5								
				next_state = S_BHA_POST_DET;
			end
			
			//S_EXE_20_ACK: begin	//curr_state = 6	
			//	if(match_20) 								//Transaction 20 Acknowledged OK
            //        next_state = S_EXE;
            //    else if(ack_tx_result == IRQ_NO_OK || timout)
            //        next_state = S_ALERT_40;
            //    else
            //        next_state = S_EXE_20_ACK;
			//end
			
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

            S_STOP_WAIT: begin
                next_state = (!action_busy && !pos_pf_busy && !i_rc_pulse_busy) ? S_ALERT_40 : S_STOP_WAIT;
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
        
        if((i_stop | ~i_emerge_stop_signal | launch_fault) && curr_state > S_IDLE && curr_state < S_ALERT_40)
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
        //else if(curr_state == S_EXE_20)
        //    a_tx_id <= 8'd20;
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
		//else if(curr_state == S_EXE_20)
		//	irq_o <= 1'b1;
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
    always @(posedge clk_i) begin
        if(rst_i || curr_state == S_IDLE) a_alm_num <= 0;
        else if(curr_state < S_ALERT_40 && (next_state == alert_next) && next_state != curr_state) begin
            if(is_motion && !i_dv_alarm) a_alm_num <= 8'd108;          // Drive alarm
            else if(is_motion && !i_servo_ready) a_alm_num <= 8'd113;  // Servo not ready
            else if(action_error && i_axis_limf) a_alm_num <= 8'd109;  // Forward limit
            else if(action_error && i_axis_limb) a_alm_num <= 8'd110;  // Backward limit
            else if(i_stop) a_alm_num <= 8'd106;                       // Stop warning
            else if(!i_emerge_stop_signal) a_alm_num <= 8'd107;        // Emergency stop
            else if(launch_fault) a_alm_num <= launch_alarm;        // Launch fault
            else if(curr_state == S_BHA_POST_DET && action_error)
                a_alm_num <= (a_bhv_id_r == 1) ? 8'd120 : is_move ? 8'd122 : 8'd121;
            else if(ack_tx_result == IRQ_NO_OK) a_alm_num <= ack_ps_alart_num; // PS alarm
            else if(curr_state == S_BHA_PRE_DET) a_alm_num <= 8'd100;  // Pre-check timeout
            else if(curr_state == S_READY_10_ACK) a_alm_num <= 8'd101; // Ready ACK timeout
            else if(curr_state == S_BHA_POST_DET) a_alm_num <= motion_done_latched ? 8'd116 : 8'd102;
            else if(curr_state == S_SUCC_30_ACK) a_alm_num <= 8'd103;  // Success ACK timeout
            else a_alm_num <= 8'd105;
        end
    end

    //Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 20'd0;
		else if(!a_en)
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
reg        action_start;
reg        get_postion_flag;
always@(posedge clk_i) begin
    if(rst_i || !a_en) begin
        action_start    <= 1'b0;
    end
    else if(curr_state == S_EXE && launch_ok) begin
        if     (a_bhv_id_r == 8'd1 )  action_start   <= 1'b1;   // Home serch
        else if(a_bhv_id_r == 8'd2 )  action_start   <= 1'b1;   // JOG
        else if(a_bhv_id_r == 8'd3 )  action_start   <= 1'b1;   // Move absul
        else if(a_bhv_id_r == 8'd20)  action_start   <= 1'b1;   // JOG          [safe]
        else if(a_bhv_id_r == 8'd21)  action_start   <= 1'b1;   // Move absul   [safe]
        else if(a_bhv_id_r == 8'd30)  get_postion_flag <= 1'b1;   // Get postion
        else begin
            action_start    <= 1'b0;
            get_postion_flag<= 1'b0;
        end
    end
    else begin
        action_start    <= 1'b0;
        get_postion_flag<= 1'b0;
    end
end

// motion start triggers
wire home_start;
wire jog_start;
wire move_start;
assign home_start = (a_bhv_id_r == 8'd1) ? (action_start && launch_ok) : 1'b0;
assign jog_start  = ((a_bhv_id_r == 8'd2)||(a_bhv_id_r == 8'd20)) ? (action_start && launch_ok) : 1'b0;
assign move_start = launch_ok && ((a_bhv_id_r == 8'd3)||(a_bhv_id_r == 8'd21)) ? (action_start && launch_ok) : 1'b0;

// axis_org register
reg axis_org;
always@(posedge clk_i) begin
    if(rst_i)
        axis_org <= 1'b0;
    else
        axis_org <= i_axis_zero;
end

// common params
localparam DIR_POS = 1'b1;
localparam DIR_NEG = 1'b0;

wire r_dv_ok = i_servo_ready & i_dv_alarm;//estop and alarm active low, add by szzhang 20260914

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

// HOME (beh=1)
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
wire         home_pf_touchstop;

wire         pos_pf_done;
wire         pos_pf_error;

Home_fa_std
home_u
(
  .clk            ( clk_i              ),
  .reset          ( rst_i              ),

  .i_drv_son      ( r_dv_ok           ),
  .i_lim_f        ( i_axis_limf        ),
  .i_lim_b        ( i_axis_limb        ),
  .i_org          ( axis_org           ),
  .i_pf_spd       ( home_spd_eff       ),
  .i_spd_min      ( touch_spd_eff      ),
  .i_pf_acc       ( home_acc_eff       ),
  .i_pf_dec       ( home_dec_eff       ),
  .i_pf_dir       ( DIR_NEG            ),
  .i_start        ( home_start         ),
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
  .o_pf_touchstop ( home_pf_touchstop  ),
  .i_pf_busy      ( pos_pf_busy        ),
  .i_pf_done      ( pos_pf_done        )
);
wire        w_soft_lim_en = (rcfg_pos_max > rcfg_pos_min) && ~home_busy;
assign      w_soft_lim_f  = w_soft_lim_en && (r_pf_abspos >= rcfg_pos_max);
assign      w_soft_lim_b  = w_soft_lim_en && (r_pf_abspos <= rcfg_pos_min);
wire signed [31:0] s_move_tgt = rserv_target_pulse;
wire        w_move_over_f = w_soft_lim_en && (s_move_tgt > rcfg_pos_max);
wire        w_move_over_b = w_soft_lim_en && (s_move_tgt < rcfg_pos_min);
wire        w_jog_lim_f   = i_axis_limf;
wire        w_jog_lim_b   = i_axis_limb;
wire        w_move_lim_f  = i_axis_limf;
wire        w_move_lim_b  = i_axis_limb;
assign      w_sw_move     = (a_bhv_id_r == 8'd3) || (a_bhv_id_r == 8'd21);
assign o_soft_lim_f = w_soft_lim_f;
assign o_soft_lim_b = w_soft_lim_b;

// JOG (beh=2;20)
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

Jog_fa_std jog_u
(
  .clk            ( clk_i              ),
  .reset          ( rst_i              ),

  .i_drv_son      ( r_dv_ok           ),
  .i_lim_f        ( w_jog_lim_f        ),
  .i_lim_b        ( w_jog_lim_b        ),
  .i_org          ( axis_org           ),
  .i_pf_spd       ( jog_spd_eff        ),
  .i_pf_acc       ( jog_acc_eff        ),
  .i_pf_dec       ( jog_dec_eff        ),
  .i_pf_pulse     ( rserv_step_pulse   ),
  .i_pf_dir       ( rserv_dir          ),
  .i_start        ( jog_start          ),
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

// MOVE (beh=3;21)
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

Move_fa_std move_u
(
  .clk            ( clk_i              ),
  .reset          ( rst_i              ),

  .i_drv_son      ( r_dv_ok           ),
  .i_lim_f        ( w_move_lim_f       ),
  .i_lim_b        ( w_move_lim_b       ),
  .i_org          ( axis_org           ),
  .i_abspos       ( r_pf_abspos        ),
  .i_pf_spd       ( move_spd_eff       ),
  .i_pf_acc       ( move_acc_eff       ),
  .i_pf_dec       ( move_dec_eff       ),
  .i_pf_pulse     ( rserv_target_pulse ),
  .i_start        ( move_start         ),
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

wire hard_abort;
wire motion_pause;
// Positioner
reg  [31:0]  pos_pf_spd;
reg  [31:0]  pos_pf_acc;
reg  [31:0]  pos_pf_dec;

wire [32:0]  home_touch_dec_2x = {home_dec_eff, 1'b0};
wire [31:0]  home_touch_dec = (home_touch_dec_2x > {1'b0, dec_max_eff})
                            ? dec_max_eff 
                            : home_touch_dec_2x[31:0];
wire [31:0]  pos_quickstop_dec = ((a_bhv_id_r == 8'd1) && home_pf_touchstop)
                              ? home_touch_dec 
                              : dec_max_eff;
reg          pos_quickstop;
reg  [31:0]  pos_pf_mode;
reg          pos_pf_start;
reg          pos_pf_stop;
reg          pos_pf_dir;
reg  [31:0]  pos_pf_pulse;

wire         o_rc_pulse_start;
wire [31:0]  o_rc_pulse_period;
wire [31:0]  o_rc_pulse_number;
wire         o_rc_pulse_dir;
wire         i_rc_pulse_done;


Positioner_std #(.USE_ABORT(1), .BASE_REFCLK(156_250_000)) pos_u
(
  .clk            ( clk_i              ),
  .reset          ( rst_i              ),
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
  .i_pulse_done   ( i_rc_pulse_done    ),
  .i_pulse_busy   ( i_rc_pulse_busy    )
);

// Pulmot_fd pulse generator
Pulmot_fd #(.USE_PAUSE(1), .USE_ABORT(1)) Pulmot_fd00
(
  .clk              ( clk_i              ),
  .reset            ( rst_i              ),

  .i_bv_pulse_start ( o_rc_pulse_start ),
  .i_bv_pulse_period( o_rc_pulse_period  ),
  .i_bv_pulse_number( o_rc_pulse_number  ),
  .i_bv_pulse_dir   ( o_rc_pulse_dir     ),
  .o_bv_pulse_done  ( i_rc_pulse_done    ),
  .o_bv_pulse_busy  ( i_rc_pulse_busy    ),
  .i_abort          ( hard_abort ),
  .i_pause          ( 1'b0            ),

  .i_dv_ready       ( 1'b0               ),
  .i_dv_inp         ( 1'b0               ),
  .i_dv_phase_a     ( 1'b0               ),
  .i_dv_phase_b     ( 1'b0               ),
  .i_dv_phase_z     ( 1'b0               ),
  .o_dv_pulse_p     ( o_dv_pulse         ),
  .o_dv_pulse_n     ( o_dv_dir           )
);

reg action_alarm;
wire stop_request = action_alarm || i_stop || !i_emerge_stop_signal || !i_drive_enabled || !a_en;
assign hard_abort = !r_dv_ok || (i_axis_limf && pos_pf_dir) || (i_axis_limb && !pos_pf_dir);
assign motion_pause = i_pause && !stop_request && !hard_abort;

wire raw_done = home_done || jog_done || move_done;
wire raw_error = home_error || jog_error || move_error || pos_pf_error;
// action status 

always @(posedge clk_i) begin
    if(rst_i) begin
        action_busy <= 0;
        action_done <= 0;
        motion_done_latched <= 0;
        action_error <= 0;
        home_stop <= 0;
        jog_stop <= 0;
        move_stop <= 0;
    end else begin
        action_busy <= home_busy || jog_busy || move_busy || pos_pf_busy || i_rc_pulse_busy;
        home_stop <= stop_request;
        jog_stop <= stop_request;
        move_stop <= stop_request;
        if(a_bhv_vld_r || action_start) begin
            action_done <= 0;
            motion_done_latched <= 0;
            action_error <= 0;
        end else begin
            if(raw_done) motion_done_latched <= 1;
            if((motion_done_latched || raw_done) && i_servo_done && !action_error && !raw_error)
                action_done <= 1;
            if(raw_error || ((pos_pf_busy || i_rc_pulse_busy) && hard_abort &&
                (!r_dv_ok || a_bhv_id_r != 1 || !home_limit_recover))) begin
                action_error <= 1;
                action_done <= 0;
            end
        end
    end
end

// data mux
always@(*) begin
    case(a_bhv_id_r)
        8'd1: begin
            pos_pf_spd    = home_pf_spd   > spd_max_eff ? spd_max_eff :home_pf_spd;
            pos_pf_acc    = home_pf_acc   > acc_max_eff ? acc_max_eff :home_pf_acc;
            pos_pf_dec    = home_pf_dec   > dec_max_eff ? dec_max_eff :home_pf_dec;
            pos_pf_mode   = 32'h00;   // home
            pos_pf_pulse  = home_pf_pulse;
            pos_pf_start  = home_pf_start;
            pos_pf_stop   = home_pf_stop;
            pos_pf_dir    = home_pf_dir;
            pos_quickstop = home_pf_quickstop;
        end
        8'd2, 8'd20: begin
            pos_pf_spd    = jog_pf_spd    > spd_max_eff ? spd_max_eff :jog_pf_spd;
            pos_pf_acc    = jog_pf_acc    > acc_max_eff ? acc_max_eff :jog_pf_acc;
            pos_pf_dec    = jog_pf_dec    > dec_max_eff ? dec_max_eff :jog_pf_dec;
            pos_pf_mode   = 32'h01;   // jog
            pos_pf_pulse  = jog_pf_pulse;
            pos_pf_start  = jog_pf_start;
            pos_pf_stop   = jog_pf_stop;
            pos_pf_dir    = jog_pf_dir;
            pos_quickstop = jog_pf_quickstop;
        end
        8'd3, 8'd21: begin
            pos_pf_spd    = move_pf_spd   > spd_max_eff ? spd_max_eff :move_pf_spd;
            pos_pf_acc    = move_pf_acc   > acc_max_eff ? acc_max_eff :move_pf_acc;
            pos_pf_dec    = move_pf_dec   > dec_max_eff ? dec_max_eff :move_pf_dec;
            pos_pf_mode   = 32'h01;   // move
            pos_pf_pulse  = move_pf_pulse;
            pos_pf_start  = move_pf_start;
            pos_pf_stop   = move_pf_stop;
            pos_pf_dir    = move_pf_dir;
            pos_quickstop = move_pf_quickstop;
        end
        default: begin
            pos_pf_spd    = 32'd0;
            pos_pf_acc    = 32'd0;
            pos_pf_dec    = 32'd0;
            pos_pf_mode   = 32'd0;
            pos_pf_pulse  = 32'd0;
            pos_pf_start  = 1'b0;
            pos_pf_stop   = 1'b0;
            pos_pf_dir    = 1'b0;
            pos_quickstop = 1'b0;
        end
    endcase
end

// absolute position tracking
reg home_pos_reset;
always@(posedge clk_i) begin
    if(rst_i || home_busy)
        home_pos_reset <= 1'b0;
    else if(home_done & ~home_busy & ~home_error)
        home_pos_reset <= 1'b1;
    else 
        home_pos_reset <= home_pos_reset;
end

// track physical pulse edges, not command cycles, change by szzhang 20260913
reg  r_dv_pls_d;
always@(posedge clk_i) r_dv_pls_d <= rst_i ? 1'b1 : o_dv_pulse;
wire w_dv_pls_rise = o_dv_pulse & ~r_dv_pls_d;

always@(posedge clk_i) begin
    if(rst_i)
        r_pf_abspos <= 32'd0;
    else begin
        if(home_done & ~home_busy & ~home_error & ~home_pos_reset)
            r_pf_abspos <= 32'd0;
        else if(w_dv_pls_rise)
            r_pf_abspos <= (o_dv_dir == DIR_POS) ? r_pf_abspos + 1'b1 : r_pf_abspos - 1'b1;
        else
            r_pf_abspos <= r_pf_abspos;

    end
end

always@(posedge clk_i) begin
    if(rst_i || !a_en)
        action_alarm <= 1'b0;
    else if(curr_state == S_EXE && launch_ok)
        action_alarm <= 1'b0;
    else if(curr_state == S_ALERT_40 || curr_state == S_STOP_WAIT)
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
