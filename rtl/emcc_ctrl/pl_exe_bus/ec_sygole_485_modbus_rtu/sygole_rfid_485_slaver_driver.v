`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/15 15:20:14
// Design Name: 
// Module Name: osm61_laser_distance_ctrl
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
/////////////////////////////////////////////////////////////////////////////////
module sygole_rfid_485_slaver_driver
(
    input                   i_clk             ,//  user clk ��100MHz or 156.25MHz��
    input                   i_rst             ,
    input                   i_prot_clk        ,// 156.25MHz
    input                   i_prot_rst        ,
    input   wire [31:0]     i_baud_rate       ,//���ڲ�����

	//--- �Ӱ�ӿ� use clk domain 156.25MHz --
	input  wire [4:0]       i_cur_slv_board_id, //
	input  wire [4:0]       i_slv_board_id    , 
	input  wire             i_rs485_ch_r_flag , //send en
	output reg  [31:0]      o_m2s_rs485_msg   , //send data
	input  wire             i_rs485_ch_flag   , //recv en
	input  wire [31:0]      i_s2m_rs485_msg   , //recv data

	//--- �Խ�ҵ��ģ�� clk domain 100MHz or 156.25MHz--
    input  wire             i_send_req        ,
    input  wire             i_send_req_p      ,
    output reg              o_send_finish_p   ,
    input  wire [8*21-1:0]  i_send_data       ,// little-end
    input  wire [8* 4-1:0]  i_send_data_head  ,
    output reg  [8*24-1:0]  o_recv_data       , //
    output reg              o_recv_finish_p   , // o_recv_data�ȶ��㹻��ʱ���������

    input  wire             i_uart_inspect    ,
    output reg  [7:0]       o_modbus_err_code  // 5 = SG_CRC_ERR ; 6 = SG_TIME_OUT
);

   localparam  INTERVAL_10ms  = 32'd1000000;      //10ms
   localparam  TXD_DATA_NUM   = 8'd24;
   localparam  RFID_READ_CMD  = 8'h03;
   localparam  RFID_WRITE_CMD = 8'h10;
   localparam  ST_IDLE      = 0;
   localparam  ST_TXD_E     = 1;
   localparam  ST_TXD_CRC   = 2;
   localparam  ST_TXD       = 3;
   localparam  ST_END       = 4;
     
    reg [7:0]    cur_state      ;
    reg [31:0]   time_cnt       ;
    reg [31:0]   uart_id_buf    ;
    reg         start_send_req;         //��ʼ����
   
    reg          i_send_req_dy1;
    reg [3:0]    uart_delay_cnt;
    reg          uart_id_flag  ;

    reg         m2s_send_finish_dy1;
    reg         m2s_send_finish_dy2;
    reg         m2s_send_finish_dy3;
    reg         m2s_send_finish_dy4;
    reg         m2s_send_finish_dy4_temp;
    reg         m2s_send_finish_dy5;

    reg         s2m_recv_finish_dy1;
    reg         s2m_recv_finish_dy2;
    reg         s2m_recv_finish_dy3;
    reg         s2m_recv_finish_dy4;
    reg         s2m_recv_finish_dy4_temp;
    reg         s2m_recv_finish_dy5;

// --------------- 156.25MHZ clock domain ---------------
    reg [7:0]    m2s_state;
    reg [7:0]    s2m_state;
 //   reg [3:0]    m2s_start_send;         //��ʼ����
 //   reg [7:0]    m2s_send_num;           //���͵��ֽ���
 //   reg [7:0]    m2s_recv_num;           //���յ��ֽ���
    reg           rs485_ch_flag_d1;
    reg           rs485_ch_flag_d2;
    reg  [31:0]   m2s_send_char1;         //�����ַ�1*4
    reg  [31:0]   m2s_send_char2;         //�����ַ�2*4
    reg  [31:0]   m2s_send_char3;         //�����ַ�3*4
    reg  [31:0]   m2s_send_char4;         //�����ַ�4*4
    reg  [31:0]   m2s_send_char5;         //�����ַ�5*4
    reg  [31:0]   m2s_send_char6;         //�����ַ�6*4
    reg           m2s_send_finish     ;
    reg [31:0]    s2m_uart_id         ;
    reg [7:0]     s2m_recv_byte[23:0] ;
    reg           s2m_recv_finish     ;
// ------------------------------------------------------

 // cross clock domain

   always @(posedge i_clk)begin
        if(i_rst)begin
            time_cnt <= 0;
            cur_state <= ST_IDLE;
        end else begin
            case(cur_state)
                ST_IDLE: begin
                    time_cnt <= 0;
                //  if(i_send_req) begin
                    if(i_send_req_p) begin
                    //  cur_state <= ST_TXD_E;
                        cur_state <= ST_TXD; //crc already finish
                    end
                end
         /*     ST_TXD_E: begin
                    time_cnt <= 0;
                   cur_state <= ST_TXD_CRC;
                end
               ST_TXD_CRC: begin
                    if(time_cnt == INTERVAL_10ms) begin
                        time_cnt <= time_cnt;
                        cur_state <= ST_TXD;
                    end else begin
                        time_cnt <= time_cnt + 1'b1; 
                        cur_state <= ST_TXD_CRC;                        
                    end
                end */
                ST_TXD: begin
                    time_cnt <= 0;
                //  cur_state <= ~i_send_req ? ST_IDLE : ST_TXD;
                    if(o_recv_finish_p) cur_state <= ST_IDLE;
                end
                default: begin
                    cur_state <= ST_IDLE;
                end
            endcase
        end
    end
    
  /* 
   always@(posedge i_clk) begin
       if(i_rst) begin
           start_send_req <= 1'b0;
       end else if(i_send_req) begin
           start_send_req <= (cur_state == ST_TXD) ? 1'b1 : 1'b0;
       end else begin
           start_send_req <= 1'b0;
       end
   end
*/
   always@(posedge i_clk) begin
       if(i_rst) begin
           start_send_req <= 1'b0;
       end
       else begin
        if(~start_send_req)begin
            if(i_send_req_p)
                 start_send_req <= 1'b1;
        end
        else begin
             if(o_recv_finish_p)
                start_send_req <= 0;
        end

       end
   end
    
    // ---------- corss clock domain without fifo -------
    always @(posedge i_clk)begin
        if(i_rst) begin
            uart_id_buf <= 0;
            uart_delay_cnt <= 12;
        end else if(uart_id_buf != s2m_uart_id) begin // it could stay mismatched for 2-3 clock cycles ;��bit��ʱ�����źţ��ȽϽ����һ�¿��ܻ����������ʱ��
            uart_id_buf <= s2m_uart_id;
            uart_delay_cnt <= 0;
        end else if(uart_delay_cnt < 12) begin
            uart_delay_cnt <= uart_delay_cnt + 1'b1;
        end
    end

    //send
    always @(posedge i_clk)begin
        if(i_rst) begin
            m2s_send_finish_dy1 <= 0;
            m2s_send_finish_dy2 <= 0;
            m2s_send_finish_dy3 <= 0;
            m2s_send_finish_dy4 <= 0;
            m2s_send_finish_dy4_temp <= 0;
            m2s_send_finish_dy5 <= 0;
            o_send_finish_p <= 0;
        end  begin 
            m2s_send_finish_dy1 <= m2s_send_finish;
            m2s_send_finish_dy2 <= m2s_send_finish_dy1;
            m2s_send_finish_dy3 <= m2s_send_finish_dy2;
            m2s_send_finish_dy4 <= m2s_send_finish_dy3;
            m2s_send_finish_dy4_temp <= m2s_send_finish_dy4 | m2s_send_finish_dy3 ;
            m2s_send_finish_dy5 <= m2s_send_finish_dy4_temp;
            o_send_finish_p <= m2s_send_finish_dy4_temp & (~m2s_send_finish_dy5);
        end
    end
    //receive
    always @(posedge i_clk)begin
        if(i_rst) begin
            s2m_recv_finish_dy1 <= 0;
            s2m_recv_finish_dy2 <= 0;
            s2m_recv_finish_dy3 <= 0;
            s2m_recv_finish_dy4 <= 0;
            s2m_recv_finish_dy4_temp <= 0;
            s2m_recv_finish_dy5 <= 0;
            o_recv_finish_p <= 0;
        end  begin 
            s2m_recv_finish_dy1 <= s2m_recv_finish;
            s2m_recv_finish_dy2 <= s2m_recv_finish_dy1;
            s2m_recv_finish_dy3 <= s2m_recv_finish_dy2;
            s2m_recv_finish_dy4 <= s2m_recv_finish_dy3;
            s2m_recv_finish_dy4_temp <= s2m_recv_finish_dy4 | s2m_recv_finish_dy3 ;
            s2m_recv_finish_dy5 <= s2m_recv_finish_dy4_temp;
            o_recv_finish_p <= s2m_recv_finish_dy4_temp & (~s2m_recv_finish_dy5);
        end
    end
    // -------------------------------------------------------
    
    always @(posedge i_clk)begin
        if(i_rst) begin
            uart_id_flag   <= 1'b0;
            i_send_req_dy1 <= 1'b0;
            o_modbus_err_code <= 0;
        end
        else begin
            i_send_req_dy1 <= i_send_req;
        //  if(i_send_req & ~i_send_req_dy1) begin
            if(i_send_req_p) begin    
                o_modbus_err_code <= 0;
                uart_id_flag  <= 1'b0;
            end else if(uart_delay_cnt == 10) begin // wait 10 clks for siginal corssing clock domain
                uart_id_flag  <= 1'b1;
                if(uart_id_buf[31])begin            //rx_err_flag
                    o_modbus_err_code <= 6;     	    //SG_TIME_OUT
                end else if(s2m_recv_byte[1]==RFID_WRITE_CMD) begin
                    o_modbus_err_code <= 1;  // 1 =ok
                end else if(s2m_recv_byte[1]==RFID_READ_CMD) begin
                    o_modbus_err_code <= 1;  // 1 =ok
                end else begin
                    o_modbus_err_code <= 5;         //SG_CRC_ERR
                end
            end else if(i_uart_inspect & ~uart_id_flag) begin    
                o_modbus_err_code <= 6;       //SG_TIME_OUT
            end
        end
    end


 // --------------- Receive and Send ---------------------------------
 //  ------------- 156.25MHz clock domain --------------------------------

   // ---------- send clk : 156.25MHz --------

   always@(posedge i_prot_clk) begin
       if(i_prot_rst) begin
            m2s_send_char1 <= 0;
            m2s_send_char2 <= 0;
            m2s_send_char3 <= 0;
            m2s_send_char4 <= 0;
            m2s_send_char5 <= 0;
            m2s_send_char6 <= 0;
       end else begin
            m2s_send_char1 <= i_send_data[8* 4-1:   0];        //{8'h00            ,8'h00          ,RFID_WRITE_CMD  ,i_dev_port       };
            m2s_send_char2 <= i_send_data[8* 8-1:8* 4];        //{i_tx_data1[31:24],8'h0C          ,          8'h06 ,8'h00            };
            m2s_send_char3 <= i_send_data[8*12-1:8* 8];        //{i_tx_data2[31:24],i_tx_data1[7:0],i_tx_data1[15:8],i_tx_data1[23:16]};
            m2s_send_char4 <= i_send_data[8*16-1:8*12];        //{i_tx_data3[31:24],i_tx_data2[7:0],i_tx_data2[15:8],i_tx_data2[23:16]};
            m2s_send_char5 <= i_send_data[8*20-1:8*16];        //{o_crc_reg[7:0]   ,i_tx_data3[7:0],i_tx_data3[15:8],i_tx_data3[23:16]};
            m2s_send_char6 <= {24'h0,i_send_data[8*21-1:8*20]};//{8'h00,8'h00,8'h00,o_crc_reg[15:8]};
       end
   end

    // ---------- send clk : 156.25MHz --------
/*
    assign  m2s_send_char1 = i_send_data[8* 4-1:   0];        //{8'h00            ,8'h00          ,RFID_WRITE_CMD  ,i_dev_port       };
    assign  m2s_send_char2 = i_send_data[8* 8-1:8* 4];        //{i_tx_data1[31:24],8'h0C          ,          8'h06 ,8'h00            };
    assign  m2s_send_char3 = i_send_data[8*12-1:8* 8];        //{i_tx_data2[31:24],i_tx_data1[7:0],i_tx_data1[15:8],i_tx_data1[23:16]};
    assign  m2s_send_char4 = i_send_data[8*16-1:8*12];        //{i_tx_data3[31:24],i_tx_data2[7:0],i_tx_data2[15:8],i_tx_data2[23:16]};
    assign  m2s_send_char5 = i_send_data[8*20-1:8*16];        //{o_crc_reg[7:0]   ,i_tx_data3[7:0],i_tx_data3[15:8],i_tx_data3[23:16]};
    assign  m2s_send_char6 = {24'h0,i_send_data[8*21-1:8*20]};//{8'h00,8'h00,8'h00,o_crc_reg[15:8]};
  */ 

   // ---------- send clk : 100MHz --------
   always@(posedge i_clk) begin
       if(i_rst) begin
            o_recv_data <= 0;
       end else begin
            o_recv_data[8*8-1:    0] <= {s2m_recv_byte[7] ,s2m_recv_byte[6] ,s2m_recv_byte[5] ,s2m_recv_byte[4] ,s2m_recv_byte[3] ,s2m_recv_byte[2] ,s2m_recv_byte[1] ,s2m_recv_byte[0] };
            o_recv_data[8*16-1:8* 8] <= {s2m_recv_byte[15],s2m_recv_byte[14],s2m_recv_byte[13],s2m_recv_byte[12],s2m_recv_byte[11],s2m_recv_byte[10],s2m_recv_byte[9] ,s2m_recv_byte[8] };
            o_recv_data[8*24-1:8*16] <= {s2m_recv_byte[23],s2m_recv_byte[22],s2m_recv_byte[21],s2m_recv_byte[20],s2m_recv_byte[19],s2m_recv_byte[18],s2m_recv_byte[17],s2m_recv_byte[16]};
       end
   end
/*
    assign  o_recv_data[8*8-1:    0] = {s2m_recv_byte[7] ,s2m_recv_byte[6] ,s2m_recv_byte[5] ,s2m_recv_byte[4] ,s2m_recv_byte[3] ,s2m_recv_byte[2] ,s2m_recv_byte[1] ,s2m_recv_byte[0] };
    assign  o_recv_data[8*16-1:8* 8] = {s2m_recv_byte[15],s2m_recv_byte[14],s2m_recv_byte[13],s2m_recv_byte[12],s2m_recv_byte[11],s2m_recv_byte[10],s2m_recv_byte[9] ,s2m_recv_byte[8] };
    assign  o_recv_data[8*24-1:8*16] = {s2m_recv_byte[23],s2m_recv_byte[22],s2m_recv_byte[21],s2m_recv_byte[20],s2m_recv_byte[19],s2m_recv_byte[18],s2m_recv_byte[17],s2m_recv_byte[16]};
*/
   // ---------- send clk : 156.25MHz --------
   always@(posedge i_prot_clk) begin
       if(i_prot_rst) begin
           o_m2s_rs485_msg <= 0;
           m2s_state <= 0;
       end else begin   
           case(m2s_state)
              0: begin
                  if(i_rs485_ch_r_flag) begin
                      o_m2s_rs485_msg <= s2m_uart_id;
                      m2s_state <= 1;
                  end
              end
              1: begin
              //  o_m2s_rs485_msg <= {m2s_tail_symbol,m2s_recv_num,m2s_send_num,m2s_start_send,m2s_baud_rate};
                  o_m2s_rs485_msg <= {i_send_data_head[31:5],start_send_req,i_send_data_head[3:0]};
                  m2s_state <= 2;
              end
              2: begin
                  o_m2s_rs485_msg <= m2s_send_char1;
                  m2s_state <= 3;
              end
              3: begin
                  o_m2s_rs485_msg <= m2s_send_char2;
                  m2s_state <= 4;
              end
              4: begin
                  o_m2s_rs485_msg <= m2s_send_char3;
                  m2s_state <= 5;
              end
              5: begin
                  o_m2s_rs485_msg <= m2s_send_char4;
                  m2s_state <= 6;
              end
              6: begin
                  o_m2s_rs485_msg <= m2s_send_char5;
                  m2s_state <= 7;
              end
              7: begin
                  o_m2s_rs485_msg <= m2s_send_char6;
                  m2s_state <= 8;
              end
              8: begin
                  o_m2s_rs485_msg <= 0;
                  m2s_state <= 9;
              end
              9: begin
                  o_m2s_rs485_msg <= 0;
                  m2s_state <= 10;
              end
              10: begin
                  o_m2s_rs485_msg <= 0;
                  m2s_state <= 11;
              end
              11: begin
                  o_m2s_rs485_msg <= 0;
                  m2s_state <= 12;
              end
              12: begin
                  o_m2s_rs485_msg <= 0;
                  m2s_state <= 0;
              end
              default: begin
                  o_m2s_rs485_msg <= 0;
                  m2s_state <= 0;
              end
           endcase
       end
   end
   
   // ---------- receive clk : 156.25MHz ------
   always@(posedge i_prot_clk) begin
       rs485_ch_flag_d1 <= i_rs485_ch_flag & (i_cur_slv_board_id == i_slv_board_id);
       rs485_ch_flag_d2 <= rs485_ch_flag_d1;
       if(i_prot_rst) begin
            s2m_uart_id <= 0;
            s2m_state <= 0;
            {s2m_recv_byte[3] ,s2m_recv_byte[2] ,s2m_recv_byte[1] ,s2m_recv_byte[0] } <= 0;
            {s2m_recv_byte[7] ,s2m_recv_byte[6] ,s2m_recv_byte[5] ,s2m_recv_byte[4] } <= 0;
            {s2m_recv_byte[11],s2m_recv_byte[10],s2m_recv_byte[9] ,s2m_recv_byte[8] } <= 0;
            {s2m_recv_byte[15],s2m_recv_byte[14],s2m_recv_byte[13],s2m_recv_byte[12]} <= 0;
            {s2m_recv_byte[19],s2m_recv_byte[18],s2m_recv_byte[17],s2m_recv_byte[16]} <= 0;
            {s2m_recv_byte[23],s2m_recv_byte[22],s2m_recv_byte[21],s2m_recv_byte[20]} <= 0;
       end else begin   
           case(s2m_state)
              0: begin
                  if(rs485_ch_flag_d2) begin
                      s2m_uart_id <= i_s2m_rs485_msg;
                      s2m_state <= 1;
                  end
              end
              1: begin
                  {s2m_recv_byte[3],s2m_recv_byte[2],s2m_recv_byte[1],s2m_recv_byte[0]} <= i_s2m_rs485_msg;
                  s2m_state <= 2;
              end
              2: begin
                  {s2m_recv_byte[7],s2m_recv_byte[6],s2m_recv_byte[5],s2m_recv_byte[4]} <= i_s2m_rs485_msg;
                  s2m_state <= 3;
              end
              3: begin
                  {s2m_recv_byte[11],s2m_recv_byte[10],s2m_recv_byte[9],s2m_recv_byte[8]} <= i_s2m_rs485_msg;
                  s2m_state <= 4;
              end
              4: begin
                  {s2m_recv_byte[15],s2m_recv_byte[14],s2m_recv_byte[13],s2m_recv_byte[12]} <= i_s2m_rs485_msg;
                  s2m_state <= 5;
              end
              5: begin
                  {s2m_recv_byte[19],s2m_recv_byte[18],s2m_recv_byte[17],s2m_recv_byte[16]} <= i_s2m_rs485_msg;
                  s2m_state <= 6;
              end
              6: begin
                  {s2m_recv_byte[23],s2m_recv_byte[22],s2m_recv_byte[21],s2m_recv_byte[20]} <= i_s2m_rs485_msg;
                  s2m_state <= 7;
              end
              7: begin
                  s2m_state <= 8;
              end
              8: begin
                  s2m_state <= 9;
              end
              9: begin
                  s2m_state <= 10;
              end
              10: begin
                  s2m_state <= 11;
              end
              11: begin
                  s2m_state <= 12;
              end
              12: begin
                  s2m_state <= 0;
              end
              default: begin
                  s2m_state <= 0;
              end
           endcase
       end
   end
   
    always@(posedge i_prot_clk) begin
       if(i_prot_rst) begin
            m2s_send_finish <= 0;
            s2m_recv_finish <= 0;
       end else begin
            m2s_send_finish <= (m2s_state==10)|(m2s_state==11)|(m2s_state==12);//��ɱ�־��������ʱ�ӣ�Ҫ������ʱ����һ��ʱ�����ڣ�
            s2m_recv_finish <= (s2m_state==10)|(s2m_state==11)|(s2m_state==12);
       end
    end


endmodule




