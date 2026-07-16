`timescale 1 ns / 100 ps
`include  "base_addr.vh"
`include  "para_reg_addr.vh"
`include  "depot_addr_map.vh"
`include  "reg_addr_pl.vh"
`include  "globe_includes.vh"
`include  "components_param.vh"

module aurora_8b10b_0_TB;

    //*************************Parameter Declarations**************************

    parameter       SIM_MAX_TIME     = 9500000;    //To quit the simulation
    //125.0MHz GT Reference clock
    parameter       CLOCKPERIOD_1    = 6.4;
    parameter       CLOCKPERIOD_2    = 6.4;
    //parameter       CLOCKPERIOD_1 = 8.0;
    //parameter       CLOCKPERIOD_2 = 8.0;
    parameter       INIT_CLOCKPERIOD = 5;          // Board/System Clock

    parameter       GEN_MPSOC        = 1;

    //************************Internal Register Declarations*****************************

    //Freerunning Clock
    reg             reference_clk_1_n_r;
    reg             reference_clk_2_n_r;
    reg             init_clk_p;

    //Global signals
    reg             gt_reset_in;
    reg             gsr_r;
    reg             gts_r;
    reg             reset_i;

    //********************************Wire Declarations**********************************

    //Freerunning Clock
    wire            reference_clk_1_p_r;
    wire            reference_clk_2_p_r;

    wire            init_clk_n;

    //Dut1
    //Error Detection Interface
    //Status
    wire            channel_up_1_i;

    //GT Serial I/O
    wire            rxp_1_i;
    wire            rxn_1_i;

    wire            txp_1_i;
    wire            txn_1_i;

    // Error signals from the Local Link packet checker

    //Dut2
    //Error Detection Interface
    //Status
    wire            channel_up_2_i;

    //GT Serial I/O
    localparam      SLV_STA_NUM = `SIM_SLV_STA_NUM;

    wire            rxp_1st_i[0:SLV_STA_NUM-1];
    wire            rxn_1st_i[0:SLV_STA_NUM-1];
    wire            txp_1st_i[0:SLV_STA_NUM-1];
    wire            txn_1st_i[0:SLV_STA_NUM-1];

    wire            rxp_2nd_i[0:SLV_STA_NUM-1];
    wire            rxn_2nd_i[0:SLV_STA_NUM-1];
    wire            txp_2nd_i[0:SLV_STA_NUM-1];
    wire            txn_2nd_i[0:SLV_STA_NUM-1];

    // Error signals from the Local Link packet checker

    reg [SLV_STA_NUM-1:0] gen_link_error = 0;
//*********************************Main Body of Code**********************************

    //_________________________Serial Connections________________

    //__________________________Global Signals_____________________________
   
    //Simultate the global reset that occurs after configuration at the beginning
    //of the simulation. Note that both GT smart models use the same global signals.
    assign glbl.GSR = gsr_r;
    assign glbl.GTS = gts_r;

    initial
        begin
            gts_r       = 1'b0;
            gsr_r       = 1'b1;
            gt_reset_in = 1'b1;
            #5000;
            gsr_r       = 1'b0;
            gt_reset_in = 1'b0;
            repeat(10) @(posedge init_clk_p);
            gt_reset_in = 1'b1;
            repeat(10) @(posedge init_clk_p);
            gt_reset_in = 1'b0;
        end

    reg     rs232_rxd_dat = 'd0;
    always begin
        # (20000) rs232_rxd_dat = ~rs232_rxd_dat;
    end

    //____________________________Clocks____________________________

    initial
        reference_clk_1_n_r = 1'b0;

    always 
        #(CLOCKPERIOD_1 / 2) reference_clk_1_n_r = !reference_clk_1_n_r;

    assign reference_clk_1_p_r = !reference_clk_1_n_r;


    initial
        reference_clk_2_n_r = 1'b0;


    always 
        #(CLOCKPERIOD_2 / 2) reference_clk_2_n_r = !reference_clk_2_n_r;

    assign reference_clk_2_p_r = !reference_clk_2_n_r;

    initial
        init_clk_p = 1'b0;


    always 
        #(INIT_CLOCKPERIOD / 2) init_clk_p = !init_clk_p;

    assign init_clk_n =  !init_clk_p;
 
    //____________________________Resets____________________________
   
    initial
    begin
        reset_i = 1'b1;
        #1000 reset_i = 1'b0;
    end
    //________________________Instantiate Dut 1 ________________

    emcc_mst_top emmcc_mst_top_u
    (
        // Status Signals
        .INIT_CLK_P (init_clk_p),
        .INIT_CLK_N (init_clk_n),
        // Clock Signals
        .GT_REFCLK_P(reference_clk_1_p_r),
        .GT_REFCLK_N(reference_clk_1_n_r),
        // GT I/O
        .RXP_0      (rxp_1_i),
        .RXN_0      (rxn_1_i),
        .TXP_0      (txp_1_i),
        .TXN_0      (txn_1_i),
        //=================================
        // GT I/O
        .RXP_1      (rxp_11_i),
        .RXN_1      (rxn_11_i),
        .TXP_1      (txp_11_i),
        .TXN_1      (txn_11_i)
    );

    generate
        genvar j;
        for (j=0; j < SLV_STA_NUM; j=j+1)begin: SLV_STA
            if(j==0)begin
                assign   rxn_1st_i[0]   =   txn_1_i | gen_link_error[0];
                assign   rxp_1st_i[0]   =   txp_1_i | gen_link_error[0];
                assign   rxn_1_i        =   txn_1st_i[0] | gen_link_error[0];
                assign   rxp_1_i        =   txp_1st_i[0] | gen_link_error[0];
            end else begin
                assign  rxn_1st_i[j]    =   txn_2nd_i[j-1] | gen_link_error[j];
                assign  rxp_1st_i[j]    =   txp_2nd_i[j-1] | gen_link_error[j];
                assign  rxn_2nd_i[j-1]  =   txn_1st_i[j] | gen_link_error[j];
                assign  rxp_2nd_i[j-1]  =   txp_1st_i[j] | gen_link_error[j];
            end
            
            emcc_slv_top
            #(
            )
                emmcc_slv_top_u
                (
                //    // Status Signals
                `ifdef SIM_PLATFORM_MST
                    .INIT_CLK_P(init_clk_p),
                    .INIT_CLK_N(init_clk_n),
                `else
                `endif
                    // Clock Signals
                    .GT_REFCLK_P(reference_clk_2_p_r),
                    .GT_REFCLK_N(reference_clk_2_n_r),

                    // GT I/O
                    .RXP_0(rxp_1st_i[j]),
                    .RXN_0(rxn_1st_i[j]),

                    .TXP_0(txp_1st_i[j]),
                    .TXN_0(txn_1st_i[j]),
                //=================================
                    // GT I/O
                    .RXP_1(rxp_2nd_i[j]),
                    .RXN_1(rxn_2nd_i[j]),

                    .TXP_1(txp_2nd_i[j]),
                    .TXN_1(txn_2nd_i[j]),

                    .uart_rtl_0_txd     (),
                    .uart_rtl_0_rxd     (rs232_rxd_dat),
                    .uart_rtl_1_txd     (),
                    .uart_rtl_1_rxd     (0),
//                    .uart_rtl_2_txd     (),
//                    .uart_rtl_2_rxd     (0),
//                    .uart_rtl_3_txd     (),
//                    .uart_rtl_3_rxd     (0),
//                    .uart_rtl_4_txd     (),
//                    .uart_rtl_4_rxd     (0),
//                    .uart_rtl_5_txd     (),
//                    .uart_rtl_5_rxd     (0),
//                    .uart_rtl_6_txd     (),
//                    .uart_rtl_6_rxd     (0),
//                    .uart_rtl_7_txd     (),
//                    .uart_rtl_7_rxd     (0),
//                    .uart_rtl_8_txd     (),
//                    .uart_rtl_8_rxd     (0),

                    .dataout            (),
                    .datain             (64'hfefe_efef_baba_abab+j)
                );
        end
    endgenerate

    assign  rxn_11_i                    =   txn_2nd_i[SLV_STA_NUM-1];
    assign  rxp_11_i                    =   txp_2nd_i[SLV_STA_NUM-1];
    assign  rxn_2nd_i[SLV_STA_NUM-1]    =    txn_11_i;
    assign  rxp_2nd_i[SLV_STA_NUM-1]    =    txp_11_i;


    always @ (posedge channel_up_1_i or posedge channel_up_2_i)
    begin
        if((channel_up_1_i == 1'b1) && (channel_up_2_i == 1'b1))
        begin
            $display("\naurora_8b10b_0_TB : INFO : @Time : %t CHANNEL_UP is asserted in both DUT\n", $time);
            #5000 $display("\naurora_8b10b_0_TB : INFO : Test Completed Successfully\n");
        end
    end

    //Abort the simulation when it reaches to max time limit
    initial begin
        #(SIM_MAX_TIME) $display("\nAURORA_TB : INFO : Reached max. simulation time limit\n");
        //  $finish;
    end

//                          mpsoc platform
    generate
        if(GEN_MPSOC == 1) begin:SIM_MPSOC
            reg tb_ACLK;
            reg tb_ARESETn;
            wire temp_clk;
            wire temp_rstn;
            reg [31:0] read_data;
            wire [7:0] leds;
            reg resp;
			reg	[31:0]	rdata;
            genvar i;

            initial begin
                tb_ACLK = 1'b0;
            end
            
            //------------------------------------------------------------------------
            // Simple Clock Generator
            //------------------------------------------------------------------------
            always #10 tb_ACLK = !tb_ACLK;
               
            initial begin
                $display ("running the tb");
                tb_ARESETn = 1'b0;
                repeat(20)@(posedge tb_ACLK);
                tb_ARESETn = 1'b1;
                @(posedge tb_ACLK);
                repeat(5) @(posedge tb_ACLK);

                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.set_debug_level_info(1'b0);
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
                #200;
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h1);
                #2000 ;  // This delay depends on your clock frequency. It should be at least 16 clock cycles. 
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h0);
                #2000;
                //PS RX PORT
                wait (aurora_8b10b_0_TB.emmcc_mst_top_u.prot_clk_rst == 0)                                                                                                           //
//              aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_from_file("./../../../../../src//hdl/sim_src/ps_tx_depot_init.dat",32'hB000_0000,512* `SIM_SLV_STA_NUM *4, resp);//unit:BUYTE ,so the number of config must be mult 4
//              aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_to_file   ("./../../../../../src//hdl/sim_src/ps_tx_depot_read.dat",32'hB000_0000,4096, resp);
                // AXI transfer width is 32-bit; the length is counted in BYTE units

//                optical_fiber_case0;
                //tst_roller_component;
				
				// PS write reset
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `RST_EN,16,128'hfefe_1011_1012_1013_1014_1015_1016_fefe, resp);
				//	#100 ;
				
				aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_burst_strb
                (
                    `PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `RST_EN,  // start_addr
                    10,                          // len (0 => 1 beat)
                    4,                          // siz = 4 => 16 bytes/beat (128 bits)
                    1,                          // burst = INCR
                    0,                          // lck
                    0,                          // cache
                    0,                          // prot
                    1280'd0,  // data
                    1,                          // strb_en = 1 (enable byte strobes)
                    160'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF,                   // strb: byte lane valid mask
                    4,                          // datasize
                    resp
                );


aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst
	(
    `PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `RST_EN+4,
    0,
    2,    // siz to use for the read
    1,
    0,
    0,
    0,
    rdata,
    resp
);	
			#1000;	
				
				
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `RST_EN+16,16,128'h0010_0011_0012_0013_0014_0015_0016_0017, resp);
				//	#100 ;
				//	
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data
				//	(`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `RST_EN,16, read_data, resp);
				//	#1000 ;
				

				
				
				
				
				 
				//	// write SC_ID
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `SC_ID,4,32'h0000_0066, resp);
				//	#100 ;
				//	 
				//	// write EC_ID
				//	 aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `EC_ID,4,32'h0000_0088, resp);
				//	#100 ;
				//	
				//	// write B_EN (behavior enable)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `B_EN,4,32'h0000_0000, resp);
				//	#100 ;
				//	
				//	// write C_EN (timer enable)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `C_EN,4,32'h0000_0000, resp);
				//	#100 ;
				//	
				//	// ps write A_TX_OT (tx timeout)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `A_TX_OT,4,32'hf000_0000, resp);
				//	#100 ;
				//	
				//	// ps write PARAM1 (signal valid, active low)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `PARAM1,4,32'h0000_0000, resp);
				//	#100 ;
				//	
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `PARAM2,4,32'h0000_0001, resp);
				//	#100 ;
				//	
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data
				//	(`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `PARAM2,4, read_data, resp);
				//	#100 ;
				//	
				//	// set behavior ID = 1
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `A_BHV_ID,4,32'h0000_0001, resp);
				//	#10000 ;
				//	
				//	
				//	//wait_intr
				//	
				//	// ps write result report (value 10)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `A_TX_RSULT_RPT,4,{8'd1,8'd10,8'h51,8'd0}, resp);
				//	#10000 ;
				//	
				//	// ps write result report (value 20)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `A_TX_RSULT_RPT,4,{8'd1,8'd20,8'h51,8'd0}, resp);
				//	#10000 ;
				//	
				//	// ps write result report (value 30)
				//	aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
				//	`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `A_TX_RSULT_RPT,4,{8'd1,8'd30,8'h51,8'd0}, resp);
				//	#10000 ;
				
                $display ("Simulation completed");
//                $stop;
            end

            assign temp_clk = tb_ACLK;
            assign temp_rstn = tb_ARESETn;
            
        end else begin:NO_SIM_MPSOC

        end
    endgenerate

    task    optical_fiber_case0;
        fork
            begin
                //PS DEOPT TRANSACTION
                    wait_all_slv_initial_done;
                if(1)begin
                        ps_cfg_pl_intf_tst_mode(1);//12
                    //first 
                        ps_cfg_trsf_req(1);//16
                        wait_mststa_rcv_tst_dg_done;
                        ps_cfg_trsf_req(0);
    //                //second
                        ps_cfg_trsf_req(1);
                        wait_mststa_rcv_tst_dg_done;
                        ps_cfg_trsf_req(0);
    //                //third
                        ps_cfg_trsf_req(1);
                        wait_mststa_rcv_tst_dg_done;
                        ps_cfg_trsf_req(0);
                end
                #2000 ;
                gen_slv_do_ao_dat;
                ps_cfg_pl_intf_tst_mode(0);
                ps_rd_depot_flag(0);
                #200000;
                ps_rd_depot_flag(1);
                #20000;
                ps_rd_depot_flag(0);
            end
            begin
            end
            begin
                gen_link_error[SLV_STA_NUM-1:0] = 0;
//                #150000 gen_link_error[SLV_STA_NUM-2] = 1;
                #550000  gen_link_error[SLV_STA_NUM-2] = 0;
            end
            begin
                detect_optical_fiber_status;
            end
        join
    endtask

    task    wait_all_slv_initial_done;
        reg [31:0]  read_data;
        reg [31:0]  slv_num;
        reg [5:0]   j;
        reg resp;
        begin
            read_data = 0;
            //check master optical fiber link status
            while   (read_data[1:0] !== 3)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data(`MST_APP_REG_BASE + `LINK_STATUS_ADDR,4, read_data, resp);
                $display ("master station link status is 32'h%x",read_data);
            end
            read_data = 0;
            //wait slave_number update
            while   (read_data == 0)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data(`MST_APP_REG_BASE + `SLV_STA_NUM_ADDR,4, read_data, resp);
                #500;
            end
            slv_num =   read_data;
            $display ("the number of slave station is 32'h%x",slv_num);
            //read the id of all slave station
            for (j = 0; j < slv_num; j=j+1) begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data(`MST_APP_REG_BASE + `CACHE_SLV_ID_BIAS_ADDR + {j,4'h0},4, read_data, resp);
                $display ("the id of 32'h%x slave station is 32'h%x",j, read_data);
            end
        end
    endtask

    task ps_cfg_trsf_req;
        input   work_flag;
        reg resp;
        begin
            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`MST_APP_REG_BASE + `PS_TX_REQ_ADDR,4, work_flag, resp);//ps send request
            if(work_flag)begin
                $display ("PS send tx request signal to PL ");
            end else begin
                $display ("PS clear tx request signal");
            end
        end
    endtask

    task ps_rd_depot_flag;
        input   [31:0]  flag;
        reg resp;
        begin
            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`MST_APP_REG_BASE + `PS_RD_DEPOT_FLAG_ADDR,4, flag, resp);//ps send request
            $display ("PS send tx request signal to PL ");
        end
    endtask

    task ps_cfg_pl_intf_tst_mode;
        input   tst_flag;
        reg resp;
        begin
            if(tst_flag)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`MST_APP_REG_BASE + `MST_APP_MODE_ADDR,4, 32'h0001_0001, resp);
                $display ("PS config pl part to go into test mode");
            end else begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`MST_APP_REG_BASE + `MST_APP_MODE_ADDR,4, 32'h0000_0001, resp);
                $display ("PS config pl part to go into work mode");
            end
        end
    endtask

    task gen_slv_do_ao_dat;
        reg resp;
        begin
            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `GEN_OPT_DAT_BIAS + `SLV1ST_DO_DAT_CFG_ADDR,4, 32'hDEAD_BEAF, resp);
            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `GEN_OPT_DAT_BIAS + `SLV2ND_DO_DAT_CFG_ADDR,4, 32'hBEAF_DEAD, resp);
            $display ("config slave station do data");
        end
    endtask

    task wait_mststa_rcv_tst_dg_done;
        begin
            //aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.wait_interrupt(4'h8, read_data);
            wait (aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_mst_app_u.rcv_intf_tst_dg_done)
            $display ("%t, PL has finished once transfer",$time);
        end
    endtask
    
    task    detect_optical_fiber_status;
        reg         resp;
        reg [15:0]  read_data;
        begin
            wait(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_mst_app_u.mst_app_cfg_u.app_err_flag)
            $display ("%t, optical fiber transfer data occur one error",$time);
            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data(`MST_APP_REG_BASE + `LINK_STATUS_ADDR,4, read_data, resp);
            $display ("%t, current all slave station link status is 32'h%x",$time,read_data);
            wait(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_mst_app_u.mst_app_cfg_u.app_err_flag == 0)
            $display ("%t, all station link was recover",$time);
        end
    endtask
//////////////////////////////////////////////////////////////////
    parameter   SP_COMP_NUM     =   2;
    parameter   COMP_TOTAL_NUM  =   7;

    int COMP_WK_EN_CFG_ADDR[COMP_TOTAL_NUM] = '{
         `PL_CFG_BASE_ADDR + `ROLLER_1034_REG_BIAS + `COMP_WK_EN_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1000_REG_BIAS + `COMP_WK_EN_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1001_REG_BIAS + `COMP_WK_EN_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `COMP_WK_EN_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `COMP_WK_EN_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1004_REG_BIAS + `COMP_WK_EN_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1005_REG_BIAS + `COMP_WK_EN_ADDR
    };

    int CFP_SP_COMP_TOKEN[SP_COMP_NUM] = '{
         `PL_CFG_BASE_ADDR + `ROLLER_1034_REG_BIAS + `PATH_MSG_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1001_REG_BIAS + `PATH_MSG_ADDR
    };

    int CFP_ROLLER_COMP_MODE[SP_COMP_NUM] = '{
         `PL_CFG_BASE_ADDR + `ROLLER_1034_REG_BIAS + `PS_CFG_WK_MODE_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1001_REG_BIAS + `PS_CFG_WK_MODE_ADDR
    };

    int CFP_END_ROLLER_COMP_MODE[SP_COMP_NUM] = '{
         `PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `PS_CFG_WK_MODE_ADDR
        ,`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `PS_CFG_WK_MODE_ADDR
    };

`define ROLLER_1034_PATH        aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_mix_top_u.ec_1di_check_u0
`define ROLLER_1002_PATH        aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_mix_top_u.ec_1di_check_u0
//`define ROLLER_1003_PATH        aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_1003_u

   //task tst_roller_component;
   //    begin
   //        roller_tst_case0;
   //    end
   //endtask


    //task automatic roller_tst_case0;
    //    begin
    //        ps_en_all_roller_comp;
    //        ps_all_roller_comp_mode;
    //        ps_all_end_roller_comp_mode;
    //        fork
    //            pl_part_task;
    //            ps_part_task;
    //        join
    //    end
    //endtask

   //task pl_part_task;
   //    fork
// //          gen_comp_error_for_roller_sp0;
// //          gen_comp_error_for_roller_mp0;
// //          gen_comp_error_for_roller_ep0;
   //        gen_indone_for_roller_sp0;
   //        gen_indone_for_roller_mp0;
   //        gen_indone_for_roller_ep0;
   //    join
   //endtask

    //task ps_part_task;
    //    begin
    //        forever roller_irq_prcs;
    //    end
    //endtask

    task automatic ps_en_all_roller_comp;
        reg resp;
        integer j;
        begin
           for (j = 0; j < COMP_TOTAL_NUM; j=j+1) begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
                    (COMP_WK_EN_CFG_ADDR[j][31:0]),4,32'h0000_0001, resp);
           end
        end
    endtask
    
    task automatic ps_all_roller_comp_mode;
        reg resp;
        integer j;
        begin
           for (j = 0; j < SP_COMP_NUM; j=j+1) begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
                    (CFP_ROLLER_COMP_MODE[j][31:0]),4,32'h0000_0001, resp);
           end
        end
    endtask
    
    task automatic ps_all_end_roller_comp_mode;
        reg resp;
        integer j;
        begin
           for (j = 0; j < SP_COMP_NUM; j=j+1) begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
                    (CFP_END_ROLLER_COMP_MODE[j][31:0]),4,32'h0000_0002, resp);
           end
        end
    endtask

    task automatic ps_cfg_roller_sp_token;
        input   [3:0] j;
        reg resp;
        integer seed_dat;
        begin
            //[31:18]       [17:4]      [3:0]
            //PATH_MSG      TOKEN       COMP_TYPE
            seed_dat = $time;//ps_reg_wr_dat[17:4]
            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(
                CFP_SP_COMP_TOKEN[j][31:0],4,{14'h0,seed_dat[13:0],4'd2}, resp);//irq ack opt
        end
    endtask

    // Temporarily commented out: ROLLER test tasks (invalid hierarchical path)
    /*
    task automatic gen_indone_for_roller_sp0;
        begin
            force   `ROLLER_1034_PATH.dgt_error = 1;
            force   `ROLLER_1034_PATH.mat_arrived = 1;
            force   `ROLLER_1034_PATH.yzqg_up       =   1;
            force   `ROLLER_1034_PATH.yzqg_down     =   1;
            #20000
            //first
            force   `ROLLER_1034_PATH.mat_arrived = 0;
            #1000
            force   `ROLLER_1034_PATH.yzqg_down   = 0;
            repeat(10) @(posedge `ROLLER_1034_PATH.clk);
            force   `ROLLER_1034_PATH.mat_arrived = 1;
            force   `ROLLER_1034_PATH.yzqg_down   = 1;
            //second
        end
    endtask


    task automatic gen_indone_for_roller_mp0;
        begin
            force   `ROLLER_1002_PATH.dgt_error = 1;
            force   `ROLLER_1002_PATH.mat_arrived = 1;
            wait (`ROLLER_1002_PATH.dgt_start == 0);
            repeat(10000) @(posedge `ROLLER_1002_PATH.clk);
            force   `ROLLER_1002_PATH.mat_arrived = 0;
            repeat(10) @(posedge `ROLLER_1002_PATH.clk);
            force   `ROLLER_1002_PATH.mat_arrived = 1;
        end
    endtask
    */

    //task automatic gen_indone_for_roller_ep0;
    //    begin
    //        force   `ROLLER_1003_PATH.dgt_error = 1;
    //        force   `ROLLER_1003_PATH.mat_arrived = 1;
    //        wait (`ROLLER_1003_PATH.dgt_start == 0);
    //        repeat(10000) @(posedge `ROLLER_1003_PATH.clk);
    //        force   `ROLLER_1003_PATH.mat_arrived = 0;
    //        repeat(10) @(posedge `ROLLER_1002_PATH.clk);
    //        force   `ROLLER_1003_PATH.mat_arrived = 1;
    //    end
    //endtask
/*

    task gen_comp_error_for_roller_sp0;
        begin
            force `ROLLER_1034_PATH.roller_comp_u.comp_error   =   1;
            #5000;
            force aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_sp0_u.roller_comp_u.comp_error   =   0;
        end
    endtask

    task gen_comp_error_for_roller_mp0;
        begin
            force aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_1002_u.roller_comp_u.comp_error   =   1;
            #10000
            force aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_1002_u.roller_comp_u.comp_error   =   0;
        end
    endtask

    task gen_comp_error_for_roller_ep0;
        begin
            force aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_ep0_u.roller_comp_u.comp_error   =   1;
            #15000
            force aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_ep0_u.roller_comp_u.comp_error   =   0;
        end
    endtask
*/
    //task roller_irq_prcs;
    //    begin
    //        roller_irq_prcs_sp0;
    //        roller_irq_prcs_mp0;
    //        roller_irq_prcs_ep0;
    //        #600;
    //    end
    //endtask

    task roller_irq_prcs_sp0;
        reg resp;
        reg [31:0]  read_data;
        begin
            if(`ROLLER_1034_PATH.o_intr_irq)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_1034_REG_BIAS + `INT_TYPE_ADDR,4,read_data, resp);
                    $display ("%t, read the interrupt type of roller 1034",$time);
                if(read_data[7:0] == `OUT_CKSF_ERR_EVENT)begin
                    $display ("%t, read interrupt type is OUT_CKSF_ERR_EVENT from sp0",$time);
                end else if (read_data[7:0] == `SCAN_TOKEN_EVENT)begin
                    $display ("%t, start point component request one token from PS",$time);
                end else if (read_data[7:0] == `IN_BEH_SUC_EVENT)begin
                    ps_cfg_roller_sp_token(0);
                    $display ("%t, start point component request one token from PS",$time);
                end else if (read_data[7:0] == `OUT_BEH_ERR_EVENT)begin
                    $display ("%t, read interrupt type is OUT_BEH_ERR_EVENT from sp0",$time);
                end
//                if(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_1034_u.roller_comp_u.comp_error == 0)begin
//                    ps_cfg_roller_sp_token(0);
//                end
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_1034_REG_BIAS + `INT_ACK_ADDR,4,9, resp);//irq ack opt
            end
        end
    endtask

    task roller_irq_prcs_mp0;
        reg resp;
        reg [31:0]  read_data;
        begin
            if(`ROLLER_1002_PATH.o_intr_irq)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `INT_TYPE_ADDR,4,read_data, resp);
                    $display ("%t, read the interrupt type of roller 1002",$time);
                if(read_data[7:0] == `IN_CKSF_ERR_EVENT)begin
                    $display ("%t, read interrupt type is IN_CKSF_ERR_EVENT from mp0",$time);
                end else if (read_data[7:0] == `IN_BEH_SUC_EVENT)begin
                    $display ("%t, 1002 component request one token from PS",$time);
                end else if (read_data[7:0] == `OUT_CKSF_ERR_EVENT)begin

                end
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `INT_ACK_ADDR,4,9, resp);//irq ack opt
            end
        end
    endtask

/*
    task roller_irq_prcs_sp1;
        reg resp;
        reg [31:0]  read_data;
        begin
            if(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_sp1_u.roller_comp_u.irq_prcs_busy)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_SP1_REG_BIAS + `INT_TYPE_ADDR,4,read_data, resp);
                if(read_data == `OUT_CKSF_ERR_EVENT)begin
                    $display ("%t, read interrupt type is OUT_CKSF_ERR_EVENT from sp0",$time);
                end else if (read_data == `OUT_BEH_ERR_EVENT)begin
                    $display ("%t, read interrupt type is OUT_BEH_ERR_EVENT from sp0",$time);
                end
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_SP1_REG_BIAS + `INT_ACK_ADDR,4,read_data, resp);//irq ack opt
                if(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_sp1_u.roller_comp_u.comp_error == 0)begin
                    ps_cfg_roller_sp_token(1);
                end
                #100;//wait deassert irq_prcs_busy
            end
        end
    endtask

    task roller_irq_prcs_sp2;
        reg resp;
        reg [31:0]  read_data;
        begin
            if(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_sp2_u.roller_comp_u.irq_prcs_busy)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_SP2_REG_BIAS + `INT_TYPE_ADDR,4,read_data, resp);
                if(read_data == `OUT_CKSF_ERR_EVENT)begin
                    $display ("%t, read interrupt type is OUT_CKSF_ERR_EVENT from sp0",$time);
                end else if (read_data == `OUT_BEH_ERR_EVENT)begin
                    $display ("%t, read interrupt type is OUT_BEH_ERR_EVENT from sp0",$time);
                end
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_SP2_REG_BIAS + `INT_ACK_ADDR,4,read_data, resp);//irq ack opt
                if(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_sp2_u.roller_comp_u.comp_error == 0)begin
                    ps_cfg_roller_sp_token(2);
                end
                #100;//wait deassert irq_prcs_busy
            end
        end
    endtask

    task roller_irq_prcs_mp0;
        reg resp;
        reg [31:0]  read_data_a;
        reg [31:0]  inq_type;
        begin
            if(aurora_8b10b_0_TB.emmcc_mst_top_u.emcc_comp_top_u.roller_1002_u.roller_comp_u.irq_prcs_busy)begin
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `INT_TYPE_ADDR,4,read_data_a, resp);
                inq_type = read_data_a;
                if(read_data_a == `IN_CKSF_ERR_EVENT)begin
                    $display ("%t, read interrupt type is IN_CKSF_ERR_EVENT from mp0",$time);
                end else if (read_data_a == `QUERY_PATH_EVENT)begin
                    aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `CUR_TOKEN_ADDR,4,read_data_a, resp);
                    aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `PATH_MSG_ADDR,4,{30'd0,read_data_a[1:0]}, resp);
                end else if (read_data_a == `OUT_CKSF_ERR_EVENT)begin

                end
                aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_1002_REG_BIAS + `INT_ACK_ADDR,4,inq_type, resp);//irq ack opt
                #100;
//                $display ("%t, ps has processed component's interrupt",$time);
            end
        end
    endtask
*/
    //task roller_irq_prcs_ep0;
    //    reg resp;
    //    reg [31:0]  read_data;
    //    begin
    //        if(`ROLLER_1003_PATH.comp_irq)begin
    //            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_data (`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `INT_TYPE_ADDR,4,read_data, resp);
//  //              $display ("%t, read interrupt type by roller component was 32'h%x",$time, read_data);
    //                $display ("%t, read interrupt from 1003",$time);
    //            if(read_data == `IN_CKSF_ERR_EVENT)begin
    //                $display ("%t, read interrupt type is IN_CKSF_ERR_EVENT from 1003",$time);
    //            end else if (read_data == `IN_BEH_SUC_EVENT)begin
    //                $display ("%t, 1003 component request one token from PS",$time);
//  //                  aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `PATH_MSG_ADDR,4,32'h0000_0002, resp);
    //
    //            end else if (read_data == `OUT_CKSF_ERR_EVENT)begin
    //
    //            end
    //            aurora_8b10b_0_TB.emmcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_data(`PL_CFG_BASE_ADDR + `ROLLER_1003_REG_BIAS + `INT_ACK_ADDR,4,9, resp);//irq ack opt
//  //              $display ("%t, ps has processed component's interrupt",$time);
    //        end
    //    end
    //endtask

endmodule

/*
<task_name>(<comma_separated _inputs>, <comma_separated _outputs>);

   task <task_name>;
      input <input_name>;
      <more_inputs>

      output <output_name>;
      <more_outputs>

      begin
         <statements>;
      end
   endtask
*/
