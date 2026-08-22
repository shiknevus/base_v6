///////////////////////////////////////////////////////////////////////////////
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_EXAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//        
module hardware_interface_top
(
     input                       clk
    ,input                       reset

	,input                       downstream_lane_up
    ,input                       downstream_link
	,input                       s_axi_rx_tvalid_0
	,input             	         s_axi_rx_tvalid_1

	,input wire                 driver_cfg_wea
    ,input wire [15:0]          driver_cfg_addra
    ,input wire [31:0]          driver_cfg_dina
    ,input wire                 rd_msg_addr_en
    ,input wire [15:0]          rd_msg_addr
    ,input wire [95:0]          slvbd_inio
    ,output wire [47:0]         slvbd_outio
    ,input  wire [7:0]          uart_232_rxd
    ,output wire [7:0]          uart_232_txd
    ,input  wire                uart_485_rxd
    ,output wire                uart_485_txd
    ,output wire                uart_485_dir
    ,input  wire [3:0]          i_dv_alarm      
    ,output wire [3:0]          o_dv_pulse
    ,output wire [3:0]          o_dv_dir
    ,output wire [3:0]          o_dv_reset
    ,output wire [3:0]          o_dv_son
    ,output reg [31:0]          di_regoin_msg
    ,output reg [31:0]          do_regoin_msg
    ,output reg [31:0]          rs232_ch0_msg
    ,output reg [31:0]          rs232_ch1_msg
    ,output reg [31:0]          rs232_ch2_msg
    ,output reg [31:0]          rs232_ch3_msg
    ,output reg [31:0]          rs232_ch4_msg
    ,output reg [31:0]          rs232_ch5_msg
    ,output reg [31:0]          rs232_ch6_msg
    ,output reg [31:0]          rs232_ch7_msg
    ,output reg [31:0]          rs485_ch8_msg
    ,output reg [31:0]          pul_motor0_msg
    ,output reg [31:0]          pul_motor1_msg
    ,output reg [31:0]          pul_motor2_msg
    ,output reg [31:0]          pul_motor3_msg
);
    localparam  bias_rs232_ch0  = 10;
    localparam  bias_rs232_ch1  = 26;
    localparam  bias_rs232_ch2  = 42;
    localparam  bias_rs232_ch3  = 58;
    localparam  bias_rs232_ch4  = 74;
    localparam  bias_rs232_ch5  = 90;
    localparam  bias_rs232_ch6  = 106;
    localparam  bias_rs232_ch7  = 122;
    localparam  bias_rs485_ch8  = 138;
    localparam  bias_pul_motor0 = 154;
    localparam  bias_pul_motor1 = 170;
    localparam  bias_pul_motor2 = 186;
    localparam  bias_pul_motor3 = 202;
    localparam  bias_depot_end  = 218;

    wire             action_alarm[3:0];
    wire             action_start[3:0];
    wire             action_son[3:0];
    wire             action_beat[3:0];
    wire             action_busy[3:0];
    wire             action_done[3:0];
    wire             action_error[3:0];
    wire             device_alarm[3:0];
    wire             device_beat[3:0];
    wire             rctrl_drive_on[3:0];
    wire             rctrl_drive_reset[3:0];
    wire             rserv_dir[3:0];
    wire             rcfg_pf_mode[3:0];
    wire [31:0]      r_pf_abspos[3:0];
    wire [7:0]       cur_beha[3:0];
    wire [31:0]      rserv_step_pulse[3:0];
    wire [31:0]      rserv_target_pulse[3:0];
    wire [15:0]      rcfg_home_spd[3:0];
    wire [15:0]      rcfg_home_acc[3:0];
    wire [15:0]      rcfg_home_dec[3:0];
    wire [15:0]      rcfg_jog_spd[3:0];
    wire [15:0]      rcfg_jog_acc[3:0];
    wire [15:0]      rcfg_jog_dec[3:0];
    wire [15:0]      rcfg_move_spd[3:0];
    wire [15:0]      rcfg_move_acc[3:0];
    wire [15:0]      rcfg_move_dec[3:0];
    wire [15:0]      rcfg_spd_max[3:0];
    wire [15:0]      rcfg_acc_max[3:0];
    wire [15:0]      rcfg_dec_max[3:0];
    wire [15:0]      rcfg_qs_dec[3:0];
    wire [31:0]      rcfg_timedly[3:0];
    wire             i_axis_limf[3:0];
    wire             i_axis_limb[3:0];
    wire             i_axis_org[3:0];
    wire             i_axis_point[3:0];
    wire             i_axis_abspos0[3:0]; 
    wire [31:0]      rs232_uart_id[7:0];            //uart_id
    wire [3:0]       rs232_baud_rate[7:0];          //波特率
    wire             rs232_start_send[7:0];         //开始发送
    wire [1:0]       rs232_odd_even[7:0];           //奇偶校验
    wire [7:0]       rs232_send_num[7:0];           //发送的字节数
    wire [7:0]       rs232_recv_num[7:0];           //接收的字节数
    wire [7:0]       rs232_tail_symbol[7:0];        //结束符
    wire [31:0]      rs232_send_char1[7:0];         //发送字符1*4
    wire [31:0]      rs232_send_char2[7:0];         //发送字符2*4
    wire [31:0]      rs232_send_char3[7:0];         //发送字符3*4
    wire [31:0]      rs232_send_char4[7:0];         //发送字符4*4
    wire [31:0]      rs485_uart_id;
    wire [3:0]       rs485_baud_rate;
    wire             rs485_start_send;
    wire [1:0]       rs485_odd_even;
    wire [7:0]       rs485_send_num;
    wire [7:0]       rs485_recv_num;
    wire [7:0]       rs485_tail_symbol;
    wire [31:0]      rs485_send_char1;
    wire [31:0]      rs485_send_char2;
    wire [31:0]      rs485_send_char3;
    wire [31:0]      rs485_send_char4;
    wire [31:0]      rs485_send_char5;
    wire [31:0]      rs485_send_char6;
    reg  [31:0]      pul_motor0_buf[15:0];
    reg  [31:0]      pul_motor1_buf[15:0];
    reg  [31:0]      pul_motor2_buf[15:0];
    reg  [31:0]      pul_motor3_buf[15:0];
    reg  [31:0]      rs232_ch0_buf[31:0];
    reg  [31:0]      rs232_ch1_buf[31:0];
    reg  [31:0]      rs232_ch2_buf[31:0];
    reg  [31:0]      rs232_ch3_buf[31:0];
    reg  [31:0]      rs232_ch4_buf[31:0];
    reg  [31:0]      rs232_ch5_buf[31:0];
    reg  [31:0]      rs232_ch6_buf[31:0];
    reg  [31:0]      rs232_ch7_buf[31:0];
    reg  [31:0]      rs485_ch8_buf[31:0];

	reg              axi_flag;
	reg	 [23:0]		  wk_cnt;
	reg [15:0]       rd_msg_addr_d;
	reg [31:0]       slvbd_outio_low;
	reg [15:0]       slvbd_outio_high;
	wire [4:0]       uart_rx_sel[7:0];
	wire [31:0]      uart_rx_32data[7:0];
	wire [4:0]       uart_485_rx_sel;
	wire [31:0]      uart_485_rx_32data;

    assign uart_rx_sel[0] = ((rd_msg_addr_d >= bias_rs232_ch0) & (rd_msg_addr_d < bias_rs232_ch1)) ? (rd_msg_addr_d - bias_rs232_ch0) : 0;
    assign uart_rx_sel[1] = ((rd_msg_addr_d >= bias_rs232_ch1) & (rd_msg_addr_d < bias_rs232_ch2)) ? (rd_msg_addr_d - bias_rs232_ch1) : 0;
    assign uart_rx_sel[2] = ((rd_msg_addr_d >= bias_rs232_ch2) & (rd_msg_addr_d < bias_rs232_ch3)) ? (rd_msg_addr_d - bias_rs232_ch2) : 0;
    assign uart_rx_sel[3] = ((rd_msg_addr_d >= bias_rs232_ch3) & (rd_msg_addr_d < bias_rs232_ch4)) ? (rd_msg_addr_d - bias_rs232_ch3) : 0;
    assign uart_rx_sel[4] = ((rd_msg_addr_d >= bias_rs232_ch4) & (rd_msg_addr_d < bias_rs232_ch5)) ? (rd_msg_addr_d - bias_rs232_ch4) : 0;
    assign uart_rx_sel[5] = ((rd_msg_addr_d >= bias_rs232_ch5) & (rd_msg_addr_d < bias_rs232_ch6)) ? (rd_msg_addr_d - bias_rs232_ch5) : 0;
    assign uart_rx_sel[6] = ((rd_msg_addr_d >= bias_rs232_ch6) & (rd_msg_addr_d < bias_rs232_ch7)) ? (rd_msg_addr_d - bias_rs232_ch6) : 0;
    assign uart_rx_sel[7] = ((rd_msg_addr_d >= bias_rs232_ch7) & (rd_msg_addr_d < bias_rs485_ch8)) ? (rd_msg_addr_d - bias_rs232_ch7) : 0;
    assign uart_485_rx_sel = ((rd_msg_addr_d >= bias_rs485_ch8) & (rd_msg_addr_d < bias_pul_motor0)) ? (rd_msg_addr_d - bias_rs485_ch8) : 0;
	assign slvbd_outio = {slvbd_outio_high,slvbd_outio_low};
	assign action_alarm[0] = pul_motor0_buf[0][0];
    assign action_alarm[1] = pul_motor1_buf[0][0];
    assign action_alarm[2] = pul_motor2_buf[0][0];
    assign action_alarm[3] = pul_motor3_buf[0][0];
    assign action_start[0] = pul_motor0_buf[0][1];
    assign action_start[1] = pul_motor1_buf[0][1];
    assign action_start[2] = pul_motor2_buf[0][1];
    assign action_start[3] = pul_motor3_buf[0][1];
    assign action_son[0] = pul_motor0_buf[0][2];
    assign action_son[1] = pul_motor1_buf[0][2];
    assign action_son[2] = pul_motor2_buf[0][2];
    assign action_son[3] = pul_motor3_buf[0][2];
    assign i_axis_limf[0] = pul_motor0_buf[0][3];
    assign i_axis_limf[1] = pul_motor1_buf[0][3];
    assign i_axis_limf[2] = pul_motor2_buf[0][3];
    assign i_axis_limf[3] = pul_motor3_buf[0][3];
    assign i_axis_limb[0] = pul_motor0_buf[0][4];
    assign i_axis_limb[1] = pul_motor1_buf[0][4];
    assign i_axis_limb[2] = pul_motor2_buf[0][4];
    assign i_axis_limb[3] = pul_motor3_buf[0][4];
    assign i_axis_org[0] = pul_motor0_buf[0][5];
    assign i_axis_org[1] = pul_motor1_buf[0][5];
    assign i_axis_org[2] = pul_motor2_buf[0][5];
    assign i_axis_org[3] = pul_motor3_buf[0][5];
    assign action_beat[0] = pul_motor0_buf[0][6];
    assign action_beat[1] = pul_motor1_buf[0][6];
    assign action_beat[2] = pul_motor2_buf[0][6];
    assign action_beat[3] = pul_motor3_buf[0][6];
    assign i_axis_point[0] = pul_motor0_buf[0][7];
    assign i_axis_point[1] = pul_motor1_buf[0][7];
    assign i_axis_point[2] = pul_motor2_buf[0][7];
    assign i_axis_point[3] = pul_motor3_buf[0][7];
    assign i_axis_abspos0[0] = pul_motor0_buf[0][15];
    assign i_axis_abspos0[1] = pul_motor1_buf[0][15];
    assign i_axis_abspos0[2] = pul_motor2_buf[0][15];
    assign i_axis_abspos0[3] = pul_motor3_buf[0][15];
    assign cur_beha[0] = pul_motor0_buf[0][23:16];
    assign cur_beha[1] = pul_motor1_buf[0][23:16];
    assign cur_beha[2] = pul_motor2_buf[0][23:16];
    assign cur_beha[3] = pul_motor3_buf[0][23:16];
    assign rserv_step_pulse[0] = pul_motor0_buf[1];
    assign rserv_step_pulse[1] = pul_motor1_buf[1];
    assign rserv_step_pulse[2] = pul_motor2_buf[1];
    assign rserv_step_pulse[3] = pul_motor3_buf[1];
    assign rserv_target_pulse[0] = pul_motor0_buf[2];
    assign rserv_target_pulse[1] = pul_motor1_buf[2];
    assign rserv_target_pulse[2] = pul_motor2_buf[2];
    assign rserv_target_pulse[3] = pul_motor3_buf[2];
    assign {rcfg_home_spd[0],rcfg_move_spd[0]} = pul_motor0_buf[3];
    assign {rcfg_home_spd[1],rcfg_move_spd[1]} = pul_motor1_buf[3];
    assign {rcfg_home_spd[2],rcfg_move_spd[2]} = pul_motor2_buf[3];
    assign {rcfg_home_spd[3],rcfg_move_spd[3]} = pul_motor3_buf[3];
    assign {rctrl_drive_reset[0],rctrl_drive_on[0],rcfg_pf_mode[0],rserv_dir[0],rcfg_jog_spd[0]} = pul_motor0_buf[4][19:0];
    assign {rctrl_drive_reset[1],rctrl_drive_on[1],rcfg_pf_mode[1],rserv_dir[1],rcfg_jog_spd[1]} = pul_motor1_buf[4][19:0];
    assign {rctrl_drive_reset[2],rctrl_drive_on[2],rcfg_pf_mode[2],rserv_dir[2],rcfg_jog_spd[2]} = pul_motor2_buf[4][19:0];
    assign {rctrl_drive_reset[3],rctrl_drive_on[3],rcfg_pf_mode[3],rserv_dir[3],rcfg_jog_spd[3]} = pul_motor3_buf[4][19:0];
    assign {rcfg_home_acc[0],rcfg_home_dec[0]} = pul_motor0_buf[5];
    assign {rcfg_home_acc[1],rcfg_home_dec[1]} = pul_motor1_buf[5];
    assign {rcfg_home_acc[2],rcfg_home_dec[2]} = pul_motor2_buf[5];
    assign {rcfg_home_acc[3],rcfg_home_dec[3]} = pul_motor3_buf[5];
    assign {rcfg_jog_acc[0],rcfg_jog_dec[0]} = pul_motor0_buf[6];
    assign {rcfg_jog_acc[1],rcfg_jog_dec[1]} = pul_motor1_buf[6];
    assign {rcfg_jog_acc[2],rcfg_jog_dec[2]} = pul_motor2_buf[6];
    assign {rcfg_jog_acc[3],rcfg_jog_dec[3]} = pul_motor3_buf[6];
    assign {rcfg_move_acc[0],rcfg_move_dec[0]} = pul_motor0_buf[7];
    assign {rcfg_move_acc[1],rcfg_move_dec[1]} = pul_motor1_buf[7];
    assign {rcfg_move_acc[2],rcfg_move_dec[2]} = pul_motor2_buf[7];
    assign {rcfg_move_acc[3],rcfg_move_dec[3]} = pul_motor3_buf[7];
    assign {rcfg_acc_max[0],rcfg_dec_max[0]} = pul_motor0_buf[8];
    assign {rcfg_acc_max[1],rcfg_dec_max[1]} = pul_motor1_buf[8];
    assign {rcfg_acc_max[2],rcfg_dec_max[2]} = pul_motor2_buf[8];
    assign {rcfg_acc_max[3],rcfg_dec_max[3]} = pul_motor3_buf[8];
    assign {rcfg_spd_max[0],rcfg_qs_dec[0]} = pul_motor0_buf[9];
    assign {rcfg_spd_max[1],rcfg_qs_dec[1]} = pul_motor1_buf[9];
    assign {rcfg_spd_max[2],rcfg_qs_dec[2]} = pul_motor2_buf[9];
    assign {rcfg_spd_max[3],rcfg_qs_dec[3]} = pul_motor3_buf[9];
    assign rcfg_timedly[0] = pul_motor0_buf[10];
    assign rcfg_timedly[1] = pul_motor1_buf[10];
    assign rcfg_timedly[2] = pul_motor2_buf[10];
    assign rcfg_timedly[3] = pul_motor3_buf[10];
    assign rs232_uart_id[0] = rs232_ch0_buf[0];
    assign rs232_uart_id[1] = rs232_ch1_buf[0];
    assign rs232_uart_id[2] = rs232_ch2_buf[0];
    assign rs232_uart_id[3] = rs232_ch3_buf[0];
    assign rs232_uart_id[4] = rs232_ch4_buf[0];
    assign rs232_uart_id[5] = rs232_ch5_buf[0];
    assign rs232_uart_id[6] = rs232_ch6_buf[0];
    assign rs232_uart_id[7] = rs232_ch7_buf[0];
    assign rs485_uart_id = rs485_ch8_buf[0];
    assign rs232_baud_rate[0] = rs232_ch0_buf[1][3:0];
    assign rs232_baud_rate[1] = rs232_ch1_buf[1][3:0];
    assign rs232_baud_rate[2] = rs232_ch2_buf[1][3:0];
    assign rs232_baud_rate[3] = rs232_ch3_buf[1][3:0];
    assign rs232_baud_rate[4] = rs232_ch4_buf[1][3:0];
    assign rs232_baud_rate[5] = rs232_ch5_buf[1][3:0];
    assign rs232_baud_rate[6] = rs232_ch6_buf[1][3:0];
    assign rs232_baud_rate[7] = rs232_ch7_buf[1][3:0];
    assign rs485_baud_rate = rs485_ch8_buf[1][3:0];
    assign rs232_start_send[0] = rs232_ch0_buf[1][4:4];
    assign rs232_start_send[1] = rs232_ch1_buf[1][4:4];
    assign rs232_start_send[2] = rs232_ch2_buf[1][4:4];
    assign rs232_start_send[3] = rs232_ch3_buf[1][4:4];
    assign rs232_start_send[4] = rs232_ch4_buf[1][4:4];
    assign rs232_start_send[5] = rs232_ch5_buf[1][4:4];
    assign rs232_start_send[6] = rs232_ch6_buf[1][4:4];
    assign rs232_start_send[7] = rs232_ch7_buf[1][4:4];
    assign rs485_start_send = rs485_ch8_buf[1][4:4];
    assign rs232_odd_even[0] = rs232_ch0_buf[1][7:6];
    assign rs232_odd_even[1] = rs232_ch1_buf[1][7:6];
    assign rs232_odd_even[2] = rs232_ch2_buf[1][7:6];
    assign rs232_odd_even[3] = rs232_ch3_buf[1][7:6];
    assign rs232_odd_even[4] = rs232_ch4_buf[1][7:6];
    assign rs232_odd_even[5] = rs232_ch5_buf[1][7:6];
    assign rs232_odd_even[6] = rs232_ch6_buf[1][7:6];
    assign rs232_odd_even[7] = rs232_ch7_buf[1][7:6];
    assign rs485_odd_even = rs485_ch8_buf[1][7:6];
    assign rs232_send_num[0] = rs232_ch0_buf[1][15:8];
    assign rs232_send_num[1] = rs232_ch1_buf[1][15:8];
    assign rs232_send_num[2] = rs232_ch2_buf[1][15:8];
    assign rs232_send_num[3] = rs232_ch3_buf[1][15:8];
    assign rs232_send_num[4] = rs232_ch4_buf[1][15:8];
    assign rs232_send_num[5] = rs232_ch5_buf[1][15:8];
    assign rs232_send_num[6] = rs232_ch6_buf[1][15:8];
    assign rs232_send_num[7] = rs232_ch7_buf[1][15:8];
    assign rs485_send_num = rs485_ch8_buf[1][15:8];
    assign rs232_recv_num[0] = rs232_ch0_buf[1][23:16];
    assign rs232_recv_num[1] = rs232_ch1_buf[1][23:16];
    assign rs232_recv_num[2] = rs232_ch2_buf[1][23:16];
    assign rs232_recv_num[3] = rs232_ch3_buf[1][23:16];
    assign rs232_recv_num[4] = rs232_ch4_buf[1][23:16];
    assign rs232_recv_num[5] = rs232_ch5_buf[1][23:16];
    assign rs232_recv_num[6] = rs232_ch6_buf[1][23:16];
    assign rs232_recv_num[7] = rs232_ch7_buf[1][23:16];
    assign rs485_recv_num = rs485_ch8_buf[1][23:16];
    assign rs232_tail_symbol[0] = rs232_ch0_buf[1][31:24];
    assign rs232_tail_symbol[1] = rs232_ch1_buf[1][31:24];
    assign rs232_tail_symbol[2] = rs232_ch2_buf[1][31:24];
    assign rs232_tail_symbol[3] = rs232_ch3_buf[1][31:24];
    assign rs232_tail_symbol[4] = rs232_ch4_buf[1][31:24];
    assign rs232_tail_symbol[5] = rs232_ch5_buf[1][31:24];
    assign rs232_tail_symbol[6] = rs232_ch6_buf[1][31:24];
    assign rs232_tail_symbol[7] = rs232_ch7_buf[1][31:24];
    assign rs485_tail_symbol = rs485_ch8_buf[1][31:24];
    assign rs232_send_char1[0] = rs232_ch0_buf[2];
    assign rs232_send_char1[1] = rs232_ch1_buf[2];
    assign rs232_send_char1[2] = rs232_ch2_buf[2];
    assign rs232_send_char1[3] = rs232_ch3_buf[2];
    assign rs232_send_char1[4] = rs232_ch4_buf[2];
    assign rs232_send_char1[5] = rs232_ch5_buf[2];
    assign rs232_send_char1[6] = rs232_ch6_buf[2];
    assign rs232_send_char1[7] = rs232_ch7_buf[2];
    assign rs485_send_char1 = rs485_ch8_buf[2];
    assign rs232_send_char2[0] = rs232_ch0_buf[3];
    assign rs232_send_char2[1] = rs232_ch1_buf[3];
    assign rs232_send_char2[2] = rs232_ch2_buf[3];
    assign rs232_send_char2[3] = rs232_ch3_buf[3];
    assign rs232_send_char2[4] = rs232_ch4_buf[3];
    assign rs232_send_char2[5] = rs232_ch5_buf[3];
    assign rs232_send_char2[6] = rs232_ch6_buf[3];
    assign rs232_send_char2[7] = rs232_ch7_buf[3];
    assign rs485_send_char2 = rs485_ch8_buf[3];
    assign rs232_send_char3[0] = rs232_ch0_buf[4];
    assign rs232_send_char3[1] = rs232_ch1_buf[4];
    assign rs232_send_char3[2] = rs232_ch2_buf[4];
    assign rs232_send_char3[3] = rs232_ch3_buf[4];
    assign rs232_send_char3[4] = rs232_ch4_buf[4];
    assign rs232_send_char3[5] = rs232_ch5_buf[4];
    assign rs232_send_char3[6] = rs232_ch6_buf[4];
    assign rs232_send_char3[7] = rs232_ch7_buf[4];
    assign rs485_send_char3 = rs485_ch8_buf[4];
    assign rs232_send_char4[0] = rs232_ch0_buf[5];
    assign rs232_send_char4[1] = rs232_ch1_buf[5];
    assign rs232_send_char4[2] = rs232_ch2_buf[5];
    assign rs232_send_char4[3] = rs232_ch3_buf[5];
    assign rs232_send_char4[4] = rs232_ch4_buf[5];
    assign rs232_send_char4[5] = rs232_ch5_buf[5];
    assign rs232_send_char4[6] = rs232_ch6_buf[5];
    assign rs232_send_char4[7] = rs232_ch7_buf[5];
    assign rs485_send_char4 = rs485_ch8_buf[5];
    assign rs485_send_char5 = rs485_ch8_buf[6];
    assign rs485_send_char6 = rs485_ch8_buf[7];

	always @(posedge clk)begin
        if(reset)begin
            wk_cnt <= 0;
		end else if (s_axi_rx_tvalid_0|s_axi_rx_tvalid_1) begin
            wk_cnt <= 0;
		end else begin
			wk_cnt <= wk_cnt + 1'b1; 
        end
    end
	always @(posedge clk)begin
        if(reset)begin
            axi_flag <= 1'b0;
		end else if (s_axi_rx_tvalid_0|s_axi_rx_tvalid_1) begin
            axi_flag <= 1'b0;	
        end else if (wk_cnt == 24'hffffff) begin
            axi_flag <= 1'b1;
        end else begin
            axi_flag <= axi_flag;
        end
    end
    
    always @(posedge clk)begin
        rd_msg_addr_d <= rd_msg_addr;
        if(reset)begin
            di_regoin_msg <= 0;
            do_regoin_msg <= 32'hffff_ffff;
        end else if(rd_msg_addr_en & (rd_msg_addr_d < bias_rs232_ch0)) begin
            case(rd_msg_addr_d)
                1: begin
                    do_regoin_msg <= slvbd_outio_low;
                end
                2: begin
                    do_regoin_msg <= slvbd_outio_high;
                end
                3: begin
                    di_regoin_msg <= slvbd_inio[31:0];
                end
                4: begin
                    di_regoin_msg <= slvbd_inio[63:32];
                end
                5: begin
                    di_regoin_msg <= slvbd_inio[95:64];
                end
                default: begin
                end
            endcase
        end else if(rd_msg_addr_en & (rd_msg_addr_d >= bias_rs232_ch0)) begin
            casex(rd_msg_addr_d - bias_rs232_ch0)
                16'h000x: begin
                    rs232_ch0_msg <= uart_rx_32data[0];
                end
                16'h001x: begin
                    rs232_ch1_msg <= uart_rx_32data[1];
                end
                16'h002x: begin
                    rs232_ch2_msg <= uart_rx_32data[2];
                end
                16'h003x: begin
                    rs232_ch3_msg <= uart_rx_32data[3];
                end
                16'h004x: begin
                    rs232_ch4_msg <= uart_rx_32data[4];
                end
                16'h005x: begin
                    rs232_ch5_msg <= uart_rx_32data[5];
                end
                16'h006x: begin
                    rs232_ch6_msg <= uart_rx_32data[6];
                end
                16'h007x: begin
                    rs232_ch7_msg <= uart_rx_32data[7];
                end
                16'h008x: begin
                    rs485_ch8_msg <= uart_485_rx_32data;
                end
                16'h009x: begin
                    if(rd_msg_addr_d == (bias_pul_motor0+10)) begin
                        pul_motor0_msg <= {26'd0,device_beat[0],o_dv_dir[0],device_alarm[0],action_error[0],action_done[0],action_busy[0]};
                    end else if(rd_msg_addr_d == (bias_pul_motor0+11)) begin
                        pul_motor0_msg <= r_pf_abspos[0];
                    end else begin
                        pul_motor0_msg <= pul_motor0_buf[rd_msg_addr_d - bias_pul_motor0];
                    end
                end
                16'h00ax: begin
                    if(rd_msg_addr_d == (bias_pul_motor1+10)) begin
                        pul_motor1_msg <= {26'd0,device_beat[1],o_dv_dir[1],device_alarm[1],action_error[1],action_done[1],action_busy[1]};
                    end else if(rd_msg_addr_d == (bias_pul_motor1+11)) begin
                        pul_motor1_msg <= r_pf_abspos[1];
                    end else begin
                        pul_motor1_msg <= pul_motor1_buf[rd_msg_addr_d - bias_pul_motor1];
                    end
                end
                16'h00bx: begin
                    if(rd_msg_addr_d == (bias_pul_motor2+10)) begin
                        pul_motor2_msg <= {26'd0,device_beat[2],o_dv_dir[2],device_alarm[2],action_error[2],action_done[2],action_busy[2]};
                    end else if(rd_msg_addr_d == (bias_pul_motor2+11)) begin
                        pul_motor2_msg <= r_pf_abspos[2];
                    end else begin
                        pul_motor2_msg <= pul_motor2_buf[rd_msg_addr_d - bias_pul_motor2];
                    end
                end
                16'h00cx: begin
                    if(rd_msg_addr_d == (bias_pul_motor3+10)) begin
                        pul_motor3_msg <= {26'd0,device_beat[3],o_dv_dir[3],device_alarm[3],action_error[3],action_done[3],action_busy[3]};
                    end else if(rd_msg_addr_d == (bias_pul_motor3+11)) begin
                        pul_motor3_msg <= r_pf_abspos[3];
                    end else begin
                        pul_motor3_msg <= pul_motor3_buf[rd_msg_addr_d - bias_pul_motor3];
                    end 
                end
                default: begin
                end
            endcase
        end    
    end
    
    always @(posedge clk)begin
        if(reset | axi_flag)begin
            slvbd_outio_low <= 32'hffff_ffff;
            slvbd_outio_high <= 16'hffff;
        end else if(driver_cfg_wea & (driver_cfg_addra < bias_rs232_ch0)) begin 
            case(driver_cfg_addra)
                1: begin
                    slvbd_outio_low <= driver_cfg_dina;
                end
                2: begin
                    slvbd_outio_high <= driver_cfg_dina;
                end
                default: begin
                end
            endcase
        end else if(driver_cfg_wea & (driver_cfg_addra >= bias_rs232_ch0)) begin
            casex(driver_cfg_addra - bias_rs232_ch0)
                16'h000x: begin
                    rs232_ch0_buf[driver_cfg_addra - bias_rs232_ch0] <= driver_cfg_dina;
                end
                16'h001x: begin
                    rs232_ch1_buf[driver_cfg_addra - bias_rs232_ch1] <= driver_cfg_dina;
                end
                16'h002x: begin
                    rs232_ch2_buf[driver_cfg_addra - bias_rs232_ch2] <= driver_cfg_dina;
                end
                16'h003x: begin
                    rs232_ch3_buf[driver_cfg_addra - bias_rs232_ch3] <= driver_cfg_dina;
                end
                16'h004x: begin
                    rs232_ch4_buf[driver_cfg_addra - bias_rs232_ch4] <= driver_cfg_dina;
                end
                16'h005x: begin
                    rs232_ch5_buf[driver_cfg_addra - bias_rs232_ch5] <= driver_cfg_dina;
                end
                16'h006x: begin
                    rs232_ch6_buf[driver_cfg_addra - bias_rs232_ch6] <= driver_cfg_dina;
                end
                16'h007x: begin
                    rs232_ch7_buf[driver_cfg_addra - bias_rs232_ch7] <= driver_cfg_dina;
                end
                16'h008x: begin
                    rs485_ch8_buf[driver_cfg_addra - bias_rs485_ch8] <= driver_cfg_dina;
                end
                16'h009x: begin
                    pul_motor0_buf[driver_cfg_addra - bias_pul_motor0] <= driver_cfg_dina;
                end
                16'h00ax: begin
                    pul_motor1_buf[driver_cfg_addra - bias_pul_motor1] <= driver_cfg_dina;
                end
                16'h00bx: begin
                    pul_motor2_buf[driver_cfg_addra - bias_pul_motor2] <= driver_cfg_dina;
                end
                16'h00cx: begin
                    pul_motor3_buf[driver_cfg_addra - bias_pul_motor3] <= driver_cfg_dina;
                end
                default: begin
                end
            endcase    
        end    
    end

    generate	
	   genvar i;
	   for (i=0; i<4; i=i+1)begin: AXIS
	   slv_pul_axis    slv_pul_axis_u
	   (
		    .clk		   	         ( clk			        )
		   ,.reset		 	         ( reset	            )
		   
		   ,.action_flag   	         ( axi_flag             )
		   ,.action_alarm   	     ( action_alarm[i]      )
		   ,.action_start   	     ( action_start[i]      )
		   ,.action_son   	         ( action_son[i]        )
		   ,.action_beat   	         ( action_beat[i]       )
		   ,.device_alarm   	     ( device_alarm[i]      )
		   ,.device_beat   	         ( device_beat[i]       )
		   ,.action_error   	     ( action_error[i]      )
		   ,.action_busy   	         ( action_busy[i]       )
		   ,.action_done   	         ( action_done[i]       )

           ,.r_pf_abspos   	         ( r_pf_abspos[i]       )
           ,.cur_beha   	         ( cur_beha[i]          )
		   ,.rctrl_drive_on   	     ( rctrl_drive_on[i]    )
		   ,.rctrl_drive_reset   	 ( rctrl_drive_reset[i] )
		   ,.rserv_dir   	         ( rserv_dir[i]         )
		   ,.rcfg_pf_mode	         ( rcfg_pf_mode[i]	    )
		   ,.rserv_step_pulse   	 ( rserv_step_pulse[i]  )
		   ,.rserv_target_pulse   	 ( rserv_target_pulse[i])
		   ,.rcfg_home_spd   	     ( rcfg_home_spd[i]     )
		   ,.rcfg_home_acc   	     ( rcfg_home_acc[i]     )
		   ,.rcfg_home_dec   	     ( rcfg_home_dec[i]     )
		   ,.rcfg_jog_spd   	     ( rcfg_jog_spd[i]      )
		   ,.rcfg_jog_acc	         ( rcfg_jog_acc[i]	    )
		   ,.rcfg_jog_dec   	     ( rcfg_jog_dec[i]      )
		   ,.rcfg_move_spd   	     ( rcfg_move_spd[i]     )
		   ,.rcfg_move_acc   	     ( rcfg_move_acc[i]     )
		   ,.rcfg_move_dec   	     ( rcfg_move_dec[i]     )
		   ,.rcfg_spd_max	         ( rcfg_spd_max[i]	    )
		   ,.rcfg_acc_max   	     ( rcfg_acc_max[i]      )
		   ,.rcfg_dec_max   	     ( rcfg_dec_max[i]      )
		   ,.rcfg_qs_dec   	         ( rcfg_qs_dec[i]       )
		   ,.rcfg_timedly   	     ( rcfg_timedly[i]      )

		   ,.i_axis_limf             ( i_axis_limf[i]       )
		   ,.i_axis_limb             ( i_axis_limb[i]       )
           ,.i_axis_org              ( i_axis_org[i]        )
           ,.i_axis_point            ( i_axis_point[i]      )
           ,.i_axis_abspos0          ( i_axis_abspos0[i]    )
           ,.i_device_alarm          ( i_dv_alarm[i]        )
           ,.o_device_pulse          ( o_dv_pulse[i]        )
           ,.o_device_dir            ( o_dv_dir[i]          )
           ,.o_device_reset          ( o_dv_reset[i]        )
           ,.o_device_son            ( o_dv_son[i]          )
	   );
	   end
   endgenerate
   
   generate	
	   genvar j;
	   for (j=0; j<8; j=j+1)begin: UART
	   common_rs232_top    common_rs232_top_u
       (
            .i_clk                  (clk                    )
           ,.i_rst                  (reset                  )

           ,.i_clear                (1'b0                   )
           ,.i_rx_sel               (uart_rx_sel[j]         )
           ,.o_rx_32data            (uart_rx_32data[j]      )
           ,.uart_rxd               (uart_232_rxd[j]        )
           ,.uart_txd               (uart_232_txd[j]        ) 

           ,.rs232_baud_rate        (rs232_baud_rate[j]     )
           ,.rs232_odd_even         (rs232_odd_even[j]      )
           ,.rs232_start_send       (rs232_start_send[j]    )
           ,.rs232_send_num         (rs232_send_num[j]      )
           ,.rs232_recv_num         (rs232_recv_num[j]      )
           ,.rs232_tail_symbol      (rs232_tail_symbol[j]   )
           ,.rs232_send_char1       (rs232_send_char1[j]    )
           ,.rs232_send_char2       (rs232_send_char2[j]    )
           ,.rs232_send_char3       (rs232_send_char3[j]    )
           ,.rs232_send_char4       (rs232_send_char4[j]    )
       );
	   end
   endgenerate
   
   common_rs485_top    common_rs485_top_u
   (
         .i_clk                  (clk                   )
        ,.i_rst                  (reset                 )

        ,.i_clear                (1'b0                  )
        ,.i_rx_sel               (uart_485_rx_sel       )
        ,.o_rx_32data            (uart_485_rx_32data    )
        ,.uart_rxd               (uart_485_rxd          )
        ,.uart_txd               (uart_485_txd          )
        ,.uart_dir               (uart_485_dir          )

        ,.rs232_baud_rate        (rs485_baud_rate       )
        ,.rs232_odd_even         (rs485_odd_even        )
        ,.rs232_start_send       (rs485_start_send      )
        ,.rs232_send_num         (rs485_send_num        )
        ,.rs232_recv_num         (rs485_recv_num        )
        ,.rs232_tail_symbol      (rs485_tail_symbol     )
        ,.rs232_send_char1       (rs485_send_char1      )
        ,.rs232_send_char2       (rs485_send_char2      )
        ,.rs232_send_char3       (rs485_send_char3      )
        ,.rs232_send_char4       (rs485_send_char4      )
        ,.rs232_send_char5       (rs485_send_char5      )
        ,.rs232_send_char6       (rs485_send_char6      )
    );

endmodule