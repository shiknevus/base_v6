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
`include  "./../include_files/mst_global_cfg/components_param.vh"
`include "./../hdl/include_files/depot_addr_map.vh"

module emcc_comp_top
#(
     parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
    ,parameter  RAM_DEPTH       =   4096
    ,parameter  RAM_DWIDTH      =   32
    ,parameter  RAM_AWIDTH      =   $clog2(RAM_DEPTH)
    ,parameter  BAG_LENGTH  =   512  
)
(
     input                              clk
    ,input                              reset

//
    ,input  wire                        slv_cfg_msg_rden
    ,input  wire    [RAM_AWIDTH-1:0]    slv_cfg_msg_addr
    ,output wire    [RAM_DWIDTH-1:0]    slv_cfg_msg_dat

    ,input  wire    [3:0]               slv_sta_msg_vld     //slave station status message
    ,input  wire    [RAM_AWIDTH-1:0]    slv_sta_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    slv_sta_msg_dat

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
    ,input  wire    [63:0]              di_mst_msg
    ,output wire    [31:0]              do_mst_msg
    //reg cfg interrupt
    ,output wire    [511:0]             comp_irq
    ,output wire                        tst_sig
);
    localparam  TOKEN_DWIDTH=   16;
    localparam  BIAS_NUM    =   1000;
    localparam  COMP_NUM    =   2500;
    localparam  USE_COMP_NUM=   26;
    
    wire    [4:0]                               irq_bus_witch;
    wire    [(BIAS_NUM+COMP_NUM-1):BIAS_NUM]    rll_comp_irq;
    reg [31:0]  cur_timer = 'd0;
    wire                        sub_ps_reg_rd_vld[BIAS_NUM+COMP_NUM-1:BIAS_NUM];
    wire    [PS_REG_DWIDTH-1:0] sub_ps_reg_rd_dat[BIAS_NUM+COMP_NUM-1:BIAS_NUM];

//  components interface
    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_m01_token_if_sp[3:0]();
    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_m00_token_if_mp[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_m01_token_if_mp[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_m02_token_if_mp[1:0]();
    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s00_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s01_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
    emcc_token_if #(.DATA_WIDTH(14))  roller_s02_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
//////////////////////////////////////////////////////////////////////////////////////////////guangqianfenbao   
    wire    [RAM_DWIDTH*2-1:0]          do_regoin_msg[RAM_DWIDTH-1:0];    //1
    wire    [RAM_DWIDTH*3-1:0]          di_regoin_msg[RAM_DWIDTH-1:0];    //1
    wire    [RAM_DWIDTH*4-1:0]          ai_regoin_msg[RAM_DWIDTH-1:0];     //1
    wire    [RAM_DWIDTH-1:0]            rs232_1st_msg[RAM_DWIDTH-1:0];//1
    wire    [RAM_DWIDTH-1:0]            rs232_2nd_msg[RAM_DWIDTH-1:0];//1
    wire    [RAM_DWIDTH-1:0]            reseve_data[RAM_DWIDTH-1:0];//1
    reg     [31:0]                      tst_dat;
    wire    [3:0]                       sys_wea[RAM_DWIDTH-1:0];
    wire    [RAM_AWIDTH-1:0]            sys_addra[RAM_DWIDTH-1:0];
    //receive buffer
    wire    [RAM_DWIDTH-1:0]            pre_r_uuid[RAM_DWIDTH-1:0];    //1
    wire    [RAM_DWIDTH*2-1:0]          do_regoin_r_msg[RAM_DWIDTH-1:0];    //1
    wire    [RAM_DWIDTH*3-1:0]          di_regoin_r_msg[RAM_DWIDTH-1:0];    //1
    wire    [RAM_DWIDTH*4-1:0]          ai_regoin_r_msg[RAM_DWIDTH-1:0];     //1
    wire    [RAM_DWIDTH-1:0]            rs232_1st_r_msg[RAM_DWIDTH-1:0];//1
    wire    [RAM_DWIDTH-1:0]            rs232_2nd_r_msg[RAM_DWIDTH-1:0];//1
    wire    [RAM_DWIDTH-1:0]            reseve_r_data[RAM_DWIDTH-1:0];//1    
 ///////////////////////////////////////////////////////////////////////////////////////
    wire    mat_arrived[1000:1500];
    wire    dgt_error[1000:1500];
    wire    dgt_start[1000:1500];
    wire    yzqg_up[1000:1500];
    wire    yzqg_down[1000:1500];
    wire    yzqg_out[1000:1500];
    wire    yzdj_start_z[1000:1500];
    
    //////////////////////////////
    wire    qdqg_up[1000:1500];
    wire    qdqg_down[1000:1500];
    wire    qdqg_out[1000:1500];
    wire    cdqg_put_out[1000:1500];
    wire    cdqg_draw_back[1000:1500];
    wire    cdqg_out[1000:1500];
   
    ///////////////////////////
    
    pkg_route
    #(
         .RAM_DEPTH         (RAM_DEPTH  )
        ,.RAM_DWIDTH        (RAM_DWIDTH )
        ,.BAG_LENGTH        (BAG_LENGTH )
    )
        pkg_route_u
        (
             .clk                   (clk                    )
            ,.rst                   (reset                  )

            ,.slv_cfg_msg_rden      (slv_cfg_msg_rden       )
            ,.slv_cfg_msg_addr      (slv_cfg_msg_addr       )
            ,.slv_cfg_msg_dat       (slv_cfg_msg_dat        )

            ,.slv_sta_msg_vld       (slv_sta_msg_vld        )
            ,.slv_sta_msg_addr      (slv_sta_msg_addr       )
            ,.slv_sta_msg_dat       (slv_sta_msg_dat        )

//slave to master
            ,.do_regoin_msg         (do_regoin_msg          )
            ,.di_regoin_msg         (di_regoin_msg          )
           
            ,.ai_regoin_msg         (ai_regoin_msg          )
        
            ,.rs232_1st_msg         (rs232_1st_msg          )
            ,.rs232_2nd_msg         (rs232_2nd_msg          )
        
            ,.reseve_data           (reseve_data            )

//master to slave
            ,.pre_r_uuid            (pre_r_uuid             )
            ,.do_regoin_r_msg       (do_regoin_r_msg        )
            ,.di_regoin_r_msg       (di_regoin_r_msg        )
       
            ,.ai_regoin_r_msg       (ai_regoin_r_msg        )
          
            ,.rs232_1st_r_msg       (rs232_1st_r_msg        )
            ,.rs232_2nd_r_msg       (rs232_2nd_r_msg        )
            ,.reseve_r_data         (reseve_r_data          )
            
            ,.sys_addra             (sys_addra        )
            ,.sys_wea               (sys_wea          )
            
        );

    assign  tst_sig =   |tst_dat;
    assign  do_mst_msg[4:1] = 32'hffff_ffff;
    assign  do_mst_msg[31:27] = 32'hffff_ffff;
    
      generate
        for (genvar k=0; k < 32; k=k+1)begin: INITIAL_SLV_CFG_MSG
        	    if(k == 0)begin
                assign  do_regoin_r_msg[k][19:19] = 32'hffff_ffff;
                assign  do_regoin_r_msg[k][31:22] = 32'hffff_ffff;
                assign  do_regoin_r_msg[k][63:32] = 32'hffff_ffff;
              end else if(k == 1)begin
                assign  do_regoin_r_msg[k][5:4] = 32'hffff_ffff;
               	assign  do_regoin_r_msg[k][21:20] = 32'hffff_ffff;
               	assign  do_regoin_r_msg[k][31:26] = 32'hffff_ffff;	
                assign  do_regoin_r_msg[k][63:32] = 32'hffff_ffff;
              end else if (k==2)begin
                assign  do_regoin_r_msg[k][24:24] = 32'hffff_ffff;
              end else if (k==3)begin
                assign  do_regoin_r_msg[k][31:31] = 32'hffff_ffff;
              end else if (k==4)begin
                assign  do_regoin_r_msg[k][31:28] = 32'hffff_ffff;
              end else if (k==5)begin
                assign  do_regoin_r_msg[k][31:28] = 32'hffff_ffff;
              end else if (k==6)begin
                assign  do_regoin_r_msg[k][31:28] = 32'hffff_ffff;
              end else if (k==7)begin
                assign  do_regoin_r_msg[k][31:30] = 32'hffff_ffff;
              end else if (k==8)begin
                ;
              end else if (k==9)begin
                assign  do_regoin_r_msg[k][24:23] = 2'hf;
                assign  do_regoin_r_msg[k][29:29] = 1'b1;
              end else if (k==10)begin
                assign  do_regoin_r_msg[k][31:28] = 32'hffff_ffff; 
              end else if (k==11)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==12)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==13)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==14)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==15)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==16)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==17)begin
                assign  do_regoin_r_msg[k][31:20] = 12'hfff;
              end else if (k==18)begin
                assign  do_regoin_r_msg[k][21:21] = 32'hffff_ffff;
                assign  do_regoin_r_msg[k][31:26] = 32'hffff_ffff;
              end else begin
//                assign  pre_r_uuid[k][31:0]         =   32'h0000_1111_1010;
                assign  do_regoin_r_msg[k][63:0]    =   64'hffff_ffff_ffff_ffff;
//                assign  di_regoin_r_msg[k][31:0]    =   {{16{k}},16'h0002};
//                assign  di_regoin_r_msg[k][63:32]   =   {{16{k}},16'h0003};
//                assign  di_regoin_r_msg[k][95:64]   =   {{16{k}},16'h0004};
//                assign  ai_regoin_r_msg[k][31:0]    =   {{16{k}},16'h0005};
//                assign  ai_regoin_r_msg[k][63:32]   =   {{16{k}},16'h0006};
//                assign  ai_regoin_r_msg[k][95:64]   =   {{16{k}},16'h0007};
//                assign  ai_regoin_r_msg[k][127:96]  =   {{16{k}},16'h0008};
//                assign  rs232_1st_r_msg[k][31:0]    =   {{16{k}},16'h0009};
//                assign  rs232_2nd_r_msg[k][31:0]    =   {{16{k}},16'h000a};
//                assign  reseve_r_data[k][31:0]      =   {{16{k}},16'h000b};
            end
        end
    endgenerate

////////////////////////
    ps_rd_dat_route
    #(
         .CHANNEL_BIAS      (BIAS_NUM       )
        ,.CHANNEL_NUM       (COMP_NUM       )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
    )
        ps_rd_dat_route_u
        (
             .ps_reg_clk        (ps_reg_clk     )
            ,.ps_reg_reset      (ps_reg_reset   )
            ,.ps_reg_rd_vld     (ps_reg_rd_vld  )
            ,.ps_reg_rd_dat     (ps_reg_rd_dat  )

            ,.ds_rd_vld         (sub_ps_reg_rd_vld      )
            ,.ds_rd_dat         (sub_ps_reg_rd_dat      )
        );
/*    
    generate
        for (genvar j=USE_COMP_NUM; j < COMP_NUM; j=j+1)begin: GEN_PS_RD_DAT
            assign  sub_ps_reg_rd_vld[j]   =   (cur_timer == j) ? 1'b1 : 1'b0;
            assign  sub_ps_reg_rd_dat[j]   =   cur_timer + j;
            assign  comp_irq[j] =   0;
        end
    endgenerate
*/
///////////////////////////////////////////////////////////////////////////////////////kaishi_0
/*
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1000_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1000           )
        ,.WORK_OUT1_PATH (14'd1001          )
    )
        roller_1000_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][13]    )
            ,.dgt_error                 (di_regoin_msg[9][36]    )
            ,.dgt_start                 (do_regoin_r_msg[9][0]  )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1000] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1000] )
            ,.comp_irq                  (rll_comp_irq[1000]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1000])
            ,.m1_token_if               (roller_s01_token_if[1001])
        );
*/
    assign  yzqg_up[1000]       =   di_regoin_msg[9][1];
    assign  yzqg_down[1000]     =   di_regoin_msg[9][2];
    assign  do_regoin_r_msg[9][17]  =   yzqg_out[1000]    ;
    assign  do_regoin_r_msg[9][27]  =   yzdj_start_z[1000];
      rll_transf_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1000_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1000           )
        ,.WORK_OUT1_PATH (14'd1001          )
    )
        roller_1000_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[9][13]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[9][36]    )
            ,.dgt_start                 (do_regoin_r_msg[9][0]  )
            ,.yzqg_up                   (yzqg_up[1000]    )
            ,.yzqg_down                 (yzqg_down[1000]    )
            ,.yzqg_out                  (yzqg_out[1000]  )
            ,.yzdj_start_z              (yzdj_start_z[1000]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1000] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1000] )
            ,.comp_irq                  (rll_comp_irq[1000]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1000])
            ,.m1_token_if               (roller_s01_token_if[1001])
        );

   ///////////////////////////////////////////////////////////////////////////////////////kaishi_1
     rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1034_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1034           )
        ,.WORK_OUT1_PATH (14'd1002          )
    )
        roller_1034_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (mat_arrived[1034]    )
            ,.dgt_error                 (dgt_error[1034]   )
            ,.dgt_start                 (dgt_start[1034]  )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1034] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1034] )
            ,.comp_irq                  (rll_comp_irq[1034]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1034])
            ,.m1_token_if               (roller_s01_token_if[1002])
        );
		
//====================================================================================================================		
		reg i_time_1ms_vld;
		reg [31:0]cnt11;
		always@(posedge clk)begin
		if(reset)begin
			i_time_1ms_vld<=0;
			cnt11<= 0;end
		else if(cnt11 >= 156249)begin
			cnt11<= 0;
			i_time_1ms_vld<=1;end
		else begin
			cnt11<=cnt11+1;
			i_time_1ms_vld<=0;end
		end
	// ROLLER_1003_REG_BIAS
			ec_1di_check #(
			.REG_SPACE_BIAS (`ROLLER_1003_REG_BIAS),	
			.REG_SPACE_SIZE (512),
			.A_BHA_NUM      (2),
			.B_BHA_NUM      (1)
		) ec_1di_check_u0 (
			.clk_i           (clk),
			.rst             (reset),
			.aurora_reset    (1'b0),     // unuse
			.i_time_1ms_vld  (i_time_1ms_vld),
			.i_time_1s_vld   (1'd0),
			.ps_reg_clk		(ps_reg_clk),
			.ps_reg_reset   (ps_reg_reset   ),
			.i_st_wr_en      (ps_reg_we),
			.i_st_wr_addr    (ps_reg_addr),
			.i_st_wr_data    (ps_reg_wr_dat),
			.i_st_rd_en      (ps_reg_re),
			.i_st_rd_addr    (ps_reg_rd_addr),
			.o_st_rd_data    (sub_ps_reg_rd_dat[1003]),
			.o_st_rd_vld     (sub_ps_reg_rd_vld[1003]),
			.di              (1'd1),
			.o_intr_irq      (rll_comp_irq[1003])
		);
		
   ////////////////////////////////////////////////////////////////////////////////////////1jin1chu
    	rll_ic_oc_comp_top
    	#(
    	     .REG_SPACE_BIAS(`ROLLER_1001_REG_BIAS)
    	    ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
    	    ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
    	    ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
    	    ,.CUR_LOCATION  (14'd1001           )
    	    ,.WORK_OUT1_PATH (14'd1002          )
    	)
    	    roller_1001_u
    	    (
    	         .clk                       (clk        )
    	        ,.reset                     (reset      )
    	
    	    //  ps interface
    	        //reg cfg interface
    	        ,.ps_reg_clk                (ps_reg_clk     )
    	        ,.ps_reg_reset              (ps_reg_reset   )
    	        
    	        ,.mat_arrived               (di_regoin_msg[9][14]    )   //arrive_test_mf
    	        ,.dgt_error                 (di_regoin_msg[9][37]    )
    	        ,.dgt_start                 (do_regoin_r_msg[9][1]  )
    	
    	        ,.ps_reg_we                 (ps_reg_we     )
    	        ,.ps_reg_addr               (ps_reg_addr   )
    	        ,.ps_reg_wr_dat             (ps_reg_wr_dat )
    	        ,.ps_reg_re                 (ps_reg_re     )
    	        ,.ps_reg_rd_addr            (ps_reg_rd_addr)
    	        ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1001] )
    	        ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1001] )
    	        ,.comp_irq                  (rll_comp_irq[1001]    )
    	    //  components interface
    	
    	        ,.s1_token_if               (roller_s01_token_if[1001])
    	        ,.m1_token_if               (roller_s00_token_if[1002])
    	    );     
   ////////////////////////////////////////////////////////////////////////////////////////2jin1chu   
    rll_ic_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1002_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1002           )
        ,.WORK_OUT1_PATH (14'd1003         )
    )
        roller_1002_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[9][15]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[9][38]    )
            ,.dgt_start                 (do_regoin_r_msg[9][2]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1002] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1002] )
            ,.comp_irq                  (rll_comp_irq[1002]      )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[1002])
            ,.s1_token_if               (roller_s01_token_if[1002])
            ,.m1_token_if               (roller_s01_token_if[1003])
        ); 

 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    //	rll_ic_oc_comp_top
    //	#(
    //	     .REG_SPACE_BIAS(`ROLLER_1003_REG_BIAS)
    //	    ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
    //	    ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
    //	    ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
    //	    ,.CUR_LOCATION  (14'd1003           )
    //	    ,.WORK_OUT1_PATH (14'd1004          )
    //	)
    //	    roller_1003_u
    //	    (
    //	         .clk                       (clk        )
    //	        ,.reset                     (reset      )
    //	
    //	    //  ps interface
    //	        //reg cfg interface
    //	        ,.ps_reg_clk                (ps_reg_clk     )
    //	        ,.ps_reg_reset              (ps_reg_reset   )
    //	        
    //	        ,.mat_arrived               (di_regoin_msg[9][16]    )  //arrive_test_mf
    //	        ,.dgt_error                 (di_regoin_msg[9][39]    )
    //	        ,.dgt_start                 (do_regoin_r_msg[9][3]  )
    //	
    //	        ,.ps_reg_we                 (ps_reg_we     )
    //	        ,.ps_reg_addr               (ps_reg_addr   )
    //	        ,.ps_reg_wr_dat             (ps_reg_wr_dat )
    //	        ,.ps_reg_re                 (ps_reg_re     )
    //	        ,.ps_reg_rd_addr            (ps_reg_rd_addr)
    //	        ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1003] )
    //	        ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1003] )
    //	        ,.comp_irq                  (rll_comp_irq[1003]      )
    //	    //  components interface
    //	
    //	        ,.s1_token_if               (roller_s01_token_if[1003])
    //	        ,.m1_token_if               (roller_s01_token_if[1004])
    //	    );
  //////////////////////////////////////////////////////////////////////232      
    rll_scan_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1004_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1004           )
        ,.WORK_OUT1_PATH (14'd1005          )
         ,.SLAVE_PCB_NUM  (9)
        ,.LOCK_SCAN_ADDR(`DEPOT_BIAS_RS232_2ND)
    )
        roller_1004_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[9][17]    )
            ,.dgt_error                 (di_regoin_msg[9][40]    )
            ,.dgt_start                 (do_regoin_r_msg[9][4]  )

            ,.rs232_1st_vld             (sys_wea[9]           )
            ,.rs232_1st_addr            (sys_addra[9]         )
            ,.rs232_1st_msg             (rs232_2nd_msg[9]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1004] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1004] )
            ,.comp_irq                  (rll_comp_irq[1004]      )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1004])
            ,.m1_token_if               (roller_s01_token_if[1005])
        );
     
    rll_online_height_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1005_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1005           )
        ,.WORK_OUT1_PATH (14'd1006          )
    )
        roller_1005_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived1              (di_regoin_msg[9][18]  ) 
            ,.mat_arrived2              (di_regoin_msg[9][54]  )
            ,.mat_arrived               (di_regoin_msg[9][55]  )
            ,.dgt_error                 (di_regoin_msg[9][41]  )
            ,.dgt_start                 (do_regoin_r_msg[9][5] )
            ,.ldl_data                  (ai_regoin_msg[9][15:0])
            ,.ldr_data                  (ai_regoin_msg[9][31:16])

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1005] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1005] )
            ,.comp_irq                  (rll_comp_irq[1005]      )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1005])
            ,.m1_token_if               (roller_s01_token_if[1006])
        );   
		

////////////////////////////////////////////////////////////////////////////////1jin2chu        
`ifndef SIM_PLATFORM_MST
    localparam   COMP_TOTAL_NUM  =   9;
    localparam [31:0] ROLLER_COMP_REG_BIAS[1006:1014] = '{
         `ROLLER_1006_REG_BIAS
        ,`ROLLER_1007_REG_BIAS
        ,`ROLLER_1008_REG_BIAS
        ,`ROLLER_1009_REG_BIAS
        ,`ROLLER_1010_REG_BIAS
        ,`ROLLER_1011_REG_BIAS
        ,`ROLLER_1012_REG_BIAS
        ,`ROLLER_1013_REG_BIAS
        ,`ROLLER_1014_REG_BIAS
    };

    localparam [31:0] M0_DWS_BRANCH_ID[1006:1014] = '{
         1036
        ,1039
        ,1042
        ,1045
        ,1048
        ,1051
        ,1054
        ,1057
        ,1060
    };

    assign  mat_arrived[1006]           =   di_regoin_msg[10][25];
    assign  dgt_error[1006]             =   di_regoin_msg[10][2];
    assign  yzqg_up[1006]               =   di_regoin_msg[10][11];
    assign  yzqg_down[1006]             =   di_regoin_msg[10][12];
    assign  do_regoin_r_msg[10][12]     =   dgt_start[1006];
    assign  do_regoin_r_msg[10][21]     =   yzqg_out[1006];
    assign  do_regoin_r_msg[10][4]      =   yzdj_start_z[1006];

    assign  mat_arrived[1007]           =   di_regoin_msg[11][23];
    assign  dgt_error[1007]             =   di_regoin_msg[11][0];
    assign  yzqg_up[1007]               =   di_regoin_msg[11][9];
    assign  yzqg_down[1007]             =   di_regoin_msg[11][10];
    assign  do_regoin_r_msg[11][0]      =   dgt_start[1007];
    assign  do_regoin_r_msg[11][9]      =   yzqg_out[1007];
    assign  do_regoin_r_msg[11][18]     =   yzdj_start_z[1007];

    assign  mat_arrived[1008]           =   di_regoin_msg[12][23];
    assign  dgt_error[1008]             =   di_regoin_msg[12][0];
    assign  yzqg_up[1008]               =   di_regoin_msg[12][9];
    assign  yzqg_down[1008]             =   di_regoin_msg[12][10];
    assign  do_regoin_r_msg[12][0]      =   dgt_start[1008];
    assign  do_regoin_r_msg[12][9]      =   yzqg_out[1008];
    assign  do_regoin_r_msg[12][18]     =   yzdj_start_z[1008];

    assign  mat_arrived[1009]           =   di_regoin_msg[13][23];
    assign  dgt_error[1009]             =   di_regoin_msg[13][0];
    assign  yzqg_up[1009]               =   di_regoin_msg[13][9];
    assign  yzqg_down[1009]             =   di_regoin_msg[13][10];
    assign  do_regoin_r_msg[13][0]      =   dgt_start[1009];
    assign  do_regoin_r_msg[13][9]      =   yzqg_out[1009];
    assign  do_regoin_r_msg[13][18]     =   yzdj_start_z[1009];

    assign  mat_arrived[1010]           =   di_regoin_msg[14][23];
    assign  dgt_error[1010]             =   di_regoin_msg[14][0];
    assign  yzqg_up[1010]               =   di_regoin_msg[14][9];
    assign  yzqg_down[1010]             =   di_regoin_msg[14][10];
    assign  do_regoin_r_msg[14][0]      =   dgt_start[1010];
    assign  do_regoin_r_msg[14][9]      =   yzqg_out[1010];
    assign  do_regoin_r_msg[14][18]     =   yzdj_start_z[1010];

    assign  mat_arrived[1011]           =   di_regoin_msg[15][23];
    assign  dgt_error[1011]             =   di_regoin_msg[15][0];
    assign  yzqg_up[1011]               =   di_regoin_msg[15][9];
    assign  yzqg_down[1011]             =   di_regoin_msg[15][10];
    assign  do_regoin_r_msg[15][0]      =   dgt_start[1011];
    assign  do_regoin_r_msg[15][9]      =   yzqg_out[1011];
    assign  do_regoin_r_msg[15][18]     =   yzdj_start_z[1011];

    assign  mat_arrived[1012]           =   di_regoin_msg[16][23];
    assign  dgt_error[1012]             =   di_regoin_msg[16][0];
    assign  yzqg_up[1012]               =   di_regoin_msg[16][9];
    assign  yzqg_down[1012]             =   di_regoin_msg[16][10];
    assign  do_regoin_r_msg[16][0]      =   dgt_start[1012];
    assign  do_regoin_r_msg[16][9]      =   yzqg_out[1012];
    assign  do_regoin_r_msg[16][18]     =   yzdj_start_z[1012];

    assign  mat_arrived[1013]           =   di_regoin_msg[17][23];
    assign  dgt_error[1013]             =   di_regoin_msg[17][0];
    assign  yzqg_up[1013]               =   di_regoin_msg[17][9];
    assign  yzqg_down[1013]             =   di_regoin_msg[17][10];
    assign  do_regoin_r_msg[17][0]      =   dgt_start[1013];
    assign  do_regoin_r_msg[17][9]      =   yzqg_out[1013];
    assign  do_regoin_r_msg[17][18]     =   yzdj_start_z[1013];

    assign  mat_arrived[1014]           =   di_regoin_msg[18][28];
    assign  dgt_error[1014]             =   di_regoin_msg[18][0];
    assign  yzqg_up[1014]               =   di_regoin_msg[18][14];
    assign  yzqg_down[1014]             =   di_regoin_msg[18][15];
    assign  do_regoin_r_msg[18][0]      =   dgt_start[1014];
    assign  do_regoin_r_msg[18][14]     =   yzqg_out[1014];
    assign  do_regoin_r_msg[18][24]     =   yzdj_start_z[1014];

    generate
        for (genvar k=1006; k < (1006+9); k=k+1)begin:ROLLER_M0_N      //from master branch 0 and node 1000
            rll_transf_ic_oc_or_comp_top
            #(
                 .REG_SPACE_BIAS(ROLLER_COMP_REG_BIAS[k])
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  (k                  )
                ,.WORK_OUT0_PATH (M0_DWS_BRANCH_ID[k])
                ,.WORK_OUT1_PATH (k+1          )
            )
                roller_mp5_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[k]  )  //arrive_test_mf
                    ,.dgt_error                 (dgt_error[k]   )
                    ,.dgt_start                 (dgt_start[k]    )
                    ,.yzqg_up                   (yzqg_up[k]      )
                    ,.yzqg_down                 (yzqg_down[k]    )
                    ,.yzqg_out                  (yzqg_out[k]     )
                    ,.yzdj_start_z              (yzdj_start_z[k])

                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k] )
                    ,.comp_irq                  (rll_comp_irq[k]    )
                //  components interface

                    ,.s1_token_if               (roller_s01_token_if[k])
                    ,.m1_token_if               (roller_s01_token_if[k+1]  )
                    ,.m0_token_if               (roller_s01_token_if[M0_DWS_BRANCH_ID[k]]  )
                );
        //1006 1007 1008 1009 1010 1011 1012 1013 1014
        //7     8   9     10    11  12  13      14 15
      end
   endgenerate
  /////////////////////////////////////////////////////////////////////jieshu      
    localparam [31:0] ROLLER_M0_B_REG_BIAS[1036:1062] = '{
         `ROLLER_1036_REG_BIAS
        ,`ROLLER_1037_REG_BIAS
        ,`ROLLER_1038_REG_BIAS
        ,`ROLLER_1039_REG_BIAS
        ,`ROLLER_1040_REG_BIAS
        ,`ROLLER_1041_REG_BIAS
        ,`ROLLER_1042_REG_BIAS
        ,`ROLLER_1043_REG_BIAS
        ,`ROLLER_1044_REG_BIAS
        ,`ROLLER_1045_REG_BIAS
        ,`ROLLER_1046_REG_BIAS
        ,`ROLLER_1047_REG_BIAS
        ,`ROLLER_1048_REG_BIAS
        ,`ROLLER_1049_REG_BIAS
        ,`ROLLER_1050_REG_BIAS
        ,`ROLLER_1051_REG_BIAS
        ,`ROLLER_1052_REG_BIAS
        ,`ROLLER_1053_REG_BIAS
        ,`ROLLER_1054_REG_BIAS
        ,`ROLLER_1055_REG_BIAS
        ,`ROLLER_1056_REG_BIAS
        ,`ROLLER_1057_REG_BIAS
        ,`ROLLER_1058_REG_BIAS
        ,`ROLLER_1059_REG_BIAS
        ,`ROLLER_1060_REG_BIAS
        ,`ROLLER_1061_REG_BIAS
        ,`ROLLER_1062_REG_BIAS
    };

    localparam [31:0] MM_DWS_BRANCH_ID[1090:1098] = '{
         1090
        ,1091
        ,1092
        ,1093
        ,1094
        ,1095
        ,1096
        ,1097
        ,1098
    };

    assign  mat_arrived[1036]       =   di_regoin_msg[10][27];
    assign  dgt_error[1036]         =   di_regoin_msg[10][4];
    assign  do_regoin_r_msg[10][14] =   dgt_start[1036];
    assign  mat_arrived[1039]       =   di_regoin_msg[11][25];
    assign  dgt_error[1039]         =   di_regoin_msg[11][2];
    assign  do_regoin_r_msg[11][2]  =   dgt_start[1039];
    assign  mat_arrived[1042]       =   di_regoin_msg[12][25];
    assign  dgt_error[1042]         =   di_regoin_msg[12][2];
    assign  do_regoin_r_msg[12][2]  =   dgt_start[1042];
    assign  mat_arrived[1045]       =   di_regoin_msg[13][25];
    assign  dgt_error[1045]         =   di_regoin_msg[13][2];
    assign  do_regoin_r_msg[13][2]  =   dgt_start[1045];
    assign  mat_arrived[1048]       =   di_regoin_msg[14][25];
    assign  dgt_error[1048]         =   di_regoin_msg[14][2];
    assign  do_regoin_r_msg[14][2]  =   dgt_start[1048];
    assign  mat_arrived[1051]       =   di_regoin_msg[15][25];
    assign  dgt_error[1051]         =   di_regoin_msg[15][2];
    assign  do_regoin_r_msg[15][2]  =   dgt_start[1051];
    assign  mat_arrived[1054]       =   di_regoin_msg[16][25];
    assign  dgt_error[1054]         =   di_regoin_msg[16][2];
    assign  do_regoin_r_msg[16][2]  =   dgt_start[1054];
    assign  mat_arrived[1057]       =   di_regoin_msg[17][25];
    assign  dgt_error[1057]         =   di_regoin_msg[17][2];
    assign  do_regoin_r_msg[17][2]  =   dgt_start[1057];
    assign  mat_arrived[1060]       =   di_regoin_msg[18][35];
    assign  dgt_error[1060]         =   di_regoin_msg[18][7];
    assign  do_regoin_r_msg[18][7]  =   dgt_start[1060];
    
////////////////////////////////////////////////////wf
/////1037
    assign  mat_arrived[1037]       =   di_regoin_msg[10][28];
    assign  dgt_error[1037]         =   di_regoin_msg[10][5];
    assign  do_regoin_r_msg[10][15]  =   dgt_start[1037]; 
///1038
assign mat_arrived[1038]             = di_regoin_msg[10][29];  
assign dgt_error[1038]               = di_regoin_msg[10][6];   
assign do_regoin_r_msg[10][16]       = dgt_start[1038] ;
assign qdqg_up[1038]                 = di_regoin_msg[10][15];
assign qdqg_down[1038]               = di_regoin_msg[10][16];
assign do_regoin_r_msg[10][23]       = qdqg_out[1038]   ;
assign cdqg_put_out[1038]            = di_regoin_msg[10][17];
assign cdqg_draw_back[1038]          = di_regoin_msg[10][18];
assign do_regoin_r_msg[10][24]       =cdqg_out[1038] ;
///1040
assign  mat_arrived[1040]       =   di_regoin_msg[11][26];
assign  dgt_error[1040]         =   di_regoin_msg[11][3];
assign  do_regoin_r_msg[11][3]  =   dgt_start[1040]; 
///1041
assign mat_arrived[1041]             = di_regoin_msg[11][27];  
assign dgt_error[1041]               = di_regoin_msg[11][4];   
assign do_regoin_r_msg[11][4]        = dgt_start[1041] ;
assign qdqg_up[1041]                 = di_regoin_msg[11][13];
assign qdqg_down[1041]               = di_regoin_msg[11][14] ;
assign do_regoin_r_msg[11][11]       = qdqg_out[1041]   ;
assign cdqg_put_out[1041]            = di_regoin_msg[11][15];
assign cdqg_draw_back[1041]          = di_regoin_msg[11][16];
assign do_regoin_r_msg[11][12]       =cdqg_out[1041] ;
////////////1043
assign mat_arrived[1043]             =  di_regoin_msg[12][26];    
assign dgt_error[1043]              =   di_regoin_msg[12][3] ;    
assign do_regoin_r_msg[12][3]     =   dgt_start[1043]     ; 
////////////1044
assign mat_arrived [1044]      =         di_regoin_msg[12][27];  
assign dgt_error [1044]        =         di_regoin_msg[12][4]  ; 
assign do_regoin_r_msg[12][4]  =         dgt_start  [1044]  ;  
assign qdqg_up   [1044]        =         di_regoin_msg[12][13]      ;   //zu dang kai
assign qdqg_down  [1044]       =        di_regoin_msg[12][14];
assign do_regoin_r_msg[12][11] =        qdqg_out[1044] ;  //zu dang  
assign cdqg_put_out [1044]     =       di_regoin_msg[12][15]  ;  //ding wei kai
assign cdqg_draw_back [1044]   =       di_regoin_msg[12][16];
assign do_regoin_r_msg[12][12] =       cdqg_out  [1044]    ; //ding wei
///////1046
assign mat_arrived  [1046]       =    di_regoin_msg[13][26]   ;
assign dgt_error    [1046]       =    di_regoin_msg[13][3]    ;
assign do_regoin_r_msg[13][3]    =    dgt_start  [1046]  ;
//1047
assign mat_arrived[1047]          =     di_regoin_msg[13][27] ;
assign dgt_error[1047]           =      di_regoin_msg[13][4];   
assign do_regoin_r_msg[13][4]   =    dgt_start[1047]  ;
assign qdqg_up [1047]             =     di_regoin_msg[13][13] ;   //zu dang kai
assign qdqg_down [1047]           =    di_regoin_msg[13][14];
assign do_regoin_r_msg[13][11]    =   qdqg_out [1047] ; //zu dang  
assign cdqg_put_out[1047]        = di_regoin_msg[13][15];    //ding wei kai
assign cdqg_draw_back[1047]       =di_regoin_msg[13][16];
assign do_regoin_r_msg[13][12]     = cdqg_out [1047];     //ding wei
 ///1049
assign mat_arrived [1049]                =       di_regoin_msg[14][26] ;  
assign dgt_error [1049]                   =       di_regoin_msg[14][3];     
assign do_regoin_r_msg[14][3]      =       dgt_start [1049]  ;     
//1050
assign mat_arrived[1050]          =     di_regoin_msg[14][27] ;
assign dgt_error[1050]           =      di_regoin_msg[14][4] ;   
assign do_regoin_r_msg[14][4]   =    dgt_start[1050]  ;
assign qdqg_up [1050]             =     di_regoin_msg[14][13] ;   //zu dang kai
assign qdqg_down [1050]           =    di_regoin_msg[14][14];
assign do_regoin_r_msg[14][11]    =   qdqg_out [1050] ; //zu dang  
assign cdqg_put_out[1050]        = di_regoin_msg[14][15];    //ding wei kai
assign cdqg_draw_back[1050]       =di_regoin_msg[14][16];
assign do_regoin_r_msg[14][12]     = cdqg_out [1050];     //ding wei
//////1052
assign   mat_arrived [1052]       =       di_regoin_msg[15][26]   ;
assign   dgt_error   [1052]       =       di_regoin_msg[15][3]    ;
assign   do_regoin_r_msg[15][3]   =       dgt_start[1052]         ;
////1053
 assign mat_arrived     [1053]   =    di_regoin_msg[15][27]  ;
 assign dgt_error       [1053]   =    di_regoin_msg[15][4]   ;
 assign do_regoin_r_msg[15][4]   =    dgt_start[1053]        ;
 assign qdqg_up         [1053]   =    di_regoin_msg[15][13]  ; 
 assign qdqg_down       [1053]   =    di_regoin_msg[15][14]  ; 
 assign do_regoin_r_msg[15][11]  =    qdqg_out        [1053] ;
 assign cdqg_put_out    [1053]   =    di_regoin_msg[15][15]  ; 
 assign cdqg_draw_back  [1053]   =    di_regoin_msg[15][16]  ; 
 assign do_regoin_r_msg[15][12]  =    cdqg_out[1053]         ;
///1055
assign mat_arrived  [1055]       =    di_regoin_msg[16][26]   ;                                             
assign dgt_error    [1055]       =    di_regoin_msg[16][3]    ;
assign do_regoin_r_msg[16][3]    =    dgt_start    [1055]     ;
///1056
assign mat_arrived   [1056]     =       di_regoin_msg[16][27]      ;                      
assign dgt_error     [1056]     =       di_regoin_msg[16][4]       ;                      
assign do_regoin_r_msg[16][4]   =       dgt_start     [1056]       ;                     
assign qdqg_up       [1056]     =       di_regoin_msg[16][13]      ;   
assign qdqg_down     [1056]     =       di_regoin_msg[16][14]      ;                    
assign do_regoin_r_msg[16][11]  =       qdqg_out      [1056]       ;      
assign cdqg_put_out  [1056]     =       di_regoin_msg[16][15]      ;      
assign cdqg_draw_back[1056]     =       di_regoin_msg[16][16]     ;      
assign do_regoin_r_msg[16][12]  =       cdqg_out      [1056]       ;    
////1058
assign mat_arrived    [1058]      =     di_regoin_msg[17][26]      ;  
assign dgt_error      [1058]      =     di_regoin_msg[17][3]       ;  
assign do_regoin_r_msg[17][3]     =     dgt_start      [1058]      ;  
//////1059
assign mat_arrived     [1059]     =     di_regoin_msg[17][27]  ;                  
assign dgt_error       [1059]     =     di_regoin_msg[17][4]   ;                                     
assign do_regoin_r_msg[17][4]     =     dgt_start       [1059] ;                   
assign qdqg_up         [1059]     =     di_regoin_msg[17][13]  ;    
assign qdqg_down       [1059]     =     di_regoin_msg[17][14]  ;    
assign do_regoin_r_msg[17][11]    =  qdqg_out        [1059]    ;  
assign cdqg_put_out    [1059]     =     di_regoin_msg[17][15]  ;    
assign cdqg_draw_back  [1059]     =     di_regoin_msg[17][16]  ;    
assign do_regoin_r_msg[17][12]    =  cdqg_out        [1059]    ;  
////1061                                                          
                                                                  
   assign mat_arrived   [1061]    =   di_regoin_msg[18][36];
   assign dgt_error     [1061]    =   di_regoin_msg[18][8];
   assign do_regoin_r_msg[18][8]  =   dgt_start     [1061];
////1062                                                          
  assign mat_arrived    [1062]    =      di_regoin_msg[18][37]  ; 
  assign dgt_error      [1062]    =      di_regoin_msg[18][9]   ; 
  assign do_regoin_r_msg[18][9]   =      dgt_start      [1062]  ; 
//  assign qdqg_up        [1062]    =      di_regoin_msg[18][18]  ; 
//  assign qdqg_down      [1062]    =      di_regoin_msg[18][19]  ; 
//  assign do_regoin_r_msg[18][16]  =      qdqg_out       [1062]  ; 
//  assign cdqg_put_out   [1062]    =      di_regoin_msg[18][20]  ; 
//  assign cdqg_draw_back [1062]    =      di_regoin_msg[18][21]  ; 
//  assign do_regoin_r_msg[18][17]  =      cdqg_out       [1062]  ; 

/////////////////////////////////////////////////////////////////////////////////wf
generate
        for (genvar k=1036; k < (1063); k=k+3)begin:ROLLER_M0_B      //from master branch 0 and node 1000
            rll_ic_oc_comp_top
            #(
                 .REG_SPACE_BIAS(ROLLER_M0_B_REG_BIAS[k])
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  (k           )
                ,.WORK_OUT1_PATH(k          )
            )
                roller_M0K_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[k] )  //arrive_test_mf
                    ,.dgt_error                 (dgt_error[k]   )
                    ,.dgt_start                 (dgt_start[k]   )

                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k] )
                    ,.comp_irq                  (rll_comp_irq[k]    )
                //  components interface

                    ,.s1_token_if               (roller_s01_token_if[k])
                    ,.m1_token_if               (roller_s01_token_if[k+1])
                );
            //17 18 19 20 21 22 23 24 25
                rll_ic_oc_comp_top
                #(
                     .REG_SPACE_BIAS(ROLLER_M0_B_REG_BIAS[k+1])
                    ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                    ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                    ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                    ,.CUR_LOCATION  (k+1           )
                    ,.WORK_OUT1_PATH(k+1          )
                )
                    roller_k_u
                    (
                         .clk                       (clk        )
                        ,.reset                     (reset      )

                    //  ps interface
                        //reg cfg interface
                        ,.ps_reg_clk                (ps_reg_clk     )
                        ,.ps_reg_reset              (ps_reg_reset   )
                        
                        ,.mat_arrived               (mat_arrived[k+1] )  //arrive_test_mf
                        ,.dgt_error                 (dgt_error[k+1]   )
                        ,.dgt_start                 (dgt_start[k+1]   )

                        ,.ps_reg_we                 (ps_reg_we     )
                        ,.ps_reg_addr               (ps_reg_addr   )
                        ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                        ,.ps_reg_re                 (ps_reg_re     )
                        ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                        ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k+1] )
                        ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k+1] )
                        ,.comp_irq                  (rll_comp_irq[k+1]    )
                    //  components interface

                        ,.s1_token_if               (roller_s01_token_if[k+1])
                        ,.m1_token_if               (roller_s01_token_if[k+2])
                    );
            end
   endgenerate
//////1099
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1099_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1099           )
        ,.WORK_OUT1_PATH (14'd1100          )
    )
        roller_1099_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][52]   )   
            ,.dgt_error                 (di_regoin_msg[9][42]   )    
            ,.dgt_start                 (do_regoin_r_msg[9][6]  )    


        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1099] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1099] )
            ,.comp_irq                  (rll_comp_irq[1099]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1099])
            ,.m1_token_if               (roller_s01_token_if[1100])
        );

 ////////////1100
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1100_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1100           )
        ,.WORK_OUT1_PATH (14'd1101         )
    )
        roller_1100_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[10][40]   )
            ,.dgt_error                 (di_regoin_msg[10][0]   )  
            ,.dgt_start                 (do_regoin_r_msg[10][0]  ) 

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1100] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1100] )
            ,.comp_irq                  (rll_comp_irq[1100]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1100])
            ,.m1_token_if               (roller_s01_token_if[1101])
        );
////////////1101
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1101_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1101           )
        ,.WORK_OUT1_PATH (14'd1102         )
    )
        roller_1101_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][20]   )  
            ,.dgt_error                 (di_regoin_msg[9][43]   )   
            ,.dgt_start                 (do_regoin_r_msg[9][7]  )   

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1101] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1101] )
            ,.comp_irq                  (rll_comp_irq[1101]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1101])
            ,.m1_token_if               (roller_s01_token_if[1102])
        );
////////////1102
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1102_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1102           )
        ,.WORK_OUT1_PATH (14'd1103         )
    )
        roller_1102_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[10][41]   ) 
            ,.dgt_error                 (di_regoin_msg[10][1]   )   
            ,.dgt_start                 (do_regoin_r_msg[10][1]  )  
  

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1102] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1102] )
            ,.comp_irq                  (rll_comp_irq[1102]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1102])
            ,.m1_token_if               (roller_s01_token_if[1103])
        );                           

rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1103_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1103         )
        ,.WORK_OUT1_PATH (14'd1105          )
    )
        roller_1103_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
             ,.mat_arrived               (di_regoin_msg[9][21]    )
            ,.dgt_error                 (di_regoin_msg[9][44]    )
            ,.dgt_start                 (do_regoin_r_msg[9][8]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1103] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1103] )
            ,.comp_irq                  (rll_comp_irq[1103]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1103])
            ,.m1_token_if               (roller_s00_token_if[1105])
        );

    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1104_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1104           )
        ,.WORK_OUT1_PATH (14'd1105          )
    )
        roller_1104_u
        (
              .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][22]    )
            ,.dgt_error                 (di_regoin_msg[9][45]    )
            ,.dgt_start                 (do_regoin_r_msg[9][9]  )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1104] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1104] )
            ,.comp_irq                  (rll_comp_irq[1104]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1104])
            ,.m1_token_if               (roller_s01_token_if[1105])
        );

      rll_transf_ic_il_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1105_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1105           )
        ,.WORK_OUT1_PATH (14'd1106          )
    )
        roller_1105_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[9][24]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[9][46]    )
            ,.dgt_start                 (do_regoin_r_msg[9][10]  )
            ,.yzqg_up                   (di_regoin_msg[9][3]    )
            ,.yzqg_down                 (di_regoin_msg[9][4]    )
            ,.yzqg_out                  (do_regoin_r_msg[9][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1105] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1105] )
            ,.comp_irq                  (rll_comp_irq[1105]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[1105])
            ,.s1_token_if               (roller_s01_token_if[1105])
            ,.m1_token_if               (roller_s01_token_if[1106])
        );    

    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1106_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1106         )
        ,.WORK_OUT1_PATH (14'd1107          )
    )
        roller_1106_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
             ,.mat_arrived               (di_regoin_msg[9][25]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[9][47]    )
            ,.dgt_start                 (do_regoin_r_msg[9][11]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1106] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1106] )
            ,.comp_irq                  (rll_comp_irq[1106]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1106])
            ,.m1_token_if               (roller_s01_token_if[1107])
        );        

  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1107_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1107           )
        ,.WORK_OUT1_PATH (14'd1108         )
    )
        roller_1107_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[9][26]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[9][48]    )
            ,.dgt_start                 (do_regoin_r_msg[9][12]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1107] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1107] )
            ,.comp_irq                  (rll_comp_irq[1107]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1107])
            ,.m1_token_if               (roller_s01_token_if[1108])
        );      
        
////////////1108
    rll_close_box_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1108_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1108           )
        ,.WORK_OUT1_PATH (14'd1110          )
    )
        roller_1108_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][27]   )  
            ,.dgt_error                 (di_regoin_msg[9][49]   )
            ,.dgt_start                 (do_regoin_r_msg[9][13] )
            ,.qdqg_up                   (di_regoin_msg[9][5]    )
            ,.qdqg_down                 (di_regoin_msg[9][6]    )
            ,.qdqg_out                  (do_regoin_r_msg[9][19] )
            ,.cdqg_put_out              (di_regoin_msg[9][7]    )
            ,.cdqg_draw_back            (di_regoin_msg[9][8]    )
            ,.cdqg_out                  (do_regoin_r_msg[9][20] )
            ,.khg_di1                   (di_regoin_msg[9][34]   ) 
            ,.khg_di2                   (di_regoin_msg[9][32]   )
            ,.khg_dq1                   (do_regoin_r_msg[9][25] )
            ,.khg_dq2                   (do_regoin_r_msg[9][30] )
            ,.khg_error                 (di_regoin_msg[9][53]   )
 
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1108] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1108] )
            ,.comp_irq                  (rll_comp_irq[1108]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1108])
            ,.m1_token_if               (roller_s01_token_if[1110])
        );

////////////1110
    rll_scan_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1110_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1110           )
        ,.WORK_OUT1_PATH (14'd2000         )
         ,.SLAVE_PCB_NUM  (9)
        ,.LOCK_SCAN_ADDR(`DEPOT_BIAS_RS232_1ST)
    )
        roller_1110_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
          ,.mat_arrived               (di_regoin_msg[9][29]   )
            ,.dgt_error                 (di_regoin_msg[9][51]    )
            ,.dgt_start                 (do_regoin_r_msg[9][15]  )

            ,.rs232_1st_vld             (sys_wea[9]           )
            ,.rs232_1st_addr            (sys_addra[9]         )
            ,.rs232_1st_msg             (rs232_1st_msg[9]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1110] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1110] )
            ,.comp_irq                  (rll_comp_irq[1110]      )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1110])
            ,.m1_token_if               (roller_s01_token_if[2000])
        );
////////////2000
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2000_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2000           )
        ,.WORK_OUT1_PATH (14'd2004         )
    )
        roller_2000_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
             ,.mat_arrived               (di_regoin_msg[2][33]   )
            ,.dgt_error                 (di_regoin_msg[2][0]    )
            ,.dgt_start                 (do_regoin_r_msg[2][0]  )
  
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2000] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2000] )
            ,.comp_irq                  (rll_comp_irq[2000]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[2000])
            ,.m1_token_if               (roller_s01_token_if[2004])
        );
   rll_scan_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2007_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2007           )
        ,.WORK_OUT1_PATH (14'd2003         )
        ,.SLAVE_PCB_NUM  (2)
        ,.LOCK_SCAN_ADDR(`DEPOT_BIAS_RS232_1ST)
    )
        roller_2007_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[2][40]   )
            ,.dgt_error                 (di_regoin_msg[2][5]   )
            ,.dgt_start                 (do_regoin_r_msg[2][5]  )

            ,.rs232_1st_vld             (sys_wea[2]           )
            ,.rs232_1st_addr            (sys_addra[2]         )
            ,.rs232_1st_msg             (rs232_1st_msg[2]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2007] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2007] )
            ,.comp_irq                  (rll_comp_irq[2007]      )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2007])
            ,.m1_token_if               (roller_s01_token_if[2003])
        );

    roller_midpoint_23
    #(
         .REG_SPACE_BIAS(`ROLLER_2003_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2003           )
        ,.WORK_OUT0_PATH (14'd2114          )
        ,.WORK_OUT1_PATH (14'd2002          )
        ,.WORK_OUT2_PATH (14'd2004          )
    )
        roller_2003_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][36]   )
            ,.dgt_error                 (di_regoin_msg[2][2]    )
            ,.dgt_start                 (do_regoin_r_msg[2][2]  )
            ,.yzqg_up                   (di_regoin_msg[2][17]   )
            ,.yzqg_down                 (di_regoin_msg[2][18]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][16] )
            ,.yzdj_start_z              (do_regoin_r_msg[2][27] )
            ,.yzdj_start_f              (do_regoin_r_msg[2][28] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2003] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2003] )
            ,.comp_irq                  (rll_comp_irq[2003]   )
        //  components interface
            ,.s0_token_if               (roller_s00_token_if[2003])
            ,.s1_token_if               (roller_s01_token_if[2003])     //(roller_m01_token_if_sp[1])
            ,.m0_token_if               (roller_s01_token_if[2114])
            ,.m1_token_if               (roller_s01_token_if[2002])
            ,.m2_token_if               (roller_s00_token_if[2004])     //(roller_m01_token_if_mp[0])
        );

    roller_midpoint_23
    #(
         .REG_SPACE_BIAS(`ROLLER_2004_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2004           )
        ,.WORK_OUT0_PATH (14'd2005          )
        ,.WORK_OUT1_PATH (14'd2006          )
        ,.WORK_OUT2_PATH (14'd2003          )
    )
        roller_2004_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][37]   )
            ,.dgt_error                 (di_regoin_msg[2][3]    )
            ,.dgt_start                 (do_regoin_r_msg[2][3]  )
            ,.yzqg_up                   (di_regoin_msg[2][19]   )
            ,.yzqg_down                 (di_regoin_msg[2][20]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][17] )
            ,.yzdj_start_z              (do_regoin_r_msg[2][29] )
            ,.yzdj_start_f              (do_regoin_r_msg[2][30] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2004] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2004] )
            ,.comp_irq                  (rll_comp_irq[2004]    )
        //  components interface
            ,.s0_token_if               (roller_s00_token_if[2004])     //(roller_m01_token_if_mp[0])
            ,.s1_token_if               (roller_s01_token_if[2004])
            ,.m0_token_if               (roller_s01_token_if[2005])     //(roller_m01_token_if_mp[1])
            ,.m1_token_if               (roller_s01_token_if[2006])     //(roller_m01_token_if_mp[2])
            ,.m2_token_if               (roller_s00_token_if[2003])
        );

    roller_midpoint_il_oc
    #(
         .REG_SPACE_BIAS(`ROLLER_2005_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2005           )
        ,.WORK_OUT1_PATH (14'd2001          )
    )
        roller_2005_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][39]   )
            ,.dgt_error                 (di_regoin_msg[2][4]    )
            ,.dgt_start                 (do_regoin_r_msg[2][4]  )
            ,.yzqg_up                   (di_regoin_msg[2][21]   )
            ,.yzqg_down                 (di_regoin_msg[2][22]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][18] )
            ,.yzdj_start_z              (do_regoin_r_msg[2][31] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2005] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2005] )
            ,.comp_irq                  (rll_comp_irq[2005]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2005])
            ,.m1_token_if               (roller_s01_token_if[2001])
        );

    roller_endpoint_alm
    #(
         .REG_SPACE_BIAS(`ROLLER_2001_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2001           )
        ,.WORK_OUT1_PATH (14'd2001          )
    )
        roller_2001_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][34]  )
            ,.wl                        (do_regoin_r_msg[2][25])

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2001] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2001] )
            ,.comp_irq                  (rll_comp_irq[2001]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2001])
        );

    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2006_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2006           )
        ,.WORK_OUT1_PATH (14'd2008          )
    )
        roller_2006_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_mst_msg[49] )       //di_mst_msg[30]
            ,.dgt_error                 (di_mst_msg[16] )
            ,.dgt_start                 (do_mst_msg[0]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2006] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2006] )
            ,.comp_irq                  (rll_comp_irq[2006]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2006])
            ,.m1_token_if               (roller_s01_token_if[2008])
        );
        
    roller_midpoint_ic_or
    #(
         .REG_SPACE_BIAS(`ROLLER_2008_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2008           )
        ,.WORK_OUT1_PATH (14'd2009          )
    )
        roller_2008_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][41]   )
            ,.dgt_error                 (di_regoin_msg[2][6]    )
            ,.dgt_start                 (do_regoin_r_msg[2][6]  )
            ,.yzqg_up                   (di_regoin_msg[2][23]   )
            ,.yzqg_down                 (di_regoin_msg[2][24]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][19] )
            ,.yzdj_start_z              (do_regoin_r_msg[3][28] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2008] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2008] )
            ,.comp_irq                  (rll_comp_irq[2008]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2008])
            ,.m1_token_if               (roller_s01_token_if[2009])
        );
        
    rll_transf_il_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2009_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2009           )
        ,.WORK_OUT1_PATH (14'd2010          )
        ,.WORK_OUT0_PATH (14'd2012          ) 
    )
        roller_2009_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][42]   )
            ,.dgt_error                 (di_regoin_msg[2][7]    )
            ,.dgt_start                 (do_regoin_r_msg[2][7]  )
            ,.yzqg_up                   (di_regoin_msg[2][25]   )
            ,.yzqg_down                 (di_regoin_msg[2][26]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][20] )
            ,.yzdj_start_z              (do_regoin_r_msg[3][29] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2009] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2009] )
            ,.comp_irq                  (rll_comp_irq[2009]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2009])
            ,.m1_token_if               (roller_s01_token_if[2010])
            ,.m0_token_if               (roller_s01_token_if[2012])
        );
        
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2010_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2010           )
        ,.WORK_OUT1_PATH (14'd2011          )
    )
        roller_2010_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][43]   )
            ,.dgt_error                 (di_regoin_msg[2][8]    )
            ,.dgt_start                 (do_regoin_r_msg[2][8]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2010] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2010] )
            ,.comp_irq                  (rll_comp_irq[2010]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2010])
            ,.m1_token_if               (roller_s01_token_if[2011])
        );
        
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2011_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2011           )
        ,.WORK_OUT1_PATH (14'd2011          )
    )
        roller_2011_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][44]   )
            ,.dgt_error                 (di_regoin_msg[2][9]    )
            ,.dgt_start                 (do_regoin_r_msg[2][9]  )
            ,.yzqg_up                   (di_regoin_msg[2][27]   )
            ,.yzqg_down                 (di_regoin_msg[2][28]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][21] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2011] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2011] )
            ,.comp_irq                  (rll_comp_irq[2011]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2011])
        );
///////////////////2002
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2002_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2002           )
        ,.WORK_OUT1_PATH (14'd1111         )
    )
        roller_2002_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[2][35]   )
            ,.dgt_error                 (di_regoin_msg[2][1]    )
            ,.dgt_start                 (do_regoin_r_msg[2][1]  )
            ,.yzqg_up                   (di_regoin_msg[2][15]    )
            ,.yzqg_down                 (di_regoin_msg[2][16]    )
            ,.yzqg_out                  (do_regoin_r_msg[2][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[2][26]  )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2002] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2002] )
            ,.comp_irq                  (rll_comp_irq[2002]    )
        //  components interface
            
             ,.s0_token_if               (roller_s00_token_if[2002])
	         ,.s1_token_if               (roller_s01_token_if[2002])
            ,.m1_token_if               (roller_s01_token_if[1111])
        );
    
     rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1111_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1111           )
        ,.WORK_OUT1_PATH (14'd1109          )
    )
        roller_1111_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][30]   )
            ,.dgt_error                 (di_regoin_msg[9][0]    )
            ,.dgt_start                 (do_regoin_r_msg[9][16] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1111] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1111] )
            ,.comp_irq                  (rll_comp_irq[1111]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[1111])
            ,.m1_token_if               (roller_s01_token_if[1109])
        );
        
    rll_open_box_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1109_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1109           )
        ,.WORK_OUT1_PATH (14'd1000          )
    )
        roller_1109_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[9][28]   )
            ,.dgt_error                 (di_regoin_msg[9][50]   )
            ,.dgt_start                 (do_regoin_r_msg[9][14] )
            ,.qdqg_up                   (di_regoin_msg[9][9]    )
            ,.qdqg_down                 (di_regoin_msg[9][10]   )
            ,.qdqg_out                  (do_regoin_r_msg[9][21] )
            ,.cdqg_put_out              (di_regoin_msg[9][11]   )
            ,.cdqg_draw_back            (di_regoin_msg[9][12]   )
            ,.cdqg_out                  (do_regoin_r_msg[9][22] )
            ,.khg_di1                   (di_regoin_msg[9][35]   ) 
            ,.khg_di2                   (di_regoin_msg[9][33]   )
            ,.khg_dq1                   (do_regoin_r_msg[9][26] )
            ,.khg_dq2                   (do_regoin_r_msg[9][31] )
            ,.khg_error                 (di_regoin_msg[9][53]   )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1109] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1109] )
            ,.comp_irq                  (rll_comp_irq[1109]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[1109])
            ,.m1_token_if               (roller_s01_token_if[1000])
        );

/////////////////////////////////////////////////////////////////////////////jieshu
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1015_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1015           )
        ,.WORK_OUT1_PATH (14'd1016          )
    )
        roller_1015_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[18][29]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[18][1]    )
            ,.dgt_start                 (do_regoin_r_msg[18][1]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1015] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1015] )
            ,.comp_irq                  (rll_comp_irq[1015]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1015])
            ,.m1_token_if               (roller_s01_token_if[1016])
        );

    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1016_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1016           )
        ,.WORK_OUT1_PATH (14'd1017          )
    )
        roller_1016_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[18][30]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[18][2]    )
            ,.dgt_start                 (do_regoin_r_msg[18][2]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1016] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1016] )
            ,.comp_irq                  (rll_comp_irq[1016]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1016])
            ,.m1_token_if               (roller_s01_token_if[1017])
        );
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1017_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1017           )
        ,.WORK_OUT1_PATH (14'd1018          )
    )
        roller_1017_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[18][31]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[18][3]    )
            ,.dgt_start                 (do_regoin_r_msg[18][3]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1017] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1017] )
            ,.comp_irq                  (rll_comp_irq[1017]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1017])
            ,.m1_token_if               (roller_s01_token_if[1018])
        );    

/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1018_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1018           )
        ,.WORK_OUT1_PATH (14'd1019          )
    )
        roller_1018_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[18][32]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[18][4]    )
            ,.dgt_start                 (do_regoin_r_msg[18][4]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1018] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1018] )
            ,.comp_irq                  (rll_comp_irq[1018]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1018])
            ,.m1_token_if               (roller_s01_token_if[1019])
        );    
/////////////////////////////////////////////////////////////////////////////jieshu

    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1019_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1019           )
        ,.WORK_OUT1_PATH (14'd1020          )
    )
        roller_1019_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
             ,.mat_arrived               (di_regoin_msg[18][33]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[18][5]    )
            ,.dgt_start                 (do_regoin_r_msg[18][5]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1019] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1019] )
            ,.comp_irq                  (rll_comp_irq[1019]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1019])
            ,.m1_token_if               (roller_s01_token_if[1020])
        );
//================================================second region
    assign  mat_arrived[1020]           =   di_regoin_msg[18][34];
    assign  dgt_error[1020]             =   di_regoin_msg[18][6];
    assign  yzqg_up[1020]               =   di_regoin_msg[18][16];
    assign  yzqg_down[1020]             =   di_regoin_msg[18][17];
    assign  do_regoin_r_msg[18][6]      =   dgt_start[1020];
    assign  do_regoin_r_msg[18][15]     =   yzqg_out[1020];
    assign  do_regoin_r_msg[18][25]     =   yzdj_start_z[1020];

    assign  mat_arrived[1021]           =   di_regoin_msg[17][24];
    assign  dgt_error[1021]             =   di_regoin_msg[17][1];
    assign  yzqg_up[1021]               =   di_regoin_msg[17][11];
    assign  yzqg_down[1021]             =   di_regoin_msg[17][12];
    assign  do_regoin_r_msg[17][1]      =   dgt_start[1021];
    assign  do_regoin_r_msg[17][10]     =   yzqg_out[1021];
    assign  do_regoin_r_msg[17][19]     =   yzdj_start_z[1021];

    assign  mat_arrived[1022]           =   di_regoin_msg[16][24];
    assign  dgt_error[1022]             =   di_regoin_msg[16][1];
    assign  yzqg_up[1022]               =   di_regoin_msg[16][11];
    assign  yzqg_down[1022]             =   di_regoin_msg[16][12];
    assign  do_regoin_r_msg[16][1]      =   dgt_start[1022];
    assign  do_regoin_r_msg[16][10]     =   yzqg_out[1022];
    assign  do_regoin_r_msg[16][19]     =   yzdj_start_z[1022];

    assign  mat_arrived[1023]           =    di_regoin_msg[15][24];
    assign  dgt_error[1023]             =    di_regoin_msg[15][1];
    assign  yzqg_up[1023]               =    di_regoin_msg[15][11];
    assign  yzqg_down[1023]             =    di_regoin_msg[15][12];
    assign  do_regoin_r_msg[15][1]      =    dgt_start[1023];
    assign  do_regoin_r_msg[15][10]     =    yzqg_out[1023];
    assign  do_regoin_r_msg[15][19]     =    yzdj_start_z[1023];

    assign  mat_arrived[1024]           =   di_regoin_msg[14][24];
    assign  dgt_error[1024]             =   di_regoin_msg[14][1];
    assign  yzqg_up[1024]               =   di_regoin_msg[14][11];
    assign  yzqg_down[1024]             =   di_regoin_msg[14][12];
    assign  do_regoin_r_msg[14][1]      =   dgt_start[1024];
    assign  do_regoin_r_msg[14][10]     =   yzqg_out[1024];
    assign  do_regoin_r_msg[14][19]     =   yzdj_start_z[1024];

    assign  mat_arrived[1025]           =    di_regoin_msg[13][24];
    assign  dgt_error[1025]             =    di_regoin_msg[13][1];
    assign  yzqg_up[1025]               =    di_regoin_msg[13][11];
    assign  yzqg_down[1025]             =    di_regoin_msg[13][12];
    assign  do_regoin_r_msg[13][1]      =    dgt_start[1025];
    assign  do_regoin_r_msg[13][10]     =    yzqg_out[1025];
    assign  do_regoin_r_msg[13][19]     =    yzdj_start_z[1025];

    assign  mat_arrived[1026]           =    di_regoin_msg[12][24];
    assign  dgt_error[1026]             =    di_regoin_msg[12][1];
    assign  yzqg_up[1026]               =    di_regoin_msg[12][11];
    assign  yzqg_down[1026]             =    di_regoin_msg[12][12];
    assign  do_regoin_r_msg[12][1]      =    dgt_start[1026];
    assign  do_regoin_r_msg[12][10]     =    yzqg_out[1026];
    assign  do_regoin_r_msg[12][19]     =    yzdj_start_z[1026];

    assign  mat_arrived[1027]           =    di_regoin_msg[11][24];
    assign  dgt_error[1027]             =    di_regoin_msg[11][1];
    assign  yzqg_up[1027]               =    di_regoin_msg[11][11];
    assign  yzqg_down[1027]             =    di_regoin_msg[11][12];
    assign  do_regoin_r_msg[11][1]      =    dgt_start[1027];
    assign  do_regoin_r_msg[11][10]     =    yzqg_out[1027];
    assign  do_regoin_r_msg[11][19]     =    yzdj_start_z[1027];

    assign  mat_arrived[1028]           =    di_regoin_msg[10][26];
    assign  dgt_error[1028]             =    di_regoin_msg[10][3];
    assign  yzqg_up[1028]               =    di_regoin_msg[10][13];
    assign  yzqg_down[1028]             =    di_regoin_msg[10][14];
    assign  do_regoin_r_msg[10][13]     =    dgt_start[1028];
    assign  do_regoin_r_msg[10][22]     =    yzqg_out[1028];
    assign  do_regoin_r_msg[10][5]      =    yzdj_start_z[1028];

    assign  mat_arrived[1029]           =    di_regoin_msg[10][42];
    assign  dgt_error[1029]             =    di_regoin_msg[10][30];
    assign  do_regoin_r_msg[10][6]      =    dgt_start[1029];

    assign  mat_arrived[1030]           =    di_regoin_msg[10][43];
    assign  dgt_error[1030]             =    di_regoin_msg[10][31];
    assign  do_regoin_r_msg[10][7]      =    dgt_start[1030];

    assign  mat_arrived[1031]           =    di_regoin_msg[10][44];
    assign  dgt_error[1031]             =    di_regoin_msg[10][32];
    assign  do_regoin_r_msg[10][8]      =    dgt_start[1031];

    assign  mat_arrived[1032]           =   di_regoin_msg[10][45];
    assign  dgt_error[1032]             =   di_regoin_msg[10][33];
    assign  do_regoin_r_msg[10][9]      =   dgt_start[1032];

    assign  mat_arrived[1033]           =   di_regoin_msg[10][46];
    assign  dgt_error[1033]             =   di_regoin_msg[10][34];
    assign  do_regoin_r_msg[10][10]     =   dgt_start[1033];

    assign  mat_arrived[1034]           =   di_regoin_msg[10][47];
    assign  dgt_error[1034]             =   di_regoin_msg[10][35];
    assign  do_regoin_r_msg[10][11]     =   dgt_start[1034];

    assign  mat_arrived[1063]           =   di_regoin_msg[18][38];
    assign  dgt_error[1063]             =   di_regoin_msg[18][10];
    assign  do_regoin_r_msg[18][10]     =   dgt_start[1063];

    assign  mat_arrived[1066]           =   di_regoin_msg[17][28];
    assign  dgt_error[1066]             =   di_regoin_msg[17][5];
    assign  do_regoin_r_msg[17][5]      =   dgt_start[1066];

    assign  mat_arrived[1069]           =   di_regoin_msg[16][28];
    assign  dgt_error[1069]             =   di_regoin_msg[16][5];
    assign  do_regoin_r_msg[16][5]      =   dgt_start[1069];

    assign  mat_arrived[1072]           =   di_regoin_msg[15][28];
    assign  dgt_error[1072]             =   di_regoin_msg[15][5];
    assign  do_regoin_r_msg[15][5]      =   dgt_start[1072];

    assign  mat_arrived[1075]           =   di_regoin_msg[14][28];
    assign  dgt_error[1075]             =   di_regoin_msg[14][5];
    assign  do_regoin_r_msg[14][5]      =   dgt_start[1075];

    assign  mat_arrived[1078]           =   di_regoin_msg[13][28];
    assign  dgt_error[1078]             =   di_regoin_msg[13][5];
    assign  do_regoin_r_msg[13][5]      =   dgt_start[1078];

    assign  mat_arrived[1081]           =   di_regoin_msg[12][28];
    assign  dgt_error[1081]             =   di_regoin_msg[12][5];
    assign  do_regoin_r_msg[12][5]      =   dgt_start[1081];

    assign  mat_arrived[1084]           =   di_regoin_msg[11][28];
    assign  dgt_error[1084]             =   di_regoin_msg[11][5];
    assign  do_regoin_r_msg[11][5]      =   dgt_start[1084];

    assign  mat_arrived[1087]           =   di_regoin_msg[10][36];
    assign  dgt_error[1087]             =   di_regoin_msg[10][7];
    assign  do_regoin_r_msg[10][17]     =   dgt_start[1087];
 ////////////////////////////////////////////////////////////////////////////////////wf
 ////1064
            assign mat_arrived   [1064]    =    di_regoin_msg[18][39]  ;
            assign dgt_error     [1064]    =    di_regoin_msg[18][11]  ;
            assign do_regoin_r_msg[18][11] =    dgt_start     [1064] ;    
//1065
assign mat_arrived      [1065]      =   di_regoin_msg[18][40]   ;
assign dgt_error        [1065]      =   di_regoin_msg[18][9]    ;              
assign do_regoin_r_msg[18][12]      =   dgt_start[1065]         ;
//assign qdqg_up          [1065]      =   di_regoin_msg[18][22]   ;
//assign qdqg_down        [1065]      =   di_regoin_msg[18][23]   ;
//assign do_regoin_r_msg[18][18]      =   qdqg_out [1065]         ;
//assign cdqg_put_out     [1065]      =   di_regoin_msg[18][24]   ;
//assign cdqg_draw_back   [1065]      =   di_regoin_msg[18][25]   ;
//assign do_regoin_r_msg[18][19]      =   cdqg_out [1065]         ;

///////1067
assign mat_arrived    [1067]      =     di_regoin_msg[17][29]     ;
assign dgt_error      [1067]      =     di_regoin_msg[17][6]      ;
assign do_regoin_r_msg[17][6]     =     dgt_start      [1067]     ; 
//1068
  assign mat_arrived      [1068] =       di_regoin_msg[17][30]      ;
  assign dgt_error        [1068] =       di_regoin_msg[17][7]       ;
  assign do_regoin_r_msg[17][7]  =       dgt_start        [1068]    ;
  assign qdqg_up          [1068] =       di_regoin_msg[17][17]      ;
  assign qdqg_down        [1068] =       di_regoin_msg[17][18]      ;
  assign do_regoin_r_msg[17][13] =       qdqg_out         [1068]    ;
  assign cdqg_put_out     [1068] =       di_regoin_msg[17][19]      ;
  assign cdqg_draw_back   [1068] =       di_regoin_msg[17][20]      ;
  assign do_regoin_r_msg[17][14] =       cdqg_out         [1068]    ;
 //1070
  assign mat_arrived     [1070]      =    di_regoin_msg[16][29]     ;  
  assign dgt_error       [1070]      =    di_regoin_msg[16][6]      ;  
  assign do_regoin_r_msg[16][6]      =    dgt_start       [1070]    ; 
//1071
 assign mat_arrived      [1071]     =   di_regoin_msg[16][30]        ;                           
 assign dgt_error        [1071]     =   di_regoin_msg[16][7]         ;                                                                           
 assign do_regoin_r_msg[16][7]      =   dgt_start        [1071]      ;
 assign qdqg_up          [1071]     =   di_regoin_msg[16][17]        ;
 assign qdqg_down        [1071]     =   di_regoin_msg[16][18]        ;
 assign do_regoin_r_msg[16][13]     =   qdqg_out         [1071]      ;
 assign cdqg_put_out     [1071]     =   di_regoin_msg[16][19]        ;
 assign cdqg_draw_back   [1071]     =   di_regoin_msg[16][20]        ;
 assign do_regoin_r_msg[16][14]     =   cdqg_out         [1071]      ;   
////1073
assign mat_arrived    [1073]     =      di_regoin_msg[15][29]        ;
assign dgt_error      [1073]     =      di_regoin_msg[15][6]         ;
assign do_regoin_r_msg[15][6]    =      dgt_start      [1073]        ;  
///1074
assign  mat_arrived       [1074]   =     di_regoin_msg[15][30]        ;
assign  dgt_error         [1074]   =     di_regoin_msg[15][7]         ;
assign  do_regoin_r_msg[15][7]     =     dgt_start         [1074]     ;
assign  qdqg_up           [1074]   =     di_regoin_msg[15][17]        ;
assign  qdqg_down         [1074]   =     di_regoin_msg[15][18]        ;
assign  do_regoin_r_msg[15][13]    =     qdqg_out          [1074]     ;
assign  cdqg_put_out      [1074]   =     di_regoin_msg[15][19]        ;
assign  cdqg_draw_back    [1074]   =     di_regoin_msg[15][20]        ;
assign  do_regoin_r_msg[15][14]    =     cdqg_out          [1074]     ;
////1076
 assign  mat_arrived    [1076]     =      di_regoin_msg[14][29]        ;
 assign  dgt_error      [1076]     =      di_regoin_msg[14][6]         ;
 assign  do_regoin_r_msg[14][6]    =      dgt_start      [1076]        ;
 //1077
  assign  mat_arrived      [1077]    =     di_regoin_msg[14][30]        ;
  assign  dgt_error        [1077]    =     di_regoin_msg[14][7]         ;
  assign  do_regoin_r_msg[14][7]     =     dgt_start        [1077]      ;  
  assign  qdqg_up          [1077]    =     di_regoin_msg[14][17]        ;
  assign  qdqg_down        [1077]    =     di_regoin_msg[14][18]        ;
  assign  do_regoin_r_msg[14][13]    =     qdqg_out         [1077]      ;
  assign  cdqg_put_out     [1077]    =     di_regoin_msg[14][19]        ;
  assign  cdqg_draw_back   [1077]    =     di_regoin_msg[14][20]        ; 
  assign  do_regoin_r_msg[14][14]    =     cdqg_out         [1077]      ;
 //1079
   assign  mat_arrived    [1079]    =       di_regoin_msg[13][29]   ;         
   assign  dgt_error      [1079]    =       di_regoin_msg[13][6]    ;         
   assign  do_regoin_r_msg[13][6]   =       dgt_start      [1079]   ;   
   //1080
    assign  mat_arrived        [1080]   =    di_regoin_msg[13][30]          ;              
    assign  dgt_error          [1080]   =    di_regoin_msg[13][7]           ;        
    assign  do_regoin_r_msg[13][7]      =    dgt_start          [1080]      ;
    assign  qdqg_up            [1080]   =    di_regoin_msg[13][17]          ;
    assign  qdqg_down          [1080]   =    di_regoin_msg[13][18]          ;
    assign  do_regoin_r_msg[13][13]     =    qdqg_out           [1080]      ;
    assign  cdqg_put_out       [1080]   =    di_regoin_msg[13][19]          ;
    assign  cdqg_draw_back     [1080]   =    di_regoin_msg[13][20]          ;
    assign  do_regoin_r_msg[13][14]     =    cdqg_out           [1080]      ;   
///1082
 assign  mat_arrived     [1082]    =      di_regoin_msg[12][29]         ;  
 assign  dgt_error       [1082]    =      di_regoin_msg[12][6]          ;  
 assign  do_regoin_r_msg[12][6]    =      dgt_start       [1082]        ; 
///1083
assign  mat_arrived     [1083]    =      di_regoin_msg[12][30]         ;         
assign  dgt_error       [1083]    =      di_regoin_msg[12][7]          ;
assign  do_regoin_r_msg[12][7]    =      dgt_start       [1083]        ;
assign  qdqg_up         [1083]    =      di_regoin_msg[12][17]         ;
assign  qdqg_down       [1083]    =      di_regoin_msg[12][18]         ;
assign  do_regoin_r_msg[12][13]   =      qdqg_out        [1083]        ;
assign  cdqg_put_out    [1083]    =      di_regoin_msg[12][19]         ;
assign  cdqg_draw_back  [1083]    =      di_regoin_msg[12][20]         ;
assign  do_regoin_r_msg[12][14]   =      cdqg_out        [1083]        ;
//1085    
  assign mat_arrived  [1085]    =          di_regoin_msg[11][29]     ;
  assign dgt_error    [1085]    =          di_regoin_msg[11][6]      ;
  assign do_regoin_r_msg[11][6] =          dgt_start    [1085]       ;     
 ///1086
 assign mat_arrived      [1086]  =       di_regoin_msg[11][30]      ; 
 assign dgt_error        [1086]  =       di_regoin_msg[11][7]       ; 
 assign do_regoin_r_msg[11][7]   =       dgt_start        [1086]    ;
 assign qdqg_up          [1086]  =       di_regoin_msg[11][17]      ; 
 assign qdqg_down        [1086]  =       di_regoin_msg[11][18]      ; 
 assign do_regoin_r_msg[11][13]  =       qdqg_out         [1086]    ;  
 assign cdqg_put_out     [1086]  =       di_regoin_msg[11][19]      ; 
 assign cdqg_draw_back   [1086]  =       di_regoin_msg[11][20]      ; 
 assign do_regoin_r_msg[11][14]  =       cdqg_out         [1086]    ; 
 ////1088
  assign mat_arrived   [1088]      =      di_regoin_msg[10][37]     ;
  assign dgt_error     [1088]      =      di_regoin_msg[10][8]      ;
  assign do_regoin_r_msg[10][18]   =      dgt_start     [1088]      ;  
  //1089
  assign mat_arrived     [1089]   =       di_regoin_msg[10][38]     ;                                                  
  assign dgt_error       [1089]   =       di_regoin_msg[10][9]      ;
  assign do_regoin_r_msg[10][19]  =       dgt_start       [1089]    ;
  assign qdqg_up         [1089]   =       di_regoin_msg[10][19]     ;
  assign qdqg_down       [1089]   =       di_regoin_msg[10][20]     ;
  assign do_regoin_r_msg[10][25]  =       qdqg_out        [1089]    ; 
  assign cdqg_put_out    [1089]   =       di_regoin_msg[10][21]     ;
  assign cdqg_draw_back  [1089]   =       di_regoin_msg[10][22]     ;
  assign do_regoin_r_msg[10][26]  =       cdqg_out        [1089]    ; 
 //////////////////////////////////////////////////////////////////////////////////////////////////////
     localparam [31:0] ROLLER_M2_N_REG_BIAS[1020:1028] = '{
         `ROLLER_1020_REG_BIAS
        ,`ROLLER_1021_REG_BIAS
        ,`ROLLER_1022_REG_BIAS
        ,`ROLLER_1023_REG_BIAS
        ,`ROLLER_1024_REG_BIAS
        ,`ROLLER_1025_REG_BIAS
        ,`ROLLER_1026_REG_BIAS
        ,`ROLLER_1027_REG_BIAS
        ,`ROLLER_1028_REG_BIAS
    };

    localparam [31:0] M2_DWS_BRANCH_ID[1020:1028] = '{
         1063
        ,1066
        ,1069
        ,1072
        ,1075
        ,1078
        ,1081
        ,1084
        ,1087
    };

    generate
        for (genvar k=1020; k < (1020+9); k=k+1)begin:ROLLER_M2_N      //from master branch 0 and node 1000
            rll_transf_ic_oc_or_comp_top
            #(
                 .REG_SPACE_BIAS(ROLLER_M2_N_REG_BIAS[k])
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  (k                  )
                ,.WORK_OUT0_PATH (M2_DWS_BRANCH_ID[k])
                ,.WORK_OUT1_PATH (k+1          )
            )
                roller_mp5_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[k]  )  //arrive_test_mf
                    ,.dgt_error                 (dgt_error[k]   )
                    ,.dgt_start                 (dgt_start[k]    )
                    ,.yzqg_up                   (yzqg_up[k]      )
                    ,.yzqg_down                 (yzqg_down[k]    )
                    ,.yzqg_out                  (yzqg_out[k]     )
                    ,.yzdj_start_z              (yzdj_start_z[k])

                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k] )
                    ,.comp_irq                  (rll_comp_irq[k]    )
                //  components interface

                    ,.s1_token_if               (roller_s01_token_if[k])
                    ,.m1_token_if               (roller_s01_token_if[k+1]  )
                    ,.m0_token_if               (roller_s01_token_if[M2_DWS_BRANCH_ID[k]]  )
                );
        //1 2 3 4 5 6 7 8 9
      end
   endgenerate

    localparam [31:0] ROLLER_M2_B_REG_BIAS[1063:1089] = '{
            `ROLLER_1063_REG_BIAS 
            ,`ROLLER_1064_REG_BIAS
            ,`ROLLER_1065_REG_BIAS
            ,`ROLLER_1066_REG_BIAS
            ,`ROLLER_1067_REG_BIAS
            ,`ROLLER_1068_REG_BIAS
            ,`ROLLER_1069_REG_BIAS
            ,`ROLLER_1070_REG_BIAS
            ,`ROLLER_1071_REG_BIAS
            ,`ROLLER_1072_REG_BIAS
            ,`ROLLER_1073_REG_BIAS
            ,`ROLLER_1074_REG_BIAS
            ,`ROLLER_1075_REG_BIAS
            ,`ROLLER_1076_REG_BIAS
            ,`ROLLER_1077_REG_BIAS
            ,`ROLLER_1078_REG_BIAS
            ,`ROLLER_1079_REG_BIAS
            ,`ROLLER_1080_REG_BIAS
            ,`ROLLER_1081_REG_BIAS
            ,`ROLLER_1082_REG_BIAS
            ,`ROLLER_1083_REG_BIAS
            ,`ROLLER_1084_REG_BIAS
            ,`ROLLER_1085_REG_BIAS
            ,`ROLLER_1086_REG_BIAS
            ,`ROLLER_1087_REG_BIAS
            ,`ROLLER_1088_REG_BIAS
            ,`ROLLER_1089_REG_BIAS
    };

    generate
        for (genvar k=1063; k < (1088); k=k+3)begin:ROLLER_M2_B      //from master branch 0 and node 1000
            rll_ic_oc_comp_top
            #(
                 .REG_SPACE_BIAS(ROLLER_M2_B_REG_BIAS[k])
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  (k           )
                ,.WORK_OUT1_PATH(k          )
            )
                roller_ep1_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[k] )  //arrive_test_mf
                    ,.dgt_error                 (dgt_error[k]   )
                    ,.dgt_start                 (dgt_start[k]   )

                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k] )
                    ,.comp_irq                  (rll_comp_irq[k]    )
                //  components interface

                    ,.s1_token_if               (roller_s01_token_if[k])
                    ,.m1_token_if               (roller_s01_token_if[k+1])
                );
            // 10 11 12 13 14 15 16 17 18
//////////////////////////////////////////////////////////////////////////wf
            rll_ic_oc_comp_top
            #(
                 .REG_SPACE_BIAS(ROLLER_M2_B_REG_BIAS[k+1])
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  (k+1           )
                ,.WORK_OUT1_PATH(k+1          )
            )
                roller_M2L_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[k+1] )  
                    ,.dgt_error                 (dgt_error[k+1]   )
                    ,.dgt_start                 (dgt_start[k+1]   )

                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k+1] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k+1] )
                    ,.comp_irq                  (rll_comp_irq[k+1]    )
                //  components interface

                    ,.s1_token_if               (roller_s01_token_if[k+1])
                    ,.m1_token_if               (roller_s01_token_if[k+2])
                );
/////////////////////////////////////////wf                
//roller_location
//            #(
//                 .REG_SPACE_BIAS(ROLLER_M2_B_REG_BIAS[k+2])
//                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
//                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
//                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
//                ,.CUR_LOCATION  (k+2           )
//                ,.WORK_OUT1_PATH(k+2          )
//            )
//                roller_M2M_u
//                (
//                     .clk                       (clk        )
//                    ,.reset                     (reset      )

//                //  ps interface
//                    //reg cfg interface
//                    ,.ps_reg_clk                (ps_reg_clk     )
//                    ,.ps_reg_reset              (ps_reg_reset   )
                    
//                    ,.mat_arrived               (mat_arrived[k+2] )  
//                    ,.dgt_error                 (dgt_error[k+2]   )
//                    ,.dgt_start                 (dgt_start[k+2]   )
		    
//                    ,.qdqg_up                   (qdqg_up[k+2])
//                    ,.qdqg_down                 (qdqg_down[k+2])
//                    ,.qdqg_out                  (qdqg_out[k+2])
//                    ,.cdqg_put_out              (cdqg_put_out[k+2])
//                    ,.cdqg_draw_back            (cdqg_draw_back[k+2])
//                    ,.cdqg_out                  (cdqg_out[k+2])
    
//                    ,.ps_reg_we                 (ps_reg_we     )
//                    ,.ps_reg_addr               (ps_reg_addr   )
//                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
//                    ,.ps_reg_re                 (ps_reg_re     )
//                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
//                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[k+2] )
//                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[k+2] )
//                    ,.comp_irq                  (rll_comp_irq[k+2]    )
//                    //  components interface
    
//                    ,.s1_token_if               (roller_s01_token_if[k+2])
//                    ,.m1_token_if               (roller_s02_token_if[MM_DWS_BRANCH_ID[(k-1036)/3]])
//                );
//////////////////////////////////////////////////////////////////           
      end
   endgenerate

    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1029_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1029           )
        ,.WORK_OUT1_PATH (14'd1030          )
    )
        roller_1029_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (mat_arrived[1029]   )
            ,.dgt_error                 (dgt_error[1029]   )
            ,.dgt_start                 (dgt_start[1029]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1029] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1029] )
            ,.comp_irq                  (rll_comp_irq[1029]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1029])
            ,.m1_token_if               (roller_s01_token_if[1030])
        );
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1030_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1030           )
        ,.WORK_OUT1_PATH (14'd1031          )
    )
        roller_1030_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (mat_arrived[1030 ]   )
            ,.dgt_error                 (dgt_error[1030 ]    )
            ,.dgt_start                 (dgt_start[1030 ]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1030] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1030] )
            ,.comp_irq                  (rll_comp_irq[1030]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1030])
            ,.m1_token_if               (roller_s01_token_if[1031])
        );    
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1031_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1031           )
        ,.WORK_OUT1_PATH (14'd1032          )
    )
        roller_1031_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
           ,.mat_arrived               (mat_arrived[1031]   )
            ,.dgt_error                 (dgt_error[1031]   )
            ,.dgt_start                 (dgt_start[1031] )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1031] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1031] )
            ,.comp_irq                  (rll_comp_irq[1031]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1031])
            ,.m1_token_if               (roller_s01_token_if[1032])
        );
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1032_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1032           )
        ,.WORK_OUT1_PATH (14'd1033          )
    )
        roller_1032_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
          ,.mat_arrived               (mat_arrived[1032]   )
            ,.dgt_error                 (dgt_error[1032]    )
            ,.dgt_start                 (dgt_start[1032]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1032] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1032] )
            ,.comp_irq                  (rll_comp_irq[1032]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1032])
            ,.m1_token_if               (roller_s01_token_if[1033])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu       
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1033_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1033           )
        ,.WORK_OUT1_PATH (14'd1034          )
    )
        roller_1033_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (mat_arrived [1033]  )
            ,.dgt_error                 (dgt_error[1033] )
            ,.dgt_start                 (dgt_start[1033] )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1033] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1033] )
            ,.comp_irq                  (rll_comp_irq[1033]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[1033])
            ,.m1_token_if               (roller_s01_token_if[1034])
        );
////////////////////////////////////////////////////////////wf_3jin1chu
///1098
 rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1098_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1098           )
        ,.WORK_OUT1_PATH (14'd1099          )
    )
        roller_1098_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[10][39]    )
            ,.dgt_error                 (di_regoin_msg[10][10]    )
            ,.dgt_start                 (do_regoin_r_msg[10][20]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[10][23]    )
            ,.yzqg_down                 (di_regoin_msg[10][24]    )
            ,.yzqg_out                  (do_regoin_r_msg[10][27]  )
            ,.yzdj_start_z              (do_regoin_r_msg[10][2]  )
            ,.yzdj_start_f              (do_regoin_r_msg[10][3]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1098] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1098] )
            ,.comp_irq                  (rll_comp_irq[1098]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1098])
            ,.s1_token_if               (roller_s01_token_if[1098])
            ,.s2_token_if               (roller_s02_token_if[1098])
            ,.m1_token_if               (roller_s01_token_if[1099])
        );
///1097
  rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1097_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1097           )
        ,.WORK_OUT1_PATH (14'd1098          )
    )
        roller_1097_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[11][31]    )
            ,.dgt_error                 (di_regoin_msg[11][8]    )
            ,.dgt_start                 (do_regoin_r_msg[11][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[11][21]    )
            ,.yzqg_down                 (di_regoin_msg[11][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[11][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[11][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[11][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1097] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1097] )
            ,.comp_irq                  (rll_comp_irq[1097]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1097])
            ,.s1_token_if               (roller_s01_token_if[1097])
            ,.s2_token_if               (roller_s02_token_if[1097])
            ,.m1_token_if               (roller_s01_token_if[1098])
        ); 
////1096
 rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1096_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1096           )
        ,.WORK_OUT1_PATH (14'd1097          )
    )
        roller_1096_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[12][31]    )
            ,.dgt_error                 (di_regoin_msg[12][8]    )
            ,.dgt_start                 (do_regoin_r_msg[12][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[12][21]    )
            ,.yzqg_down                 (di_regoin_msg[12][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[12][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[12][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[12][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1096] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1096] )
            ,.comp_irq                  (rll_comp_irq[1096]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1096])
            ,.s1_token_if               (roller_s01_token_if[1096])
            ,.s2_token_if               (roller_s02_token_if[1096])
            ,.m1_token_if               (roller_s01_token_if[1097])
        ); 
//////1095
  rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1095_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1095           )
        ,.WORK_OUT1_PATH (14'd1096          )
    )
        roller_1095_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[13][31]    )
            ,.dgt_error                 (di_regoin_msg[13][8]    )
            ,.dgt_start                 (do_regoin_r_msg[13][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[13][21]    )
            ,.yzqg_down                 (di_regoin_msg[13][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[13][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[13][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[13][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1095] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1095] )
            ,.comp_irq                  (rll_comp_irq[1095]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1095])
            ,.s1_token_if               (roller_s01_token_if[1095])
            ,.s2_token_if               (roller_s02_token_if[1095])
            ,.m1_token_if               (roller_s01_token_if[1096])
        ); 
//////////1094
   rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1094_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1094           )
        ,.WORK_OUT1_PATH (14'd1095          )
    )
        roller_1094_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[14][31]    )
            ,.dgt_error                 (di_regoin_msg[14][8]    )
            ,.dgt_start                 (do_regoin_r_msg[14][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[14][21]    )
            ,.yzqg_down                 (di_regoin_msg[14][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[14][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[14][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[14][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1094] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1094] )
            ,.comp_irq                  (rll_comp_irq[1094]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1094])
            ,.s1_token_if               (roller_s01_token_if[1094])
            ,.s2_token_if               (roller_s02_token_if[1094])
            ,.m1_token_if               (roller_s01_token_if[1095])
        );  
 /////1093
   rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1093_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1093           )
        ,.WORK_OUT1_PATH (14'd1094          )
    )
        roller_1093_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[15][31]    )
            ,.dgt_error                 (di_regoin_msg[15][8]    )
            ,.dgt_start                 (do_regoin_r_msg[15][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[15][21]    )
            ,.yzqg_down                 (di_regoin_msg[15][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[15][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[15][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[15][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1093] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1093] )
            ,.comp_irq                  (rll_comp_irq[1093]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1093])
            ,.s1_token_if               (roller_s01_token_if[1093])
            ,.s2_token_if               (roller_s02_token_if[1093])
            ,.m1_token_if               (roller_s01_token_if[1094])
        );       
///1092
   rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1092_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1092           )
        ,.WORK_OUT1_PATH (14'd1093          )
    )
        roller_1092_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[16][31]    )
            ,.dgt_error                 (di_regoin_msg[16][8]    )
            ,.dgt_start                 (do_regoin_r_msg[16][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[16][21]    )
            ,.yzqg_down                 (di_regoin_msg[16][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[16][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[16][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[16][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1092] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1092] )
            ,.comp_irq                  (rll_comp_irq[1092]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1092])
            ,.s1_token_if               (roller_s01_token_if[1092])
            ,.s2_token_if               (roller_s02_token_if[1092])
            ,.m1_token_if               (roller_s01_token_if[1093])
        );        
/////1091
 rll_transf_ic_il_ir_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1091_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1091           )
        ,.WORK_OUT1_PATH (14'd1092          )
    )
        roller_1091_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[17][31]    )
            ,.dgt_error                 (di_regoin_msg[17][8]    )
            ,.dgt_start                 (do_regoin_r_msg[17][8]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][11]  )
            ,.yzqg_up                   (di_regoin_msg[17][21]    )
            ,.yzqg_down                 (di_regoin_msg[17][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[17][15]  )
            ,.yzdj_start_z              (do_regoin_r_msg[17][16]  )
            ,.yzdj_start_f              (do_regoin_r_msg[17][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1091] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1091] )
            ,.comp_irq                  (rll_comp_irq[1091]    )
        //  components interface

            ,.s0_token_if               (roller_s00_token_if[1091])
            ,.s1_token_if               (roller_s01_token_if[1091])
            ,.s2_token_if               (roller_s02_token_if[1091])
            ,.m1_token_if               (roller_s01_token_if[1092])
        );   
 //1090:2jin1chu
  roller_midpoint2_1
    #(
         .REG_SPACE_BIAS(`ROLLER_1090_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1090           )
        ,.WORK_OUT1_PATH (14'd1091         )
    )
        roller_1090_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[18][41]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[18][13]    )
            ,.dgt_start                 (do_regoin_r_msg[18][13]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[18][26]    )
            ,.yzqg_down                 (di_regoin_msg[18][27]    )
            ,.yzqg_out                  (do_regoin_r_msg[18][20]  )
            ,.yzdj_start_z              (do_regoin_r_msg[18][22]  )
            ,.yzdj_start_f              (do_regoin_r_msg[18][23]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1090] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1090] )
            ,.comp_irq                  (rll_comp_irq[1090]  )
        //  components interface
            
            ,.s0_token_if               (roller_s02_token_if[1090])
            ,.s1_token_if               (roller_s00_token_if[1090])
            ,.m1_token_if               (roller_s01_token_if[1091])
        );    
///////////////////////////////////////////////dingwei
////////1038               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1038_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1038           )
                ,.WORK_OUT1_PATH( 14'd1098          )
            )
                roller_1038_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1038] )  
                    ,.dgt_error                 (dgt_error[1038]   )
                    ,.dgt_start                 (dgt_start[1038]   )
		    
                    ,.qdqg_up                   (qdqg_up[1038])
                    ,.qdqg_down                 (qdqg_down[1038])
                    ,.qdqg_out                  (qdqg_out[1038])
                    ,.cdqg_put_out              (cdqg_put_out[1038])
                    ,.cdqg_draw_back            (cdqg_draw_back[1038])
                    ,.cdqg_out                  (cdqg_out[1038])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1038] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1038] )
                    ,.comp_irq                  (rll_comp_irq[1038]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1038])
                    ,.m1_token_if               (roller_s00_token_if[1098])
                );   
 ////////1041               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1041_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1041           )
                ,.WORK_OUT1_PATH( 14'd1097          )
            )
                roller_1041_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1041] )  
                    ,.dgt_error                 (dgt_error[1041]   )
                    ,.dgt_start                 (dgt_start[1041]   )
		    
                    ,.qdqg_up                   (qdqg_up[1041])
                    ,.qdqg_down                 (qdqg_down[1041])
                    ,.qdqg_out                  (qdqg_out[1041])
                    ,.cdqg_put_out              (cdqg_put_out[1041])
                    ,.cdqg_draw_back            (cdqg_draw_back[1041])
                    ,.cdqg_out                  (cdqg_out[1041])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1041] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1041] )
                    ,.comp_irq                  (rll_comp_irq[1041]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1041])
                    ,.m1_token_if               (roller_s00_token_if[1097])
                );                 
  ////////1044               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1044_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1044          )
                ,.WORK_OUT1_PATH( 14'd1096          )
            )
                roller_1044_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1044] )  
                    ,.dgt_error                 (dgt_error[1044]   )
                    ,.dgt_start                 (dgt_start[1044]   )
		    
                    ,.qdqg_up                   (qdqg_up[1044])
                    ,.qdqg_down                 (qdqg_down[1044])
                    ,.qdqg_out                  (qdqg_out[1044])
                    ,.cdqg_put_out              (cdqg_put_out[1044])
                    ,.cdqg_draw_back            (cdqg_draw_back[1044])
                    ,.cdqg_out                  (cdqg_out[1044])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1044] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1044] )
                    ,.comp_irq                  (rll_comp_irq[1044]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1044])
                    ,.m1_token_if               (roller_s00_token_if[1096])
                );                 
   ////////1047               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1047_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1047          )
                ,.WORK_OUT1_PATH( 14'd1095          )
            )
                roller_1047_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1047] )  
                    ,.dgt_error                 (dgt_error[1047]   )
                    ,.dgt_start                 (dgt_start[1047]   )
		    
                    ,.qdqg_up                   (qdqg_up[1047])
                    ,.qdqg_down                 (qdqg_down[1047])
                    ,.qdqg_out                  (qdqg_out[1047])
                    ,.cdqg_put_out              (cdqg_put_out[1047])
                    ,.cdqg_draw_back            (cdqg_draw_back[1047])
                    ,.cdqg_out                  (cdqg_out[1047])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1047] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1047] )
                    ,.comp_irq                  (rll_comp_irq[1047]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1047])
                    ,.m1_token_if               (roller_s00_token_if[1095])
                );                                
    ////////1050               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1050_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1050          )
                ,.WORK_OUT1_PATH( 14'd1094          )
            )
                roller_1050_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1050] )  
                    ,.dgt_error                 (dgt_error[1050]   )
                    ,.dgt_start                 (dgt_start[1050]   )
		    
                    ,.qdqg_up                   (qdqg_up[1050])
                    ,.qdqg_down                 (qdqg_down[1050])
                    ,.qdqg_out                  (qdqg_out[1050])
                    ,.cdqg_put_out              (cdqg_put_out[1050])
                    ,.cdqg_draw_back            (cdqg_draw_back[1050])
                    ,.cdqg_out                  (cdqg_out[1050])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1050] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1050] )
                    ,.comp_irq                  (rll_comp_irq[1050]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1050])
                    ,.m1_token_if               (roller_s00_token_if[1094])
                );  
     ////////1053               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1053_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1053         )
                ,.WORK_OUT1_PATH( 14'd1093          )
            )
                roller_1053_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1053] )  
                    ,.dgt_error                 (dgt_error[1053]   )
                    ,.dgt_start                 (dgt_start[1053]   )
		    
                    ,.qdqg_up                   (qdqg_up[1053])
                    ,.qdqg_down                 (qdqg_down[1053])
                    ,.qdqg_out                  (qdqg_out[1053])
                    ,.cdqg_put_out              (cdqg_put_out[1053])
                    ,.cdqg_draw_back            (cdqg_draw_back[1053])
                    ,.cdqg_out                  (cdqg_out[1053])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1053] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1053] )
                    ,.comp_irq                  (rll_comp_irq[1053]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1053])
                    ,.m1_token_if               (roller_s00_token_if[1093])
                ); 
     ////////1056               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1056_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1056         )
                ,.WORK_OUT1_PATH( 14'd1092          )
            )
                roller_1056_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1056] )  
                    ,.dgt_error                 (dgt_error[1056]   )
                    ,.dgt_start                 (dgt_start[1056]   )
		    
                    ,.qdqg_up                   (qdqg_up[1056])
                    ,.qdqg_down                 (qdqg_down[1056])
                    ,.qdqg_out                  (qdqg_out[1056])
                    ,.cdqg_put_out              (cdqg_put_out[1056])
                    ,.cdqg_draw_back            (cdqg_draw_back[1056])
                    ,.cdqg_out                  (cdqg_out[1056])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1056] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1056] )
                    ,.comp_irq                  (rll_comp_irq[1056]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1056])
                    ,.m1_token_if               (roller_s00_token_if[1092])
                );    
      ////////1059               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1059_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1059         )
                ,.WORK_OUT1_PATH( 14'd1091          )
            )
                roller_1059_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1059] )  
                    ,.dgt_error                 (dgt_error[1059]   )
                    ,.dgt_start                 (dgt_start[1059]   )
		    
                    ,.qdqg_up                   (qdqg_up[1059])
                    ,.qdqg_down                 (qdqg_down[1059])
                    ,.qdqg_out                  (qdqg_out[1059])
                    ,.cdqg_put_out              (cdqg_put_out[1059])
                    ,.cdqg_draw_back            (cdqg_draw_back[1059])
                    ,.cdqg_out                  (cdqg_out[1059])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1059] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1059] )
                    ,.comp_irq                  (rll_comp_irq[1059]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1059])
                    ,.m1_token_if               (roller_s00_token_if[1091])
                );          
  ////////1062    ic----oc            
  rll_manual_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1062_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1062           )
        ,.WORK_OUT1_PATH (14'd1090         )
    )
        roller_1062_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (mat_arrived[1062]    )
            ,.dgt_error                 (dgt_error[1062]   )
            ,.dgt_start                 (dgt_start[1062]  )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1062] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1062] )
            ,.comp_irq                  (rll_comp_irq[1062]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1062])
            ,.m1_token_if               (roller_s00_token_if[1090])
        );
///////////////////////////////////////////////////you
////////1089              
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1089_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1089           )
                ,.WORK_OUT1_PATH( 14'd1098          )
            )
                roller_1089_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1089] )  
                    ,.dgt_error                 (dgt_error[1089]   )
                    ,.dgt_start                 (dgt_start[1089]   )
		    
                    ,.qdqg_up                   (qdqg_up[1089])
                    ,.qdqg_down                 (qdqg_down[1089])
                    ,.qdqg_out                  (qdqg_out[1089])
                    ,.cdqg_put_out              (cdqg_put_out[1089])
                    ,.cdqg_draw_back            (cdqg_draw_back[1089])
                    ,.cdqg_out                  (cdqg_out[1089])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1089] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1089] )
                    ,.comp_irq                  (rll_comp_irq[1089]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1089])
                    ,.m1_token_if               (roller_s02_token_if[1098])
                );   
 ////////1086               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1086_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1086           )
                ,.WORK_OUT1_PATH( 14'd1097          )
            )
                roller_1086_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1086] )
                    ,.dgt_error                 (dgt_error[1086]   )
                    ,.dgt_start                 (dgt_start[1086]   )
		    
                    ,.qdqg_up                   (qdqg_up[1086])
                    ,.qdqg_down                 (qdqg_down[1086])
                    ,.qdqg_out                  (qdqg_out[1086])
                    ,.cdqg_put_out              (cdqg_put_out[1086])
                    ,.cdqg_draw_back            (cdqg_draw_back[1086])
                    ,.cdqg_out                  (cdqg_out[1086])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1086] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1086] )
                    ,.comp_irq                  (rll_comp_irq[1086]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1086])
                    ,.m1_token_if               (roller_s02_token_if[1097])
                );                 
  ////////1083               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1083_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1083          )
                ,.WORK_OUT1_PATH( 14'd1096          )
            )
                roller_1083_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1083] )  
                    ,.dgt_error                 (dgt_error[1083]   )
                    ,.dgt_start                 (dgt_start[1083]   )
		    
                    ,.qdqg_up                   (qdqg_up[1083])
                    ,.qdqg_down                 (qdqg_down[1083])
                    ,.qdqg_out                  (qdqg_out[1083])
                    ,.cdqg_put_out              (cdqg_put_out[1083])
                    ,.cdqg_draw_back            (cdqg_draw_back[1083])
                    ,.cdqg_out                  (cdqg_out[1083])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1083] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1083] )
                    ,.comp_irq                  (rll_comp_irq[1083]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1083])
                    ,.m1_token_if               (roller_s02_token_if[1096])
                );                 
   ////////1080               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1080_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1080          )
                ,.WORK_OUT1_PATH( 14'd1095          )
            )
                roller_1080_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1080] )  
                    ,.dgt_error                 (dgt_error[1080]   )
                    ,.dgt_start                 (dgt_start[1080]   )
		    
                    ,.qdqg_up                   (qdqg_up[1080])
                    ,.qdqg_down                 (qdqg_down[1080])
                    ,.qdqg_out                  (qdqg_out[1080])
                    ,.cdqg_put_out              (cdqg_put_out[1080])
                    ,.cdqg_draw_back            (cdqg_draw_back[1080])
                    ,.cdqg_out                  (cdqg_out[1080])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1080] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1080] )
                    ,.comp_irq                  (rll_comp_irq[1080]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1080])
                    ,.m1_token_if               (roller_s02_token_if[1095])
                );   
   ////////1077               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1077_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1077          )
                ,.WORK_OUT1_PATH( 14'd1094          )
            )
                roller_1077_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1077] )  
                    ,.dgt_error                 (dgt_error[1077]   )
                    ,.dgt_start                 (dgt_start[1077]   )
		    
                    ,.qdqg_up                   (qdqg_up[1077])
                    ,.qdqg_down                 (qdqg_down[1077])
                    ,.qdqg_out                  (qdqg_out[1077])
                    ,.cdqg_put_out              (cdqg_put_out[1077])
                    ,.cdqg_draw_back            (cdqg_draw_back[1077])
                    ,.cdqg_out                  (cdqg_out[1077])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1077] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1077] )
                    ,.comp_irq                  (rll_comp_irq[1077]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1077])
                    ,.m1_token_if               (roller_s02_token_if[1094])
                );    
   ////////1074               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1074_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1074          )
                ,.WORK_OUT1_PATH( 14'd1093          )
            )
                roller_1074_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1074] )  
                    ,.dgt_error                 (dgt_error[1074]   )
                    ,.dgt_start                 (dgt_start[1074]   )
		    
                    ,.qdqg_up                   (qdqg_up[1074])
                    ,.qdqg_down                 (qdqg_down[1074])
                    ,.qdqg_out                  (qdqg_out[1074])
                    ,.cdqg_put_out              (cdqg_put_out[1074])
                    ,.cdqg_draw_back            (cdqg_draw_back[1074])
                    ,.cdqg_out                  (cdqg_out[1074])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1074] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1074] )
                    ,.comp_irq                  (rll_comp_irq[1074]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1074])
                    ,.m1_token_if               (roller_s02_token_if[1093])
                );  
   ////////1071               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1071_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1071          )
                ,.WORK_OUT1_PATH( 14'd1092          )
            )
                roller_1071_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1071] )  
                    ,.dgt_error                 (dgt_error[1071]   )
                    ,.dgt_start                 (dgt_start[1071]   )
		    
                    ,.qdqg_up                   (qdqg_up[1071])
                    ,.qdqg_down                 (qdqg_down[1071])
                    ,.qdqg_out                  (qdqg_out[1071])
                    ,.cdqg_put_out              (cdqg_put_out[1071])
                    ,.cdqg_draw_back            (cdqg_draw_back[1071])
                    ,.cdqg_out                  (cdqg_out[1071])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1071] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1071] )
                    ,.comp_irq                  (rll_comp_irq[1071]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1071])
                    ,.m1_token_if               (roller_s02_token_if[1092])
                );       
  ////////1068               
rll_online_pos_comp_top
            #(
                 .REG_SPACE_BIAS(`ROLLER_1068_REG_BIAS)
                ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
                ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
                ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
                ,.CUR_LOCATION  ( 14'd1068          )
                ,.WORK_OUT1_PATH( 14'd1091          )
            )
                roller_1068_u
                (
                     .clk                       (clk        )
                    ,.reset                     (reset      )

                //  ps interface
                    //reg cfg interface
                    ,.ps_reg_clk                (ps_reg_clk     )
                    ,.ps_reg_reset              (ps_reg_reset   )
                    
                    ,.mat_arrived               (mat_arrived[1068] )  
                    ,.dgt_error                 (dgt_error[1068]   )
                    ,.dgt_start                 (dgt_start[1068]   )
		    
                    ,.qdqg_up                   (qdqg_up[1068])
                    ,.qdqg_down                 (qdqg_down[1068])
                    ,.qdqg_out                  (qdqg_out[1068])
                    ,.cdqg_put_out              (cdqg_put_out[1068])
                    ,.cdqg_draw_back            (cdqg_draw_back[1068])
                    ,.cdqg_out                  (cdqg_out[1068])
    
                    ,.ps_reg_we                 (ps_reg_we     )
                    ,.ps_reg_addr               (ps_reg_addr   )
                    ,.ps_reg_wr_dat             (ps_reg_wr_dat )
                    ,.ps_reg_re                 (ps_reg_re     )
                    ,.ps_reg_rd_addr            (ps_reg_rd_addr)
                    ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1068] )
                    ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1068] )
                    ,.comp_irq                  (rll_comp_irq[1068]    )
                    //  components interface
    
                    ,.s1_token_if               (roller_s01_token_if[1068])
                    ,.m1_token_if               (roller_s02_token_if[1091])
                );   
  ////////1065       ic----oc            
  rll_manual_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_1065_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd1065           )
        ,.WORK_OUT1_PATH (14'd1090         )
    )
        roller_1065_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (mat_arrived[1065]    )
            ,.dgt_error                 (dgt_error[1065]   )
            ,.dgt_start                 (dgt_start[1065]  )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[1065] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[1065] )
            ,.comp_irq                  (rll_comp_irq[1065]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[1065])
            ,.m1_token_if               (roller_s02_token_if[1090])
        ); 
///////////////////////////////////////////////////////////////////////////////////////pingbi

//////////////////////////////////////////
///////*****wf******////////
//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2012       
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2012_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2012           )
        ,.WORK_OUT0_PATH (14'd2013          )
        ,.WORK_OUT1_PATH (14'd2015         )
    )
        roller_2012_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][32]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[3][0]    )
            ,.dgt_start                 (do_regoin_r_msg[3][0]  )
            ,.yzqg_up                   (di_regoin_msg[3][16]    )
            ,.yzqg_down                 (di_regoin_msg[3][17]    )
            ,.yzqg_out                  (do_regoin_r_msg[3][16]  )
            ,.yzdj_start_z              (do_regoin_r_msg[3][24]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2012])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2012] )
            ,.comp_irq                  (rll_comp_irq[2012]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2012])
            ,.m1_token_if               (roller_s01_token_if[2015])
            ,.m0_token_if               (roller_s01_token_if[2013])
        );  
///////2015   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2015_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2015          )
        ,.WORK_OUT1_PATH (14'd2016          )
    )
        roller_2015_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][35]   )
            ,.dgt_error                 (di_regoin_msg[3][3]    )
            ,.dgt_start                 (do_regoin_r_msg[3][3]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2015] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2015] )
            ,.comp_irq                  (rll_comp_irq[2015]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2015])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2016])
        );
//////2016   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2016_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )       
        ,.CUR_LOCATION  (14'd2016          )
        ,.WORK_OUT1_PATH (14'd2017          )
    )
        roller_2016_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][36]   )
            ,.dgt_error                 (di_regoin_msg[3][4]    )
            ,.dgt_start                 (do_regoin_r_msg[3][4]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2016] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2016] )
            ,.comp_irq                  (rll_comp_irq[2016]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2016])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2017])
        );
 ////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2017       
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2017_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2017           )
        ,.WORK_OUT0_PATH (14'd2018          )
        ,.WORK_OUT1_PATH (14'd2020         )
    )
        roller_2017_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][37]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[3][5]    )
            ,.dgt_start                 (do_regoin_r_msg[3][5]  )
            ,.yzqg_up                   (di_regoin_msg[3][20]    )
            ,.yzqg_down                 (di_regoin_msg[3][21]    )
            ,.yzqg_out                  (do_regoin_r_msg[3][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[3][25]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2017])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2017] )
            ,.comp_irq                  (rll_comp_irq[2017]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2017])
            ,.m1_token_if               (roller_s01_token_if[2020])
            ,.m0_token_if               (roller_s01_token_if[2018])
        );  
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2020       
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2020_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )

        ,.CUR_LOCATION  (14'd2020           )
        ,.WORK_OUT0_PATH (14'd2021          )
        ,.WORK_OUT1_PATH (14'd2023         )
    )
        roller_2020_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][32]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[4][0]    )
            ,.dgt_start                 (do_regoin_r_msg[4][0]  )

            ,.yzqg_up                   (di_regoin_msg[4][16]    )
            ,.yzqg_down                 (di_regoin_msg[4][17]    )
            ,.yzqg_out                  (do_regoin_r_msg[4][16]  )
            ,.yzdj_start_z              (do_regoin_r_msg[4][24]  )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2020])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2020] )
            ,.comp_irq                  (rll_comp_irq[2020]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2020])
            ,.m1_token_if               (roller_s01_token_if[2023])
            ,.m0_token_if               (roller_s01_token_if[2021])
        ); 
///////////////////////////////////////////////////////////////////////1jin1chu
////////2023   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2023_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2023          )
        ,.WORK_OUT1_PATH (14'd2024          )
    )
        roller_2023_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][35]   )
            ,.dgt_error                 (di_regoin_msg[4][3]    )
            ,.dgt_start                 (do_regoin_r_msg[4][3]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2023] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2023] )
            ,.comp_irq                  (rll_comp_irq[2023]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2023])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2024])
        );
    
/////////////////////////////////////////////////////////////////////1jin1chu
//////2024   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2024_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2024          )
        ,.WORK_OUT1_PATH (14'd2025          )
    )
        roller_2024_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][36]   )
            ,.dgt_error                 (di_regoin_msg[4][4]    )
            ,.dgt_start                 (do_regoin_r_msg[4][4]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2024] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2024] )
            ,.comp_irq                  (rll_comp_irq[2024]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2024])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2025])
        );
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2025      
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2025_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2025           )
        ,.WORK_OUT0_PATH (14'd2026          )
        ,.WORK_OUT1_PATH (14'd2028         )
    )
        roller_2025_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][37]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[4][5]    )
            ,.dgt_start                 (do_regoin_r_msg[4][5]  )
            ,.yzqg_up                   (di_regoin_msg[4][20]    )
            ,.yzqg_down                 (di_regoin_msg[4][21]    )
            ,.yzqg_out                  (do_regoin_r_msg[4][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[4][25]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2025])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2025] )
            ,.comp_irq                  (rll_comp_irq[2025]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2025])
            ,.m1_token_if               (roller_s01_token_if[2028])
            ,.m0_token_if               (roller_s01_token_if[2026])
        ); 
////////////////////////////////////////////////////////////////////////////////1jin2chu 
///////2028      
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2028_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2028           )
        ,.WORK_OUT0_PATH (14'd2029          )
        ,.WORK_OUT1_PATH (14'd2031         )
    )
        roller_2028_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][32]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[5][0]    )
            ,.dgt_start                 (do_regoin_r_msg[5][0]  )
            ,.yzqg_up                   (di_regoin_msg[5][16]    )
            ,.yzqg_down                 (di_regoin_msg[5][17]    )
            ,.yzqg_out                  (do_regoin_r_msg[5][16]  )
            ,.yzdj_start_z              (do_regoin_r_msg[5][24]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2028])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2028] )
            ,.comp_irq                  (rll_comp_irq[2028]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2028])
            ,.m1_token_if               (roller_s01_token_if[2031])
            ,.m0_token_if               (roller_s01_token_if[2029])
        ); 
///////////////////////////////////////////////////////////////////////1jin1chu
////////2031   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2031_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2031          )
        ,.WORK_OUT1_PATH (14'd2032          )
    )
        roller_2031_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][35]   )
            ,.dgt_error                 (di_regoin_msg[5][3]    )
            ,.dgt_start                 (do_regoin_r_msg[5][3]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2031] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2031] )
            ,.comp_irq                  (rll_comp_irq[2031]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2031])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2032])
        );
///////////////////////////////////////////////////////////////////////1jin1chu
////////2032  
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2032_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2032          )
        ,.WORK_OUT1_PATH (14'd2033          )
    )
        roller_2032_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][36]   )
            ,.dgt_error                 (di_regoin_msg[5][4]    )
            ,.dgt_start                 (do_regoin_r_msg[5][4]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2032] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2032] )
            ,.comp_irq                  (rll_comp_irq[2032]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2032])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2033])
        );
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2033      
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2033_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2033           )
        ,.WORK_OUT0_PATH (14'd2034          )
        ,.WORK_OUT1_PATH (14'd2036         )
    )
        roller_2033_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][37]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[5][5]    )
            ,.dgt_start                 (do_regoin_r_msg[5][5]  )
            ,.yzqg_up                   (di_regoin_msg[5][20]    )
            ,.yzqg_down                 (di_regoin_msg[5][21]    )
            ,.yzqg_out                  (do_regoin_r_msg[5][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[5][25]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2033])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2033] )
            ,.comp_irq                  (rll_comp_irq[2033]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2033])
            ,.m1_token_if               (roller_s01_token_if[2036])
            ,.m0_token_if               (roller_s01_token_if[2034])
        );  
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2036     
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2036_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2036           )
        ,.WORK_OUT0_PATH (14'd2037          )
        ,.WORK_OUT1_PATH (14'd2039         )
    )
        roller_2036_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][32]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[6][0]    )
            ,.dgt_start                 (do_regoin_r_msg[6][0]  )
            ,.yzqg_up                   (di_regoin_msg[6][16]    )
            ,.yzqg_down                 (di_regoin_msg[6][17]    )
            ,.yzqg_out                  (do_regoin_r_msg[6][16]  )
            ,.yzdj_start_z              (do_regoin_r_msg[6][24]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2036])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2036] )
            ,.comp_irq                  (rll_comp_irq[2036]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2036])
            ,.m1_token_if               (roller_s01_token_if[2039])
            ,.m0_token_if               (roller_s01_token_if[2037])
        ); 
///////////////////////////////////////////////////////////////////////1jin1chu
////////2039   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2039_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2039          )
        ,.WORK_OUT1_PATH (14'd2040          )
    )
        roller_2039_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][35]   )
            ,.dgt_error                 (di_regoin_msg[6][3]    )
            ,.dgt_start                 (do_regoin_r_msg[6][3]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2039] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2039] )
            ,.comp_irq                  (rll_comp_irq[2039]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2039])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2040])
        );
///////////////////////////////////////////////////////////////////////1jin1chu
////////2040  
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2040_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2040          )
        ,.WORK_OUT1_PATH (14'd2041         )
    )
        roller_2040_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][36]   )
            ,.dgt_error                 (di_regoin_msg[6][4]    )
            ,.dgt_start                 (do_regoin_r_msg[6][4]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2040] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2040] )
            ,.comp_irq                  (rll_comp_irq[2040]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2040])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2041])
        );
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2041      
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2041_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2041           )
        ,.WORK_OUT0_PATH (14'd2042          )
        ,.WORK_OUT1_PATH (14'd2044         )
    )
        roller_2041_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][37]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[6][5]    )
            ,.dgt_start                 (do_regoin_r_msg[6][5]  )
            ,.yzqg_up                   (di_regoin_msg[6][20]    )
            ,.yzqg_down                 (di_regoin_msg[6][21]    )
            ,.yzqg_out                  (do_regoin_r_msg[6][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[6][25]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2041])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2041] )
            ,.comp_irq                  (rll_comp_irq[2041]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2041])
            ,.m1_token_if               (roller_s01_token_if[2044])
            ,.m0_token_if               (roller_s01_token_if[2042])
        );
//////////////////////////////////////////////////////////////yizai   1jin1cju
////////2044   
      rll_transf_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2044_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
       
        ,.CUR_LOCATION  (14'd2044           )
        ,.WORK_OUT1_PATH (14'd2045          )
    )
        roller_2044_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][32]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[7][0]    )
            ,.dgt_start                 (do_regoin_r_msg[7][0]  )
            ,.yzqg_up                   (di_regoin_msg[7][16]    )
            ,.yzqg_down                 (di_regoin_msg[7][17]    )
            ,.yzqg_out                  (do_regoin_r_msg[7][16]  )
            ,.yzdj_start_z              (do_regoin_r_msg[7][24]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2044] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2044] )
            ,.comp_irq                  (rll_comp_irq[2044]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2044])
            ,.m1_token_if               (roller_s01_token_if[2045])
        );
///////////////////////////////////////////////////////////////////////1jin1chu
////////2045   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2045_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2045          )
        ,.WORK_OUT1_PATH (14'd2046          )
    )
        roller_2045_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][33]   )
            ,.dgt_error                 (di_regoin_msg[7][1]    )
            ,.dgt_start                 (do_regoin_r_msg[7][1]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2045] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2045] )
            ,.comp_irq                  (rll_comp_irq[2045]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2045])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2046])
        );
///////////////////////////////////////////////////////////////////////1jin1chu
////////2046   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2046_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2046          )
        ,.WORK_OUT1_PATH (14'd2047          )
    )
        roller_2046_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][34]   )
            ,.dgt_error                 (di_regoin_msg[7][2]    )
            ,.dgt_start                 (do_regoin_r_msg[7][2]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2046] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2046] )
            ,.comp_irq                  (rll_comp_irq[2046]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2046])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2047])
        );
//////////////////////////////////////////////////////////////gunttongyizai   1jin1cju
////////2047   
 roller_midpoint_ic_or
    #(
         .REG_SPACE_BIAS(`ROLLER_2047_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2047          )
        ,.WORK_OUT1_PATH (14'd2048          )
    )
        roller_2047_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            ,.mat_arrived               (di_regoin_msg[7][35]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[7][3]    )
            ,.dgt_start                 (do_regoin_r_msg[7][3]  )
            ,.yzqg_up                   (di_regoin_msg[7][18]    )
            ,.yzqg_down                 (di_regoin_msg[7][19]    )
            ,.yzqg_out                  (do_regoin_r_msg[7][17]  )
            ,.yzdj_start_z              (do_regoin_r_msg[7][25]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2047] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2047] )
            ,.comp_irq                  (rll_comp_irq[2047]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2047])
            ,.m1_token_if               (roller_s01_token_if[2048])
        );
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2048    
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2048_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2048           )
        ,.WORK_OUT0_PATH (14'd2049          )
        ,.WORK_OUT1_PATH (14'd2051         )
    )
        roller_2048_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][36]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[7][4]    )
            ,.dgt_start                 (do_regoin_r_msg[7][4]  )
            ,.yzqg_up                   (di_regoin_msg[7][20]    )
            ,.yzqg_down                 (di_regoin_msg[7][21]    )
            ,.yzqg_out                  (do_regoin_r_msg[7][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[7][26]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2048])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2048] )
            ,.comp_irq                  (rll_comp_irq[2048]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2048])
            ,.m1_token_if               (roller_s01_token_if[2051])
            ,.m0_token_if               (roller_s01_token_if[2049])
        );  
///////////////////////////////////////////////////////////////////////1jin1chu
////////2051   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2051_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2051          )
        ,.WORK_OUT1_PATH (14'd2052          )
    )
        roller_2051_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][39]   )
            ,.dgt_error                 (di_regoin_msg[7][7]    )
            ,.dgt_start                 (do_regoin_r_msg[7][7]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2051] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2051] )
            ,.comp_irq                  (rll_comp_irq[2051]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2051])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2052])
        );
///////////////////////////////////////////////////////////////////////1jin1chu
////////2052   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2052_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2052          )
        ,.WORK_OUT1_PATH (14'd2053          )
    )
        roller_2052_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][35]   )
            ,.dgt_error                 (di_regoin_msg[8][0]    )
            ,.dgt_start                 (do_regoin_r_msg[8][0]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2052] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2052] )
            ,.comp_irq                  (rll_comp_irq[2052]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2052])  ////wf
             ,.m1_token_if                 (roller_s01_token_if[2053])
        );
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2053    
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2053_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2053           )
        ,.WORK_OUT0_PATH (14'd2054          )
        ,.WORK_OUT1_PATH (14'd2056         )
    )
        roller_2053_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][36]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[8][1]    )
            ,.dgt_start                 (do_regoin_r_msg[8][1]  )
            ,.yzqg_up                   (di_regoin_msg[8][17]    )
            ,.yzqg_down                 (di_regoin_msg[8][18]    )
            ,.yzqg_out                  (do_regoin_r_msg[8][18]  )
            ,.yzdj_start_z              (do_regoin_r_msg[8][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2053])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2053] )
            ,.comp_irq                  (rll_comp_irq[2053]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2053])
            ,.m1_token_if               (roller_s01_token_if[2056])
            ,.m0_token_if               (roller_s01_token_if[2054])
        ); 
////////////////////////////////////////////////////////////////////////////////1jin2chu 
 ///////2056    
rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2056_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2056           )
        ,.WORK_OUT0_PATH (14'd2057          )
        ,.WORK_OUT1_PATH (14'd2059         )
    )
        roller_2056_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][39]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[8][4]    )
            ,.dgt_start                 (do_regoin_r_msg[8][4]  )
            ,.yzqg_up                   (di_regoin_msg[8][21]    )
            ,.yzqg_down                 (di_regoin_msg[8][22]    )
            ,.yzqg_out                  (do_regoin_r_msg[8][20]  )
            ,.yzdj_start_z              (do_regoin_r_msg[8][29]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2056])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2056] )
            ,.comp_irq                  (rll_comp_irq[2056]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2056])
            ,.m1_token_if               (roller_s01_token_if[2059])
            ,.m0_token_if               (roller_s01_token_if[2057])
        ); 
///////////////////////////////////////////////////////////////////////1jin1chu
/////2013  
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2013_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2013           )
        ,.WORK_OUT1_PATH (14'd2014          )
    )
        roller_2013_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[3][33]   )
            ,.dgt_error                 (di_regoin_msg[3][1]    )
            ,.dgt_start                 (do_regoin_r_msg[3][1]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2013] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2013] )
            ,.comp_irq                  (rll_comp_irq[2013]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2013])
            ,.m1_token_if               (roller_s01_token_if[2014])
        );
///2014        
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2014_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2014           )
        ,.WORK_OUT1_PATH (14'd2014          )
    )
        roller_2014_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[3][34]   )
            ,.dgt_error                 (di_regoin_msg[3][2]    )
            ,.dgt_start                 (do_regoin_r_msg[3][2]  )
            ,.yzqg_up                   (di_regoin_msg[3][18]   )
            ,.yzqg_down                 (di_regoin_msg[3][19]   )
            ,.yzqg_out                  (do_regoin_r_msg[3][17] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2014] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2014] )
            ,.comp_irq                  (rll_comp_irq[2014]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2014])
        );
 /////2018 
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2018_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2018           )
        ,.WORK_OUT1_PATH (14'd2019          )
    )
        roller_2018_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[3][38]   )
            ,.dgt_error                 (di_regoin_msg[3][6]    )
            ,.dgt_start                 (do_regoin_r_msg[3][6]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2018] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2018] )
            ,.comp_irq                  (rll_comp_irq[2018]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2018])
            ,.m1_token_if               (roller_s01_token_if[2019])
        );
///2019      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2019_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2019           )
        ,.WORK_OUT1_PATH (14'd2019          )
    )
        roller_2019_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[3][39]   )
            ,.dgt_error                 (di_regoin_msg[3][7]    )
            ,.dgt_start                 (do_regoin_r_msg[3][7]  )
            ,.yzqg_up                   (di_regoin_msg[3][22]   )
            ,.yzqg_down                 (di_regoin_msg[3][23]   )
            ,.yzqg_out                  (do_regoin_r_msg[3][19] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2019] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2019] )
            ,.comp_irq                  (rll_comp_irq[2019]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2019])
        );
 /////2021
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2021_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2021           )
        ,.WORK_OUT1_PATH (14'd2022          )
    )
        roller_2021_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[4][33]   )
            ,.dgt_error                 (di_regoin_msg[4][1]    )
            ,.dgt_start                 (do_regoin_r_msg[4][1]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2021] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2021] )
            ,.comp_irq                  (rll_comp_irq[2021]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2021])
            ,.m1_token_if               (roller_s01_token_if[2022])
        );
///2022      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2022_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2022           )
        ,.WORK_OUT1_PATH (14'd2022          )
    )
        roller_2022_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[4][34]   )
            ,.dgt_error                 (di_regoin_msg[4][2]    )
            ,.dgt_start                 (do_regoin_r_msg[4][2]  )
            ,.yzqg_up                   (di_regoin_msg[4][18]   )
            ,.yzqg_down                 (di_regoin_msg[4][19]   )
            ,.yzqg_out                  (do_regoin_r_msg[4][17] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2022] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2022] )
            ,.comp_irq                  (rll_comp_irq[2022]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2022])
        );        
  /////2026
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2026_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2026           )
        ,.WORK_OUT1_PATH (14'd2027          )
    )
        roller_2026_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[4][38]   )
            ,.dgt_error                 (di_regoin_msg[4][6]    )
            ,.dgt_start                 (do_regoin_r_msg[4][6]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2026] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2026] )
            ,.comp_irq                  (rll_comp_irq[2026]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2026])
            ,.m1_token_if               (roller_s01_token_if[2027])
        );
///2027      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2027_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2027           )
        ,.WORK_OUT1_PATH (14'd2027          )
    )
        roller_2027_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[4][39]   )
            ,.dgt_error                 (di_regoin_msg[4][7]    )
            ,.dgt_start                 (do_regoin_r_msg[4][7]  )
            ,.yzqg_up                   (di_regoin_msg[4][22]   )
            ,.yzqg_down                 (di_regoin_msg[4][23]   )
            ,.yzqg_out                  (do_regoin_r_msg[4][19] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2027] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2027] )
            ,.comp_irq                  (rll_comp_irq[2027]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2027])
        );         
  /////2029
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2029_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2029           )
        ,.WORK_OUT1_PATH (14'd2030          )
    )
        roller_2029_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[5][33]   )
            ,.dgt_error                 (di_regoin_msg[5][1]    )
            ,.dgt_start                 (do_regoin_r_msg[5][1]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2029] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2029] )
            ,.comp_irq                  (rll_comp_irq[2029]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2029])
            ,.m1_token_if               (roller_s01_token_if[2030])
        );
///2030      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2030_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2030           )
        ,.WORK_OUT1_PATH (14'd2030          )
    )
        roller_2030_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[5][34]   )
            ,.dgt_error                 (di_regoin_msg[5][2]    )
            ,.dgt_start                 (do_regoin_r_msg[5][2]  )
            ,.yzqg_up                   (di_regoin_msg[5][18]   )
            ,.yzqg_down                 (di_regoin_msg[5][19]   )
            ,.yzqg_out                  (do_regoin_r_msg[5][17] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2030] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2030] )
            ,.comp_irq                  (rll_comp_irq[2030]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2030])
        );   
  /////2034
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2034_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2034           )
        ,.WORK_OUT1_PATH (14'd2035          )
    )
        roller_2034_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[5][38]   )
            ,.dgt_error                 (di_regoin_msg[5][6]    )
            ,.dgt_start                 (do_regoin_r_msg[5][6]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2034] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2034] )
            ,.comp_irq                  (rll_comp_irq[2034]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2034])
            ,.m1_token_if               (roller_s01_token_if[2035])
        );
///2035      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2035_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2035           )
        ,.WORK_OUT1_PATH (14'd2035          )
    )
        roller_2035_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[5][39]   )
            ,.dgt_error                 (di_regoin_msg[5][7]    )
            ,.dgt_start                 (do_regoin_r_msg[5][7]  )
            ,.yzqg_up                   (di_regoin_msg[5][22]   )
            ,.yzqg_down                 (di_regoin_msg[5][23]   )
            ,.yzqg_out                  (do_regoin_r_msg[5][19] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2035] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2035] )
            ,.comp_irq                  (rll_comp_irq[2035]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2035])
        );    
 /////2037
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2037_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2037           )
        ,.WORK_OUT1_PATH (14'd2038          )
    )
        roller_2037_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[6][33]   )
            ,.dgt_error                 (di_regoin_msg[6][1]    )
            ,.dgt_start                 (do_regoin_r_msg[6][1]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2037] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2037] )
            ,.comp_irq                  (rll_comp_irq[2037]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2037])
            ,.m1_token_if               (roller_s01_token_if[2038])
        );
///2038      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2038_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2038           )
        ,.WORK_OUT1_PATH (14'd2038          )
    )
        roller_2038_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[6][34]   )
            ,.dgt_error                 (di_regoin_msg[6][2]    )
            ,.dgt_start                 (do_regoin_r_msg[6][2]  )
            ,.yzqg_up                   (di_regoin_msg[6][18]   )
            ,.yzqg_down                 (di_regoin_msg[6][19]   )
            ,.yzqg_out                  (do_regoin_r_msg[6][17] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2038] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2038] )
            ,.comp_irq                  (rll_comp_irq[2038]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2038])
        );  
  /////2042
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2042_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2042           )
        ,.WORK_OUT1_PATH (14'd2043          )
    )
        roller_2042_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[6][38]   )
            ,.dgt_error                 (di_regoin_msg[6][6]    )
            ,.dgt_start                 (do_regoin_r_msg[6][6]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2042] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2042] )
            ,.comp_irq                  (rll_comp_irq[2042]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2042])
            ,.m1_token_if               (roller_s01_token_if[2043])
        );
///2043      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2043_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
       
        ,.CUR_LOCATION  (14'd2043           )
        ,.WORK_OUT1_PATH (14'd2043          )
    )
        roller_2043_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[6][39]   )
            ,.dgt_error                 (di_regoin_msg[6][7]    )
            ,.dgt_start                 (do_regoin_r_msg[6][7]  )
            ,.yzqg_up                   (di_regoin_msg[6][22]   )
            ,.yzqg_down                 (di_regoin_msg[6][23]   )
            ,.yzqg_out                  (do_regoin_r_msg[6][19] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2043] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2043] )
            ,.comp_irq                  (rll_comp_irq[2043]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2043])
        ); 
  /////2049
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2049_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2049           )
        ,.WORK_OUT1_PATH (14'd2050          )
    )
        roller_2049_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[7][37]   )
            ,.dgt_error                 (di_regoin_msg[7][5]    )
            ,.dgt_start                 (do_regoin_r_msg[7][5]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2049] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2049] )
            ,.comp_irq                  (rll_comp_irq[2049]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2049])
            ,.m1_token_if               (roller_s01_token_if[2050])
        );
///2050      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2050_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2050           )
        ,.WORK_OUT1_PATH (14'd2050          )
    )
        roller_2050_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[7][38]   )
            ,.dgt_error                 (di_regoin_msg[7][6]    )
            ,.dgt_start                 (do_regoin_r_msg[7][6]  )
            ,.yzqg_up                   (di_regoin_msg[7][22]   )
            ,.yzqg_down                 (di_regoin_msg[7][23]   )
            ,.yzqg_out                  (do_regoin_r_msg[7][19] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2050] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2050] )
            ,.comp_irq                  (rll_comp_irq[2050]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2050])
        );         
  /////2054
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2054_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2054           )
        ,.WORK_OUT1_PATH (14'd2055          )
    )
        roller_2054_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][37]   )
            ,.dgt_error                 (di_regoin_msg[8][2]    )
            ,.dgt_start                 (do_regoin_r_msg[8][2]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2054] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2054] )
            ,.comp_irq                  (rll_comp_irq[2054]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2054])
            ,.m1_token_if               (roller_s01_token_if[2055])
        );
///2055      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2055_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2055           )
        ,.WORK_OUT1_PATH (14'd2055          )
    )
        roller_2055_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][38]   )
            ,.dgt_error                 (di_regoin_msg[8][3]    )
            ,.dgt_start                 (do_regoin_r_msg[8][3]  )
            ,.yzqg_up                   (di_regoin_msg[8][19]   )
            ,.yzqg_down                 (di_regoin_msg[8][20]   )
            ,.yzqg_out                  (do_regoin_r_msg[8][19] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2055] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2055] )
            ,.comp_irq                  (rll_comp_irq[2055]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2055])
        );  
 /////2057
  rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2057_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2057           )
        ,.WORK_OUT1_PATH (14'd2058          )
    )
        roller_2057_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][40]   )
            ,.dgt_error                 (di_regoin_msg[8][5]    )
            ,.dgt_start                 (do_regoin_r_msg[8][5]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2057] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2057] )
            ,.comp_irq                  (rll_comp_irq[2057]   )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2057])
            ,.m1_token_if               (roller_s01_token_if[2058])
        );
///2058      
    roller_endpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2058_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2058           )
        ,.WORK_OUT1_PATH (14'd2058          )
    )
        roller_2058_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][41]   )
            ,.dgt_error                 (di_regoin_msg[8][6]    )
            ,.dgt_start                 (do_regoin_r_msg[8][6]  )
            ,.yzqg_up                   (di_regoin_msg[8][23]   )
            ,.yzqg_down                 (di_regoin_msg[8][24]   )
            ,.yzqg_out                  (do_regoin_r_msg[8][21] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2058] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2058] )
            ,.comp_irq                  (rll_comp_irq[2058]    )
        //  components interface
        
            ,.s1_token_if               (roller_s01_token_if[2058])
        );                 
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2061      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2061_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2061           )
        ,.WORK_OUT1_PATH (14'd2064          )
    )
        roller_2061_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][44]   )
            ,.dgt_error                 (di_regoin_msg[8][9]    )
            ,.dgt_start                 (do_regoin_r_msg[8][10]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2061] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2061] )
            ,.comp_irq                  (rll_comp_irq[2061]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2061])
             ,.m1_token_if                 (roller_s01_token_if[2064])
        );

////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2064  
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2064_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2064           )
        ,.WORK_OUT1_PATH (14'd2067          )
    )
        roller_2064_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[8][47]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[8][12]    )
            ,.dgt_start                 (do_regoin_r_msg[8][13]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[8][29]    )
            ,.yzqg_down                 (di_regoin_msg[8][30]    )
            ,.yzqg_out                  (do_regoin_r_msg[8][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[8][30]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2064] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2064] )
            ,.comp_irq                  (rll_comp_irq[2064]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2064])
            ,.s1_token_if               (roller_s01_token_if[2064])
            ,.m1_token_if               (roller_s01_token_if[2067])
        );    
 
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2067  
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2067_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2067           )
        ,.WORK_OUT1_PATH (14'd2068          )
    )
        roller_2067_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[8][50]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[8][15]    )
            ,.dgt_start                 (do_regoin_r_msg[8][16]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[8][33]    )
            ,.yzqg_down                 (di_regoin_msg[8][34]    )
            ,.yzqg_out                  (do_regoin_r_msg[8][25]  )
            ,.yzdj_start_z              (do_regoin_r_msg[8][31]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2067] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2067] )
            ,.comp_irq                  (rll_comp_irq[2067]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2067])
            ,.s1_token_if               (roller_s01_token_if[2067])
            ,.m1_token_if               (roller_s01_token_if[2068])
        );    
  
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2068      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2068_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2068           )
        ,.WORK_OUT1_PATH (14'd2069          )
    )
        roller_2068_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][51]   )
            ,.dgt_error                 (di_regoin_msg[8][16]    )
            ,.dgt_start                 (do_regoin_r_msg[8][17]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2068] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2068] )
            ,.comp_irq                  (rll_comp_irq[2068]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2068])
             ,.m1_token_if                 (roller_s01_token_if[2069])
        ); 
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2069      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2069_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2069           )
        ,.WORK_OUT1_PATH (14'd2072          )
    )
        roller_2069_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][40]   )
            ,.dgt_error                 (di_regoin_msg[7][8]    )
            ,.dgt_start                 (do_regoin_r_msg[7][8]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2069] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2069] )
            ,.comp_irq                  (rll_comp_irq[2069]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2069])
             ,.m1_token_if                 (roller_s01_token_if[2072])
        );
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2072  
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2072_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2072           )
        ,.WORK_OUT1_PATH (14'd2073          )
    )
        roller_2072_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[7][43]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[7][11]    )
            ,.dgt_start                 (do_regoin_r_msg[7][11]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[7][26]    )
            ,.yzqg_down                 (di_regoin_msg[7][27]    )
            ,.yzqg_out                  (do_regoin_r_msg[7][21]  )
            ,.yzdj_start_z              (do_regoin_r_msg[7][27]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2072] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2072] )
            ,.comp_irq                  (rll_comp_irq[2072]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2072])
            ,.s1_token_if               (roller_s01_token_if[2072])
            ,.m1_token_if               (roller_s01_token_if[2073])
        );    
//////////////////////////////////////////////////////////////yizai _guntong  1jin1cju
////////2073   
  rll_transf_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2073_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2073           )
        ,.WORK_OUT1_PATH (14'd2074          )
    )
        roller_2073_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][44]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[7][12]    )
            ,.dgt_start                 (do_regoin_r_msg[7][12]  )
            ,.yzqg_up                   (di_regoin_msg[7][28]    )
            ,.yzqg_down                 (di_regoin_msg[7][29]    )
            ,.yzqg_out                  (do_regoin_r_msg[7][22]  )
            ,.yzdj_start_z              (do_regoin_r_msg[7][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2073] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2073] )
            ,.comp_irq                  (rll_comp_irq[2073]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2073])
            ,.m1_token_if               (roller_s01_token_if[2074])
        ); 
 /////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2074      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2074_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2074           )
        ,.WORK_OUT1_PATH (14'd2075          )
    )
        roller_2074_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][45]   )
            ,.dgt_error                 (di_regoin_msg[7][13]    )
            ,.dgt_start                 (do_regoin_r_msg[7][13]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2074] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2074] )
            ,.comp_irq                  (rll_comp_irq[2074]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2074])
             ,.m1_token_if                 (roller_s01_token_if[2075])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2075      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2075_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2075           )
        ,.WORK_OUT1_PATH (14'd2076          )
    )
        roller_2075_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][46]   )
            ,.dgt_error                 (di_regoin_msg[7][14]    )
            ,.dgt_start                 (do_regoin_r_msg[7][14]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2075] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2075] )
            ,.comp_irq                  (rll_comp_irq[2075]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2075])
             ,.m1_token_if                 (roller_s01_token_if[2076])
        );
//////////////////////////////////////////////////////////////guntong_yizai   1jin1cju
////////2076  
      roller_midpoint_ic_or
    #(
         .REG_SPACE_BIAS(`ROLLER_2076_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2076          )
        ,.WORK_OUT1_PATH (14'd2079          )
    )
        roller_2076_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            ,.mat_arrived               (di_regoin_msg[7][47]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[7][15]    )
            ,.dgt_start                 (do_regoin_r_msg[7][15]  )
            ,.yzqg_up                   (di_regoin_msg[7][30]    )
            ,.yzqg_down                 (di_regoin_msg[7][31]    )
            ,.yzqg_out                  (do_regoin_r_msg[7][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[7][29]  )
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2076] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2076] )
            ,.comp_irq                  (rll_comp_irq[2076]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2076])
            ,.m1_token_if               (roller_s01_token_if[2079])
        ); 
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2079  
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2079_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2079           )
        ,.WORK_OUT1_PATH (14'd2080          )
    )
        roller_2079_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[6][42]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[6][10]    )
            ,.dgt_start                 (do_regoin_r_msg[6][10]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[6][26]    )
            ,.yzqg_down                 (di_regoin_msg[6][27]    )
            ,.yzqg_out                  (do_regoin_r_msg[6][21]  )
            ,.yzdj_start_z              (do_regoin_r_msg[6][26]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2079] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2079] )
            ,.comp_irq                  (rll_comp_irq[2079]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2079])
            ,.s1_token_if               (roller_s01_token_if[2079])
            ,.m1_token_if               (roller_s01_token_if[2080])
        );     
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2080      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2080_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2080           )
        ,.WORK_OUT1_PATH (14'd2081          )
    )
        roller_2080_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][43]   )
            ,.dgt_error                 (di_regoin_msg[6][11]    )
            ,.dgt_start                 (do_regoin_r_msg[6][11]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2080] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2080] )
            ,.comp_irq                  (rll_comp_irq[2080]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2080])
             ,.m1_token_if                 (roller_s01_token_if[2081])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2081      
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2081_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2081           )
        ,.WORK_OUT1_PATH (14'd2084          )
    )
        roller_2081_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][44]   )
            ,.dgt_error                 (di_regoin_msg[6][12]    )
            ,.dgt_start                 (do_regoin_r_msg[6][12]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2081] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2081] )
            ,.comp_irq                  (rll_comp_irq[2081]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2081])
             ,.m1_token_if                 (roller_s01_token_if[2084])
        );
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2084 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2084_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2084           )
        ,.WORK_OUT1_PATH (14'd2087         )
    )
        roller_2084_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[6][47]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[6][15]    )
            ,.dgt_start                 (do_regoin_r_msg[6][15]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[6][30]    )
            ,.yzqg_down                 (di_regoin_msg[6][31]    )
            ,.yzqg_out                  (do_regoin_r_msg[6][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[6][27]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2084] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2084] )
            ,.comp_irq                  (rll_comp_irq[2084]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2084])
            ,.s1_token_if               (roller_s01_token_if[2084])
            ,.m1_token_if               (roller_s01_token_if[2087])
        );    
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2087 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2087_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2087           )
        ,.WORK_OUT1_PATH (14'd2088         )
    )
        roller_2087_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[5][42]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[5][10]    )
            ,.dgt_start                 (do_regoin_r_msg[5][10]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[5][26]    )
            ,.yzqg_down                 (di_regoin_msg[5][27]    )
            ,.yzqg_out                  (do_regoin_r_msg[5][21]  )
            ,.yzdj_start_z              (do_regoin_r_msg[5][26]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2087] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2087] )
            ,.comp_irq                  (rll_comp_irq[2087]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2087])
            ,.s1_token_if               (roller_s01_token_if[2087])
            ,.m1_token_if               (roller_s01_token_if[2088])
        );     
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2088     
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2088_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2088           )
        ,.WORK_OUT1_PATH (14'd2089          )
    )
        roller_2088_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][43]   )
            ,.dgt_error                 (di_regoin_msg[5][11]    )
            ,.dgt_start                 (do_regoin_r_msg[5][11]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2088] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2088] )
            ,.comp_irq                  (rll_comp_irq[2088]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2088])
             ,.m1_token_if                 (roller_s01_token_if[2089])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2089     
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2089_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2089           )
        ,.WORK_OUT1_PATH (14'd2092          )
    )
        roller_2089_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][44]   )
            ,.dgt_error                 (di_regoin_msg[5][12]    )
            ,.dgt_start                 (do_regoin_r_msg[5][12]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2089] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2089] )
            ,.comp_irq                  (rll_comp_irq[2089]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2089])
             ,.m1_token_if                 (roller_s01_token_if[2092])
        );
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2092 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2092_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2092           )
        ,.WORK_OUT1_PATH (14'd2095         )
    )
        roller_2092_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[5][47]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[5][15]    )
            ,.dgt_start                 (do_regoin_r_msg[5][15]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[5][30]    )
            ,.yzqg_down                 (di_regoin_msg[5][31]    )
            ,.yzqg_out                  (do_regoin_r_msg[5][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[5][27]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2092] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2092] )
            ,.comp_irq                  (rll_comp_irq[2092]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2092])
            ,.s1_token_if               (roller_s01_token_if[2092])
            ,.m1_token_if               (roller_s01_token_if[2095])
        );      
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2095 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2095_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2095           )
        ,.WORK_OUT1_PATH (14'd2096         )
    )
        roller_2095_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[4][42]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[4][10]    )
            ,.dgt_start                 (do_regoin_r_msg[4][10]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[4][26]    )
            ,.yzqg_down                 (di_regoin_msg[4][27]    )
            ,.yzqg_out                  (do_regoin_r_msg[4][21]  )
            ,.yzdj_start_z              (do_regoin_r_msg[4][26]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2095] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2095] )
            ,.comp_irq                  (rll_comp_irq[2095]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2095])
            ,.s1_token_if               (roller_s01_token_if[2095])
            ,.m1_token_if               (roller_s01_token_if[2096])
        );    
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2096     
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2096_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2096           )
        ,.WORK_OUT1_PATH (14'd2097          )
    )
        roller_2096_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][43]   )
            ,.dgt_error                 (di_regoin_msg[4][11]    )
            ,.dgt_start                 (do_regoin_r_msg[4][11]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2096] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2096] )
            ,.comp_irq                  (rll_comp_irq[2096]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2096])
             ,.m1_token_if                 (roller_s01_token_if[2097])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2097     
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2097_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2097           )
        ,.WORK_OUT1_PATH (14'd2098          )
    )
        roller_2097_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][44]   )
            ,.dgt_error                 (di_regoin_msg[4][12]    )
            ,.dgt_start                 (do_regoin_r_msg[4][12]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2097] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2097] )
            ,.comp_irq                  (rll_comp_irq[2097]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2097])
             ,.m1_token_if                 (roller_s01_token_if[2100])
        );
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2100 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2100_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2100           )
        ,.WORK_OUT1_PATH (14'd2103         )
    )
        roller_2100_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[4][47]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[4][15]    )
            ,.dgt_start                 (do_regoin_r_msg[4][15]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[4][30]    )
            ,.yzqg_down                 (di_regoin_msg[4][31]    )
            ,.yzqg_out                  (do_regoin_r_msg[4][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[4][27]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2100] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2100] )
            ,.comp_irq                  (rll_comp_irq[2100]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2100])
            ,.s1_token_if               (roller_s01_token_if[2100])
            ,.m1_token_if               (roller_s01_token_if[2103])
        );    
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2103 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2103_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2103           )
        ,.WORK_OUT1_PATH (14'd2104         )
    )
        roller_2103_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[3][42]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[3][10]    )
            ,.dgt_start                 (do_regoin_r_msg[3][10]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[3][26]    )
            ,.yzqg_down                 (di_regoin_msg[3][27]    )
            ,.yzqg_out                  (do_regoin_r_msg[3][21]  )
            ,.yzdj_start_z              (do_regoin_r_msg[3][26]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2103] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2103] )
            ,.comp_irq                  (rll_comp_irq[2103]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2103])
            ,.s1_token_if               (roller_s01_token_if[2103])
            ,.m1_token_if               (roller_s01_token_if[2104])
        );       
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2104     
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2104_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2104           )
        ,.WORK_OUT1_PATH (14'd2105          )
    )
        roller_2104_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][43]   )
            ,.dgt_error                 (di_regoin_msg[3][11]    )
            ,.dgt_start                 (do_regoin_r_msg[3][11]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2104] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2104] )
            ,.comp_irq                  (rll_comp_irq[2104]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2104])
             ,.m1_token_if                 (roller_s01_token_if[2105])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2105    
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2105_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2105           )
        ,.WORK_OUT1_PATH (14'd2108          )
    )
        roller_2105_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][48]   )
            ,.dgt_error                 (di_regoin_msg[3][12]    )
            ,.dgt_start                 (do_regoin_r_msg[3][12]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2105] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2105] )
            ,.comp_irq                  (rll_comp_irq[2105]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2105])
             ,.m1_token_if                 (roller_s01_token_if[2108])
        );
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2108 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2108_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2108           )
        ,.WORK_OUT1_PATH (14'd2111         )
    )
        roller_2108_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[3][47]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[3][15]    )
            ,.dgt_start                 (do_regoin_r_msg[3][15]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[3][30]    )
            ,.yzqg_down                 (di_regoin_msg[3][31]    )
            ,.yzqg_out                  (do_regoin_r_msg[3][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[3][27]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2108] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2108] )
            ,.comp_irq                  (rll_comp_irq[2108]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2108])
            ,.s1_token_if               (roller_s01_token_if[2108])
            ,.m1_token_if               (roller_s01_token_if[2111])
        );       
////////////////////////////////////////////////////////////////////2jin1chu   
////////////////////2111 
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2111_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2111           )
        ,.WORK_OUT1_PATH (14'd2007         )
    )
        roller_2111_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[2][47]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[2][12]    )
            ,.dgt_start                 (do_regoin_r_msg[2][12]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[2][30]    )
            ,.yzqg_down                 (di_regoin_msg[2][31]    )
            ,.yzqg_out                  (do_regoin_r_msg[2][23]  )
            ,.yzdj_start_z              (do_regoin_r_msg[3][30]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2111] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2111] )
            ,.comp_irq                  (rll_comp_irq[2111]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2111])
            ,.s1_token_if               (roller_s01_token_if[2111])
            ,.m1_token_if               (roller_s01_token_if[2007])
        );    
/////////////////////////////////////////////////////////////////////////////////////////////////////
//////2109
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2109_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2109           )
        ,.WORK_OUT1_PATH (14'd2110          )
    )
        roller_2109_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[2][45]   )
            ,.dgt_error                 (di_regoin_msg[2][10]   )
            ,.dgt_start                 (do_regoin_r_msg[2][10] )
            ,.yzqg_up                   (di_regoin_msg[2][29]   )
            ,.yzqg_down                 (di_regoin_msg[2][30]   )
            ,.yzqg_out                  (do_regoin_r_msg[2][22] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2109] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2109] )
            ,.comp_irq                  (rll_comp_irq[2109]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2110])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 ////////2110   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2110_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2110           )
        ,.WORK_OUT1_PATH (14'd2111          )
    )
        roller_2110_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[2][46]   )
            ,.dgt_error                 (di_regoin_msg[2][11]    )
            ,.dgt_start                 (do_regoin_r_msg[2][11]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2110] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2110] )
            ,.comp_irq                  (rll_comp_irq[2110]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2110])
             ,.m1_token_if                 (roller_s00_token_if[2111])
        );
        
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2106
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2106_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2106           )
        ,.WORK_OUT1_PATH (14'd2107          )
    )
        roller_2106_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[3][45]   )
            ,.dgt_error                 (di_regoin_msg[3][13]   )
            ,.dgt_start                 (do_regoin_r_msg[3][13] )
            ,.yzqg_up                   (di_regoin_msg[3][28]   )
            ,.yzqg_down                 (di_regoin_msg[3][29]   )
            ,.yzqg_out                  (do_regoin_r_msg[3][22] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2106] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2106] )
            ,.comp_irq                  (rll_comp_irq[2106]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2107])
        );
 ////////2107   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2107_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2107           )
        ,.WORK_OUT1_PATH (14'd2108          )
    )
        roller_2107_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][46]   )
            ,.dgt_error                 (di_regoin_msg[3][14]    )
            ,.dgt_start                 (do_regoin_r_msg[3][14]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2107] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2107] )
            ,.comp_irq                  (rll_comp_irq[2107]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2107])
             ,.m1_token_if                 (roller_s00_token_if[2108])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
//////2101
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2101_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2101           )
        ,.WORK_OUT1_PATH (14'd2102          )
    )
        roller_2101_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[3][40]   )
            ,.dgt_error                 (di_regoin_msg[3][8]   )
            ,.dgt_start                 (do_regoin_r_msg[3][8] )
            ,.yzqg_up                   (di_regoin_msg[3][24]   )
            ,.yzqg_down                 (di_regoin_msg[3][25]   )
            ,.yzqg_out                  (do_regoin_r_msg[3][20] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2101] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2101] )
            ,.comp_irq                  (rll_comp_irq[2101]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2102])
        );
 ////////2102   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2102_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2102           )
        ,.WORK_OUT1_PATH (14'd2103          )
    )
        roller_2102_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[3][41]   )
            ,.dgt_error                 (di_regoin_msg[3][9]    )
            ,.dgt_start                 (do_regoin_r_msg[3][9]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2102] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2102] )
            ,.comp_irq                  (rll_comp_irq[2102]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2102])
             ,.m1_token_if                 (roller_s00_token_if[2103])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
//////2098
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2098_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2098           )
        ,.WORK_OUT1_PATH (14'd2099          )
    )
        roller_2098_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[4][45]   )
            ,.dgt_error                 (di_regoin_msg[4][13]   )
            ,.dgt_start                 (do_regoin_r_msg[4][13] )
            ,.yzqg_up                   (di_regoin_msg[4][28]   )
            ,.yzqg_down                 (di_regoin_msg[4][29]   )
            ,.yzqg_out                  (do_regoin_r_msg[4][22] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2098] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2098] )
            ,.comp_irq                  (rll_comp_irq[2098]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2099])
        );
 ////////2099   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2099_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2099           )
        ,.WORK_OUT1_PATH (14'd2100          )
    )
        roller_2099_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][46]   )
            ,.dgt_error                 (di_regoin_msg[4][14]    )
            ,.dgt_start                 (do_regoin_r_msg[4][14]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2099] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2099] )
            ,.comp_irq                  (rll_comp_irq[2099]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2099])
             ,.m1_token_if                 (roller_s00_token_if[2100])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2093
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2093_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2093           )
        ,.WORK_OUT1_PATH (14'd2094          )
    )
        roller_2093_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[4][40]   )
            ,.dgt_error                 (di_regoin_msg[4][8]   )
            ,.dgt_start                 (do_regoin_r_msg[4][8] )
            ,.yzqg_up                   (di_regoin_msg[4][24]   )
            ,.yzqg_down                 (di_regoin_msg[4][25]   )
            ,.yzqg_out                  (do_regoin_r_msg[4][20] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2093] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2093] )
            ,.comp_irq                  (rll_comp_irq[2093]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2094])
        );
 ////////2094   
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2094_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2094           )
        ,.WORK_OUT1_PATH (14'd2095          )
    )
        roller_2094_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[4][41]   )
            ,.dgt_error                 (di_regoin_msg[4][9]    )
            ,.dgt_start                 (do_regoin_r_msg[4][9]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2094] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2094] )
            ,.comp_irq                  (rll_comp_irq[2094]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2094])
             ,.m1_token_if                 (roller_s00_token_if[2095])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2090
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2090_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2090           )
        ,.WORK_OUT1_PATH (14'd2091          )
    )
        roller_2090_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[5][45]   )
            ,.dgt_error                 (di_regoin_msg[5][13]   )
            ,.dgt_start                 (do_regoin_r_msg[5][13] )
            ,.yzqg_up                   (di_regoin_msg[5][28]   )
            ,.yzqg_down                 (di_regoin_msg[5][29]   )
            ,.yzqg_out                  (do_regoin_r_msg[5][22] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2090] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2090] )
            ,.comp_irq                  (rll_comp_irq[2090]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2091])
        );
 ////////2091  
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2091_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2091           )
        ,.WORK_OUT1_PATH (14'd2092          )
    )
        roller_2091_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][46]   )
            ,.dgt_error                 (di_regoin_msg[5][14]    )
            ,.dgt_start                 (do_regoin_r_msg[5][14]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2091] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2091] )
            ,.comp_irq                  (rll_comp_irq[2091]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2091])
             ,.m1_token_if                 (roller_s00_token_if[2092])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2085
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2085_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2085           )
        ,.WORK_OUT1_PATH (14'd2086          )
    )
        roller_2085_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[5][40]   )
            ,.dgt_error                 (di_regoin_msg[5][8]   )
            ,.dgt_start                 (do_regoin_r_msg[5][8] )
            ,.yzqg_up                   (di_regoin_msg[5][24]   )
            ,.yzqg_down                 (di_regoin_msg[5][25]   )
            ,.yzqg_out                  (do_regoin_r_msg[5][20] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2085] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2085] )
            ,.comp_irq                  (rll_comp_irq[2085]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2086])
        );
 ////////2086  
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2086_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2086           )
        ,.WORK_OUT1_PATH (14'd2087          )
    )
        roller_2086_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[5][41]   )
            ,.dgt_error                 (di_regoin_msg[5][9]    )
            ,.dgt_start                 (do_regoin_r_msg[5][9]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2086] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2086] )
            ,.comp_irq                  (rll_comp_irq[2086]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2086])
             ,.m1_token_if                 (roller_s00_token_if[2087])
        );
/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
  //////2082
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2082_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2082           )
        ,.WORK_OUT1_PATH (14'd2083          )
    )
        roller_2082_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[6][45]   )
            ,.dgt_error                 (di_regoin_msg[6][13]   )
            ,.dgt_start                 (do_regoin_r_msg[6][13] )
            ,.yzqg_up                   (di_regoin_msg[6][28]   )
            ,.yzqg_down                 (di_regoin_msg[6][29]   )
            ,.yzqg_out                  (do_regoin_r_msg[6][22] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2082] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2082] )
            ,.comp_irq                  (rll_comp_irq[2082]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2083])
        );
 ////////2083  
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2083_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2083           )
        ,.WORK_OUT1_PATH (14'd2084          )
    )
        roller_2083_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][46]   )
            ,.dgt_error                 (di_regoin_msg[6][14]    )
            ,.dgt_start                 (do_regoin_r_msg[6][14]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2083] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2083] )
            ,.comp_irq                  (rll_comp_irq[2083]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2083])
             ,.m1_token_if                 (roller_s00_token_if[2084])
        );

/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
//////2077
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2077_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2077           )
        ,.WORK_OUT1_PATH (14'd2078          )
    )
        roller_2077_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[6][40]   )
            ,.dgt_error                 (di_regoin_msg[6][8]   )
            ,.dgt_start                 (do_regoin_r_msg[6][8] )
            ,.yzqg_up                   (di_regoin_msg[6][24]   )
            ,.yzqg_down                 (di_regoin_msg[6][25]   )
            ,.yzqg_out                  (do_regoin_r_msg[6][20] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2077] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2077] )
            ,.comp_irq                  (rll_comp_irq[2077]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2078])
        ); 
 ////////2078 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2078_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2078           )
        ,.WORK_OUT1_PATH (14'd2079          )
    )
        roller_2078_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[6][41]   )
            ,.dgt_error                 (di_regoin_msg[6][9]    )
            ,.dgt_start                 (do_regoin_r_msg[6][9]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2078] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2078] )
            ,.comp_irq                  (rll_comp_irq[2078]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2078])
             ,.m1_token_if                 (roller_s00_token_if[2079])
        );

/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2070
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2070_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2070           )
        ,.WORK_OUT1_PATH (14'd2071          )
    )
        roller_2070_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[7][41]   )
            ,.dgt_error                 (di_regoin_msg[7][9]   )
            ,.dgt_start                 (do_regoin_r_msg[7][9] )
            ,.yzqg_up                   (di_regoin_msg[7][24]   )
            ,.yzqg_down                 (di_regoin_msg[7][25]   )
            ,.yzqg_out                  (do_regoin_r_msg[7][20] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2070] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2070] )
            ,.comp_irq                  (rll_comp_irq[2070]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2071])
        ); 
 ////////2071 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2071_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2071           )
        ,.WORK_OUT1_PATH (14'd2072          )
    )
        roller_2071_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[7][42]   )
            ,.dgt_error                 (di_regoin_msg[7][10]    )
            ,.dgt_start                 (do_regoin_r_msg[7][10]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2071] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2071] )
            ,.comp_irq                  (rll_comp_irq[2071]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2071])
             ,.m1_token_if                 (roller_s00_token_if[2072])
        );

/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2065
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2065_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2065           )
        ,.WORK_OUT1_PATH (14'd2066          )
    )
        roller_2065_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][48]   )
            ,.dgt_error                 (di_regoin_msg[8][13]   )
            ,.dgt_start                 (do_regoin_r_msg[8][14] )
            ,.yzqg_up                   (di_regoin_msg[8][31]   )
            ,.yzqg_down                 (di_regoin_msg[8][32]   )
            ,.yzqg_out                  (do_regoin_r_msg[8][24] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2065] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2065] )
            ,.comp_irq                  (rll_comp_irq[2065]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2066])
        ); 
 ////////2066 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2066_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2066           )
        ,.WORK_OUT1_PATH (14'd2067          )
    )
        roller_2066_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][49]   )
            ,.dgt_error                 (di_regoin_msg[8][14]    )
            ,.dgt_start                 (do_regoin_r_msg[8][15]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2066] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2066] )
            ,.comp_irq                  (rll_comp_irq[2066]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2066])
             ,.m1_token_if                 (roller_s00_token_if[2067])
        );

/////////////////////////////////////////////////////////////////////////////////////////////1jin1chu
 //////2062
 roller_startpoint_auto
    #(
         .REG_SPACE_BIAS(`ROLLER_2062_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2062           )
        ,.WORK_OUT1_PATH (14'd2063          )
    )
        roller_2062_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][45]   )
            ,.dgt_error                 (di_regoin_msg[8][10]   )
            ,.dgt_start                 (do_regoin_r_msg[8][11] )
            ,.yzqg_up                   (di_regoin_msg[8][27]   )
            ,.yzqg_down                 (di_regoin_msg[8][28]   )
            ,.yzqg_out                  (do_regoin_r_msg[8][22] )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2062] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2062] )
            ,.comp_irq                  (rll_comp_irq[2062]   )
        //  components interface
            ,.m1_token_if               (roller_s01_token_if[2063])
        ); 
 ////////2063 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2063_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2063           )
        ,.WORK_OUT1_PATH (14'd2064          )
    )
        roller_2063_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[8][46]   )
            ,.dgt_error                 (di_regoin_msg[8][11]    )
            ,.dgt_start                 (do_regoin_r_msg[8][12]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2063] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2063] )
            ,.comp_irq                  (rll_comp_irq[2063]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2063])
             ,.m1_token_if                 (roller_s00_token_if[2064])
        );
        
//////////hunaceng2059_2060
  roller_midpoint_level_ic_oc
    #(
         .REG_SPACE_BIAS(`ROLLER_2059_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2059           )
        ,.WORK_OUT1_PATH (14'd2060          )
    )
        roller_2059_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][42]   )
            ,.dgt_error                 (di_regoin_msg[8][7]    )
            ,.dgt_start                 (do_regoin_r_msg[8][7]  )
            ,.hcqg_up                   (di_regoin_msg[8][25]   )
            ,.hcqg_down                 (di_regoin_msg[8][26]   )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2059] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2059] )
            ,.comp_irq                  (rll_comp_irq[2059]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[2059])
            ,.m1_token_if               (roller_s01_token_if[2060])
        );
//////
 roller_midpoint_level_ud
    #(
         .REG_SPACE_BIAS(`ROLLER_2060_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2060           )
        ,.WORK_OUT1_PATH (14'd2061          )
    )
        roller_2060_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[8][43]   )
            ,.dgt_error                 (di_regoin_msg[8][8]    )
            ,.dgt_start                 (do_regoin_r_msg[8][8]  )
            ,.dgt_start_f               (do_regoin_r_msg[8][9]  )
            ,.hcqg_up                   (di_regoin_msg[8][25]   )
            ,.hcqg_down                 (di_regoin_msg[8][26]   )
            ,.hcqg_out_up               (do_regoin_r_msg[8][26]  )
            ,.hcqg_out_down             (do_regoin_r_msg[8][27]  )

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2060] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2060] )
            ,.comp_irq                  (rll_comp_irq[2060]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[2060])
            ,.m1_token_if               (roller_s01_token_if[2061])
        );
 ////////2160 
    rll_slv_scan_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2160_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2160           )
        ,.WORK_OUT1_PATH (14'd2158          )
        ,.SLAVE_PCB_NUM  ( 1 )
        ,.LOCK_SCAN_ADDR(`DEPOT_BIAS_RS232_1ST)
    )
        roller_2160_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

            ,.ext_dev_req               (di_regoin_msg[1][55])
            ,.ext_dev_ack               (do_regoin_r_msg[1][24])
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][35]     )
            ,.dgt_error                 (di_regoin_msg[1][11]     )
            ,.dgt_start                 (do_regoin_r_msg[1][17]   )

            ,.rs232_1st_vld             (sys_wea[1]           )
            ,.rs232_1st_addr            (sys_addra[1]         )
            ,.rs232_1st_msg             (rs232_1st_msg[1]     )
            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2160] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2160] )
            ,.comp_irq                  (rll_comp_irq[2160]    )
        //  components interface

             ,.m1_token_if                 (roller_s01_token_if[2158])
        );  
   ////////2158 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2158_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2158           )
        ,.WORK_OUT1_PATH (14'd2156          )
    )
        roller_2158_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][33]     )
            ,.dgt_error                 (di_regoin_msg[1][9]     )
            ,.dgt_start                 (do_regoin_r_msg[1][15]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2158] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2158] )
            ,.comp_irq                  (rll_comp_irq[2158]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2158])
             ,.m1_token_if                 (roller_s01_token_if[2156])
        );   
     ////////2156 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2156_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2156           )
        ,.WORK_OUT1_PATH (14'd2154          )
    )
        roller_2156_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][31]     )
            ,.dgt_error                 (di_regoin_msg[1][7]     )
            ,.dgt_start                 (do_regoin_r_msg[1][13]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2156] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2156] )
            ,.comp_irq                  (rll_comp_irq[2156]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2156])
             ,.m1_token_if                 (roller_s01_token_if[2154])
        );    
  ////////2154 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2154_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2154           )
        ,.WORK_OUT1_PATH (14'd2153          )
    )
        roller_2154_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][29]     )
            ,.dgt_error                 (di_regoin_msg[1][5]     )
            ,.dgt_start                 (do_regoin_r_msg[1][11]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2154] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2154] )
            ,.comp_irq                  (rll_comp_irq[2154]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2154])
             ,.m1_token_if                 (roller_s01_token_if[2153])
        );  
 ////////2153 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2153_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2153           )
        ,.WORK_OUT1_PATH (14'd2151          )
    )
        roller_2153_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][28]     )
            ,.dgt_error                 (di_regoin_msg[1][4]     )
            ,.dgt_start                 (do_regoin_r_msg[1][10]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2153] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2153] )
            ,.comp_irq                  (rll_comp_irq[2153]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2153])
             ,.m1_token_if                 (roller_s01_token_if[2151])
        );
////////2151 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2151_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2151           )
        ,.WORK_OUT1_PATH (14'd2150          )
    )
        roller_2151_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][26]     )
            ,.dgt_error                 (di_regoin_msg[1][2]     )
            ,.dgt_start                 (do_regoin_r_msg[1][8]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2151] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2151] )
            ,.comp_irq                  (rll_comp_irq[2151]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2151])
             ,.m1_token_if                 (roller_s01_token_if[2150])
        ); 
///////2150          
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2150_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2150           )
        ,.WORK_OUT1_PATH (14'd2146          )
       
        
    )
        roller_2150_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][24]    )
            ,.dgt_error                 (di_regoin_msg[0][49]    )
            ,.dgt_start                 (do_regoin_r_msg[0][15]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2150] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2150] )
            ,.comp_irq                  (rll_comp_irq[2150]      )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[2150])
            ,.m1_token_if               (roller_s01_token_if[2146])
        );                
////////////////////2146 
 rll_transf_ic_il_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2146_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2146          )
        ,.WORK_OUT1_PATH (14'd2142        )
        ,.WORK_OUT0_PATH (14'd2145        )
    )
        roller_2146_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[1][25]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[1][1]    )
            ,.dgt_start                 (do_regoin_r_msg[1][7]  )
//            ,.dgt_start_f               (do_regoin_r_msg[0][6]  )
            ,.yzqg_up                   (di_regoin_msg[1][18]    )
            ,.yzqg_down                 (di_regoin_msg[1][19]    )
            ,.yzqg_out                  (do_regoin_r_msg[1][1]  )
            ,.yzdj_start_z              (do_regoin_r_msg[1][3]  )
           // ,.yzdj_start_f              (do_regoin_r_msg[9][28]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2146] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2146] )
            ,.comp_irq                  (rll_comp_irq[2146]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2146])
            ,.s1_token_if               (roller_s01_token_if[2146])
            ,.m0_token_if               (roller_s00_token_if[2145])
            ,.m1_token_if               (roller_s01_token_if[2142])
        );   
/////2142         
 rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2142_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2142           )
        ,.WORK_OUT0_PATH (14'd2143          )
        ,.WORK_OUT1_PATH (14'd2140         )
    )
        roller_2142_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][18]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[0][43]    )
            ,.dgt_start                 (do_regoin_r_msg[0][9]  )
            ,.yzqg_up                   (di_regoin_msg[0][2]    )
            ,.yzqg_down                 (di_regoin_msg[0][3]    )
            ,.yzqg_out                  (do_regoin_r_msg[0][17]  )
            ,.yzdj_start_z              (do_regoin_r_msg[0][21]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2142])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2142] )
            ,.comp_irq                  (rll_comp_irq[2142]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2142])
            ,.m1_token_if               (roller_s01_token_if[2140])
            ,.m0_token_if               (roller_s01_token_if[2143])
        ); 
////////2140 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2140_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2140           )
        ,.WORK_OUT1_PATH (14'd2137          )
    )
        roller_2140_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][16]     )
            ,.dgt_error                 (di_regoin_msg[0][41]     )
            ,.dgt_start                 (do_regoin_r_msg[0][7]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2140] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2140] )
            ,.comp_irq                  (rll_comp_irq[2140]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2140])
             ,.m1_token_if                 (roller_s01_token_if[2137])
        );    
/////2137         
 rll_transf_ic_oc_or_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2137_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2137           )
        ,.WORK_OUT0_PATH (14'd2138          )
        ,.WORK_OUT1_PATH (14'd2135          )
    )
        roller_2137_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][13]    )  //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[0][39]    )
            ,.dgt_start                 (do_regoin_r_msg[0][5]  )
            ,.yzqg_up                   (di_regoin_msg[0][0]    )
            ,.yzqg_down                 (di_regoin_msg[0][1]    )
            ,.yzqg_out                  (do_regoin_r_msg[0][16]  )
            ,.yzdj_start_z              (do_regoin_r_msg[0][20]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2137])
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2137] )
            ,.comp_irq                  (rll_comp_irq[2137]    )
        //  components interface

            ,.s1_token_if               (roller_s01_token_if[2137])
            ,.m1_token_if               (roller_s01_token_if[2135])
            ,.m0_token_if               (roller_s01_token_if[2138])
        ); 
////////2135 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2135_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2135           )
        ,.WORK_OUT1_PATH (14'd2133          )
    )
        roller_2135_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][11]     )
            ,.dgt_error                 (di_regoin_msg[0][37]     )
            ,.dgt_start                 (do_regoin_r_msg[0][3]   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2135] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2135] )
            ,.comp_irq                  (rll_comp_irq[2135]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2135])
             ,.m1_token_if                 (roller_s01_token_if[2133])
        );   
////////2133 
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2133_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2133           )
        ,.WORK_OUT1_PATH (14'd2130          )
    )
        roller_2133_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[48]     )
            ,.dgt_error                 (~di_mst_msg[11]     )
            ,.dgt_start                 (do_mst_msg[12]    )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2133] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2133] )
            ,.comp_irq                  (rll_comp_irq[2133]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2133])
             ,.m1_token_if                 (roller_s01_token_if[2130])
        );  
////////2130
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2130_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2130           )
        ,.WORK_OUT1_PATH (14'd2128          )
    )
        roller_2130_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[47]     )
            ,.dgt_error                 (~di_mst_msg[10]     )
            ,.dgt_start                 (do_mst_msg[11]    )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2130] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2130] )
            ,.comp_irq                  (rll_comp_irq[2130]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2130])
             ,.m1_token_if                 (roller_s01_token_if[2128])
        );     
////////2128
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2128_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2128           )
        ,.WORK_OUT1_PATH (14'd2126          )
    )
        roller_2128_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[45]     )
            ,.dgt_error                 (~di_mst_msg[9]     )
            ,.dgt_start                 (do_mst_msg[10]    )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2128] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2128] )
            ,.comp_irq                  (rll_comp_irq[2128]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2128])
             ,.m1_token_if                 (roller_s01_token_if[2125])
        );   
////////2125
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2125_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2125           )
        ,.WORK_OUT1_PATH (14'd2123         )
    )
        roller_2125_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[42]     )
            ,.dgt_error                 (~di_mst_msg[8]     )
            ,.dgt_start                 (do_mst_msg[9]    )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2125] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2125] )
            ,.comp_irq                  (rll_comp_irq[2125]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2125])
             ,.m1_token_if                 (roller_s01_token_if[2123])
        );  
////////2123
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2123_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2123           )
        ,.WORK_OUT1_PATH (14'd2120          )
    )
        roller_2123_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[40]     )
            ,.dgt_error                 (~di_mst_msg[7]     )
            ,.dgt_start                 (do_mst_msg[8]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2123] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2123] )
            ,.comp_irq                  (rll_comp_irq[2123]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2123])
             ,.m1_token_if                 (roller_s01_token_if[2120])
        );    
////////2120
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2120_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2120           )
        ,.WORK_OUT1_PATH (14'd2118          )
    )
        roller_2120_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[37]     )
            ,.dgt_error                 (~di_mst_msg[6]     )
            ,.dgt_start                 (do_mst_msg[7]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2120] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2120] )
            ,.comp_irq                  (rll_comp_irq[2120]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2120])
             ,.m1_token_if                 (roller_s01_token_if[2118])
        );  
////////2118
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2118_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2118           )
        ,.WORK_OUT1_PATH (14'd2115          )
    )
        roller_2118_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[35]     )
            ,.dgt_error                 (~di_mst_msg[5]     )
            ,.dgt_start                 (do_mst_msg[6]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2118] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2118] )
            ,.comp_irq                  (rll_comp_irq[2118]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2118])
             ,.m1_token_if                 (roller_s01_token_if[2115])
        ); 
////////2115
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2115_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2115            )
        ,.WORK_OUT1_PATH (14'd2113          )
    )
        roller_2115_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[32]     )
            ,.dgt_error                 (~di_mst_msg[4]     )
            ,.dgt_start                 (do_mst_msg[5]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2115] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2115] )
            ,.comp_irq                  (rll_comp_irq[2115]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2115])
             ,.m1_token_if                 (roller_s01_token_if[2113])
        );          
////////2113
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2113_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2113           )
        ,.WORK_OUT1_PATH (14'd2112          )
    )
        roller_2113_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[2][49]     )
            ,.dgt_error                 (di_regoin_msg[2][14]     )
            ,.dgt_start                 (do_regoin_r_msg[2][14]    )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2113] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2113] )
            ,.comp_irq                  (rll_comp_irq[2113]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2113])
             ,.m1_token_if                 (roller_s01_token_if[2112])
        );   
////////2112
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2112_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2112           )
        ,.WORK_OUT1_PATH (14'd2002          )
    )
        roller_2112_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[2][48]     )
            ,.dgt_error                 (di_regoin_msg[2][13]     )
            ,.dgt_start                 (do_regoin_r_msg[2][13]    )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2112] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2112] )
            ,.comp_irq                  (rll_comp_irq[2112]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2112])
             ,.m1_token_if                 (roller_s00_token_if[2002])
        );    
////////2114
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2114_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2114           )
        ,.WORK_OUT1_PATH (14'd2116          )
    )
        roller_2114_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[31]     )
            ,.dgt_error                 (di_mst_msg[19]     )
            ,.dgt_start                 (do_mst_msg[17]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2114] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2114] )
            ,.comp_irq                  (rll_comp_irq[2114]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2114])
             ,.m1_token_if                 (roller_s01_token_if[2116])
        );    
////////2116
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2116_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2116           )
        ,.WORK_OUT1_PATH (14'd2117          )
    )
        roller_2116_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[33]     )
            ,.dgt_error                 (di_mst_msg[20]     )
            ,.dgt_start                 (do_mst_msg[18]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2116] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2116] )
            ,.comp_irq                  (rll_comp_irq[2116]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2116])
             ,.m1_token_if                 (roller_s01_token_if[2117])
        );   
////////2117
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2117_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2117           )
        ,.WORK_OUT1_PATH (14'd2119          )
    )
        roller_2117_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[34]     )
            ,.dgt_error                 (di_mst_msg[21]     )
            ,.dgt_start                 (do_mst_msg[19]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2117] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2117] )
            ,.comp_irq                  (rll_comp_irq[2117]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2117])
             ,.m1_token_if                 (roller_s01_token_if[2119])
        );  
////////2119
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2119_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2119           )
        ,.WORK_OUT1_PATH (14'd2121          )
    )
        roller_2119_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[36]     )
            ,.dgt_error                 (di_mst_msg[22]     )
            ,.dgt_start                 (do_mst_msg[20]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2119] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2119] )
            ,.comp_irq                  (rll_comp_irq[2119]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2119])
             ,.m1_token_if                 (roller_s01_token_if[2121])
        ); 
////////2121
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2121_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2121           )
        ,.WORK_OUT1_PATH (14'd2122          )
    )
        roller_2121_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[38]     )
            ,.dgt_error                 (di_mst_msg[23]     )
            ,.dgt_start                 (do_mst_msg[21]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2121] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2121] )
            ,.comp_irq                  (rll_comp_irq[2121]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2121])
             ,.m1_token_if                 (roller_s01_token_if[2122])
        );   
////////2122
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2122_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2122           )
        ,.WORK_OUT1_PATH (14'd2124          )
    )
        roller_2122_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[39]     )
            ,.dgt_error                 (di_mst_msg[24]     )
            ,.dgt_start                 (do_mst_msg[22]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2122] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2122] )
            ,.comp_irq                  (rll_comp_irq[2122]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2122])
             ,.m1_token_if                 (roller_s01_token_if[2124])
        );  
////////2124
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2124_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2124           )
        ,.WORK_OUT1_PATH (14'd2126          )
    )
        roller_2124_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[41]     )
            ,.dgt_error                 (di_mst_msg[25]     )
            ,.dgt_start                 (do_mst_msg[23]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2124] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2124] )
            ,.comp_irq                  (rll_comp_irq[2124]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2124])
             ,.m1_token_if                 (roller_s01_token_if[2126])
        );  
///////2126
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2126_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2126           )
        ,.WORK_OUT1_PATH (14'd2127          )
    )
        roller_2126_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[43]     )
            ,.dgt_error                 (di_mst_msg[26]     )
            ,.dgt_start                 (do_mst_msg[24]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2126] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2126] )
            ,.comp_irq                  (rll_comp_irq[2126]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2126])
             ,.m1_token_if                 (roller_s01_token_if[2127])
        ); 
///////2127
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2127_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2127           )
        ,.WORK_OUT1_PATH (14'd2129          )
    )
        roller_2127_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[44]     )
            ,.dgt_error                 (di_mst_msg[27]     )
            ,.dgt_start                 (do_mst_msg[25]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2127] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2127] )
            ,.comp_irq                  (rll_comp_irq[2127]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2127])
             ,.m1_token_if                 (roller_s01_token_if[2129])
        );  
///////2129
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2129_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2129           )
        ,.WORK_OUT1_PATH (14'd2131          )
    )
        roller_2129_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_mst_msg[46]     )
            ,.dgt_error                 (di_mst_msg[28]     )
            ,.dgt_start                 (do_mst_msg[26]     )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2129] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2129] )
            ,.comp_irq                  (rll_comp_irq[2129]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2129])
             ,.m1_token_if                 (roller_s01_token_if[2131])
        );  
///////2131
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2131_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2131           )
        ,.WORK_OUT1_PATH (14'd2132          )
    )
        roller_2131_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][8]     )
            ,.dgt_error                 (di_regoin_msg[0][34]    )
            ,.dgt_start                 (do_regoin_r_msg[0][0]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2131] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2131] )
            ,.comp_irq                  (rll_comp_irq[2131]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2131])
             ,.m1_token_if                 (roller_s01_token_if[2132])
        );    
///////2132
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2132_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2132           )
        ,.WORK_OUT1_PATH (14'd2134          )
    )
        roller_2132_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][9]     )
            ,.dgt_error                 (di_regoin_msg[0][35]    )
            ,.dgt_start                 (do_regoin_r_msg[0][1]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2132] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2132] )
            ,.comp_irq                  (rll_comp_irq[2132]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2132])
             ,.m1_token_if                 (roller_s01_token_if[2134])
        ); 
///////2134
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2134_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2134           )
        ,.WORK_OUT1_PATH (14'd2136          )
    )
        roller_2134_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][10]     )
            ,.dgt_error                 (di_regoin_msg[0][36]    )
            ,.dgt_start                 (do_regoin_r_msg[0][2]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2134] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2134] )
            ,.comp_irq                  (rll_comp_irq[2134]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2134])
             ,.m1_token_if                 (roller_s01_token_if[2136])
        );         
///////2136
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2136_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2136           )
        ,.WORK_OUT1_PATH (14'd2139          )
    )
        roller_2136_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][12]     )
            ,.dgt_error                 (di_regoin_msg[0][38]    )
            ,.dgt_start                 (do_regoin_r_msg[0][4]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2136] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2136] )
            ,.comp_irq                  (rll_comp_irq[2136]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2136])
             ,.m1_token_if                 (roller_s01_token_if[2139])
        );  
///////2139
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2139_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2139           )
        ,.WORK_OUT1_PATH (14'd2141          )
    )
        roller_2139_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][15]     )
            ,.dgt_error                 (di_regoin_msg[0][40]    )
            ,.dgt_start                 (do_regoin_r_msg[0][6]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2139] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2139] )
            ,.comp_irq                  (rll_comp_irq[2139]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2139])
             ,.m1_token_if                 (roller_s01_token_if[2141])
        );    
///////2141
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2141_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2141           )
        ,.WORK_OUT1_PATH (14'd2145          )
    )
        roller_2141_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][17]     )
            ,.dgt_error                 (di_regoin_msg[0][42]    )
            ,.dgt_start                 (do_regoin_r_msg[0][8]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2141] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2141] )
            ,.comp_irq                  (rll_comp_irq[2141]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2141])
             ,.m1_token_if                 (roller_s01_token_if[2145])
        );   
///////////////////////////////2145
 rll_transf_ic_il_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2145_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2145          )
        ,.WORK_OUT1_PATH (14'd2149        )
    )
        roller_2145_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.mat_arrived               (di_regoin_msg[1][24]    )   //arrive_test_mf
            ,.dgt_error                 (di_regoin_msg[1][0]    )
            ,.dgt_start                 (do_regoin_r_msg[1][6]  )
            
            ,.yzqg_up                   (di_regoin_msg[1][16]    )
            ,.yzqg_down                 (di_regoin_msg[1][17]    )
            ,.yzqg_out                  (do_regoin_r_msg[1][0]  )
            ,.yzdj_start_z              (do_regoin_r_msg[1][2]  )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2145] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2145] )
            ,.comp_irq                  (rll_comp_irq[2145]  )
        //  components interface
            
            ,.s0_token_if               (roller_s00_token_if[2145])
            ,.s1_token_if               (roller_s01_token_if[2145])
            ,.m1_token_if               (roller_s01_token_if[2149])
        );   
///////////////////////////
///////2149
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2149_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2149           )
        ,.WORK_OUT1_PATH (14'd2152          )
    )
        roller_2149_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][23]     )
            ,.dgt_error                 (di_regoin_msg[0][48]    )
            ,.dgt_start                 (do_regoin_r_msg[0][14]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2149] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2149] )
            ,.comp_irq                  (rll_comp_irq[2149]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2149])
             ,.m1_token_if                 (roller_s01_token_if[2152])
        );    
///////2152
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2152_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2152           )
        ,.WORK_OUT1_PATH (14'd2155          )
    )
        roller_2152_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][27]     )
            ,.dgt_error                 (di_regoin_msg[1][3]    )
            ,.dgt_start                 (do_regoin_r_msg[1][9]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2152] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2152] )
            ,.comp_irq                  (rll_comp_irq[2152]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2152])
             ,.m1_token_if                 (roller_s01_token_if[2155])
        );   
///////2155
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2155_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2155           )
        ,.WORK_OUT1_PATH (14'd2157          )
    )
        roller_2155_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][30]     )
            ,.dgt_error                 (di_regoin_msg[1][6]    )
            ,.dgt_start                 (do_regoin_r_msg[1][12]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2155] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2155] )
            ,.comp_irq                  (rll_comp_irq[2155]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2155])
             ,.m1_token_if                 (roller_s01_token_if[2157])
        );    
///////2157
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2157_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2157           )
        ,.WORK_OUT1_PATH (14'd2159          )
    )
        roller_2157_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][32]     )
            ,.dgt_error                 (di_regoin_msg[1][8]    )
            ,.dgt_start                 (do_regoin_r_msg[1][14]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2157] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2157] )
            ,.comp_irq                  (rll_comp_irq[2157]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2157])
             ,.m1_token_if                 (roller_s01_token_if[2159])
        );  
///////2159
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2159_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2159           )
        ,.WORK_OUT1_PATH (14'd2161          )
    )
        roller_2159_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][34]     )
            ,.dgt_error                 (di_regoin_msg[1][10]    )
            ,.dgt_start                 (do_regoin_r_msg[1][16]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2159] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2159] )
            ,.comp_irq                  (rll_comp_irq[2159]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2159])
             ,.m1_token_if                 (roller_s01_token_if[2161])
        );    
///////2161
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2161_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2161           )
        ,.WORK_OUT1_PATH (14'd2162          )
    )
        roller_2161_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[1][36]     )
            ,.dgt_error                 (di_regoin_msg[1][12]    )
            ,.dgt_start                 (do_regoin_r_msg[1][18]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2161] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2161] )
            ,.comp_irq                  (rll_comp_irq[2161]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2161])
             ,.m1_token_if                 (roller_s01_token_if[2162])
        );  
///////2162
    rll_mst_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2162_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2162           )
        ,.WORK_OUT1_PATH (14'd4162          )
    )
        roller_2162_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

             ,.mat_arrived              (di_regoin_msg[1][37]  )
            ,.dgt_error                 (di_regoin_msg[1][13]  )
            ,.dgt_start                 (do_regoin_r_msg[1][19])
            ,.ext_dev_req               (do_regoin_r_msg[1][25])
            ,.ext_dev_ack               (di_regoin_msg[1][56])
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2162] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2162] )
            ,.comp_irq                  (rll_comp_irq[2162]    )
        //  components interface

             ,.s1_token_if              (roller_s01_token_if[2162])
        ); 
///////2147          
rll_scan_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2147_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2147           )
        ,.WORK_OUT1_PATH (14'd2146          )
        ,.SLAVE_PCB_NUM  ( 1 )
        ,.LOCK_SCAN_ADDR(`DEPOT_BIAS_RS232_2ND)
    )
        roller_2147_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][21]    )
            ,.dgt_error                 (di_regoin_msg[0][46]    )
            ,.dgt_start                 (do_regoin_r_msg[0][12]  )

            ,.rs232_1st_vld             (sys_wea[1]           )
            ,.rs232_1st_addr            (sys_addra[1]         )
            ,.rs232_1st_msg             (rs232_2nd_msg[1]     )

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2147] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2147] )
            ,.comp_irq                  (rll_comp_irq[2147]      )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[2147])
            ,.m1_token_if               (roller_s00_token_if[2146])
        );     
///////2148
    rll_ohlyslv_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2148_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2148           )
        ,.WORK_OUT1_PATH (14'd2147          )
    )
        roller_2148_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

            ,.mat_arrived               (di_regoin_msg[0][22]     )
            ,.dgt_error                 (di_regoin_msg[0][47]    )
            ,.dgt_start                 (do_regoin_r_msg[0][13]   )
            ,.ext_dev_req               (di_regoin_msg[1][52])
            ,.ext_dev_ack               (do_regoin_r_msg[1][23])
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            

            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2148] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2148] )
            ,.comp_irq                  (rll_comp_irq[2148]    )
        //  components interface
             ,.m1_token_if                 (roller_s01_token_if[2147])
        );  
///////2143
    rll_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2143_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2143           )
        ,.WORK_OUT1_PATH (14'd2144         )
    )
        roller_2143_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][19]     )
            ,.dgt_error                 (di_regoin_msg[0][44]    )
            ,.dgt_start                 (do_regoin_r_msg[0][10]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2143] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2143] )
            ,.comp_irq                  (rll_comp_irq[2143]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2143])
             ,.m1_token_if                 (roller_s01_token_if[2144])
        );   
///////2144
    rll_mst_ic_oc_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2144_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2144           )
        ,.WORK_OUT1_PATH (14'd4144         )
    )
        roller_2144_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )

            ,.ext_dev_req     (do_regoin_r_msg[1][22])
            ,.ext_dev_ack     (di_regoin_msg[1][51])
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            
            ,.mat_arrived               (di_regoin_msg[0][20]     )
            ,.dgt_error                 (di_regoin_msg[0][45]    )
            ,.dgt_start                 (do_regoin_r_msg[0][11]   )


            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2144] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2144] )
            ,.comp_irq                  (rll_comp_irq[2144]    )
        //  components interface

             ,.s1_token_if                 (roller_s01_token_if[2144])
        );  
/////////////2138
rll_alm_ic_comp_top
    #(
         .REG_SPACE_BIAS(`ROLLER_2138_REG_BIAS)
        ,.REG_SPACE_SIZE(`REG_SPACE_SIZE    )
        ,.PS_REG_AWIDTH (PS_REG_AWIDTH      )
        ,.PS_REG_DWIDTH (PS_REG_DWIDTH      )
        ,.CUR_LOCATION  (14'd2138           )
    )
        roller_2138_u
        (
             .clk                       (clk        )
            ,.reset                     (reset      )
            
            ,.mat_arrived               (di_regoin_msg[0][14]  )
            ,.wl                        (do_regoin_r_msg[0][18])

            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )

            ,.ps_reg_we                 (ps_reg_we      )
            ,.ps_reg_addr               (ps_reg_addr    )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat  )
            ,.ps_reg_re                 (ps_reg_re      )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr )
            ,.ps_reg_rd_vld             (sub_ps_reg_rd_vld[2138] )
            ,.ps_reg_rd_dat             (sub_ps_reg_rd_dat[2138] )
            ,.comp_irq                  (rll_comp_irq[2138]   )
        //  components interface
            ,.s1_token_if               (roller_s01_token_if[2138])
        );        
`endif
////////////////////////   
///////////////////////////////////////////////////////////////////
//interrupt assign
    assign  comp_irq[0] = rll_comp_irq[1000];
    assign  comp_irq[1] = rll_comp_irq[1001];
    assign  comp_irq[2] = rll_comp_irq[1002];
    assign  comp_irq[3] = rll_comp_irq[1003];
    assign  comp_irq[4] = rll_comp_irq[1004];
    assign  comp_irq[5] = rll_comp_irq[1005];
    assign  comp_irq[6] = rll_comp_irq[1006];
    assign  comp_irq[7] = rll_comp_irq[1007];
    assign  comp_irq[8] = rll_comp_irq[1008];
    assign  comp_irq[9] = rll_comp_irq[1009];
    assign  comp_irq[10] = rll_comp_irq[1010];
    assign  comp_irq[11] = rll_comp_irq[1011];
    assign  comp_irq[12] = rll_comp_irq[1012];
    assign  comp_irq[13] = rll_comp_irq[1013];
    assign  comp_irq[14] = rll_comp_irq[1014];
    assign  comp_irq[15] = rll_comp_irq[1015];
    assign  comp_irq[16] = rll_comp_irq[1016];
    assign  comp_irq[17] = rll_comp_irq[1017];
    assign  comp_irq[18] = rll_comp_irq[1018];
    assign  comp_irq[19] = rll_comp_irq[1019];
    assign  comp_irq[20] = rll_comp_irq[1020];
    assign  comp_irq[21] = rll_comp_irq[1021];
    assign  comp_irq[22] = rll_comp_irq[1022];
    assign  comp_irq[23] = rll_comp_irq[1023];
    assign  comp_irq[24] = rll_comp_irq[1024];
    assign  comp_irq[25] = rll_comp_irq[1025];
    assign  comp_irq[26] = rll_comp_irq[1026];
    assign  comp_irq[27] = rll_comp_irq[1027];
    assign  comp_irq[28] = rll_comp_irq[1028];
    assign  comp_irq[29] = rll_comp_irq[1029];
    assign  comp_irq[30] = rll_comp_irq[1030];
    assign  comp_irq[31] = rll_comp_irq[1031];
    assign  comp_irq[32] = rll_comp_irq[1032];
    assign  comp_irq[33] = rll_comp_irq[1033];
    assign  comp_irq[34] = rll_comp_irq[1034];
    assign  comp_irq[35] = rll_comp_irq[1035];
    assign  comp_irq[36] = rll_comp_irq[1036];
    assign  comp_irq[37] = rll_comp_irq[1037];
    assign  comp_irq[38] = rll_comp_irq[1038];
    assign  comp_irq[39] = rll_comp_irq[1039];
    assign  comp_irq[40] = rll_comp_irq[1040];
    assign  comp_irq[41] = rll_comp_irq[1041];
    assign  comp_irq[42] = rll_comp_irq[1042];
    assign  comp_irq[43] = rll_comp_irq[1043];
    assign  comp_irq[44] = rll_comp_irq[1044];
    assign  comp_irq[45] = rll_comp_irq[1045];
    assign  comp_irq[46] = rll_comp_irq[1046];
    assign  comp_irq[47] = rll_comp_irq[1047];
    assign  comp_irq[48] = rll_comp_irq[1048];
    assign  comp_irq[49] = rll_comp_irq[1049];
    assign  comp_irq[50] = rll_comp_irq[1050];
    assign  comp_irq[51] = rll_comp_irq[1051];
    assign  comp_irq[52] = rll_comp_irq[1052];
    assign  comp_irq[53] = rll_comp_irq[1053];
    assign  comp_irq[54] = rll_comp_irq[1054];
    assign  comp_irq[55] = rll_comp_irq[1055];
    assign  comp_irq[56] = rll_comp_irq[1056];
    assign  comp_irq[57] = rll_comp_irq[1057];
    assign  comp_irq[58] = rll_comp_irq[1058];
    assign  comp_irq[59] = rll_comp_irq[1059];
    assign  comp_irq[60] = rll_comp_irq[1060];
    assign  comp_irq[61] = rll_comp_irq[1061];
    assign  comp_irq[62] = rll_comp_irq[1062];
    assign  comp_irq[63] = rll_comp_irq[1063];
    assign  comp_irq[64] = rll_comp_irq[1064];
    assign  comp_irq[65] = rll_comp_irq[1065];
    assign  comp_irq[66] = rll_comp_irq[1066];
    assign  comp_irq[67] = rll_comp_irq[1067];
    assign  comp_irq[68] = rll_comp_irq[1068];
    assign  comp_irq[69] = rll_comp_irq[1069];
    assign  comp_irq[70] = rll_comp_irq[1070];
    assign  comp_irq[71] = rll_comp_irq[1071];
    assign  comp_irq[72] = rll_comp_irq[1072];
    assign  comp_irq[73] = rll_comp_irq[1073];
    assign  comp_irq[74] = rll_comp_irq[1074];
    assign  comp_irq[75] = rll_comp_irq[1075];
    assign  comp_irq[76] = rll_comp_irq[1076];
    assign  comp_irq[77] = rll_comp_irq[1077];
    assign  comp_irq[78] = rll_comp_irq[1078];
    assign  comp_irq[79] = rll_comp_irq[1079];
    assign  comp_irq[80] = rll_comp_irq[1080];
    assign  comp_irq[81] = rll_comp_irq[1081];
    assign  comp_irq[82] = rll_comp_irq[1082];
    assign  comp_irq[83] = rll_comp_irq[1083];
    assign  comp_irq[84] = rll_comp_irq[1084];
    assign  comp_irq[85] = rll_comp_irq[1085];
    assign  comp_irq[86] = rll_comp_irq[1086];
    assign  comp_irq[87] = rll_comp_irq[1087];
    assign  comp_irq[88] = rll_comp_irq[1088];
    assign  comp_irq[89] = rll_comp_irq[1089];
    assign  comp_irq[90] = rll_comp_irq[1090];
    assign  comp_irq[91] = rll_comp_irq[1091];
    assign  comp_irq[92] = rll_comp_irq[1092];
    assign  comp_irq[93] = rll_comp_irq[1093];
    assign  comp_irq[94] = rll_comp_irq[1094];
    assign  comp_irq[95] = rll_comp_irq[1095];
    assign  comp_irq[96] = rll_comp_irq[1096];
    assign  comp_irq[97] = rll_comp_irq[1097];
    assign  comp_irq[98] = rll_comp_irq[1098];
    assign  comp_irq[99] = rll_comp_irq[1099];
    assign  comp_irq[100] = rll_comp_irq[1100];
    assign  comp_irq[101] = rll_comp_irq[1101];
    assign  comp_irq[102] = rll_comp_irq[1102];
    assign  comp_irq[103] = rll_comp_irq[1103];
    assign  comp_irq[104] = rll_comp_irq[1104];
    assign  comp_irq[105] = rll_comp_irq[1105];
    assign  comp_irq[106] = rll_comp_irq[1106];
    assign  comp_irq[107] = rll_comp_irq[1107];
    assign  comp_irq[108] = rll_comp_irq[1108];
    assign  comp_irq[109] = rll_comp_irq[1109];
    assign  comp_irq[110] = rll_comp_irq[1110];
    assign  comp_irq[111] = rll_comp_irq[1111];


    assign  comp_irq[112] = rll_comp_irq[2000];
    assign  comp_irq[113] = rll_comp_irq[2001];
    assign  comp_irq[114] = rll_comp_irq[2002];
    assign  comp_irq[115] = rll_comp_irq[2003];
    assign  comp_irq[116] = rll_comp_irq[2004];
    assign  comp_irq[117] = rll_comp_irq[2005];
    assign  comp_irq[118] = rll_comp_irq[2006];
    assign  comp_irq[119] = rll_comp_irq[2007];
    assign  comp_irq[120] = rll_comp_irq[2008];
    assign  comp_irq[121] = rll_comp_irq[2009];
    assign  comp_irq[122] = rll_comp_irq[2010];
    assign  comp_irq[123] = rll_comp_irq[2011];
    assign  comp_irq[124] = rll_comp_irq[2012];
    assign  comp_irq[125] = rll_comp_irq[2013];
    assign  comp_irq[126] = rll_comp_irq[2014];
    assign  comp_irq[127] = rll_comp_irq[2015];
    assign  comp_irq[128] = rll_comp_irq[2016];
    assign  comp_irq[129] = rll_comp_irq[2017];
    assign  comp_irq[130] = rll_comp_irq[2018];
    assign  comp_irq[131] = rll_comp_irq[2019];
    assign  comp_irq[132] = rll_comp_irq[2020];
    assign  comp_irq[133] = rll_comp_irq[2021];
    assign  comp_irq[134] = rll_comp_irq[2022];
    assign  comp_irq[135] = rll_comp_irq[2023];
    assign  comp_irq[136] = rll_comp_irq[2024];
    assign  comp_irq[137] = rll_comp_irq[2025];
    assign  comp_irq[138] = rll_comp_irq[2026];
    assign  comp_irq[139] = rll_comp_irq[2027];
    assign  comp_irq[140] = rll_comp_irq[2028];
    assign  comp_irq[141] = rll_comp_irq[2029];
    assign  comp_irq[142] = rll_comp_irq[2030];
    assign  comp_irq[143] = rll_comp_irq[2031];
    assign  comp_irq[144] = rll_comp_irq[2032];
    assign  comp_irq[145] = rll_comp_irq[2033];
    assign  comp_irq[146] = rll_comp_irq[2034];
    assign  comp_irq[147] = rll_comp_irq[2035];
    assign  comp_irq[148] = rll_comp_irq[2036];
    assign  comp_irq[149] = rll_comp_irq[2037];
    assign  comp_irq[150] = rll_comp_irq[2038];
    assign  comp_irq[151] = rll_comp_irq[2039];
    assign  comp_irq[152] = rll_comp_irq[2040];
    assign  comp_irq[153] = rll_comp_irq[2041];
    assign  comp_irq[154] = rll_comp_irq[2042];
    assign  comp_irq[155] = rll_comp_irq[2043];
    assign  comp_irq[156] = rll_comp_irq[2044];
    assign  comp_irq[157] = rll_comp_irq[2045];
    assign  comp_irq[158] = rll_comp_irq[2046];
    assign  comp_irq[159] = rll_comp_irq[2047];
    assign  comp_irq[160] = rll_comp_irq[2048];
    assign  comp_irq[161] = rll_comp_irq[2049];
    assign  comp_irq[162] = rll_comp_irq[2050];
    assign  comp_irq[163] = rll_comp_irq[2051];
    assign  comp_irq[164] = rll_comp_irq[2052];
    assign  comp_irq[165] = rll_comp_irq[2053];
    assign  comp_irq[166] = rll_comp_irq[2054];
    assign  comp_irq[167] = rll_comp_irq[2055];
    assign  comp_irq[168] = rll_comp_irq[2056];
    assign  comp_irq[169] = rll_comp_irq[2057];
    assign  comp_irq[170] = rll_comp_irq[2058];
    assign  comp_irq[171] = rll_comp_irq[2059];
    assign  comp_irq[172] = rll_comp_irq[2060];
    assign  comp_irq[173] = rll_comp_irq[2061];
    assign  comp_irq[174] = rll_comp_irq[2062];
    assign  comp_irq[175] = rll_comp_irq[2063];
    assign  comp_irq[176] = rll_comp_irq[2064];
    assign  comp_irq[177] = rll_comp_irq[2065];
    assign  comp_irq[178] = rll_comp_irq[2066];
    assign  comp_irq[179] = rll_comp_irq[2067];
    assign  comp_irq[180] = rll_comp_irq[2068];
    assign  comp_irq[181] = rll_comp_irq[2069];
    assign  comp_irq[182] = rll_comp_irq[2070];
    assign  comp_irq[183] = rll_comp_irq[2071];
    assign  comp_irq[184] = rll_comp_irq[2072];
    assign  comp_irq[185] = rll_comp_irq[2073];
    assign  comp_irq[186] = rll_comp_irq[2074];
    assign  comp_irq[187] = rll_comp_irq[2075];
    assign  comp_irq[188] = rll_comp_irq[2076];
    assign  comp_irq[189] = rll_comp_irq[2077];
    assign  comp_irq[190] = rll_comp_irq[2078];
    assign  comp_irq[191] = rll_comp_irq[2079];
    assign  comp_irq[192] = rll_comp_irq[2080];
    assign  comp_irq[193] = rll_comp_irq[2081];
    assign  comp_irq[194] = rll_comp_irq[2082];
    assign  comp_irq[195] = rll_comp_irq[2083];
    assign  comp_irq[196] = rll_comp_irq[2084];
    assign  comp_irq[197] = rll_comp_irq[2085];
    assign  comp_irq[198] = rll_comp_irq[2086];
    assign  comp_irq[199] = rll_comp_irq[2087];
    assign  comp_irq[200] = rll_comp_irq[2088];
    assign  comp_irq[201] = rll_comp_irq[2089];
    assign  comp_irq[202] = rll_comp_irq[2090];
    assign  comp_irq[203] = rll_comp_irq[2091];
    assign  comp_irq[204] = rll_comp_irq[2092];
    assign  comp_irq[205] = rll_comp_irq[2093];
    assign  comp_irq[206] = rll_comp_irq[2094];
    assign  comp_irq[207] = rll_comp_irq[2095];
    assign  comp_irq[208] = rll_comp_irq[2096];
    assign  comp_irq[209] = rll_comp_irq[2097];
    assign  comp_irq[210] = rll_comp_irq[2098];
    assign  comp_irq[211] = rll_comp_irq[2099];
    assign  comp_irq[212] = rll_comp_irq[2100];
    assign  comp_irq[213] = rll_comp_irq[2101];
    assign  comp_irq[214] = rll_comp_irq[2102];
    assign  comp_irq[215] = rll_comp_irq[2103];
    assign  comp_irq[216] = rll_comp_irq[2104];
    assign  comp_irq[217] = rll_comp_irq[2105];
    assign  comp_irq[218] = rll_comp_irq[2106];
    assign  comp_irq[219] = rll_comp_irq[2107];
    assign  comp_irq[220] = rll_comp_irq[2108];
    assign  comp_irq[221] = rll_comp_irq[2109];
    assign  comp_irq[222] = rll_comp_irq[2110];
    assign  comp_irq[223] = rll_comp_irq[2111];
    assign  comp_irq[224] = rll_comp_irq[2112];
    assign  comp_irq[225] = rll_comp_irq[2113];
    assign  comp_irq[226] = rll_comp_irq[2114];
    
    assign  comp_irq[227] = rll_comp_irq[2115];
    assign  comp_irq[228] = rll_comp_irq[2116];
    assign  comp_irq[229] = rll_comp_irq[2117];
    assign  comp_irq[230] = rll_comp_irq[2118];
    assign  comp_irq[231] = rll_comp_irq[2119];
    assign  comp_irq[232] = rll_comp_irq[2120];
    assign  comp_irq[233] = rll_comp_irq[2121];
    assign  comp_irq[234] = rll_comp_irq[2122];
    assign  comp_irq[235] = rll_comp_irq[2123];
    assign  comp_irq[236] = rll_comp_irq[2124];
    assign  comp_irq[237] = rll_comp_irq[2125];
    assign  comp_irq[238] = rll_comp_irq[2126];
    assign  comp_irq[239] = rll_comp_irq[2127];
    assign  comp_irq[240] = rll_comp_irq[2128];
    assign  comp_irq[241] = rll_comp_irq[2129];
    assign  comp_irq[242] = rll_comp_irq[2130];
    assign  comp_irq[243] = rll_comp_irq[2131];
    assign  comp_irq[244] = rll_comp_irq[2132];
    assign  comp_irq[245] = rll_comp_irq[2133];
    assign  comp_irq[246] = rll_comp_irq[2134];
    assign  comp_irq[247] = rll_comp_irq[2135];
    assign  comp_irq[248] = rll_comp_irq[2136];
    assign  comp_irq[249] = rll_comp_irq[2137];
    assign  comp_irq[250] = rll_comp_irq[2138];
    assign  comp_irq[251] = rll_comp_irq[2139];
    assign  comp_irq[252] = rll_comp_irq[2140];
    assign  comp_irq[253] = rll_comp_irq[2141];
    assign  comp_irq[254] = rll_comp_irq[2142];
    assign  comp_irq[255] = rll_comp_irq[2143];
    assign  comp_irq[256] = rll_comp_irq[2144];
    assign  comp_irq[257] = rll_comp_irq[2145];
    assign  comp_irq[258] = rll_comp_irq[2146];
    assign  comp_irq[259] = rll_comp_irq[2147];
    assign  comp_irq[260] = rll_comp_irq[2148];
    assign  comp_irq[261] = rll_comp_irq[2149];
    assign  comp_irq[262] = rll_comp_irq[2150];
    assign  comp_irq[263] = rll_comp_irq[2151];
    assign  comp_irq[264] = rll_comp_irq[2152];
    assign  comp_irq[265] = rll_comp_irq[2153];
    assign  comp_irq[266] = rll_comp_irq[2154];
    assign  comp_irq[267] = rll_comp_irq[2155];
    assign  comp_irq[268] = rll_comp_irq[2156];
    assign  comp_irq[269] = rll_comp_irq[2157];
    assign  comp_irq[270] = rll_comp_irq[2158];
    assign  comp_irq[271] = rll_comp_irq[2159];
    assign  comp_irq[272] = rll_comp_irq[2160];
    assign  comp_irq[273] = rll_comp_irq[2161];
    assign  comp_irq[274] = rll_comp_irq[2162];
    assign  comp_irq[275] = rll_comp_irq[2163];
    assign  comp_irq[276] = rll_comp_irq[2164];
    assign  comp_irq[277] = rll_comp_irq[2165];
    assign  comp_irq[278] = rll_comp_irq[2166];
    assign  comp_irq[279] = rll_comp_irq[2167];
    assign  comp_irq[280] = rll_comp_irq[2168];
    assign  comp_irq[281] = rll_comp_irq[2169];
    assign  comp_irq[282] = rll_comp_irq[2170];
    assign  comp_irq[283] = rll_comp_irq[2171];
    assign  comp_irq[284] = rll_comp_irq[2172];
    assign  comp_irq[285] = rll_comp_irq[2173];
    assign  comp_irq[286] = rll_comp_irq[2174];
    assign  comp_irq[287] = rll_comp_irq[2175];
    assign  comp_irq[288] = rll_comp_irq[2176];
    assign  comp_irq[289] = rll_comp_irq[2177];
    assign  comp_irq[290] = rll_comp_irq[2178];
    assign  comp_irq[291] = rll_comp_irq[2179];
    assign  comp_irq[292] = rll_comp_irq[2180];
    assign  comp_irq[293] = rll_comp_irq[2181];
    assign  comp_irq[294] = rll_comp_irq[2182];
    assign  comp_irq[295] = rll_comp_irq[2183];
    assign  comp_irq[296] = rll_comp_irq[2184];
    assign  comp_irq[297] = rll_comp_irq[2185];
    assign  comp_irq[298] = rll_comp_irq[2186];
    assign  comp_irq[299] = rll_comp_irq[2187];
    assign  comp_irq[300] = rll_comp_irq[2188];
    assign  comp_irq[301] = rll_comp_irq[2189];
    assign  comp_irq[302] = rll_comp_irq[2190];
    assign  comp_irq[303] = rll_comp_irq[2191];
    assign  comp_irq[304] = rll_comp_irq[2192];
    assign  comp_irq[305] = rll_comp_irq[2193];
    assign  comp_irq[306] = rll_comp_irq[2194];
    assign  comp_irq[307] = rll_comp_irq[2195];
    assign  comp_irq[308] = rll_comp_irq[2196];
    assign  comp_irq[309] = rll_comp_irq[2197];
    assign  comp_irq[310] = rll_comp_irq[2198];
    assign  comp_irq[311] = rll_comp_irq[2199];
    assign  comp_irq[312] = rll_comp_irq[2200];
    assign  comp_irq[313] = rll_comp_irq[2201];
    assign  comp_irq[314] = rll_comp_irq[2202];
    assign  comp_irq[315] = rll_comp_irq[2203];
    assign  comp_irq[316] = rll_comp_irq[2204];
    assign  comp_irq[317] = rll_comp_irq[2205];
    assign  comp_irq[318] = rll_comp_irq[2206];
    assign  comp_irq[319] = rll_comp_irq[2207];
    assign  comp_irq[320] = rll_comp_irq[2208];
    assign  comp_irq[321] = rll_comp_irq[2209];
    assign  comp_irq[322] = rll_comp_irq[2210];
    assign  comp_irq[323] = rll_comp_irq[2211];  

endmodule