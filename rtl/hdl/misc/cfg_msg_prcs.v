
`timescale 1 ns / 1 ps

module cfg_msg_prcs #
(
    parameter integer ADDR_WIDTH    = 7-1,
    parameter integer DATA_WIDTH    = 32
)
(
     input  wire                        clk
    ,input  wire                        reset
    ,input  wire                        slv_reg_we
    ,input  wire    [ADDR_WIDTH-1:0]    slv_reg_addr
    ,input  wire    [DATA_WIDTH-1:0]    slv_reg_wr_dat
    ,input  wire                        slv_reg_re
    ,input  wire    [ADDR_WIDTH-1:0]    slv_reg_rd_addr
    ,output reg                         slv_reg_rd_vld
    ,output reg     [DATA_WIDTH-1:0]    slv_reg_rd_dat

/////////////
    ,output wire                        ps_reg_clk
    ,output wire                        ps_reg_reset
    ,output wire                        ps_reg_we
    ,output wire    [ADDR_WIDTH-1:0]    ps_reg_addr
    ,output wire    [DATA_WIDTH-1:0]    ps_reg_wr_dat
    ,output wire                        ps_reg_re
    ,output wire    [ADDR_WIDTH-1:0]    ps_reg_rd_addr
    ,input  wire                        ps_reg_rd_vld
    ,input  wire    [DATA_WIDTH-1:0]    ps_reg_rd_dat

);

    always @( * ) begin
        // Address decoding for reading registers
        case ( slv_reg_rd_addr[ADDR_WIDTH-1:0] )
            default : slv_reg_rd_dat <= ps_reg_rd_dat;
        endcase
    end

    reg slv_reg_re_d1;
    reg slv_reg_re_d2;
    reg slv_reg_re_d3;
    always @(posedge clk)begin
        slv_reg_re_d1   <=  slv_reg_re;
        slv_reg_re_d2   <=  slv_reg_re_d1;
        slv_reg_re_d3   <=  slv_reg_re_d2;
//        slv_reg_rd_vld  <=  slv_reg_re_d3 | ps_reg_rd_vld;
        slv_reg_rd_vld  <=  ps_reg_rd_vld;
    end
////////////////////////////////////////////
    assign  ps_reg_clk      =   clk;
    assign  ps_reg_reset    =   reset;
    assign  ps_reg_we       =   slv_reg_we;
    assign  ps_reg_addr     =   slv_reg_addr;
    assign  ps_reg_wr_dat   =   slv_reg_wr_dat;
    assign  ps_reg_re       =   slv_reg_re;
    assign  ps_reg_rd_addr  =   slv_reg_rd_addr;
    
endmodule
