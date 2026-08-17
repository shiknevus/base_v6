`timescale 1ns / 1ps

module tb_spi_module;
localparam TRANSACTION_WIDTH = 24;
localparam CPOL              = 1;
localparam CPHA              = 0;
localparam SYS_CLK_PERIOD    = 10;    //100MHz系统时钟

reg                          i_sys_clk;
reg                          i_rst_n;
reg [TRANSACTION_WIDTH-1:0]  iv_tx_data;
reg                          i_tx_data_vld;

wire [TRANSACTION_WIDTH-1:0] ov_rx_data;
wire                         o_trans_done;
wire                         spi_busy;

wire                         o_spi_cs_n;
wire                         o_spi_clk;
wire                         o_spi_mosi;
wire                          i_spi_miso;


spi_module#(
    .P_DATA_WIDTH      	(TRANSACTION_WIDTH)
    ,.P_CPOL            (1)
    ,.P_CPHL            (0)
	,.P_DIV_NUM			(10)
)spi_module_u0(                  
   .i_clk               (i_sys_clk)
   ,.i_rst              (!i_rst_n)
   ,.o_spi_clk          (o_spi_clk)
   ,.o_spi_csn          (o_spi_cs_n)
   ,.o_spi_mosi         (o_spi_mosi)
   ,.i_spi_miso         (i_spi_miso)
   ,.i_tx_da       		(iv_tx_data)
   ,.i_tx_vld     		(i_tx_data_vld)	
   ,.o_spi_busy			(spi_busy)
   ,.o_rx_da		    (ov_rx_data)
   ,.o_rx_vld           (o_trans_done)
);

// 100MHz时钟生成
initial begin
    i_sys_clk = 1'b0;
    forever #(SYS_CLK_PERIOD/2) i_sys_clk = ~i_sys_clk;
end

// 主激励流程
initial begin
    i_rst_n       = 1'b0;
    iv_tx_data    = 'd0;
    i_tx_data_vld = 1'b0;

    #(SYS_CLK_PERIOD * 8);
    i_rst_n = 1'b1;
    $display("==== Reset Released ====");
    #(SYS_CLK_PERIOD * 20);

    // ===================== 第一帧：发送 16'h66F8 =====================
    wait(!spi_busy);
	#6000;
	iv_tx_data    = 24'h6688F0;
	#(SYS_CLK_PERIOD * 20);
	
	@(posedge i_sys_clk);
    i_tx_data_vld = 1'b1;
    #(SYS_CLK_PERIOD+0.2);
    i_tx_data_vld = 1'b0;

    wait(o_trans_done);
    #(SYS_CLK_PERIOD * 30);

    // ===================== 第二帧：发送 16'h0000，同时从机送出 88A6 =====================
    wait(!spi_busy);
	
	iv_tx_data    = 24'h55A5F0;
	#(SYS_CLK_PERIOD * 20);
	
	@(posedge i_sys_clk);
    i_tx_data_vld = 1'b1;
    #(SYS_CLK_PERIOD+0.2);
    i_tx_data_vld = 1'b0;

    wait(o_trans_done);

    #(SYS_CLK_PERIOD * 100);
end

	assign	i_spi_miso = o_spi_mosi;
	
endmodule