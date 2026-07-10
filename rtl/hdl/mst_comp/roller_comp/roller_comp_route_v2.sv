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
module roller_comp_route_v2
#(
     parameter  IN_CHAN_NUM     =   3'd1
    ,parameter  OUT_CHAN_NUM    =   3'd1
    ,parameter  WORK_OUT0_PATH  =   14'd1001
    ,parameter  WORK_OUT1_PATH  =   14'd1002
    ,parameter  WORK_OUT2_PATH  =   14'd1003
    ,parameter  TOKEN_DWIDTH    =   16
)
(
     input                              clk
    ,input                              reset

//  components interface
    ,emcc_token_if.sp                   s0_token_if
    ,emcc_token_if.sp                   s1_token_if
    ,emcc_token_if.sp                   s2_token_if

    ,emcc_token_if.mp                   m0_token_if
    ,emcc_token_if.mp                   m1_token_if
    ,emcc_token_if.mp                   m2_token_if

//  to kernel module slave interface
    ,output logic                       m_token_valid
    ,input  wire                        m_token_ready
    ,output logic     [TOKEN_DWIDTH-1:0]              m_token_data
    ,input  wire                        m_token_bvalid
    ,output reg                         m_token_bready
    ,input  wire    [2:0]               m_token_bresp

//  from kernel module master interface
    ,input  wire                        s_token_valid
    ,output reg                         s_token_ready
    ,input  wire    [TOKEN_DWIDTH-1:0]              s_token_data
    ,output reg                         s_token_bvalid
    ,input  wire                        s_token_bready
    ,output reg     [2:0]               s_token_bresp
//other
    ,input  wire    [2:0]               in_chan_seq
    ,input          [13:0]               path_msg_dat
    ,input          [2:0]               act_out_chan_num
);
    localparam  CHAN_NUM    =   3;

    reg [2:0]   out_chan_seq;
    //internel route module interface which is connected to upstream master interface
    wire            ups_s_token_valid_rs[CHAN_NUM-1:0];    //up stream token channel
    wire            ups_s_token_ready_rs[CHAN_NUM-1:0];    //up stream token channel
    wire    [TOKEN_DWIDTH-1:0]  ups_s_token_data_rs[CHAN_NUM-1:0];     //up stream token channel
    wire            ups_s_token_bvalid_rs[CHAN_NUM-1:0];   //up stream token channel
    wire            ups_s_token_bready_rs[CHAN_NUM-1:0];   //up stream token channel
    wire    [2:0]   ups_s_token_bresp_rs[CHAN_NUM-1:0];    //up stream token channel

    //internel route module interface which is connected to kernel module slave interface
    wire            m_token_valid_rs[CHAN_NUM-1:0];
    wire            m_token_ready_rs[CHAN_NUM-1:0];
    wire    [TOKEN_DWIDTH-1:0]  m_token_data_rs[CHAN_NUM-1:0];
    wire            m_token_bvalid_rs[CHAN_NUM-1:0];
    wire            m_token_bready_rs[CHAN_NUM-1:0];
    wire    [2:0]   m_token_bresp_rs[CHAN_NUM-1:0];

    //internel route module interface which is connected to downstream slave interface
    wire            dws_m_token_valid_rs[CHAN_NUM-1:0]; 
    wire            dws_m_token_ready_rs[CHAN_NUM-1:0]; 
    wire    [TOKEN_DWIDTH-1:0]  dws_m_token_data_rs[CHAN_NUM-1:0];  
    wire            dws_m_token_bvalid_rs[CHAN_NUM-1:0];
    wire            dws_m_token_bready_rs[CHAN_NUM-1:0];
    wire    [2:0]   dws_m_token_bresp_rs[CHAN_NUM-1:0]; 

    //internel route module interface which is connected to kernel module master interface
    wire            s_token_valid_rs[CHAN_NUM-1:0];
    wire            s_token_ready_rs[CHAN_NUM-1:0];
    wire    [TOKEN_DWIDTH-1:0]  s_token_data_rs[CHAN_NUM-1:0];
    wire            s_token_bvalid_rs[CHAN_NUM-1:0];
    wire            s_token_bready_rs[CHAN_NUM-1:0];
    wire    [2:0]   s_token_bresp_rs[CHAN_NUM-1:0];

    generate
        if((IN_CHAN_NUM ==  1) | (IN_CHAN_NUM ==  0)) begin:UPS_SINGLE_IN
            assign  s1_token_if.wready    =  m_token_ready;
            assign  s1_token_if.bvalid    =  m_token_bvalid;
            assign  s1_token_if.bresp     =  m_token_bresp;
        end else begin:UPS_MULTIPLE_IN
            //up stream -> route
            assign  ups_s_token_valid_rs[0] =   s0_token_if.wvalid;
            assign  ups_s_token_valid_rs[1] =   s1_token_if.wvalid;
            assign  ups_s_token_valid_rs[2] =   s2_token_if.wvalid;
            assign  ups_s_token_data_rs[0]  =   s0_token_if.wdata;
            assign  ups_s_token_data_rs[1]  =   s1_token_if.wdata;
            assign  ups_s_token_data_rs[2]  =   s2_token_if.wdata;
            assign  s0_token_if.wready      =   ups_s_token_ready_rs[0];
            assign  s1_token_if.wready      =   ups_s_token_ready_rs[1];
            assign  s2_token_if.wready      =   ups_s_token_ready_rs[2];

            assign  s0_token_if.bvalid  =   ups_s_token_bvalid_rs[0];
            assign  s1_token_if.bvalid  =   ups_s_token_bvalid_rs[1];
            assign  s2_token_if.bvalid  =   ups_s_token_bvalid_rs[2];
            assign  s0_token_if.bresp   =   ups_s_token_bresp_rs[0];
            assign  s1_token_if.bresp   =   ups_s_token_bresp_rs[1];
            assign  s2_token_if.bresp   =   ups_s_token_bresp_rs[2];

            assign  ups_s_token_bready_rs[0]    =   s0_token_if.bready;
            assign  ups_s_token_bready_rs[1]    =   s1_token_if.bready;
            assign  ups_s_token_bready_rs[2]    =   s2_token_if.bready;

            for (genvar j=0; j < IN_CHAN_NUM; j=j+1)begin:UPS_TOKEN_SLICE
                //route -> reg_slice
                axi_reg_slice
                #(
                     .DATA_WIDTH            (32 )
                    ,.FORWARD_REGISTERED    (1  )
                    ,.BACKWARD_REGISTERED   (1  )
                 )
                    ups_token_data_slice
                     (
                         .clk           (clk    )
                        ,.resetn        (~reset )
                        ,.s_axi_valid   (ups_s_token_valid_rs[j] )
                        ,.s_axi_ready   (ups_s_token_ready_rs[j] )
                        ,.s_axi_data    (ups_s_token_data_rs[j]  )
                        ,.m_axi_valid   (m_token_valid_rs[j]    )
                        ,.m_axi_ready   (m_token_ready_rs[j]    )
                        ,.m_axi_data    (m_token_data_rs[j]     )
                    );

                axi_reg_slice
                #(
                     .DATA_WIDTH            (3  )
                    ,.FORWARD_REGISTERED    (1  )
                    ,.BACKWARD_REGISTERED   (1  )
                 )
                    ups_token_resp_slice
                     (
                         .clk           (clk    )
                        ,.resetn        (~reset )
                        ,.s_axi_valid   (m_token_bvalid_rs[j]       )
                        ,.s_axi_ready   (m_token_bready_rs[j]       )
                        ,.s_axi_data    (m_token_bresp_rs[j]        )
                        ,.m_axi_valid   (ups_s_token_bvalid_rs[j]    )
                        ,.m_axi_ready   (ups_s_token_bready_rs[j]    )
                        ,.m_axi_data    (ups_s_token_bresp_rs[j]     )
                    );
                //reg_slice -> kernel slave
                assign  m_token_ready_rs[j]     =  (in_chan_seq == j) ? m_token_ready : 1'b0;
                assign  m_token_bvalid_rs[j]    =  (in_chan_seq == j) ? m_token_bvalid : 1'b0;
                assign  m_token_bresp_rs[j]     =  (in_chan_seq == j) ? m_token_bresp : 1'b0;
            end
        end
    endgenerate

    generate
        if((IN_CHAN_NUM ==  1) | (IN_CHAN_NUM ==  0)) begin:UPS_SINGLE_IN1
            assign  m_token_valid   =  s1_token_if.wvalid;
            assign  m_token_data    =  s1_token_if.wdata;
            assign  m_token_bready  =  s1_token_if.bready;
        end else begin:UPS_MULTIPLE_IN1
            //reg_slice -> kernel slave
            always @( * )begin
                m_token_valid       <=  0;
                m_token_data        <=  0;
                m_token_bready      <=  0;
                for (int k = 0; k < IN_CHAN_NUM; k++) begin
                    if (in_chan_seq == k) begin
                        m_token_valid       <=  m_token_valid_rs[k];
                        m_token_data        <=  m_token_data_rs[k];
                        m_token_bready      <=  m_token_bready_rs[k];
                    end
                end
            end
        end
    endgenerate

///////////////////////////////

    generate
        if((OUT_CHAN_NUM ==  1) | (OUT_CHAN_NUM ==  0)) begin:DWS_SINGLE_OUT
                assign  m1_token_if.wvalid     = s_token_valid;
                assign  m1_token_if.wdata      = s_token_data;
                assign  m1_token_if.bready     = s_token_bready;
        end else begin:DWS_MULTIPLE_OUT
            always @(posedge clk)begin
                if (path_msg_dat == WORK_OUT0_PATH) begin
                    out_chan_seq    <=  0;
                end else if (path_msg_dat == WORK_OUT1_PATH) begin
                    out_chan_seq    <=  1;
                end else if (path_msg_dat == WORK_OUT2_PATH) begin
                    out_chan_seq    <=  2;
                end
            end

            //route -> down stream
            assign  m0_token_if.wvalid =   dws_m_token_valid_rs[0];
            assign  m1_token_if.wvalid =   dws_m_token_valid_rs[1];
            assign  m2_token_if.wvalid =   dws_m_token_valid_rs[2];
            assign  m0_token_if.wdata  =   dws_m_token_data_rs[0]   ;
            assign  m1_token_if.wdata  =   dws_m_token_data_rs[1]   ;
            assign  m2_token_if.wdata  =   dws_m_token_data_rs[2]   ;
            assign  dws_m_token_ready_rs[0]      =   m0_token_if.wready;
            assign  dws_m_token_ready_rs[1]      =   m1_token_if.wready;
            assign  dws_m_token_ready_rs[2]      =   m2_token_if.wready;

            assign  dws_m_token_bvalid_rs[0]  =   m0_token_if.bvalid;
            assign  dws_m_token_bvalid_rs[1]  =   m1_token_if.bvalid;
            assign  dws_m_token_bvalid_rs[2]  =   m2_token_if.bvalid;
            assign  dws_m_token_bresp_rs[0]   =   m0_token_if.bresp ;
            assign  dws_m_token_bresp_rs[1]   =   m1_token_if.bresp ;
            assign  dws_m_token_bresp_rs[2]   =   m2_token_if.bresp ;

            assign  m0_token_if.bready    =   dws_m_token_bready_rs[0];
            assign  m1_token_if.bready    =   dws_m_token_bready_rs[1];
            assign  m2_token_if.bready    =   dws_m_token_bready_rs[2];

            for (genvar j=0; j < OUT_CHAN_NUM; j=j+1)begin:DWS_TOKEN_SLICE
                //kernel master -> reg_slice
                assign  s_token_valid_rs[j]     = (out_chan_seq == j) ? s_token_valid : 0;
                assign  s_token_data_rs[j]      = (out_chan_seq == j) ? s_token_data : 0;
                assign  s_token_bready_rs[j]    = (out_chan_seq == j) ? s_token_bready : 0;

                //regslice -> route
                axi_reg_slice
                #(
                     .DATA_WIDTH            (32 )
                    ,.FORWARD_REGISTERED    (1  )
                    ,.BACKWARD_REGISTERED   (1  )
                 )
                    dws_token_data_slice
                     (
                         .clk           (clk    )
                        ,.resetn        (~reset )
                        ,.s_axi_valid   (s_token_valid_rs[j]    )
                        ,.s_axi_ready   (s_token_ready_rs[j]    )
                        ,.s_axi_data    (s_token_data_rs[j]     )
                        ,.m_axi_valid   (dws_m_token_valid_rs[j] )
                        ,.m_axi_ready   (dws_m_token_ready_rs[j] )
                        ,.m_axi_data    (dws_m_token_data_rs[j]  )
                    );

                axi_reg_slice
                #(
                     .DATA_WIDTH            (3  )
                    ,.FORWARD_REGISTERED    (1  )
                    ,.BACKWARD_REGISTERED   (1  )
                 )
                    dws_token_resp_slice
                     (
                         .clk           (clk    )
                        ,.resetn        (~reset )
                        ,.s_axi_valid   (dws_m_token_bvalid_rs[j]    )
                        ,.s_axi_ready   (dws_m_token_bready_rs[j]    )
                        ,.s_axi_data    (dws_m_token_bresp_rs[j]     )
                        ,.m_axi_valid   (s_token_bvalid_rs[j]       )
                        ,.m_axi_ready   (s_token_bready_rs[j]       )
                        ,.m_axi_data    (s_token_bresp_rs[j]        )
                    );
            end
        end
    endgenerate

    generate
        if((OUT_CHAN_NUM ==  1) | (OUT_CHAN_NUM ==  0)) begin:DWS_SINGLE_OUT1
                assign  s_token_ready   = m1_token_if.wready;
                assign  s_token_bvalid  = m1_token_if.bvalid;
                assign  s_token_bresp   = m1_token_if.bresp;
        end else begin:DWS_MULTIPLE_OUT1
            //kernel master -> reg_slice
            always @( * )begin
                s_token_ready   <=  0;
                s_token_bvalid  <=  0;
                s_token_bresp   <=  0;
                for (int k = 0; k < OUT_CHAN_NUM; k++) begin
                    if (out_chan_seq == k) begin
                        s_token_ready   <=  s_token_ready_rs[k];
                        s_token_bvalid  <=  s_token_bvalid_rs[k];
                        s_token_bresp   <=  s_token_bresp_rs[k];
                    end
                end
            end
        end
    endgenerate

endmodule