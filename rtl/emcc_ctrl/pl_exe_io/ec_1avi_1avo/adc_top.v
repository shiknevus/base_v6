`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/23 10:31:12
// Design Name: 
// Module Name: adc_top
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
    // input   wire                 ps_reg_clk 
    //,input   wire                 ps_reg_reset 
    input   	wire                i_sys_clk 
    ,input   	wire                i_rst_n   
    ,input                         	i_time_1ms_vld
    
    // spi interface
    ,output  wire                 o_spi_cs_n
    ,output  wire                 o_spi_clk 
    ,output  wire                 o_spi_mosi
    ,input   wire                 i_spi_miso
    
    ,output wire                   o_adc_ch0_data_vld
    ,output wire   [31:0]          ov_adc_ch0_data
    ,output wire                   o_adc_ch1_data_vld
    ,output wire   [31:0]          ov_adc_ch1_data
);

localparam TRANSACTION_WIDTH = 16;

reg                  tx_en     ;
reg                  rx_en     ;
reg [TRANSACTION_WIDTH-1:0]   send_data ;
reg                  data_vld  ;
wire[TRANSACTION_WIDTH-1:0]   data_out  ;
wire                 tx_done   ;
wire                 rx_done   ;

reg [3:0] state;
reg [15:0] time_cnt;
reg [15:0] range;
reg [15:0] control;

always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
     tx_en     <= 'b0 ;
     rx_en     <= 'b0 ;
     send_data <= 'd0 ;
     data_vld  <= 'b0 ;
     state     <= 'd0 ;
     time_cnt  <= 'd0 ;
  end else begin
    case(state)
        0:begin
            if(time_cnt > 100)begin //100ms
                time_cnt <= 'd0 ;
                state    <= 'd1 ;
            end else begin
                time_cnt <= time_cnt + i_time_1ms_vld ;
                state    <= 'd0 ;
            end
        end
        1:begin
             tx_en     <= 'b1 ;
             rx_en     <= 'b0 ;
             send_data <= range[15:0] ; // range+-10V
             data_vld  <= 'b1 ;
             state     <= 'd2 ;
             time_cnt  <= 'd0 ;
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
            if(time_cnt > 100)begin
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
             send_data <= control[15:0] ; // control   
             data_vld  <= 'b1 ;
             state     <= 'd5 ;
             time_cnt  <= 'd0 ;
        end
        5:begin
             rx_en     <= 'b0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
             if(tx_done)begin
                state     <= 'd7 ;
                tx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd5 ;
                tx_en      <= 'b1 ;
             end
        end
        
        6:begin
             if(rx_done)begin
                state     <= 'd7 ;
                rx_en     <= 'b0 ;
             end
             else begin
                 state     <= 'd6 ;
                 rx_en      <= 'b1 ;
             end
             tx_en     <= 'b0 ;
             send_data <= 16'd0 ;
             data_vld  <= 'b0 ;
             time_cnt  <= 'd0 ;
        end
        7:begin
            if(time_cnt > 80)begin
                time_cnt <= 'd0 ;
                state    <= 'd6 ;
            end else begin
                time_cnt <= time_cnt + 1 ;
                state    <= 'd7 ;
            end
            
             tx_en     <= 'b0 ;
             rx_en     <= 'b0 ;
             send_data <= 16'd0 ; 
             data_vld  <= 'b0 ;
        end
    endcase
  end
end


wire spi_ready;
spi_module#( 
    .TRANSACTION_WIDTH (TRANSACTION_WIDTH)           // 8,16,24,32
    ,.CPOL              (1)            // 0,1
    ,.CPHA              (0)            // 0,1
    ,.NOM_OF_SLAVES     (1)            // 1 - 32
    
) U_spi_module(
    // .ps_reg_clk   (ps_reg_clk  )
    .i_sys_clk   (i_sys_clk  )
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
    ,.o_spi_cs_n  ( o_spi_cs_n )
//    ,.o_spi_clk   ( o_spi_clk  )
    ,.o_ref_spi_clk   ( o_spi_clk  )
    ,.o_spi_mosi  ( o_spi_mosi )
    ,.i_spi_miso  ( i_spi_miso )
);


reg [1:0]edge_rx_done;
reg [15:0]rx_adc_data;
reg [31:0]rx_adc_data_ch0;
reg [31:0]rx_adc_data_ch1;

reg adc_ch0_data_vld;
reg adc_ch1_data_vld;
wire rx_vld = edge_rx_done==2'b01;
always @ (posedge i_sys_clk)
begin
  if(!i_rst_n) begin
        edge_rx_done     <= 'b0 ;
        rx_adc_data_ch0  <= 'd0 ;
        rx_adc_data_ch1  <= 'd0 ;
        rx_adc_data      <= 'd0 ;
        adc_ch0_data_vld      <= 'd0 ;
        adc_ch1_data_vld      <= 'd0 ;
  end else begin
        edge_rx_done     <= {edge_rx_done[0],rx_done};
        rx_adc_data      <= data_out;
        if(rx_vld)begin
            rx_adc_data_ch0  <= rx_adc_data[13]==1'b0 ? {16'd0,3'b0,rx_adc_data[12:0]} : rx_adc_data_ch0;
            adc_ch0_data_vld <= rx_adc_data[13]==1'b0 ? 1'b1 : 1'b0;
            rx_adc_data_ch1  <= rx_adc_data[13]==1'b1 ? {16'd0,3'b0,rx_adc_data[12:0]} : rx_adc_data_ch1;
            adc_ch1_data_vld <= rx_adc_data[13]==1'b1 ? 1'b1 : 1'b0;
        end else begin
            rx_adc_data_ch0  <= rx_adc_data_ch0 ;
            rx_adc_data_ch1  <= rx_adc_data_ch1 ;
            adc_ch0_data_vld      <= 'd0 ;
            adc_ch1_data_vld      <= 'd0 ;
        end
  end
end


assign o_adc_ch0_data_vld = adc_ch0_data_vld;
assign ov_adc_ch0_data    = rx_adc_data_ch0;
assign o_adc_ch1_data_vld = adc_ch1_data_vld;
assign ov_adc_ch1_data    = rx_adc_data_ch1;
   
// ---------------------------------------------------------------------------------
// --------------------------- For register write ----------------------------------
// ---------------------------------------------------------------------------------

always @ (posedge i_sys_clk)
begin
  if(i_rst_n) begin
        control   <= 16'b1000_0100_0010_1000;
        range     <= 16'b1011_1001_1000_0000;
//        range     <= 16'b1010000000000000;
  end else begin
		control   <= control ;
		range     <= range   ;
//           range   <= (wr_task_vld & wr_task_addr == 'h3808)     ? ps_reg_wr_dat[15:0] : range;
//           control <= (wr_task_vld & wr_task_addr == 'h380C)     ? ps_reg_wr_dat[15:0] : control;
  end
end


//    ila_adc U_ila_adc(
//     .clk(ps_reg_clk)
//    ,.probe0({i_sys_clk,i_rst_n,o_spi_clk,o_spi_mosi,i_spi_miso,o_spi_cs_n,rx_done,tx_done})
//    ,.probe1(data_out)
//    ,.probe2(send_data)
//    ,.probe3({state,data_vld,spi_ready,tx_en})
//    ,.probe4(time_cnt)
//    );
    

endmodule
