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
//       |<--------------------------32bit-------------------------->|
//       |  0        7 |  8       15   | 16        23 |  24      31  |
//       |     CMD     |     INDEX     |    DST ADDR_L(reg addr)     |
//       |  DST ADDR_H(slave station)  |       package length        |
//       |                           RSCV                            |
//       |-----------------------------------------------------------|
//       |                                                           |
//       |                           DATA                            |
//       |-----------------------------------------------------------|
/////////////////////////////////////////////////////////////////
module datagram_tx_rd(
     input              clk
    ,input              reset

    //the signals of tx controler to tx_rd module 
    ,input              datagram_rd_start
    ,output reg         datagram_rd_finish
    ,input              first_slv_sta   //first child datagram package
    ,input              last_slv_sta    //last child datagram package

    //ethercat and datagram header
    ,input      [3:0]   ethcat_tx_type
    ,input  wire[15:0]  datagram_rd_bias
    ,input      [7:0]   datagram_cmd
    ,input      [7:0]   datagram_index
    ,input      [31:0]  datagram_dst_addr
    ,input      [15:0]  datagram_pl_len
    ,   (* MARK_DEBUG="true" *)input      [7:0]   datagram_wkc
    ,input      [15:0]  datagram_uuid
    //app depot ll bus
    ,output             app_rd_en
    ,output     [15:0]  app_rd_addr
    ,input      [31:0]  app_rd_data
    
    //datagram axi stream to ethcat layer
    ,   (* MARK_DEBUG="true" *)output reg         m_app_tx_tvalid = 'd0
    ,   (* MARK_DEBUG="true" *)input              m_app_tx_tready
    ,   (* MARK_DEBUG="true" *)output reg         m_app_tx_sop
    ,   (* MARK_DEBUG="true" *)output reg         m_app_tx_eop
    ,   (* MARK_DEBUG="true" *)output reg [31:0]  m_app_tx_tdata

);
    localparam  SS_ADDR_CFG_MODE=   1;//slave station address config mode
    
    localparam  STM_IDLE        = 'd0;
    localparam  STM_HEAD_1st    = 'd1;
    localparam  STM_HEAD_2nd    = 'd2;
    localparam  STM_HEAD_3rd    = 'd3;
    localparam  STM_INIT_PKG    = 'd4;//transfe initial package
    localparam  STM_NOR_DG_1ST  = 'd5;//transfe normal package
    localparam  STM_DG_1ST_END  = 'd6;//transfe normal package
    localparam  STM_NOR_DG_2ND  = 'd7;//transfe normal package
    localparam  STM_HB_PKG      = 'd8;//transfe heartbeat package
    localparam  STM_WKC_TAG     = 'd9;//process work counter tag
    localparam  STM_END         = 'd10;
    
   (* MARK_DEBUG="true" *)    reg [4:0]   wk_state    = 'd0;
    reg [4:0]   wk_state_d1 = 'd0;
    reg [4:0]   wk_state_d2 = 'd0;
    reg         rd_app_done;
    reg [31:0]  work_cnt    = 0;
    reg [31:0]  work_cnt_d1 = 0;
    reg [31:0]  work_cnt_d2 = 0;
    wire        pkg_rdy;
    reg [15:0]  payload_len = 0;
    wire[14:0]  RSV_TAG;
    wire[15:0]  IRQ_TAG;
    assign  pkg_rdy = 1;

    assign  RSV_TAG   = 15'h7eef;
    assign  IRQ_TAG   = 16'hdead;

    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(datagram_rd_start) begin
                        wk_state  <=  STM_HEAD_1st;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_HEAD_1st:begin
                    wk_state  <=  STM_HEAD_2nd;
                end
                STM_HEAD_2nd:begin
                    wk_state  <=  STM_HEAD_3rd;
                end
                STM_HEAD_3rd:begin
                    if(ethcat_tx_type == `ETHCAT_TYPE_INITIAL)begin
                        wk_state  <=  STM_INIT_PKG;
                    end else if (ethcat_tx_type == `ETHCAT_TYPE_DATAGRAM)begin
                        wk_state  <=  STM_NOR_DG_1ST;
                    end else if (ethcat_tx_type == `ETHCAT_TYPE_HEARTBEAT)begin
                        wk_state  <=  STM_HB_PKG;
                    end
                end
                STM_NOR_DG_1ST:begin
                    if(rd_app_done)begin
                        wk_state  <=  STM_DG_1ST_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_DG_1ST_END:begin
                    wk_state  <=  STM_NOR_DG_2ND;
                end
                STM_NOR_DG_2ND,STM_INIT_PKG,STM_HB_PKG:begin
                    if(rd_app_done)begin
                        wk_state  <=  STM_WKC_TAG;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_WKC_TAG:begin
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
            STM_HB_PKG,STM_NOR_DG_1ST,STM_NOR_DG_2ND,STM_INIT_PKG:begin
                if(pkg_rdy)begin
                    work_cnt <= work_cnt + 1;
                end else begin
                    work_cnt  <=  work_cnt;
                end
            end
            default: begin
                work_cnt  <=  0;
            end
        endcase
    end

    always @( * ) begin
        case(wk_state)
            STM_END:begin
                datagram_rd_finish  <=  'd1;
            end
            default: begin
                datagram_rd_finish  <=  'd0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                payload_len <= 'd0;
            end
            STM_HEAD_1st:begin
                payload_len <= (datagram_pl_len >> 2);
            end
            default: begin
                payload_len <= payload_len;
            end
        endcase
    end
    
    always @( * )begin
        case(wk_state)
            STM_NOR_DG_1ST,STM_NOR_DG_2ND:begin
                rd_app_done <= (pkg_rdy & (work_cnt == (payload_len >> 1) - 1)) ? 1'b1 : 1'b0;
            end
            default: begin
                rd_app_done <= (pkg_rdy & (work_cnt == payload_len - 1)) ? 1'b1 : 1'b0;
            end
        endcase
    end
    assign  app_rd_addr = (wk_state == STM_NOR_DG_1ST) ? (work_cnt + datagram_rd_bias) : 0;
    assign  app_rd_en   = (wk_state == STM_NOR_DG_1ST);

    always @(posedge clk)begin
        wk_state_d1 <= wk_state;
        wk_state_d2 <= wk_state_d1;
        work_cnt_d1 <=  work_cnt;
        work_cnt_d2 <=  work_cnt_d1;
    end
    
    always @(posedge clk) begin
        case(wk_state_d2)
            STM_HEAD_1st:begin
                m_app_tx_tdata  <=  {datagram_dst_addr[15:0],
                                     datagram_index[7:0],
                                     datagram_cmd[7:0]};
            end
            STM_HEAD_2nd:begin
                m_app_tx_tdata  <=  {datagram_pl_len[15:0] + 0,
                                     datagram_dst_addr[31:16]};
            end
            STM_HEAD_3rd:begin
//                m_app_tx_tdata  <=  {IRQ_TAG[15:0],~last_slv_sta,RSV_TAG[14:0]};
                m_app_tx_tdata  <=  {datagram_uuid[15:0],~last_slv_sta,RSV_TAG[14:0]};
            end
            STM_HB_PKG:begin
                if(work_cnt_d2  ==  0)begin
                    m_app_tx_tdata[7:0]     <=  8'hff;
                    m_app_tx_tdata[15:8]    <=  datagram_dst_addr[23:16];
                    m_app_tx_tdata[31:16]   <=  16'h5555;//Ê±¼ä´Á
                end else begin
                    m_app_tx_tdata  <=  32'haaaa_5550 + datagram_dst_addr[23:16];
                end
            end
            STM_NOR_DG_1ST:begin
                m_app_tx_tdata  <=  app_rd_data;
            end
            STM_NOR_DG_2ND:begin
                m_app_tx_tdata  <=  0;
            end
            STM_INIT_PKG:begin
                if(work_cnt_d2  ==  0)begin
                    m_app_tx_tdata[7:0]     <=  SS_ADDR_CFG_MODE;
                    m_app_tx_tdata[15:8]    <=  datagram_dst_addr[23:16];
                    m_app_tx_tdata[23:16]   <=  8'hff;
                    m_app_tx_tdata[31:24]   <=  8'hdd;//reserve
                end else begin
                    m_app_tx_tdata  <=  32'h5555_7777 + datagram_dst_addr[23:16];
                end
            end
            STM_WKC_TAG:begin
                m_app_tx_tdata  <=  datagram_wkc;
            end
            default: begin
                m_app_tx_tdata  <=  32'd0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state_d2)
            STM_HEAD_1st,STM_HEAD_2nd,STM_HEAD_3rd,
            STM_INIT_PKG,STM_NOR_DG_1ST,STM_NOR_DG_2ND,STM_HB_PKG,STM_WKC_TAG:begin
                m_app_tx_tvalid <=  1;
            end
            default: begin
                m_app_tx_tvalid <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state_d2)
            STM_HEAD_1st:begin
                m_app_tx_sop <= first_slv_sta;
            end
            default: begin
                m_app_tx_sop <= 1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state_d2)
            STM_WKC_TAG:begin
                m_app_tx_eop <= last_slv_sta;
            end
            default: begin
                m_app_tx_eop <= 1'b0;
            end
        endcase
    end
endmodule

