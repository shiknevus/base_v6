`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23
// Design Name: 
// Module Name: common_rs232_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// set slave addr:

//////////////////////////////////////////////////////////////////////////////////
module common_rs232_top
(
     input  wire                        i_clk
    ,input  wire                        i_rst

    ,input  wire                        i_clear
    ,input  wire [4:0]                  i_rx_sel
    ,output wire [31:0]                 o_rx_32data
    ,input  wire                        uart_rxd
    ,output wire                        uart_txd
    ,output wire                        uart_dir

    ,input  wire [2:0]                  rs232_baud_rate
    ,input  wire [1:0]                  rs232_odd_even
    ,input  wire                        rs232_start_send
    ,input  wire [7:0]                  rs232_send_num
    ,input  wire [7:0]                  rs232_recv_num
    ,input  wire [7:0]                  rs232_tail_symbol
    ,input  wire [31:0]                 rs232_send_char1
    ,input  wire [31:0]                 rs232_send_char2
    ,input  wire [31:0]                 rs232_send_char3
    ,input  wire [31:0]                 rs232_send_char4
    ,input  wire [31:0]                 rs232_send_char5
    ,input  wire [31:0]                 rs232_send_char6
);
    localparam  INTERVAL_10ms  = 32'd1000000;      //10ms
    localparam  TXD_DATA_NUM = 8'd24;
    localparam  RXD_DATA_NUM = 8'd64;
    localparam  ST_RX_IDLE   = 0;
    localparam  ST_RX_WORK   = 1;
    localparam  ST_RX_SAVE   = 2;
    localparam  ST_RX_OK     = 3;
    localparam  ST_RX_ERR    = 4;
    localparam  ST_RX_END    = 5;
    
    reg [31:0]  rs232_rx_buf0[15:0];
    reg [31:0]  rs232_rx_buf1[15:0];
    reg         buf_flag;
    reg [27:0]  uart_id;
    reg [7:0]   uart_rx_state;
    reg [7:0]   uart_tx_state;
    reg [7:0]   rx_num;
    wire [7:0]  rx_data;
    reg [7:0]   rx_dev_data[RXD_DATA_NUM-1:0];
    reg [31:0]  rx_time;
    wire        rx_ready;
    reg         rx_ready_d1;
    reg         rx_err_flag;
    wire        tx_cmd;
    reg [7:0]   tx_num;
    reg [7:0]   tx_num_buf;
    reg [7:0]   tx_data;
    wire [7:0]  tx_dev_data[TXD_DATA_NUM-1:0];
    wire        tx_ready;
    reg         tx_ready_d1;
    reg         rs232_send_d1;
    reg         latch_txd_work;
    wire        no_cmd_send;
    reg [31:0]  send_cnt_add;
    wire        send_cnt_max;

    assign {tx_dev_data[3],tx_dev_data[2],tx_dev_data[1],tx_dev_data[0]} = rs232_send_char1;
    assign {tx_dev_data[7],tx_dev_data[6],tx_dev_data[5],tx_dev_data[4]} = rs232_send_char2;
    assign {tx_dev_data[11],tx_dev_data[10],tx_dev_data[9],tx_dev_data[8]} = rs232_send_char3;
    assign {tx_dev_data[15],tx_dev_data[14],tx_dev_data[13],tx_dev_data[12]} = rs232_send_char4;
    assign {tx_dev_data[19],tx_dev_data[18],tx_dev_data[17],tx_dev_data[16]} = rs232_send_char5;
    assign {tx_dev_data[23],tx_dev_data[22],tx_dev_data[21],tx_dev_data[20]} = rs232_send_char6;
    assign o_rx_32data = buf_flag ? rs232_rx_buf1[i_rx_sel] : rs232_rx_buf0[i_rx_sel];
    assign no_cmd_send = ((rs232_send_num==0) & (rs232_recv_num==0) & (rs232_tail_symbol==0)) ? 1'b1 : 1'b0;
    assign send_cnt_max = (send_cnt_add == INTERVAL_10ms) ? 1'b1 : 1'b0;
    assign tx_cmd   = latch_txd_work ? 1'b1 : 1'b0;
    assign uart_dir = latch_txd_work ? 1'b1 : 1'b0;

    always @(posedge i_clk)begin
        tx_ready_d1 <= tx_ready;
        rx_ready_d1 <= rx_ready;
        rs232_send_d1 <= rs232_start_send;
    end
    
    always @(posedge i_clk)begin
        if(uart_dir) begin
            if(tx_num_buf != tx_num) begin
                tx_num_buf <= tx_num;
                send_cnt_add <= 0;
            end else begin
                send_cnt_add <= send_cnt_add + 1'b1;
            end
        end else begin
            send_cnt_add <= 0;
        end
    end

    always @(posedge i_clk)begin
        if(i_rst)begin
            latch_txd_work <= 1'b0;
        end else if((rs232_start_send & ~rs232_send_d1) & (rs232_send_num > 0)) begin
            latch_txd_work <= 1'b1; 
        end else if(send_cnt_max | (uart_dir & (tx_ready & ~tx_ready_d1) & (tx_num == rs232_send_num-1))) begin
            latch_txd_work <= 1'b0;
        end else begin
            latch_txd_work <= latch_txd_work;
        end
    end
    
    always @(posedge i_clk)begin
        if(i_rst)begin
            tx_data <= 0;
            tx_num  <= 0;
        end else if(uart_dir) begin
            tx_data <= tx_dev_data[tx_num];
            if(tx_ready & ~tx_ready_d1) begin
                if(tx_num == rs232_send_num-1) begin
                    tx_num <= 0;
                end else begin
                    tx_num <= tx_num + 1'b1;
                end    
            end else begin
                tx_num <= tx_num;
            end
        end else begin 
            tx_data <= 0;
            tx_num  <= 0;  
        end
    end

    always @(posedge i_clk)begin
        if(i_rst)begin
            rx_err_flag <= 1'b0;
            rx_time <= 0;
            rx_num <= 0;
            buf_flag <= 1'b0;
            uart_id <= 0;
            uart_rx_state <= ST_RX_IDLE;
        end else begin
            case(uart_rx_state)
                ST_RX_IDLE: begin
                    if(rx_ready & ~rx_ready_d1) begin
                        rx_time <= 0;
                        rx_dev_data[0] <= rx_data;
                        if(((rs232_tail_symbol != 0) & (rx_data == rs232_tail_symbol)) | (no_cmd_send & (rx_data==8'h0d | rx_data==8'h0a))) begin
                            rx_num <= 0;
                            uart_rx_state <= ST_RX_IDLE;
                        end else begin
                            rx_num <= 1;
                            uart_rx_state <= ST_RX_WORK;
                        end
                    end
                end
                ST_RX_WORK: begin
                    if(rx_ready & ~rx_ready_d1) begin
                        rx_err_flag <= 1'b0;
                        rx_time <= 0;
                        rx_num <= rx_num + 1'b1;
                        rx_dev_data[rx_num] <= rx_data;
                        if(((rs232_tail_symbol != 0) & (rx_data == rs232_tail_symbol)) | (no_cmd_send & (rx_data==8'h0d | rx_data==8'h0a)) | ((rs232_recv_num != 0) & (rx_num == rs232_recv_num-1))) begin
                            uart_id <= uart_id + 1'b1;
                            uart_rx_state <= ST_RX_SAVE;
                        end
                    end else if(rx_time >= INTERVAL_10ms) begin
                        rx_err_flag <= 1'b1;
                        rx_time <= 0;                   
                        uart_id <= uart_id + 1'b1;      
                        uart_rx_state <= ST_RX_SAVE;    //uart_rx_state <= ST_RX_ERR;
                    end else begin
                        rx_time <= rx_time + 1'b1;       
                    end
                end
                ST_RX_SAVE: begin
                    rx_time <= rx_time + 1'b1;
                    if(buf_flag) begin
                        if(rx_time == 0) begin
                            rs232_rx_buf0[0] <= {rx_err_flag,3'd0,uart_id};
                        end else begin
                            rs232_rx_buf0[rx_time] <= {rx_dev_data[((rx_time-1)<<2)+3],rx_dev_data[((rx_time-1)<<2)+2],rx_dev_data[((rx_time-1)<<2)+1],rx_dev_data[((rx_time-1)<<2)+0]};
                        end
                    end else begin
                        if(rx_time == 0) begin
                            rs232_rx_buf1[0] <= {rx_err_flag,3'd0,uart_id};
                        end else begin
                            rs232_rx_buf1[rx_time] <= {rx_dev_data[((rx_time-1)<<2)+3],rx_dev_data[((rx_time-1)<<2)+2],rx_dev_data[((rx_time-1)<<2)+1],rx_dev_data[((rx_time-1)<<2)+0]}; 
                        end   
                    end
                    if(rx_time >= 15) begin
                        buf_flag <= ~buf_flag;
                        uart_rx_state <= ST_RX_OK;
                    end
                end
                ST_RX_OK,ST_RX_ERR: begin
                    rx_time <= 0;
                    uart_rx_state <= ST_RX_END;
                end
                ST_RX_END: begin
                    rx_time <= rx_time + 1'b1;
                    rx_dev_data[rx_time] <= 8'h00;
                    if(rx_time >= (RXD_DATA_NUM-1)) begin
                        rx_num <= 0;
                        uart_rx_state <= ST_RX_IDLE;
                    end
                end
                default: begin
                    rx_time <= 0;
                    rx_num <= 0;
                    uart_rx_state <= ST_RX_IDLE;
                end
            endcase
        end
    end
    
    uart_top    uart_top_u0
    (
	   .clk                (i_clk               ),
	   .reset              (i_rst               ),
		
	   .i_bps_sel          (rs232_baud_rate     ),
	   .i_odd_even_check   (rs232_odd_even      ),
	   .uart_txd           (uart_txd            ),
       .uart_rxd           (uart_rxd            ),
	   .tx_data            (tx_data             ),
       .rx_data            (rx_data             ),
	   .tx_ready		   (tx_ready            ),
       .rx_ready		   (rx_ready            ),
       .tx_en			   (tx_cmd              )
    );
     
endmodule
            