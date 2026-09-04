`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: 
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


module uart_driver_modbus_rtu#(
    parameter  RAM_DWIDTH  =   32,
    parameter  CLK_FREQ = 100000000
) (
     input                  clk           ,
    input                   reset         ,
    input  wire  [19:0]     i_uart_bps    ,
    input  wire  [7:0]      i_frame_gap   ,
    input        [1:0]      i_parity      , //奇偶校验，0=None 无校验 1=Odd 奇校验 2=EVE偶校验
    input  wire             i_uart_rx     ,
    output wire             o_uart_tx     ,
    output reg              o_uart_de     ,
    
    input  wire                             i_send_start   ,// level or pulse all right , just detect drising edge
    output reg                              o_send_ready   ,
    input  wire [7:0]                       i_send_length  ,
    input  wire [RAM_DWIDTH*RAM_DWIDTH-1:0] i_data_send    ,
    output reg                              o_data_pack_ok ,
    output reg [RAM_DWIDTH*RAM_DWIDTH-1:0]  o_data_rcv     
);

always @(posedge clk)begin
    if(reset)begin
        o_uart_de <= 0;
    end else begin
        o_uart_de <= ~o_send_ready;
    end
end


reg send_start_n;
wire send_start = (send_start_n != i_send_start)&&(send_start_n == 0);  // rising edge 
always @(posedge clk)begin
    if(reset)begin
        send_start_n <= 0;
    end else begin
        send_start_n <= i_send_start;
    end
end

wire       rx_done;    
wire [7:0] rx_data;    
reg rx_done_n;
wire rx_vld = (~rx_done_n) & rx_done;
always @(posedge clk)begin
    if(reset)begin
        rx_done_n <= 0;
    end else begin
        rx_done_n <= rx_done;
    end    
end
reg  [22:0] cfg_1byte_trans_time; 
wire [23:0] cfg_1byte_trans_time_x2; 
reg  [19:0] cfg_frame_gap;
reg         rx_stop_en;
reg  [19:0] rx_stop_cnt;

reg [3:0] rx_state;
reg [7:0] rx_cnt;
reg [16:0] delay_cnt;
always @(posedge clk)begin
    if(reset)begin
        rx_state <= 'd0;
        rx_cnt   <= 'd0;
        o_data_pack_ok   <= 1'b0;
        o_data_rcv   <= 'd0;
        delay_cnt   <= 'd0;
    end else begin
        case(rx_state)
            0:begin
                //if(rx_vld && (rx_data == STX))begin
                if(rx_vld)begin
                    o_data_rcv[7:0] <= rx_data;
                    rx_state <= 'd1;
                    rx_cnt   <= 1;
                end else begin
                    rx_state <= 'd0;
                    rx_cnt   <= 'd0;
                end
                o_data_pack_ok   <= 1'b0;
                delay_cnt   <= 'd0;
            end
            1:begin
                if(rx_vld)begin
                    o_data_rcv[(((rx_cnt+1) * 8)-1) -:8] <= rx_data;
                    rx_state <= 'd1;
                    rx_cnt   <= rx_cnt + 1;
                end 
                else if(rx_stop_en)begin
                        rx_state <= 'd2;
                        rx_cnt   <= 'd0;
                end else begin
                    rx_state <= 'd1;
                    rx_cnt   <= rx_cnt;
                end
                delay_cnt   <= 'd0;
            end
            2:begin // delay
            //    if(delay_cnt == 100000)begin  // 1ms
                    rx_state <= 'd0;
                    o_data_pack_ok   <= 1'b1;
                    delay_cnt   <= 'd0;
            //    end else begin
            //        rx_state <= 'd2;
            //        delay_cnt   <= delay_cnt + 1;
            //        o_data_pack_ok   <= 1'b0;
            //    end
                rx_cnt   <= 'd0;
            end
            default:begin
                rx_state <= 'd0;
                rx_cnt   <= 'd0;
            end
        endcase
    end    
end

always @(posedge clk)begin
    if(reset)begin
        rx_stop_cnt <= 0;
    end
    else begin
        if(rx_state!=0)begin
            if(rx_vld)
                rx_stop_cnt <= 0;
            else
                rx_stop_cnt = rx_stop_cnt + 1'b1;
        end
    end
end

always @(posedge clk)begin
    if(reset)
        rx_stop_en <= 1'b0;
    else begin
        if(rx_state!=0)begin
            if(rx_stop_cnt==cfg_1byte_trans_time_x2)rx_stop_en <= 1'b1;//different bps use different delay
        end
        else
            rx_stop_en <= 1'b0;
    end
end

// ------------------------- frame_gap 帧间隔 （备用） -------------------------------------
//低速（≤19200 bps）：严格遵循 3.5个字符时间 的动态计算值。
//高速（> 19200 bps）：使用 固定的 1.75ms。
always @(posedge clk)begin
    if(reset)
        cfg_frame_gap <= 1'b0;
    else begin
        if(i_frame_gap==0)
            case(i_uart_bps)
                2400   :cfg_frame_gap <= CLK_FREQ * 0.00420 * 3.5; //2400MHz = 14.4ms *3.5
                4800   :cfg_frame_gap <= CLK_FREQ * 0.00210 * 3.5; //4800bps = 7.2ms *3.5
                9600   :cfg_frame_gap <= CLK_FREQ * 0.00105 * 3.5; //9600bps = 3.65ms *3.5
                19200  :cfg_frame_gap <= CLK_FREQ * 0.00070 * 3.5; //19200bps = 1.8ms *3.5
                38400  :cfg_frame_gap <= CLK_FREQ * 0.00057 * 3.5; //38400bps=1.75ms *3.5（min 1.75ms for safe）
                57600  :cfg_frame_gap <= CLK_FREQ * 0.00057 * 3.5; //57600bps=1.75ms *3.5（min 1.75ms for safe）
                115200 :cfg_frame_gap <= CLK_FREQ * 0.00057 * 3.5; //115200bps = 1.75ms *3.5（min 1.75ms for safe）
                128000 :cfg_frame_gap <= CLK_FREQ * 0.00057 * 3.5; //115200bps = 1.75ms *3.5（min 1.75ms for safe）
                default:cfg_frame_gap <= CLK_FREQ * 0.00105 * 3.5; //default 9600bps
            endcase
        else
            cfg_frame_gap<=i_frame_gap;
    end
end

// ------------------------- TX -------------------------------------

reg       tx_en;         
reg [7:0] tx_data;    
wire      tx_ready;

reg [7:0] rs232_data_send_buf[RAM_DWIDTH*4-1:0];
reg [3:0] send_state;
integer for_i;
reg [7:0] send_cnt;
reg [7:0] send_length;
reg [23:0] tx_end_wait_cnt;
always @(posedge clk)begin
    if(reset)begin
        send_state <= 0;
        send_cnt <= 'h0;
        send_length <= 0;
        o_send_ready <= 0;
        tx_en <= 0;
        tx_data <= 0;
        tx_end_wait_cnt <= 0;
    end else begin
        case(send_state)
            0:begin
                if(send_start)begin
                    send_state <= 1;
                    o_send_ready <= 0;
                end else begin
                    send_state <= 0;
                    o_send_ready <= 1;
                end
                send_length <= i_send_length;
                send_cnt <= 0;
                tx_en <= 0;
                tx_data <= 0;
                tx_end_wait_cnt <= 0;
            end
            1:begin
                for(for_i=0;for_i<send_length;for_i=for_i+1)begin
                    rs232_data_send_buf[for_i] <= i_data_send[((send_length-for_i)*8-1) -: 8];
                end
                send_state <= tx_ready ? 2 : 1;
                send_length <= i_send_length;
                send_cnt <= 0;
                tx_end_wait_cnt <= 0;
            end
            2:begin
                send_state <= 3;
                tx_en <= 1;
                tx_data <= rs232_data_send_buf[send_cnt];
                send_cnt <= send_cnt + 1;
                tx_end_wait_cnt <= 0;
            end
            3:begin
                send_state <= 4;
                tx_en <= 0;
                tx_data <= tx_data;
                send_cnt <= send_cnt;
                tx_end_wait_cnt <= 0;
            end
            4:begin
                if(tx_ready)begin
                    if(send_cnt==send_length)send_state <= 5;
                    else send_state <= 2;
                end else begin
                    send_state <= 4;
                end
                tx_en <= 0;
                tx_data <= tx_data;
                send_cnt <= send_cnt;
                tx_end_wait_cnt <= 0;
            end
            5:begin
                if(tx_end_wait_cnt==cfg_1byte_trans_time)begin//different bps use different delay
                    send_state <= 0;
                    tx_end_wait_cnt <= 0;
                end else begin
                    send_state <= 5;
                    tx_end_wait_cnt <= tx_end_wait_cnt + 1;
                end
            end
            default:begin
                send_state <= 0;
                tx_en <= 0;
                tx_data <= tx_data;
                send_cnt <= send_cnt;
            end
        endcase
    end
end

// ------------------------- 1byte trans time -------------------------------------

always @(posedge clk)begin
    if(reset)
        cfg_1byte_trans_time <= 0;
    else begin
        if(i_frame_gap==0)
            case(i_uart_bps)
                2400   :cfg_1byte_trans_time <= CLK_FREQ * 0.00420; //2400bps ,use 4.2ms
                4800   :cfg_1byte_trans_time <= CLK_FREQ * 0.00210; //4800bps ,use 2.1ms
                9600   :cfg_1byte_trans_time <= CLK_FREQ * 0.00105; //9600bps ,use 1.05ms
                14400  :cfg_1byte_trans_time <= CLK_FREQ * 0.00070; //14400bps ,use 0.70ms
                19200  :cfg_1byte_trans_time <= CLK_FREQ * 0.00052; //19200bps,use 0.52ms
                38400  :cfg_1byte_trans_time <= CLK_FREQ * 0.00026; //38400bps,use 0.26ms
                57600  :cfg_1byte_trans_time <= CLK_FREQ * 0.00013; //57600bps,use 0.13ms
                115200 :cfg_1byte_trans_time <= CLK_FREQ * 0.00010; //11520000bps,use 0.07ms（min 0.1ms for safe）
                128000 :cfg_1byte_trans_time <= CLK_FREQ * 0.00010; //11520000bps,use 0.06ms（min 0.1ms for safe）
                default:cfg_1byte_trans_time <= CLK_FREQ * 0.00105; //default 9600bps ,use 1.05ms
            endcase
        else
            cfg_1byte_trans_time <= CLK_FREQ * 0.00105 * 2;//default 9600bps ,use 1ms
    end
end
    assign cfg_1byte_trans_time_x2= {cfg_1byte_trans_time,1'b0};

// ---- System CLK Divied Baud Rate ----
// ---- 系统时钟÷波特率， Example:  100MHz/9600=10416 ; 156.25MHz/9600=16276
reg [15:0] BPS_CNT;
always @(posedge clk)begin
    if(reset)begin
        BPS_CNT <= 0;
    end
    else begin
        case(i_uart_bps)
            2400  :BPS_CNT <= CLK_FREQ / 2400 ;
            4800  :BPS_CNT <= CLK_FREQ / 4800 ;
            9600  :BPS_CNT <= CLK_FREQ / 9600 ; //100MHz/9600=10416 ; 156.25MHz/9600=16276
            15200 :BPS_CNT <= CLK_FREQ / 15200;
            19200 :BPS_CNT <= CLK_FREQ / 19200;
            38400 :BPS_CNT <= CLK_FREQ / 38400;
            57600 :BPS_CNT <= CLK_FREQ / 57600;
            115200:BPS_CNT <= CLK_FREQ / 115200;
            128000:BPS_CNT <= CLK_FREQ / 128000;
            default:BPS_CNT <= CLK_FREQ/ 9600  ;//default bps=9600
        endcase
    end
end


uart_recv_modbus_rtu 
u_uart_recv( 
    .i_clk          ( clk        ), //时钟
    .i_rst          ( reset      ), //复位，高电平复位
    .i_bps_cnt      ( BPS_CNT    ), //系统时钟÷波特率，100MHz ÷ 9600=10416；
    .i_parity       ( i_parity   ), //奇偶校验，0=无校验 1=奇校验 2=偶校验
    .i_uart_rxd     ( i_uart_rx  ), //UART接收端口
    .o_uart_done    ( rx_done    ), //接收一帧数据完成标志信号
    .o_uart_data    ( rx_data    )  //接收的数据
);

uart_send_modbus_rtu
u_uart_send(  
    .i_clk          ( clk        ), //时钟
    .i_rst          ( reset      ), //复位，高电平复位
    .i_bps_cnt      ( BPS_CNT    ), //系统时钟÷波特率，100MHz ÷ 9600=10416；
    .i_parity       ( i_parity   ), //奇偶校验，0=无校验 1=奇校验 2=偶校验
    .i_uart_en      ( tx_en      ), //发送使能信号
    .i_uart_din     ( tx_data    ), //待发送数据
    .o_uart_tx_busy (            ), //发送忙状态标志      
    .o_uart_tx_ready( tx_ready   ), //发送忙状态标志      
    .o_uart_txd     ( o_uart_tx  ) //UART发送端口
    );
    

 /*  
uart_recv_modbus_rtu_old 
u_uart_recv_old(                 
    .sys_clk        (clk   ), 
    .sys_rst_n      (~reset),
    .BPS_CNT        (BPS_CNT ),
    .uart_rxd       (i_uart_rx),
    .uart_done      (),
    .uart_data      ()
    );
 
uart_send_modbus_rtu
u_uart_send(                 
    .sys_clk        (clk   ),
    .sys_rst_n      (~reset),
    .BPS_CNT        (BPS_CNT ),
    .uart_en        (tx_en),
    .uart_din       (tx_data),
    .uart_tx_ready  (tx_ready),
    .uart_txd       (o_uart_tx)
    );
    */
endmodule
