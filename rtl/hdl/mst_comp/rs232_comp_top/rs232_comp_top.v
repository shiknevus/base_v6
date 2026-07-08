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
module rs232_comp_top
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input                              clk
    ,input                              reset
    //  ps  configure message
    ,input  wire    [RAM_AWIDTH-1:0]    comp_bias_addr

    //  ps  interrupt flag
    ,output reg                         comp_irq
    ,input                              comp_ack
    
    // to master app
    ,input  wire                        slv_cfg_msg_rden
    ,input  wire    [RAM_AWIDTH-1:0]    slv_cfg_msg_addr
    ,output reg     [RAM_DWIDTH-1:0]    slv_cfg_msg_dat

    ,output reg                         ps_rd_depot_flag
    ,input  wire    [3:0]               slv_sta_msg_vld     //slave station status message
    ,input  wire    [RAM_AWIDTH-1:0]    slv_sta_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    slv_sta_msg_dat
    ,output reg                         tst_sig
);

    localparam  STM_IDLE        = 'd0;
    localparam  STM_GEN_IRQ     = 'd2;
    localparam  STM_WAIT_PS_ACK = 'd3;
    localparam  STM_END         = 'd12;
    reg [3:0]   wk_state    =   STM_IDLE;

    reg [31:0]  pre_uuid        =   'd0;
    reg [31:0]  cur_uuid        =   'd0;
    reg [31:0]  cur_uuid_d1     =   'd0;
    reg         comp_ack_d1     =   'd0;
    reg         comp_ack_d2     =   'd0;
    reg [7:0]   wk_cnt          =   'd0;
    reg         wk_cnt_done;
    always @(posedge clk)begin
        if(reset)begin
            cur_uuid    <=  'd0;
            pre_uuid    <=  'd0;
        end else if(slv_sta_msg_vld & (slv_sta_msg_addr == comp_bias_addr))begin
            cur_uuid    <=  slv_sta_msg_dat;
            pre_uuid    <=  cur_uuid;
        end else begin
            cur_uuid    <=  cur_uuid;
            pre_uuid    <=  pre_uuid;
        end
    end

    always @(posedge clk)begin
        cur_uuid_d1 <=  cur_uuid;
    end

    always @(posedge clk)begin
        comp_ack_d1 <=  comp_ack;
        comp_ack_d2 <=  comp_ack_d1;
    end

    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(cur_uuid_d1 != cur_uuid) begin
                        wk_state  <=  STM_GEN_IRQ;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_IRQ:begin
                    if(wk_cnt_done)begin
                        wk_state  <=  STM_WAIT_PS_ACK;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_WAIT_PS_ACK:begin
                    if(comp_ack_d2)begin
                        wk_state  <=  STM_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_END:begin
                    wk_state  <=  STM_IDLE;
                end
                default: begin
                    wk_state  <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_GEN_IRQ:begin
                wk_cnt  <=  wk_cnt  +   'd1;
            end
            default: begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @( * ) begin
        case(wk_state)
            STM_GEN_IRQ:begin
                wk_cnt_done <=  (wk_cnt == 10) ? 1'b1 : 1'b0;
            end
            default: begin
                wk_cnt_done <=  'd0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_GEN_IRQ:begin
                comp_irq    <=  'd1;
            end
            default: begin
                comp_irq    <=  'd0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                ps_rd_depot_flag    <=  'd0;
            end
            STM_GEN_IRQ:begin
                ps_rd_depot_flag    <=  'd1;
            end
            default: begin
                ps_rd_depot_flag    <=  ps_rd_depot_flag;
            end
        endcase
    end

////////////////////////
    reg [RAM_AWIDTH-1:0]    slv_cfg_msg_addr_d1;
    always @(posedge clk)begin
        slv_cfg_msg_addr_d1 <=  slv_cfg_msg_addr;
    end
    
    always @(posedge clk)begin
        slv_cfg_msg_dat <=  slv_cfg_msg_addr_d1;
    end
endmodule