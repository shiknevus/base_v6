`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/23 10:05:53
// Design Name: 
// Module Name: spi_module
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


module spi_module   #(
    parameter TRANSACTION_WIDTH =  16           // 8,16,32
    ,parameter CPOL              =  1            // 0,1
    ,parameter CPHA              =  0            // 0,1
    ,parameter NOM_OF_SLAVES     =  1            // 1 - 32
)(
    //input   wire                           ps_reg_clk 
    input   wire                          	i_sys_clk 
    ,input   wire                          i_rst_n   
    ,input   wire                          i_tx_start
    ,input   wire                          i_rx_start
    ,input   wire [7:0]                    iv_sel_slave
    ,input   wire [TRANSACTION_WIDTH-1:0]  iv_data_in
    ,input   wire                          i_data_vld
    ,output  wire [TRANSACTION_WIDTH-1:0]  ov_data_out
    ,output wire                           o_tx_done
    ,output wire                           o_rx_done
    ,output wire                           spi_ready
    
    // spi interface
    ,output  wire [NOM_OF_SLAVES-1:0]  o_spi_cs_n
    ,output  wire                      o_spi_clk 
    ,output  wire                      o_ref_spi_clk 
    ,output  wire                      o_spi_mosi
    ,input   wire                      i_spi_miso
);

reg   [NOM_OF_SLAVES-1:0] spi_cs_n;
reg                       spi_clk ;
reg                       spi_mosi;
wire                      spi_miso;

reg spi_clk_en;
assign o_spi_cs_n = spi_cs_n;
generate
    if(CPOL == 1)begin:CPOL1
        assign o_spi_clk  = spi_clk_en ? i_sys_clk : 1'b1;
    end else begin:CPOL0
        assign o_spi_clk  = spi_clk_en ? i_sys_clk : 1'b0;
    end
endgenerate
assign o_spi_mosi = spi_mosi;
assign spi_miso   = i_spi_miso;
assign o_ref_spi_clk   = i_sys_clk;

reg [TRANSACTION_WIDTH-1:0]  data_in;
reg [TRANSACTION_WIDTH-1:0]  rec_data;

reg [1:0]edge_tx_start;
reg [1:0]edge_rx_start;
always  @(posedge   i_sys_clk or negedge i_rst_n)begin
    if(i_rst_n==1'b0) begin
        data_in <= 'd0;
        edge_tx_start <= 2'b0;
        edge_rx_start <= 2'b0;
    end else begin
        data_in <= i_data_vld ? iv_data_in : data_in;
        edge_tx_start <= {edge_tx_start[0],i_tx_start};
        edge_rx_start <= {edge_rx_start[0],i_rx_start};
    end
end

wire tx_start = edge_tx_start == 2'b01;
wire rx_start = edge_rx_start == 2'b01;

reg [7:0] send_cnt;
reg [7:0] recv_cnt;
reg [3:0] state;
reg       rx_done;
reg       tx_done;
reg       spi_working;
assign spi_ready = ~spi_working;

generate
/////////// ---------------------------------------------------------------------------------
if(((CPOL == 0)&&(CPHA == 1))||((CPOL == 1)&&(CPHA == 0)))begin:RISING_EDGE_SEND/////////// -----------------------------------------------------------
/////////// ---------------------------------------------------------------------------------
    always  @(posedge   i_sys_clk or negedge i_rst_n)begin
        if(i_rst_n==1'b0) begin
            state        <=4'd0;
            spi_cs_n     <='hFFFFFFFF;
            spi_mosi     <=1'bZ;
            tx_done      <=1'b0;
            rx_done      <=1'b0;
            send_cnt     <= TRANSACTION_WIDTH-1;
            recv_cnt     <= TRANSACTION_WIDTH-1;
            spi_working  <= 1'b0;
            spi_clk_en   <= 1'b0;
        end
        else begin
            case(state)
                0:begin
                    if(tx_start)begin
                        state   <=4'd1;
                        spi_cs_n  <='hFFFFFFFF;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                    end else if(rx_start)begin
                        state   <=4'd4;
                        spi_cs_n[iv_sel_slave]  <=1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                    end else begin
                        state   <=4'd0;
                        spi_cs_n  <='hFFFFFFFF;
                        spi_clk_en   <= 1'b0;
                        spi_working  <= 1'b0;
                    end
                    spi_mosi   <=1'bZ;
                    tx_done      <=1'b0;
                    rx_done      <=1'b0;
                    send_cnt <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                end
                1:begin
                    if(send_cnt==0)begin
                        state   <=4'd2;
                        send_cnt <= TRANSACTION_WIDTH-1;
                        tx_done      <= 1'b1;
                        spi_clk_en   <= 1'b0;
                        spi_working  <= 1'b0;
                        spi_cs_n  <='hFFFFFFFF;
                    end else begin
                        state   <=4'd1;
                        send_cnt <= send_cnt-1;
                        tx_done      <= 1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                        spi_cs_n[iv_sel_slave]  <=1'b0;
                    end
                    recv_cnt     <= TRANSACTION_WIDTH-1;
//                    spi_cs_n     <= spi_cs_n;
                    spi_mosi     <= data_in[send_cnt];
                    rx_done      <= 1'b0;
                end
                2:begin
                    state        <=4'd0;
                    spi_cs_n     <='hFFFFFFFF;
                    spi_mosi     <=data_in[send_cnt];
                    tx_done      <=1'b0;
                    rx_done      <=1'b0;
                    send_cnt     <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_working  <= 1'b0;
                    spi_clk_en   <= 1'b0;
                    
                end
                
                4:begin
                    if(recv_cnt==0)begin
                        state   <=4'd5;
                        rx_done      <= 1'b1;
                        spi_clk_en   <= 1'b0;
                        spi_working  <= 1'b0;
                        recv_cnt     <= TRANSACTION_WIDTH-1;
                    end else begin
                        state     <=4'd4;
                        rx_done   <= 1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                        recv_cnt     <= recv_cnt-1;
                    end
                    spi_cs_n     <= spi_cs_n;
                    spi_mosi     <= 1'bZ;
                    tx_done      <= 1'b0;
                    send_cnt     <= TRANSACTION_WIDTH-1;
                end
                5:begin
                    state        <= 4'd0;
                    spi_cs_n     <= 'hFFFFFFFF;
                    spi_mosi     <= 1'bZ;
                    tx_done      <= 1'b0;
                    rx_done      <= 1'b0;
                    send_cnt     <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_working  <= 1'b0;
                    spi_clk_en   <= 1'b0;
                    
                end
                default:begin
                    state        <=4'd0;
                    spi_cs_n     <='hFFFFFFFF;
                    spi_mosi     <=1'bZ;
                    tx_done      <=1'b0;
                    rx_done      <=1'b0;
                    send_cnt <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_working  <= 1'b0;
                    spi_clk_en   <= 1'b0;
                end
            endcase
        end
    end
    
    reg rec_neg;
    always  @(negedge  i_sys_clk)begin
        if(i_rst_n==1'b0) begin
            rec_data     <= 1'b0;
            rec_neg      <= 1'b0;
        end
        else begin
            if(state==4)begin
                rec_data[recv_cnt] <= spi_miso;
                rec_neg            <= 1'b1;
            end else begin
                rec_data     <= 1'b0;
                rec_neg      <= 1'b0;
            end
        end
    end
/////////// ---------------------------------------------------------------------------------
/////////// ---------------------------------------------------------------------------------
end else begin :FALLING_EDGE_SEND /////////// ---------------------------------------------------------------------------------
/////////// ---------------------------------------------------------------------------------
/////////// ---------------------------------------------------------------------------------
    always  @(negedge   i_sys_clk)begin
        if(i_rst_n==1'b0) begin
            state        <=4'd0;
            spi_cs_n     <='hFFFFFFFF;
            spi_mosi     <=1'bZ;
            tx_done      <=1'b0;
            rx_done      <=1'b0;
            send_cnt     <= TRANSACTION_WIDTH-1;
            recv_cnt     <= TRANSACTION_WIDTH-1;
            spi_working  <= 1'b0;
            spi_clk_en   <= 1'b0;
        end
        else begin
            case(state)
                0:begin
                    if(tx_start)begin
                        state   <=4'd1;
                        spi_cs_n[iv_sel_slave]  <=1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                    end else if(rx_start)begin
                        state   <=4'd4;
                        spi_cs_n[iv_sel_slave]  <=1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                    end else begin
                        state   <=4'd0;
                        spi_cs_n  <='hFFFFFFFF;
                        spi_clk_en   <= 1'b0;
                        spi_working  <= 1'b0;
                    end
                    spi_mosi   <=1'bZ;
                    tx_done      <=1'b0;
                    rx_done      <=1'b0;
                    send_cnt <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                end
                1:begin
                    if(send_cnt==0)begin
                        state   <=4'd2;
                        send_cnt <= TRANSACTION_WIDTH-1;
                        tx_done      <= 1'b1;
                        spi_clk_en   <= 1'b0;
                        spi_working  <= 1'b0;
                    end else begin
                        state   <=4'd1;
                        send_cnt <= send_cnt-1;
                        tx_done      <= 1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                    end
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_cs_n     <= spi_cs_n;
                    spi_mosi     <= data_in[send_cnt];
                    rx_done      <= 1'b0;
                end
                2:begin
                    state        <=4'd0;
                    spi_cs_n     <='hFFFFFFFF;
                    spi_mosi     <=data_in[send_cnt];
                    tx_done      <=1'b0;
                    rx_done      <=1'b0;
                    send_cnt     <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_working  <= 1'b0;
                    spi_clk_en   <= 1'b0;
                    
                end
                
                4:begin
                    if(recv_cnt==0)begin
                        state   <=4'd5;
                        rx_done      <= 1'b1;
                        spi_clk_en   <= 1'b0;
                        spi_working  <= 1'b0;
                        recv_cnt     <= TRANSACTION_WIDTH-1;
                    end else begin
                        state     <=4'd4;
                        rx_done   <= 1'b0;
                        spi_clk_en   <= 1'b1;
                        spi_working  <= 1'b1;
                        recv_cnt     <= recv_cnt-1;
                    end
                    spi_cs_n     <= spi_cs_n;
                    spi_mosi     <= 1'bZ;
                    tx_done      <= 1'b0;
                    send_cnt     <= TRANSACTION_WIDTH-1;
                end
                5:begin
                    state        <= 4'd0;
                    spi_cs_n     <= 'hFFFFFFFF;
                    spi_mosi     <= 1'bZ;
                    tx_done      <= 1'b0;
                    rx_done      <= 1'b0;
                    send_cnt     <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_working  <= 1'b0;
                    spi_clk_en   <= 1'b0;
                    
                end
                default:begin
                    state        <=4'd0;
                    spi_cs_n     <='hFFFFFFFF;
                    spi_mosi     <=1'bZ;
                    tx_done      <=1'b0;
                    rx_done      <=1'b0;
                    send_cnt <= TRANSACTION_WIDTH-1;
                    recv_cnt     <= TRANSACTION_WIDTH-1;
                    spi_working  <= 1'b0;
                    spi_clk_en   <= 1'b0;
                end
            endcase
        end
    end
    
    reg rec_neg;
    always  @(posedge  i_sys_clk)begin
        if(i_rst_n==1'b0) begin
            rec_data     <= 1'b0;
            rec_neg      <= 1'b0;
        end
        else begin
            if(state==4)begin
                rec_data[recv_cnt] <= spi_miso;
                rec_neg            <= 1'b1;
            end else begin
                rec_data     <= 1'b0;
                rec_neg      <= 1'b0;
            end
        end
    end
/////////// ---------------------------------------------------------------------------------
/////////// ---------------------------------------------------------------------------------
/////////// ---------------------------------------------------------------------------------
end
endgenerate


assign o_tx_done = tx_done;
assign o_rx_done = rx_done;
assign ov_data_out = rec_data;

//    ila_adc U_ila_adc(
//     .clk(ps_reg_clk)
//    ,.probe0({i_sys_clk,i_rst_n,o_spi_clk,o_spi_mosi,i_spi_miso,o_spi_cs_n,rx_done,tx_done})
//    ,.probe1({send_cnt,recv_cnt})
//    ,.probe2(data_in)
//    ,.probe3({state,rx_start,tx_start,spi_ready,spi_working,spi_clk_en})
//    ,.probe4(rec_data)
////    ,.probe5({dout[15:0]})
////    ,.probe6(rec_data)
//    );
    

endmodule
