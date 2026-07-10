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
module intc_test_cfg
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
    
    ,output reg                         intc_test_cfg_en
    ,output reg                         intc_ack_vld
    ,output reg     [31:0]              intc_ack_dat
    ,output reg                         ps_cfg_intc_type_vld
    ,output reg     [31:0]              ps_cfg_intc_type_dat
    ,input          [31:0]              intc_test_type
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
            intc_test_cfg_en    <=  'd0;
        end else if((wr_reg_addr == `INTC_TEST_EN_ADDR) & ps_reg_we)begin
            intc_test_cfg_en    <=  ps_reg_wr_dat;
        end else begin
            intc_test_cfg_en    <=  intc_test_cfg_en;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            intc_ack_vld <= 'd0;
            intc_ack_dat <=  'd0;
        end else if((wr_reg_addr == `INTC_TEST_ACK_ADDR) & ps_reg_we)begin
            intc_ack_vld <=  'd1;
            intc_ack_dat <=  ps_reg_wr_dat;
        end else begin
            intc_ack_vld <=  'd0;
            intc_ack_dat <=  intc_ack_dat;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ps_cfg_intc_type_vld    <= 'd0;
            ps_cfg_intc_type_dat    <=  'd0;
        end else if((wr_reg_addr == `INTC_TEST_ACK_ADDR) & ps_reg_we)begin
            ps_cfg_intc_type_vld    <=  'd1;
            ps_cfg_intc_type_dat    <=  ps_reg_wr_dat;
        end else begin
            ps_cfg_intc_type_vld    <=  'd0;
            ps_cfg_intc_type_dat    <=  ps_cfg_intc_type_dat;
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
            `INTC_TEST_TYPE_ADDR:   ps_reg_rd_dat <= intc_test_type;
            default : ps_reg_rd_dat <= 0;
        endcase
    end
    
endmodule