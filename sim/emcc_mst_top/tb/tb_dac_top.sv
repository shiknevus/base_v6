`timescale 1 ns / 100 ps
module tb_dac_top();

localparam SYS_CLK_PERIOD    = 10;    //100MHz系统时钟

reg 	i_sys_clk		;
reg 	i_rst_n        ;
reg 	i_time_1ms_vld ;

reg		[11:0]	v_value;

wire 	o_dac_syn   ;
wire 	o_dac_sclk  ;
wire 	o_dac_din   ;
wire 	o_dac_load  ;
wire 	o_dac_clr   ;


reg	[31:0]cnt;

always@(posedge i_sys_clk)
begin
	if(!i_rst_n)
		cnt <= 0;
	else if(cnt >= 99)
		cnt <= 0;
	else
		cnt <= cnt+1;	
end

always@(posedge i_sys_clk)
begin
	if(!i_rst_n)
		i_time_1ms_vld <= 0;
	else if(cnt >= 99)
		i_time_1ms_vld <= 1;
	else
		i_time_1ms_vld <= 0;
end


	// 100MHz时钟生成
initial begin
    i_sys_clk = 1'b0;
    forever #(SYS_CLK_PERIOD/2) i_sys_clk = ~i_sys_clk;
end

initial begin
    i_rst_n       	= 1'b0;
	v_value 		=12'h000;

    #(SYS_CLK_PERIOD * 8);
    i_rst_n = 1'b1;
    #(SYS_CLK_PERIOD * 20);

	#6000;
	v_value 		=12'h568;
	#6000;
	v_value 		=12'h18F;
	#6000;
end
	
	
	dac_top dac_top_u0( 
		.i_sys_clk       (i_sys_clk		)
		,.i_rst_n        (i_rst_n       )
		,.i_time_1ms_vld (i_time_1ms_vld)
		,.i_time_1s_vld  ( 				)
		,.v_value        (v_value       )
		,.o_dac_syn      (o_dac_syn     )
		,.o_dac_sclk     (o_dac_sclk    )
		,.o_dac_din      (o_dac_din     )
		,.i_dac_dout     (    			)
		,.o_dac_load     (o_dac_load    )
		,.o_dac_clr      (o_dac_clr     )
	);

endmodule