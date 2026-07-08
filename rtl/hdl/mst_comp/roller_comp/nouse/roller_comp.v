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
module roller_comp
#(
     parameter  IN_CHAN_NUM = 3'd1
    ,parameter  OUT_CHAN_NUM = 3'd1
)
(
     input                              clk
    ,input                              reset

    ,input  [31:0]                      cur_timer
    //driver interface
    ,output reg                         comp_in_start
    ,output reg                         comp_out_start
    ,output reg                         cfg_comp_done
    ,output reg                         cfg_comp_done2
    ,input  wire                        mat_in_place
    ,input  wire                        comp_error
    ,output reg                         extra_opt_start
    ,input  wire                        extra_opt_done
    ,input  wire                        scan_token_vld

    ,input  wire                        comp_wk_en
    //reg cfg interrupt
    ,output wire                        comp_irq
    ,output wire    [7:0]               comp_irq_type
    
    ,(* MARK_DEBUG="true" *)input                              path_msg_vld
    ,(* MARK_DEBUG="true" *)input          [13:0]              path_msg_dat

    ,(* MARK_DEBUG="true" *)input                              int_ack_vld
    ,(* MARK_DEBUG="true" *)input          [7:0]               int_ack_dat

    ,(* MARK_DEBUG="true" *)output reg     [15:0]              cur_token_dat
    ,(* MARK_DEBUG="true" *)input  wire                        ps_cfg_token_vld
    ,(* MARK_DEBUG="true" *)input  wire    [31:0]              ps_cfg_token_dat
//  components interface
    ,(* MARK_DEBUG="true" *)input  wire                        s_token_valid
    ,(* MARK_DEBUG="true" *)output reg                         s_token_ready
    ,(* MARK_DEBUG="true" *)input  wire    [31:0]              s_token_data
    ,(* MARK_DEBUG="true" *)output reg                         s_token_bvalid
    ,(* MARK_DEBUG="true" *)input  wire                        s_token_bready
    ,(* MARK_DEBUG="true" *)output reg     [2:0]               s_token_bresp

    ,(* MARK_DEBUG="true" *)output reg                         m_token_valid
    ,(* MARK_DEBUG="true" *)input  wire                        m_token_ready
    ,(* MARK_DEBUG="true" *)output reg     [31:0]              m_token_data
    ,(* MARK_DEBUG="true" *)input  wire                        m_token_bvalid
    ,(* MARK_DEBUG="true" *)output reg                         m_token_bready
    ,(* MARK_DEBUG="true" *)input  wire    [2:0]               m_token_bresp
//others
    ,(* MARK_DEBUG="true" *)output reg     [2:0]               in_chan_seq
);

    localparam  WAIT_PATH_MSG_MAX_TIME = 2000;      //2000000000
    localparam  ERR_DELAY_TIME = 32'h1000000;
    
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
    localparam  STM_OUT_BEH_SUC_INT     =   'd25;    //send one token to downstream component
    localparam  STM_UPDT_IN_CHAN        =   'd26;
    localparam  STM_END                 =   'd27;
    localparam  IN_ERR_DELAY            =   'd28;
    localparam  OUT_ERR_DELAY           =   'd29;

    wire                irq_prcs_busy;
    (* MARK_DEBUG="true" *)reg     [5:0]       wk_state = STM_IDLE;
    reg     [31:0]      wk_cnt = 'd0;
    reg                 mf_flag = 1'b0;
    reg                 wk_cnt_done;
    reg                 latch_in_done;

    reg                 latch_path_msg_vld;
    reg                 latch_ps_token_vld;
    reg     [31:0]      latch_ps_token_dat;
    reg                 ps_cfg_token_vld_d1;
    reg                 ps_cfg_token_vld_d2;
    reg                 ps_cfg_token_vld_r;
    reg                 scan_token_vld_d1;
    reg                 scan_token_vld_d2;
    reg                 scan_token_vld_r;
    reg                 latch_scan_token_vld;
    reg                 irq_prcs_busy_d1;
    reg                 irq_prcs_busy_d2;
    reg                 irq_prcs_busy_r;
    
    (* MARK_DEBUG="true" *)reg [31:0]         m_token_data_reg;
    (* MARK_DEBUG="true" *)reg [31:0]         s_token_data_reg;
    (* MARK_DEBUG="true" *)reg [31:0]         ps_cfg_token_dat_reg;
    (* MARK_DEBUG="true" *)reg [13:0]         path_msg_dat_reg;
    (* MARK_DEBUG="true" *)reg [7:0]          int_ack_dat_reg;
    (* MARK_DEBUG="true" *)reg [15:0]         cur_token_dat_reg;

    (* MARK_DEBUG="true" *)reg                m_token_valid_reg;
    (* MARK_DEBUG="true" *)reg                m_token_ready_reg;
    (* MARK_DEBUG="true" *)reg                m_token_bvalid_reg;
    (* MARK_DEBUG="true" *)reg                m_token_bready_reg;
    (* MARK_DEBUG="true" *)reg [2:0]          m_token_bresp_reg;

    (* MARK_DEBUG="true" *)reg                comp_out_start_kkk;
    (* MARK_DEBUG="true" *)reg                cfg_comp_done2_kkk;
    (* MARK_DEBUG="true" *)reg                comp_error_kkk;
    (* MARK_DEBUG="true" *)reg                comp_in_start_kkk;
    (* MARK_DEBUG="true" *)reg                cfg_comp_done_kkk;
    (* MARK_DEBUG="true" *)reg                mat_in_place_kkk;

    always @(posedge clk)begin
    	m_token_valid_reg 	<= m_token_valid;
    	m_token_ready_reg 	<= m_token_ready;
    	m_token_bvalid_reg 	<= m_token_bvalid;
    	m_token_bready_reg 	<= m_token_bready;
    	m_token_bresp_reg 	<= m_token_bresp;
    	
    	cur_token_dat_reg 		<= cur_token_dat;
    	path_msg_dat_reg 			<= path_msg_dat;
    	int_ack_dat_reg 			<= int_ack_dat;
    	ps_cfg_token_dat_reg 	<= ps_cfg_token_dat;
    	s_token_data_reg 			<= s_token_data;
    	m_token_data_reg 			<= m_token_data;
    	
    	comp_out_start_kkk<=comp_out_start;
    	cfg_comp_done2_kkk<=cfg_comp_done2;
    	comp_error_kkk<=comp_error;
    	comp_in_start_kkk<=comp_in_start;
    	cfg_comp_done_kkk<=cfg_comp_done;
    	mat_in_place_kkk<=mat_in_place;
    end
    
    always @(posedge clk)begin
        irq_prcs_busy_d1 <=  irq_prcs_busy;
        irq_prcs_busy_d2 <=  irq_prcs_busy_d1;
        irq_prcs_busy_r  <=  irq_prcs_busy_d1 & (~irq_prcs_busy_d2);
    end
    
    always @(posedge clk)begin
        scan_token_vld_d1 <=  scan_token_vld;
        scan_token_vld_d2 <=  scan_token_vld_d1;
        scan_token_vld_r  <=  scan_token_vld_d1 & (~scan_token_vld_d2);
    end
    
    always @(posedge clk)begin
        ps_cfg_token_vld_d1 <=  ps_cfg_token_vld;
        ps_cfg_token_vld_d2 <=  ps_cfg_token_vld_d1;
        ps_cfg_token_vld_r  <=  ps_cfg_token_vld_d1 & (~ps_cfg_token_vld_d2);
    end
    
    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(comp_wk_en & (IN_CHAN_NUM !== 0))begin
                        wk_state    <=  STM_IN_CK;
                    end else if(comp_wk_en & (IN_CHAN_NUM == 0))begin
                        wk_state    <=  STM_OUT_CK;
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
                    if(wk_cnt_done)begin
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
                    if (wk_cnt_done) begin
                        wk_state    <=  STM_IN_TRSF_FAIL;
                    end else if(latch_in_done & latch_path_msg_vld)begin    
                        wk_state    <=  STM_IN_TRSF_SUCCESS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_TRSF_SUCCESS:begin
                    if(s_token_bready)begin
                        wk_state    <=  STM_IN_BEH_SUC_INT;
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
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_BEH_SUC_INT:begin
                    if(~irq_prcs_busy & (OUT_CHAN_NUM == 0))begin
                        wk_state    <=  STM_END;
                    end else if(~irq_prcs_busy & (OUT_CHAN_NUM !== 0))begin
                        wk_state    <=  STM_START_EXTRA_OPT;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_START_EXTRA_OPT:begin
                    wk_state    <=  STM_FINISH_EXTRA_OPT;
                end
                STM_FINISH_EXTRA_OPT:begin
                    if(extra_opt_done)begin
                        wk_state    <=  STM_OUT_CK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_OUT_CK:begin
                    if(comp_error)begin//current component have some errors
                        wk_state    <=  STM_OUT_CKSF_ERR_INT;
                    end else if(latch_scan_token_vld | IN_CHAN_NUM == 3'd0) begin
                        wk_state    <=  STM_JUDGE_PS_TOKEN;
                    end else begin
                        wk_state    <=  STM_SEND_DWS_TOKEN;
                    end
                end
                STM_JUDGE_PS_TOKEN:begin
                    if(latch_ps_token_vld)begin
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
                    if(wk_cnt_done)begin
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
//                    if(m_token_bvalid & (m_token_bresp == 0))begin
                    if(m_token_bvalid & m_token_bready & (m_token_bresp == 0))begin
                        wk_state    <=  STM_DWS_RESP_ERR;
//                    end else if(m_token_bvalid & (m_token_bresp == 1))begin
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
                        wk_state    <=  STM_OUT_CK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_DWS_RESP_SUCCESS:begin
                    wk_state    <=  STM_OUT_BEH_SUC_INT;
                end
                STM_OUT_BEH_SUC_INT:begin
                    if(~irq_prcs_busy)begin
                        wk_state    <=  STM_UPDT_IN_CHAN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_UPDT_IN_CHAN:begin
                    wk_state    <=  STM_END;
                end
                STM_END:begin
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
        end else if(wk_state == STM_UPDT_IN_CHAN)begin
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
            STM_WAIT_MAT_IN_PLACE,IN_ERR_DELAY,OUT_ERR_DELAY:begin
                wk_cnt  <=  wk_cnt + 'd1;
            end
            default:begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_START_EXTRA_OPT:begin
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
                wk_cnt_done <=  (wk_cnt == WAIT_PATH_MSG_MAX_TIME) ? 1'b0 : 1'b0;
            end
            IN_ERR_DELAY,OUT_ERR_DELAY:begin
                wk_cnt_done <=  (wk_cnt == ERR_DELAY_TIME) ? 1'b1 : 1'b0;
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
            STM_IN_CKSF_ERR_INT,STM_IN_BEH_ERR_INT,STM_IN_BEH_SUC_INT,STM_OUT_BEH_SUC_INT,
            STM_OUT_CKSF_ERR_INT,STM_DWS_RESP_ERR_INT:begin//in behavior interrupt to ps
                if(~irq_prcs_busy)begin
                    irq_vld     <=  1'b1;
                end else begin
                    irq_vld     <=  1'b0;
                end
            end
            STM_GEN_RDY_TO_UPS,STM_WAIT_MAT_IN_PLACE:begin
                if((~irq_prcs_busy) & (~latch_path_msg_vld) & (OUT_CHAN_NUM > 1))begin
                    irq_vld     <=  1'b1;
                end else begin
                    irq_vld     <=  1'b0;
                end
            end
            STM_JUDGE_PS_TOKEN:begin
                if((~irq_prcs_busy) & latch_in_done)begin
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
                irq_type    <=  (OUT_CHAN_NUM > 3'd1) ? `IN_EVENT_MORE_PATH : `IN_EVENT_ONE_PATH;    //`QUERY_PATH_EVENT;   
            end
            STM_JUDGE_PS_TOKEN:begin
                irq_type    <=  `SCAN_TOKEN_EVENT;  
            end
            STM_IN_BEH_ERR_INT:begin
                irq_type    <=  `IN_BEH_ERR_EVENT;
            end
            STM_IN_BEH_SUC_INT:begin
                irq_type    <=  `IN_BEH_SUC_EVENT;
            end
            STM_OUT_BEH_SUC_INT:begin
                irq_type    <=  `OUT_BEH_SUC_EVENT;
            end
            STM_OUT_CKSF_ERR_INT:begin
                irq_type    <=  `OUT_CKSF_ERR_EVENT;
            end
            STM_DWS_RESP_ERR_INT:begin
                irq_type    <=  `OUT_BEH_ERR_EVENT;
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
                if(OUT_CHAN_NUM > 1)begin
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
            STM_WAIT_MAT_IN_PLACE,STM_JUDGE_PS_TOKEN:begin
                if(mat_in_place && ~mf_flag)begin
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
            mf_flag <=  1'b0;
        end else begin
            if(mat_in_place && ~mf_flag)begin
                mf_flag = 1'b1;
            end else if(~mat_in_place && mf_flag)begin
                mf_flag = 1'b0;    
            end
        end        
    end
    
    always @(posedge clk)begin
        if(reset)begin
            in_chan_seq <=  1;
        end else begin
            case(wk_state)
                STM_UPDT_IN_CHAN:begin
                    if(IN_CHAN_NUM <= 1)begin
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
                cfg_comp_done  <=  1'b1;
                cfg_comp_done2  <=  1'b0;
            end
            STM_END:begin
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
                m_token_data    =   latch_ps_token_vld ? latch_ps_token_dat : s_token_data;
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