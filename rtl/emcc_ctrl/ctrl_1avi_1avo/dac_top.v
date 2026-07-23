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
	
	,input		[19:0]		v_value
    // spi interface
    ,output reg             o_dac_syn          //DAC
    ,output wire            o_dac_sclk
    ,output wire            o_dac_din
    ,input  wire            i_dac_dout
    ,output reg             o_dac_load
    ,output reg             o_dac_clr
);


localparam TRANSACTION_WIDTH = 24;

reg                  tx_en     ;
reg                  rx_en     ;
reg [TRANSACTION_WIDTH-1:0]   send_data ;
reg                  data_vld  ;
wire[TRANSACTION_WIDTH-1:0]   data_out  ;
wire                 tx_done   ;
wire                 rx_done   ;

reg [4:0] state;
reg [15:0] time_cnt;
reg [11:0] send_dac_ch0;
//reg [31:0] send_dac_ch1;
reg [31:0] power;
reg [31:0] range;
reg [31:0] control;
always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     tx_en     <= 'b0 ;
     rx_en     <= 'b0 ;
     send_data <= 'd0 ;
     data_vld  <= 'b0 ;
     state     <= 'd0 ;
     time_cnt  <= 'd0 ;
     o_dac_load  <= 'b0 ;
     o_dac_clr  <= 'b0 ;
  end else begin
    case(state)
        0:begin
            if(time_cnt > 100)begin //100ms
                time_cnt <= 'd0 ;
                state    <= 'd1 ;
                if(time_cnt > 50) 
					o_dac_clr  <= 'b1 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd0 ;
                o_dac_clr  <= 'b0 ;
            end
        end
        1:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= range[23:0] ; // range ch0
             data_vld  <= 'b1 ;
             state     <= 'd2 ;
             time_cnt  <= 'd0 ;
             o_dac_clr  <= 'b1 ;
        end
        2:begin
             rx_en     <= 'b0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                state     <= 'd3 ;
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd2 ;
                tx_en     <= 'b1 ;
             end
        end
        3:begin
            tx_en     <= 'b0 ;
            if(time_cnt > 1)begin
                time_cnt <= 'd0 ;
                state    <= 'd4 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd3 ;
            end
        end
        
        
        4:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= 24'b000010100000000000000100; // range ch1
             data_vld  <= 'b1 ;
             state     <= 'd5 ;
             time_cnt  <= 'd0 ;
             o_dac_clr  <= 'b1 ;
        end
        5:begin
             rx_en     <= 'b0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                state     <= 'd6 ;
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd5 ;
                tx_en     <= 'b1 ;
             end
        end
        6:begin
            tx_en     <= 'b0 ;
            if(time_cnt > 1)begin
                time_cnt <= 'd0 ;
                state    <= 'd7 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd6 ;
            end
        end
        
        7:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= power[23:0];
             data_vld  <= 'b1 ;
             state     <= 'd8 ;
             time_cnt  <= 'd0 ;
        end
        8:begin
             rx_en     <= 'b0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                state     <= 'd9 ;
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd8 ;
                tx_en      <= 'b1 ;
             end
        end
        
        9:begin
            tx_en     <= 'b0 ;
            if(time_cnt > 1)begin
                time_cnt <= 'd0 ;
                state    <= 'd10 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd9 ;
            end
        end
        
        10:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= control[23:0] ;
             data_vld  <= 'b1 ;
             state     <= 'd11 ;
             time_cnt  <= 'd0 ;
        end
        11:begin
             rx_en     <= 'b0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                state     <= 'd12 ;
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd11 ;
                tx_en      <= 'b1 ;
             end
        end
        
        // CHANNEL 0
        12:begin
            tx_en     <= 'b0 ;
            if(time_cnt > 100)begin
                time_cnt <= 'd0 ;
                state    <= 'd13 ;
            end else begin
                time_cnt <= time_cnt + 1 ;
                state    <= 'd12 ;
            end
        end
        
        13:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= {5'b00000,3'b000,send_dac_ch0,4'b0000} ; // ch0   
             data_vld  <= 'b1 ;
             state     <= 'd14 ;
             time_cnt  <= 'd0 ;
        end
        14:begin
             rx_en     <= 'b0 ; 
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                //state     <= 'd15 ;
				state     <= 'd18 ;//2026/7/22
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd14 ;
                tx_en      <= 'b1 ;
             end
        end
        
        // CHANNEL 1
        //	15:begin
        //	    tx_en     <= 'b0 ;
        //	    if(time_cnt > 100)begin
        //	        time_cnt <= 'd0 ;
        //	        state    <= 'd16 ;
        //	    end else begin
        //	        time_cnt <= time_cnt + 1 ;
        //	        state    <= 'd15 ;
        //	    end
        //	end
        //	
        //	16:begin
        //	     tx_en     <= 'b1 ;
        //	     rx_en     <= 'b0 ;
        //	     send_data <= {5'b00000,3'b010,send_dac_ch1[11:0],4'b0000} ; // ch1   
        //	     data_vld  <= 'b1 ;
        //	     state     <= 'd17 ;
        //	     time_cnt  <= 'd0 ;
        //	end
        //	17:begin
        //	     rx_en     <= 'b0 ;
        //	     data_vld  <= 'b0 ;
        //	     time_cnt  <= 'd0 ;
        //	     if(tx_done)begin
        //	        state     <= 'd18 ;
        //	        tx_en     <= 'b0 ;
        //	     end
        //	     else begin
        //	         state     <= 'd17 ;
        //	        tx_en      <= 'b1 ;
        //	     end
        //	end
        
        // CHANNEL 1
        18:begin
            tx_en     <= 'b0 ;
            if(time_cnt > 100)begin
                time_cnt <= 'd0 ;
                state    <= 'd19 ;
            end else begin
                time_cnt <= time_cnt + 1 ;
                state    <= 'd18 ;
            end
        end
        
        19:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= control[23:0] ; 
             data_vld  <= 'b1 ;
             state     <= 'd20 ;
             time_cnt  <= 'd0 ;
        end
        20:begin
             rx_en     <= 'b0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                state     <= 'd12 ;
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd20 ;
                tx_en      <= 'b1 ;
             end
        end
        
        
    endcase
  end
end

wire [0:0]  spi_cs_n;
wire spi_ready;

spi_module#( 
     .MODE              ("Standard")  // "Standard";"Dual";"Quad"
    ,.TRANSACTION_WIDTH (TRANSACTION_WIDTH)           // 8,16,34,32
    ,.CPOL              (1)            // 0,1
    ,.CPHA              (0)            // 0,1
    ,.NOM_OF_SLAVES     (1)            // 1 - 32
    
) U_spi_module(
    ,.i_sys_clk   (i_sys_clk  )
    ,.i_rst_n     (i_rst_n    )
    
    
    ,.iv_sel_slave(0          )
    ,.i_tx_start  (tx_en      )
    ,.i_rx_start  (rx_en      )
    ,.iv_data_in  (send_data  )
    ,.i_data_vld  (data_vld   )
    ,.ov_data_out (data_out   )
    ,.o_tx_done   (tx_done    )
    ,.o_rx_done   (rx_done    )
    ,.spi_ready   (spi_ready    )
    
    // spi interface
    ,.o_spi_cs_n  ( spi_cs_n )
//    ,.o_spi_clk   ( o_dac_sclk  )
    ,.o_ref_spi_clk   ( o_dac_sclk  )
    ,.o_spi_mosi  ( o_dac_din )
    ,.i_spi_miso  ( i_dac_dout )
);
//assign o_dac_syn = spi_cs_n;
reg dac_syn;
always @ (posedge i_sys_clk)
begin
    dac_syn <= spi_ready;
    o_dac_syn <= spi_ready;
end

   
// ---------------------------------------------------------------------------------
// --------------------------- For register write ----------------------------------
// ---------------------------------------------------------------------------------

always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     send_dac_ch0 <= 'd0 ;
     //send_dac_ch1 <= 'd0 ;
        range     <= 24'b000010000000000000000100;
        power     <= 24'b000100000000001010100101;
        control   <= 24'b000110000000000000000000;
  end else begin
     send_dac_ch0  <= v_value[11:0];
     //send_dac_ch1  <= send_dac_ch1;
	 range     		<= range    ;
	 power     		<= power    ;
	 control   		<= control  ;
	 
//           power   <= (wr_task_vld & wr_task_addr == 'h3820)     ? ps_reg_wr_dat[31:0] : power;
//           range   <= (wr_task_vld & wr_task_addr == 'h3824)     ? ps_reg_wr_dat[31:0] : range;
//           control <= (wr_task_vld & wr_task_addr == 'h3828)     ? ps_reg_wr_dat[31:0] : control;
  end
end

endmodule
