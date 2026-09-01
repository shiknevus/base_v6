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
	
	,input		[11:0]		v_value
    // spi interface
    ,output		           	o_dac_syn          //DAC
    ,output		           	o_dac_sclk
    ,output		           	o_dac_din
    ,input 		           	i_dac_dout
    ,output 	            o_dac_load
    ,output reg             o_dac_clr
);


localparam TRANSACTION_WIDTH = 24;

reg [TRANSACTION_WIDTH-1:0]   send_data ;
reg                  data_vld  ;
wire[TRANSACTION_WIDTH-1:0]   data_out  ;
wire                 tx_done   ;

reg [4:0] state;
reg [15:0] time_cnt;

wire [23:0]	range    = 24'b000010000000000000000100;
wire [23:0]	power    = 24'b000100000000001010100101;
wire [23:0]	control  = 24'b000110000000000000000000;

reg	[11:0]	v_value_r;
reg			da_da_vld;

wire	i_clk = i_sys_clk;
wire	i_rst = !i_rst_n;


always@(posedge i_clk)
begin
	if(i_rst)
		v_value_r <= 24'd0;
	else
		v_value_r <= v_value;
end

always@(posedge i_clk)
begin
	if(i_rst)
		da_da_vld <= 0;
	else if(v_value_r != v_value)
		da_da_vld <= 1;
	else
		da_da_vld <= 0;
end


always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     send_data <= 'd0 ;
     data_vld  <= 'b0 ;
     state     <= 'd0 ;
     time_cnt  <= 'd0 ;
     o_dac_clr  <= 'b0 ;
  end else begin
    case(state)
        0:begin
			if(time_cnt > 50)
				o_dac_clr  <= 'b1 ;
			else
				o_dac_clr  <= 'b0 ;
				
			if(time_cnt > 1000)begin
				o_dac_clr  <= 'b1 ;
				time_cnt <= 'd0 ;
                state    <= 'd1 ;
			end else begin
				time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd0 ;
			end
        end
        1:begin
             send_data <= range[23:0] ;		//write range reg
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
            if(time_cnt > 99)begin
                time_cnt <= 'd0 ;
                state    <= 'd7 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd3 ;
            end
        end
        
       
        7:begin
             send_data <= power[23:0];	//write power reg
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
            if(time_cnt > 99)begin
                time_cnt <= 'd0 ;
                state    <= 'd10 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd9 ;
            end
        end
        
        10:begin
             send_data <= control[23:0] ;	//write control reg
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
            if(time_cnt > 99)begin
                time_cnt <= 'd0 ;
                state    <= 'd13;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd12 ;
            end
        end
		
		//===================================================
		13:begin
			if(da_da_vld)	//5s
				state    <= 'd31;
			else
				state    <= 'd13 ;
		end	
		
		31:begin
			send_data <= {8'd0,v_value,4'd0} ;	//write control reg
             data_vld  <= 'b1 ;
             state     <= 'd32 ;
		
		end
		32:begin
             data_vld  <= 'b0 ;
             if(tx_done)
                state     <= 'd33 ;
             else 
                 state     <= 'd32 ;
        end
        
        33:begin
            if(time_cnt > 99)begin
                time_cnt <= 'd0 ;
                state    <= 'd13;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd33 ;
            end
        end
	
		default:state    <= 'd0 ;
    endcase
  end
end

wire 		 spi_cs_n;
wire 		spi_ready;

spi_module#(
	.P_DATA_WIDTH     	(TRANSACTION_WIDTH)
	,.P_CPOL          	(1)
	,.P_CPHL          	(0)
	,.P_DIV_NUM			(10)
)spi_module_u0(                  
    .i_clk              (i_sys_clk)
    ,.i_rst             (!i_rst_n)
    ,.o_spi_clk         (o_dac_sclk)
    ,.o_spi_csn         (o_dac_syn)
    ,.o_spi_mosi        (o_dac_din)
    ,.i_spi_miso        (i_dac_dout)
    ,.i_tx_da       	(send_data)
    ,.i_tx_vld     		(data_vld)
    ,.o_spi_busy		(spi_busy)
    ,.o_rx_da		    (data_out)
    ,.o_rx_vld          (tx_done)
);

  

assign 	o_dac_load = 0;



endmodule
