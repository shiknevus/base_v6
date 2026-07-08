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
module ethcat_send(
     input              clk
    ,input              reset
    
    //ethercat head content
    ,input  [15:0]      ethcat_length
    ,input  [3:0]       ethcat_type

    //axi stream interface from upstream protocol layer(datagram)
    ,input              s_app_tx_tvalid
    ,output             s_app_tx_tready
    ,input              s_app_tx_sop
    ,input              s_app_tx_eop
    ,input  [31:0]      s_app_tx_tdata
    
    //axi stream interface to downstream(crc module)
    ,output reg         m_ethcat_tx_tvalid = 'd0
    ,input              m_ethcat_tx_tready
    ,output reg         m_ethcat_tx_sop
    ,output reg         m_ethcat_tx_eop
    ,output reg [31:0]  m_ethcat_tx_tdata

);

    localparam  STM_IDLE        = 'd0;
    localparam  STM_HEAD_1st    = 'd1;
    localparam  STM_PAYLOAD     = 'd4;
    localparam  STM_BACKUP      = 'd5;
    localparam  STM_EOP         = 'd6;
    localparam  STM_END         = 'd7;
    
    reg [31:0]  data_buf;
    reg [31:0]  data_buf_d1;
    reg [4:0]   wk_state    = 'd0;
    reg         data_buf_vld;
    reg         data_buf_vld_d1;
    reg [7:0]   backup_cnt  = 'd0;

    always @(posedge clk)begin
        data_buf    <= s_app_tx_tdata;
        data_buf_d1 <=  data_buf;
    end
    
    always @(posedge clk)begin
        data_buf_vld    <=  s_app_tx_tvalid;
        data_buf_vld_d1 <=  data_buf_vld;
    end
    
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(s_app_tx_sop) begin
                        wk_state  <=  STM_HEAD_1st;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_HEAD_1st:begin
                    wk_state  <=  STM_PAYLOAD;
                end
                STM_PAYLOAD:begin
                    if(s_app_tx_eop)begin
                        wk_state  <=  STM_BACKUP;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_BACKUP:begin
                    if(backup_cnt ==  'd1) begin
                        wk_state  <=  STM_EOP;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_EOP:begin
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
            STM_HEAD_1st: begin
              backup_cnt  <=  backup_cnt  + 'd1;
            end
            STM_PAYLOAD: begin
              backup_cnt  <=  backup_cnt;
            end
            STM_BACKUP: begin
              backup_cnt  <=  backup_cnt  - 'd1;
            end
            default: begin
              backup_cnt  <=  'd0;
            end
        endcase
    end


    always @(posedge clk) begin
        case(wk_state)
            STM_HEAD_1st:begin
                m_ethcat_tx_tdata  <=  {ethcat_type[3:0],12'd0,ethcat_length[15:0]};
            end
            STM_PAYLOAD,STM_BACKUP,STM_EOP:begin
                m_ethcat_tx_tdata  <=  data_buf_d1;
            end
            default: begin
                m_ethcat_tx_tdata  <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_HEAD_1st,STM_EOP:begin
                m_ethcat_tx_tvalid <= 1;
            end
            STM_PAYLOAD,STM_BACKUP:begin
                m_ethcat_tx_tvalid  <=  data_buf_vld_d1;
            end
            default: begin
                m_ethcat_tx_tvalid  <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_HEAD_1st:begin
                m_ethcat_tx_sop  <=  1;
            end
            default: begin
                m_ethcat_tx_sop  <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_EOP:begin
                m_ethcat_tx_eop  <=  1;
            end
            default: begin
                m_ethcat_tx_eop  <=  0;
            end
        endcase
    end
endmodule

