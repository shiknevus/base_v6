`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/26 11:27:36
// Design Name: 
// Module Name: tb_man_handwheel
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


module tb_man_handwheel(

    );
	
	// ===================== 参数配置 =====================
localparam  CLK_FREQ     = 100_000_000;   // 主时钟 100M
localparam  AB_FREQ      = 10_000;        // AB相脉冲频率，可修改，例10kHz
localparam  CLK_PERIOD   = 1_000_000_000 / CLK_FREQ;  // 时钟周期 10ns
localparam  AB_PERIOD    = 1_000_000_000 / AB_FREQ;   // AB完整周期
localparam  TICK_QURT    = AB_PERIOD / 4; // AB四分之一周期，90°相位间隔

reg         clk	;
reg         rst_n;

wire		rst = !rst_n;

reg         dir_sel;  // 0:正转 A超前B； 1:反转 B超前A
reg        a_o;
reg        b_o;

reg [31:0] cnt_ns;
reg [1:0]  state;


// 100M时钟生成
initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst_n   = 1'b0;
    dir_sel = 1'b0;
    #100;
    rst_n   = 1'b1;

    // ==========仿真流程==========
    // 1.正转 A超前B，运行20个AB周期
    dir_sel = 1'b1;
    #(20000 * AB_PERIOD);

    // 2.切换反转 B超前A，运行20个AB周期
    dir_sel = 1'b0;
    #(20000 * AB_PERIOD);

    // 停止仿真
    #(5000000);
end


// -----------------------------------------------------------------------------
// dir_sel=0 正转：A超前B 90°
// dir_sel=1 反转：B超前A 90°
// TICK_QURT：四分之一AB周期，单位ns
// -----------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_ns  <= 32'd0;
        state   <= 2'd0;
        a_o     <= 1'b0;
        b_o     <= 1'b0;
    end
    else begin
        if(cnt_ns >= TICK_QURT) begin
            cnt_ns <= 32'd0;
            state  <= state + 2'd1;
        end
        else begin
            cnt_ns <= cnt_ns + 32'd10; // 100M时钟每一拍10ns
        end

        case(state)
            2'b00: begin
                if(dir_sel == 1'b0) begin //正转 A先拉高
                    a_o <= 1'b1;
                    b_o <= 1'b0;
                end else begin            //反转 B先拉高
                    a_o <= 1'b0;
                    b_o <= 1'b1;
                end
            end
            2'b01: begin
                a_o <= 1'b1;
                b_o <= 1'b1;
            end
            2'b10: begin
                if(dir_sel == 1'b0) begin
                    a_o <= 1'b0;
                    b_o <= 1'b1;
                end else begin
                    a_o <= 1'b1;
                    b_o <= 1'b0;
                end
            end
            2'b11: begin
                a_o <= 1'b0;
                b_o <= 1'b0;
            end
        endcase
    end
end

//sample_vld
reg	sample_vld;

initial sample_vld = 0;

always begin
	#1000_000;
	@(posedge clk);
	sample_vld <= 1;
	@(posedge clk);
	sample_vld <= 0;
end


wire 	[3:0] 	o_axis_number  ;
wire 	[7:0]	o_speed_gear   ;
wire 	[31:0]	o_pulse_cnt    ;
wire 			o_wheel_dir    ;

	man_handwheel man_handwheel
(
    .clk             	(clk)
    ,.reset          	(rst)
	,.i_pulse_a		 	(a_o)
	,.i_pulse_b			(b_o)
	,.i_stp_x1       	(0)
	,.i_stp_x10      	(0)
	,.i_stp_x100     	(1)
	,.i_axis_x       	(0)
	,.i_axis_y       	(0)
	,.i_axis_z       	(0)
	,.i_axis_4       	(0)
	,.i_axis_5       	(0)
	,.i_axis_6       	(1)
	,.i_axis_7       	(0)
	,.o_axis_number  	(o_axis_number )
	,.o_speed_gear   	(o_speed_gear  )
	,.o_pulse_cnt    	(o_pulse_cnt   )
	,.o_wheel_dir    	(o_wheel_dir   )
	,.sample_vld     	(sample_vld)
);

endmodule
