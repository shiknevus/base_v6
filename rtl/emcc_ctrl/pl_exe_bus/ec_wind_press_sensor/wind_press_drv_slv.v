//2026/10/13
//cgliu
// wind_press_drv 的"从板485"版本:
//   命令接口(i_act_vld/i_act/i_slave_addr/o_unit/o_decs/o_press/o_done/o_err...)、单一行为(1=读压力)
//   与发往485传感器的字节帧、错误码定义, 全部与 wind_press_drv 保持一致 —— 相同行为号发出的字节流完全相同.
//   区别: 本模块不驱动主板本地uart/485仲裁, 而是例化 mst_slv_485_driver, 把相同的帧
//   经emcc总线写入目标从板的485寄存器区(0x8A~0x99), 由从板 common_rs485_top 在从板侧485总线上实际收发.
//
// 微雀风压变送器要点(手册见 "ec_wind pressure sensor/微雀风压变送器485协议.pdf"):
//   MODBUS-RTU 默认9600,8,N,1; 功能码03一次读0x0002~0x0004共3寄存器:
//   单位(1=KPa 2=Pa)/小数位(0~4)/带符号压力(实际值=o_press/10^o_decs).
//
// 使用说明(在emcc_mix_top中直接接pkg_route, 单实例占用一条从板485通道):
//   .i_clk          ( clk                          )  // 业务时钟(组件域)
//   (单一时钟156.25MHz, 业务与emcc通道同域)
//   .i_cur_slv_board_id ( 5'd0                     )  // 本实例服务的从板号
//   .i_slv_board_id ( slv_board_id                 )  // = slv_sta_msg_addr[RAM_AWIDTH-1:9] (读侧当前板号)
//   .i_cfg_slv_board_id( cfg_slv_board_id          )  // = slv_cfg_msg_addr[RAM_AWIDTH-1:9] (写侧当前板号, 需在顶层引出)
//   .i_rs485_ch_r_flag ( rs485_00_r_flag           )
//   .o_m2s_rs485_msg  ( rs485_00_send_msg          )
//   .i_rs485_ch_flag ( rs485_00_flag               )
//   .i_s2m_rs485_msg ( rs485_00_msg                )
// 若多个模块共用同一条从板485通道, 改走 slave_rs485_arbiter 的 ch_rs485_*[板号][槽位]:
//   此时 r_flag 已被仲裁器按板号过滤, 把 i_cfg_slv_board_id 与 i_cur_slv_board_id 接同一个常量即可.
module wind_press_drv_slv
#(
	parameter	[19:0]			BAUD_RATE		= 20'd9_600		// 微雀出厂默认9600; 只支持 115200/9600/19200 (驱动内部换算成从板分档)
	,parameter	[7:0]			PARITY			= 8'd0			// 0=无校验 1=奇校验 2=偶校验
	,parameter	integer			RSP_TIMEOUT_MS	= 100			// 响应超时(ms): 含emcc两个轮询周期+从板收发时间+(短帧时)10ms截帧, 留足余量
)(
	input							i_clk
	,input							i_rst			// 高有效(业务域)
	//---------- 命令接口(与wind_press_drv一致) ----------
	,input							i_act_vld		// 命令启动, 拉高1拍(o_busy=1期间被忽略)
	,input	[1:0]					i_act			// 1=读压力(唯一行为, 其余值忽略)
	,input	[7:0]					i_slave_addr	// MODBUS从站地址(微雀默认01h), 命令接受时采样锁存
	,output	reg	[15:0]				o_unit			// 单位(1=KPa 2=Pa), o_done后有效, 保持到下一次成功更新
	,output	reg	[15:0]				o_decs			// 小数位数(0~4)
	,output	reg	[15:0]				o_press			// 压力, 带符号, 实际值=o_press/10^o_decs
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
// 错误码定义(与wind_press_drv一致)
//==================================================================================================
localparam	[7:0]	ERR_NONE	= 8'd0;	// 无错误
localparam	[7:0]	ERR_TMO		= 8'd115;	// 响应超时(无应答)
localparam	[7:0]	ERR_GAP		= 8'd116;	// 应答帧不完整
localparam	[7:0]	ERR_SLAVE	= 8'd117;	// 应答帧从站地址不符
localparam	[7:0]	ERR_CRC		= 8'd118;	// CRC校验错误
localparam	[7:0]	ERR_EXC_DEV	= 8'd120;	// MODBUS异常应答(01非法功能/02非法地址/03非法数据)
// 注: 主板版还有 ERR_GRANT=119(485总线仲裁超时), 从板为专用寄存器通道无仲裁, 不存在此错误
//==================================================================================================
// 状态机 / 帧长
//==================================================================================================
localparam	[1:0]	ST_IDLE		= 2'd0;		// 等待命令, 组装请求帧
localparam	[1:0]	ST_RUN		= 2'd1;		// 已发起发送, 等从板485应答(或超时)
localparam	[7:0]	TX_LEN		= 8'd8;		// 发送帧: 站号+03+地址2+数量2+CRC2
localparam	[7:0]	RSP_LEN		= 8'd11;	// 期望应答: 站号+03+字节数+6数据+CRC2 (异常应答5字节短帧另行解析)
//==================================================================================================
// 寄存器
//==================================================================================================
reg	[1:0]	state;								// 主状态机
reg	[7:0]	slave_r;							// 锁存的从站地址(请求帧与应答比对用同一值)
reg	[8*13-1:0]	tx_frame;						// 发送帧(小端: tx_frame[8*k+:8]=第k个发出的字节; 本帧只用前8字节, 高位端口宽度固定13字节)
reg		send_req_p;							// 驱动发送请求(1拍)
reg	[15:0]	tmo_ms;								// 响应超时ms计数
reg [15:0]  tx_crc_val;                         // 组装阶段计算得到发送CRC
//==================================================================================================
// CRC-16/MODBUS: 初值0xFFFF, 多项式0xA001, 结果低字节在前发送(与wind_press_drv一致)
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
// 从板485通道驱动输出(业务域)与应答帧字节切分(小端)/校验用CRC
// (声明置于状态机之前: 本工程仿真用ModelSim, .v文件先声明后使用才可编译)
//==================================================================================================
wire    [8*13-1:0]  w_rx_data;                       // 收到的应答帧(小端, byte[k]在[8*k+:8])
wire                w_rx_vld;                        // 1拍: 收到新帧
wire    [7:0]       w_drv_err;                       // 1=收满预期长度 6=短帧(10ms截帧)
wire    [7:0]   rx_b0   = w_rx_data[8* 0 +: 8]; // 站号
wire    [7:0]   rx_b1   = w_rx_data[8* 1 +: 8]; // 功能码
wire    [7:0]   rx_b2   = w_rx_data[8* 2 +: 8]; // 字节数 / 异常码
wire    [7:0]   rx_b3   = w_rx_data[8* 3 +: 8]; // 数据0(单位高字节) / 异常应答CRC低
wire    [7:0]   rx_b4   = w_rx_data[8* 4 +: 8]; // 数据1(单位低字节) / 异常应答CRC高
wire    [7:0]   rx_b5   = w_rx_data[8* 5 +: 8]; // 数据2(小数位高字节)
wire    [7:0]   rx_b6   = w_rx_data[8* 6 +: 8]; // 数据3(小数位低字节)
wire    [7:0]   rx_b7   = w_rx_data[8* 7 +: 8]; // 数据4(压力高字节)
wire    [7:0]   rx_b8   = w_rx_data[8* 8 +: 8]; // 数据5(压力低字节)
wire    [7:0]   rx_crcl = w_rx_data[8*(RSP_LEN-8'd2) +: 8]; // 应答帧倒数第2字节=CRC低
wire    [7:0]   rx_crch = w_rx_data[8*(RSP_LEN-8'd1) +: 8]; // 应答帧最后1字节=CRC高
wire    [15:0]  w_rsp_crc   = crc16_n(w_rx_data[8*11-1:0], RSP_LEN[3:0] - 4'd2);   // 正常应答CRC(前9字节)
wire    [15:0]  w_exc_crc   = crc16_n({88'd0, rx_b2, rx_b1, rx_b0}, 4'd3);         // 异常应答CRC(前3字节)
// ---- 发送帧载荷(小端6字节: 站号/03/00/02/00/03)与其CRC预计算 -------------------------
// ST_IDLE用<=给tx_frame赋值, 同一拍对tx_frame取到的仍是旧值(复位后全0), 算出的是"全0帧"的CRC;
// 故CRC必须对"将要写入的载荷"用组合逻辑直接算(w_tx_crc), 再同拍写入帧尾, 不能依赖tx_frame.
wire [8*6-1:0]  w_tx_pay = {8'h03, 8'h00, 8'h02, 8'h00, 8'h03, i_slave_addr}; // 小端: byte[k]在[8*k+:8]
wire [15:0]     w_tx_crc = crc16_n({{5{8'h00}}, w_tx_pay}, 4'd6);             // 低字节在前发送
//==================================================================================================
// 主状态机
//==================================================================================================
always @(posedge i_clk) begin
    if (i_rst) begin
        state       <= ST_IDLE;
        send_req_p  <= 1'b0;
        slave_r     <= 8'h01;
        tx_frame    <= {13{8'h00}};
        tx_crc_val  <= 16'h0000;
        tmo_ms      <= 16'd0;
        o_done      <= 1'b0;
        o_err       <= 1'b0;
        o_err_code  <= ERR_NONE;
        o_unit      <= 16'd0;
        o_decs      <= 16'd0;
        o_press     <= 16'd0;
    end else begin
        o_done  <= 1'b0;
        o_err   <= 1'b0;
        case (state)
            //================= 等待命令, 组装请求帧(与wind_press_drv的帧完全一致) =================
            ST_IDLE: begin
                send_req_p  <= 1'b0;
                tmo_ms      <= 16'd0;
                if (i_act_vld && i_act == 2'd1) begin
                    slave_r             <= i_slave_addr;
                    tx_frame[8* 0 +: 8] <= i_slave_addr;
                    tx_frame[8* 1 +: 8] <= 8'h03;       // 功能码0x03 读保持寄存器
                    tx_frame[8* 2 +: 8] <= 8'h00;       // 起始字地址高
                    tx_frame[8* 3 +: 8] <= 8'h02;       // 起始字地址低 (0x0002=单位)
                    tx_frame[8* 4 +: 8] <= 8'h00;       // 寄存器数量高
                    tx_frame[8* 5 +: 8] <= 8'h03;       // 寄存器数量低 (3: 单位/小数位/压力)
                    // CRC对"将要写入的载荷"用组合逻辑直接算(w_tx_crc), 低字节在前同拍写入帧尾——
                    // 不能对tx_frame取值: NBA同拍拿到的是旧帧(复位后全0), CRC会变成"全0帧"的结果(原bug: 帧尾发00 00)
                    tx_crc_val        <= w_tx_crc;            // 镜像最近一次发送CRC(比帧尾晚1拍, 波形观察用)
                    tx_frame[8* 6 +: 8] <= w_tx_crc[7:0];      // CRC低字节在前
                    tx_frame[8* 7 +: 8] <= w_tx_crc[15:8];
                    o_err_code  <= ERR_NONE;
                    send_req_p  <= 1'b1;
                    state       <= ST_RUN;
                end
            end
            //================= 已发起发送, 等从板485应答 =================
            ST_RUN: begin
                send_req_p  <= 1'b0;
                if (i_time_1ms_vld && (tmo_ms < RSP_TIMEOUT_MS))
                    tmo_ms  <= tmo_ms + 16'd1;
                if (w_rx_vld) begin               // 驱动收到新帧(完整帧或短帧)
                    tmo_ms <= 16'd0;
                    if (rx_b0 != slave_r) begin
                        o_err       <= 1'b1;
                        o_err_code  <= ERR_SLAVE;
                    end else if (rx_b1 == 8'h83) begin
                        // MODBUS异常应答: 站号+83+异常码+CRC2, 固定5字节短帧,
                        // 从板按10ms空闲超时截帧收到(驱动err=6), 但内容完整可解析
                        if ((w_exc_crc[7:0] != rx_b3) || (w_exc_crc[15:8] != rx_b4)) begin
                            o_err       <= 1'b1;
                            o_err_code  <= ERR_CRC;
                        end else begin
                            o_err       <= 1'b1;
                            o_err_code  <= ERR_EXC_DEV; // 01非法功能/02非法地址/03非法数据, 统一报120
                        end
                    end else if ((rx_b1 != 8'h03) || (w_drv_err != 8'd1)) begin
                        // 功能码不符, 或从板未收满预期长度(10ms截帧) → 应答不完整
                        o_err       <= 1'b1;
                        o_err_code  <= ERR_GAP;
                    end else if ((w_rsp_crc[7:0] != rx_crcl) || (w_rsp_crc[15:8] != rx_crch)) begin
                        o_err       <= 1'b1;
                        o_err_code  <= ERR_CRC;
                    end else begin
                        o_done      <= 1'b1;
                        o_err_code  <= ERR_NONE;
                        o_unit  <= {rx_b3, rx_b4};  // 寄存器大端, 高字节在前
                        o_decs  <= {rx_b5, rx_b6};
                        o_press <= {rx_b7, rx_b8};
                    end
                    state   <= ST_IDLE;
                end else if (tmo_ms >= RSP_TIMEOUT_MS) begin
                    // 整个链路(emcc轮询+从板收发)都没等到应答
                    o_err       <= 1'b1;
                    o_err_code  <= ERR_TMO;
                    state       <= ST_IDLE;
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
	.i_send_data		(tx_frame			),	// 13字节小端(本帧只用前8字节)
	.i_exp_send_num		(TX_LEN				),
	.i_exp_recv_num		(RSP_LEN			),
	.o_recv_data		(w_rx_data			),
	.o_recv_finish_p	(w_rx_vld			),
	.o_modbus_err_code	(w_drv_err			)
);
endmodule
