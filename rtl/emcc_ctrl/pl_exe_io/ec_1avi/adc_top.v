`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2024/03/23 10:31:12
// Design Name: 
// Module Name: adc_top	ADC7321
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


module adc_top (
    input   	wire                i_sys_clk 
    ,input   	wire                i_rst_n   
    ,input                         	i_time_1ms_vld
    // spi interface
    ,output  wire                 	o_spi_cs_n
    ,output  wire                 	o_spi_clk 
    ,output  wire                 	o_spi_mosi
    ,input   wire                 	i_spi_miso
    
    ,output wire                   	o_adc_ch0_data_vld
    ,output wire   [15:0]          	o_adc_ch0_data
    ,output wire                   	o_adc_ch1_data_vld
    ,output wire   [15:0]          	o_adc_ch1_data
);

localparam TRANSACTION_WIDTH = 16;

wire [15:0]	control  = 16'b1000_0100_0010_1000;	//直接二进制
wire [15:0]	range    = 16'b1010_0000_0000_0000;	//±10V

reg [TRANSACTION_WIDTH-1:0]   send_data ;
reg                  data_vld  ;
wire[TRANSACTION_WIDTH-1:0]   data_out  ;
wire                 tx_done   ;


reg [3:0] state;
reg [15:0] time_cnt;

always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     send_data <= 'd0 ;
     data_vld  <= 'b0 ;
     state     <= 'd0 ;
     time_cnt  <= 'd0 ;
  end else begin
    case(state)
        0:begin
            if(time_cnt > 100)begin 	//100ms
                time_cnt <= 'd0 ;
                state    <= 'd1 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd0 ;
            end
        end
		
        1:begin
             send_data <= range; // range+-10V
             data_vld  <= 'b1 ;
             state     <= 'd2 ;
        end
		
        2:begin
			 data_vld  <= 'b0 ;
             if(tx_done)
                state  <= 'd3 ;
			else
				state  <= 'd2 ;
        end
		
        3:begin
            if(time_cnt > 99)begin
                time_cnt <= 'd0 ;
                state    <= 'd4 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd3 ;
            end
        end
        
        4:begin
             send_data <= control; // control   
             data_vld  <= 'b1 ;
             state     <= 'd5 ;
        end
		
        5:begin
             data_vld  <= 'b0 ;
             if(tx_done)
                state     <= 'd6 ;
             else
                 state     <= 'd5 ;
        end

        6:begin
            if(time_cnt > 80)begin
                time_cnt <= 'd0 ;
                state    <= 'd7 ;
            end else begin
                time_cnt <= time_cnt + 1 ;
                state    <= 'd6 ;
            end
		end
		
		7:begin
			send_data <= 16'd0; // data   
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
                state    <= 'd7 ;
            end else begin
                time_cnt <= time_cnt + 1 ;
                state    <= 'd9 ;
            end
		end
		
		default :begin
             send_data <= 16'd0 ; 
             data_vld  <= 'b0 ;
		end
			
    endcase
  end
end


reg [15:0]rx_adc_data_ch0;
reg [15:0]rx_adc_data_ch1;

reg adc_ch0_data_vld;
reg adc_ch1_data_vld;


always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
        rx_adc_data_ch0  <= 'd0 ;
        rx_adc_data_ch1  <= 'd0 ;
        adc_ch0_data_vld <= 'd0 ;
        adc_ch1_data_vld <= 'd0 ;
  end else begin
        if(tx_done)begin
            rx_adc_data_ch0  <= data_out[13]==1'b0 ? {3'd0,data_out[12:0]} : rx_adc_data_ch0;
            adc_ch0_data_vld <= data_out[13]==1'b0 ? 1'b1 : 1'b0;
            rx_adc_data_ch1  <= data_out[13]==1'b1 ? {3'd0,data_out[12:0]} : rx_adc_data_ch1;
            adc_ch1_data_vld <= data_out[13]==1'b1 ? 1'b1 : 1'b0;
        end else begin
            rx_adc_data_ch0  <= rx_adc_data_ch0 ;
            rx_adc_data_ch1  <= rx_adc_data_ch1 ;
            adc_ch0_data_vld <= 'd0 ;
            adc_ch1_data_vld <= 'd0 ;
        end
  end
end


assign o_adc_ch0_data_vld	= adc_ch0_data_vld;
assign o_adc_ch0_data		= rx_adc_data_ch0;
assign o_adc_ch1_data_vld	= adc_ch1_data_vld;
assign o_adc_ch1_data		= rx_adc_data_ch1;

spi_module#(
	.P_DATA_WIDTH     	(TRANSACTION_WIDTH)
	,.P_CPOL          	(1)
	,.P_CPHL          	(0)
	,.P_DIV_NUM			(10)
)spi_module_u0(                  
    .i_clk              (i_sys_clk)
    ,.i_rst             (!i_rst_n)
    ,.o_spi_clk         (o_spi_clk	)
    ,.o_spi_csn         (o_spi_cs_n	)
    ,.o_spi_mosi        (o_spi_mosi	)
    ,.i_spi_miso        (i_spi_miso	)
    ,.i_tx_da       	(send_data)
    ,.i_tx_vld     		(data_vld)
    ,.o_spi_busy		()
    ,.o_rx_da		    (data_out)
    ,.o_rx_vld          (tx_done)
);
   
endmodule
