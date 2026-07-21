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
module app_mst_tx_ctrl(
     input              clk
    ,input              reset
    
    //from ps config msg
    ,input              app_trsf_en     //application transfer enable
    ,input              mst_sta_restart //master station transfer restart,only active on rise edge
    ,input  wire[15:0]  each_dg_length  //PS config each datagram length
    ,output reg         app_err_flag    //the error type of slave station is valid
    ,output reg [15:0]  app_err_type    //the error type of slave station

    ,output reg [15:0]  hb_err_slvsta   //indicate the index of the error station
    ,output reg         mst_prcs_hb_flag
    ,input  wire        loop_link_success
    ,output reg         ping_pong_flag

    ,output reg             prot_send_req
    ,input  wire            prot_send_ack

    //down layer config signals
    ,output reg         pkg_trsf_start  //APP notice datagram layer could transfer datagram

    //from receive module result
    ,input  wire        one_ecat_frm_done   //rx channel notice to app ctrl module that one complete return package has been recived.
    ,input  wire[3:0]   ecat_frm_rslt       //pkg crc result
    ,input  wire[7:0]   slv_sta_num         //this signals only update during first initial datagram.It indicate the number of slave station
    ,input  wire[3:0]   rx_eth_type         //the type of package has been received by rx channel
    
    //to send module config message
    ,output reg [3:0]   ethcat_tx_type
    ,output reg [15:0]  ethcat_tx_len
    
    ,output reg [7:0]   datagram_tx_cmd
    ,output reg [15:0]  datagram_tx_len
    ,output reg [7:0]   datagram_tx_num
    ,output reg [16:0]  datagram_tx_uuid
    ,output wire[31:0]  dg_hb_dst_addr//current datagram heartbeat dst address,which drive datagram layer
);

`ifdef SIM_PLATFORM_MST
//    localparam  WAIT_CNT            = `SIM_SLV_STA_NUM * 'd25_000;//MAX time intervall between two packets
    localparam  WAIT_CNT            = 'd250_000;//MAX time intervall between two packets
`else
    localparam  WAIT_CNT            = 'd156_250_000;//MAX time intervall between two package. clock period is 6.4ns
`endif
    
    localparam  STM_IDLE            = 'd0;
    localparam  STM_INIT_SLV_STA    = 'd1;//initial slave station
    localparam  STM_INIT_WAIT_ACK   = 'd2;//wait initial package ack
    localparam  STM_CK_SLV_HB       = 'd3;//check slave station heartbeat
    localparam  STM_HB_WAIT_ACK     = 'd4;//wait heartbeat ack
    localparam  STM_CK_HB_SUCCES    = 'd5;//one heartbeat of slave stiation has rx successful
    localparam  STM_TX_HS           = 'd7;//handshake with depot
    localparam  STM_TX_PKG          = 'd10;//normal package  been transfer
    localparam  STM_WAIT_ACK        = 'd11;//wait datagram ack
    localparam  STM_RD_DAT          = 'd12;//no use
    localparam  STM_POST_PRCS_INIT  = 'd13;//initial package post process
    localparam  STM_POST_PRCS_HB    = 'd14;//heart beat package post process
    localparam  STM_POST_PRCS_DG    = 'd15;//datagram package post process
    localparam  STM_SLV_ERROR       = 'd16;//no use
    localparam  STM_ALL_LINK_PASS   = 'd17;
    localparam  STM_END             = 'd18;
    
    reg     [31:0]  timer_cnt;
    wire            timer_done;
    reg     [4:0]   wk_state  = 'd0;
    reg     [7:0]   ck_hb_sta_cnt;  //the index of slate station during check heart beat
    wire            last_ck_hb_sta; 
    reg             mst_sta_restart_d1  =   'd0;//master station restart transfer
    reg             mst_sta_restart_r   =   'd0;
    reg             latch_sta_rs_flag;
    always @(posedge clk)begin
        mst_sta_restart_d1  <=  mst_sta_restart;
        mst_sta_restart_r   <=  mst_sta_restart & !mst_sta_restart_d1;
    end

    always @(posedge clk)begin
        if(reset)begin
            latch_sta_rs_flag   <=  'd0;
        end else if(mst_sta_restart_r)begin
            latch_sta_rs_flag   <=  'd1;
        end else if(app_trsf_en &(wk_state == STM_IDLE))begin
            latch_sta_rs_flag   <=  'd0;
        end else begin
            latch_sta_rs_flag   <=  latch_sta_rs_flag;
        end
    end
    
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(app_trsf_en & latch_sta_rs_flag)begin
                        wk_state  <=  STM_INIT_SLV_STA;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_INIT_SLV_STA:begin
                    wk_state  <=  STM_INIT_WAIT_ACK;
                end
                STM_INIT_WAIT_ACK:begin
                    if(timer_done)begin
                        wk_state <= STM_END;
                    end else if (one_ecat_frm_done & (ecat_frm_rslt == `ETHCAT_PRCS_CRC_FAIL))begin
                        wk_state <= STM_CK_SLV_HB;
                    end else if (one_ecat_frm_done & (ecat_frm_rslt == `ETHCAT_PRCS_SUCCESS) & 
                                 (rx_eth_type == `ETHCAT_TYPE_INITIAL))begin
                        wk_state <= STM_POST_PRCS_INIT;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                STM_TX_HS:begin
                    if(1)begin
                        wk_state  <=  STM_TX_PKG;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_PKG:begin
                    wk_state  <=  STM_WAIT_ACK;
                end
                STM_WAIT_ACK:begin
                    if(timer_done)begin
                        wk_state <= STM_CK_SLV_HB;
                    end else if (one_ecat_frm_done & (ecat_frm_rslt == `ETHCAT_PRCS_CRC_FAIL))begin
                        wk_state <= STM_CK_SLV_HB;
                    end else if (one_ecat_frm_done & (ecat_frm_rslt == `ETHCAT_PRCS_SUCCESS) & 
                                 (rx_eth_type == `ETHCAT_TYPE_DATAGRAM))begin
                        wk_state <= STM_POST_PRCS_DG;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                STM_CK_SLV_HB:begin
                    wk_state  <=  STM_HB_WAIT_ACK;
                end
                STM_HB_WAIT_ACK:begin
                    if(timer_done)begin
                        wk_state <= STM_POST_PRCS_HB;
                    end else if (one_ecat_frm_done & (ecat_frm_rslt == `ETHCAT_PRCS_CRC_FAIL))begin
                        wk_state <= STM_POST_PRCS_HB;
                    end else if (one_ecat_frm_done & (ecat_frm_rslt == `ETHCAT_PRCS_SUCCESS) & 
                                 (rx_eth_type == `ETHCAT_TYPE_HEARTBEAT))begin
                        wk_state <= STM_CK_HB_SUCCES;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                STM_CK_HB_SUCCES:begin
                    if(last_ck_hb_sta)begin
                        if(loop_link_success)begin
                            wk_state <= STM_ALL_LINK_PASS;
                        end else begin
                            wk_state <= STM_POST_PRCS_HB;
                        end
                    end else begin
                        wk_state <= STM_CK_SLV_HB;
                    end
                end
                STM_POST_PRCS_INIT:begin
                    if(~app_trsf_en)begin
                        wk_state <= STM_END;
                    end else begin
                        wk_state <= STM_TX_HS;
                    end
                end
                STM_POST_PRCS_DG:begin
                    if(~app_trsf_en)begin
                        wk_state <= STM_END;
                    end else begin
                        wk_state <= STM_TX_HS;
                    end
                end
                STM_POST_PRCS_HB:begin
                    if(~app_trsf_en)begin
                        wk_state <= STM_END;
                    end else begin
                        wk_state <= STM_CK_SLV_HB;
                    end
                end
                STM_ALL_LINK_PASS:begin
                    wk_state <= STM_TX_HS;
                end
                STM_END:begin
                    wk_state <= STM_IDLE;
                end
                default: begin
                  wk_state  <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_POST_PRCS_DG,STM_CK_SLV_HB:begin
                prot_send_req   <=  0;
            end
            STM_TX_HS:begin
                prot_send_req   <=  1;
            end
            default: begin
                prot_send_req   <=  prot_send_req;
            end
        endcase
    end

    always @(posedge clk) begin
        if(reset)begin
            datagram_tx_uuid   <=  16'hdccd;
//        end else if((wk_state == STM_POST_PRCS_DG) | 
//                    (wk_state == STM_POST_PRCS_INIT) | 
//                    (wk_state == STM_POST_PRCS_HB))begin
        end else if((wk_state == STM_POST_PRCS_DG) | 
                    (wk_state == STM_POST_PRCS_INIT))begin
            datagram_tx_uuid   <=  datagram_tx_uuid + 1;
        end else begin
            datagram_tx_uuid   <=  datagram_tx_uuid;
        end
    end

    //ping_pong_flag: 1 link error, 0 link success
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_POST_PRCS_DG:begin
                ping_pong_flag  <=  0;
            end
            STM_ALL_LINK_PASS:begin
                ping_pong_flag  <=  1;
            end
            default: begin
              ping_pong_flag    <=  ping_pong_flag;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_HB_WAIT_ACK,STM_INIT_WAIT_ACK,STM_WAIT_ACK:begin
                timer_cnt   <=  timer_cnt + 1;
            end
            default: begin
              timer_cnt  <=  0;
            end
        endcase
    end
    assign  timer_done = (timer_cnt == (WAIT_CNT - 1)) ? 1'b1 : 1'b0;
    
    always @(posedge clk) begin
        case(wk_state)
            STM_CK_SLV_HB,STM_TX_PKG,STM_INIT_SLV_STA:begin
                pkg_trsf_start  <=  1;
            end
            default: begin
                pkg_trsf_start  <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_INIT_SLV_STA,STM_TX_HS,STM_POST_PRCS_HB:begin//Checking the heart beat of some slave station is not successful.
                ck_hb_sta_cnt   <=  'd0;
            end
            STM_CK_HB_SUCCES:begin//check next slave station heartbeat
                ck_hb_sta_cnt   <=  ck_hb_sta_cnt + 1;
            end
            default: begin
                ck_hb_sta_cnt   <=  ck_hb_sta_cnt;
            end
        endcase
    end

    assign  last_ck_hb_sta  =   (ck_hb_sta_cnt == slv_sta_num - 1) ? 1'b1 : 1'b0;
    assign  dg_hb_dst_addr = ck_hb_sta_cnt;
    
    //
    always @(posedge clk) begin
        if(reset | (app_trsf_en & latch_sta_rs_flag) | (wk_state == STM_TX_HS))begin
            hb_err_slvsta   <=  'd0;
        end else if (wk_state == STM_POST_PRCS_HB)begin
            hb_err_slvsta   <=  dg_hb_dst_addr;
        end else begin
            hb_err_slvsta   <=  hb_err_slvsta;
        end
    end
    
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                ethcat_tx_type      <=  0;
                datagram_tx_len     <=  0;
                datagram_tx_num     <=  0;
                datagram_tx_cmd     <=  0;
            end
            STM_INIT_SLV_STA:begin
                ethcat_tx_type      <=  `ETHCAT_TYPE_INITIAL;
                datagram_tx_len     <=  `ETHCAT_INIT_DG_LEN;
                datagram_tx_num     <=  `DEFAULT_SUPPORT_SLV_NUM;   //the number ofdefault support slave station is 30
                datagram_tx_cmd     <=  `ETHCAT_CMD_FPRW;
            end
            STM_TX_PKG:begin
                ethcat_tx_type     <=  `ETHCAT_TYPE_DATAGRAM;
                datagram_tx_len    <=  each_dg_length;
                datagram_tx_num    <=  slv_sta_num;
                datagram_tx_cmd    <=  `ETHCAT_CMD_FPRW;
            end
            STM_CK_SLV_HB:begin
                ethcat_tx_type     <=  `ETHCAT_TYPE_HEARTBEAT;
                datagram_tx_len    <=  `ETHCAT_HB_DG_LEN;
                datagram_tx_num    <=  1;
                datagram_tx_cmd    <=  `ETHCAT_CMD_FPRW;
            end
            default: begin
                ethcat_tx_type      <=  ethcat_tx_type;
                datagram_tx_len     <=  datagram_tx_len;
                datagram_tx_num     <=  datagram_tx_num;
                datagram_tx_cmd     <=  datagram_tx_cmd;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE,STM_CK_HB_SUCCES:begin
                mst_prcs_hb_flag    <=  'd0;
            end
            STM_CK_SLV_HB:begin
                mst_prcs_hb_flag    <=  'd1;
            end
            default: begin
                mst_prcs_hb_flag      <=  mst_prcs_hb_flag;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if(reset)begin
            app_err_flag    <=  'd0;
            app_err_type    <=  'd0;
        end else if ((wk_state == STM_ALL_LINK_PASS) | (~app_trsf_en))begin
            app_err_flag    <=  'd0;
            app_err_type    <=  16'h0;
        end else if (wk_state == STM_POST_PRCS_HB)begin
            app_err_flag    <=  'd1;
            app_err_type    <=  16'hffee;
        end else begin
            app_err_flag    <=  app_err_flag;
            app_err_type    <=  app_err_type;
        end
    end

    always @(posedge clk)begin
        ethcat_tx_len  <=  `ETHCAT_HEAD_LEN + datagram_tx_num * (datagram_tx_len + `DATAGRAM_HEAD_LEN + `DATAGRAM_WKC_LEN);
    end
    
endmodule

