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
module roller_comp_v2_auto
#(
     parameter  TOKEN_DWIDTH    =   16
    ,parameter  COMP_TYPE       =   "NORMAL"
)
(
     input                              clk
    ,input                              reset
    ,input  [31:0]                      time_delay
    //driver interface
    ,output reg                         comp_in_start
    ,output reg                         comp_out_start
    ,output reg                         cfg_comp_done
    ,output reg                         cfg_comp_done2
    ,input  wire                        mat_in_place
    ,input  wire                        yzqg_up
    ,input  wire                        comp_error
    ,output reg                         extra_opt_start
    ,input  wire                        extra_opt_done
    ,input  wire                        scan_token_vld

    ,input  wire                        comp_wk_en
    //reg cfg interrupt
    ,output wire                        comp_irq
    ,output wire    [7:0]               comp_irq_type
    
    ,input                              path_msg_vld
    ,input          [13:0]              path_msg_dat
    ,input  wire    [3:0]               extra_msg

    ,input                              int_ack_vld
    ,input          [7:0]               int_ack_dat

    ,output reg     [TOKEN_DWIDTH-1:0]  cur_token_dat
    ,input  wire                        ps_cfg_token_vld
    ,input  wire    [TOKEN_DWIDTH-1:0]  ps_cfg_token_dat
//  components interface
    ,input  wire                        s_token_valid
    ,output reg                         s_token_ready
    ,input  wire    [TOKEN_DWIDTH-1:0]  s_token_data
    ,output reg                         s_token_bvalid
    ,input  wire                        s_token_bready
    ,output reg     [2:0]               s_token_bresp

    ,output reg                         m_token_valid
    ,input  wire                        m_token_ready
    ,output reg     [TOKEN_DWIDTH-1:0]   m_token_data
    ,input  wire                        m_token_bvalid
    ,output reg                         m_token_bready
    ,input  wire    [2:0]               m_token_bresp
//others
    ,output reg     [2:0]               in_chan_seq
    ,input  wire    [2:0]               act_in_chan_num
    ,input  wire    [2:0]               act_out_chan_num
    ,(* MARK_DEBUG="true" *) output reg      [5:0]              wk_state 

);
    localparam  MAX_WAIT_NUM            =   2048;
    localparam  WAIT_PATH_MSG_MAX_TIME  =   2000;      //2000000000
    localparam  Init_time_1ms           =   18'd108297;
    localparam  EXTRA_MSG_CODE          =   4'h0;
    
    localparam  STM_IDLE                =   'd0;
    localparam  STM_IN_CK               =   'd2;    //input behavior check self
    localparam  STM_IN_CKSF_ERR_INT     =   'd3;    //input behavior checkself interrupt
    localparam  STM_WAIT_IRQ_INTERVAL   =   'd5;    //input behavior interrupt
    localparam  STM_JUDGE_UPS_TOKEN     =   'd6;    //judge upstream token
    localparam  STM_GEN_RDY_TO_UPS      =   'd7;    //generate ready to upstream component
    localparam  STM_WAIT_MAT_IN_PLACE   =   'd8;    //Wait for the material to be in place
    localparam  STM_IN_TRSF_SUCCESS     =   'd9;    //Wait for the material to be in place
    localparam  STM_IN_BEH_SUC_INT      =   'd10;    //Wait for the material to be in place
    localparam  STM_IN_TRSF_FAIL        =   'd12;    //Wait for the material to be in place
    localparam  STM_IN_BEH_ERR_INT      =   'd13;    //Wait for the material to be in place
    localparam  STM_START_EXTRA_OPT     =   'd14;
    localparam  STM_FINISH_EXTRA_OPT    =   'd15;
    localparam  STM_OUT_CK              =   'd16;    //Wait for the material to be in place
    localparam  STM_OUT_CKSF_ERR_INT    =   'd17;
    localparam  STM_OUT_CKSF_ERR_IACK   =   'd18;
    localparam  STM_JUDGE_PS_TOKEN      =   'd19;    //judge ps token
    localparam  STM_SEND_DWS_TOKEN      =   'd20;    //send one token to downstream component
    localparam  STM_WAIT_DWS_TOKEN_RESP =   'd21;    //send one token to downstream component
    localparam  STM_DWS_RESP_ERR        =   'd22;    //send one token to downstream component
    localparam  STM_DWS_RESP_ERR_INT    =   'd23;    //send one token to downstream component
    localparam  STM_DWS_RESP_SUCCESS    =   'd24;    //send one token to downstream component
//    localparam  STM_OUT_BEH_SUC_INT     =   'd25;    //send one token to downstream component
    localparam  STM_UPDT_IN_CHAN        =   'd26;
    localparam  STM_END                 =   'd27;
    localparam  IN_SUCCESS_DELAY        =   'd28;
    localparam  EXTRA_OPT_DELAY         =   'd29;
    localparam  IN_ERR_DELAY            =   'd30;
    localparam  OUT_ERR_DELAY           =   'd31;
    localparam  STM_OUT_BEH_INT         =   'd32;
    localparam  GEN_SCAN_INT            =   'd33;
    localparam  STM_ROLL_SORT_IN        =   'd34;
    localparam  STM_WAIT_IRQ_SORT       =   'd35;
    localparam  STM_REQ_TOKEN           =   'd36;
    localparam  STM_ROLL_LIB_IN         =   'd37;
    localparam  WAIT_ROLL_LIB_IN        =   'd38;
    localparam  ACTION_VALVE_UP         =   'd39;
    localparam  STM_VALVE_LIB_IN        =   'd40;
    localparam  WAIT_VALVE_LIB_IN       =   'd41;
    localparam  STM_PS_CFG_MSG_ERR_INT  =   'd42;
    localparam  STM_JUDGE_PS_PATH_MSG   =   'd43;
    localparam  IS_IN_SUCCESS           =   'd49;
    localparam  STM_WAIT_MAT_SND        =   'd50;
    localparam  STM_WAIT_ERROR_CLR      =   'd51;
    
    wire                irq_prcs_busy;
    wire                mat_in_place_pose;
    reg                 mat_in_place_d1;
    reg                 mat_in_place_d2;
    reg     [32:0]      wk_cnt;
    reg                 wk_cnt_done;
    reg                 latch_in_done;

    reg                 latch_path_msg_vld;
    reg                 latch_ps_token_vld;
    reg [TOKEN_DWIDTH-1:0]  latch_ps_token_dat;
    reg                 ps_cfg_token_vld_d1;
    reg                 ps_cfg_token_vld_d2;
    reg                 ps_cfg_token_vld_r;
    reg                 scan_token_vld_d1;
    reg                 scan_token_vld_d2;
    reg                 scan_token_vld_r;
    reg                 latch_scan_token_vld;
    reg                 comp_wk_en_d1;
    reg                 comp_wk_en_d2;
    reg                 comp_wk_en_d3;
    reg                 comp_wk_en_d4;
    reg                 comp_wk_en_d5;
    
    assign mat_in_place_pose = mat_in_place_d1 & (~mat_in_place_d2);
    
    always @(posedge clk)begin
        mat_in_place_d1   <=  mat_in_place;
        mat_in_place_d2   <=  mat_in_place_d1;
    end
    
    always @(posedge clk)begin
        comp_wk_en_d1   <=  comp_wk_en;
        comp_wk_en_d2   <=  comp_wk_en_d1;
        comp_wk_en_d3   <=  comp_wk_en_d2;
        comp_wk_en_d4   <=  comp_wk_en_d3;
        comp_wk_en_d5   <=  comp_wk_en_d4;
    end
    
    always @(posedge clk)begin
        if(reset)begin
            scan_token_vld_d1 <=  0;
            scan_token_vld_d2 <=  0;
            scan_token_vld_r  <=  0;
        end else begin
            scan_token_vld_d1 <=  scan_token_vld & comp_wk_en_d2;
            scan_token_vld_d2 <=  scan_token_vld_d1;
            scan_token_vld_r  <=  scan_token_vld_d1 & (~scan_token_vld_d2);
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            ps_cfg_token_vld_d1 <=  0;
            ps_cfg_token_vld_d2 <=  0;
            ps_cfg_token_vld_r  <=  0;
        end else begin
            ps_cfg_token_vld_d1 <=  ps_cfg_token_vld & comp_wk_en_d2;
            ps_cfg_token_vld_d2 <=  ps_cfg_token_vld_d1;
            ps_cfg_token_vld_r  <=  ps_cfg_token_vld_d1 & (~ps_cfg_token_vld_d2);    
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(comp_wk_en_d2 & (act_in_chan_num !== 0))begin
                        wk_state    <=  STM_IN_CK;
                    end else if(comp_wk_en_d2 & (act_in_chan_num == 0))begin
                        wk_state    <=  STM_REQ_TOKEN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_CK:begin
                    if(comp_error | mat_in_place)begin//current component have some errors
                        wk_state    <=  STM_IN_CKSF_ERR_INT;
                    end else begin
                        wk_state    <=  STM_JUDGE_UPS_TOKEN;
                    end
                end
                STM_IN_CKSF_ERR_INT:begin//in behavior interrupt to ps
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_WAIT_IRQ_INTERVAL;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_IRQ_INTERVAL:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  IN_ERR_DELAY;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                IN_ERR_DELAY:begin
                    if((!comp_error) & (!mat_in_place))begin
                        wk_state    <=  STM_IDLE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_JUDGE_UPS_TOKEN:begin
                    if(s_token_valid)begin
                        wk_state    <=  STM_GEN_RDY_TO_UPS;
                    end else begin
                        wk_state    <=  STM_UPDT_IN_CHAN;
                    end
                end
                STM_GEN_RDY_TO_UPS:begin
                    wk_state    <=  STM_WAIT_MAT_IN_PLACE;
                end
                STM_WAIT_MAT_IN_PLACE:begin
                    if(wk_cnt_done)begin    
                        wk_state    <=  STM_IN_TRSF_FAIL;
                    end else if(latch_in_done & latch_path_msg_vld)begin    
                        wk_state    <=  IS_IN_SUCCESS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                IS_IN_SUCCESS:begin
                    wk_state    <=  IN_SUCCESS_DELAY;
                end
                IN_SUCCESS_DELAY:begin
                    if(wk_cnt_done)begin    
                        wk_state    <=  STM_IN_TRSF_SUCCESS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_TRSF_SUCCESS:begin
                    if(s_token_bready & (COMP_TYPE !== "AUTO_IN"))begin
                        wk_state    <=  STM_IN_BEH_SUC_INT;
                    end else if(s_token_bready & (COMP_TYPE == "AUTO_IN")) begin
                        wk_state    <=  STM_ROLL_LIB_IN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_TRSF_FAIL:begin
                    if(s_token_bready)begin
                        wk_state    <=  STM_IN_BEH_ERR_INT;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_BEH_ERR_INT:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_WAIT_MAT_SND;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_MAT_SND:begin
                    if(latch_in_done)begin
                        if(COMP_TYPE == "AUTO_IN")begin
                            wk_state    <=  STM_ROLL_LIB_IN;
                        end else begin
                            wk_state    <=  STM_IN_BEH_SUC_INT;
                        end
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_BEH_SUC_INT:begin
                    if(~irq_prcs_busy & (act_out_chan_num == 0))begin
                        wk_state    <=  STM_UPDT_IN_CHAN;	
                    end else if(~irq_prcs_busy & (act_out_chan_num !== 0))begin
                        wk_state    <=  EXTRA_OPT_DELAY;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                EXTRA_OPT_DELAY:begin
                    if(wk_cnt_done)begin    
                        wk_state    <=  STM_START_EXTRA_OPT;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_START_EXTRA_OPT:begin
                    wk_state    <=  STM_FINISH_EXTRA_OPT;
                end
                STM_FINISH_EXTRA_OPT:begin
                    if(extra_opt_done & (COMP_TYPE == "LOCATION"))begin
				        wk_state    <=  STM_ROLL_SORT_IN;
			        end else if(extra_opt_done & (COMP_TYPE == "SCAN")) begin
				        wk_state    <=  GEN_SCAN_INT;		
			        end else if(extra_opt_done) begin
				        wk_state    <=  STM_OUT_CK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
		        STM_ROLL_SORT_IN:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_WAIT_IRQ_SORT;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_IRQ_SORT:begin
                    if((~irq_prcs_busy) & latch_ps_token_vld)begin
		                if(extra_msg !== EXTRA_MSG_CODE)begin
                            wk_state    <=  STM_PS_CFG_MSG_ERR_INT;
                        end else begin
                            wk_state    <=  STM_OUT_CK;
                        end    
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                GEN_SCAN_INT:begin
                    if((~irq_prcs_busy) & latch_scan_token_vld)begin
                        wk_state    <=  STM_OUT_CK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_REQ_TOKEN:begin
                    if((~irq_prcs_busy) & latch_ps_token_vld)begin
                        if(latch_in_done)begin
                            wk_state    <=  STM_OUT_CK;
                        end else begin
                            wk_state    <=  STM_OUT_CKSF_ERR_INT; 
                        end        
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_OUT_CK:begin
                    if(comp_error)begin//current component have some errors
                        wk_state    <=  STM_OUT_CKSF_ERR_INT;
                    end else if((act_in_chan_num == 3'd0) | latch_scan_token_vld) begin
                        wk_state    <=  STM_JUDGE_PS_TOKEN;
                    end else begin
                        wk_state    <=  STM_JUDGE_PS_PATH_MSG;
                    end
                end
                STM_JUDGE_PS_TOKEN:begin
                    if(latch_ps_token_vld)begin
		                if(extra_msg !== EXTRA_MSG_CODE)begin
                            wk_state    <=  STM_PS_CFG_MSG_ERR_INT;
                        end else begin
                            wk_state    <=  STM_OUT_BEH_INT;
                        end    
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
		        STM_JUDGE_PS_PATH_MSG:begin
                    if(latch_path_msg_vld)begin
                        if(extra_msg !== EXTRA_MSG_CODE)begin
                            wk_state    <=  STM_PS_CFG_MSG_ERR_INT;
                        end else begin
                            wk_state    <=  STM_OUT_BEH_INT;
                        end    
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_PS_CFG_MSG_ERR_INT:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_OUT_BEH_INT:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_SEND_DWS_TOKEN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_OUT_CKSF_ERR_INT:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_OUT_CKSF_ERR_IACK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_OUT_CKSF_ERR_IACK:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  OUT_ERR_DELAY;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                OUT_ERR_DELAY:begin
                    if(COMP_TYPE == "AUTO_OUT" & latch_ps_token_vld)begin
                        wk_state    <=  STM_IDLE;
                    end else if(!comp_error)begin
                        wk_state    <=  STM_OUT_CK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_SEND_DWS_TOKEN:begin
                    if(m_token_ready)begin
                        wk_state    <=  STM_WAIT_DWS_TOKEN_RESP;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_DWS_TOKEN_RESP:begin
                    if(m_token_bvalid & m_token_bready & (m_token_bresp == 0))begin
                        wk_state    <=  STM_DWS_RESP_ERR;
                    end else if(m_token_bvalid & m_token_bready & (m_token_bresp == 1))begin
                        wk_state    <=  STM_DWS_RESP_SUCCESS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_DWS_RESP_ERR:begin
                    wk_state    <=  STM_DWS_RESP_ERR_INT;
                end
                STM_DWS_RESP_ERR_INT:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_WAIT_ERROR_CLR;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_ERROR_CLR:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_UPDT_IN_CHAN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_DWS_RESP_SUCCESS:begin
                    wk_state    <=  STM_UPDT_IN_CHAN;
                end
                STM_UPDT_IN_CHAN:begin
                    wk_state    <=  STM_END;
                end
                STM_END:begin
                    wk_state    <=  STM_IDLE;
                end
		        STM_ROLL_LIB_IN:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  WAIT_ROLL_LIB_IN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                WAIT_ROLL_LIB_IN:begin
                    if((~irq_prcs_busy) & latch_ps_token_vld)begin
		                if(extra_msg !== EXTRA_MSG_CODE)begin
                            wk_state    <=  STM_PS_CFG_MSG_ERR_INT;
                        end else begin
                            wk_state    <=  ACTION_VALVE_UP;
                        end    
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                ACTION_VALVE_UP:begin
                    if(extra_opt_done)begin
                        wk_state    <=  STM_VALVE_LIB_IN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_VALVE_LIB_IN:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  WAIT_VALVE_LIB_IN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                WAIT_VALVE_LIB_IN:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_UPDT_IN_CHAN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                default:begin
                    wk_state    <=  STM_IDLE;
                end
            endcase
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            latch_scan_token_vld  <=  1'b0;
        end else if (scan_token_vld_r) begin
            latch_scan_token_vld  <=  1'b1;
        end else if(wk_state == STM_UPDT_IN_CHAN || wk_state == STM_PS_CFG_MSG_ERR_INT)begin
            latch_scan_token_vld  <=  1'b0;
        end else begin
            latch_scan_token_vld  <=  latch_scan_token_vld;
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            latch_ps_token_vld  <=  1'b0;
        end else if (ps_cfg_token_vld_r) begin
            latch_ps_token_vld  <=  1'b1;
        end else if(wk_state == STM_UPDT_IN_CHAN)begin
            latch_ps_token_vld  <=  1'b0;
        end else begin
            latch_ps_token_vld  <=  latch_ps_token_vld;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            latch_ps_token_dat  <=  32'd0;
        end else if (ps_cfg_token_vld_r) begin
            latch_ps_token_dat  <=  ps_cfg_token_dat;
        end else begin
            latch_ps_token_dat  <=  latch_ps_token_dat;
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_WAIT_MAT_IN_PLACE,IN_SUCCESS_DELAY,EXTRA_OPT_DELAY:begin
                if(wk_cnt[17:0] == 'd0)begin
                    wk_cnt[17:0]  <=  Init_time_1ms;
                end else begin
                    wk_cnt  <=  wk_cnt + 'd1;
                end
            end
            default:begin
                wk_cnt  <=  Init_time_1ms;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_START_EXTRA_OPT,STM_ROLL_LIB_IN:begin
                extra_opt_start <=  1'b1;
            end
            default:begin
                extra_opt_start <= 1'b0;
            end
        endcase
    end

    always @( * )begin
        case(wk_state)
            STM_WAIT_MAT_IN_PLACE:begin
                wk_cnt_done <=  (wk_cnt > {15'd30000, 18'd0}) ? 1'b1 : 1'b0;
            end
            IN_SUCCESS_DELAY:begin
                wk_cnt_done <=  (wk_cnt > {time_delay[13:0], 18'd0}) ? 1'b1 : 1'b0;
            end
            EXTRA_OPT_DELAY:begin
                wk_cnt_done <=  (wk_cnt > {time_delay[29:16], 18'd0}) ? 1'b1 : 1'b0;
            end
            default:begin
                wk_cnt_done <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_RDY_TO_UPS:begin//in behavior interrupt to ps
                s_token_ready   <=  1'b1;
            end
            default:begin
                s_token_ready   <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        if(reset)begin
            cur_token_dat   <=  'd0;
        end else if (latch_ps_token_vld)begin
            cur_token_dat   <=  latch_ps_token_dat;
        end else if (wk_state == STM_WAIT_MAT_IN_PLACE) begin
            cur_token_dat   <=  s_token_data;
        end else begin
            cur_token_dat   <=  cur_token_dat;
        end
    end

    reg         irq_vld;
    reg [7:0]   irq_type;
    always @(posedge clk)begin
        case(wk_state)
            STM_IN_CKSF_ERR_INT,STM_IN_BEH_ERR_INT,STM_IN_BEH_SUC_INT,STM_OUT_BEH_INT,
            STM_OUT_CKSF_ERR_INT,STM_DWS_RESP_ERR_INT,STM_ROLL_SORT_IN,STM_ROLL_LIB_IN,STM_VALVE_LIB_IN,STM_PS_CFG_MSG_ERR_INT:begin//in behavior interrupt to ps
                if(~irq_prcs_busy)begin
                    irq_vld     <=  1'b1;
                end else begin
                    irq_vld     <=  1'b0;
                end
            end
            STM_GEN_RDY_TO_UPS,STM_WAIT_MAT_IN_PLACE:begin
                if((~irq_prcs_busy) & (~latch_path_msg_vld) & ((act_in_chan_num > 1) || (act_out_chan_num > 1)))begin
                    irq_vld     <=  1'b1;
                end else begin
                    irq_vld     <=  1'b0;
                end
            end
           STM_REQ_TOKEN:begin
                if((~irq_prcs_busy) & latch_in_done & COMP_TYPE !== "AUTO_OUT")begin
                    irq_vld     <=  1'b1;
                end else if((~irq_prcs_busy) & ((extra_opt_done | (comp_wk_en_d4 & ~comp_wk_en_d5 & ~yzqg_up)) & COMP_TYPE == "AUTO_OUT"))begin
                    irq_vld     <=  1'b1;  
                end else begin
                    irq_vld     <=  1'b0;
                end
            end
            GEN_SCAN_INT:begin
                if((~irq_prcs_busy) & latch_scan_token_vld)begin
                    irq_vld     <=  1'b1;
                end else begin
                    irq_vld     <=  1'b0;
                end
            end
            default:begin
                irq_vld     <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IN_CKSF_ERR_INT:begin//in behavior interrupt to ps
                irq_type    <=  `IN_CKSF_ERR_EVENT;
            end
            STM_GEN_RDY_TO_UPS,STM_WAIT_MAT_IN_PLACE:begin
                irq_type    <=  `IN_EVENT_MORE_PATH; 
            end
            STM_REQ_TOKEN:begin
                if(COMP_TYPE == "AUTO_OUT")begin
                    irq_type    <=   `VALVE_LIB_OUT_EVENT;
                end else begin
                    irq_type    <=  `IN_BEH_SUC_EVENT;
                end
            end
            GEN_SCAN_INT:begin
                irq_type    <=  `SCAN_TOKEN_EVENT;  
            end
            STM_IN_BEH_ERR_INT:begin
                irq_type    <=  `IN_BEH_ERR_EVENT;
            end
            STM_IN_BEH_SUC_INT:begin
                irq_type    <=  (COMP_TYPE == "MEASURE") ? `EXTERNAL_MEASURE : `IN_BEH_SUC_EVENT;
            end
            STM_OUT_BEH_INT:begin
                irq_type    <=  `OUT_BEH_SUC_EVENT;
            end
            STM_OUT_CKSF_ERR_INT:begin
                irq_type    <=  `OUT_CKSF_ERR_EVENT;
            end
            STM_DWS_RESP_ERR_INT:begin
                irq_type    <=  `OUT_BEH_ERR_EVENT;
            end
            STM_ROLL_SORT_IN:begin
                irq_type    <=  `ROLL_SORT_IN_EVENT;
            end
	        STM_ROLL_LIB_IN:begin
                irq_type    <=  `ROLL_LIB_IN_EVENT;
            end   
            STM_VALVE_LIB_IN:begin
                irq_type    <=  `VALVE_LIB_IN_EVENT;
            end
	        STM_PS_CFG_MSG_ERR_INT:begin
                irq_type    <=  `PS_CFG_MSG_ERR_EVENT;
            end
            default:begin
                irq_type    <=  0;
            end
        endcase
    end
    

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                latch_path_msg_vld  <=  1'b0;
            end
            STM_GEN_RDY_TO_UPS,STM_WAIT_MAT_IN_PLACE:begin
                if((act_in_chan_num > 1) || (act_out_chan_num > 1))begin
                    if(path_msg_vld)begin
                        latch_path_msg_vld  <=  1'b1;
                    end else begin
                        latch_path_msg_vld  <=  latch_path_msg_vld;
                    end
                end else begin
                    latch_path_msg_vld  <=  1'b1;
                end
            end
            default:begin
                latch_path_msg_vld  <=  latch_path_msg_vld;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                latch_in_done   <=  1'b0;
            end
            STM_WAIT_MAT_IN_PLACE,STM_REQ_TOKEN,STM_WAIT_MAT_SND:begin
                if(mat_in_place && COMP_TYPE == "AUTO_OUT")begin
                    latch_in_done   <=  1'b1;
                end else if(mat_in_place_pose && COMP_TYPE !== "AUTO_OUT")begin
                    latch_in_done   <=  1'b1;
                end else begin
                    latch_in_done   <=  latch_in_done;
                end
            end
            default:begin
                latch_in_done   <=  latch_in_done;
            end
        endcase
    end
    
    always @(posedge clk)begin
        if(reset)begin
            in_chan_seq <=  1;
        end else begin
            case(wk_state)
                STM_UPDT_IN_CHAN:begin
                    if(act_in_chan_num <= 1)begin
                        in_chan_seq <=  in_chan_seq;
                    end else begin
                        in_chan_seq <=  in_chan_seq + 1;
                    end
                end
                default:begin
                    in_chan_seq <=  in_chan_seq;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_RDY_TO_UPS:begin
                comp_in_start    <=  1'b1;
            end
            default:begin
                comp_in_start    <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_SEND_DWS_TOKEN:begin
                if(m_token_ready)begin
                    comp_out_start  <=  1'b1;
                end else begin
                    comp_out_start  <=  comp_out_start;
                end
            end
            default:begin
                comp_out_start  <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IN_TRSF_SUCCESS,STM_IN_TRSF_FAIL:begin
		        if(COMP_TYPE !== "AUTO_IN")begin 
                    cfg_comp_done  <=  1'b1;
                    cfg_comp_done2  <=  1'b0;
                end else begin
                    cfg_comp_done  <=  1'b0;
                    cfg_comp_done2  <=  1'b0;
                end    
            end
	        ACTION_VALVE_UP:begin
	            if(COMP_TYPE == "AUTO_IN")begin
                    cfg_comp_done  <=  1'b1;
                    cfg_comp_done2  <=  1'b0;
                end else begin
                    cfg_comp_done  <=  1'b0;
                    cfg_comp_done2  <=  1'b0;
                end    
            end
            STM_END,STM_DWS_RESP_ERR:begin
                cfg_comp_done  <=  1'b0;
                cfg_comp_done2  <=  1'b1;
            end
            default:begin
                cfg_comp_done  <=  1'b0;
                cfg_comp_done2  <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IN_TRSF_FAIL:begin
                if(s_token_bready)begin
                    s_token_bvalid  <=  1'b0;
                    s_token_bresp   <=  'd0;
                end else begin
                    s_token_bvalid  <=  1'b1;
                    s_token_bresp   <=  'd0;
                end
            end
            STM_IN_TRSF_SUCCESS:begin
                if(s_token_bready)begin
                    s_token_bvalid  <=  1'b0;
                    s_token_bresp   <=  'd0;
                end else begin
                    s_token_bvalid  <=  1'b1;
                    s_token_bresp   <=  'd1;
                end
            end
            default:begin
                s_token_bvalid  <=  1'b0;
                s_token_bresp   <=  'd0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                m_token_valid   =   1'b0;
                m_token_data    =   'd55;
            end
            STM_SEND_DWS_TOKEN:begin
                m_token_valid   =   m_token_ready ? 1'b0 : 1'b1;
                m_token_data    =   cur_token_dat;
            end
            default:begin
                m_token_valid   =   1'b0;
                m_token_data    =   m_token_data;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_WAIT_DWS_TOKEN_RESP:begin
                if(m_token_bvalid & (!m_token_bready))begin
                    m_token_bready  <=  1'b1;
                end else begin
                    m_token_bready  <=  1'b0;
                end
            end
            default:begin
                m_token_bready  <=  1'b0;
            end
        endcase
    end

    intc_top
    #(

    )
        intc_top_u
        (
             .clk           (clk)
            ,.reset         (reset)

            ,.irq_vld       (irq_vld        )
            ,.irq_type      (irq_type       )
            ,.irq_prcs_busy (irq_prcs_busy  )

            ,.ps_irq_vld    (comp_irq       )
            ,.ps_irq_type   (comp_irq_type  )
            ,.ps_iack_vld   (int_ack_vld    )
            ,.ps_iack_type  (int_ack_dat    )
        );

endmodule