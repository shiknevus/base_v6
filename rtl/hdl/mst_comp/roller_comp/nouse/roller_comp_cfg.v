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
//  master station rs232 components
/////////////////////////////////////////////////////////////////
module roller_comp_cfg
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
    ,parameter  CUR_LOCATION    =   14'd1000
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
    
    ,output reg     [31:0]              comp_wk_para
    ,output reg     [31:0]              beh_dly_time
    ,output reg                         int_ack_vld
    ,output reg     [7:0]               int_ack_dat
    ,output reg                         path_msg_vld
    ,output reg     [13:0]              path_msg_dat
    ,input  wire    [7:0]               comp_irq_type
    ,input  wire    [15:0]              cur_token_dat
    ,output reg                         ps_cfg_token_vld
    ,output reg     [31:0]              ps_cfg_token_dat
    
    ,input  wire    [5:0]               wk_state
);
    
    reg     ps_reg_re_d1;
    reg     ps_reg_re_d2;
    wire    wr_space_select;
    wire    rd_space_select;
    wire    [PS_REG_AWIDTH-1:0] wr_reg_addr;
    wire    [PS_REG_AWIDTH-1:0] rd_reg_addr;
    reg     [PS_REG_AWIDTH-1:0] rd_reg_addr_d1;
    reg     [PS_REG_AWIDTH-1:0] rd_reg_addr_d2;
    assign  wr_space_select =   ((ps_reg_addr >= REG_SPACE_BIAS) & (ps_reg_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'd1 : 1'd0;
    assign  rd_space_select =   ((ps_reg_rd_addr >= REG_SPACE_BIAS) & (ps_reg_rd_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'd1 : 1'd0;
    assign  wr_reg_addr     =   ps_reg_addr     - REG_SPACE_BIAS;
    assign  rd_reg_addr     =   ps_reg_rd_addr  -   REG_SPACE_BIAS;
    
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            path_msg_vld  <=  1'b0;
            path_msg_dat  <=  'd0;
            ps_cfg_token_vld  <=  1'b0;
            ps_cfg_token_dat  <=  'd0;
        end else if((wr_reg_addr == `PATH_MSG_ADDR) & ps_reg_we)begin
            path_msg_vld  <=  1'b1;
            path_msg_dat  <=  ps_reg_wr_dat[31:18];
            ps_cfg_token_vld  <=  1'b1;
            ps_cfg_token_dat  <=  {18'd0, ps_reg_wr_dat[17:4]};
        end else begin
            path_msg_vld  <=  1'b0;
            path_msg_dat  <=  path_msg_dat;
            ps_cfg_token_vld  <=  1'b0;
            ps_cfg_token_dat  <=  ps_cfg_token_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            comp_wk_para  <=  'd0;
        end else if((wr_reg_addr == `COMP_WK_EN_ADDR) & ps_reg_we)begin
            comp_wk_para  <=  ps_reg_wr_dat;
        end else begin
            comp_wk_para  <=  comp_wk_para;
        end
    end
    
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            beh_dly_time  <=  'd0;
        end else if((wr_reg_addr == `BEH_DLY_TIME) & ps_reg_we)begin
            beh_dly_time  <=  ps_reg_wr_dat;
        end else begin
            beh_dly_time  <=  beh_dly_time;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            int_ack_vld <= 1'b0;
            int_ack_dat <=  'd0;
        end else if((wr_reg_addr == `INT_ACK_ADDR) & ps_reg_we)begin
            int_ack_vld <=  1'b1;
            int_ack_dat <=  ps_reg_wr_dat;
        end else begin
            int_ack_vld <=  1'b0;
            int_ack_dat <=  int_ack_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        ps_reg_re_d1    <=  ps_reg_re & rd_space_select;
        ps_reg_re_d2    <=  ps_reg_re_d1;
        ps_reg_rd_vld   <=  ps_reg_re_d2;
    end
    
    always @(posedge ps_reg_clk)begin
        rd_reg_addr_d1  <=  rd_reg_addr;
        rd_reg_addr_d2  <=  rd_reg_addr_d1;
    end
    
    always @(posedge ps_reg_clk) begin
        // Address decoding for reading registers
        case ( rd_reg_addr_d2[PS_REG_AWIDTH-1:0] )
            `INT_TYPE_ADDR: ps_reg_rd_dat   <=  {8'd0, cur_token_dat, comp_irq_type};
            `CUR_COMP_ID: ps_reg_rd_dat   <=  {CUR_LOCATION, CUR_LOCATION, 4'd1};
            `COMP_WK_STATE_ADDR: ps_reg_rd_dat <=  {26'd0, wk_state};
            `RS232_START_BIAS: ps_reg_rd_dat <=  32'hb001_48a8;
            default : ps_reg_rd_dat <= 0;
        endcase
    end
    
endmodule