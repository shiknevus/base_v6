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
module roller_startpoint
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
)
(
     input                              clk
    ,input                              reset

    ,input  [31:0]                      cur_timer

    ,output wire                        transfer_cw
    ,output wire                        transfer_ccw
    ,input  wire                        transfer_alm

    ,output wire                        valve_en
    ,input  wire                        valve_up_done
    ,input  wire                        valve_down_done

    ,input  wire                        mat_arrived         //materials in place

    ,input  wire                        roller_alm
    ,output wire                        roller_cw
    ,output wire                        roller_ccw
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
    ,emcc_token_if.mp                   m1_token_if

);
    localparam  IL_CHAN_EN  =   0;
    localparam  IC_CHAN_EN  =   0;
    localparam  IR_CHAN_EN  =   0;
    localparam  OL_CHAN_EN  =   0;
    localparam  OC_CHAN_EN  =   1;
    localparam  OR_CHAN_EN  =   0;

    wire            comp_wk_en;
    wire    [4:0]   comp_irq_type;
    wire                        int_ack_vld;
    wire    [7:0]               int_ack_dat;
    wire                        path_msg_vld;
    wire    [4:0]               path_msg_dat;
    wire    [2:0]               in_chan_seq;
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
    wire                        ps_cfg_token_vld;
    wire    [31:0]              ps_cfg_token_dat;
    wire                        comp_error;
    emcc_token_if #(.DATA_WIDTH(32))  s0_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  s1_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  s2_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  m0_token_if();
    emcc_token_if #(.DATA_WIDTH(32))  m2_token_if();

    roller_comp_cfg
    #(
         .REG_SPACE_BIAS    (REG_SPACE_BIAS )
        ,.REG_SPACE_SIZE    (REG_SPACE_SIZE )
        ,.PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
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
        
        ,.comp_wk_en        (comp_wk_en     )
        ,.comp_irq_type     (comp_irq_type  )
        ,.int_ack_vld       (int_ack_vld    )
        ,.int_ack_dat       (int_ack_dat    )
        ,.path_msg_vld      (path_msg_vld   )
        ,.path_msg_dat      (path_msg_dat   )
        ,.ps_cfg_token_vld  (ps_cfg_token_vld)
        ,.ps_cfg_token_dat  (ps_cfg_token_dat)
    );

    roller_comp_route
    #(
         .IL_CHAN_EN    (IL_CHAN_EN)
        ,.IC_CHAN_EN    (IC_CHAN_EN)
        ,.IR_CHAN_EN    (IR_CHAN_EN)
        ,.OL_CHAN_EN    (OL_CHAN_EN)
        ,.OC_CHAN_EN    (OC_CHAN_EN)
        ,.OR_CHAN_EN    (OR_CHAN_EN)
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
//
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

            ,.in_chan_seq               (in_chan_seq    )
//            ,.path_msg_dat              (path_msg_dat )
            ,.path_msg_dat              (1 )
        );

    roller_comp
    #(
         .IL_CHAN_EN    (IL_CHAN_EN     )
        ,.IC_CHAN_EN    (IC_CHAN_EN     )
        ,.IR_CHAN_EN    (IR_CHAN_EN     )
        ,.OL_CHAN_EN    (OL_CHAN_EN     )
        ,.OC_CHAN_EN    (OC_CHAN_EN     )
        ,.OR_CHAN_EN    (OR_CHAN_EN     )
    )
        roller_comp_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

            ,.cur_timer                 (cur_timer  )

    //driver interface
            ,.comp_error                (comp_error     )
            ,.scan_error                ()
            ,.mat_in_place              (mat_arrived)//materials in place
    
            ,.comp_in_start             ()
            ,.comp_out_start            ()
            ,.cfg_comp_done             ()
            ,.extra_opt_start           (extra_opt_start)
            ,.extra_opt_done            (extra_opt_start)

        //  ps interface
            //reg cfg interrupt
            ,.comp_wk_en                (comp_wk_en     )
            ,.comp_irq                  (comp_irq     )
            ,.comp_irq_type             (comp_irq_type)

            ,.path_msg_vld              (path_msg_vld )
            ,.path_msg_dat              (path_msg_dat )

            ,.int_ack_vld               (int_ack_vld  )
            ,.int_ack_dat               (int_ack_dat  )

            ,.ps_cfg_token_vld  (ps_cfg_token_vld)
            ,.ps_cfg_token_dat  (ps_cfg_token_dat)

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
            ,.in_chan_seq               (in_chan_seq    )
        );

//    roller_comp_driver
//    #(

//    )
//        roller_comp_driver_u
//        (

//        );

endmodule