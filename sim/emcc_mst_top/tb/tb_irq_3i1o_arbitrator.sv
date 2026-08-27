`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/13 08:45:37
// Design Name: 
// Module Name: tb_irq_3i1o_arbitrator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 优化版：永久后台监听grant，每次grant上升沿自动清零对应irq请求
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - 重构监听逻辑，全局永久监控grant信号
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_irq_3i1o_arbitrator;
	reg 			clk_i			   	;
	reg 			rst_i              	;
	reg 	[9:0]	sc_id              	;
	reg 	[13:0]	ec_id              	;
	reg 	[3:0]	chl_priority       	;
	reg 			irq_a_i			   	;
	reg 	[7:0]	a_bhv_id           	;
	reg 	[7:0]	a_tx_id            	;
	reg 	[7:0]	a_alm_num          	;
	reg 			irq_b_i			   	;
	reg 	[7:0]	b_bhv_id       	   	;
	reg 	[7:0]	b_tx_id        	   	;
	reg 	[7:0]	b_alm_num      	   	;
	reg 			irq_c_i			   	;
	reg 	[7:0]	c_bhv_id       	   	;
	reg 	[7:0]	c_tx_id        	   	;
	reg 	[7:0]	c_alm_num		   	;
	reg 			irq_receive_ack_i  	;
	
	wire 			irq_a_grant_o      ;
	wire 			irq_b_grant_o      ;
	wire 			irq_c_grant_o      ;
	wire 	[31:0]	irq_reg1_o	       ;
	wire 	[31:0]	irq_reg2_o	       ;
	wire 			irq_o		       ;
	wire 			irq_busy_o	       ;

// 生成100MHz时钟
initial clk_i = 0;
always #5 clk_i = ~clk_i;

// 全局后台监听：复位释放后永久运行，每次grant上升沿自动拉低irq
initial begin
	// 等待复位结束
	wait(rst_i == 0);
	#10;
	// 启动3路无限循环监听，常驻后台
	fork
		// A通道：每次irq_a_grant_o上升沿，irq_a_i立刻置0
		forever begin
			@(posedge irq_a_grant_o);
			irq_a_i = 1'b0;
			$display("[%0t ns] Detect irq_a_grant_o rising edge, clear irq_a_i", $time);
		end
		// B通道
		forever begin
			@(posedge irq_b_grant_o);
			irq_b_i = 1'b0;
			$display("[%0t ns] Detect irq_b_grant_o rising edge, clear irq_b_i", $time);
		end
		// C通道
		forever begin
			@(posedge irq_c_grant_o);
			irq_c_i = 1'b0;
			$display("[%0t ns] Detect irq_c_grant_o rising edge, clear irq_c_i", $time);
		end
	join_none // 启动监听后直接放行，不阻塞主激励
end

// 主测试激励（完全保留你原有所有测试时序，删除重复fork代码）
initial begin
	// 复位初始化所有信号
	rst_i 				=	1;
	sc_id              	=	10'd102;
	ec_id              	=	14'd136;
	chl_priority       	=	4'd0;
	irq_a_i			   	=	0;
	a_bhv_id           	=	0;
	a_tx_id            	=	0;
	a_alm_num          	=	0;
	irq_b_i			   	=	0;
	b_bhv_id       	   	=	0;
	b_tx_id        	   	=	0;
	b_alm_num      	   	=	0;
	irq_c_i			   	=	0;
	c_bhv_id       	   	=	0;
	c_tx_id        	   	=	0;
	c_alm_num		   	=	0;
	irq_receive_ack_i  	=	0;
	#200;
	rst_i = 0;
	$display("[%0t ns] Reset release, start test sequence", $time);
	
	//================================================
	#2000;
	a_bhv_id           	=	8'h12;
	a_tx_id            	=	8'h10;
	a_alm_num          	=	8'd101;
	b_bhv_id       	   	=	8'h23;
	b_tx_id        	   	=	8'h20;
	b_alm_num      	   	=	8'd102;
	c_bhv_id       	   	=	8'h34;
	c_tx_id        	   	=	8'h30;
	c_alm_num		   	=	8'd103;
	
	@(posedge clk_i);
	fork
		irq_a_i			   	=	1;
		irq_b_i			   	=	1;
		irq_c_i			   	=	1;
	join
	
	irq_receive_ack_i  	=	0;

	#2000;
	@(posedge clk_i);
	irq_receive_ack_i  	=	1;
	@(posedge clk_i);
	irq_receive_ack_i  	=	0;

	#2000;
	@(posedge clk_i);
	irq_receive_ack_i  	=	1;
	@(posedge clk_i);
	irq_receive_ack_i  	=	0;

	#2000;
	@(posedge clk_i);
	irq_receive_ack_i  	=	1;
	@(posedge clk_i);
	irq_receive_ack_i  	=	0;
	
	//========================================
	#2000;
	@(posedge clk_i);
	irq_a_i			   	=	1;
	a_bhv_id           	=	8'h12;
	a_tx_id            	=	8'h10;
	a_alm_num          	=	8'd101;
	irq_b_i			   	=	0;
	b_bhv_id       	   	=	0;
	b_tx_id        	   	=	0;
	b_alm_num      	   	=	0;
	irq_c_i			   	=	0;
	c_bhv_id       	   	=	0;
	c_tx_id        	   	=	0;
	c_alm_num		   	=	0;
	irq_receive_ack_i  	=	0;
	
	#2000;
	@(posedge clk_i);
	irq_receive_ack_i  	=	1;
	@(posedge clk_i);
	irq_receive_ack_i  	=	0;
	
	//=========================================================
	#2000;
	irq_a_i			   	=	0;
	a_bhv_id           	=	0;
	a_tx_id            	=	0;
	a_alm_num          	=	0;
	@(posedge clk_i);
	irq_b_i			   	=	1;
	b_bhv_id       	   	=	8'h23;
	b_tx_id        	   	=	8'h20;
	b_alm_num      	   	=	8'd102;
	irq_c_i			   	=	0;
	c_bhv_id       	   	=	0;
	c_tx_id        	   	=	0;
	c_alm_num		   	=	0;
	irq_receive_ack_i  	=	0;
	
	#2000;
	@(posedge clk_i);
	irq_receive_ack_i  	=	1;
	@(posedge clk_i);
	irq_receive_ack_i  	=	0;
	
	//======================================================
	#2000;
	irq_a_i			   	=	0;
	a_bhv_id           	=	0;
	a_tx_id            	=	0;
	a_alm_num          	=	0;
	irq_b_i			   	=	0;
	b_bhv_id       	   	=	0;
	b_tx_id        	   	=	0;
	b_alm_num      	   	=	0;
	@(posedge clk_i);
	irq_c_i			   	=	1;
	c_bhv_id       	   	=	8'h34;
	c_tx_id        	   	=	8'h30;
	c_alm_num		   	=	8'd103;
	irq_receive_ack_i  	=	0;
	
	#2000;
	@(posedge clk_i);
	irq_receive_ack_i  	=	1;
	@(posedge clk_i);
	irq_receive_ack_i  	=	0;
	
	#2000;

end

// DUT实例化（完全保留你原有连接）
irq_3i1o_arbitrator irq_3i1o_arbitrator_u0(
	.clk_i              (clk_i			)
	,.rst_i             (rst_i            )
	,.sc_id             (sc_id            ) 
	,.ec_id             (ec_id            )
	,.chl_priority      (chl_priority     )
	,.irq_a_i			(irq_a_i			)
	,.irq_a_grant_o		(irq_a_grant_o		)
	,.a_bhv_id          (a_bhv_id         )
	,.a_tx_id           (a_tx_id          )
	,.a_alm_num         (a_alm_num        )
	,.irq_b_i			(irq_b_i			)
	,.irq_b_grant_o		(irq_b_grant_o		)
	,.b_bhv_id       	(b_bhv_id       	)
	,.b_tx_id        	(b_tx_id        	)
	,.b_alm_num      	(b_alm_num      	)
	,.irq_c_i			(irq_c_i			)
	,.irq_c_grant_o		(irq_c_grant_o		)
	,.c_bhv_id       	(c_bhv_id       	)
	,.c_tx_id        	(c_tx_id        	)
	,.c_alm_num		    (c_alm_num		   )
	,.irq_reg1_o		(irq_reg1_o			)
	,.irq_reg2_o		(irq_reg2_o			)
	,.irq_o			    (irq_o			   )
	,.irq_busy_o		(irq_busy_o			)
	,.irq_receive_ack_i	(irq_receive_ack_i)
);

endmodule