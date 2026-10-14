`timescale 1ns/1ps
//==========================================================================
// tb_wind_press: wind_press_drv(主板版)独立仿真
// 直接例化驱动 + 轻量485传感器模型(定点波特率9600), 覆盖:
//   1) act=1 读压力: 请求帧须为 01 03 00 02 00 03 A4 0B(读0x0002~0x0004共3寄存器, 手册例2),
//      回 单位1(KPa)/小数2位/压力03E9 -> o_unit/o_decs/o_press (1001/100=10.01KPa)
//   2) act=1 负压力: 回FF9C -> o_press=FF9C(-100)
//   3) act=1 CRC错 : 回帧CRC破坏 -> err_code=118
//   4) act=1 无应答: -> err_code=115(超时)
//==========================================================================
module tb_wind_press;

parameter real CLK_NS  = 6.4;         // 156.25MHz
parameter real BIT_NS  = 104166.7;    // 9600bps

reg           clk = 0;
always #(CLK_NS/2.0) clk = ~clk;

reg           rst = 1'b1;
reg           act_vld = 0;
reg   [1:0]   act = 0;
reg   [7:0]   slave_addr = 8'h01;

wire  [15:0]  unit_w, decs_w, press_w;
wire          done_w, busy_w, err_w;
wire  [7:0]   err_code_w;
wire          de_w, tx_w;
reg           rx_r = 1'b1;

integer       errors = 0;

wind_press_drv #(
	.CLK_FREQ		(156_250_000)
	,.UART_BPS		(9_600     )
	,.PARITY		("NONE"    )
) dut (
	.i_clk			(clk)
	,.i_rst			(rst)
	,.i_act_vld		(act_vld)
	,.i_act			(act)
	,.i_slave_addr		(slave_addr)
	,.o_unit		(unit_w)
	,.o_decs		(decs_w)
	,.o_press		(press_w)
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
	test_meas;
	test_neg;
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
// done/err脉冲粘滞: DUT的1拍脉冲可能在TB任务(阻塞延时发应答帧)执行期间打完,
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
// 发起一次读命令, 收集8字节请求帧并与期望比对
//--------------------------------------------------------------------------
task automatic issue_cmd(input [7:0] exp_frame [0:7]);
	reg [7:0] got [0:7];
	integer k;
	begin
		done_seen	= 1'b0;
		err_seen	= 1'b0;
		@(negedge clk);
		act		<= 2'd1;
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
// 组应答帧并发送: payload前n字节+自动CRC(可破坏), 起始延时60bit跨过DUT的ST_TURN(40bit)
//--------------------------------------------------------------------------
task automatic send_rsp(input [7:0] payload [0:8], input integer n, input bit corrupt_crc);
	reg [7:0] f [0:10];
	reg [15:0] c;
	integer k;
	begin
		for (k = 0; k < n; k = k + 1)
			f[k] = payload[k];
		c = 16'hFFFF;
		for (k = 0; k < n; k = k + 1)
			c = crc16f(c, f[k]);
		f[n] = c[7:0];
		f[n+1] = c[15:8];
		if (corrupt_crc)
			f[n] = ~f[n];
		#(BIT_NS*60.0);
		for (k = 0; k < n + 2; k = k + 1)
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
task automatic test_meas;
	begin
		$display("TEST1: 读压力(0x0002~0x0004), 回 KPa/2位/03E9");
		issue_cmd('{8'h01,8'h03,8'h00,8'h02,8'h00,8'h03,8'hA4,8'h0B});
		send_rsp('{8'h01,8'h03,8'h06,8'h00,8'h01,8'h00,8'h02,8'h03,8'hE9}, 9, 1'b0);
		wait_result;
		if (done_seen !== 1'b1) begin
			$display("[%0t] FAIL: TEST1 期望done, got err_code=%0d", $time, err_code_w);
			errors = errors + 1;
		end else if (unit_w !== 16'd1 || decs_w !== 16'd2 || press_w !== 16'h03E9) begin
			$display("[%0t] FAIL: TEST1 u=%0d d=%0d p=%04X exp=1/2/03E9", $time, unit_w, decs_w, press_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST1 unit=%0d decs=%0d press=%04X(=10.01KPa)", $time, unit_w, decs_w, press_w);
	end
endtask

task automatic test_neg;
	begin
		$display("TEST2: 读压力负值, 回FF9C(-100)");
		issue_cmd('{8'h01,8'h03,8'h00,8'h02,8'h00,8'h03,8'hA4,8'h0B});
		send_rsp('{8'h01,8'h03,8'h06,8'h00,8'h01,8'h00,8'h00,8'hFF,8'h9C}, 9, 1'b0);
		wait_result;
		if (done_seen !== 1'b1 || press_w !== 16'hFF9C) begin
			$display("[%0t] FAIL: TEST2 done_seen=%b press=%04X", $time, done_seen, press_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST2 o_press=%04X(-100)", $time, press_w);
	end
endtask

task automatic test_crc_err;
	begin
		$display("TEST3: 读压力, 回帧CRC破坏");
		issue_cmd('{8'h01,8'h03,8'h00,8'h02,8'h00,8'h03,8'hA4,8'h0B});
		send_rsp('{8'h01,8'h03,8'h06,8'h00,8'h01,8'h00,8'h02,8'h03,8'hE9}, 9, 1'b1);
		wait_result;
		if (err_seen !== 1'b1 || err_code_w !== 8'd118) begin
			$display("[%0t] FAIL: TEST3 err_seen=%b code=%0d exp=118", $time, err_seen, err_code_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST3 err_code=118", $time);
	end
endtask

task automatic test_timeout;
	begin
		$display("TEST4: 读压力, 不回应答");
		issue_cmd('{8'h01,8'h03,8'h00,8'h02,8'h00,8'h03,8'hA4,8'h0B});
		wait_result;
		if (err_seen !== 1'b1 || err_code_w !== 8'd115) begin
			$display("[%0t] FAIL: TEST4 err_seen=%b code=%0d exp=115", $time, err_seen, err_code_w);
			errors = errors + 1;
		end else
			$display("[%0t] PASS: TEST4 err_code=115(超时)", $time);
	end
endtask

endmodule
