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

   	,input  	                i_safe_status 		//safe status
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
	

	,output reg signed [31:0]			r_pf_abspos //postion
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );




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
					a_bhv_id_r <= a_bhv_id;
					a_bhv_vld_r <= 1'b0;
					sta1 <= 2;
				end
				2:begin
					if(curr_state == S_ACT_END_1)begin
						a_bhv_id_r <= 8'd0;
						a_bhv_vld_r <= 1'b0;
						sta1 <= 0;
					end else begin
						a_bhv_id_r <= a_bhv_id;
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
			
			//S_EXE_20_ACK: begin	//curr_state = 6	
			//	if(match_20) 								//Transaction 20 Acknowledged OK
            //        next_state = S_EXE;
            //    else if(ack_tx_result == IRQ_NO_OK || timout)
            //        next_state = S_ALERT_40;
            //    else
            //        next_state = S_EXE_20_ACK;
			//end
			
            S_BHA_POST_DET: begin	//curr_state = 7
				if(post_sta_allow[a_bhv_id_r - 1'b1]) begin
                    	next_state = S_SUCC_30;
				end else if(timout | action_error) begin
                            next_state = S_ALERT_40;
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
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
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
        // interrupt: i_stop forces A FSM to ALERT_40 (reported with alarm)
        if(i_stop && curr_state != S_IDLE)
            next_state = S_ALERT_40;
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
	
	always@(posedge clk_i)begin
        if(rst_i || !a_en)
            a_alm_num <= 8'd0;
        else if(i_stop && curr_state != S_IDLE)
            a_alm_num <= 8'd156;   // stop 
        else if(curr_state == S_BHA_PRE_DET && timout)
            a_alm_num <= 8'd151;
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)				
            a_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)									
            a_alm_num <= 8'd152;    
		//else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)				
        //    a_alm_num <= ack_ps_alart_num;    
        //else if(curr_state == S_EXE_20_ACK && timout)									
        //    a_alm_num <= 8'd103;    
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
    else if(curr_state == S_EXE) begin
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
assign home_start = (a_bhv_id_r == 8'd1) ? action_start : 1'b0;
assign jog_start  = ((a_bhv_id_r == 8'd2)||(a_bhv_id_r == 8'd20)) ? action_start : 1'b0;
assign move_start = ((a_bhv_id_r == 8'd3)||(a_bhv_id_r == 8'd21)) ? action_start : 1'b0;

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

// 0 register -> default
function [31:0] zdef(input [31:0] v, input [31:0] d);
    zdef = (v == 32'b0) ? d : v;
endfunction

wire [31:0] home_spd_eff  = zdef(rcfg_home_spd,  32'd1000000); // 20mm/s
wire [31:0] home_acc_eff  = zdef(rcfg_home_acc,  32'd2500000); // 50mm/s2
wire [31:0] home_dec_eff  = zdef(rcfg_home_dec,  32'd2500000);
wire [31:0] jog_spd_eff   = zdef(rcfg_jog_spd,   32'd1000000);
wire [31:0] jog_acc_eff   = zdef(rcfg_jog_acc,   32'd2500000);
wire [31:0] jog_dec_eff   = zdef(rcfg_jog_dec,   32'd2500000);
wire [31:0] move_spd_eff  = zdef(rcfg_move_spd,  32'd1000000);
wire [31:0] move_acc_eff  = zdef(rcfg_move_acc,  32'd2500000);
wire [31:0] move_dec_eff  = zdef(rcfg_move_dec,  32'd2500000);
wire [31:0] spd_max_eff   = zdef(rcfg_spd_max,   32'd4000000); // 80mm/s
wire [31:0] acc_max_eff   = zdef(rcfg_acc_max,   32'd10000000);// 200mm/s2
wire [31:0] dec_max_eff   = zdef(rcfg_dec_max,   32'd10000000);
wire [31:0] touch_spd_eff = zdef(rcfg_touch_spd, 32'd5000);

// HOME (beh=1)
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
wire         pos_pf_busy;
wire         pos_pf_done;
wire         pos_pf_error;

Home_fa_std
home_u
(
  .clk            ( clk_i              ),
  .reset          ( rst_i              ),

  .i_drv_son      ( 1'b1               ),
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

  .i_drv_son      ( 1'b1               ),
  .i_lim_f        ( i_axis_limf        ),
  .i_lim_b        ( i_axis_limb        ),
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

  .i_drv_son      ( 1'b1               ),
  .i_lim_f        ( i_axis_limf        ),
  .i_lim_b        ( i_axis_limb        ),
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

// Positioner
reg  [31:0]  pos_pf_spd;
reg  [31:0]  pos_pf_acc;
reg  [31:0]  pos_pf_dec;
wire [31:0]  pos_quickstop_dec = dec_max_eff;
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

Positioner_std pos_u
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
  .i_pause        ( i_pause            ),
  .o_pf_done      ( pos_pf_done        ),
  .o_pf_error     ( pos_pf_error       ),
  .o_pf_busy      ( pos_pf_busy        ),
  .o_pulse_start  ( o_rc_pulse_start   ),
  .o_pulse_period ( o_rc_pulse_period  ),
  .o_pulse_number ( o_rc_pulse_number  ),
  .o_pulse_dir    ( o_rc_pulse_dir     ),
  .i_pulse_done   ( i_rc_pulse_done    )
);

// Pulmot_fd pulse generator
Pulmot_fd Pulmot_fd00
(
  .clk              ( clk_i              ),
  .reset            ( rst_i              ),

  .i_bv_pulse_start ( i_pause ? 1'b0 : o_rc_pulse_start ),
  .i_bv_pulse_period( o_rc_pulse_period  ),
  .i_bv_pulse_number( o_rc_pulse_number  ),
  .i_bv_pulse_dir   ( o_rc_pulse_dir     ),
  .o_bv_pulse_done  ( i_rc_pulse_done    ),

  .i_dv_ready       ( 1'b0               ),
  .i_dv_inp         ( 1'b0               ),
  .i_dv_phase_a     ( 1'b0               ),
  .i_dv_phase_b     ( 1'b0               ),
  .i_dv_phase_z     ( 1'b0               ),
  .o_dv_pulse_p     ( o_dv_pulse         ),
  .o_dv_pulse_n     ( o_dv_dir           )
);

// action status 
reg  action_alarm;
always@(posedge clk_i) begin
    if(rst_i) begin
        action_busy  <= 1'b0;
        action_done  <= 1'b0;
        action_error <= 1'b0;
    end else begin
        case(a_bhv_id_r)
            8'd1: begin
                action_busy  <= home_busy;
                action_done  <= home_done;
                action_error <= home_error;
                home_stop    <= action_alarm | i_stop;
            end
            8'd2, 8'd20 : begin
                action_busy  <= jog_busy;
                action_done  <= jog_done;
                action_error <= jog_error;
                jog_stop     <= action_alarm | i_stop;
            end
            8'd3, 8'd21 : begin
                action_busy  <= move_busy;
                action_done  <= move_done;
                action_error <= move_error;
                move_stop    <= action_alarm | i_stop;
            end
            default: begin
                action_busy  <= 1'b0;
                action_done  <= 1'b0;
                action_error <= 1'b0;
            end
        endcase
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

always@(posedge clk_i) begin
    if(rst_i)
        r_pf_abspos <= 32'd0;
    else begin
        if(home_done & ~home_busy & ~home_error & ~home_pos_reset)
            r_pf_abspos <= 32'd0;
        else if(i_rc_pulse_done & o_rc_pulse_start)
            r_pf_abspos <= (o_rc_pulse_dir == DIR_POS) ? r_pf_abspos + 1'b1 : r_pf_abspos - 1'b1;
        else
            r_pf_abspos <= r_pf_abspos;
            
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
//==============================================================================================================================//
//----------------------------------------------------- user logic end -------------------------------------------------------//
//==============================================================================================================================//

endmodule
