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


module proactive_beh_sp_rfid#(
    parameter                 	BHA_NUM = 2 
)(
    input                       clk_i
    ,input                      rst_i
    ,input                      i_time_1ms_vld  //ms pulse
    ,input                      i_time_1s_vld   

    ,input      [BHA_NUM-1:0]   pre_sta_allow   
    ,input      [BHA_NUM-1:0]   post_sta_allow  
	
	,input						a_en			
    ,input      [7:0]           a_bhv_id
    ,input                      a_bhv_vld
    ,input      [19:0]          a_tx_ot
    ,input      [31:0]          a_tx_result_rpt	
	,input						a_tx_result_vld
    ,output		                ec_cha_st
    ,output reg [7:0]           a_tx_id
    ,output reg	[7:0]           a_alm_num

	,output reg [7:0]      		a_bhv_id_r		//A channel action ID latch
	,output	reg	[31:0]			state_monitor_o
    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response pulse
	
	,output						o_drv_busy
	,input		[31:0]			i_comp_da
	//parameter
	,input		[7:0]			i_slave_addr
	,input		[31:0]			i_rfid_wdata
	,output		[31:0]			o_rfid_rdata
	,output		[63:0]			o_rfid_uid
	,input						i_slaver_en
	//--- mst 485 interface
    ,input  wire             	i_uart_rx        
    ,output wire             	o_uart_tx        
    ,output wire             	o_uart_de        
	,output wire   				o_user_req       
    ,input  wire     			i_user_grant     
	//--- slv 485 interface
	,input  wire [4:0]       	cur_slv_board_id 
	,input  wire [4:0]       	slv_board_id     
	,input  wire             	rs485_ch_r_flag  
	,output wire [31:0]      	m2s_rs485_msg    
	,input  wire             	rs485_ch_flag    
	,input  wire [31:0]      	s2m_rs485_msg    
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
	
	//---------------------- user define varibal begin ----------------------
	reg 			act_vld			;
	reg  [1:0]		act				;
	wire [63:0]		w_o_uid		    ;
	wire [31:0]		w_o_rdata	    ;
	wire 			w_o_done	    ;
	wire 			w_o_busy	    ;
	wire 			w_o_err	        ;
	wire [7:0]		w_o_err_code    ;
	
	reg 			w_o_done_1d		;	
	
	// 主板本地485驱动(supu_rfid_drv)输出
	wire [63:0]		mst_uid				;
	wire [31:0]		mst_rdata			;
	wire			mst_done			;
	wire			mst_busy			;
	wire			mst_err				;
	wire [7:0]		mst_err_code		;
	// 从板485驱动(supu_rfid_drv_slv)输出
	wire [63:0]		slv_uid				;
	wire [31:0]		slv_rdata			;
	wire			slv_done			;
	wire			slv_busy			;
	wire			slv_err				;
	wire [7:0]		slv_err_code		;
	
	
	//	ila_0 ila_0 (
	//	.clk(clk_i), // input wire clk
    //	
    //	
	//	.probe0(i_uart_rx   ), // input wire [0:0]  probe0  
	//	.probe1(o_uart_tx   ), // input wire [0:0]  probe1 
	//	.probe2(o_uart_de   ), // input wire [0:0]  probe2 
	//	.probe3(o_user_req  ), // input wire [0:0]  probe3 
	//	.probe4(i_user_grant) // input wire [0:0]  probe4
	//	);
	
	//---------------------- user define varibal end ------------------------
	
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
                    next_state = S_EXE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end
			
			S_EXE:begin				//curr_state = 5		
				if(w_o_done)
					case(a_bhv_id_r)
						1,2,3:next_state = S_BHA_POST_DET;
						4:begin 
							if(w_o_rdata == i_comp_da)	//comp success
								next_state = S_BHA_POST_DET;
							else
								next_state = S_ALERT_40;
						end
						default:next_state = S_EXE;
					endcase
				else if(w_o_err)
					next_state = S_ALERT_40;
				else
					next_state = S_EXE;
			end

            S_BHA_POST_DET: begin	//curr_state = 7
				if(post_sta_allow[a_bhv_id_r - 1'b1]) begin
					next_state = S_SUCC_30;
				end else if(timout) begin
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
    end

    //Channel A busy signal
	assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 20 30 40
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
	
	always@(posedge clk_i)begin
        if(rst_i || !a_en)
            a_alm_num <= 8'd0;
		else if(curr_state == S_IDLE)	//clear logic
			a_alm_num <= 8'd0;
		else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)//ps 10 response error num
			a_alm_num <= ack_ps_alart_num; 	
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)//ps 30 response error num
			a_alm_num <= ack_ps_alart_num;	
		else if(curr_state == S_READY_10_ACK && timout)	//ps 10 response timeout
			a_alm_num <= 8'd101; 
		else if(curr_state == S_SUCC_30_ACK && timout)	//ps 30 response timeout
			a_alm_num <= 8'd103; 
		else if(curr_state == S_BHA_PRE_DET && timout)	//Not fully satisfied post-condition
			a_alm_num <= 8'd110; 		//drv busy states
		else if(curr_state == S_ALERT_40 && w_o_done_1d)
			a_alm_num <= 8'd111; 		//action 4 comp fail
		else if(curr_state == S_EXE && w_o_err)
			a_alm_num <= w_o_err_code;
		else
			a_alm_num <= a_alm_num;
    end

    //Timeout count
    always@(posedge clk_i)begin
        if(rst_i || !a_en)
            timout_cnt <= 20'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 20'd0;
        else if(timout_cnt > a_tx_ot)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt > a_tx_ot)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
	
	//======================================================================================================//
	//---------------------------------------------user logic begin-----------------------------------------//
	//======================================================================================================//
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			w_o_done_1d <= 0;
		else
			w_o_done_1d <= w_o_done;
	end
	
	assign o_drv_busy = w_o_busy;
	assign o_rfid_rdata = w_o_rdata;
	assign o_rfid_uid   = w_o_uid;
	
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			act_vld	<= 0;
			act		<= 0;
		end else if(curr_state_1d != curr_state && curr_state == S_EXE)begin
			act_vld	<= 1;
			act		<= (a_bhv_id_r == 4) ? 3 : a_bhv_id_r;
		end else begin
			act_vld	<= 0;
			act		<= (a_bhv_id_r == 4) ? 3 : a_bhv_id_r;
		end
	end
	
	
	//=============== 主板/从板485驱动选择 (i_slaver_en) ===============
	// i_slaver_en=1: 命令走 supu_rfid_drv_slv -> superisys_rfid_485_slaver_driver -> emcc总线 -> 目标从板485口
	// i_slaver_en=0: 命令走 supu_rfid_drv -> 主板本地uart(经RS485_Arbiter仲裁)
	// 只让被选中的驱动收到i_act_vld(未选中的一直空闲), 输出按i_slaver_en选择;
	// 两边行为号->发送帧完全一致(1=写标签 2=读UID 3=读标签; 行为4=读+比对只下发act=3)
	wire	mst_act_vld	= act_vld & ~i_slaver_en;
	wire	slv_act_vld	= act_vld &  i_slaver_en;

	assign w_o_uid      = i_slaver_en ? slv_uid      : mst_uid     ;
	assign w_o_rdata    = i_slaver_en ? slv_rdata    : mst_rdata   ;
	assign w_o_done     = i_slaver_en ? slv_done     : mst_done    ;
	assign w_o_busy     = i_slaver_en ? slv_busy     : mst_busy    ;
	assign w_o_err      = i_slaver_en ? slv_err      : mst_err     ;
	assign w_o_err_code = i_slaver_en ? slv_err_code : mst_err_code;
	
	supu_rfid_drv
	#(
		.CLK_FREQ			(156_250_000 )
		,.UART_BPS			(115_200     )
		,.PARITY			("NONE"      )
		,.RSP_TIMEOUT_MS	(500	     )
		,.GAP_TIMEOUT_MS	(500		     )
		,.GNT_TIMEOUT_MS	(800	     )
	)supu_rfid_drv_u0(
		.i_clk				(clk_i			)
		,.i_rst				(rst_i			)
		,.i_act_vld			(mst_act_vld	)// i_slaver_en=0时才接收命令
		,.i_act				(act			)//1=wr tag 2=rd UID 3=rd tag
		,.i_slave_addr		(i_slave_addr	)
		,.i_wdata			(i_rfid_wdata	)
		,.o_uid				(mst_uid		)
		,.o_rdata			(mst_rdata		)
		,.o_done			(mst_done		)
		,.o_busy			(mst_busy		)
		,.o_err				(mst_err		)
		,.o_err_code		(mst_err_code	)
		,.o_485_bus_req		(o_user_req		)
		,.i_485_bus_grant	(i_user_grant	)
		,.o_rs485_de		(o_uart_de		)
		,.o_uart_tx         (o_uart_tx		)
		,.i_uart_rx         (i_uart_rx		)
	);


	supu_rfid_drv_slv
	#(
		.BAUD_RATE			(20'd115_200	)// 只支持 115200/9600/19200 (驱动内部换算成从板分档)
		,.PARITY			(8'd0			)// 0=无校验 1=奇校验 2=偶校验
		,.RSP_TIMEOUT_MS	(666			)// 响应超时(ms): 含emcc两个轮询周期+从板收发时间+(短帧时)10ms截帧, 与主板版同量级
	)supu_rfid_drv_slv_u0(
		 .i_clk				(clk_i			)
		,.i_rst				(rst_i			)
		,.i_act_vld			(slv_act_vld	)// i_slaver_en=1时才接收命令
		,.i_act				(act			)// 相同行为号发与主板版完全相同的帧
		,.i_slave_addr		(i_slave_addr	)
		,.i_wdata			(i_rfid_wdata	)
		,.o_uid				(slv_uid		)
		,.o_rdata			(slv_rdata		)
		,.o_done			(slv_done		)
		,.o_busy			(slv_busy		)
		,.o_err				(slv_err		)
		,.o_err_code		(slv_err_code	)
		,.i_time_1ms_vld	(i_time_1ms_vld	)
		//--- 从板485通道: 走slave_rs485_arbiter, 上层接ch_rs485_*[板号][槽位] ---
		,.i_cur_slv_board_id	(cur_slv_board_id	)// 本组件挂哪块从板(=ch_board_id[板号])
		,.i_slv_board_id		(slv_board_id		)// emcc读侧当前板号(仲裁器不过滤flag, 由驱动内部比对)
		,.i_cfg_slv_board_id	(cur_slv_board_id	)// 走仲裁器r_flag已按板过滤, 接同值使门控常开; 直连pkg_route时改接slv_cfg_msg_addr高位
		,.i_rs485_ch_r_flag		(rs485_ch_r_flag	)
		,.o_m2s_rs485_msg		(m2s_rs485_msg		)
		,.i_rs485_ch_flag		(rs485_ch_flag		)
		,.i_s2m_rs485_msg		(s2m_rs485_msg		)
	);
	
	
	//======================================================================================================//
	//---------------------------------------------user logic end-------------------------------------------//
	//======================================================================================================//

endmodule