`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	cgliu
// 
// Create Date: 
// Design Name: 
// Module Name: dac_top
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


module dac_top(
    input   	wire      	i_sys_clk 
    ,input   	wire      	i_rst_n   
    ,input                	i_time_1ms_vld
    ,input                	i_time_1s_vld
	,input		[11:0]		i_v_value			//需要输出的电压值
	,input					i_v_value_vld		//电压有效信号
	,input		[23:0]		i_rd_reg			//需要读回的寄存器
	,input					i_rd_reg_vld		//寄存器有效信号
	,output	reg	[23:0]		o_reg_msg			//读回寄存器
	,output	reg				o_reg_vld			//读回寄存器有效
	
    // spi interface
    ,output reg             o_dac_syn          //DAC
    ,output wire            o_dac_sclk
    ,output wire            o_dac_din
    ,input  wire            i_dac_dout
    ,output wire            o_dac_load
    ,output reg             o_dac_clr
);

localparam	TRANSACTION_WIDTH = 24;

reg [TRANSACTION_WIDTH-1:0]   send_data ;
reg                  data_vld  ;
wire[TRANSACTION_WIDTH-1:0]   data_out  ;
wire                 tx_done   ;

reg [7:0] state;
reg [15:0] time_cnt;
reg [11:0] send_dac_ch0;
//reg [31:0] send_dac_ch1;
reg [31:0] power;
reg [31:0] range;
reg [31:0] control;

assign o_dac_load  = 0 ;

always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     send_data <= 'd0 ;
     data_vld  <= 'b0 ;
     state     <= 'd0 ;
     time_cnt  <= 'd0 ;
     o_dac_clr  <= 'b0 ;
	 o_reg_msg<= 0;
	 o_reg_vld<= 0;
  end else begin
    case(state)
        0:begin
			if(time_cnt > 50)
				o_dac_clr  <= 'b1 ;
			else
				o_dac_clr  <= 'b0 ;
				
			if(time_cnt > 100)begin
				o_dac_clr  <= 'b1 ;
				time_cnt <= 'd0 ;
                state    <= 'd1 ;
			end else begin
				time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd0 ;
			end
        end
        1:begin
             send_data <= range[23:0] ;
             data_vld  <= 'b1 ;
             state     <= 'd2 ;
        end
        2:begin
             data_vld  <= 'b0 ;
             if(tx_done)
                state     <= 'd3 ;
             else 
                 state     <= 'd2 ;
        end
        3:begin
            if(time_cnt > 9)begin
                time_cnt <= 'd0 ;
                state    <= 'd7 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd3 ;
            end
        end
        
       
        7:begin
             send_data <= power[23:0];
             data_vld  <= 'b1 ;
             state     <= 'd8 ;
        end
		
        8:begin
             data_vld  <= 'b0 ;
             if(tx_done)
                state     <= 'd9 ;
             else
                 state     <= 'd8 ;
        end
        
        9:begin
            if(time_cnt > 9)begin
                time_cnt <= 'd0 ;
                state    <= 'd10 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd9 ;
            end
        end
        
        10:begin
             send_data <= control[23:0] ;
             data_vld  <= 'b1 ;
             state     <= 'd11 ;
        end
        11:begin
             data_vld  <= 'b0 ;
             if(tx_done)
                state     <= 'd12 ;
             else 
                 state     <= 'd11 ;
        end
        
        12:begin
            if(time_cnt > 9)begin
                time_cnt <= 'd0 ;
                state    <= 'd13 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd12 ;
            end
        end
		
        13:begin
			if(i_v_value_vld)begin	//写寄存器
				send_data <= {5'b00000,3'b000,i_v_value,4'b0000} ;  
				data_vld  <= 'b1 ;
				state     <= 'd14 ;
			end else if(i_rd_reg_vld)begin	//读寄存器
				send_data <= i_rd_reg ; 
				data_vld  <= 'b1 ;
				state     <= 'd21 ;
			end
				
        end
        14:begin
             data_vld  <= 'b0 ;
             if(tx_done)
				state     <= 'd18 ;
             else 
                 state     <= 'd14 ;
        end
        
        18:begin
			if(time_cnt > 9)begin
                time_cnt <= 'd0 ;
                state    <= 'd13 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd18 ;
            end
        end
		
	////////////////////////////////////////// read reg begin /////////////////////////////////////////////	
		
		21:begin
		     data_vld  <= 'b0 ;
		     if(tx_done)
				state     <= 'd22 ;
		     else 
		         state     <= 'd21 ;
		end
		
		22:begin
			 if(time_cnt > 9)begin
                time_cnt <= 'd0 ;
                state    <= 'd23 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd22 ;
            end
		
		end
		
		23:begin
			send_data <= 24'h180000 ; 
			data_vld  <= 'b1 ;
			state     <= 'd24 ;
		end
		
		24:begin
			data_vld  <= 'b0 ;
			if(tx_done)begin
				state     <= 'd25 ;
				o_reg_msg <= data_out;
				o_reg_vld <= 1;
			end else begin
				state     <= 'd24 ;
				o_reg_msg <= 0;
				o_reg_vld <= 0;
			end
		end
		
		25:begin
			o_reg_vld <= 0;
			if(time_cnt > 5)begin
                time_cnt <= 'd0 ;
                state    <= 'd13;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd25 ;
            end
		
		end

	////////////////////////////////////////// read reg end /////////////////////////////////////////////	
  
		default:state    <= 'd0 ;
    endcase
  end
end

wire   spi_cs_n;
wire spi_ready;


wire		spi_busy;
spi_module#(
	.P_DATA_WIDTH     	(TRANSACTION_WIDTH)
	,.P_CPOL          	(1)
	,.P_CPHL          	(0)
	,.P_DIV_NUM			(10)
)spi_module_u0(                  
    .i_clk              (i_sys_clk)
    ,.i_rst             (!i_rst_n)
    ,.o_spi_clk         (o_dac_sclk)
    ,.o_spi_csn         (spi_cs_n)
    ,.o_spi_mosi        (o_dac_din)
    ,.i_spi_miso        (i_dac_dout)
    ,.i_tx_da       	(send_data)
    ,.i_tx_vld     		(data_vld)
    ,.o_spi_busy		(spi_busy)
    ,.o_rx_da		    (data_out)
    ,.o_rx_vld          (tx_done)
);



always @ (posedge i_sys_clk)
begin
    o_dac_syn <= spi_cs_n;
end

   
// ---------------------------------------------------------------------------------
// --------------------------- For register write ----------------------------------
// ---------------------------------------------------------------------------------

always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     //send_dac_ch1 <= 'd0 ;
        range     <= 24'b0000_1000_0000_0000_0000_0100;	//chanal A、V range :±10V
        power     <= 24'b0001_0000_0000_0000_0000_0101;
        control   <= 24'b0001_1000_0000_0000_0000_0000;	//No operation instruction used in readback operations.
  end else begin
     //send_dac_ch1  <= send_dac_ch1;
	 range     		<= range    ;
	 power     		<= power    ;
	 control   		<= control  ;
  end
end

endmodule
