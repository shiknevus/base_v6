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
	
	,input					i_485_rx
	,output					o_485_tx
	,output 	reg			o_485_de
	
	,input					i_sample_start
	,input			[7:0]	i_485_addr
	,output					o_ready
	,output 	reg [15:0]	o_user_da		//distance
	,output		reg			o_user_da_vld	//distance vld
    );
	
	wire 			uart_tx_vld	;
	wire 	[7:0]	uart_tx_da	;
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
		
	assign	tx_da_cs = slv_485_addr+8'h3;

	
	//------ 485 tx --------
	
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
						sta <= 1;
						slv_485_addr <= i_485_addr;
					end else begin
						sta <= 0;
						slv_485_addr <= 0;
					end
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
					if(rx_vld_r && da_reg[8] == 8'h68 && da_reg[7] == slv_485_addr && da_reg[0] == 8'h16)begin
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
				o_user_da     <= {da_reg[4],da_reg[3]};
			end else begin
				o_user_da_vld <= 0;
				o_user_da     <=o_user_da   ;
			end
	end

	uart_tx(
    .i_clk       (i_clk)
    ,.i_rst      (i_rst)
    ,.i_tx_vld   (uart_tx_vld	)
    ,.i_tx_da    (uart_tx_da	)
    ,.o_tx_done  (uart_tx_done	)
    ,.o_uart_tx  (o_485_tx)
    );
	
	uart_rx(
    .i_clk	     (i_clk)
    ,.i_rst	     (i_rst)
    ,.i_uart_rx	 (i_485_rx)
    ,.o_rx_done	 (uart_rx_done)
    ,.o_rx_da    (uart_rx_da  )
    );
	

endmodule
