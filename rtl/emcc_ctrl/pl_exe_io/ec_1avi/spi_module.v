`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2023/07/16 21:39:18
// Design Name: 
// Module Name: spi_drive
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


module spi_module#(
    parameter                           P_DATA_WIDTH      	= 8 ,
                                        P_CPOL              = 0 ,
                                        P_CPHL              = 0 ,
										P_DIV_NUM			= 10
)(                  
    input                               i_clk               ,
    input                               i_rst               ,

    output  reg                         o_spi_clk           ,
    output  reg                         o_spi_csn           ,
    output  reg                         o_spi_mosi          ,
    input                               i_spi_miso          ,

    input   	[P_DATA_WIDTH - 1 :0]   i_tx_da       		,
    input                               i_tx_vld     		,
    output  	                        o_spi_busy			,

    output  reg	[P_DATA_WIDTH - 1:0]   	o_rx_da		    	,
    output  reg                        	o_rx_vld   
);

localparam	CS_DELAY	=	6;

reg		[7:0]	curr_sta;
reg		[7:0]	next_sta;

reg								run;
reg		[P_DATA_WIDTH - 1 :0]	ri_tx_da;	
reg		[31:0]					cnt_div;
reg		[7:0]					cnt_sck	;
reg								posedge_sck;
reg								negedge_sck;
reg								run_1d;
reg		[7:0]					cnt_delay;


wire	run_negedge	= !run && run_1d;


assign	o_spi_busy = !o_spi_csn;


localparam		S_IDLE		=	8'd0;
localparam		S_DELAY		=	8'd1;
localparam		WORKING		=	8'd2;
localparam		S_DELAY1	=	8'd3;


always@(posedge i_clk)
begin
	if(i_rst)
		cnt_delay <= 0;
	else if(curr_sta == S_DELAY || curr_sta == S_DELAY1)
		if(cnt_delay >= CS_DELAY-1) 
			cnt_delay <= 0;
		else
			cnt_delay <= cnt_delay + 1;
	else
		cnt_delay <= 0;	
end


always@(posedge i_clk)
begin
	if(i_rst)
		curr_sta <= S_IDLE;
	else
		curr_sta <= next_sta;
end

always@(*)
begin
	next_sta = curr_sta;
	case(curr_sta)
		S_IDLE:	begin
			if(i_tx_vld)
				next_sta = S_DELAY;
			else
				next_sta = S_IDLE;
		end
		
		S_DELAY:begin
			if(cnt_delay >= CS_DELAY-1)
				next_sta = WORKING;
			else
				next_sta = S_DELAY;
		end
		
		WORKING:begin
			if(run_negedge)
				next_sta = S_DELAY1;
			else
				next_sta = WORKING;
		end
		
		S_DELAY1:begin
			if(cnt_delay >= CS_DELAY-1)
				next_sta = S_IDLE;
			else
				next_sta = S_DELAY1;
		end

		default: begin
			next_sta <= S_IDLE;
		end
	endcase
end

always@(posedge i_clk)
begin
	if(i_rst)
		run <= 1'b0;
	else if(curr_sta == S_DELAY && cnt_delay >= CS_DELAY-1)
		run <= 1'b1;
	else if((cnt_div >= P_DIV_NUM/2-1) && (cnt_sck >= P_DATA_WIDTH*2 - 1))
		run <= 1'b0;
	else
		run <= run;
end

always@(posedge i_clk)
begin
	if(i_rst)
		run_1d <= 0;
	else
		run_1d <= run;
end


always@(posedge i_clk)
begin
	if(i_rst)
		ri_tx_da <= 0;
	else if(curr_sta == S_IDLE && i_tx_vld)
		ri_tx_da <= i_tx_da;
	else if(curr_sta == WORKING || curr_sta == S_DELAY)
		case({P_CPOL[0],P_CPHL[0]})
			2'b00:begin						//默认低电平，上升沿采样,下降沿改变数据
				if(negedge_sck)
					ri_tx_da <= ri_tx_da << 1;
				else
					ri_tx_da <= ri_tx_da;
			end
			
			2'b01:begin						//默认低电平，下降沿采样,上升沿改变数据
				if(posedge_sck)
					ri_tx_da <= ri_tx_da << 1;
				else
					ri_tx_da <= ri_tx_da;
			end
			
			2'b10:begin						//默认高电平，下降沿采样,上升沿改变数据
				if(posedge_sck)
					ri_tx_da <= ri_tx_da << 1;
				else
					ri_tx_da <= ri_tx_da;
			end
			
			2'b11:begin						//默认高电平，上升沿采样,下降沿改变数据
				if(negedge_sck)
					ri_tx_da <= ri_tx_da << 1;
				else
					ri_tx_da <= ri_tx_da;
			end
			
			default:begin
				ri_tx_da <= ri_tx_da;
			end
		endcase
	else
		ri_tx_da <= 0;
end


always@(posedge i_clk)
begin
	if(i_rst)
		cnt_div <= 'd0;
	else if(run)
		if(cnt_div >= P_DIV_NUM/2-1)
			cnt_div <= 'd0;
		else
			cnt_div <= cnt_div + 1;
	else
		cnt_div <= 'd0;
end

always@(posedge i_clk)
begin
	if(i_rst)
		cnt_sck <= 'd0;
	else if(cnt_div >= P_DIV_NUM/2-1)
		if(cnt_sck >= P_DATA_WIDTH*2 - 1)
			cnt_sck <= 'd0;
		else
			cnt_sck <= cnt_sck+1;
	else
		cnt_sck <= cnt_sck;
end


always@(posedge i_clk)
begin
	if(i_rst)begin
		posedge_sck <= 1'b0;
		negedge_sck	<= 1'b0;
	end else begin
		case(P_CPOL[0])
			1'b0:begin
				if(curr_sta == WORKING)begin
					if(!cnt_sck[0] && cnt_div == 0)
						posedge_sck <= 1;
					else
						posedge_sck <= 0;
					
					if(cnt_sck[0] && cnt_div == 0)
						negedge_sck <= 1;
					else
						negedge_sck <= 0;
				end else begin
					posedge_sck <= 1'b0;
					negedge_sck	<= 1'b0;
				end
			end
			
			1'b1:begin
				if(curr_sta == WORKING)begin
					if(cnt_sck[0] && cnt_div == 0)
						posedge_sck <= 1;
					else
						posedge_sck <= 0;
					
					if(!cnt_sck[0] && cnt_div == 0)
						negedge_sck <= 1;
					else
						negedge_sck <= 0;
				end else begin
					posedge_sck <= 1'b0;
				    negedge_sck	<= 1'b0;
				end
			end
		
			default:begin
				posedge_sck <= 1'b0;
				negedge_sck	<= 1'b0;
			end
		endcase
	end
end

always@(posedge i_clk)
begin
	if(i_rst)
		o_spi_clk <= P_CPOL[0];
	if(run)
		if(negedge_sck)
			o_spi_clk <= 0;
		else if(posedge_sck)
			o_spi_clk <= 1;
		else if(run_negedge)
			o_spi_clk <= P_CPOL[0];
		else
			o_spi_clk <= o_spi_clk;
	else
		o_spi_clk <= P_CPOL[0];
end


always@(posedge i_clk)
begin
	if(i_rst)
		o_spi_csn <= 1'b1;
	else if(curr_sta == S_IDLE && i_tx_vld)
		o_spi_csn <= 1'b0;
	else if(curr_sta == S_DELAY1 && cnt_delay >= CS_DELAY-1)
		o_spi_csn <= 1'b1;
	else
		o_spi_csn <= o_spi_csn;
end

always@(posedge i_clk)
begin
	if(i_rst)
		o_spi_mosi <= 1'b0;
	else
		o_spi_mosi <= ri_tx_da[P_DATA_WIDTH-1];
end

always@(posedge i_clk)
begin
	if(i_rst)
		o_rx_da <= 0;
	else if(curr_sta == WORKING)
		case({P_CPOL[0],P_CPHL[0]})
			2'b00:begin						//默认低电平，上升沿采样,下降沿改变数据
				if(posedge_sck)
					o_rx_da <= {o_rx_da[P_DATA_WIDTH-2:0],i_spi_miso};
				else
					o_rx_da <= o_rx_da;
			end
			
			2'b01:begin						//默认低电平，下降沿采样,上升沿改变数据
				if(negedge_sck)
					o_rx_da <= {o_rx_da[P_DATA_WIDTH-2:0],i_spi_miso};
				else
					o_rx_da <= o_rx_da;
			end
			
			2'b10:begin						//默认高电平，下降沿采样,上升沿改变数据
				if(negedge_sck)
					o_rx_da <= {o_rx_da[P_DATA_WIDTH-2:0],i_spi_miso};
				else
					o_rx_da <= o_rx_da;
			end
			
			2'b11:begin						//默认高电平，上升沿采样,下降沿改变数据
				if(posedge_sck)
					o_rx_da <= {o_rx_da[P_DATA_WIDTH-2:0],i_spi_miso};
				else
					o_rx_da <= o_rx_da;
			end
			
			default:begin
				o_rx_da <= o_rx_da;
			end
		endcase
	else
		o_rx_da <= 0;
end

always@(posedge i_clk)
begin
	if(i_rst)
		o_rx_vld <= 1'b0;
	else if((cnt_sck >= P_DATA_WIDTH*2 - 1) && (cnt_div >= P_DIV_NUM/2-1))
		o_rx_vld <= 1'b1;
	else
		o_rx_vld <= 1'b0;
end


endmodule
