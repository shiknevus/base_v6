`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/15 15:23:54
// Design Name: 
// Module Name: uart_osm61_driver
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


module uart_osm61_driver#(
    parameter  RAM_DWIDTH  =   32
   ,parameter  STX = 8'h02
   ,parameter  ETX = 8'h03
   ,parameter  CLK_FREQ = 100000000
   ,parameter  UART_BPS = 9600
) (
     input                                      clk
    ,input                                      reset

    ,input  wire             i_uart_rx
    ,output wire             o_uart_tx
    ,output wire             o_uart_de
    
    ,input  wire [7:0]                       iv_sub_addr
    ,input  wire                             i_send_start
    ,output reg                              o_send_ready
    ,input  wire [7:0]                       iv_send_length
    ,input  wire [RAM_DWIDTH*RAM_DWIDTH-1:0] iv_rs232_data_send
    ,output reg                              o_rs232_data_pack_ok
    ,output reg [RAM_DWIDTH*RAM_DWIDTH-1:0]  ov_rs232_data_rcv
);

assign o_uart_de = ~o_send_ready;  // 0:receive   1:send

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

//reg  [RAM_DWIDTH*RAM_DWIDTH-1-16:0] crc_check_data;
reg [RAM_DWIDTH*RAM_DWIDTH-1:0]  crc_check_data;
reg  crc_cal_start;
wire crc_cal_done;
wire[15:0] crc_reg;
CRC16_modbus #(
   .RAM_DWIDTH     (RAM_DWIDTH   )
)U_CRC16_modbus(
    .sys_clk         (clk),   
    .rst_n           (reset),
    
    .iv_crc_data     (crc_check_data),
    .i_crc_cal_start (crc_cal_start),
    .iv_data_length  (5 ),
    .o_crc_cal_done  (crc_cal_done),
    .ov_crc_reg      (crc_reg)
);
wire [7:0] CRC_HIGH ;
wire [7:0] CRC_LOW ;
assign CRC_HIGH = crc_reg[15:8];
assign CRC_LOW  = crc_reg[7:0];

reg [3:0] rx_state;
reg [7:0] rx_cnt;
reg [16:0] delay_cnt;
always @(posedge clk)begin
    if(reset)begin
        rx_state <= 'd0;
        rx_cnt   <= 'd0;
        o_rs232_data_pack_ok   <= 1'b0;
        ov_rs232_data_rcv   <= 'd0;
        delay_cnt   <= 'd0;
        crc_check_data <= 'd0;
        crc_cal_start <= 'd0;
    end else begin
        case(rx_state)
            0:begin
                if(rx_vld && (rx_data == iv_sub_addr))begin
                    ov_rs232_data_rcv[7:0] <= rx_data;
                    crc_check_data[7:0]  <= rx_data;                
                    rx_state <= 'd1;
                    rx_cnt   <= 1;
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= 'd0;
                end
                o_rs232_data_pack_ok   <= 1'b0;
                delay_cnt   <= 'd0;
            end
            1:begin
                if(rx_vld)begin
                    ov_rs232_data_rcv[15:8] <= rx_data;
                    crc_check_data[15:8]  <= rx_data;                   
                    rx_state <= 'd2;
                    rx_cnt   <= rx_cnt + 2;   
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                end
                o_rs232_data_pack_ok   <= 1'b0;
                delay_cnt   <= 'd0;
            end
            2:begin
                if(rx_vld)begin
                    ov_rs232_data_rcv[(((rx_cnt) * 8)-1) -:8] <= rx_data;
                    crc_check_data[(((rx_cnt) * 8)-1) -:8]  <= rx_data;
                    if(rx_cnt == 7)begin                                                     
                        rx_state <= 'd3;
                        crc_cal_start <= 1'b1;                                               
                    end else begin
                        rx_state <= rx_state;
                    end
                    rx_cnt   <= rx_cnt + 1;   //3                
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                end
                delay_cnt   <= 'd0;
            end
            3:begin
                if(rx_vld)begin
                    ov_rs232_data_rcv[(((rx_cnt) * 8)-1) -:8] <= rx_data;                  
                    if(rx_cnt == 9)begin                                                     
                        rx_state <= 'd5;                         
                    end else begin
                        rx_state <= rx_state;
                    end
                    rx_cnt   <= rx_cnt + 1;                   
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                end
                delay_cnt   <= 'd0;
            end                     
            4:begin
                if(rx_vld)begin
                    if(crc_cal_done)begin
                        //rx_state <= ((CRC_LOW == ov_rs232_data_rcv[47:40]) && (CRC_HIGH == ov_rs232_data_rcv[55:48])) ? 5 : rx_state ;
                        rx_state <= (CRC_LOW == ov_rs232_data_rcv[63:56]) ? 5 : rx_state ; 
                    end else begin
                        rx_state <= rx_state;
                        rx_cnt   <= rx_cnt;
                    end                                      
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                end
                delay_cnt   <= 'd0;
            end            
            5:begin // delay
                if(delay_cnt == 100000)begin  // 1ms
                    rx_state <= 'd0;
                    o_rs232_data_pack_ok   <= 1'b1;
                    delay_cnt   <= 'd0;
                end else begin
                    rx_state <= rx_state;
                    delay_cnt   <= delay_cnt + 1;
                    o_rs232_data_pack_ok   <= 1'b0;
                end
                crc_check_data <= 'd0;
                rx_cnt   <= 'd0;
            end
            default:begin
                rx_state <= 'd0;
                rx_cnt   <= 'd0;
            end
        endcase
    end    
end



//always @(posedge clk)begin
//    if(reset)begin
//        rx_state <= 'd0;
//        rx_cnt   <= 'd0;
//        o_rs232_data_pack_ok   <= 1'b0;
//        ov_rs232_data_rcv   <= 'd0;
//        delay_cnt   <= 'd0;
//        crc_check_data <= 'd0;
//        crc_cal_start <= 'd0;
//    end else begin
//        case(rx_state)
//            0:begin
//                if(rx_vld && (rx_data == iv_sub_addr))begin
//                    ov_rs232_data_rcv[7:0] <= rx_data;
//                    crc_check_data[7:0]  <= rx_data;                
//                    rx_state <= 'd1;
//                    rx_cnt   <= 1;
//                end else begin
//                    rx_state <= rx_state;
//                    rx_cnt   <= 'd0;
//                end
//                o_rs232_data_pack_ok   <= 1'b0;
//                delay_cnt   <= 'd0;
//            end
//            1:begin
//                if(rx_vld)begin
//                    ov_rs232_data_rcv[15:8] <= rx_data;
//                    crc_check_data[15:8]  <= rx_data;                   
//                    rx_state <= 'd2;
//                    rx_cnt   <= rx_cnt + 2;   
//                end else begin
//                    rx_state <= rx_state;
//                    rx_cnt   <= rx_cnt;
//                end
//                o_rs232_data_pack_ok   <= 1'b0;
//                delay_cnt   <= 'd0;
//            end
//            2:begin
//                if(rx_vld)begin
//                    ov_rs232_data_rcv[(((rx_cnt) * 8)-1) -:8] <= rx_data;
//                    crc_check_data[(((rx_cnt) * 8)-1) -:8]  <= rx_data;
//                    if(rx_cnt == 5)begin                                                     
//                        rx_state <= 'd3;
//                        crc_cal_start <= 1'b1;                                               
//                    end else begin
//                        rx_state <= rx_state;
//                    end
//                    rx_cnt   <= rx_cnt + 1;   //3                
//                end else begin
//                    rx_state <= rx_state;
//                    rx_cnt   <= rx_cnt;
//                end
//                delay_cnt   <= 'd0;
//            end
//            3:begin
//                if(rx_vld)begin
//                    ov_rs232_data_rcv[(((rx_cnt) * 8)-1) -:8] <= rx_data;                  
//                    if(rx_cnt == 7)begin                                                     
//                        rx_state <= 'd5;                         
//                    end else begin
//                        rx_state <= rx_state;
//                    end
//                    rx_cnt   <= rx_cnt + 1;                   
//                end else begin
//                    rx_state <= rx_state;
//                    rx_cnt   <= rx_cnt;
//                end
//                delay_cnt   <= 'd0;
//            end                     
//            4:begin
//                if(rx_vld)begin
//                    if(crc_cal_done)begin
//                        //rx_state <= ((CRC_LOW == ov_rs232_data_rcv[47:40]) && (CRC_HIGH == ov_rs232_data_rcv[55:48])) ? 5 : rx_state ;
//                        rx_state <= (CRC_LOW == ov_rs232_data_rcv[47:40]) ? 5 : rx_state ; 
//                    end else begin
//                        rx_state <= rx_state;
//                        rx_cnt   <= rx_cnt;
//                    end                                      
//                end else begin
//                    rx_state <= rx_state;
//                    rx_cnt   <= rx_cnt;
//                end
//                delay_cnt   <= 'd0;
//            end            
//            5:begin // delay
//                if(delay_cnt == 100000)begin  // 1ms
//                    rx_state <= 'd0;
//                    o_rs232_data_pack_ok   <= 1'b1;
//                    delay_cnt   <= 'd0;
//                end else begin
//                    rx_state <= rx_state;
//                    delay_cnt   <= delay_cnt + 1;
//                    o_rs232_data_pack_ok   <= 1'b0;
//                end
//                crc_check_data <= 'd0;
//                rx_cnt   <= 'd0;
//            end
//            default:begin
//                rx_state <= 'd0;
//                rx_cnt   <= 'd0;
//            end
//        endcase
//    end    
//end


reg       tx_en;         
reg [7:0] tx_data;    
wire      tx_ready;

reg [7:0] rs232_data_send_buf[RAM_DWIDTH*4-1:0];
reg [3:0] send_state;
integer for_i;
reg [7:0] send_cnt;
reg [7:0] send_length;
reg [16:0] tx_end_wait_cnt;
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
                send_length <= iv_send_length;
                send_cnt <= 0;
                tx_en <= 0;
                tx_data <= 0;
                tx_end_wait_cnt <= 0;
            end
            1:begin
                for(for_i=0;for_i<send_length;for_i=for_i+1)begin
                    rs232_data_send_buf[for_i] <= iv_rs232_data_send[((send_length-for_i)*8-1) -: 8];
                end
                send_state <= tx_ready ? 2 : 1;
                send_length <= iv_send_length;
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
                if(tx_end_wait_cnt == 100000)begin // 1ms
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


//ila_e5cc_uart U_ila_e5cc_uart(
// .clk(clk)
//,.probe0({rx_state,send_state})
//,.probe1({i_uart_rx,o_uart_tx,tx_ready,tx_en,rx_done,send_start,o_send_ready,rx_vld})
//,.probe2({rx_data,tx_data})
//,.probe3({send_cnt,rx_cnt})
//);

//ila_e5cc_uart U_ila_e5cc_uart(
// .clk(clk)
//,.probe0(crc_check_data)
//,.probe1(rx_data)
//,.probe2(crc_reg[7:0])
//,.probe3(rx_vld)
//,.probe4(rx_state)
//);

// ila_0 your_instance_name (
//	.clk           (clk), // input wire clk
//
//	.probe0        (crc_check_data), // input wire [1023:0]  probe0  
//	.probe1        (rx_data), // input wire [7:0]  probe1 
//	.probe2        (rx_state), // input wire [7:0]  probe2 
//	.probe3        (rx_cnt) // input wire [3:0]  probe3
//);

uart_recv #(                    
    .CLK_FREQ       (CLK_FREQ),   
    .UART_BPS       (UART_BPS))   
u_uart_recv(                 
    .sys_clk        (clk   ), 
    .sys_rst_n      (~reset),
    
    .uart_rxd       (i_uart_rx),
    .uart_done      (rx_done),
    .uart_data      (rx_data)
    );
    
uart_send #(                          
    .CLK_FREQ       (CLK_FREQ),       
    .UART_BPS       (UART_BPS))     
u_uart_send(                 
    .sys_clk        (clk   ),
    .sys_rst_n      (~reset),
     
    .uart_en        (tx_en),
    .uart_din       (tx_data),
    .uart_tx_ready  (tx_ready),
    .uart_txd       (o_uart_tx)
    );
    
endmodule