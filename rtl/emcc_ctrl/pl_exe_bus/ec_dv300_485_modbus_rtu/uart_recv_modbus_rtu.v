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

module uart_recv_modbus_rtu(
    input			  i_clk      , //时钟
    input             i_rst      , //高电平复位
    input   [15:0]    i_bps_cnt  , //时钟÷波特率，100MHz ÷ 9600=10416
    input   [1:0]     i_parity   , //奇偶校验，0=无校验 1=奇校验 2=偶校验
    input             i_uart_rxd , //UART接收端口
    output  reg       o_uart_done, //接收一帧数据完成标志信号
    output  reg [7:0] o_uart_data  //接收的数据
    );
    
//localparam i_bps_cnt  = CLK_FREQ/UART_BPS;        //为得到指定波特率，需要对系统时钟计数BPS_CNT次

    wire [14:0] BPS_CNT_half;
    assign BPS_CNT_half = i_bps_cnt[15:1];
                                                                                   
//reg define
        reg        uart_rxd_d0;
        reg        uart_rxd_d1;
        reg [15:0] clk_cnt;                             //系统时钟计数器
        reg [ 3:0] rx_cnt;                              //接收数据计数器
        reg        rx_flag;                             //接收过程标志信号
        reg [ 7:0] rxdata;                              //接收数据寄存器
        
        //wire define
        wire       start_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号
        assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    
        
        //对UART接收端口的数据延迟两个时钟周期
        always @(posedge i_clk or negedge i_rst) begin 
            if (i_rst) begin 
                uart_rxd_d0 <= 1'b0;
                uart_rxd_d1 <= 1'b0;          
            end
            else begin
                uart_rxd_d0  <= i_uart_rxd;                   
                uart_rxd_d1  <= uart_rxd_d0;
            end   
        end
        
        //当脉冲信号start_flag到达时，进入接收过程           
        always @(posedge i_clk or negedge i_rst) begin         
            if (i_rst)                                  
                rx_flag <= 1'b0;
            else begin
                if(start_flag)                          //检测到起始位
                    rx_flag <= 1'b1;                    //进入接收过程，标志位rx_flag拉高
                else if(clk_cnt == BPS_CNT_half)begin
                     if((i_parity==1)|(i_parity==2))begin//开启了奇偶校验，要等第10位奇偶校验位结束
                        if(rx_cnt == 4'd10)
                            rx_flag <= 1'b0;
                     end
                     else begin//未开启奇偶校验，第9位就算结束
                        if(rx_cnt == 4'd9)
                            rx_flag <= 1'b0;
                     end
                end
                else
                    rx_flag <= rx_flag;
            end
        end
        
        //进入接收过程后，启动系统时钟计数器与接收数据计数器
        always @(posedge i_clk or negedge i_rst) begin         
            if (i_rst) begin                             
                clk_cnt <= 16'd0;                                  
                rx_cnt  <= 4'd0;
            end                                                      
            else if ( rx_flag ) begin                   //处于接收过程
                    if (clk_cnt < i_bps_cnt - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                        rx_cnt  <= rx_cnt;
                    end
                    else begin
                        clk_cnt <= 16'd0;               //对系统时钟计数达一个波特率周期后清零
                        rx_cnt  <= rx_cnt + 1'b1;       //此时接收数据计数器加1
                    end
                end
                else begin                              //接收过程结束，计数器清零
                    clk_cnt <= 16'd0;
                    rx_cnt  <= 4'd0;
                end
        end
        reg parity_bit;//目前对接收数据不做奇偶校验，备用
        //根据接收数据计数器来寄存uart接收端口数据
        always @(posedge i_clk or negedge i_rst) begin 
            if ( i_rst)  begin
                rxdata <= 8'd0;                                     
                parity_bit <=  'b0;                                     
            end else if(rx_flag)                            //系统处于接收过程
                if (clk_cnt == BPS_CNT_half) begin         //判断系统时钟计数器计数到数据位中间
                    case ( rx_cnt )
                     4'd0 : rxdata[0] <= uart_rxd_d1; // 起始位, 无用
                     4'd1 : rxdata[0] <= uart_rxd_d1;   //寄存数据位最低位
                     4'd2 : rxdata[1] <= uart_rxd_d1;
                     4'd3 : rxdata[2] <= uart_rxd_d1;
                     4'd4 : rxdata[3] <= uart_rxd_d1;
                     4'd5 : rxdata[4] <= uart_rxd_d1;
                     4'd6 : rxdata[5] <= uart_rxd_d1;
                     4'd7 : rxdata[6] <= uart_rxd_d1;
                     4'd8 : rxdata[7] <= uart_rxd_d1;   //寄存数据位最高位
                     4'd9 : parity_bit <= uart_rxd_d1;   //寄存数据位最高位(rx_cnt=9仅在开启奇偶校验时出现)
                     default:;                                    
                    endcase
                end
                else begin
                    rxdata <= rxdata;
                    parity_bit <= parity_bit;
                end
            else begin
                rxdata <= 8'd0;
                parity_bit <= 0;
            end
        end
        
        //数据接收完毕后给出标志信号并寄存输出接收到的数据
        always @(posedge i_clk or negedge i_rst) begin        
            if (i_rst) begin
                o_uart_data <= 8'd0;                               
                o_uart_done <= 1'b0;
            end
            else begin
                if((i_parity==1)|(i_parity==2))begin//开启了奇偶校验，要等第10位奇偶校验位结束
                    if(rx_cnt == 4'd10) begin//接收数据计数器计数到停止位时
                        o_uart_data <= rxdata; //寄存输出接收到的数据
                        o_uart_done <= 1'b1;   //并将接收完成标志位拉高
                    end
                    else begin                                 
                    //  o_uart_data <= 8'd0;
                        o_uart_done <= 1'b0; 
                    end
                end
                else begin
                    if(rx_cnt == 4'd9) begin//未开启奇偶校验，第9位就算结束
                        o_uart_data <= rxdata; //寄存输出接收到的数据
                        o_uart_done <= 1'b1;   //并将接收完成标志位拉高
                    end
                    else begin                                 
                    //  o_uart_data <= 8'd0;
                        o_uart_done <= 1'b0; 
                    end
                end
            end  
        end

endmodule	