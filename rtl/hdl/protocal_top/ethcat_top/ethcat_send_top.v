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
module ethcat_send_top
#(
    parameter  WOKE_MODE   = "MAST"
)
(
     input                  clk
    ,input                  reset
    
    //ethercat head content
    ,input          [15:0]  ethcat_length
    ,input          [3:0]   ethcat_type
    
    //axi stream interface is used to transfer tx package
    ,input                  s_app_tx_tvalid
    ,output                 s_app_tx_tready
    ,input                  s_app_tx_sop
    ,input                  s_app_tx_eop
    ,input          [31:0]  s_app_tx_tdata
    
    //axi stream interface to aurora IP
    ,output                 m_boroa_tx_tvalid
    ,input                  m_boroa_tx_tready
    ,output         [3:0]   m_boroa_tx_tkeep
    ,output                 m_boroa_tx_tlast
    ,output         [31:0]  m_boroa_tx_tdata

    //only used by slave mode,which is used to recive the package,
    //and transfer this package to aurora IP
    ,input  wire            s_slvsta_tx_sof
    ,input  wire            s_slvsta_tx_eof
    ,input  wire            s_slvsta_tx_tvalid
    ,input  wire    [31:0]  s_slvsta_tx_tdata
);

    //AXI stream interface from ethcat send module to crc module
    wire            m_ethcat_tx_tvalid;
    wire            m_ethcat_tx_tready;
    wire            m_ethcat_tx_sop;
    wire            m_ethcat_tx_eop;
    wire    [31:0]  m_ethcat_tx_tdata;

    generate
        if(WOKE_MODE ==  "MAST") begin:MAST
            ethcat_send
                ethcat_send_u
                (
                     .clk                   (clk)
                    ,.reset                 (reset)

                    //ethercat head content
                    ,.ethcat_length         (ethcat_length)
                    ,.ethcat_type           (ethcat_type)

                    //axi stream interface is used to transfer tx package
                    ,.s_app_tx_tvalid       (s_app_tx_tvalid)
                    ,.s_app_tx_tready       (s_app_tx_tready)
                    ,.s_app_tx_sop          (s_app_tx_sop)
                    ,.s_app_tx_eop          (s_app_tx_eop)
                    ,.s_app_tx_tdata        (s_app_tx_tdata)

                    //AXI stream interface from ethcat send module to crc module
                    ,.m_ethcat_tx_tvalid    (m_ethcat_tx_tvalid)
                    ,.m_ethcat_tx_tready    (m_ethcat_tx_tready)
                    ,.m_ethcat_tx_sop       (m_ethcat_tx_sop)
                    ,.m_ethcat_tx_eop       (m_ethcat_tx_eop)
                    ,.m_ethcat_tx_tdata     (m_ethcat_tx_tdata)
                );
        end else begin:SLAVE
            assign  m_ethcat_tx_tvalid  =   s_slvsta_tx_tvalid;
            assign  m_ethcat_tx_sop     =   s_slvsta_tx_sof;
            assign  m_ethcat_tx_eop     =   s_slvsta_tx_eof;
            assign  m_ethcat_tx_tdata   =   s_slvsta_tx_tdata;
        end
    endgenerate

    //TX CRC intf to send buffer
    wire    [0:31]     tx_data_crc;
    wire    [0:1]      tx_rem_crc;
    wire               tx_src_rdy_crc;
    wire               tx_sof_crc;
    wire               tx_eof_crc;
    wire               tx_dst_rdy_crc;

    tx_crc
        tx_crc_u
        (
            //downstream interface
             .DATA_DS       (tx_data_crc)
            ,.REM_DS        (tx_rem_crc)
            ,.SOF_N_DS      (tx_sof_crc_n)
            ,.EOF_N_DS      (tx_eof_crc_n)
            ,.SRC_RDY_N_DS  (tx_src_rdy_crc_n)
            ,.DST_RDY_N_DS  (0) //

            //upstream interface
            ,.DST_RDY_N_US  ()
            ,.DATA_US       (m_ethcat_tx_tdata)
            ,.REM_US        (2'b11)
            ,.SOF_N_US      (~m_ethcat_tx_sop)
            ,.EOF_N_US      (~m_ethcat_tx_eop)
            ,.SRC_RDY_N_US  (~m_ethcat_tx_tvalid)
            ,.RESET         (reset)
            ,.CLK           (clk)
        );

    ethcat_send_cache
        ethcat_send_cache_u
        (
             .clk               (clk)
            ,.reset             (reset)

            //updtream interface
            ,.s_crc_tx_tvalid   (~tx_src_rdy_crc_n)
            ,.s_crc_tx_tready   ()
            ,.s_crc_tx_sop      (~tx_sof_crc_n)
            ,.s_crc_tx_eop      (~tx_eof_crc_n)
            ,.s_crc_tx_tdata    (tx_data_crc)

            //downdtream interface
            ,.m_boroa_tx_tvalid (m_boroa_tx_tvalid)
            ,.m_boroa_tx_tready (m_boroa_tx_tready)
            ,.m_boroa_tx_tkeep  (m_boroa_tx_tkeep)
            ,.m_boroa_tx_tlast  (m_boroa_tx_tlast)
            ,.m_boroa_tx_tdata  (m_boroa_tx_tdata)
        );

endmodule

