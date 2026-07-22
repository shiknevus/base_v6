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
module datagram_tx_ctrl(
     input              clk
    ,input              reset
    //these control signals from up protocol layer 
    ,input              pkg_trsf_start  ////indicate that one datagram could been transfer
    ,input  [3:0]       ethcat_tx_type
    ,input  [7:0]       datagram_tx_cmd
    ,input  [15:0]      datagram_tx_len
    ,   (* MARK_DEBUG="true" *)input  [7:0]       datagram_tx_num
    ,input  [15:0]      datagram_tx_uuid

    ,output reg             prot_send_req
    ,input  wire            prot_send_ack
    //current datagram heartbeat dst address,which drive datagram layer
    ,input  [31:0]      dg_hb_dst_addr//datagram heartbeat dst address
    
    //the control interface during tx_controller and tx_read
    ,output reg         datagram_rd_start
    ,input              datagram_rd_finish
    ,output reg         first_slv_sta       //first child datagram package
    ,output reg         last_slv_sta        //last child datagram package

    ,output reg [15:0]  datagram_rd_bias    //depot read bias address during current child datagram
        //notice tx_rd module that current dg header content
    ,output reg [7:0]   datagram_index
    ,output reg [31:0]  datagram_dst_addr
    ,output reg [15:0]  datagram_pl_len    //datagram payload length(unit:BYTE)
    ,output reg [7:0]   datagram_cmd
    ,output reg [15:0]  datagram_uuid
    ,output reg [7:0]   datagram_wkc
);

    localparam  STM_IDLE        = 'd0;
    localparam  STM_TRSF_INIT   = 'd1;  //transfer initial datagram package
    localparam  STM_TRSF_HB     = 'd2;  //transfer initial heartbeat package
    localparam  STM_TX_HS       = 'd3;
    localparam  STM_RD_DATAGRAM = 'd6;  //start reading datagram from app depot
    localparam  STM_WAIT_TRSF   = 'd7;  //wait that reading operation finished
    localparam  STM_ONCE_FINISH = 'd8;  //once datagram operation is finished
    localparam  STM_ALL_FINISH  = 'd9;  //all datagram operation is finished
    localparam  STM_END         = 'd10;
   (* MARK_DEBUG="true" *)    reg [4:0]   wk_state     = 'd0;
    reg [15:0]  slv_sta_cnt;//slave station index cnt
    wire        last_slv_trsf;
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(pkg_trsf_start & (ethcat_tx_type == `ETHCAT_TYPE_INITIAL)) begin
                        wk_state  <=  STM_TRSF_INIT;
                    end else if(pkg_trsf_start & (ethcat_tx_type == `ETHCAT_TYPE_DATAGRAM)) begin
                        wk_state  <=  STM_TX_HS;
                    end else if(pkg_trsf_start & (ethcat_tx_type == `ETHCAT_TYPE_HEARTBEAT)) begin
                        wk_state  <=  STM_TRSF_HB;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TRSF_INIT:begin
                    wk_state  <=  STM_WAIT_TRSF;
                end
                STM_TX_HS:begin
                    if(prot_send_ack)begin
                        wk_state  <=  STM_RD_DATAGRAM;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_DATAGRAM:begin
                    wk_state  <=  STM_WAIT_TRSF;
                end
                STM_TRSF_HB:begin
                    wk_state  <=  STM_WAIT_TRSF;
                end
                STM_WAIT_TRSF:begin
                    if(datagram_rd_finish)begin
                        wk_state  <=  STM_ONCE_FINISH;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_ONCE_FINISH:begin
                    if(last_slv_trsf)begin
                        wk_state  <=  STM_ALL_FINISH;
                    end else if(ethcat_tx_type == `ETHCAT_TYPE_INITIAL)begin
                        wk_state  <=  STM_TRSF_INIT;
                    end else if(ethcat_tx_type == `ETHCAT_TYPE_DATAGRAM)begin
                        wk_state  <=  STM_TX_HS;
                    end
                end
                STM_ALL_FINISH:begin
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
            STM_IDLE,STM_ALL_FINISH:begin
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
        case(wk_state)
            STM_TRSF_HB,STM_RD_DATAGRAM,STM_TRSF_INIT:begin
                datagram_rd_start   <= 1;
            end
            default: begin
                datagram_rd_start   <= 0;
            end
        endcase
    end

    always @(posedge clk) begin
        if(reset)begin
            datagram_index  <=  'd0;
        end else if(wk_state == STM_ALL_FINISH)begin
            datagram_index  <=  datagram_index + 1;
        end else begin
            datagram_index  <=  datagram_index;
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                datagram_rd_bias    <= 'd0;
            end
            STM_ONCE_FINISH:begin
                datagram_rd_bias    <= datagram_rd_bias + `EACH_CHILD_DEPOT_SIZE;
            end
            default: begin
                datagram_rd_bias    <= datagram_rd_bias;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                slv_sta_cnt         <=  'd0;
            end
            STM_ONCE_FINISH:begin
                slv_sta_cnt         <= slv_sta_cnt + 1;
            end
            default: begin
                slv_sta_cnt         <= slv_sta_cnt;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                datagram_wkc    <=  8'h01;
            end
            STM_TRSF_INIT:begin
                datagram_wkc    <=  datagram_wkc - 'd1;
            end
            STM_RD_DATAGRAM:begin
                datagram_wkc    <=  datagram_wkc - 'd1;
            end
            STM_TRSF_HB:begin
                datagram_wkc    <=  datagram_wkc - 'd1;
            end
            default: begin
                datagram_wkc    <=  datagram_wkc;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                datagram_dst_addr   <=  'd0;
            end
            STM_TRSF_INIT:begin
                datagram_dst_addr   <=  {slv_sta_cnt[15:0],16'd0};
            end
            STM_RD_DATAGRAM:begin
                datagram_dst_addr   <=  {slv_sta_cnt[15:0],16'd0};
            end
            STM_TRSF_HB:begin
                datagram_dst_addr   <=  {dg_hb_dst_addr[15:0],16'd0};
            end
            default: begin
                datagram_dst_addr   <=  datagram_dst_addr;
            end
        endcase
    end
    
    assign  last_slv_trsf = (slv_sta_cnt == (datagram_tx_num - 1)) ? 1'b1 : 1'b0;

    always @(posedge clk)begin
        datagram_pl_len   <=  datagram_tx_len;
    end

    always @(posedge clk)begin
        datagram_cmd    <=  datagram_tx_cmd;
    end

    always @(posedge clk)begin
        datagram_uuid    <=  datagram_tx_uuid;
    end

    always @( * )begin
        last_slv_sta <= last_slv_trsf;
    end

    always @( * )begin
        first_slv_sta <= (slv_sta_cnt == 0);
    end
endmodule