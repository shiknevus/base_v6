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
    parameter                 	BHA_NUM 		= 2   //Number of active behaviors
	,parameter					ARV_SIG_DET_TIM	= 5
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

    ,input  	                i_safe_status 
    ,input  	                i_axis_limf     
    ,input  	                i_axis_limb     
    ,input  	                i_axis_org
    ,input  	                i_axis_point
    ,input  	                i_axis_reset
    ,input  	                i_servo_notok
    ,input  	                i_servo_stop
    ,input  	                i_dv_alarm
    ,output reg                 o_dv_pulse
    ,output reg                 o_dv_dir
    ,output reg                 o_dv_reset
    ,output reg                 o_dv_son
    ,input  	 [7:0]          set_wheel_gear
    ,input  	 [3:0]          i_wheel_prog
    ,input  	                i_wheel_run
    ,input  	                i_wheel_dir
    ,input  	 [15:0]         i_wheel_speed

    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response
	,output reg [31:0]			state_monitor_o
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
	
	reg	[7:0]	detect_tim;	//s
	reg			detect_flag;
	
	
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
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
    //Current behavior number
    always@(posedge clk_i)begin
        if(rst_i)
            a_bhv_id_r <= 8'd0;
        else if(a_bhv_vld)
            a_bhv_id_r <= a_bhv_id;
        else
            a_bhv_id_r <= a_bhv_id_r;
    end

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
            S_IDLE: 
			begin	//0
                if (a_en && a_bhv_id != 8'd0 && a_bhv_vld)    //ps behavior execution instruction
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end

            S_BHA_PRE_DET: 
			begin	//1
                if ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM ) && pre_sta_allow[a_bhv_id_r - 1])
                    next_state = S_READY_10;
                else if(timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_BHA_PRE_DET;
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
				if(detect_flag) begin
                	if ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM ) && post_sta_allow[a_bhv_id_r - 1])
                    	next_state = S_SUCC_30;
                	else
                    	next_state = S_ALERT_40;
				end
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

    //Channel A busy signal
	assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 20 30 40
    always@(posedge clk_i)begin
        if(rst_i)
            a_tx_id <= 8'd0;
		else if(!a_en)
			a_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        //else if(curr_state == S_EXE_20)
        //    a_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            a_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            a_tx_id <= 8'd40;
		else if(match_40)
			a_tx_id <= 8'd0;
        else
            a_tx_id <= a_tx_id;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            irq_o <= 1'b0;
		else if(!a_en)
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
        if(rst_i)
            a_alm_num <= 8'd0;
		else if(!a_en)
			a_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)						//The pre - full inspection is not met.
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
		else if(match_40)
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

	always@(posedge clk_i)
	begin
    	if(rst_i) begin
    	    detect_tim  <= 8'd0;
    	    detect_flag <= 1'b0;
    	end
    	else if(curr_state != S_BHA_POST_DET) begin
    	    detect_tim  <= 8'd0;
    	    detect_flag <= 1'b0;
    	end
    	else begin
    	    if(detect_tim >= ARV_SIG_DET_TIM - 1'b1) begin
    	        detect_tim  <= detect_tim; 
    	        detect_flag <= 1'b1;  
    	    end
    	    else begin
    	        //detect_tim  <= detect_tim + i_time_1s_vld;	//actual
				detect_tim  <= detect_tim + 1;	//sim
    	        detect_flag <= 1'b0;	
    	    end
    	end
	end
	
	
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en)
			do_o <= 2'b00;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd1)		//Drive to position 1
			do_o <= 2'b01;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd2)		//Drive to position 2
			do_o <= 2'b10;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd3)		//invalid behavior 
			do_o <= 2'b00;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd4)		//Sense position 1
			do_o <= 2'b00;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd5)		//Sense position 2
			do_o <= 2'b00;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd6)		//Drive to direction 1
			do_o <= 2'b01;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd7 )		//Drive to direction 2
			do_o <= 2'b10; 
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd8 )		//Sense hook 1
			do_o <= 2'b00; 
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd9 )		//Sense hook 0
			do_o <= 2'b00; 
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd10)		//Drive to position 1 [safe]
			do_o <= 2'b01;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd11)		//Drive to position 2 [safe]
			do_o <= 2'b10;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd12)		//Drive to direction 1 [safe]
			do_o <= 2'b01;
		else if(curr_state == S_EXE && a_bhv_id_r == 8'd13)		//Drive to direction 2 [safe]
			do_o <= 2'b10;
		else
			do_o <= do_o;
	end


	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================
	localparam P_EN_EFF     	  = 1'b0;
   	localparam P_RST_EFF      = 1'b0;
   	assign o_dv_son   =  i_auto_manual_singal ? ~P_EN_EFF : rctrl_drive_on ? (bh_disable ? ~P_EN_EFF : P_EN_EFF) : ~P_EN_EFF;
   	assign o_dv_reset = (rctrl_drive_reset | i_axis_reset) ? P_RST_EFF : ~P_RST_EFF;
   

   	reg              i_wheel_enable;
   	wire             i_wheel_work;
   	assign   i_wheel_work = i_wheel_run & i_wheel_enable;
   	assign   i_switch_man = (i_wheel_prog==0) ? 1'b0 : 1'b1;
   	always@(posedge clk) begin
   	    if((i_wheel_prog==0) | (i_wheel_prog==15)) begin
   	        i_wheel_enable <= 1'b0;
   	    end else if(set_wheel_gear[i_wheel_prog-1]) begin
   	        i_wheel_enable <= 1'b1;
   	    end else begin
   	        i_wheel_enable <= 1'b0;
   	    end
   	end

   	wire wheel_son = ((curr_beh_number == 1) & i_switch_man) ? 1'b1 : 1'b0;


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
      .o_dv_pulse_p     ( o_dv_pulse         ),
      .o_dv_pulse_n     ( o_dv_dir           )
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
      .clk            ( clk               ),
      .reset          ( reset             ),
      .i_pf_spd       ( pos_pf_spd        ),
      .i_pf_acc       ( pos_pf_acc        ),
      .i_pf_dec       ( pos_pf_dec        ),
      .i_pf_mode      ( pos_pf_mode       ),
      .i_pf_start     ( pos_pf_start      ),
      .i_pf_stop      ( pos_pf_stop       ),
      .i_pf_dir       ( pos_pf_dir        ),
      .i_pf_pulse     ( pos_pf_pulse      ),
      .i_quickstop    ( pos_quickstop     ),
      .i_quickstop_dec( pos_quickstop_dec ),
      .o_pf_done      ( pos_pf_done       ),
      .o_pf_error     ( pos_pf_error      ),
      .o_pf_busy      ( pos_pf_busy       ),
      .o_pulse_start  ( o_rc_pulse_start  ),
      .o_pulse_period ( o_rc_pulse_period ),
      .o_pulse_number ( o_rc_pulse_number ),
      .o_pulse_dir    ( o_rc_pulse_dir    ),
      .i_pulse_done   ( i_rc_pulse_done   )
   );
   
    /// -------------------------------------------------------------------------
   /// -------------------------------------------------------------------------
   /// -------------------------------------------------------------------------
   wire         home_start;
   reg axis_org;
   `ifdef ENB_SIM_MODULE
       reg sim_start_n;
       wire sim_start = (sim_start_n ==0) && (home_start==1);
       reg [3:0]sim_state;
       reg [15:0]sim_org_cnt;
       always @ (posedge clk)
       begin
          if(reset)begin
            sim_start_n <= 'b0;
            sim_org_cnt <= 'b0;
            sim_state <= 'b0;
            axis_org <= 'b0;
          end else begin
            sim_start_n <= home_start;
            case(sim_state)
                0:begin
                    if(sim_start)sim_state<=1;
                    else sim_state <= 0;
                    sim_org_cnt <= 0;
                    axis_org <= 0;
                end
                1:begin
                    if(sim_org_cnt < 1000)begin
                        sim_org_cnt <= sim_org_cnt + i_time_1ms_vld;
                        sim_state <= sim_state;
                    end else begin
                        sim_state <= sim_state + 1;
                        sim_org_cnt <= 0;
                    end
                    axis_org <= 0;
                end
                2:begin
                    if(sim_org_cnt < 1000)begin
                        sim_org_cnt <= sim_org_cnt + i_time_1ms_vld;
                        sim_state <= sim_state;
                    end else begin
                        sim_state <= sim_state + 1;
                        sim_org_cnt <= 0;
                    end
                    axis_org <= 1;
                end
                3:begin
                    sim_org_cnt <= 'b0;
                    sim_state <= 'b0;
                    axis_org <= 'b0;
                end
                default:begin
                    sim_org_cnt <= 'b0;
                    sim_state <= 'b0;
                    axis_org <= 'b0;
                end
            endcase
          end
       end
   `else
       always @(posedge clk) begin
           axis_org <= i_axis_org;
       end
   `endif
   /// -------------------------------------------------------------------------
   /// -------------------------------------------------------------------------
   /// -------------------------------------------------------------------------
   
   ////////////////// HOME
//   wire         home_start;
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

    localparam DIR_POS  	      = 1'b1;
    localparam DIR_NEG    	      = 1'b0;
    localparam P_SPD_MIN    	  = 32'd5000;      // pulse/s
   Home_fa_std #(P_SPD_MIN/1000)
   home_u
   (
      .clk            ( clk               ),
      .reset          ( reset             ),
      
      .i_drv_son      ( action_son           ),
      .i_lim_f        ( i_axis_limf       ),
      .i_lim_b        ( i_axis_limb       ),
      .i_org          ( axis_org          ),
      .i_pf_spd       ( rcfg_home_spd     ),
      .i_pf_acc       ( rcfg_home_acc     ),
      .i_pf_dec       ( rcfg_home_dec     ),
      .i_pf_dir       ( DIR_NEG           ),
      .i_start        ( home_start    	  ),
      .i_stop         ( home_stop         ),
      .o_busy         ( home_busy         ),
      .o_done         ( home_done         ),
      .o_error        ( home_error        ),
      .o_pf_spd       ( home_pf_spd       ),
      .o_pf_acc       ( home_pf_acc       ),
      .o_pf_dec       ( home_pf_dec       ),
      .o_pf_pulse     ( home_pf_pulse     ),
      .o_pf_dir       ( home_pf_dir       ),
      .o_pf_start     ( home_pf_start     ),
      .o_pf_stop      ( home_pf_stop      ),
      .o_pf_quickstop ( home_pf_quickstop ),
      .i_pf_busy      ( pos_pf_busy       ),
      .i_pf_done      ( pos_pf_done       )
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
      .clk            ( clk              ),
      .reset          ( reset            ),
      
      .i_drv_son      ( action_son          ),
      .i_lim_f        ( i_axis_limf      ),
      .i_lim_b        ( i_axis_limb      ),
      .i_org          ( axis_org         ),
      .i_pf_spd       ( rcfg_jog_spd     ),
      .i_pf_acc       ( rcfg_jog_acc     ),
      .i_pf_dec       ( rcfg_jog_dec     ),
      .i_pf_pulse     ( rserv_step_pulse ),
      .i_pf_dir       ( rserv_dir        ),
      .i_start        ( jog_start   	 ),
      .i_stop         ( jog_stop         ),
      .o_busy         ( jog_busy         ),
      .o_done         ( jog_done         ),
      .o_error        ( jog_error        ),
      .o_pf_spd       ( jog_pf_spd       ),
      .o_pf_acc       ( jog_pf_acc       ),
      .o_pf_dec       ( jog_pf_dec       ),
      .o_pf_pulse     ( jog_pf_pulse     ),
      .o_pf_dir       ( jog_pf_dir       ),
      .o_pf_start     ( jog_pf_start     ),
      .o_pf_stop      ( jog_pf_stop      ),
      .o_pf_quickstop ( jog_pf_quickstop ),
      .i_pf_busy      ( pos_pf_busy      ),
      .i_pf_done      ( pos_pf_done      )
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

   
   reg signed [31:0]  r_pf_abspos;
   Move_fa_std	move_u
   (
      .clk            ( clk                ),
      .reset          ( reset              ),
      
      .i_drv_son      ( action_son            ),
      .i_lim_f        ( i_axis_limf        ),
      .i_lim_b        ( i_axis_limb        ),
      .i_org          ( axis_org           ),
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


endmodule