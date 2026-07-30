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
module mst_app_cfg
#(
     parameter  REG_SPACE_BIAS  =   0
    ,parameter  REG_SPACE_SIZE  =   512
    ,parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
)
(
     input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,input  wire                        ps_reg_we
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,input  wire                        ps_reg_re
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,output reg                         ps_reg_rd_vld
    ,output reg     [PS_REG_DWIDTH-1:0] ps_reg_rd_dat

    ,input  wire                        prot_clk
    ,input  wire    [3:0]               slv_id_we
    ,input  wire    [15:0]              slv_id_addr
    ,input  wire    [31:0]              slv_id_din
    ,input  wire    [31:0]              slv_fpga_version
	
	,output reg  [31:0] debug_data
	
	,input  wire             			init_error    // From prot_clk domain
	,output reg             			init_err_clr
	,input wire            				init_err
	,output reg             			cnt_err_clr
	,input wire	[31:0]  				cnt_err
	,input wire            				init_finish
	,input  wire    [2:0]               err_code      // From prot_clk domain (synchronized)
    
    ,input  wire    [15:0]              board_temp_82130
    
    ,output reg                         o_do_dbg_data_vld
    ,output reg     [31:0]              ov_io_mode_cfg // set config mode
    ,input  wire    [31:0]              iv_rd_io_data  // read input or output io data
    ,output reg     [31:0]              ov_do_dbg_data // write output io data
    ,output reg                         o_read_dbg_data_done
    ,output reg                         o_wr_cfg_data_done

    ,input                              link_success
    ,input  wire                        loop_link_success
    ,input  wire                        app_err_flag        //the error type of slave station is valid
    ,input  wire    [7:0]               app_err_type        //the error type of slave station
    ,input  wire    [7:0]               hb_err_slvsta       //indicate the index of the error station //指示产生链接错误的从站
    ,input  wire    [7:0]               slv_sta_num     //this signals only update during first initial datagram.It indicate the number of slave station

    ,output wire                        ps_tst_trsf_port
    ,output wire                        ps_trsf_port_en
    ,input  wire    [31:0]              stat_rslt
    ,output wire                        ps_loopback_flag
    ,output reg                         ps_tx_req
    ,output reg                         ps_rd_depot_flag
    ,output reg                         opt_intf_init_en
    ,output reg                         hb_scan_req  // PS manual heartbeat scan trigger
);
    
    localparam  STM_IDLE        = 'd0;
    localparam  STM_INI        	= 'd1;
    localparam  STM_INI_DONE    = 'd2;
    localparam  STM_RUN     	= 'd3;
	
    reg     ps_reg_re_d1;
    reg     ps_reg_re_d2;
    reg     ps_reg_re_d3;
    reg     ps_reg_re_d4;
    reg     ps_reg_re_d5;
    wire    wr_space_select;
    wire    rd_space_select;
    wire    [PS_REG_AWIDTH-1:0] wr_reg_addr;
    wire    [PS_REG_AWIDTH-1:0] rd_reg_addr;
    reg     [PS_REG_AWIDTH-1:0] rd_reg_addr_d1;
    reg     [PS_REG_AWIDTH-1:0] rd_reg_addr_d2;
    wire                        link_status;
	
	reg							init_finish_d1;
	reg							init_finish_d2;
	
	// Synchronized versions of signals from prot_clk domain
	reg                         init_error_d1;
	reg                         init_error_d2;
	reg     [2:0]               err_code_d1;
	reg     [2:0]               err_code_d2;
	reg     [7:0]               app_err_type_d1;
	reg     [7:0]               app_err_type_d2;
	reg     [7:0]               hb_err_slvsta_d1;
	reg     [7:0]               hb_err_slvsta_d2;
	
    assign  wr_space_select =   ((ps_reg_addr >= REG_SPACE_BIAS) & (ps_reg_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'd1 : 1'd0;
    assign  rd_space_select =   ((ps_reg_rd_addr >= REG_SPACE_BIAS) & (ps_reg_rd_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'd1 : 1'd0;
    assign  wr_reg_addr     =   ps_reg_addr     - REG_SPACE_BIAS;
    assign  rd_reg_addr     =   ps_reg_rd_addr  -   REG_SPACE_BIAS;
/////////////////////////////////////////
    (* MARK_DEBUG="true" *)reg [31:0]  mst_app_wk_mode;
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            mst_app_wk_mode <=  'd0;
        end else if((wr_reg_addr == `MST_APP_MODE_ADDR) & ps_reg_we)begin
            mst_app_wk_mode <=  ps_reg_wr_dat;
        end else begin
            mst_app_wk_mode <=  mst_app_wk_mode;
        end
    end
    assign  ps_loopback_flag    =   mst_app_wk_mode[31];
    assign  ps_tst_trsf_port    =   mst_app_wk_mode[16];
    assign  ps_trsf_port_en     =   mst_app_wk_mode[0];
    
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ps_tx_req   <=  'd0;
        end else if((wr_reg_addr == `PS_TX_REQ_ADDR) & ps_reg_we)begin
            ps_tx_req   <=  ps_reg_wr_dat[0];
        end else begin
            ps_tx_req   <=  ps_tx_req;
        end
    end

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            opt_intf_init_en   <=  'd0;
        end else if((wr_reg_addr == `OPT_INTF_INIT_EN_ADDR) & ps_reg_we)begin
            opt_intf_init_en   <=  ps_reg_wr_dat[0];
        end else begin
            opt_intf_init_en   <=  opt_intf_init_en;
        end
    end
    
    // Heartbeat scan trigger: pulse when PS writes to HB_SCAN_REQ_ADDR
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            hb_scan_req   <=  'd0;
        end else if((wr_reg_addr == `HB_SCAN_REQ_ADDR) & ps_reg_we)begin
            hb_scan_req   <=  ps_reg_wr_dat[0];  // Pulse high when written
        end else begin
            hb_scan_req   <=  'd0;  // Auto-clear to generate pulse
        end
    end
    
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ps_rd_depot_flag    <=  'd0;
        end else if((wr_reg_addr == `PS_RD_DEPOT_FLAG_ADDR) & ps_reg_we)begin
            ps_rd_depot_flag    <=  ps_reg_wr_dat[0];
        end else begin
            ps_rd_depot_flag    <=  ps_rd_depot_flag;
        end
    end
    
    
    // ------ add by qsj start -------------------
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ov_io_mode_cfg  <=  32'd0;
            o_wr_cfg_data_done <= 'b0;
        end else if((wr_reg_addr == `BOARD_IO_SELECT_ADDR) & ps_reg_we)begin
            ov_io_mode_cfg  <=  ps_reg_wr_dat ;
            o_wr_cfg_data_done <= 1'b1;
        end else begin
            ov_io_mode_cfg    <=  ov_io_mode_cfg ;
            o_wr_cfg_data_done <= 'b0;
        end
    end


    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            ov_do_dbg_data  <= 'd0;
            o_do_dbg_data_vld <= 'b0;
        end else if((wr_reg_addr == `BOARD_WRITE_IO_DATA_ADDR) & ps_reg_we)begin
            ov_do_dbg_data  <= ps_reg_wr_dat ;
            o_do_dbg_data_vld <= 'b1;
        end else begin
            ov_do_dbg_data  <= 'd0;
            o_do_dbg_data_vld <= 'b0;
        end
    end
    

    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            debug_data  <= 'd0;
        end else if((wr_reg_addr == `DEBUG_DATA_ADDR) & ps_reg_we)begin
            debug_data  <= ps_reg_wr_dat ;
        end 
    end
    // ------ add by qsj end -------------------
    
    localparam  RAM_DWIDTH  =   32;
    localparam  RAM_DEPTH   =   512;
    localparam  RAM_TYPE    =   "BLOCK_SDP";
    reg [15:0]  id_buf_rd_addr = 0;
    wire[31:0]  id_buf_rd_dat;
    gen_ram
    #(
         .RAM_DWIDTH  (RAM_DWIDTH   )
        ,.RAM_DEPTH   (RAM_DEPTH    )
        ,.TYPE        (RAM_TYPE     )
    )
        id_buf_u
        (
             .clka      (prot_clk   )
            ,.wea       (&slv_id_we )
            ,.addra     (slv_id_addr)
            ,.dina      (slv_id_din )
            ,.clkb      (ps_reg_clk )
            ,.enb       (1          )
            ,.addrb     (id_buf_rd_addr[15:4])
            ,.doutb     (id_buf_rd_dat  )
        );

    always @( * )begin
        id_buf_rd_addr  <=  rd_reg_addr - `CACHE_SLV_ID_BIAS_ADDR;
    end


    // ------ add by qsj start -------------------
    reg [15:0]  fpga_version_buf_rd_addr = 0;
    wire[31:0]  fpga_version_buf_rd_dat;
    always @(posedge ps_reg_clk)begin
        if(ps_reg_reset)begin
            fpga_version_buf_rd_addr  <= 'd0;
        end else if((wr_reg_addr == `FPGA_VERSION_RD_ADDR) & ps_reg_we)begin
            fpga_version_buf_rd_addr  <= ps_reg_wr_dat ;
        end else begin
            fpga_version_buf_rd_addr  <= fpga_version_buf_rd_addr;
        end
    end
    gen_ram
    #(
         .RAM_DWIDTH  (RAM_DWIDTH   )
        ,.RAM_DEPTH   (RAM_DEPTH    )
        ,.TYPE        (RAM_TYPE     )
    )
    fpga_version_buf_u
    (
         .clka      (prot_clk   )
        ,.wea       (&slv_id_we )
        ,.addra     (slv_id_addr)
        ,.dina      (slv_fpga_version )
        ,.clkb      (ps_reg_clk )
        ,.enb       (1          )
        ,.addrb     (fpga_version_buf_rd_addr[15:4] )
        ,.doutb     (fpga_version_buf_rd_dat        )
    );
    // ------ add by qsj end  -------------------


/////////////////////////////////////////
	
	// err_code and init_error are now inputs from prot_clk domain
	// They are generated in app_mst_tx_ctrl.v

	// Double-register synchronization for prot_clk domain signals
	always @(posedge ps_reg_clk)begin
        init_finish_d1    <=  init_finish;
        init_finish_d2    <=  init_finish_d1;
        init_error_d1     <=  init_error;
        init_error_d2     <=  init_error_d1;
        err_code_d1       <=  err_code;
        err_code_d2       <=  err_code_d1;
        app_err_type_d1   <=  app_err_type;
        app_err_type_d2   <=  app_err_type_d1;
        hb_err_slvsta_d1  <=  hb_err_slvsta;
        hb_err_slvsta_d2  <=  hb_err_slvsta_d1;
    end

/////////////////////////////////////////    
    always @(posedge ps_reg_clk)begin
        ps_reg_re_d1    <=  ps_reg_re & rd_space_select;
        ps_reg_re_d2    <=  ps_reg_re_d1;
        ps_reg_rd_vld   <=  ps_reg_re_d2;
        ps_reg_re_d3   <=  ps_reg_rd_vld;
        ps_reg_re_d4   <=  ps_reg_re_d3;
        ps_reg_re_d5   <=  ps_reg_re_d4;
        o_read_dbg_data_done   <=  ps_reg_re_d5;
    end
    
    always @(posedge ps_reg_clk)begin
        rd_reg_addr_d1  <=  rd_reg_addr;
        rd_reg_addr_d2  <=  rd_reg_addr_d1;
    end
    
    assign  link_status =   (slv_sta_num !== 0) ? 1 : 0;
    always @(posedge ps_reg_clk) begin
        // Address decoding for reading registers
        case ( rd_reg_addr_d2[PS_REG_AWIDTH-1:0] )
            `SLV_STA_NUM_ADDR:  ps_reg_rd_dat   <=  slv_sta_num;
            `LINK_STATUS_ADDR:  ps_reg_rd_dat   <=  {8'd0,app_err_type[7:0],hb_err_slvsta[7:0],{6'd0,link_success,loop_link_success}};
//            `LINK_STATUS_ADDR:  ps_reg_rd_dat   <=  {slv_sta_num,hb_err_slvsta_d2,app_err_type_d2,{err_code_d2,5'd0}};
            `STAT_TIME_ADDR  :  ps_reg_rd_dat   <=  stat_rslt;
            `CHECK_SYSTERM_ADDR :  ps_reg_rd_dat   <=  32'hdeadbeaf;
            `BOARD_TEMPERATURE_ADDR:  ps_reg_rd_dat   <=  {16'b0,board_temp_82130};
            `FPGA_VERSION_DATA_ADDR  :  ps_reg_rd_dat   <=  fpga_version_buf_rd_addr==32'h000000FF ? `FPGA_VERSION : fpga_version_buf_rd_dat;
            `BOARD_READ_IO_DATA_ADDR :  ps_reg_rd_dat   <=  iv_rd_io_data;
            default : ps_reg_rd_dat <= id_buf_rd_dat;
        endcase
    end
    
endmodule