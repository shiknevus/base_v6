//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sun Jun 28 18:17:39 2020
//Host        : ZK-YF-100 running 64-bit major release  (build 9200)
//Command     : generate_target mststa_mpsoc_wrapper.bd
//Design      : mststa_mpsoc_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module mststa_mpsoc_wrapper
   (AXI_GPIO_tri_io,
    GPIO_tri_io,
    O_INTR_IRQ,
    PLCFG_M_AXI_araddr,
    PLCFG_M_AXI_arprot,
    PLCFG_M_AXI_arready,
    PLCFG_M_AXI_arvalid,
    PLCFG_M_AXI_awaddr,
    PLCFG_M_AXI_awprot,
    PLCFG_M_AXI_awready,
    PLCFG_M_AXI_awvalid,
    PLCFG_M_AXI_bready,
    PLCFG_M_AXI_bresp,
    PLCFG_M_AXI_bvalid,
    PLCFG_M_AXI_rdata,
    PLCFG_M_AXI_rready,
    PLCFG_M_AXI_rresp,
    PLCFG_M_AXI_rvalid,
    PLCFG_M_AXI_wdata,
    PLCFG_M_AXI_wready,
    PLCFG_M_AXI_wstrb,
    PLCFG_M_AXI_wvalid,
    PLCLK,
    PLRESETN,
    RX_BRAM_PORTB_addr,
    RX_BRAM_PORTB_clk,
    RX_BRAM_PORTB_din,
    RX_BRAM_PORTB_dout,
    RX_BRAM_PORTB_en,
    RX_BRAM_PORTB_rst,
    RX_BRAM_PORTB_we,
    TX_BRAM_PORTB_addr,
    TX_BRAM_PORTB_clk,
    TX_BRAM_PORTB_din,
    TX_BRAM_PORTB_dout,
    TX_BRAM_PORTB_en,
    TX_BRAM_PORTB_rst,
    TX_BRAM_PORTB_we,
    UART_0_rxd,
    UART_0_txd,
    intr_0,
    pl_ps_irq);
  inout [0:0]AXI_GPIO_tri_io;
  inout [7:0]GPIO_tri_io;
  input [127:0]O_INTR_IRQ;
  output [31:0]PLCFG_M_AXI_araddr;
  output [2:0]PLCFG_M_AXI_arprot;
  input PLCFG_M_AXI_arready;
  output PLCFG_M_AXI_arvalid;
  output [31:0]PLCFG_M_AXI_awaddr;
  output [2:0]PLCFG_M_AXI_awprot;
  input PLCFG_M_AXI_awready;
  output PLCFG_M_AXI_awvalid;
  output PLCFG_M_AXI_bready;
  input [1:0]PLCFG_M_AXI_bresp;
  input PLCFG_M_AXI_bvalid;
  input [31:0]PLCFG_M_AXI_rdata;
  output PLCFG_M_AXI_rready;
  input [1:0]PLCFG_M_AXI_rresp;
  input PLCFG_M_AXI_rvalid;
  output [31:0]PLCFG_M_AXI_wdata;
  input PLCFG_M_AXI_wready;
  output [3:0]PLCFG_M_AXI_wstrb;
  output PLCFG_M_AXI_wvalid;
  output PLCLK;
  output PLRESETN;
  input [31:0]RX_BRAM_PORTB_addr;
  input RX_BRAM_PORTB_clk;
  input [31:0]RX_BRAM_PORTB_din;
  output [31:0]RX_BRAM_PORTB_dout;
  input RX_BRAM_PORTB_en;
  input RX_BRAM_PORTB_rst;
  input [3:0]RX_BRAM_PORTB_we;
  input [31:0]TX_BRAM_PORTB_addr;
  input TX_BRAM_PORTB_clk;
  input [31:0]TX_BRAM_PORTB_din;
  output [31:0]TX_BRAM_PORTB_dout;
  input TX_BRAM_PORTB_en;
  input TX_BRAM_PORTB_rst;
  input [3:0]TX_BRAM_PORTB_we;
  input UART_0_rxd;
  output UART_0_txd;
  input [6:0]intr_0;
  input [0:0]pl_ps_irq;

  wire [0:0]AXI_GPIO_tri_i_0;
  wire [0:0]AXI_GPIO_tri_io_0;
  wire [0:0]AXI_GPIO_tri_o_0;
  wire [0:0]AXI_GPIO_tri_t_0;
  wire [0:0]GPIO_tri_i_0;
  wire [1:1]GPIO_tri_i_1;
  wire [2:2]GPIO_tri_i_2;
  wire [3:3]GPIO_tri_i_3;
  wire [4:4]GPIO_tri_i_4;
  wire [5:5]GPIO_tri_i_5;
  wire [6:6]GPIO_tri_i_6;
  wire [7:7]GPIO_tri_i_7;
  wire [0:0]GPIO_tri_io_0;
  wire [1:1]GPIO_tri_io_1;
  wire [2:2]GPIO_tri_io_2;
  wire [3:3]GPIO_tri_io_3;
  wire [4:4]GPIO_tri_io_4;
  wire [5:5]GPIO_tri_io_5;
  wire [6:6]GPIO_tri_io_6;
  wire [7:7]GPIO_tri_io_7;
  wire [0:0]GPIO_tri_o_0;
  wire [1:1]GPIO_tri_o_1;
  wire [2:2]GPIO_tri_o_2;
  wire [3:3]GPIO_tri_o_3;
  wire [4:4]GPIO_tri_o_4;
  wire [5:5]GPIO_tri_o_5;
  wire [6:6]GPIO_tri_o_6;
  wire [7:7]GPIO_tri_o_7;
  wire [0:0]GPIO_tri_t_0;
  wire [1:1]GPIO_tri_t_1;
  wire [2:2]GPIO_tri_t_2;
  wire [3:3]GPIO_tri_t_3;
  wire [4:4]GPIO_tri_t_4;
  wire [5:5]GPIO_tri_t_5;
  wire [6:6]GPIO_tri_t_6;
  wire [7:7]GPIO_tri_t_7;
  wire [127:0]O_INTR_IRQ;
  wire [31:0]PLCFG_M_AXI_araddr;
  wire [2:0]PLCFG_M_AXI_arprot;
  wire PLCFG_M_AXI_arready;
  wire PLCFG_M_AXI_arvalid;
  wire [31:0]PLCFG_M_AXI_awaddr;
  wire [2:0]PLCFG_M_AXI_awprot;
  wire PLCFG_M_AXI_awready;
  wire PLCFG_M_AXI_awvalid;
  wire PLCFG_M_AXI_bready;
  wire [1:0]PLCFG_M_AXI_bresp;
  wire PLCFG_M_AXI_bvalid;
  wire [31:0]PLCFG_M_AXI_rdata;
  wire PLCFG_M_AXI_rready;
  wire [1:0]PLCFG_M_AXI_rresp;
  wire PLCFG_M_AXI_rvalid;
  wire [31:0]PLCFG_M_AXI_wdata;
  wire PLCFG_M_AXI_wready;
  wire [3:0]PLCFG_M_AXI_wstrb;
  wire PLCFG_M_AXI_wvalid;
  wire PLCLK;
  wire PLRESETN;
  wire [31:0]RX_BRAM_PORTB_addr;
  wire RX_BRAM_PORTB_clk;
  wire [31:0]RX_BRAM_PORTB_din;
  wire [31:0]RX_BRAM_PORTB_dout;
  wire RX_BRAM_PORTB_en;
  wire RX_BRAM_PORTB_rst;
  wire [3:0]RX_BRAM_PORTB_we;
  wire [31:0]TX_BRAM_PORTB_addr;
  wire TX_BRAM_PORTB_clk;
  wire [31:0]TX_BRAM_PORTB_din;
  wire [31:0]TX_BRAM_PORTB_dout;
  wire TX_BRAM_PORTB_en;
  wire TX_BRAM_PORTB_rst;
  wire [3:0]TX_BRAM_PORTB_we;
  wire UART_0_rxd;
  wire UART_0_txd;
  wire [6:0]intr_0;
  wire [0:0]pl_ps_irq;

  IOBUF AXI_GPIO_tri_iobuf_0
       (.I(AXI_GPIO_tri_o_0),
        .IO(AXI_GPIO_tri_io[0]),
        .O(AXI_GPIO_tri_i_0),
        .T(AXI_GPIO_tri_t_0));
  IOBUF GPIO_tri_iobuf_0
       (.I(GPIO_tri_o_0),
        .IO(GPIO_tri_io[0]),
        .O(GPIO_tri_i_0),
        .T(GPIO_tri_t_0));
  IOBUF GPIO_tri_iobuf_1
       (.I(GPIO_tri_o_1),
        .IO(GPIO_tri_io[1]),
        .O(GPIO_tri_i_1),
        .T(GPIO_tri_t_1));
  IOBUF GPIO_tri_iobuf_2
       (.I(GPIO_tri_o_2),
        .IO(GPIO_tri_io[2]),
        .O(GPIO_tri_i_2),
        .T(GPIO_tri_t_2));
  IOBUF GPIO_tri_iobuf_3
       (.I(GPIO_tri_o_3),
        .IO(GPIO_tri_io[3]),
        .O(GPIO_tri_i_3),
        .T(GPIO_tri_t_3));
  IOBUF GPIO_tri_iobuf_4
       (.I(GPIO_tri_o_4),
        .IO(GPIO_tri_io[4]),
        .O(GPIO_tri_i_4),
        .T(GPIO_tri_t_4));
  IOBUF GPIO_tri_iobuf_5
       (.I(GPIO_tri_o_5),
        .IO(GPIO_tri_io[5]),
        .O(GPIO_tri_i_5),
        .T(GPIO_tri_t_5));
  IOBUF GPIO_tri_iobuf_6
       (.I(GPIO_tri_o_6),
        .IO(GPIO_tri_io[6]),
        .O(GPIO_tri_i_6),
        .T(GPIO_tri_t_6));
  IOBUF GPIO_tri_iobuf_7
       (.I(GPIO_tri_o_7),
        .IO(GPIO_tri_io[7]),
        .O(GPIO_tri_i_7),
        .T(GPIO_tri_t_7));
  mststa_mpsoc mststa_mpsoc_i
       (.AXI_GPIO_tri_i(AXI_GPIO_tri_i_0),
        .AXI_GPIO_tri_o(AXI_GPIO_tri_o_0),
        .AXI_GPIO_tri_t(AXI_GPIO_tri_t_0),
        .GPIO_tri_i({GPIO_tri_i_7,GPIO_tri_i_6,GPIO_tri_i_5,GPIO_tri_i_4,GPIO_tri_i_3,GPIO_tri_i_2,GPIO_tri_i_1,GPIO_tri_i_0}),
        .GPIO_tri_o({GPIO_tri_o_7,GPIO_tri_o_6,GPIO_tri_o_5,GPIO_tri_o_4,GPIO_tri_o_3,GPIO_tri_o_2,GPIO_tri_o_1,GPIO_tri_o_0}),
        .GPIO_tri_t({GPIO_tri_t_7,GPIO_tri_t_6,GPIO_tri_t_5,GPIO_tri_t_4,GPIO_tri_t_3,GPIO_tri_t_2,GPIO_tri_t_1,GPIO_tri_t_0}),
        .O_INTR_IRQ(O_INTR_IRQ),
        .PLCFG_M_AXI_araddr(PLCFG_M_AXI_araddr),
        .PLCFG_M_AXI_arprot(PLCFG_M_AXI_arprot),
        .PLCFG_M_AXI_arready(PLCFG_M_AXI_arready),
        .PLCFG_M_AXI_arvalid(PLCFG_M_AXI_arvalid),
        .PLCFG_M_AXI_awaddr(PLCFG_M_AXI_awaddr),
        .PLCFG_M_AXI_awprot(PLCFG_M_AXI_awprot),
        .PLCFG_M_AXI_awready(PLCFG_M_AXI_awready),
        .PLCFG_M_AXI_awvalid(PLCFG_M_AXI_awvalid),
        .PLCFG_M_AXI_bready(PLCFG_M_AXI_bready),
        .PLCFG_M_AXI_bresp(PLCFG_M_AXI_bresp),
        .PLCFG_M_AXI_bvalid(PLCFG_M_AXI_bvalid),
        .PLCFG_M_AXI_rdata(PLCFG_M_AXI_rdata),
        .PLCFG_M_AXI_rready(PLCFG_M_AXI_rready),
        .PLCFG_M_AXI_rresp(PLCFG_M_AXI_rresp),
        .PLCFG_M_AXI_rvalid(PLCFG_M_AXI_rvalid),
        .PLCFG_M_AXI_wdata(PLCFG_M_AXI_wdata),
        .PLCFG_M_AXI_wready(PLCFG_M_AXI_wready),
        .PLCFG_M_AXI_wstrb(PLCFG_M_AXI_wstrb),
        .PLCFG_M_AXI_wvalid(PLCFG_M_AXI_wvalid),
        .PLCLK(PLCLK),
        .PLRESETN(PLRESETN),
        .RX_BRAM_PORTB_addr(RX_BRAM_PORTB_addr),
        .RX_BRAM_PORTB_clk(RX_BRAM_PORTB_clk),
        .RX_BRAM_PORTB_din(RX_BRAM_PORTB_din),
        .RX_BRAM_PORTB_dout(RX_BRAM_PORTB_dout),
        .RX_BRAM_PORTB_en(RX_BRAM_PORTB_en),
        .RX_BRAM_PORTB_rst(RX_BRAM_PORTB_rst),
        .RX_BRAM_PORTB_we(RX_BRAM_PORTB_we),
        .TX_BRAM_PORTB_addr(TX_BRAM_PORTB_addr),
        .TX_BRAM_PORTB_clk(TX_BRAM_PORTB_clk),
        .TX_BRAM_PORTB_din(TX_BRAM_PORTB_din),
        .TX_BRAM_PORTB_dout(TX_BRAM_PORTB_dout),
        .TX_BRAM_PORTB_en(TX_BRAM_PORTB_en),
        .TX_BRAM_PORTB_rst(TX_BRAM_PORTB_rst),
        .TX_BRAM_PORTB_we(TX_BRAM_PORTB_we),
        .UART_0_rxd(UART_0_rxd),
        .UART_0_txd(UART_0_txd),
        .intr_0(intr_0),
        .pl_ps_irq(pl_ps_irq));
endmodule
