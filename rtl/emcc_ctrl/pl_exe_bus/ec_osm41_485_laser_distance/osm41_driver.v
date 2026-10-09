`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/08/14 08:14:55
// Design Name: 
// Module Name: osm41_driver
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
//baud: 115200
//8N1

module osm41_driver(
	 input					i_clk
	,input					i_rst
	
	,input					i_485_bus_grant
	,output 	reg			o_485_bus_req	 
	
	,input					i_485_rx
	,output					o_485_tx
	,output 	reg			o_485_de
	
	,input					i_time_1ms_vld
	,input					i_sample_start
	,input			[7:0]	i_485_addr
	,output					o_ready
	,output 	reg [15:0]	o_user_da		//distance
	,output		reg			o_user_da_vld	//distance vld
	//debug signal
	,output			[7:0]	o_sta
    );
	
	reg 			uart_tx_vld	;
	reg 	[7:0]	uart_tx_da	;
	wire 			uart_tx_done;
	
	wire 			uart_rx_done;
	wire 	[7:0]	uart_rx_da  ;
	
	wire	[15:0]	tx_da_cs;
	reg		[15:0]	rx_da_cs;
	
	reg		[7:0]	slv_485_addr;
	
	reg				rx_vld_r;
	reg				rx_vld_r_1d;
	reg				rx_vld_r_2d;
	reg				rx_vld_r_3d;

	reg		[7:0]	da_reg	[8:0];
	reg		[7:0]	sta;
	
	reg				ri_sample_start;
	reg				sample_start_posedge;

	//------ reply timeout ------
	//Frame send done -> no valid reply frame within REPLY_TIMEOUT_MS -> release bus request,
	//prevent o_485_bus_req held forever and occupy the 485 bus when sensor is absent/quiet.
	//note: 9 bytes reply frame needs about 0.8ms at 115200bps, plus sensor conversion time,
	//      so 20ms is safe; raise it only if the sensor datasheet conversion time exceeds this.
	//      (2000ms was a debug leftover - it parked the shared rs485_1 arbiter for 2s per query.)
	localparam				RX_TIMEOUT_MS	= 20;	//unit: ms
	reg		[15:0]			rx_timeout_cnt;
	wire					rx_timeout;
		
	assign	tx_da_cs = slv_485_addr+8'h3;
	
	assign o_sta = sta;	//debug
	
	//------ 485 tx --------
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			o_485_bus_req <= 0;
		else if(sample_start_posedge)
			o_485_bus_req <= 1;
		else if(o_user_da_vld || rx_timeout)	//reply ok or timeout, release bus
			o_485_bus_req <= 0;
		else
			o_485_bus_req <= o_485_bus_req;
	end

	
	always@(posedge i_clk)
	begin
		ri_sample_start <= i_sample_start;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			sample_start_posedge <= 0;
		else if({ri_sample_start != i_sample_start} && ri_sample_start == 0)
			sample_start_posedge <= 1;
		else
			sample_start_posedge <= 0;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)begin
			sta <= 0;
			uart_tx_vld <= 0;
			uart_tx_da <= 0;
			o_485_de <= 0;
			slv_485_addr <= 0;
		end else
			case(sta)
				0:begin
					uart_tx_vld <= 0;
					uart_tx_da <= 0;
					o_485_de <= 0;
					
					if(sample_start_posedge)begin		//start	posedge
						sta <= 20;
						slv_485_addr <= i_485_addr;
					end else begin
						sta <= 0;
						//note: keep slv_485_addr here! state 0 is also the reply-wait state,
						//clearing it makes the reply address match always compare with 0.
					end
				end
				20:begin
					sta <= 21;
				end
				21:begin
					if(i_485_bus_grant)
						sta <= 1;
					else
						sta <= 21;
				end
				1:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= 8'h68;	//frame head: 0x68
					o_485_de <= 1;
					sta <= 2;
				end
				2:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)
						sta <= 3;
				end
				3:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= slv_485_addr;	//addr
					sta <= 4;
				end
				4:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)
						sta <= 5;
				end
				5:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= 8'h03;	//byte num
					sta <= 6;
				end
				6:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)
						sta <= 7;
				end
				7:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= 8'h00;	//read distance function
					sta <= 8;
				end
				8:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)
						sta <= 9;
				end
				9:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= tx_da_cs[7:0];	//cs
					sta <= 10;
				end
				10:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)
						sta <= 11;
				end
				11:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= tx_da_cs[15:8];	//cs
					sta <= 12;
				end
				12:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)
						sta <= 13;
				end
				13:begin	
					uart_tx_vld <= 1;
					uart_tx_da <= 8'h16;		//frame end
					sta <= 14;
				end
				14:begin
					uart_tx_vld <= 0;
					if(uart_tx_done)begin
						sta <= 0;
						o_485_de <= 0;
					end
				end
				
				default:sta <= 0;
			endcase
	end

	//------ reply timeout counter ------
	//count 1ms ticks while bus request is pending;
	//restart at frame-send-done(sta==14 & uart_tx_done) so the reply window is independent of baud rate;
	//timeout is masked while transmitting(!o_485_de) to avoid aborting a frame on the bus.
	assign	rx_timeout = o_485_bus_req && !o_485_de && (rx_timeout_cnt >= RX_TIMEOUT_MS);

	always@(posedge i_clk)
	begin
		if(i_rst || !o_485_bus_req)
			rx_timeout_cnt <= 0;
		else if(sta == 14 && uart_tx_done)	//frame send done, restart reply wait window
			rx_timeout_cnt <= 0;
		else if(sample_start_posedge)		//new query triggered, restart wait window
			rx_timeout_cnt <= 0;
		else if(i_time_1ms_vld)
			rx_timeout_cnt <= rx_timeout_cnt + 1'b1;
	end

	assign	o_ready = !o_485_de;
	
	
	//--------- 485 rx ----------

	always@(posedge i_clk)
	begin
		if(i_rst)begin
			da_reg[0] <= 0;
			da_reg[1] <= 0;
			da_reg[2] <= 0;
			da_reg[3] <= 0;
			da_reg[4] <= 0;
			da_reg[5] <= 0;
			da_reg[6] <= 0;
			da_reg[7] <= 0;
			da_reg[8] <= 0;
			rx_vld_r <= 0;
		end else if(uart_rx_done)begin
			rx_vld_r <= 1;
			da_reg[0] <= uart_rx_da;
			da_reg[1] <= da_reg[0];
			da_reg[2] <= da_reg[1];
			da_reg[3] <= da_reg[2];
			da_reg[4] <= da_reg[3];
			da_reg[5] <= da_reg[4];
			da_reg[6] <= da_reg[5];
			da_reg[7] <= da_reg[6];
			da_reg[8] <= da_reg[7];
		end else begin
			rx_vld_r <= 0;
		end
	end
	
	reg [3:0]	sta2;
	
	always@(posedge i_clk)
	begin
		if(i_rst)begin
			rx_da_cs <= 0;
			sta2 <= 0;
		end else 
			case(sta2)
				0:begin
					rx_da_cs <= 0;
					if(rx_vld_r && da_reg[8] == 8'h68 && da_reg[7] == slv_485_addr && da_reg[0] == 8'h16)
						sta2 <= 1;
					else
						sta2 <= 0;	
				end
				1:begin
					rx_da_cs <= da_reg[3]+da_reg[3]+8'h5+slv_485_addr;
					sta2 <= 2;
				end
				2:begin
					sta2 <= 3;
				end
				3:begin
					sta2 <= 0;
				end
				default: begin
					sta2 <= 0;
				end
			endcase
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)begin
			rx_vld_r_1d <= 0;
			rx_vld_r_2d <= 0;
			rx_vld_r_3d <= 0;
		end else begin
			rx_vld_r_1d <= rx_vld_r;
			rx_vld_r_2d <= rx_vld_r_1d;
			rx_vld_r_3d <= rx_vld_r_2d;
		end	
	end

	
	always@(posedge i_clk)
	begin
		if(i_rst)begin
			o_user_da     <= 0;
			o_user_da_vld <= 0;
		end else 
			if(rx_vld_r_3d && da_reg[8] == 8'h68 && da_reg[7] == slv_485_addr && da_reg[0] == 8'h16)begin
				o_user_da_vld <= 1;
				o_user_da     <= {da_reg[3],da_reg[4]};
			end else begin
				o_user_da_vld <= 0;
				o_user_da     <=o_user_da   ;
			end
	end
	
	uart_tx uart_tx_u0(
    .i_clk       (i_clk)
    ,.i_rst      (i_rst)
    ,.i_tx_vld   (uart_tx_vld	)
    ,.i_tx_da    (uart_tx_da	)
    ,.o_tx_done  (uart_tx_done	)
    ,.o_uart_tx  (o_485_tx)
    );
	
	uart_rx uart_rx_u0(
    .i_clk	     (i_clk)
    ,.i_rst	     (i_rst)
    ,.i_uart_rx	 (i_485_rx)
    ,.o_rx_done	 (uart_rx_done)
    ,.o_rx_da    (uart_rx_da  )
    );
	

endmodule
