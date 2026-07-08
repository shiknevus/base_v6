
`timescale 1 ns / 1 ps

module ps_cfg_top #
(
    // Users to add parameters here
    parameter integer OPT_MEM_ADDR_BITS = 7-1,
    // User parameters ends
    // Do not modify the parameters beyond this line

    // Parameters of Axi Slave Bus Interface S_AXI
    parameter integer C_S_AXI_DATA_WIDTH    = 32,
    parameter integer C_S_AXI_ADDR_WIDTH    = 9
)
(
    // Users to add ports here
    output wire                             ps_reg_clk,
    output wire                             ps_reg_reset,
    output wire                             ps_reg_we,
    output wire    [OPT_MEM_ADDR_BITS-1:0]  ps_reg_addr,
    output wire    [C_S_AXI_DATA_WIDTH-1:0] ps_reg_wr_dat,
    output wire                             ps_reg_re,
    output wire    [OPT_MEM_ADDR_BITS-1:0]  ps_reg_rd_addr,
    input  wire                             ps_reg_rd_vld,
    input  wire    [C_S_AXI_DATA_WIDTH-1:0] ps_reg_rd_dat,

    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S_AXI
    input wire  s_axi_aclk,
    input wire  s_axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
    input wire [2 : 0] s_axi_awprot,
    input wire  s_axi_awvalid,
    output wire  s_axi_awready,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
    input wire  s_axi_wvalid,
    output wire  s_axi_wready,
    output wire [1 : 0] s_axi_bresp,
    output wire  s_axi_bvalid,
    input wire  s_axi_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
    input wire [2 : 0] s_axi_arprot,
    input wire  s_axi_arvalid,
    output wire  s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
    output wire [1 : 0] s_axi_rresp,
    output wire  s_axi_rvalid,
    input wire  s_axi_rready
);

    wire                                slv_reg_we;
    wire    [OPT_MEM_ADDR_BITS-1:0]     slv_reg_addr;
    wire    [C_S_AXI_DATA_WIDTH-1:0]    slv_reg_wr_dat;
    wire                                slv_reg_re;
    wire    [OPT_MEM_ADDR_BITS-1:0]     slv_reg_rd_addr;
    wire                                slv_reg_rd_vld;
    wire    [C_S_AXI_DATA_WIDTH-1:0]    slv_reg_rd_dat;

// Instantiation of Axi Bus Interface S_AXI
//    axilite_S_AXI # (
    axilite_S_AXI_raw # (
        .OPT_MEM_ADDR_BITS  (OPT_MEM_ADDR_BITS),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) axilite_S_AXI_u (
        .slv_reg_we         (slv_reg_we         ),
        .slv_reg_addr       (slv_reg_addr       ),
        .slv_reg_wr_dat     (slv_reg_wr_dat     ),
        .slv_reg_re         (slv_reg_re         ),
        .slv_reg_rd_addr    (slv_reg_rd_addr    ),
        .slv_reg_rd_vld     (slv_reg_rd_vld     ),
        .slv_reg_rd_dat     (slv_reg_rd_dat     ),

        .S_AXI_ACLK(s_axi_aclk),
        .S_AXI_ARESETN(s_axi_aresetn),
        .S_AXI_AWADDR(s_axi_awaddr),
        .S_AXI_AWPROT(s_axi_awprot),
        .S_AXI_AWVALID(s_axi_awvalid),
        .S_AXI_AWREADY(s_axi_awready),
        .S_AXI_WDATA(s_axi_wdata),
        .S_AXI_WSTRB(s_axi_wstrb),
        .S_AXI_WVALID(s_axi_wvalid),
        .S_AXI_WREADY(s_axi_wready),
        .S_AXI_BRESP(s_axi_bresp),
        .S_AXI_BVALID(s_axi_bvalid),
        .S_AXI_BREADY(s_axi_bready),
        .S_AXI_ARADDR(s_axi_araddr),
        .S_AXI_ARPROT(s_axi_arprot),
        .S_AXI_ARVALID(s_axi_arvalid),
        .S_AXI_ARREADY(s_axi_arready),
        .S_AXI_RDATA(s_axi_rdata),
        .S_AXI_RRESP(s_axi_rresp),
        .S_AXI_RVALID(s_axi_rvalid),
        .S_AXI_RREADY(s_axi_rready)
    );

    // Add user logic here
    cfg_msg_prcs
    #(
         .ADDR_WIDTH    (OPT_MEM_ADDR_BITS  )
        ,.DATA_WIDTH    (C_S_AXI_DATA_WIDTH )
    )
    cfg_msg_prcs_u
    (
         .clk               (s_axi_aclk     )
        ,.reset             (~s_axi_aresetn )
        ,.slv_reg_we        (slv_reg_we     )
        ,.slv_reg_addr      (slv_reg_addr   )
        ,.slv_reg_wr_dat    (slv_reg_wr_dat )
        ,.slv_reg_re        (slv_reg_re     )
        ,.slv_reg_rd_addr   (slv_reg_rd_addr)
        ,.slv_reg_rd_vld    (slv_reg_rd_vld )
        ,.slv_reg_rd_dat    (slv_reg_rd_dat )
        
        ,.ps_reg_clk        (ps_reg_clk     )
        ,.ps_reg_reset      (ps_reg_reset   )
        ,.ps_reg_we         (ps_reg_we      )
        ,.ps_reg_addr       (ps_reg_addr    )
        ,.ps_reg_wr_dat     (ps_reg_wr_dat  )
        ,.ps_reg_re         (ps_reg_re      )
        ,.ps_reg_rd_addr    (ps_reg_rd_addr )
        ,.ps_reg_rd_vld     (ps_reg_rd_vld  )
        ,.ps_reg_rd_dat     (ps_reg_rd_dat  )

    );

// User logic ends
endmodule