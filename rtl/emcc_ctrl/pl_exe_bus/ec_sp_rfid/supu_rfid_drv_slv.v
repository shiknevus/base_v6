//2026/10/9
//cgliu
//supu_rfid_drv 的"从板485"版本:
//  命令接口(i_act_vld/i_act/i_slave_addr/i_wdata/o_uid/o_rdata/o_done/o_err...)、3个行为的定义、
//  每个行为发往485传感器的字节帧、错误码定义, 全部与 supu_rfid_drv 保持一致 —— 相同行为号发出的字节流完全相同.
//  区别: 本模块不驱动主板本地uart/485仲裁, 而是例化 mst_slv_485_driver, 把相同的帧
//  经emcc总线写入目标从板的485寄存器区(0x8A~0x99), 由从板 common_rs485_top 在从板侧485总线上实际收发.
//
// 使用说明(在emcc_mix_top中直接接pkg_route, 单实例占用一条从板485通道):
//   .i_clk          ( clk                          )  // 业务时钟(组件域)
//   (单一时钟156.25MHz, 原i_prot_clk/i_prot_rst端口已删除, 业务与emcc通道同域)
//   .i_cur_slv_board_id ( 5'd0                     )  // 本实例服务的从板号
//   .i_slv_board_id ( slv_board_id                 )  // = slv_sta_msg_addr[RAM_AWIDTH-1:9] (读侧当前板号)
//   .i_cfg_slv_board_id( cfg_slv_board_id          )  // = slv_cfg_msg_addr[RAM_AWIDTH-1:9] (写侧当前板号, 需在顶层引出)
//   .i_rs485_ch_r_flag ( rs485_00_r_flag           )
//   .o_m2s_rs485_msg  ( rs485_00_send_msg          )
//   .i_rs485_ch_flag ( rs485_00_flag               )
//   .i_s2m_rs485_msg ( rs485_00_msg                )
// 若多个模块共用同一条从板485通道, 改走 slave_rs485_arbiter 的 ch_rs485_*[板号][槽位]:
//   此时 r_flag 已被仲裁器按板号过滤, 把 i_cfg_slv_board_id 与 i_cur_slv_board_id 接同一个常量即可.

module supu_rfid_drv_slv
#(
	parameter	[19:0]			BAUD_RATE		= 20'd115_200	// 只支持 115200/9600/19200 (驱动内部换算成从板分档)
	,parameter	[7:0]			PARITY			= 8'd0			// 0=无校验 1=奇校验 2=偶校验
	,parameter	integer			RSP_TIMEOUT_MS	= 100			// 响应超时(ms): 含emcc两个轮询周期+从板收发时间+(短帧时)10ms截帧, 留足余量
)(
	input							i_clk
	,input							i_rst			// 高有效(业务域)
	//---------- 命令接口(与supu_rfid_drv一致) ----------
	,input							i_act_vld		// 命令启动, 拉高1拍(o_busy=1期间被忽略)
	,input	[1:0]					i_act			// 1=写标签 2=读UID 3=读标签
	,input	[7:0]					i_slave_addr	// MODBUS从站地址, 命令接受时采样锁存
	,input	[31:0]					i_wdata			// 行为1: 写入的32bit数据
	,output	reg	[63:0]				o_uid			// 行为2: UID(o_done后有效)
	,output	reg	[31:0]				o_rdata			// 行为3: 读回的32bit(o_done后有效)
	,output	reg						o_done			// 1拍: 命令成功完成
	,output							o_busy			// 1=驱动忙
	,output	reg						o_err			// 1拍: 命令失败, 看o_err_code
	,output	reg	[7:0]				o_err_code		// 错误号码(保持到下一次命令)
	,input							i_time_1ms_vld	// 1ms节拍, 响应超时计数用
	//---------- 从板485通道接口(取代主板本地uart+485总线仲裁) ----------
	,input	[4:0]					i_cur_slv_board_id	// 本实例服务的从板号
	,input	[4:0]					i_slv_board_id		// 当前emcc轮询读到的从板号(接slv_board_id, s2m方向由驱动内部比对)
	,input	[4:0]					i_cfg_slv_board_id	// 当前emcc配置写到的从板号(=slv_cfg_msg_addr高位), 用于m2s发送窗口板号过滤
	,input							i_rs485_ch_r_flag	// 主板→从板 寄存器写窗口(pkg_route: rs485_00_r_flag, 全板广播)
	,output	wire	[31:0]			o_m2s_rs485_msg		// 主板→从板 寄存器写数据流(pkg_route: rs485_00_send_msg)
	,input							i_rs485_ch_flag		// 从板寄存器读窗口(pkg_route: rs485_00_flag, 全板广播)
	,input	wire	[31:0]			i_s2m_rs485_msg		// 从板→主板 寄存器读数据流(pkg_route: rs485_00_msg)
);

//==================================================================================================
// 错误码定义(与supu_rfid_drv一致)
//==================================================================================================
localparam	[7:0]	ERR_NONE	= 8'd0;	// 无错误
localparam	[7:0]	ERR_TMO		= 8'd115;	// 响应超时(无应答)
localparam	[7:0]	ERR_GAP		= 8'd116;	// 应答帧不完整
localparam	[7:0]	ERR_SLAVE	= 8'd117;	// 应答帧从站地址不符
localparam	[7:0]	ERR_CRC		= 8'd118;	// CRC校验错误
localparam	[7:0]	ERR_EXC_DEV	= 8'd120;	// MODBUS异常应答: 设备故障(04H)或其他非0BH异常
localparam	[7:0]	ERR_EXC_TAG	= 8'd121;	// MODBUS异常应答: 标签不在读取区域(0BH)
// 注: 主板版还有 ERR_GRANT=119(485总线仲裁超时), 从板为专用寄存器通道无仲裁, 不存在此错误

//==================================================================================================
// 状态机
//==================================================================================================
localparam	[1:0]	ST_IDLE		= 2'd0;		// 等待命令, 组装请求帧
localparam	[1:0]	ST_RUN		= 2'd1;		// 已发起发送, 等从板485应答(或超时)

//==================================================================================================
// 寄存器
//==================================================================================================
reg	[1:0]	state;								// 主状态机
reg	[1:0]	act_r;								// 锁存的行为码
reg	[7:0]	slave_r;							// 锁存的从站地址(请求帧与应答比对用同一值)
reg	[8*13-1:0]	tx_frame;						// 发送帧(小端: tx_frame[8*k+:8]=第k个发出的字节)
reg	[7:0]	tx_len;								// 发送帧总长(字节)
reg	[7:0]	exp_len;							// 期望应答帧总长(字节)
reg		send_req_p;							// 驱动发送请求(1拍)
reg	[15:0]	tmo_ms;								// 响应超时ms计数

//==================================================================================================
// CRC-16/MODBUS: 初值0xFFFF, 多项式0xA001, 结果低字节在前发送(与supu_rfid_drv一致)
//==================================================================================================
function	[15:0]	crc16;
	input	[15:0]	c;
	input	[7:0]	d;
	integer	k;
	begin
		crc16 = c ^ {8'h00, d};
		for (k = 0; k < 8; k = k + 1) begin
			if (crc16[0])
				crc16 = {1'b0, crc16[15:1]} ^ 16'hA001;
			else
				crc16 = {1'b0, crc16[15:1]};
		end
	end
endfunction

// 对小端字节串的前n字节做CRC(用于发送帧预计算与应答帧校验)
function	[15:0]	crc16_n;
	input	[8*11-1:0]	le;	// 小端字节串: le[8*k+:8]=第k字节
	input	[3:0]		n;	// 参与CRC的字节数
	integer	k;
	reg	[15:0]	c;
	begin
		c = 16'hFFFF;
		for (k = 0; k < 11; k = k + 1) begin
			if (k < n)
				c = crc16(c, le[8*k +: 8]);
		end
		crc16_n = c;
	end
endfunction

//==================================================================================================
// 发送帧CRC(命令接受时用当前输入组合计算, 与supu_rfid_drv相同字节序)
//==================================================================================================
wire	[15:0]	w_crc	= (i_act == 2'd1)	// 行为1: 站号+10+地址2+数量2+字节数+数据4 = 11字节参与CRC
				? crc16_n({i_wdata[7:0],i_wdata[15:8],i_wdata[23:16],i_wdata[31:24],8'h04,8'h02,8'h00,8'h00,8'h00,8'h10,i_slave_addr}, 4'd11)
				// 行为2/3: 站号+03+地址2+数量2 = 6字节参与CRC (行为2: 地址E000/数量04; 行为3: 地址0000/数量02)
				// 修复: 数量低字节此前写死8'h04, 行为3实发0x02, CRC不符被传感器静默丢弃→超时115
				: crc16_n({(i_act == 2'd2) ? 8'h04 : 8'h02,8'h00,8'h00,(i_act == 2'd2) ? 8'hE0 : 8'h00,8'h03,i_slave_addr}, 4'd6);

//==================================================================================================
// 从板485通道驱动输出(业务域)与应答帧字节切分(小端)/校验用CRC
// (声明置于状态机之前: 本工程仿真用ModelSim, .v文件先声明后使用才可编译)
//==================================================================================================
wire	[8*13-1:0]	w_rx_data;							// 收到的应答帧(小端, byte[k]在[8*k+:8])
wire			w_rx_vld;							// 1拍: 收到新帧
wire	[7:0]		w_drv_err;							// 1=收满预期长度 6=短帧(10ms截帧)

wire	[7:0]	rx_b0	= w_rx_data[8* 0 +: 8];	// 站号
wire	[7:0]	rx_b1	= w_rx_data[8* 1 +: 8];	// 功能码
wire	[7:0]	rx_b2	= w_rx_data[8* 2 +: 8];	// 字节数 / 异常码
wire	[7:0]	rx_b3	= w_rx_data[8* 3 +: 8];
wire	[7:0]	rx_b4	= w_rx_data[8* 4 +: 8];
wire	[7:0]	rx_b5	= w_rx_data[8* 5 +: 8];
wire	[7:0]	rx_b6	= w_rx_data[8* 6 +: 8];
wire	[7:0]	rx_b7	= w_rx_data[8* 7 +: 8];
wire	[7:0]	rx_b8	= w_rx_data[8* 8 +: 8];
wire	[7:0]	rx_b9	= w_rx_data[8* 9 +: 8];
wire	[7:0]	rx_b10	= w_rx_data[8*10 +: 8];
wire	[7:0]	rx_crcl	= w_rx_data[8*(exp_len-8'd2) +: 8];	// 应答帧倒数第2字节=CRC低
wire	[7:0]	rx_crch	= w_rx_data[8*(exp_len-8'd1) +: 8];	// 应答帧最后1字节=CRC高

wire	[7:0]	w_exp_func	= (act_r == 2'd1) ? 8'h10 : 8'h03;	// 期望的应答功能码
wire	[15:0]	w_rsp_crc	= crc16_n(w_rx_data[8*11-1:0], exp_len[3:0] - 4'd2);	// 正常应答CRC(前exp_len-2字节)
wire	[15:0]	w_exc_crc	= crc16_n({64'd0, rx_b2, rx_b1, rx_b0}, 4'd3);		// 异常应答CRC(前3字节)

//==================================================================================================
// 主状态机
//==================================================================================================
always @(posedge i_clk) begin
	if (i_rst) begin
		state		<= ST_IDLE;
		send_req_p	<= 1'b0;
		act_r		<= 2'd0;
		slave_r		<= 8'h01;
		tx_frame	<= {13{8'h00}};
		tx_len		<= 8'd0;
		exp_len		<= 8'd0;
		tmo_ms		<= 16'd0;
		o_done		<= 1'b0;
		o_err		<= 1'b0;
		o_err_code	<= ERR_NONE;
		o_uid		<= 64'd0;
		o_rdata		<= 32'd0;
	end else begin
		o_done	<= 1'b0;
		o_err	<= 1'b0;

		case (state)
		//================= 等待命令, 组装请求帧(与supu_rfid_drv的帧完全一致) =================
		ST_IDLE: begin
			send_req_p	<= 1'b0;
			tmo_ms		<= 16'd0;
			if (i_act_vld) begin
				act_r		<= i_act;
				slave_r		<= i_slave_addr;
				o_err_code	<= ERR_NONE;
				case (i_act)
				//---- 行为1: 写标签 32bit @字地址0 (13字节: 11载荷+2CRC) ----
				2'd1: begin
					tx_frame[8* 0 +: 8] <= i_slave_addr;
					tx_frame[8* 1 +: 8] <= 8'h10;			// 功能码0x10 写多寄存器
					tx_frame[8* 2 +: 8] <= 8'h00;			// 起始字地址高
					tx_frame[8* 3 +: 8] <= 8'h00;			// 起始字地址低 (0)
					tx_frame[8* 4 +: 8] <= 8'h00;			// 寄存器数量高
					tx_frame[8* 5 +: 8] <= 8'h02;			// 寄存器数量低 (2寄存器=4字节)
					tx_frame[8* 6 +: 8] <= 8'h04;			// 字节数
					tx_frame[8* 7 +: 8] <= i_wdata[31:24];	// 数据字节0(标签字节0)
					tx_frame[8* 8 +: 8] <= i_wdata[23:16];
					tx_frame[8* 9 +: 8] <= i_wdata[15:8];
					tx_frame[8*10 +: 8] <= i_wdata[7:0];
					tx_frame[8*11 +: 8] <= w_crc[7:0];		// CRC低字节在前
					tx_frame[8*12 +: 8] <= w_crc[15:8];
					tx_len	<= 8'd13;
					exp_len	<= 8'd8;						// 写回显: 站号+10+地址2+数量2+CRC2
					send_req_p	<= 1'b1;
					state		<= ST_RUN;
				end
				//---- 行为2: 读UID (E000~E0003, 4寄存器=8字节) ----
				2'd2: begin
					tx_frame[8* 0 +: 8] <= i_slave_addr;
					tx_frame[8* 1 +: 8] <= 8'h03;			// 功能码0x03 读保持寄存器
					tx_frame[8* 2 +: 8] <= 8'hE0;			// 起始地址高
					tx_frame[8* 3 +: 8] <= 8'h00;			// 起始地址低 (E000)
					tx_frame[8* 4 +: 8] <= 8'h00;			// 寄存器数量高
					tx_frame[8* 5 +: 8] <= 8'h04;			// 寄存器数量低 (4)
					tx_frame[8* 6 +: 8] <= w_crc[7:0];
					tx_frame[8* 7 +: 8] <= w_crc[15:8];
					tx_len	<= 8'd8;
					exp_len	<= 8'd13;						// 站号+03+字节数+8数据+CRC2
					send_req_p	<= 1'b1;
					state		<= ST_RUN;
				end
				//---- 行为3: 读标签 32bit @字地址0 ----
				2'd3: begin
					tx_frame[8* 0 +: 8] <= i_slave_addr;
					tx_frame[8* 1 +: 8] <= 8'h03;
					tx_frame[8* 2 +: 8] <= 8'h00;
					tx_frame[8* 3 +: 8] <= 8'h00;
					tx_frame[8* 4 +: 8] <= 8'h00;
					tx_frame[8* 5 +: 8] <= 8'h02;			// 2寄存器=4字节
					tx_frame[8* 6 +: 8] <= w_crc[7:0];
					tx_frame[8* 7 +: 8] <= w_crc[15:8];
					tx_len	<= 8'd8;
					exp_len	<= 8'd9;						// 站号+03+字节数+4数据+CRC2
					send_req_p	<= 1'b1;
					state		<= ST_RUN;
				end
				//---- 非法行为码: 忽略该命令 ----
				default: ;
				endcase
			end
		end

		//================= 已发起发送, 等从板485应答 =================
		ST_RUN: begin
			send_req_p	<= 1'b0;
			if (i_time_1ms_vld && (tmo_ms < RSP_TIMEOUT_MS))
				tmo_ms	<= tmo_ms + 16'd1;

			if (w_rx_vld) begin					// 驱动收到新帧(完整帧或短帧)
				if (rx_b0 != slave_r) begin
					o_err		<= 1'b1;
					o_err_code	<= ERR_SLAVE;
				end else if (rx_b1 == (w_exp_func | 8'h80)) begin
					// MODBUS异常应答: 站号+(功能码|80)+异常码+CRC2, 固定5字节短帧,
					// 从板按10ms空闲超时截帧收到(驱动err=6), 但内容完整可解析
					if ((w_exc_crc[7:0] != rx_b3) || (w_exc_crc[15:8] != rx_b4)) begin
						o_err		<= 1'b1;
						o_err_code	<= ERR_GAP;
					end else begin
						o_err		<= 1'b1;
						o_err_code	<= (rx_b2 == 8'h0B) ? ERR_EXC_TAG : ERR_EXC_DEV;
					end
				end else if ((rx_b1 != w_exp_func) || (w_drv_err != 8'd1)) begin
					// 功能码不符, 或从板未收满预期长度(10ms截帧) → 应答不完整
					o_err		<= 1'b1;
					o_err_code	<= ERR_GAP;
				end else if ((w_rsp_crc[7:0] != rx_crcl) || (w_rsp_crc[15:8] != rx_crch)) begin
					o_err		<= 1'b1;
					o_err_code	<= ERR_CRC;
				end else begin
					o_done		<= 1'b1;
					o_err_code	<= ERR_NONE;
					case (act_r)
					2'd2:	o_uid	<= {rx_b3,rx_b4,rx_b5,rx_b6,rx_b7,rx_b8,rx_b9,rx_b10};
					2'd3:	o_rdata	<= {rx_b3,rx_b4,rx_b5,rx_b6};
					default: ;	// 行为1写回显帧无数据
					endcase
				end
				state	<= ST_IDLE;
			end else if (tmo_ms >= RSP_TIMEOUT_MS) begin
				// 整个链路(emcc轮询+从板收发)都没等到应答
				o_err		<= 1'b1;
				o_err_code	<= ERR_TMO;
				state		<= ST_IDLE;
			end
		end

		default: state <= ST_IDLE;
		endcase
	end
end

assign	o_busy	= (state != ST_IDLE);

//==================================================================================================
// 从板485通道驱动例化
//==================================================================================================
// m2s发送窗口板号过滤: r_flag是所有从板共享的广播信号(只要PS写到"某块板"的0x8A区就会拉高),
// 必须只在自己的目标从板窗口送数, 否则帧会写进别的从板(多板系统必须接; 单板系统把
// i_cfg_slv_board_id与i_cur_slv_board_id接同一个常量即可). 组合逻辑, 不改变拍节时序.
wire	w_r_flag_gate = i_rs485_ch_r_flag & (i_cfg_slv_board_id == i_cur_slv_board_id);

mst_slv_485_driver u_slv485_drv (
	.i_clk				(i_clk				),
	.i_rst				(i_rst				),
	.i_baud_rate		(BAUD_RATE			),
	.i_parity			(PARITY				),

	//--- 从板通道 ---
	.i_cur_slv_board_id	(i_cur_slv_board_id	),
	.i_slv_board_id		(i_slv_board_id		),
	.i_rs485_ch_r_flag	(w_r_flag_gate		),	// 板号过滤后的发送窗口
	.o_m2s_rs485_msg	(o_m2s_rs485_msg	),
	.i_rs485_ch_flag	(i_rs485_ch_flag	),
	.i_s2m_rs485_msg	(i_s2m_rs485_msg	),

	//--- 业务侧 ---
	.i_send_req_p		(send_req_p			),
	.o_send_finish_p	(					),	// 发送交棒完成, 本模块不等待
	.i_send_data		(tx_frame			),	// 13字节小端
	.i_exp_send_num		(tx_len				),
	.i_exp_recv_num		(exp_len			),
	.o_recv_data		(w_rx_data			),
	.o_recv_finish_p	(w_rx_vld			),
	.o_modbus_err_code	(w_drv_err			)
);

endmodule
