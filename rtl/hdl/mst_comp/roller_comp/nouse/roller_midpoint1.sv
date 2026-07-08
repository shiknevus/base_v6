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
module roller_midpoint1
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
    ,parameter  IN_CHAN_NUM     =   3'd1
    ,parameter  OUT_CHAN_NUM    =   3'd1
    ,parameter  CUR_LOCATION    =   14'd1103
    ,parameter  WORK_OUT0_PATH  =   14'd1111
    ,parameter  WORK_OUT1_PATH  =   14'd1105
    ,parameter  WORK_OUT2_PATH  =   14'd1112
)
(
     input                              clk
    ,input                              reset
    ,input  [31:0]                      cur_timer

    ,input wire                         mat_arrived
    ,input wire                         dgt_error      
    ,output wire                        dgt_start      
    ,output wire                        dgt_start_f
    ,input wire                         yzqg_up
    ,input wire                         yzqg_down
    ,output wire                        yzqg_out
    ,output wire                        yzdj_start_z
    ,output wire                        yzdj_start_f
    
//  ps interface
    //reg cfg interface
    ,input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,input  wire                        ps_reg_we
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,input  wire                        ps_reg_re
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,output wire                        ps_reg_rd_vld
    ,output wire    [PS_REG_DWIDTH-1:0] ps_reg_rd_dat
    //reg cfg interrupt
    ,output wire                        comp_irq
//  components interface
    //,emcc_token_if.sp                   s0_token_if
    ,emcc_token_if.sp                   s1_token_if
    //,emcc_token_if.sp                   s2_token_if

    //,emcc_token_if.mp                   m0_token_if
    //,emcc_token_if.mp                   m1_token_if
    //,emcc_token_if.mp                   m2_token_if
);
    
    wire    [31:0]              comp_wk_para;
    wire    [7:0]               comp_irq_type;
    wire                        int_ack_vld;
    wire    [7:0]               int_ack_dat;
    wire                        path_msg_vld;
    wire    [13:0]              path_msg_dat;
    wire    [2:0]               in_chan_seq;
    wire    [15:0]              cur_token_dat;
    wire                        ps_cfg_token_vld;
    wire    [31:0]              ps_cfg_token_dat;

    wire                        route_m_token_valid;
    wire                        route_m_token_ready;
    wire    [31:0]              route_m_token_data;
    wire                        route_m_token_bvalid;
    wire                        route_m_token_bready;
    wire    [2:0]               route_m_token_bresp;

    wire                        route_s_token_valid;
    wire                        route_s_token_ready;
    wire    [31:0]              route_s_token_data;
    wire                        route_s_token_bvalid;
    wire                        route_s_token_bready;
    wire    [2:0]               route_s_token_bresp;
    
    wire                        comp_in_start;
    wire                        comp_out_start;
    wire                        cfg_comp_done;
    wire                        cfg_comp_done2;
    wire                        mat_in_place;
    wire                        comp_error;
    wire                        extra_opt_start;
    wire                        extra_opt_done;
    
    emcc_token_if #(.DATA_WIDTH(32))  s0_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  s2_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  m0_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  m1_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  m2_token_if();

    roller_comp_cfg
    #(
         .REG_SPACE_BIAS    (REG_SPACE_BIAS )
        ,.REG_SPACE_SIZE    (REG_SPACE_SIZE )
        ,.PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
        ,.CUR_LOCATION      (CUR_LOCATION   )
    )
    roller_comp_cfg_u
    (
         .ps_reg_clk        (ps_reg_clk     )
        ,.ps_reg_reset      (ps_reg_reset   )
        ,.ps_reg_we         (ps_reg_we      )
        ,.ps_reg_addr       (ps_reg_addr    )
        ,.ps_reg_wr_dat     (ps_reg_wr_dat  )
        ,.ps_reg_re         (ps_reg_re      )
        ,.ps_reg_rd_addr    (ps_reg_rd_addr )
        ,.ps_reg_rd_vld     (ps_reg_rd_vld  )
        ,.ps_reg_rd_dat     (ps_reg_rd_dat  )
        
        ,.comp_wk_para      (comp_wk_para   )
        ,.comp_irq_type     (comp_irq_type  )
        ,.int_ack_vld       (int_ack_vld    )
        ,.int_ack_dat       (int_ack_dat    )
        ,.path_msg_vld      (path_msg_vld   )
        ,.path_msg_dat      (path_msg_dat   )
        ,.cur_token_dat     (cur_token_dat  )
        ,.ps_cfg_token_vld  (ps_cfg_token_vld   )
        ,.ps_cfg_token_dat  (ps_cfg_token_dat   )
    );

    roller_comp_route
    #(
         .IN_CHAN_NUM       (IN_CHAN_NUM    )
        ,.OUT_CHAN_NUM      (OUT_CHAN_NUM   )
        ,.WORK_OUT0_PATH    (WORK_OUT0_PATH )
        ,.WORK_OUT1_PATH    (WORK_OUT1_PATH )
        ,.WORK_OUT2_PATH    (WORK_OUT2_PATH )
    )
        roller_comp_route_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  components interface
            ,.s0_token_if               (s0_token_if)
            ,.s1_token_if               (s1_token_if)
            ,.s2_token_if               (s2_token_if)

            ,.m0_token_if               (m0_token_if)
            ,.m1_token_if               (m1_token_if)
            ,.m2_token_if               (m2_token_if)

            ,.m_token_valid             (route_m_token_valid  )
            ,.m_token_ready             (route_m_token_ready  )
            ,.m_token_data              (route_m_token_data   )
            ,.m_token_bvalid            (route_m_token_bvalid )
            ,.m_token_bready            (route_m_token_bready )
            ,.m_token_bresp             (route_m_token_bresp  )

            ,.s_token_valid             (route_s_token_valid  )
            ,.s_token_ready             (route_s_token_ready  )
            ,.s_token_data              (route_s_token_data   )
            ,.s_token_bvalid            (route_s_token_bvalid )
            ,.s_token_bready            (route_s_token_bready )
            ,.s_token_bresp             (route_s_token_bresp  )

            ,.in_chan_seq               (in_chan_seq  )
            ,.path_msg_dat              (path_msg_dat )
        );

    roller_comp
    #(
        .IN_CHAN_NUM       (IN_CHAN_NUM    )
        ,.OUT_CHAN_NUM      (OUT_CHAN_NUM   )
    )
        roller_comp_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            ,.cur_timer                 (cur_timer  )

            //driver interface
            ,.comp_in_start             (comp_in_start  )
            ,.comp_out_start            (comp_out_start )
            ,.cfg_comp_done             (cfg_comp_done  )
            ,.cfg_comp_done2            (cfg_comp_done2 )
            ,.mat_in_place              (mat_in_place   )
            ,.comp_error                (comp_error     )
            ,.extra_opt_start           (extra_opt_start)
            ,.extra_opt_done            (extra_opt_done )

            //reg cfg interrupt
            ,.comp_wk_en                (comp_wk_para[31:31])
            ,.comp_irq                  (comp_irq     )
            ,.comp_irq_type             (comp_irq_type)

            ,.path_msg_vld              (path_msg_vld )
            ,.path_msg_dat              (path_msg_dat )

            ,.int_ack_vld               (int_ack_vld  )
            ,.int_ack_dat               (int_ack_dat  )
            ,.cur_token_dat             (cur_token_dat)
            ,.ps_cfg_token_vld          (ps_cfg_token_vld     )
            ,.ps_cfg_token_dat          (ps_cfg_token_dat     )
        //  components interface
            ,.s_token_valid             (route_m_token_valid  )
            ,.s_token_ready             (route_m_token_ready  )
            ,.s_token_data              (route_m_token_data   )
            ,.s_token_bvalid            (route_m_token_bvalid )
            ,.s_token_bready            (route_m_token_bready )
            ,.s_token_bresp             (route_m_token_bresp  )

            ,.m_token_valid             (route_s_token_valid  )
            ,.m_token_ready             (route_s_token_ready  )
            ,.m_token_data              (route_s_token_data   )
            ,.m_token_bvalid            (route_s_token_bvalid )
            ,.m_token_bready            (route_s_token_bready )
            ,.m_token_bresp             (route_s_token_bresp  )
//other
            ,.in_chan_seq               (in_chan_seq   )
        );
        
    rll_ic_oc_comp
    #(
        .IN_CHAN_NUM        (IN_CHAN_NUM    )
        ,.OUT_CHAN_NUM      (OUT_CHAN_NUM   )
        ,.WORK_OUT1_PATH    (WORK_OUT1_PATH )
    )   
        rll_ic_oc_comp_u
        (
            .clk                        (clk            )
            ,.reset                     (reset          )
            ,.time_delay                (comp_wk_para[15:0])

            ,.comp_in_start             (comp_in_start  )
            ,.comp_out_start            (comp_out_start )
            ,.cur_in_path               (in_chan_seq    )
            ,.cur_out_path              (WORK_OUT1_PATH )
            ,.cfg_comp_done             (cfg_comp_done  )
            ,.cfg_comp_done2            (cfg_comp_done2 )
            ,.comp_error                (comp_error     )
            ,.mat_in_place              (mat_in_place   )
            ,.extra_opt_start           (extra_opt_start)
            ,.extra_opt_done            (extra_opt_done )

            ,.mf                        (mat_arrived    )
            ,.dgt_error                 (dgt_error      )
            ,.dgt_start                 (dgt_start      )
            ,.dgt_start_f               (dgt_start_f    )
            ,.yzqg_up                   (yzqg_up        )
            ,.yzqg_down                 (yzqg_down      )
            ,.yzqg_out                  (yzqg_out       )
            ,.yzdj_start_z              (yzdj_start_z   )
            ,.yzdj_start_f              (yzdj_start_f   )
        );

endmodule