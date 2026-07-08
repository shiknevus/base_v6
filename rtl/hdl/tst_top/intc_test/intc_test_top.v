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
module intc_test_top
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
)
(
     input                              clk
    ,input                              reset
    
    ,output reg     [1023:0]            comp_irq
    
    ,input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,input  wire                        ps_reg_we
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,input  wire                        ps_reg_re
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,output wire                        ps_reg_rd_vld
    ,output wire    [PS_REG_DWIDTH-1:0] ps_reg_rd_dat
);

    localparam  STM_IDLE                =   'd0;
    localparam  STM_WAIT_INTC_TYPE      =   'd1;
    localparam  STM_GEN_INTC            =   'd2;
    localparam  STM_WAIT_INTC_ACK       =   'd3;
    localparam  STM_END                 =   'd27;

    reg     [5:0]               wk_state    =   STM_IDLE;
    reg     [31:0]              wk_cnt      =   'd0;
    reg                         wk_cnt_done;
    wire                        intc_test_cfg_en;
    wire                        intc_ack_vld;
    wire    [31:0]              intc_ack_dat;
    wire                        ps_cfg_intc_type_vld;
    wire    [31:0]              ps_cfg_intc_type_dat;
    wire    [31:0]              intc_test_type;
    intc_test_cfg
    #(
         .REG_SPACE_BIAS    (REG_SPACE_BIAS )
        ,.REG_SPACE_SIZE    (REG_SPACE_SIZE )
        ,.PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
    )
    intc_test_cfg_u
    (
         .ps_reg_clk        (ps_reg_clk     )
        ,.ps_reg_reset      (ps_reg_reset   )
        ,.ps_reg_we         (ps_reg_we      )
        ,.ps_reg_addr       (ps_reg_addr    )
        ,.ps_reg_wr_dat     (ps_reg_wr_dat  )
        ,.ps_reg_re         (ps_reg_re      )
        ,.ps_reg_rd_addr    (ps_reg_rd_addr )
        ,.ps_reg_rd_vld     (ps_reg_rd_vld  )
        ,.ps_reg_rd_dat     (ps_reg_rd_dat  )
        
        ,.intc_test_cfg_en      (intc_test_cfg_en    )
        ,.intc_ack_vld          (intc_ack_vld        )
        ,.intc_ack_dat          (intc_ack_dat        )
        ,.ps_cfg_intc_type_vld  (ps_cfg_intc_type_vld)
        ,.ps_cfg_intc_type_dat  (ps_cfg_intc_type_dat)
        ,.intc_test_type        (intc_test_type      )
    );

    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(intc_test_cfg_en)begin
                        wk_state    <=  STM_WAIT_INTC_TYPE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_INTC_TYPE:begin
                    if(ps_cfg_intc_type_vld)begin
                        wk_state    <=  STM_GEN_INTC;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_GEN_INTC:begin
                    if(wk_cnt_done)begin
                        wk_state    <=  STM_WAIT_INTC_ACK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_INTC_ACK:begin
                    if(intc_ack_vld & (intc_ack_dat == ps_cfg_intc_type_dat))begin
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_END:begin
                    wk_state    <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_INTC:begin
                wk_cnt  <=  wk_cnt + 'd1;
            end
            default:begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @( * )begin
        case(wk_state)
            STM_GEN_INTC:begin
                wk_cnt_done <=  (wk_cnt == 100) ? 'd1 : 'd0;
            end
            default:begin
                wk_cnt_done <=  'd0;
            end
        endcase
    end

    localparam  INTC_NUM    =   1024;
    genvar j;
    generate
        for (j=0; j < INTC_NUM; j=j+1)
        begin: INTC_
            always @(posedge clk)begin
                case(wk_state)
                    STM_GEN_INTC:begin
                        comp_irq[j] <=  'd1;
                    end
                    STM_END:begin
                        comp_irq[j] <=  'd0;
                    end
                endcase
            end
        end
    endgenerate

endmodule
