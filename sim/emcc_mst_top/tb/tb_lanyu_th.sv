`timescale 1ns/1ps
//==========================================================================
// tb_lanyu_th: lanyu_temper_humidity_drv(主板版)独立仿真
// 直接例化驱动 + 轻量485传感器模型(定点波特率115200), 覆盖:
//   1) act=1 读温度  : 请求帧须为 01 03 00 00 00 01 84 0A, 回012B→o_temp
//   2) act=2 读湿度  : 请求帧须为 02 03 00 00 00 01 84 39, 回02A0→o_humi
//   3) act=1 负温度  : 回FFCD→o_temp=FFCD(-5.1℃)
//   4) act=1 传感器故障: 回2710→err_code=122, o_temp不变
//   5) act=1 CRC错   : 回帧CRC破坏→err_code=118
//   6) act=1 无应答  : →err_code=115(超时)
//==========================================================================
module tb_lanyu_th;

parameter real CLK_NS  = 6.4;      // 156.25MHz
parameter real BIT_NS  = 8680.6;   // 115200bps

reg           clk = 0;
always #(CLK_NS/2.0) clk = ~clk;

reg           rst = 1'b1;
reg           act_vld = 0;
reg   [1:0]   act = 0;
reg   [7:0]   slave_addr = 8'h01;

wire  [15:0]  temp_w, humi_w;
wire          done_w, busy_w, err_w;
wire  [7:0]   err_code_w;
wire          de_w, tx_w;
reg           rx_r = 1'b1;

integer       errors = 0;

lanyu_temper_humidity_drv #(
	.CLK_FREQ		(156_250_000)
	,.UART_BPS		(115_200)
	,.PARITY		("NONE")
	,.RSP_TIMEOUT_MS	(2)
	,.GAP_TIMEOUT_MS	(2)
	,.GNT_TIMEOUT_MS	(2)
) dut (
	.i_clk			(clk)
	,.i_rst			(rst)
	,.i_act_vld		(act_vld)
	,.i_act			(act)
	,.i_slave_addr		(slave_addr)
	,.o_temp		(temp_w)
	,.o_humi		(humi_w)
	,.o_done		(done_w)
	,.o_busy		(busy_w)
	,.o_err		(err_w)
	,.o_err_code		(err_code_w)
	,.o_485_bus_req	()
	,.i_485_bus_grant	(1'b1)
	,.o_rs485_de		(de_w)
	,.o_uart_tx		(tx_w)
	,.i_uart_rx		(rx_r)
);

initial begin
	rst = 1'b1;
	#1000;
	@(negedge clk);
	rst = 1'b0;
	#1000;
	test_temp;
	test_humi;
	test_neg;
	test_sens_fault;
	test_crc_err;
	test_timeout;
	$display("=========================================");
	if (errors == 0)
		$display("ALL TESTS PASSED");
	else
		$display("FAILED: %0d error(s)", errors);
	$finish;
end

//--------------------------------------------------------------------------
// CRC-16/MODBUS
//--------------------------------------------------------------------------
function automatic [15:0] crc16f(input [15:0] c, input [7:0] d);
	integer k;
	begin
		crc16f = c ^ {8'h00, d};
		for (k = 0; k < 8; k = k + 1)
			crc16f = crc16f[0] ? ({1'b0, crc16f[15:1]} ^ 16'hA001)
					   : {1'b0, crc16f[15:1]};
	end
endfunction

//--------------------------------------------------------------------------
// 485物理层: 从tx_w收1字节 / 往rx_r发1字节 (8N1)
//--------------------------------------------------------------------------
task automatic mon_byte(output [7:0] b);
	integer k;
	begin
		@(negedge tx_w);
		#(BIT_NS*1.5);
		for (k = 0; k < 8; k = k + 1) begin
			b[k] = tx_w;
			#BIT_NS;
		end
	end
endtask

task automatic drv_byte(input [7:0] d);
	integer k;
	begin
		rx_r = 1'b0;
		#BIT_NS;
		for (k = 0; k < 8; k = k + 1) begin
			rx_r = d[k];
			#BIT_NS;
		end
		rx_r = 1'b1;
		#BIT_NS;
	end
endtask

//--------------------------------------------------------------------------
// done/err脉冲粘滞: DUT的1拍脉冲可能在TB任务(如send_rsp的阻塞延时)执行期间打完,
// 用always置位的标志代替直接wait脉冲线, 消除竞态
//--------------------------------------------------------------------------
reg done_seen = 1'b0;
reg err_seen  = 1'b0;
always @(posedge clk) begin
	if (rst) begin
		done_seen	<= 1'b0;
		err_seen	<= 1'b0;
	end else begin
		if (done_w)
			done_seen	<= 1'b1;
		if (err_w)
			err_seen	<= 1'b1;
	end
end

//--------------------------------------------------------------------------
// 发起一次读命令, 收集8字节请求帧并与期望比对
//--------------------------------------------------------------------------
task automatic issue_cmd(input [1:0] a, input [7:0] exp_frame [0:7]);
	reg [7:0] got [0:7];
	integer k;
	begin
		done_seen	= 1'b0;
		err_seen	= 1'b0;
		@(negedge clk);
		act		<= a;
		act_vld		<= 1'b1;
		@(negedge clk);
		act_vld		<= 1'b0;
		act		<= 0;
		for (k = 0; k < 8; k = k + 1)
			mon_byte(got[k]);
		for (k = 0; k < 8; k = k + 1)
			if (got[k] !== exp_frame[k]) begin
				$display("[%0t] FAIL: 请求帧字节%0d got=%02X exp=%02X", $time, k, got[k], exp_frame[k]);
				errors = errors + 1;
			end
	end
endtask

//--------------------------------------------------------------------------
// 组应答帧并发送(起始时间=最后1字节停止位结束后60bit, 跨过DUT的ST_TURN 40bit静默)
//--------------------------------------------------------------------------
task automatic send_rsp(input [7:0] sta, input [15:0] val, input bit corrupt_crc);
	reg [7:0] f [0:6];
	reg [15:0] c;
	integer k;
	begin
		f[0] = sta;
		f[1] = 8'h03;
		f[2] = 8'h02;
		f[3] = val[15:8];
		f[4] = val[7:0];
		c = 16'hFFFF;
		for (k = 0; k < 5; k = k + 1)
			c = crc16f(c, f[k]);
		f[5] = c[7:0];
		f[6] = c[15:8];
		if (corrupt_crc)
			f[5] = ~f[5];
		#(BIT_NS*60.0);
		for (k = 0; k < 7; k = k + 1)
			drv_byte(f[k]);
	end
endtask

task automatic wait_result;
	begin
		wait (done_seen === 1'b1 || err_seen === 1'b1);
		@(posedge clk);
	end
endtask

//--------------------------------------------------------------------------
// 测试用例
//--------------------------------------------------------------------------
reg [15:0] temp_keep;

task automatic test_temp;
	begin
		$display("TEST1: 读温度(01), 回012B");
		issue_cmd(2'd1, '{8'h01,8'h03,8'h00,8'h00,8'h00,8'h01,8'h84,8'h0A});
		send_rsp(8'h01, 16'h012B, 1'b0);
		wait_result;
		if (done_seen !== 1'b1) begin
			$display("[%0t] FAIL: TEST1 期望done, got err_code=%0d", $time, err_code_w);
			errors = errors + 1;
		end else if (temp_w !== 16'h012B) begin
			$display("[%0t] FAIL: TEST1 o_temp=%04X exp=012B", $time, temp_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST1 o_temp=%04X", $time, temp_w);
	end
endtask

task automatic test_humi;
	begin
		$display("TEST2: 读湿度(02), 回02A0");
		issue_cmd(2'd2, '{8'h02,8'h03,8'h00,8'h00,8'h00,8'h01,8'h84,8'h39});
		send_rsp(8'h02, 16'h02A0, 1'b0);
		wait_result;
		if (done_seen !== 1'b1) begin
			$display("[%0t] FAIL: TEST2 期望done, got err_code=%0d", $time, err_code_w);
			errors = errors + 1;
		end else if (humi_w !== 16'h02A0) begin
			$display("[%0t] FAIL: TEST2 o_humi=%04X exp=02A0", $time, humi_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST2 o_humi=%04X", $time, humi_w);
	end
endtask

task automatic test_neg;
	begin
		$display("TEST3: 读温度负值, 回FFCD(-51→-5.1℃)");
		issue_cmd(2'd1, '{8'h01,8'h03,8'h00,8'h00,8'h00,8'h01,8'h84,8'h0A});
		send_rsp(8'h01, 16'hFFCD, 1'b0);
		wait_result;
		if (done_seen !== 1'b1 || temp_w !== 16'hFFCD) begin
			$display("[%0t] FAIL: TEST3 done_seen=%b temp=%04X", $time, done_seen, temp_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST3 o_temp=%04X", $time, temp_w);
	end
endtask

task automatic test_sens_fault;
	begin
		$display("TEST4: 读温度, 回2710(传感器内部故障)");
		temp_keep = temp_w;
		issue_cmd(2'd1, '{8'h01,8'h03,8'h00,8'h00,8'h00,8'h01,8'h84,8'h0A});
		send_rsp(8'h01, 16'h2710, 1'b0);
		wait_result;
		if (err_seen !== 1'b1 || err_code_w !== 8'd122) begin
			$display("[%0t] FAIL: TEST4 err_seen=%b code=%0d exp=122", $time, err_seen, err_code_w);
			errors = errors + 1;
		end else if (temp_w !== temp_keep) begin
			$display("[%0t] FAIL: TEST4 o_temp被错误更新", $time);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST4 err_code=122, o_temp保持", $time);
	end
endtask

task automatic test_crc_err;
	begin
		$display("TEST5: 读温度, 回帧CRC破坏");
		issue_cmd(2'd1, '{8'h01,8'h03,8'h00,8'h00,8'h00,8'h01,8'h84,8'h0A});
		send_rsp(8'h01, 16'h0190, 1'b1);
		wait_result;
		if (err_seen !== 1'b1 || err_code_w !== 8'd118) begin
			$display("[%0t] FAIL: TEST5 err_seen=%b code=%0d exp=118", $time, err_seen, err_code_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST5 err_code=118", $time);
	end
endtask

task automatic test_timeout;
	begin
		$display("TEST6: 读温度, 不回应答");
		issue_cmd(2'd1, '{8'h01,8'h03,8'h00,8'h00,8'h00,8'h01,8'h84,8'h0A});
		wait_result;
		if (err_seen !== 1'b1 || err_code_w !== 8'd115) begin
			$display("[%0t] FAIL: TEST6 err_seen=%b code=%0d exp=115", $time, err_seen, err_code_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST6 err_code=115(超时)", $time);
	end
endtask

endmodule
