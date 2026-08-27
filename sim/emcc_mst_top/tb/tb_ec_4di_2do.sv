
`timescale 1 ns / 100 ps
`include "./../../../rtl/include_files/reg_addr_pl.vh"
`include "./../../../rtl/include_files/globe_includes.vh"
`include "./../../../rtl/include_files/components_param.vh"
module tb_ec_4di_2do;

//*************************Parameter Declarations**************************

parameter       SIM_MAX_TIME  = 9500000; //To quit the simulation
    //125.0MHz GT Reference clock
parameter       CLOCKPERIOD_1 = 6.4	;
parameter       CLOCKPERIOD_2 = 6.4	;
//parameter       CLOCKPERIOD_1 = 8.0;
//parameter       CLOCKPERIOD_2 = 8.0;
parameter       INIT_CLOCKPERIOD = 5 ; // Board/System Clock

parameter GEN_MPSOC = 1;
//************************Internal Register Declarations*****************************

    //Freerunning Clock
reg                reference_clk_1_n_r;
reg                reference_clk_2_n_r;
reg     init_clk_p;

    //Global signals
reg                gt_reset_in;
reg                gsr_r;
reg                gts_r;
reg                reset_i;

//********************************Wire Declarations**********************************
   
    //Freerunning Clock        
wire               reference_clk_1_p_r;
wire               reference_clk_2_p_r;         

wire    init_clk_n;
//Dut1

    //Error Detection Interface

    //Status
wire               channel_up_1_i;        

    //GT Serial I/O
wire               rxp_1_i; 
wire               rxn_1_i; 
   
wire               txp_1_i; 
wire               txn_1_i; 


//*********************************Main Body of Code**********************************

    //_________________________Serial Connections________________

    //__________________________Global Signals_____________________________
   
    //Simultate the global reset that occurs after configuration at the beginning
    //of the simulation. Note that both GT smart models use the same global signals.
    assign glbl.GSR = gsr_r;
    assign glbl.GTS = gts_r;

    initial
        begin
            gts_r    = 1'b0;
            gsr_r    = 1'b1;
            gt_reset_in = 1'b1;
            #5000;
            gsr_r    = 1'b0;
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

emcc_mst_top emcc_mst_top_u
(
    // Status Signals
    .INIT_CLK_P(init_clk_p),
    .INIT_CLK_N(init_clk_n),
    // Clock Signals
    .GT_REFCLK_P(reference_clk_1_p_r),
    .GT_REFCLK_N(reference_clk_1_n_r),
    // GT I/O
    .RXP_0(rxp_1_i),
    .RXN_0(rxn_1_i),
    .TXP_0(txp_1_i),
    .TXN_0(txn_1_i),
//=================================
    // GT I/O
    .RXP_1(rxp_11_i),
    .RXN_1(rxn_11_i),
    .TXP_1(txp_11_i),
    .TXN_1(txn_11_i)
);

			localparam	EC_BIAS_ADDR = 20'h2600;


            reg tb_ACLK;
            reg tb_ARESETn;
            wire temp_clk;
            wire temp_rstn;
            reg [31:0] read_data;
            wire [7:0] leds;
            reg resp;
            genvar i;
			reg [1:0]	resp1;
			reg	loop_end;
			
			reg	[31:0]	rddata;

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

                tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.set_debug_level_info(1'b0);
                tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
                #200;
                tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
                tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h1);
                #2000 ;  // This delay depends on your clock frequency. It should be at least 16 clock cycles. 
                tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
                tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h0);
                #2000 ;

                //PS RX PORT
                wait (tb_ec_4di_2do.emcc_mst_top_u.prot_clk_rst == 0)                                                                                                           //
         //////////////////////       tb_ec_1do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_from_file("./../../../../../src//hdl/sim_src/ps_tx_depot_init.dat",32'hB000_0000,512* `SIM_SLV_STA_NUM *4, resp);//unit:BUYTE ,so the number of config must be mult 4
//                tb_ec_1do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_to_file   ("./../../../../../src//hdl/sim_src/ps_tx_depot_read.dat",32'hB000_0000,4096, resp);
                //400行对应100个AXI时钟  800对应200个AXI时钟，AXI的总线位宽为32bit,由此可见此处的值以BYTE为单位

//                optical_fiber_case0;
                //tst_roller_component;
				
				//tb_ec_1do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.wait_interrupt(4'd0, rddata);

				//ps写复位
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `RST_EN,32'h0000_0001,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `SC_ID,32'h0000_0066,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `EC_ID,32'h0000_0088,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_EN,32'h0000_0001,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `B_EN,32'h0000_0000,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `C_EN,32'h0000_0000,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `M_SAF_ST,32'h0000_0000,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `LINK_M_SAF_ST,32'h0000_0001,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `BHV_PRIORITY,32'h0000_0000,resp1);

				//行为超时
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_OT,32'hFFFF_0000,resp1);
				
				loop_end = 1'b0;
				while(loop_end == 1'b0) begin
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `EC_CHA_ST, read_data);
					@(posedge init_clk_p); 
					
					if(read_data == 32'h0000_0000) begin
						loop_end = 1'b1; 
					end
				end
				
				//============================================	行为ID=1	正常	==================================

				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b0011;	
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0001,resp1);	
				
				//10
				//wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				#600;				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h010a_5167,resp1);//写事务回应寄存器
				
				//30 / 40
				//wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				#600;	
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h011E_5167,resp1);//写事务回应寄存器

				
				
				//============================================	行为ID=2		==================================
				
				#6000;
				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b1100;	
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0002,resp1);	
				
				//10
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd2,8'd10})	
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h020a_5167,resp1);//写事务回应寄存器
					else
						$stop;
				end else
					$stop;

				//30 / 40
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd2,8'd30})	//scuss
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h021E_5167,resp1);//写事务回应寄存器
					else if(read_data == {8'h88,8'h66,8'd2,8'd40})//fail
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h0228_5199,resp1);//写事务回应寄存器
				end else
					$stop;
				
				
				//============================================	行为ID=3		==================================
				
				#6000;
				
				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b0011;
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0003,resp1);	
				
				//10
				@(posedge tb_ACLK);
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd3,8'd10})	
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h030a_5167,resp1);//写事务回应寄存器
					else
						$stop;
				end else
					$stop;
				
				
				//30 / 40
				@(posedge tb_ACLK);
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd3,8'd30})	//scuss
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h031E_5167,resp1);//写事务回应寄存器
					else if(read_data == {8'h88,8'h66,8'd3,8'd40})//fail
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h0328_5199,resp1);//写事务回应寄存器
				end else
					$stop;
				
				
				
					//============================================	行为ID=4		==================================
				
				#6000;
				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b0011;	
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0004,resp1);	
				
				//10
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd4,8'd10})	
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h040a_5167,resp1);//写事务回应寄存器
					else
						$stop;
				end else
					$stop;
				
				
				//30 / 40
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd4,8'd30})	//scuss
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h041E_5167,resp1);//写事务回应寄存器
					else if(read_data == {8'h88,8'h66,8'd4,8'd40})//fail
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h0428_5199,resp1);//写事务回应寄存器
				end else
					$stop;
				
				
					//============================================	行为ID=5		==================================
				
				#6000;
				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b1100;	
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0005,resp1);	
				
				//10
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd5,8'd10})	
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h050a_5167,resp1);//写事务回应寄存器
					else
						$stop;
				end else
					$stop;

				//30 / 40
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd5,8'd30})	//scuss
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h051E_5167,resp1);//写事务回应寄存器
					else if(read_data == {8'h88,8'h66,8'd5,8'd40})//fail
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h0528_5199,resp1);//写事务回应寄存器
				end else
					$stop;
				
				
					//============================================	行为ID=6		==================================
				
				#6000;
				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b0011;	
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0006,resp1);	
				
				//10
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd6,8'd10})	
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h060a_5167,resp1);//写事务回应寄存器
					else
						$stop;
				end else
					$stop;

				
				//30 / 40
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd6,8'd30})	//scuss
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h061E_5167,resp1);//写事务回应寄存器
					else if(read_data == {8'h88,8'h66,8'd6,8'd40})//fail
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h0628_5199,resp1);//写事务回应寄存器
				end else
					$stop;
				
				
					//============================================	行为ID=7		==================================
				
				#6000;
				
				tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.di_i_ec_4di_2do = 4'b1100;		
				
				ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_BHV_ID,32'h0000_0007,resp1);	
				
				//10
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd7,8'd10})	
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h070a_5167,resp1);//写事务回应寄存器
					else
						$stop;
				end else
					$stop;

				//30 / 40
				wait (tb_ec_4di_2do.emcc_mst_top_u.emcc_mix_top_u.ec_4di_2do_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG2, read_data);
				if(read_data == 32'd0)	begin	//no alart
					ps_read_word(`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `IRQ_REG1, read_data);
					if(read_data == {8'h88,8'h66,8'd7,8'd30})	//scuss
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h071E_5167,resp1);//写事务回应寄存器
					else if(read_data == {8'h88,8'h66,8'd7,8'd40})//fail
						ps_write_word(	`PL_CFG_BASE_ADDR + EC_BIAS_ADDR + `A_TX_RSULT_RPT,32'h0728_5199,resp1);//写事务回应寄存器
				end else
					$stop;
				
				
				

				
				#2000;
				$stop;
					
            end

            assign temp_clk = tb_ACLK;
            assign temp_rstn = tb_ARESETn;
            
	

task automatic ps_write_word;
    input   [31:0]  addr;       //目标4字节偏移地址(需4字节对齐)
    input   [31:0]  w_data;     //要写入的32bit数据
    output  [1:0]   resp;       //AXI BRESP
    reg     [127:0] bus_data;   //128bit总线数据
    reg     [15:0]  wstrb;      //128bit总线对应的16bit WSTRB
    reg     [1:0]   word_sel;   //选中总线上的哪个word(0~3)
	
    begin
        word_sel = addr[3:2];                           //addr[3:2]决定word在128bit总线中的位置
        bus_data = 128'd0;
        bus_data[word_sel*32 +: 32] = w_data;           //把32bit数据放到对应word槽
        wstrb    = 16'h0000;
        wstrb[word_sel*4 +: 4] = 4'b1111;               //只使能对应4字节通道的WSTRB
        tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_burst_strb(
            {addr[31:4],4'b0000},                       //AWADDR对齐到16字节边界
            8'd0,                                        //len=0(单拍)
            3'd4,                                        //size=4(2^4=16字节/拍,即128bit)
            2'b01,                                       //burst=INCR
            1'b0,                                        //lock
            4'b0000,                                     //cache
            3'b000,                                      //prot
            bus_data,                                    //128bit写数据
            1'b1,                                        //strb_en=1,使用自定义WSTRB
            wstrb,                                       //16bit WSTRB掩码
            16,                                          //datasize=16字节(一整拍)
            resp                                         //BRESP
        );
    end
endtask

task automatic ps_read_word;
	input	[31:0]	rd_addr;
	output	[31:0]	read_data;
	reg				resp;
begin
tb_ec_4di_2do.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst// 2配置的size
					(rd_addr,0,2,1,0,0,0,read_data,resp);
end
endtask	


endmodule
