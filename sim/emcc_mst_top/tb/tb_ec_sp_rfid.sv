
`timescale 1 ns / 100 ps

`include "../../../rtl/include_files/components_param.vh"
`include "../../../rtl/include_files/reg_addr_pl.vh"

module tb_ec_sp_rfid;

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

    //---- 苏培RFID从站模型信号(声明须在DUT例化之前, 避免端口隐式声明) ----
    wire        sp_tx_pin;              // 485物理TX(仅观察)
    wire        sp_de_pin;              // 485方向DE(仅观察)
    reg         sp_rx_line  = 1'b1;     // 485物理RX(tb驱动), 空闲为高

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
    .TXN_1(txn_11_i),
//=================================
    // 苏培RFID 485物理口: 从站模型监听tx, 驱动rx
    .rs485_1_rx (sp_rx_line),
    .rs485_1_tx (sp_tx_pin ),
    .rs485_1_de (sp_de_pin )
);

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
			
			localparam 		REG_BIAS_ADDR	=	20'h03000;

            initial begin
                tb_ACLK = 1'b0;
            end
            
            //------------------------------------------------------------------------
            // Simple Clock Generator
            //------------------------------------------------------------------------
            always #10 tb_ACLK = !tb_ACLK;
               
			   
			   
            initial begin
                tb_ARESETn = 1'b0;
                repeat(20)@(posedge tb_ACLK);
                tb_ARESETn = 1'b1;
                @(posedge tb_ACLK);
                repeat(5) @(posedge tb_ACLK);

                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.set_debug_level_info(1'b0);
                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
                #200;
                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h1);
                #2000 ;  // This delay depends on your clock frequency. It should be at least 16 clock cycles. 
                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h0);
                #2000 ;

                //PS RX PORT
                wait (tb_ec_sp_rfid.emcc_mst_top_u.prot_clk_rst == 0)                                                                                                           //
         //////////////////////       tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_from_file("./../../../../../src//hdl/sim_src/ps_tx_depot_init.dat",32'hB000_0000,512* `SIM_SLV_STA_NUM *4, resp);//unit:BUYTE ,so the number of config must be mult 4
//                tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_to_file   ("./../../../../../src//hdl/sim_src/ps_tx_depot_read.dat",32'hB000_0000,4096, resp);
                //400行对应100个AXI时钟  800对应200个AXI时钟，AXI的总线位宽为32bit,由此可见此处的值以BYTE为单位

//                optical_fiber_case0;
                //tst_roller_component;
				
				//tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.wait_interrupt(4'd0, rddata);

				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `RST_EN,32'h0000_0001,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `SC_ID,32'h0000_0066,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `EC_ID,32'h0000_0088,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `M_ST,32'h0000_0000,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `UNIT_ST,32'h0000_0000,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `M_SAF_ST,32'h0000_0000,resp1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `LINK_M_SAF_ST,32'h0000_0000,resp1);

				//行为超时
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_OT,32'hFFFF_FFFF,resp1);
				
				//写从站地址
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `PARAM16,32'h0000_0006,resp1);

				//写数据
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `PARAM1,32'h1122_3344,resp1);
				
				//写比较数据
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `PARAM2,32'h1122_3344,resp1);
				
				
				loop_end = 1'b0;
				while(loop_end == 1'b0) begin
					ps_read_word(`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `EC_CHA_ST, read_data);
					@(posedge tb_ACLK);
					
					if(read_data == 32'h0000_0000) begin
						loop_end = 1'b1; 
					end
				end
				
				//============================================行为ID=1	成功	==================================
				@(posedge tb_ACLK);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_BHV_ID,32'h0000_0001,resp1);	
				
				//10
				wait (tb_ec_sp_rfid.emcc_mst_top_u.emcc_mix_top_u.ec_sp_rfid_u0.o_intr_irq == 1'b1);
				ps_read_word(`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `IRQ_REG2, read_data);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_RSULT_RPT,32'h010a_5167,resp1);//写事务回应寄存器

				//30/40
				wait (tb_ec_sp_rfid.emcc_mst_top_u.emcc_mix_top_u.ec_sp_rfid_u0.o_intr_irq == 1'b1);
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_RSULT_RPT,32'h011E_5167,resp1);//写事务回应寄存器
				
				//============================================行为ID=2	成功	==================================
				//	loop_end = 1'b0;
				//	while(loop_end == 1'b0) begin
				//		ps_read_word(`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `EC_CHA_ST, read_data);
				//		@(posedge tb_ACLK);
				//		
				//		if(read_data == 32'h0000_0000) begin
				//			loop_end = 1'b1; 
				//		end
				//	end
				//	
				//	#6000;
				//	@(posedge tb_ACLK);
				//	
				//	ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_BHV_ID,32'h0000_0002,resp1);	
				//	
				//	
				//	//10
				//	wait (tb_ec_sp_rfid.emcc_mst_top_u.emcc_mix_top_u.ec_sp_rfid_u0.o_intr_irq == 1'b1);
                //	
				//	ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_RSULT_RPT,32'h020a_5167,resp1);//写事务回应寄存器
				//	
                //	
				//	//30/40
				//	wait (tb_ec_sp_rfid.emcc_mst_top_u.emcc_mix_top_u.ec_sp_rfid_u0.o_intr_irq == 1'b1);
				//	
				//	ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_RSULT_RPT,32'h021E_5167,resp1);//写事务回应寄存器
				
				//============================================行为 3 =============================================
				loop_end = 1'b0;
				while(loop_end == 1'b0) begin
					ps_read_word(`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `EC_CHA_ST, read_data);
					@(posedge tb_ACLK);
					
					if(read_data == 32'h0000_0000) begin
						loop_end = 1'b1; 
					end
				end
				
				#6000;
				@(posedge tb_ACLK);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_BHV_ID,32'h0000_0003,resp1);	
				
				
				//10
				wait (tb_ec_sp_rfid.emcc_mst_top_u.emcc_mix_top_u.ec_sp_rfid_u0.o_intr_irq == 1'b1);

				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_RSULT_RPT,32'h030a_5167,resp1);//写事务回应寄存器
				

				//30/40
				wait (tb_ec_sp_rfid.emcc_mst_top_u.emcc_mix_top_u.ec_sp_rfid_u0.o_intr_irq == 1'b1);
				
				ps_write_word(	`PL_CFG_BASE_ADDR + REG_BIAS_ADDR + `A_TX_RSULT_RPT,32'h031E_5167,resp1);//写事务回应寄存器
				
				
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
        tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_burst_strb(
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
tb_ec_sp_rfid.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst// 2配置的size
					(rd_addr,0,2,1,0,0,0,read_data,resp);
end
endtask


//==========================================================================
// 苏培RFID从站模型(自适应波特率版)
// 监听485物理TX线(rs485_1_tx), 把整帧按100ns细网格采样缓存后离线解码:
//   1) 用"相邻字节起始沿间隔=10bit"自校准精确bit时长 —— 免疫prot_clk实际频率
//      与CLK_FREQ参数不一致造成的波特率偏差(仿真中axi_clk_0可能不是156.25MHz);
//   2) 解码结果须帧CRC校验通过才认为有效;
//   3) 帧尾(连续200µs空闲)后延时(跨过DUT的ST_TURN静默), 按同一bit时长回送应答.
//   行为1(0x10写标签) -> 回显帧, 并记忆写入的4字节
//   行为2(0x03读E000) -> 回UID SP_UID(DUT最终o_uid=SP_UID)
//   行为3(0x03读0000) -> 回行为1写入的4字节
// 波形调试: sp_state 0=等帧 1=采样中 2=发应答中 3=解码失败重同步
//           sp_baud = 实测波特率(读它即可知道DUT实际波特率/prot_clk)
//==========================================================================
localparam  [63:0]  SP_UID       = 64'h1122_3344_5566_7788; // 行为2回的UID(可自行修改)
localparam  real    SP_GRID_NS   = 100.0;     // 细网格采样间隔
localparam  real    SP_IDLE_NS   = 200_000.0; // 帧尾判定: TX连续空闲200µs
localparam  real    SP_NOM_BIT   = 8678.4;    // 标称bit时长(仅作校准搜索范围中心)

reg         sp_smp [0:200000];   // 帧采样缓存(约20ms@100ns, 覆盖低速波特率的长帧)
integer     sp_smp_cnt;
real        sp_bit    = SP_NOM_BIT;  // 实测1bit时长
real        sp_baud   = 115200.0;    // 实测波特率 = 1e9/sp_bit

reg [7:0]   sp_req [0:15];          // 收到的请求帧(波形观察用)
reg [7:0]   sp_rsp [0:15];          // 组装的应答帧(波形观察用)
reg [7:0]   sp_tag [0:3];           // 从站标签存储: 行为1写入, 行为3读回
integer     sp_req_cnt;             // 请求帧字节数
integer     sp_rsp_len;             // 应答帧有效字节数(CRC前)
integer     sp_i;
integer     sp_dec_ok;
reg         sp_got_edge;
reg         sp_crc_ok;
reg [15:0]  sp_crc;
reg [3:0]   sp_state = 4'd0;

// CRC-16/MODBUS: 初值0xFFFF, 多项式0xA001
function automatic [15:0] sp_crc16(input [15:0] c, input [7:0] d);
    integer k;
    begin
        sp_crc16 = c ^ {8'h00, d};
        for (k = 0; k < 8; k = k + 1)
            sp_crc16 = sp_crc16[0] ? ({1'b0, sp_crc16[15:1]} ^ 16'hA001)
                                   : {1'b0, sp_crc16[15:1]};
    end
endfunction

// 从from_idx起找第nth个下降沿(前一样本=1当前=0), 返回网格下标, 找不到返回-1
function automatic integer sp_fall(input integer from_idx, input integer nth);
    integer k, cnt;
    begin
        sp_fall = -1;
        cnt = 0;
        if (from_idx < 1) from_idx = 1;
        for (k = from_idx; k < sp_smp_cnt; k = k + 1) begin
            if (sp_smp[k-1] === 1'b1 && sp_smp[k] === 1'b0) begin
                if (cnt == nth) begin
                    sp_fall = k;
                    k = sp_smp_cnt;
                end
                cnt = cnt + 1;
            end
        end
    end
endfunction

// 采一帧: 从起始位下降沿起按SP_GRID_NS网格采样, 连续空闲SP_IDLE_NS判帧尾
task automatic sp_capture;
    integer run_hi;
    begin
        @(negedge sp_tx_pin);
        sp_smp_cnt = 0;
        run_hi = 0;
        while (run_hi * SP_GRID_NS < SP_IDLE_NS && sp_smp_cnt < 200000) begin
            #SP_GRID_NS;
            sp_smp[sp_smp_cnt] = (sp_tx_pin === 1'b1);
            sp_smp_cnt = sp_smp_cnt + 1;
            if (sp_smp[sp_smp_cnt-1] === 1'b1)
                run_hi = run_hi + 1;
            else
                run_hi = 0;
        end
    end
endtask

// 离线解码采样缓存: 输出ok与sp_req[]/sp_req_cnt, 成功时更新sp_bit/sp_baud
task automatic sp_decode(output integer ok);
    integer e0, ej, j, m, k, found, nstart;
    integer e_idx [0:17];       // 各字节起始沿下标(e_idx[0]=0为帧首)
    real    bit_g, t_g;
    integer lo, hi;
    reg [7:0]  byt;
    reg [7:0]  loc_req [0:15];  // 本地暂存, 仅解码成功才提交到sp_req(避免失败候选污染波形观察)
    begin
        ok = 0;
        // 逐个候选: 假设"第j个下降沿 = 字节1的起始沿"(与帧首相隔正好10bit)
        for (j = 1; j <= 8 && ok == 0; j = j + 1) begin
            ej = sp_fall(1, j);
            if (ej > 0) begin
                bit_g = ej * 1.0 / 10.0;              // 候选bit时长(网格单位)
                if (bit_g * SP_GRID_NS > SP_NOM_BIT * 0.1 &&
                    bit_g * SP_GRID_NS < SP_NOM_BIT * 10.0) begin
                    // 以该bit节拍串联各字节起始沿(预测位置±0.4bit内须有下降沿)
                    e_idx[0] = 0;
                    nstart = 1;
                    for (m = 1; m <= 15; m = m + 1) begin
                        t_g = 10.0 * m * bit_g;
                        lo = $rtoi(t_g - 0.4 * bit_g);
                        hi = $rtoi(t_g + 0.4 * bit_g) + 1;
                        found = -1;
                        for (k = lo; k <= hi; k = k + 1)
                            if (k >= 1 && k < sp_smp_cnt &&
                                sp_smp[k-1] === 1'b1 && sp_smp[k] === 1'b0)
                                found = k;
                        if (found < 0)
                            m = 16;                   // 帧完
                        else begin
                            e_idx[nstart] = found;
                            nstart = nstart + 1;
                        end
                    end
                    if (nstart >= 4 && nstart <= 16) begin
                        // 用首末起始沿精化bit(消除网格量化累积误差)
                        bit_g = (e_idx[nstart-1] - e_idx[0]) * 1.0 / (10.0 * (nstart - 1));
                        // 解码全部字节: bit k中心 = 字节起始 + (1.5+k)bit, bit偏移必须乘bit_g
                        for (m = 0; m < nstart; m = m + 1) begin
                            byt = 8'h00;
                            for (k = 0; k < 8; k = k + 1)
                                byt[k] = sp_smp[$rtoi(e_idx[0] + (10.0*m + 1.5 + k) * bit_g + 0.5)];
                            loc_req[m] = byt;
                        end
                        // 帧CRC校验
                        sp_crc = 16'hFFFF;
                        for (m = 0; m < nstart - 2; m = m + 1)
                            sp_crc = sp_crc16(sp_crc, loc_req[m]);
                        sp_crc_ok = (sp_crc[7:0] == loc_req[nstart-2]) &&
                                    (sp_crc[15:8] == loc_req[nstart-1]);
                        if (sp_crc_ok && (loc_req[1] == 8'h10 || loc_req[1] == 8'h03)) begin
                            ok = 1;
                            for (m = 0; m < nstart; m = m + 1)
                                sp_req[m] = loc_req[m];
                            sp_req_cnt = nstart;
                            sp_bit  = bit_g * SP_GRID_NS;
                            sp_baud = 1.0e9 / sp_bit;
                        end
                    end
                end
            end
        end
    end
endtask

// 在rs485_1_rx上发1字节(8N1, LSB先发, 用实测bit时长)
task automatic sp_put_byte(input [7:0] da);
    integer k;
    begin
        sp_rx_line = 1'b0;          // 起始位
        #sp_bit;
        for (k = 0; k < 8; k = k + 1) begin
            sp_rx_line = da[k];
            #sp_bit;
        end
        sp_rx_line = 1'b1;          // 停止位
        #sp_bit;
    end
endtask

// 等TX线连续静默满SP_IDLE_NS(解码失败后重新对齐帧头用)
task automatic sp_wait_idle;
    begin
        forever begin
            sp_got_edge = 1'b0;
            fork
                begin @(sp_tx_pin); sp_got_edge = 1'b1; end   // 任意跳变都重计
                #SP_IDLE_NS;
            join_any
            disable fork;
            if (sp_got_edge == 1'b0)
                break;
        end
    end
endtask

initial begin : sp_slave_model
    for (sp_i = 0; sp_i < 4; sp_i = sp_i + 1)
        sp_tag[sp_i] = 8'h00;
    sp_req_cnt = 0;
    sp_rsp_len = 0;
    sp_state   = 4'd0;

    // 等TX线进入空闲高电平(复位期间仲裁器强制tx=1)再开始监听, 避开X态假起始位
    wait (sp_tx_pin === 1'b1);

    forever begin
        //---- 采样一帧(阻塞到帧尾+200µs空闲) ----
        sp_state = 4'd0;
        sp_capture;
        sp_state = 4'd1;
        sp_decode(sp_dec_ok);

        //---- 按请求内容组装应答 ----
        sp_rsp_len = 0;
        if (sp_dec_ok != 0) begin
            if (sp_req[1] == 8'h10) begin           // 行为1: 写标签 -> 回显站号+功能码+地址2+数量2
                for (sp_i = 0; sp_i < 6; sp_i = sp_i + 1)
                    sp_rsp[sp_i] = sp_req[sp_i];
                sp_rsp_len = 6;
                // 模拟标签存储: 记住写入的4字节, 供行为3读回
                for (sp_i = 0; sp_i < 4; sp_i = sp_i + 1)
                    sp_tag[sp_i] = sp_req[7 + sp_i];
            end else if (sp_req[1] == 8'h03) begin  // 行为2/3: 读保持寄存器
                sp_rsp[0] = sp_req[0];
                sp_rsp[1] = 8'h03;
                if (sp_req[2] == 8'hE0) begin       // 行为2: 读UID, 回SP_UID共8字节
                    sp_rsp[2] = 8'h08;
                    for (sp_i = 0; sp_i < 8; sp_i = sp_i + 1)
                        sp_rsp[3 + sp_i] = SP_UID[63 - sp_i*8 -: 8];
                    sp_rsp_len = 11;
                end else begin                      // 行为3: 读标签, 回上次写入的4字节
                    sp_rsp[2] = 8'h04;
                    for (sp_i = 0; sp_i < 4; sp_i = sp_i + 1)
                        sp_rsp[3 + sp_i] = sp_tag[sp_i];
                    sp_rsp_len = 7;
                end
            end
        end

        if (sp_rsp_len > 0) begin
            //---- CRC(低字节在前) ----
            sp_crc = 16'hFFFF;
            for (sp_i = 0; sp_i < sp_rsp_len; sp_i = sp_i + 1)
                sp_crc = sp_crc16(sp_crc, sp_rsp[sp_i]);
            sp_rsp[sp_rsp_len]      = sp_crc[7:0];
            sp_rsp[sp_rsp_len + 1]  = sp_crc[15:8];

            //---- 延时跨过DUT的ST_TURN静默(40bit)后发送应答帧 ----
            sp_state = 4'd2;
            if (45.0 * sp_bit > SP_IDLE_NS)
                #(45.0 * sp_bit - SP_IDLE_NS);
            else
                #(2.5 * sp_bit);
            for (sp_i = 0; sp_i < sp_rsp_len + 2; sp_i = sp_i + 1)
                sp_put_byte(sp_rsp[sp_i]);
            sp_state = 4'd0;
        end else begin
            //---- 帧无法识别: 等总线静默后重新等下一帧 ----
            sp_state = 4'd3;
            sp_wait_idle;
        end
    end
end


endmodule
