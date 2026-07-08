/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//    
//
//Description:
//
/////////////////////////////////////////////////////////////////
module mst_app_cfg
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
)
(
     input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,input  wire                        ps_reg_we
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,input  wire                        ps_reg_re
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,output reg                         ps_reg_rd_vld
    ,output reg     [PS_REG_DWIDTH-1:0] ps_reg_rd_dat

    ,input  wire                        prot_clk
    ,input  wire    [3:0]               slv_id_we
    ,input  wire    [15:0]              slv_id_addr
    ,input  wire    [31:0]              slv_id_din

    ,input                              link_success
    ,input  wire                        loop_link_success
    ,input  wire                        app_err_flag        //the error type of slave station is valid
    ,input  wire    [15:0]              app_err_type        //the error type of slave station
    ,input  wire    [15:0]              hb_err_slvsta       //indicate the index of the error station //指示产生链接错误的从站
    ,input  wire    [7:0]               slv_sta_num     //this signals only update during first initial datagram.It indicate the number of slave station

    ,output wire                        ps_tst_trsf_port
    ,output wire                        ps_trsf_port_en
    ,input  wire    [31:0]              stat_rslt
    ,output wire                        ps_loopback_flag
    ,output reg                         ps_tx_req
    ,output reg                         ps_rd_depot_flag
    ,output reg                         opt_intf_init_en
);
    
    reg     ps_reg_re_d1;
    reg     ps_reg_re_d2;
    wire    wr_space_select;
    wire    rd_space_select;
    wire    [PS_REG_AWIDTH-1:0] wr_reg_addr;
    wire    [PS_REG_AWIDTH-1:0] rd_reg_addr;
    reg     [PS_REG_AWIDTH-1:0] rd_reg_addr_d1;
    reg     [PS_REG_AWIDTH-1:0] rd_reg_addr_d2;
    wire                        link_status;
    assign  wr_space_select =   ((ps_reg_addr >= REG_SPACE_BIAS) & (ps_reg_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'd1 : 1'd0;
    assign  rd_space_select =   ((ps_reg_rd_addr >= REG_SPACE_BIAS) & (ps_reg_rd_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'd1 : 1'd0;
    assign  wr_reg_addr     =   ps_reg_addr     - REG_SPACE_BIAS;
    assign  rd_reg_addr     =   ps_reg_rd_addr  -   REG_SPACE_BIAS;
/////////////////////////////////////////
    (* MARK_DEBUG="true" *)reg [31:0]  mst_app_wk_mode;
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            mst_app_wk_mode <=  'd0;
        end else if((wr_reg_addr == `MST_APP_MODE_ADDR) & ps_reg_we)begin
            mst_app_wk_mode <=  ps_reg_wr_dat;
        end else begin
            mst_app_wk_mode <=  mst_app_wk_mode;
        end
    end
    assign  ps_loopback_flag    =   mst_app_wk_mode[31];
    assign  ps_tst_trsf_port    =   mst_app_wk_mode[16];
    assign  ps_trsf_port_en     =   mst_app_wk_mode[0];
    
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ps_tx_req   <=  'd0;
        end else if((wr_reg_addr == `PS_TX_REQ_ADDR) & ps_reg_we)begin
            ps_tx_req   <=  ps_reg_wr_dat[0];
        end else begin
            ps_tx_req   <=  ps_tx_req;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            opt_intf_init_en   <=  'd0;
        end else if((wr_reg_addr == `OPT_INTF_INIT_EN_ADDR) & ps_reg_we)begin
            opt_intf_init_en   <=  ps_reg_wr_dat[0];
        end else begin
            opt_intf_init_en   <=  opt_intf_init_en;
        end
    end
    
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ps_rd_depot_flag    <=  'd0;
        end else if((wr_reg_addr == `PS_RD_DEPOT_FLAG_ADDR) & ps_reg_we)begin
            ps_rd_depot_flag    <=  ps_reg_wr_dat[0];
        end else begin
            ps_rd_depot_flag    <=  ps_rd_depot_flag;
        end
    end
    
    localparam  RAM_DWIDTH  =   32;
    localparam  RAM_DEPTH   =   512;
    localparam  RAM_TYPE    =   "BLOCK_SDP";
    reg [15:0]  id_buf_rd_addr = 0;
    wire[31:0]  id_buf_rd_dat;
    gen_ram
    #(
         .RAM_DWIDTH  (RAM_DWIDTH   )
        ,.RAM_DEPTH   (RAM_DEPTH    )
        ,.TYPE        (RAM_TYPE     )
    )
        id_buf_u
        (
             .clka      (prot_clk   )
            ,.wea       (&slv_id_we )
            ,.addra     (slv_id_addr)
            ,.dina      (slv_id_din )
            ,.clkb      (ps_reg_clk )
            ,.enb       (1          )
            ,.addrb     (id_buf_rd_addr[15:4])
            ,.doutb     (id_buf_rd_dat  )
        );

    always @( * )begin
        id_buf_rd_addr  <=  rd_reg_addr - `CACHE_SLV_ID_BIAS_ADDR;
    end

/////////////////////////////////////////
    
    always @(posedge ps_reg_clk)begin
        ps_reg_re_d1    <=  ps_reg_re & rd_space_select;
        ps_reg_re_d2    <=  ps_reg_re_d1;
        ps_reg_rd_vld   <=  ps_reg_re_d2;
    end
    
    always @(posedge ps_reg_clk)begin
        rd_reg_addr_d1  <=  rd_reg_addr;
        rd_reg_addr_d2  <=  rd_reg_addr_d1;
    end
    
    assign  link_status =   (slv_sta_num !== 0) ? 1 : 0;
    always @(posedge ps_reg_clk) begin
        // Address decoding for reading registers
        case ( rd_reg_addr_d2[PS_REG_AWIDTH-1:0] )
            `SLV_STA_NUM_ADDR:  ps_reg_rd_dat   <=  slv_sta_num;
//            `LINK_STATUS_ADDR:  ps_reg_rd_dat   <=  {8'd0,app_err_type[7:0],hb_err_slvsta[7:0],{6'd0,link_success,loop_link_success}};
            `LINK_STATUS_ADDR:  ps_reg_rd_dat   <=  {8'd0,app_err_type[7:0],hb_err_slvsta[7:0],{6'd0,link_status,link_status}};
            `STAT_TIME_ADDR  :  ps_reg_rd_dat   <=  stat_rslt;
            default : ps_reg_rd_dat <= id_buf_rd_dat;
        endcase
    end
    
endmodule