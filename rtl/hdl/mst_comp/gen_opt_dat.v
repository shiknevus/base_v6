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
module gen_opt_dat
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
)
(
     input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,(* MARK_DEBUG="true" *)input  wire                        ps_reg_we
    ,(* MARK_DEBUG="true" *)input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,(* MARK_DEBUG="true" *)input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,(* MARK_DEBUG="true" *)input  wire                        ps_reg_re
    ,(* MARK_DEBUG="true" *)input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,(* MARK_DEBUG="true" *)output reg                         ps_reg_rd_vld
    ,(* MARK_DEBUG="true" *)output reg     [PS_REG_DWIDTH-1:0] ps_reg_rd_dat
    
    ,(* MARK_DEBUG="true" *)output reg     [31:0]              slv1st_do_dat
    ,output reg     [31:0]              slv1st_di_dat
    ,(* MARK_DEBUG="true" *)output reg     [31:0]              slv1st_ao_dat
    ,output reg     [31:0]              slv1st_ai_dat

    ,(* MARK_DEBUG="true" *)output reg     [31:0]              slv2nd_do_dat
    ,output reg     [31:0]              slv2nd_di_dat
    ,(* MARK_DEBUG="true" *)output reg     [31:0]              slv2nd_ao_dat
    ,output reg     [31:0]              slv2nd_ai_dat
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
            slv1st_do_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV1ST_DO_DAT_CFG_ADDR) & ps_reg_we)begin
            slv1st_do_dat   <=  ps_reg_wr_dat;
        end else begin
            slv1st_do_dat   <=  slv1st_do_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv1st_di_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV1ST_DI_DAT_CFG_ADDR) & ps_reg_we)begin
            slv1st_di_dat   <=  ps_reg_wr_dat;
        end else begin
            slv1st_di_dat   <=  slv1st_di_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv1st_ao_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV1ST_AO_DAT_CFG_ADDR) & ps_reg_we)begin
            slv1st_ao_dat   <=  ps_reg_wr_dat;
        end else begin
            slv1st_ao_dat   <=  slv1st_ao_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv1st_ai_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV1ST_AI_DAT_CFG_ADDR) & ps_reg_we)begin
            slv1st_ai_dat   <=  ps_reg_wr_dat;
        end else begin
            slv1st_ai_dat   <=  slv1st_ai_dat;
        end
    end
//////////////////////////////////////////
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv2nd_do_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV2ND_DO_DAT_CFG_ADDR) & ps_reg_we)begin
            slv2nd_do_dat   <=  ps_reg_wr_dat;
        end else begin
            slv2nd_do_dat   <=  slv2nd_do_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv2nd_di_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV2ND_DI_DAT_CFG_ADDR) & ps_reg_we)begin
            slv2nd_di_dat   <=  ps_reg_wr_dat;
        end else begin
            slv2nd_di_dat   <=  slv2nd_di_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv2nd_ao_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV2ND_AO_DAT_CFG_ADDR) & ps_reg_we)begin
            slv2nd_ao_dat   <=  ps_reg_wr_dat;
        end else begin
            slv2nd_ao_dat   <=  slv2nd_ao_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            slv2nd_ai_dat   <=  'd0;
        end else if((wr_reg_addr == `SLV2ND_AI_DAT_CFG_ADDR) & ps_reg_we)begin
            slv2nd_ai_dat   <=  ps_reg_wr_dat;
        end else begin
            slv2nd_ai_dat   <=  slv2nd_ai_dat;
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
            default : ps_reg_rd_dat <= 0;
        endcase
    end
    
endmodule