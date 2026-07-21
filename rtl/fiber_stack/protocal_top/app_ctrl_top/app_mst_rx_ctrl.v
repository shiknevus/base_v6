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
module app_mst_rx_ctrl(
     input                  clk
    ,input                  reset
    
    ,output reg             one_ecat_frm_done   //rx channel notice to app ctrl module that one complete return package has been recived.
    ,output reg     [3:0]   ecat_frm_rslt       //pkg crc result
    ,(* MARK_DEBUG="true" *)output reg     [7:0]   slv_sta_num         //this signals only update during first initial datagram.It indicate the number of slave station
    ,output reg     [3:0]   rx_eth_type         //the type of package has been received by rx channel

    ,output reg             prot_rcv_req
    ,input                  prot_rcv_ack
    
    //ll cache interface which is used between app layer and ethcat layer
    ,output reg     [3:0]   cache_we
    ,output reg     [15:0]  cache_addr
    ,output reg     [31:0]  cache_din
    ,input  wire    [31:0]  cache_dout
    //ethercat crc result
    ,input  wire            rx_crc_vld
    ,input  wire            rx_crc_pass
    
    //app layer ll interface with application depot
    ,(* MARK_DEBUG="true" *)output reg     [3:0]   depot_we
    ,(* MARK_DEBUG="true" *)output reg     [15:0]  depot_addr
    ,(* MARK_DEBUG="true" *)output wire    [31:0]  depot_din
    ,input  wire    [31:0]  depot_dout

    //the interface which is used to stors all of slave station id
    ,(* MARK_DEBUG="true" *)output reg     [3:0]   slv_id_we       = 'd0
    ,(* MARK_DEBUG="true" *)output reg     [15:0]  slv_id_addr     = 'd0
    ,(* MARK_DEBUG="true" *)output reg     [31:0]  slv_id_din      = 'd0
    
    //heart beat check result
    ,(* MARK_DEBUG="true" *)output reg             ck_slv_hb_vld
    ,(* MARK_DEBUG="true" *)output reg     [15:0]  ck_slv_hb_addr  //slave station address
    ,(* MARK_DEBUG="true" *)output reg     [15:0]  ck_slv_hb_data  //salve staiton timestamp
);

    localparam  STM_IDLE            = 'd0;
    localparam  STM_CRC_PASS        = 'd1;
    localparam  STM_CRC_FAIL        = 'd2;
    localparam  STM_ETHCAT_HEAD     = 'd3;//read ethercat header
    localparam  STM_ECAT_HD_L       = 'd4;//latency read ethercat header
    localparam  STM_ECAT_HD_PARSE   = 'd5;//parse ecat header
    localparam  STM_RX_HS           = 'd6;//decided next operate address after ethercat header
    localparam  STM_NXT_ADDR_EH     = 'd7;//decided next operate address after ethercat header
    localparam  STM_DATAGRAM_HEAD   = 'd8;//read datagram header
    localparam  STM_DG_HD_L         = 'd9;// datagram head latency
    localparam  STM_DG_HD_PARSE     = 'd10;//parse datagram header
    localparam  STM_DG_HD_PRCS      = 'd11;//process datagram header
    localparam  STM_DH2WKC_JUMP_ADDR= 'd12;//the address space need jump from datagram header to wkc
    localparam  STM_RD_DATAGRAM     = 'd13;//read datagram
    localparam  STM_RD_DATAGRAM_L   = 'd14;//read datagram latency
    localparam  STM_RD_DG_PARSE     = 'd15;//parse datagram only used by initial package and heart beat package
    localparam  STM_DG_PRCS         = 'd16;//this stage is used to store some message to cache buffer in slave 
    localparam  STM_NXT_ADDR_DG     = 'd17;//the address space need jump from datagram to next datagram header
    localparam  STM_RD_WKC          = 'd18;//read work counter
    localparam  STM_RD_WKC_L        = 'd19;//read wkc latency
    localparam  STM_RD_WKC_PARSE    = 'd20;//parse wkc
    localparam  STM_PRCS_WKC_L      = 'd21;//porcess wkc latency
    localparam  STM_PRCS_WKC        = 'd22;//no use
    localparam  STM_WKC2DG_JUMP_ADDR= 'd23;//the address space need jump from wkc to next datagram header
    localparam  STM_WKC2DH_JUMP_ADDR= 'd24;//the address space need jump from wkc to next datagram
    localparam  STM_ONCE_DG_FINISH  = 'd25;//one child datagram has process finish
    localparam  STM_RX_DONE         = 'd26;//all child datagram has process done
    localparam  STM_TX_PKG          = 'd27;//only used by slave mode.this stage read complete package from ecat cache and send to them to aurora tx port
    localparam  STM_END             = 'd29;

    localparam  CACHE_L_NUM     = 'd3;  //cahce buffer read latency
    localparam  SLV_DEPOT2CACHE = 'd5;  //the latency from depot to cache
    
    reg [5:0]   wk_state        = 'd0;
    reg [5:0]   wk_state_d1     = 'd0;
    reg [5:0]   wk_state_d2     = 'd0;
    reg [3:0]   latency_cnt     = 'd0;
    reg         latency_cnt_done;
    reg [15:0]  ethcat_len      = 'd0;
    reg [3:0]   ethcat_type     = 'd0;
    reg [15:0]  rd_cache_cnt    = 'd0;
    reg [15:0]  rd_cache_cnt_d1 = 'd0;
    reg [15:0]  rd_cache_cnt_d2 = 'd0;
    reg         rd_cache_done   = 'd0;
    reg [31:0]  data_buf[3:0];
    reg         cache_rd_en;
    reg         cache_rd_en_d1;
    reg         cache_rd_en_d2;
    reg [15:0]  cache_addr_nxt_bias;
    reg [7:0]   datagram_cmd    =   'd0;
    reg [7:0]   datagram_index  =   'd0;
    reg [31:0]  datagram_addr   =   'd0;
    reg [15:0]  datagram_len    =   'd0;
    reg         datagram_last   =   'D0;
    reg [7:0]   datagram_wkc    =   'd0;
    reg [7:0]   slv_sta_addr    =   'd0;
    reg [31:0]  slv_sta_id      =   'd0;
    reg [14:0]  rsv_tag         =   'd0;//reserve tag of datatram
    reg [15:0]  ira_tag         =   'd0;//irq tag of datatram
    reg [7:0]   rx_dg_cnt       =   'd0;//child datagram index counter
    reg [15:0]  depot_bias_addr =   'd0;//each child datagram operate the bias address of app depot,which is only used by slave mode
    always @(posedge clk)begin
        wk_state_d1     <=  wk_state;
        wk_state_d2     <=  wk_state_d1;
        rd_cache_cnt_d1 <=  rd_cache_cnt;
        rd_cache_cnt_d2 <=  rd_cache_cnt_d1;
    end

    always @( * )begin
        data_buf[0] <= cache_dout;
    end
    
    always @(posedge clk)begin
        if(reset)begin
            data_buf[1] <= 0;
            data_buf[2] <= 0;
        end if(cache_rd_en_d2)begin
            data_buf[1] <= data_buf[0];
            data_buf[2] <= data_buf[1];
        end else begin
            data_buf[1] <= data_buf[1];
            data_buf[2] <= data_buf[2];
        end
    end
    
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(rx_crc_vld & rx_crc_pass) begin
                        wk_state  <=  STM_CRC_PASS;
                    end else if(rx_crc_vld & !rx_crc_pass) begin
                        wk_state  <=  STM_CRC_FAIL;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_CRC_PASS:begin
                    wk_state  <=  STM_ETHCAT_HEAD;
                end
                STM_CRC_FAIL:begin
                    wk_state  <=  STM_END;
                end
                STM_ETHCAT_HEAD:begin
                    wk_state  <=  STM_ECAT_HD_L;
                end
                STM_ECAT_HD_L:begin
                    if(latency_cnt_done)begin
                        wk_state  <=  STM_ECAT_HD_PARSE;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_ECAT_HD_PARSE:begin
                    if(ethcat_type == `ETHCAT_TYPE_DATAGRAM)begin
                        wk_state  <=  STM_NXT_ADDR_EH;
                    end else if(ethcat_type == `ETHCAT_TYPE_HEARTBEAT)begin
                        wk_state  <=  STM_NXT_ADDR_EH;
                    end else if(ethcat_type == `ETHCAT_TYPE_INITIAL)begin
                        wk_state  <=  STM_NXT_ADDR_EH;
                    end else begin
                        wk_state  <=  STM_END;
                    end
                end
                STM_NXT_ADDR_EH:begin
                    wk_state  <=  STM_DATAGRAM_HEAD;
                end
                STM_DATAGRAM_HEAD:begin
                    if(rd_cache_done)begin
                        wk_state  <=  STM_DG_HD_L;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_DG_HD_L:begin
                    if(latency_cnt_done)begin
                        wk_state  <=  STM_DG_HD_PARSE;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_DG_HD_PARSE:begin
                    wk_state  <=  STM_DH2WKC_JUMP_ADDR;
                end
                STM_DH2WKC_JUMP_ADDR:begin
                    wk_state  <=  STM_RD_WKC;
                end
                STM_RD_DATAGRAM:begin
                    if(rd_cache_done)begin
                        wk_state  <=  STM_RD_DATAGRAM_L;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_DATAGRAM_L:begin
                    if(latency_cnt_done)begin
                        wk_state  <=  STM_RD_DG_PARSE;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_DG_PARSE:begin
//                    wk_state  <=  STM_DG_PRCS;
                    wk_state  <=  STM_NXT_ADDR_DG;  //mast station no need to write to cache buffer
                end
//                STM_DG_PRCS:begin
//                    if(rd_cache_done)begin
//                        wk_state  <=  STM_NXT_ADDR_DG;
//                    end else begin
//                        wk_state  <=  wk_state;
//                    end
//                end
                STM_NXT_ADDR_DG:begin
                    wk_state  <=  STM_ONCE_DG_FINISH;
                end
                STM_RD_WKC:begin
                    wk_state  <=  STM_RD_WKC_L;
                end
                STM_RD_WKC_L:begin
                    if(latency_cnt_done)begin
                        wk_state  <=  STM_RD_WKC_PARSE;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_WKC_PARSE:begin
                    wk_state  <=  STM_PRCS_WKC_L;
                end
                STM_PRCS_WKC_L:begin
                    wk_state  <=  STM_WKC2DG_JUMP_ADDR;
                end
//                STM_WKC2DH_JUMP_ADDR:begin
//                    wk_state  <=  STM_ONCE_DG_FINISH;
//                end
                STM_WKC2DG_JUMP_ADDR:begin
                    if(ethcat_type == `ETHCAT_TYPE_DATAGRAM)begin
                        wk_state  <=  STM_RX_HS;
                    end else begin
                        wk_state  <=  STM_RD_DATAGRAM;
                    end
                end
                STM_RX_HS:begin
                    if(prot_rcv_ack)begin
                        wk_state  <=  STM_RD_DATAGRAM;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_ONCE_DG_FINISH:begin
                    if(datagram_last | (cache_addr_nxt_bias > ethcat_len[15:2] ))begin
                        wk_state  <=  STM_RX_DONE;
                    end else begin
                        wk_state  <=  STM_DATAGRAM_HEAD;
                    end
                end
                STM_RX_DONE:begin
                    wk_state  <=  STM_END;
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
            STM_IDLE:begin
                rx_dg_cnt       <=  'd0;
                depot_bias_addr <=  'd0;
            end
            STM_ONCE_DG_FINISH:begin
                rx_dg_cnt       <=  rx_dg_cnt + 'd1;
                depot_bias_addr <=  depot_bias_addr + `EACH_CHILD_DEPOT_SIZE;
            end
            default: begin
                rx_dg_cnt       <=  rx_dg_cnt;
                depot_bias_addr <=  depot_bias_addr ;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_RX_DONE:begin
                prot_rcv_req    <=  'd0;
            end
            STM_RX_HS:begin
                prot_rcv_req    <=  'd1;
            end
            default: begin
                prot_rcv_req    <=  prot_rcv_req;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_ECAT_HD_L,STM_DG_HD_L,STM_RD_DATAGRAM_L,STM_RD_WKC_L,STM_PRCS_WKC_L:begin
                latency_cnt <=  latency_cnt + 1;
            end
            default: begin
                latency_cnt <=  0;
            end
        endcase
    end
    
    always @( * )begin
        case(wk_state)
            STM_PRCS_WKC_L:begin
                latency_cnt_done <= (latency_cnt == 5 - 1) ? 1'd1 : 1'd0;
            end
            default: begin
                latency_cnt_done <= (latency_cnt == CACHE_L_NUM - 1) ? 1'd1 : 1'd0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_DATAGRAM_HEAD,STM_RD_DATAGRAM,STM_RD_WKC,STM_DG_PRCS,STM_TX_PKG:begin
                rd_cache_cnt <= rd_cache_cnt + 'd1;
            end
            default: begin
                rd_cache_cnt <= 0;
            end
        endcase
    end
    
    always @( * ) begin
        case(wk_state)
            STM_DATAGRAM_HEAD:begin
                rd_cache_done <= (rd_cache_cnt == (`DATAGRAM_HEAD_LEN >>2 ) - 1);
            end
            STM_RD_DATAGRAM:begin
                if(ethcat_type == `ETHCAT_TYPE_DATAGRAM) begin
                    rd_cache_done <= (rd_cache_cnt == ((datagram_len[15:2]>>1) -1));
                end else begin
                    rd_cache_done <= (rd_cache_cnt == (datagram_len[15:2] -1));
                end
            end
//            STM_DG_PRCS:begin
//                if(ethcat_type == `ETHCAT_TYPE_DATAGRAM) begin
//                    rd_cache_done <= (rd_cache_cnt == ((datagram_len[15:2]>>1) + SLV_DEPOT2CACHE -1));
//                end else begin
//                    rd_cache_done <= (rd_cache_cnt == (datagram_len[15:2] -1));
//                end
//            end
            STM_RD_WKC:begin
                rd_cache_done <= (rd_cache_cnt == 0);
            end
            STM_TX_PKG:begin
                rd_cache_done <= (rd_cache_cnt == (ethcat_len[15:2] -1));
            end
            default: begin
                rd_cache_done <= 0;
            end
        endcase
    end
    
    wire    [47:0]  jump_dg_size;
    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                cache_addr_nxt_bias <= 'd0;
            end
            STM_NXT_ADDR_EH:begin
                cache_addr_nxt_bias <=  cache_addr_nxt_bias + (`ETHCAT_HEAD_LEN >>2);//ethcat head length is 1(4B).
            end
            STM_DH2WKC_JUMP_ADDR:begin
                cache_addr_nxt_bias <=  cache_addr_nxt_bias + (`DATAGRAM_HEAD_LEN >>2 ) + datagram_len[15:2];//datagram head length is 3(12B).
            end
            STM_NXT_ADDR_DG:begin
                cache_addr_nxt_bias <=  cache_addr_nxt_bias + datagram_len[15:2] + (`DATAGRAM_WKC_LEN >>2 );//datagram head length is 3(12B).
            end
            STM_WKC2DG_JUMP_ADDR:begin
                cache_addr_nxt_bias <=  cache_addr_nxt_bias - datagram_len[15:2];
            end
            STM_WKC2DH_JUMP_ADDR:begin
                cache_addr_nxt_bias <=  cache_addr_nxt_bias + (`DATAGRAM_WKC_LEN >>2 );//next datagram head
            end
            default: begin
                cache_addr_nxt_bias <= cache_addr_nxt_bias;
            end
        endcase
    end
    
    wire    [17:0]  each_rl_dg_size;//real datagram each buffer size
    wire    [17:0]  each_dg_head_size;
    wire    [17:0]  jump_dg_number;
    assign  each_rl_dg_size[17:0]   =   {4'd0,datagram_len[15:2]};
    assign  each_dg_head_size       =   4;
    assign  jump_dg_number          =   {18'd1};
    DSP_sumAD_multC_plusC calc_jump_dg_size_u (
      .CLK(clk),  // input wire CLK
      .A(each_rl_dg_size),      // input wire [17 : 0] A
      .B(jump_dg_number),      // input wire [17 : 0] B
      .C(48'd0),      // input wire [47 : 0] C
      .D(each_dg_head_size),      // input wire [17 : 0] D
      .P(jump_dg_size)      // output wire [47 : 0] P
    );
    
    always @(posedge clk) begin
        case(wk_state)
            STM_DG_PRCS:begin
                if(ethcat_type !== `ETHCAT_TYPE_DATAGRAM)begin
                    cache_we    <=  4'hf;
                end else begin
                    if(rd_cache_cnt == SLV_DEPOT2CACHE)begin
                        cache_we    <=  4'hf;
                    end else begin
                        cache_we    <=  cache_we;
                    end
                end
            end
            STM_PRCS_WKC_L:begin
                cache_we    <=  4'hf;
            end
            default: begin
                cache_we    <=  4'h0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_ETHCAT_HEAD,STM_DATAGRAM_HEAD,STM_RD_DATAGRAM,STM_RD_WKC,STM_TX_PKG:begin
                cache_rd_en <=  1;
            end
            STM_TX_PKG:begin
                cache_rd_en <=  1;
            end
            default: begin
                cache_rd_en <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_ETHCAT_HEAD,STM_DATAGRAM_HEAD,STM_RD_WKC:begin
                cache_addr  <=  cache_addr_nxt_bias + rd_cache_cnt;
            end
            STM_RD_DATAGRAM:begin
                if(ethcat_type !== `ETHCAT_TYPE_DATAGRAM)begin
                    cache_addr  <=  cache_addr_nxt_bias + rd_cache_cnt;
                end else begin
                    cache_addr  <=  cache_addr_nxt_bias + rd_cache_cnt + (datagram_len[15:2] >> 1);//数据包只需要读出接收区的数据报文
                end
            end
//            STM_DG_PRCS:begin//no use
//                if(ethcat_type !== `ETHCAT_TYPE_DATAGRAM)begin
//                    cache_addr  <=  cache_addr_nxt_bias + rd_cache_cnt;
//                end else begin
//                    cache_addr  <=  cache_addr_nxt_bias + rd_cache_cnt + (datagram_len[15:2] >> 1) - SLV_DEPOT2CACHE;
//                end
//            end
            STM_PRCS_WKC_L:begin
                cache_addr  <=  cache_addr_nxt_bias;
            end
            STM_TX_PKG:begin
                cache_addr  <=  rd_cache_cnt;
            end
            default: begin
                cache_addr  <=  cache_addr;
            end
        endcase
    end

    always @(posedge clk)begin
        cache_rd_en_d1  <=  cache_rd_en;
        cache_rd_en_d2  <=  cache_rd_en_d1;
    end
    
//    always @( * ) begin
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                ethcat_len  <=  'd0;
                ethcat_type <=  'd0;
            end
            STM_ECAT_HD_L:begin
                ethcat_len  <=  cache_dout[15:0];
                ethcat_type <=  cache_dout[31:28];
            end
            default: begin
                ethcat_len  <=  ethcat_len;
                ethcat_type <=  ethcat_type;
            end
        endcase
    end
    
//    always @( * ) begin
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                datagram_cmd            <=  'd0;
                datagram_index          <=  'd0;
                datagram_addr           <=  'd0;
                datagram_len            <=  'd0;
                datagram_last           <=  'd0;
                rsv_tag                 <=  'd0;
                ira_tag                 <=  'd0;
            end
            STM_DG_HD_L:begin
                datagram_cmd            <=  data_buf[2-0][7:0];
                datagram_index          <=  data_buf[2-0][15:8];
                datagram_addr[15:0]     <=  data_buf[2-0][31:16];
                datagram_addr[31:16]    <=  data_buf[2-1][15:0];
                datagram_len            <=  data_buf[2-1][31:16];
                datagram_last           <=  ~data_buf[2-2][15];
                rsv_tag                 <=  data_buf[2-2][14:0];
                ira_tag                 <=  data_buf[2-2][31:16];

            end
            default: begin
                datagram_cmd            <=  datagram_cmd;
                datagram_index          <=  datagram_index;
                datagram_addr           <=  datagram_addr;
                datagram_len            <=  datagram_len;
                datagram_last           <=  datagram_last;
                rsv_tag                 <=  rsv_tag;
                ira_tag                 <=  rsv_tag;
            end
        endcase
    end

//    always @( * ) begin
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                slv_id_we               <=  4'h0;
                slv_id_addr             <=  'd0;
                slv_id_din              <=  'd0;
            end
            STM_RD_DATAGRAM_L:begin
                if((ethcat_type == `ETHCAT_TYPE_INITIAL) & latency_cnt_done)begin
                    slv_id_we               <=  4'hf;
                    slv_id_addr             <=  data_buf[2-1][23:16];//从站地址
                    slv_id_din              <=  data_buf[2-2][31:0];//slave station id
                end else begin
                    slv_id_we               <=  4'h0;
                    slv_id_addr             <=  'd0;
                    slv_id_din              <=  'd0;
                end
            end
            default: begin
                slv_id_we               <=  4'h0;
                slv_id_addr             <=  slv_id_addr;
                slv_id_din              <=  slv_id_din;
            end
        endcase
    end

//    always @( * ) begin
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                ck_slv_hb_vld           <=  4'h0;
                ck_slv_hb_addr          <=  'd0;
                ck_slv_hb_data          <=  'd0;
            end
            STM_RD_DATAGRAM_L:begin
                if((ethcat_type == `ETHCAT_TYPE_HEARTBEAT) & latency_cnt_done)begin
                    ck_slv_hb_vld           <=  4'h1;
                    ck_slv_hb_addr          <=  data_buf[2-1][15:8];
                    ck_slv_hb_data          <=  data_buf[2-2][15:0];
                end else begin
                    ck_slv_hb_vld           <=  4'h0;
                    ck_slv_hb_addr          <=  'd0;
                    ck_slv_hb_data          <=  'd0;
                end
            end
            default: begin
                ck_slv_hb_vld               <=  4'h0;
                ck_slv_hb_addr              <=  ck_slv_hb_addr;
                ck_slv_hb_data              <=  ck_slv_hb_data;
            end
        endcase
    end

//    always @( * ) begin
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                datagram_wkc    <=  'd0;
            end
            STM_RD_WKC_L:begin
                datagram_wkc    <=  cache_dout[7:0];
            end
            default: begin
                datagram_wkc    <=  datagram_wkc;
            end
        endcase
    end

    always @(posedge clk) begin
        if(reset)begin
            slv_sta_num <=  'd0;
        end else if((wk_state == STM_RD_WKC_PARSE) && 
                    (ethcat_type == `ETHCAT_TYPE_INITIAL) &&
                    (rx_dg_cnt  ==  0))begin
            slv_sta_num <=  datagram_wkc ;
        end else begin
            slv_sta_num <=  slv_sta_num;
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                ecat_frm_rslt <=  'd0;
            end
            STM_CRC_FAIL:begin
                ecat_frm_rslt   <=  `ETHCAT_PRCS_CRC_FAIL;
            end
            STM_RX_DONE:begin
                ecat_frm_rslt   <=  `ETHCAT_PRCS_SUCCESS;
            end
            default: begin
                ecat_frm_rslt   <=  ecat_frm_rslt;
            end
        endcase
    end

    always @(posedge clk) begin
        if(reset)begin
            one_ecat_frm_done   <=  'd0;
            rx_eth_type         <=  'd0;
        end else begin
            case(wk_state)
                STM_END:begin
                    one_ecat_frm_done   <=  'd1;
                    rx_eth_type         <=   ethcat_type;
                end
                default: begin
                    one_ecat_frm_done   <=  'd0;
                    rx_eth_type         <=   rx_eth_type;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        case(wk_state_d2)
            STM_RD_DATAGRAM:begin
                if(ethcat_type == `ETHCAT_TYPE_DATAGRAM)begin
                    depot_we    <=  4'hf;
                    depot_addr  <=  rd_cache_cnt_d2  + depot_bias_addr;
                end else begin
                    depot_we    <=  4'h0;
                    depot_addr  <=  'd0;
                end
            end
            default: begin
                depot_we    <=  4'h0;
                depot_addr  <=  'd0;
            end
        endcase
    end
    assign  depot_din   =   (depot_we == 4'hf) ? cache_dout : 'd0;

    always @(posedge clk)begin
        cache_din   <=   0;
    end 
endmodule

