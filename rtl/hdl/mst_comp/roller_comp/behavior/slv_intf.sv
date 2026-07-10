/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Luhui
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
module slv_intf
#(
      parameter  TOKEN_DWIDTH    =   16
)
(
     input  wire            clk
    ,input  wire            reset
    ,input  wire            comp_wk_en
    
    ,input  wire            ext_dev_req
    ,output reg             ext_dev_ack

    ,emcc_token_if.mp                   m1_token_if
);

    localparam  WAIT_BEAT_NUM           =   100_000_000;

    localparam  STM_IDLE                =   'd0;
    localparam  STM_WAIT_PERIP_REQ      =   'd1;
    localparam  STM_DEBOUNCE            =   'd2;
    localparam  STM_SEND_DWS_TOKEN      =   'd3;
    localparam  STM_WAIT_DWS_TOKEN_RESP =   'd4;
    localparam  STM_DWS_RESP_SUCCESS    =   'd5;
    localparam  STM_END                 =   'd10;

    reg         ext_dev_req_d1  =   'd0;
    reg         ext_dev_req_d2  =   'd0;
    reg         ext_dev_req_r   =   'd0;
 (* MARK_DEBUG="true" *)   reg [4:0]    wk_state    =   'd0;
 (* MARK_DEBUG="true" *)   reg    ext_dev_req_r_reg;
    reg     [$clog2(WAIT_BEAT_NUM):0]   wk_cnt      =   'd0;
    reg                 wk_cnt_done;

    always @(posedge clk)begin
        ext_dev_req_d1  <=  ext_dev_req;
        ext_dev_req_d2  <=  ext_dev_req_d1;
        ext_dev_req_r		<=	ext_dev_req_d1 & (~ext_dev_req_d2);
    end
    always @(posedge clk)begin
        ext_dev_req_r_reg  <=  ext_dev_req_r;
    end
    
    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(comp_wk_en)begin
                        wk_state    <=  STM_WAIT_PERIP_REQ;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_PERIP_REQ:begin
                    if(ext_dev_req_r)begin
                        wk_state    <=  STM_DEBOUNCE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_DEBOUNCE:begin
                    if(~ext_dev_req_d2)begin
                        wk_state    <=  STM_END;
                    end else if (wk_cnt_done & ext_dev_req_d2) begin
                        wk_state    <=  STM_SEND_DWS_TOKEN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_SEND_DWS_TOKEN:begin
                    if(m1_token_if.wready)begin
                        wk_state    <=  STM_WAIT_DWS_TOKEN_RESP;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_DWS_TOKEN_RESP:begin
                    if(m1_token_if.bvalid & m1_token_if.bready & (m1_token_if.bresp == 0))begin
                        wk_state    <=  STM_DWS_RESP_SUCCESS;
                    end else if(m1_token_if.bvalid & m1_token_if.bready & (m1_token_if.bresp == 1))begin
                        wk_state    <=  STM_DWS_RESP_SUCCESS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_DWS_RESP_SUCCESS:begin
                    wk_state    <=  STM_END;
                end
                STM_END:begin
                    wk_state    <=  STM_IDLE;
                end
                default:begin
                    wk_state    <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_DEBOUNCE:begin
                if(wk_cnt_done)begin
                    wk_cnt  <=  'd0;
                end else begin
                    wk_cnt  <=  wk_cnt + 'd1;
                end
            end
            default:begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @( * )begin
        case(wk_state)
            STM_DEBOUNCE:begin
                wk_cnt_done <=  (wk_cnt == WAIT_BEAT_NUM) ? 1'b1 : 1'b0;
            end
            default:begin
                wk_cnt_done <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                m1_token_if.wvalid  <=   1'b0;
                m1_token_if.wdata   <=   0;
            end
            STM_SEND_DWS_TOKEN:begin
                m1_token_if.wvalid  <=   m1_token_if.wready ? 1'b0 : 1'b1;
                m1_token_if.wdata   <=   16'hffff;
            end
            default:begin
                m1_token_if.wvalid  <=   1'b0;
                m1_token_if.wdata   <=   m1_token_if.wdata;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_WAIT_DWS_TOKEN_RESP:begin
                if(m1_token_if.bvalid & (!m1_token_if.bready))begin
                    m1_token_if.bready  <=  1'b1;
                end else begin
                    m1_token_if.bready  <=  1'b0;
                end
            end
            default:begin
                m1_token_if.bready  <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_WAIT_DWS_TOKEN_RESP:begin
                ext_dev_ack <=  'd1;
            end
            default:begin
                ext_dev_ack <=  'd0;
            end
        endcase
    end
endmodule