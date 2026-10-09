//2026/10/7
//cgliu

module supu_rfid_drv
#(
	parameter			CLK_FREQ		= 100_000_000
	,parameter			UART_BPS		= 115_200
	,parameter			PARITY			= "NONE"
	,parameter			RSP_TIMEOUT_MS	= 2	//ms
	,parameter			GAP_TIMEOUT_MS	= 2	//ms
	,parameter			GNT_TIMEOUT_MS	= 2	//ms
)(
	input							i_clk
	,input							i_rst			// 高有效, 与 uart_tx/uart_rx 一致
	//---------- 命令接口 ----------
	,input							i_act_vld		// 命令启动, 拉高1拍(o_busy=1期间被忽略)
	,input	[1:0]					i_act			// 1=写标签 2=读UID 3=读标签
	,input	[7:0]					i_slave_addr	// MODBUS从站地址(苏培默认01h, 合法1~16), 命令接受时采样锁存
	,input	[31:0]					i_wdata			// 行为1: 写入的32bit数据
	,output	reg	[63:0]				o_uid			// 行为2: UID(o_done后有效)
	,output	reg	[31:0]				o_rdata			// 行为3: 读回的32bit(o_done后有效)
	,output	reg						o_done			// 1拍: 命令成功完成
	,output							o_busy			// 1=驱动忙
	,output	reg						o_err			// 1拍: 命令失败, 看o_err_code
	,output	reg	[7:0]				o_err_code		// 错误号码(保持到下一次命令)
	//---------- 485总线仲裁 ----------
	,output							o_485_bus_req	// 1=请求占用485总线(整个事务期间保持)
	,input							i_485_bus_grant	// 1=获得总线授权, 允许开始收发
	//---------- UART / RS485 ----------
	,output							o_rs485_de		// RS485方向: 1=发送
	,output							o_uart_tx
	,input							i_uart_rx
);

//==================================================================================================
// 错误码定义
//==================================================================================================
localparam	[7:0]	ERR_NONE	= 8'd0;	// 无错误
localparam	[7:0]	ERR_TMO		= 8'd115;	// 响应超时(无应答)
localparam	[7:0]	ERR_GAP		= 8'd116;	// 应答帧不完整
localparam	[7:0]	ERR_SLAVE	= 8'd117;	// 应答帧从站地址不符
localparam	[7:0]	ERR_CRC		= 8'd118;	// CRC校验错误
localparam	[7:0]	ERR_GRANT	= 8'd119;	// 485总线仲裁超时(未获得授权)
localparam	[7:0]	ERR_EXC_DEV	= 8'd120;	// MODBUS异常应答: 设备故障(04H)或其他非0BH异常
localparam	[7:0]	ERR_EXC_TAG	= 8'd121;	// MODBUS异常应答: 标签不在读取区域(0BH)

//==================================================================================================
// 状态机 / 定时参数
//==================================================================================================
localparam	[3:0]	ST_IDLE		= 4'd0;		// 等待命令
localparam	[3:0]	ST_TX_LOAD	= 4'd1;		// 装载发送字节(仅1拍)
localparam	[3:0]	ST_TX_WAIT	= 4'd2;		// 等当前字节发送完成
localparam	[3:0]	ST_TURN		= 4'd3;		// 发送后总线静默+RS485换向(4字符)
localparam	[3:0]	ST_RSP_WAIT	= 4'd4;		// 等应答首字节
localparam	[3:0]	ST_RX		= 4'd5;		// 接收并解析应答
localparam	[3:0]	ST_CHECK	= 4'd6;		// CRC校验与结果判定
localparam	[3:0]	ST_REQ		= 4'd7;		// 请求485总线, 等待i_485_bus_grant授权

localparam	integer	BAUD_CYC	= CLK_FREQ/UART_BPS;			// 1个bit的时钟数
localparam	integer	TURN_CYC	= BAUD_CYC*40;					// 4字符静默(>RTU帧间隔3.5字符)
localparam	integer	GAP_TMO_CYC	= (CLK_FREQ/1000)*GAP_TIMEOUT_MS;
localparam	integer	RSP_TMO_CYC	= (CLK_FREQ/1000)*RSP_TIMEOUT_MS;
localparam	integer	GNT_TMO_CYC	= (CLK_FREQ/1000)*GNT_TIMEOUT_MS;

//==================================================================================================
// 寄存器定义
//==================================================================================================
reg	[3:0]	state;								// 主状态机
reg	[1:0]	act_r;								// 锁存的行为码
reg	[7:0]	slave_r;							// 锁存的从站地址(请求帧与应答比对用同一值)
reg	[7:0]	tx_mem	[0:12];						// 发送帧缓冲(最长13字节=写标签)
reg	[7:0]	rx_mem	[0:12];						// 接收帧暂存(调试观察用)
reg	[3:0]	tx_idx;								// 发送字节计数
reg	[3:0]	tx_len;								// 发送帧总长
reg	[3:0]	tx_pay;								// 发送帧中CRC之前的有效字节数
reg	[15:0]	tx_crc;								// 发送CRC累加
reg	[3:0]	rx_idx;								// 接收字节计数
reg	[3:0]	exp_len;							// 本应答帧期望总长
reg			rsp_exc;							// 1=收到异常应答(功能码|0x80)
reg	[7:0]	exc_r;								// 异常应答中的异常码(内部暂存)
reg	[15:0]	rx_crc;								// 接收CRC累加
reg	[7:0]	rx_crcl;							// 收到的CRC低字节
reg	[7:0]	rx_crch;							// 收到的CRC高字节
reg	[31:0]	tmo_cnt;							// 超时计数器(分时复用)
integer		i;

wire	[7:0]	w_rx_da;							// uart_rx数据
wire			w_rx_done;							// uart_rx字节完成(1拍)
wire			w_tx_done;							// uart_tx字节完成(1拍)
wire	[7:0]	w_exp_func	= (act_r == 2'd1) ? 8'h10 : 8'h03;	// 期望的应答功能码
wire	[7:0]	w_tx_da;							// 发送字节(CRC字节由tx_crc给出)
wire			w_tx_vld;							// 发送启动(1拍)

//==================================================================================================
// CRC-16/MODBUS: 初值0xFFFF, 多项式0xA001, 结果低字节在前发送
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

//==================================================================================================
// 发送字节选择: 有效字节之后先发CRC低字节再发CRC高字节
//==================================================================================================
assign	w_tx_da	= (tx_idx <  tx_pay) ? tx_mem[tx_idx]
			: (tx_idx == tx_pay) ? tx_crc[7:0]
			:					   tx_crc[15:8];

assign	w_tx_vld	= (state == ST_TX_LOAD);
assign	o_busy		= (state != ST_IDLE);
assign	o_485_bus_req	= (state != ST_IDLE);	// 命令被接受即拉高, 事务结束(成功/失败)回IDLE自动拉低
assign	o_rs485_de	= (state == ST_TX_LOAD) || (state == ST_TX_WAIT) || (state == ST_TURN);

//==================================================================================================
// 主状态机
//==================================================================================================
always @(posedge i_clk) begin
	if (i_rst) begin
		state		<= ST_IDLE;
		o_done		<= 1'b0;
		o_err		<= 1'b0;
		o_err_code	<= ERR_NONE;
		act_r		<= 2'd0;
		slave_r		<= 8'h01;
		tx_idx		<= 4'd0;
		tx_len		<= 4'd0;
		tx_pay		<= 4'd0;
		tx_crc		<= 16'hFFFF;
		rx_idx		<= 4'd0;
		exp_len		<= 4'd0;
		rsp_exc		<= 1'b0;
		exc_r		<= 8'h00;
		rx_crc		<= 16'hFFFF;
		rx_crcl		<= 8'h00;
		rx_crch		<= 8'h00;
		tmo_cnt		<= 32'd0;
		o_uid		<= 64'd0;
		o_rdata		<= 32'd0;
		for (i = 0; i < 13; i = i + 1) begin
			tx_mem[i] <= 8'h00;
			rx_mem[i] <= 8'h00;
		end
	end else begin
		o_done <= 1'b0;
		o_err  <= 1'b0;

		case (state)
		//================= 等待命令, 组装请求帧 =================
		ST_IDLE: begin
			if (i_act_vld) begin
				act_r		<= i_act;
				slave_r		<= i_slave_addr;
				tx_idx		<= 4'd0;
				tx_crc		<= 16'hFFFF;
				o_err_code	<= ERR_NONE;
				tmo_cnt		<= 32'd0;
				case (i_act)
				//---- 行为1: 写标签 32bit @字地址0 ----
				2'd1: begin
					tx_mem[0]	<= i_slave_addr;
					tx_mem[1]	<= 8'h10;			// 功能码0x10 写多寄存器
					tx_mem[2]	<= 8'h00;			// 起始字地址高
					tx_mem[3]	<= 8'h00;			// 起始字地址低 (0)
					tx_mem[4]	<= 8'h00;			// 寄存器数量高
					tx_mem[5]	<= 8'h02;			// 寄存器数量低 (2寄存器=4字节)
					tx_mem[6]	<= 8'h04;			// 字节数
					tx_mem[7]	<= i_wdata[31:24];	// 数据字节0(标签字节0)
					tx_mem[8]	<= i_wdata[23:16];
					tx_mem[9]	<= i_wdata[15:8];
					tx_mem[10]	<= i_wdata[7:0];
					tx_len		<= 4'd13;
					tx_pay		<= 4'd11;
					state		<= ST_REQ;			// → 先请求485总线
				end
				//---- 行为2: 读UID (E000~E003, 4寄存器=8字节) ----
				2'd2: begin
					tx_mem[0]	<= i_slave_addr;
					tx_mem[1]	<= 8'h03;			// 功能码0x03 读保持寄存器
					tx_mem[2]	<= 8'hE0;			// 起始地址高
					tx_mem[3]	<= 8'h00;			// 起始地址低 (E000)
					tx_mem[4]	<= 8'h00;			// 寄存器数量高
					tx_mem[5]	<= 8'h04;			// 寄存器数量低 (4)
					tx_len		<= 4'd8;
					tx_pay		<= 4'd6;
					state		<= ST_REQ;
				end
				//---- 行为3: 读标签 32bit @字地址0 ----
				2'd3: begin
					tx_mem[0]	<= i_slave_addr;
					tx_mem[1]	<= 8'h03;
					tx_mem[2]	<= 8'h00;
					tx_mem[3]	<= 8'h00;
					tx_mem[4]	<= 8'h00;
					tx_mem[5]	<= 8'h02;			// 2寄存器=4字节
					tx_len		<= 4'd8;
					tx_pay		<= 4'd6;
					state		<= ST_REQ;
				end
				//---- 非法行为码: 忽略该命令 ----
				default: ;
				endcase
			end
		end

		//================= 请求485总线, 等待仲裁授权 =================
		ST_REQ: begin
			if (i_485_bus_grant)
				state <= ST_TX_LOAD;				// 获得总线 → 开始发送请求帧
			else if (tmo_cnt >= GNT_TMO_CYC) begin	// 长时间得不到授权(仲裁器异常/总线被长期占用)
				o_err		<= 1'b1;
				o_err_code	<= ERR_GRANT;
				state		<= ST_IDLE;				// 回IDLE, 释放o_485_bus_req
			end else
				tmo_cnt <= tmo_cnt + 32'd1;
		end

		//================= 装载发送字节(本状态仅停留1拍) =================
		ST_TX_LOAD: begin
			if (tx_idx < tx_pay)					// 有效字节参与CRC累加
				tx_crc <= crc16(tx_crc, tx_mem[tx_idx]);
			tmo_cnt	<= 32'd0;
			state	<= ST_TX_WAIT;
		end

		//================= 等当前字节发送完成 =================
		ST_TX_WAIT: begin
			if (w_tx_done) begin
				tmo_cnt	<= 32'd0;
				if (tx_idx == tx_len - 4'd1)
					state <= ST_TURN;				// 全部发完 → 总线静默/换向
				else begin
					tx_idx	<= tx_idx + 4'd1;
					state	<= ST_TX_LOAD;
				end
			end
		end

		//================= 发送后总线静默 + RS485收发切换 =================
		ST_TURN: begin
			if (tmo_cnt >= TURN_CYC) begin
				tmo_cnt	<= 32'd0;
				rx_crc	<= 16'hFFFF;
				rx_idx	<= 4'd0;
				rsp_exc	<= 1'b0;
				state	<= ST_RSP_WAIT;
			end else
				tmo_cnt <= tmo_cnt + 32'd1;
		end

		//================= 等应答首字节(从站地址) =================
		ST_RSP_WAIT: begin
			if (tmo_cnt >= RSP_TMO_CYC) begin
				o_err		<= 1'b1;
				o_err_code	<= ERR_TMO;
				state		<= ST_IDLE;
			end else if (w_rx_done) begin
				tmo_cnt		<= 32'd0;
				rx_crc		<= crc16(16'hFFFF, w_rx_da);
				rx_mem[0]	<= w_rx_da;
				rx_idx		<= 4'd1;
				if (w_rx_da != slave_r) begin
					o_err		<= 1'b1;
					o_err_code	<= ERR_SLAVE;
					state		<= ST_IDLE;
				end else
					state <= ST_RX;
			end else
				tmo_cnt <= tmo_cnt + 32'd1;
		end

		//================= 接收并逐字节解析应答 =================
		ST_RX: begin
			if (tmo_cnt >= GAP_TMO_CYC) begin		// 字节间隔超时→帧不完整
				o_err		<= 1'b1;
				o_err_code	<= ERR_GAP;
				state		<= ST_IDLE;
			end else if (w_rx_done) begin
				tmo_cnt			<= 32'd0;
				rx_mem[rx_idx]	<= w_rx_da;
				if ((rx_idx <= 4'd2) || (rx_idx < exp_len - 4'd2))
					rx_crc <= crc16(rx_crc, w_rx_da);	// 除最后2字节(CRC)外全部参与累加

				case (rx_idx)
				//---- 字节1: 区分正常应答/异常应答, 确定帧长 ----
				4'd1: begin
					if (w_rx_da == (w_exp_func | 8'h80)) begin
						rsp_exc	<= 1'b1;				// 异常应答: 站号+(功能码|80)+异常码+CRC2
						exp_len	<= 4'd5;
					end else begin
						rsp_exc	<= 1'b0;				// 正常应答(内容正确性由CRC兜底)
						case (act_r)
						2'd1:	exp_len <= 4'd8;	// 写回显: 站号+10+地址2+数量2+CRC2
						2'd2:	exp_len <= 4'd13;	// 读UID: +字节数+8数据+CRC2
						default:	exp_len <= 4'd9;	// 读32bit: +字节数+4数据+CRC2
						endcase
					end
				end
				//---- 字节2: 异常应答时为异常码 ----
				4'd2: begin
					if (rsp_exc)
						exc_r <= w_rx_da;
				end
				default: ;
				endcase

				//---- 数据移位接收: 字节在前的进高位(与写命令字节序对称) ----
				if (!rsp_exc) begin
					if (act_r == 2'd2 && rx_idx >= 4'd3 && rx_idx <= 4'd10)
						o_uid	<= {o_uid[55:0], w_rx_da};
					if (act_r == 2'd3 && rx_idx >= 4'd3 && rx_idx <= 4'd6)
						o_rdata	<= {o_rdata[23:0], w_rx_da};
				end

				//---- 帧尾判定 ----
				if (rx_idx == exp_len - 4'd2)
					rx_crcl	<= w_rx_da;
				if (rx_idx == exp_len - 4'd1) begin
					rx_crch	<= w_rx_da;
					state	<= ST_CHECK;
				end else
					rx_idx	<= rx_idx + 4'd1;
			end else
				tmo_cnt <= tmo_cnt + 32'd1;
		end

		//================= 帧接收完成: CRC校验 + 结果判定 =================
		ST_CHECK: begin
			if ((rx_crc[7:0] != rx_crcl) || (rx_crc[15:8] != rx_crch)) begin
				o_err		<= 1'b1;
				o_err_code	<= ERR_CRC;
			end else if (rsp_exc) begin				// 0x1B=标签不在读取区域(最常见), 其余归入0x14
				o_err		<= 1'b1;
				o_err_code	<= (exc_r == 8'h0B) ? ERR_EXC_TAG : ERR_EXC_DEV;
			end else begin
				o_done		<= 1'b1;
				o_err_code	<= ERR_NONE;
			end
			state <= ST_IDLE;
		end

		default: state <= ST_IDLE;
		endcase
	end
end

//==================================================================================================
// UART 发送 / 接收 (复用本目录 uart_tx.v / uart_rx.v)
//==================================================================================================
uart_tx #(
	.CLK_FREQ	(CLK_FREQ)
	,.UART_BPS	(UART_BPS)
	,.PARITY	(PARITY)
) u_uart_tx (
	.i_clk		(i_clk)
	,.i_rst		(i_rst)
	,.i_tx_vld	(w_tx_vld)
	,.i_tx_da	(w_tx_da)
	,.o_tx_done	(w_tx_done)
	,.o_uart_tx	(o_uart_tx)
);

uart_rx #(
	.CLK_FREQ	(CLK_FREQ)
	,.UART_BPS	(UART_BPS)
	,.PARITY	(PARITY)
) u_uart_rx (
	.i_clk		(i_clk)
	,.i_rst		(i_rst)
	,.i_uart_rx	(i_uart_rx)
	,.o_rx_done	(w_rx_done)
	,.o_rx_da	(w_rx_da)
);

endmodule
