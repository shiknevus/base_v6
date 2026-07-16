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
module depot_arbit
#(

)
(
     input  prot_clk             //prot_clk
    ,input  prot_reset           //prot_clk prot_reset
    ,input  app_clk
    ,input  app_reset
    ,input  prot_send_req//protocol layer
    ,output prot_send_ack
    ,input  app_depot_req
    ,output app_depot_ack
);
    localparam  STM_IDLE        =   'd0;
    localparam  STM_PROT_PRCS   =   'd1;
    localparam  STM_APP_PRCS    =   'd2;
    localparam  STM_END         =   'd3;
    reg [3:0]   wk_state    =   0;
    reg         app_depot_req_d1    =   'd0;
    reg         app_depot_req_d2    =   'd0;
    reg         app_depot_ack_r1    =   'd0;
    reg         app_depot_ack_r2    =   'd0;
    always @(posedge prot_clk)begin
        app_depot_req_d1    <=  app_depot_req;
        app_depot_req_d2    <=  app_depot_req_d1;
    end

    always @(posedge prot_clk)begin
        if(prot_reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(prot_send_req)begin
                        wk_state    <=  STM_PROT_PRCS;
                    end else if (app_depot_req_d2) begin
                        wk_state    <=  STM_APP_PRCS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_PROT_PRCS:begin
                    if(~prot_send_req)begin
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_APP_PRCS:begin
                    if(~app_depot_req_d2)begin
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
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
    
    assign  prot_send_ack   =   (wk_state == STM_PROT_PRCS) ? 1'b1 : 1'b0;

    always @(posedge app_clk)begin
        app_depot_ack_r1    <=  (wk_state == STM_APP_PRCS)  ? 1'b1 : 1'b0;
        app_depot_ack_r2    <=  app_depot_ack_r1;
    end
    assign  app_depot_ack   =   app_depot_ack_r2;
endmodule

