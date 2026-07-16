/**************

udp_rcv.v

Takes in data from IP_recv.v when udp_valid is high, strips the UDP header, and serves the raw data to the application layer.
Current implementation does not utilize checksum.

jdp45 hmm32 mjk64
ece 576
cornell univ
nov 07

**************/
module ethcat_rcv
#(
    parameter  WOKE_MODE   = "MAST"
)
(
     input                  clk
    ,input                  reset
    ,(* MARK_DEBUG="true" *)input                  s_ethcat_rx_sop
    ,(* MARK_DEBUG="true" *)input                  s_ethcat_rx_eop
    ,(* MARK_DEBUG="true" *)input                  s_ethcat_rx_vld
    ,(* MARK_DEBUG="true" *)input          [31:0]  s_ethcat_rx_dat
    ,input  wire            crc_valid
    ,input  wire            crc_pass_fail

    
    ,input          [3:0]   cache_we
    ,input          [15:0]  cache_addr
    ,input          [31:0]  cache_din
    ,output         [31:0]  cache_dout
    ,output                 rx_crc_vld
    ,output                 rx_crc_pass

    ,output                 test_sig
);

    localparam  RAM_DEPTH   =   (WOKE_MODE  == "MAST") ? 32768 : 32768;
`ifdef SIM_PLATFORM_MST
//    localparam  RAM_TYPE    =   "BLOCK";
    localparam  RAM_TYPE    =   "ULTRA";
`else
    localparam  RAM_TYPE    =   (WOKE_MODE  == "MAST") ? "ULTRA" : "BLOCK";
`endif

    localparam  RAM_DWIDTH  =   32;
    localparam  RAM_AWIDTH  =   $clog2(RAM_DEPTH);
(* MARK_DEBUG="true" *)    reg     [RAM_AWIDTH-1:0]    addra;
    wire    [RAM_DWIDTH-1:0]    dina;
    wire                        enb;
    wire    [RAM_AWIDTH-1:0]    addrb;
    wire    [RAM_DWIDTH-1:0]    dinb;
    wire    [RAM_DWIDTH-1:0]    doutb;
    wire    [3:0]               wea;
    wire    [3:0]               web;
    reg [7:0] backup_cnt  = 'd0;

    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          (RAM_TYPE       )
    )
        gen_ram_u
    (
         .clka  (clk        )
        ,.ena   (1          )
        ,.wea   (wea    )
        ,.addra (addra      )
        ,.dina  (dina       )
        ,.douta ()
        ,.clkb  (clk        )
        ,.enb   (enb          )
        ,.web   (web)
        ,.addrb (addrb      )
        ,.dinb  (dinb        )
        ,.doutb (doutb        )
    );
    assign  dina  =   s_ethcat_rx_dat;
    assign  wea   =   4'hf & {4{s_ethcat_rx_vld}};

    always @(posedge clk)begin
        if(reset)begin
            addra <=  'd0;
        end else if(s_ethcat_rx_eop)begin
            addra <=  'd0;
        end else if(s_ethcat_rx_vld)begin
            addra <=  addra + 1;
        end else begin
            addra <=  addra;
        end
    end

    assign  enb  =   1;
    assign  web         =   cache_we;
    assign  addrb       =   cache_addr;
    assign  dinb        =   cache_din;
    assign  cache_dout  =   doutb;
    
    assign  rx_crc_vld = crc_valid;
    assign  rx_crc_pass= ~crc_pass_fail;

endmodule
