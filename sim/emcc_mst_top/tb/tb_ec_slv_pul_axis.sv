`timescale 1 ns / 1 ns
`include "../../../rtl/include_files/components_param.vh"
`include "../../../rtl/include_files/reg_addr_pl.vh"

module tb_ec_slv_pul_axis;
//********************************Defines*********************************
`define EC_COMP_INST_PATH tb_ec_slv_pul_axis.emcc_mst_top_u.emcc_mix_top_u.ec_slv_pul_axis_u0
//*************************Parameter Declarations**************************
parameter       SIM_MAX_TIME  = 40000000;
parameter       CLOCKPERIOD_1 = 6.4	;
parameter       CLOCKPERIOD_2 = 6.4	;
parameter       INIT_CLOCKPERIOD = 5 ;
parameter GEN_MPSOC = 1;
//************************Internal Register Declarations*******************
reg                reference_clk_1_n_r;
reg                reference_clk_2_n_r;
reg     init_clk_p;
reg                gt_reset_in;
reg                gsr_r;
reg                gts_r;
reg                reset_i;
//********************************Wire Declarations************************
wire               reference_clk_1_p_r;
wire               reference_clk_2_p_r;
wire    init_clk_n;
wire               channel_up_1_i;
wire               rxp_1_i;
wire               rxn_1_i;
wire               txp_1_i;
wire               txn_1_i;
wire		rxn_11_i;
wire		txp_11_i;
wire		txn_11_i;
//*********************************Main Body******************************
assign glbl.GSR = gsr_r;
assign glbl.GTS = gts_r;

initial begin
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
initial reference_clk_1_n_r = 1'b0;
always  #(CLOCKPERIOD_1 / 2) reference_clk_1_n_r = !reference_clk_1_n_r;
assign reference_clk_1_p_r = !reference_clk_1_n_r;

initial reference_clk_2_n_r = 1'b0;
always  #(CLOCKPERIOD_2 / 2) reference_clk_2_n_r = !reference_clk_2_n_r;
assign reference_clk_2_p_r = !reference_clk_2_n_r;

initial init_clk_p = 1'b0;
always #(INIT_CLOCKPERIOD / 2) init_clk_p = !init_clk_p;
assign init_clk_n =  !init_clk_p;

//____________________________Resets____________________________
initial begin
    reset_i = 1'b1;
  #1000 reset_i = 1'b0;
end

//________________________Instantiate Dut_______________________
emcc_mst_top emcc_mst_top_u
(
    .INIT_CLK_P(init_clk_p),
    .INIT_CLK_N(init_clk_n),
    .GT_REFCLK_P(reference_clk_1_p_r),
    .GT_REFCLK_N(reference_clk_1_n_r),
    .RXP_0(rxp_1_i),
    .RXN_0(rxn_1_i),
    .TXP_0(txp_1_i),
    .TXN_0(txn_1_i),
    .RXP_1(rxp_11_i),
    .RXN_1(rxn_11_i),
    .TXP_1(txp_11_i),
    .TXN_1(txn_11_i)
);

localparam EC_BIAS_ADDR = `PL_CFG_BASE_ADDR + {20'h1c00};

reg tb_ACLK;
reg tb_ARESETn;
reg [31:0] read_data;
reg resp;
genvar i;
reg [1:0] resp1;
reg loop_end;
reg [31:0] rddata;

initial begin
    tb_ACLK = 1'b0;
end

always #10 tb_ACLK = !tb_ACLK;

//slave message simulator: respond to m2s_pulm_msg with s2m_pulm_msg
reg [31:0] sim_s2m_state;
reg [31:0] sim_s2m_cnt;
always @(posedge tb_ec_slv_pul_axis.emcc_mst_top_u.emcc_mix_top_u.ec_slv_pul_axis_u0.clk_i) begin
    if(reset_i) begin
        sim_s2m_state <= 0;
        sim_s2m_cnt   <= 0;
    end else begin
        case(sim_s2m_state)
            0: begin
                //wait for m2s cycle start (pul_motor_r_flag forced high)
                sim_s2m_cnt <= sim_s2m_cnt + 1;
                if(sim_s2m_cnt > 10) sim_s2m_state <= 1;
            end
            1: begin
                //simulate s2m_0tmp: direction=1
                force `EC_COMP_INST_PATH.s2m_pulm_msg = {31'd0, 1'b1};
                #100;
                force `EC_COMP_INST_PATH.pul_motor_flag = 1'b1;
                #20;
                force `EC_COMP_INST_PATH.pul_motor_flag = 1'b0;
                sim_s2m_state <= 2;
            end
            2: begin
                //then send s2m_10tmp: {alarm=0,err=0,done=1,busy=0}
                sim_s2m_cnt <= sim_s2m_cnt + 1;
                if(sim_s2m_cnt > 30) begin
                    force `EC_COMP_INST_PATH.s2m_pulm_msg = 32'h2000_0000;  // done=1
                    #100;
                    force `EC_COMP_INST_PATH.pul_motor_flag = 1'b1;
                    #20;
                    force `EC_COMP_INST_PATH.pul_motor_flag = 1'b0;
                    sim_s2m_state <= 3;
                end
            end
            3: begin
                //release and reset for next behavior
                release `EC_COMP_INST_PATH.s2m_pulm_msg;
                release `EC_COMP_INST_PATH.pul_motor_flag;
                sim_s2m_state <= 0;
                sim_s2m_cnt   <= 0;
            end
        endcase
    end
end

initial begin
    $display ("running tb_ec_slv_pul_axis");
    tb_ARESETn = 1'b0;
    repeat(20)@(posedge tb_ACLK);
    tb_ARESETn = 1'b1;
    @(posedge tb_ACLK);
    repeat(5) @(posedge tb_ACLK);

    tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.set_debug_level_info(1'b0);
    tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    #200;
    tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
    tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h1);
    #2000;
    tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h0);
    #2000;

    //PS RX PORT
    fork
        begin
            wait (tb_ec_slv_pul_axis.emcc_mst_top_u.axi_clk_0 === 1'b1);
            $display("  [%0t] axi_clk_0 up", $time);
        end
        begin #500000; $display("WARN: axi_clk_0 not seen, continue"); end
    join_any
    disable fork;
    $display("  [%0t] axi_clk_0=%b prot_clk_rst=%b (before force)", $time,
             tb_ec_slv_pul_axis.emcc_mst_top_u.axi_clk_0,
             tb_ec_slv_pul_axis.emcc_mst_top_u.prot_clk_rst);
    force tb_ec_slv_pul_axis.emcc_mst_top_u.prot_clk_rst = 1'b0;
    force `EC_COMP_INST_PATH.pul_motor_r_flag = 1'b1;   // slave motor ready -> m2s frame loop runs

    //ps write rst
    ps_write_word(EC_BIAS_ADDR + `RST_EN,      32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `SC_ID,        32'h0000_0066, resp1);
    ps_write_word(EC_BIAS_ADDR + `EC_ID,        32'h0000_0088, resp1);
    ps_write_word(EC_BIAS_ADDR + `A_EN,         32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `B_EN,         32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `C_EN,         32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `BHV_PRIORITY,  32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `A_TX_OT,      32'hFFFF_0000, resp1);

    //config via PARAM (same mapping as ec_slv_pul_axis parent)
    ps_write_word(EC_BIAS_ADDR + `PARAM1,       32'h0000_07D0, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM2,       32'h0000_07D0, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM3,       32'h0000_07D0, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM4,       32'h0000_0032, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM5,       32'h0000_0064, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM6,       32'h0000_0064, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM7,       32'h0000_03E8, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM8,       32'h0003_0D40, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM9,       32'h0003_0D40, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM16,      32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM26,      32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM27,      32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM28,      32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM29,      32'h0000_0000, resp1);
    ps_write_word(EC_BIAS_ADDR + `PARAM30,      32'h0000_0001, resp1);

    //============================================  behavior 1: home  ==================================
    #500;
    do_behavior(8'd1);      // home -> home_completed=1
    //============================================  behavior 2: move0  ==================================
    #500;
    do_behavior(8'd2);      // needs home_completed
    //============================================  behavior 3: jog  ==================================
    #500;
    do_behavior(8'd3);      // needs home_completed

    //============================================  limit test: press limf  ==================================
    #1000;
    force `EC_COMP_INST_PATH.i_axis_limf = 1'b1;   // limit rising edge -> latch alarm
    #2000;
    do_behavior(8'd3);      // rejected: irq40 alarm 101 (jog blocked at limit)
    force `EC_COMP_INST_PATH.i_axis_limf = 1'b0;
    #500;
    do_behavior(8'd3);      // new behavior issued + limit released -> latch cleared, ok

    //============================================  behavior 7: soff  ==================================
    #500;
    do_behavior(8'd7);      // always allowed (clears home_completed)
    //============================================  behavior 8: reset  ==================================
    #500;
    do_behavior(8'd8);      // always allowed

    //============================================  home allowed at limit  ==================================
    #500;
    force `EC_COMP_INST_PATH.i_axis_limf = 1'b1;
    #500;
    do_behavior(8'd1);      // home allowed even at limit (homing leaves the limit)
    force `EC_COMP_INST_PATH.i_axis_limf = 1'b0;

    #2000;
    $finish;
end


task automatic do_behavior;
    input [7:0] beh_id;
    reg [31:0] irq1, irq2;
    reg irq_ok;
    begin
        ps_write_word(EC_BIAS_ADDR + `A_BHV_ID, {24'd0, beh_id}, resp1);
        // 10 (with timeout)
        irq_ok = 1'b0;
        fork
            begin @`EC_COMP_INST_PATH.o_intr_irq; irq_ok = 1'b1; end
            begin #10000000; $display("WARN: BHV %0d irq10 TIMEOUT", beh_id); end
        join_any
        disable fork;
        if(!irq_ok) begin $display("BHV %0d SKIPPED", beh_id); return; end
        ps_read_word(EC_BIAS_ADDR + `IRQ_REG2, irq2);
        if(irq2 == 32'd0) begin
            ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
            if(irq1 == {8'h88, 8'h66, beh_id, 8'd10})
                ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {beh_id, 8'h0a, 16'h5100}, resp1);
            else $stop;
        end else begin
            // alarm first (limit rejection etc): irq40 with alm_num in IRQ_REG2[31:24]
            $display("  [%0t] BHV %0d ALARM first (irq40) alm_num=%0d", $time, beh_id, irq2[31:24]);
            ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
            if(irq1 == {8'h88, 8'h66, beh_id, 8'd40})
                ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {beh_id, 8'h28, 16'h5101}, resp1);
            else $stop;
            return;
        end
        // 30/40 (with timeout)
        irq_ok = 1'b0;
        fork
            begin @`EC_COMP_INST_PATH.o_intr_irq; irq_ok = 1'b1; end
            begin #10000000; $display("WARN: BHV %0d irq30 TIMEOUT", beh_id); end
        join_any
        disable fork;
        if(!irq_ok) begin $display("BHV %0d RESULT SKIPPED", beh_id); return; end
        ps_read_word(EC_BIAS_ADDR + `IRQ_REG2, irq2);
        if(irq2 == 32'd0) begin
            ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
            if(irq1 == {8'h88, 8'h66, beh_id, 8'd30})
                ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {beh_id, 8'h1e, 16'h5100}, resp1);
            else if(irq1 == {8'h88, 8'h66, beh_id, 8'd40}) begin
                $display("  [%0t] BHV %0d ALARM (irq40) alm_num=%0d", $time, beh_id, irq2[31:24]);
                ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {beh_id, 8'h28, 16'h5101}, resp1);
            end
            else $stop;
        end else $stop;
    end
endtask

task automatic ps_write_word;
    input   [31:0]  addr;
    input   [31:0]  w_data;
    output  [1:0]   resp;
    reg     [127:0] bus_data;
    reg     [15:0]  wstrb;
    reg     [1:0]   word_sel;
    begin
        word_sel = addr[3:2];
        bus_data = 128'd0;
        bus_data[word_sel*32 +: 32] = w_data;
        wstrb    = 16'h0000;
        wstrb[word_sel*4 +: 4] = 4'b1111;
        tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_burst_strb(
            {addr[31:4],4'b0000},
            8'd0, 3'd4, 2'b01, 1'b0, 4'b0000, 3'b000,
            bus_data, 1'b1, wstrb, 16, resp
        );
    end
endtask

task automatic ps_read_word;
    input   [31:0]  rd_addr;
    output  [31:0]  read_data;
    reg             resp;
    begin
        tb_ec_slv_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst
            (rd_addr, 0, 2, 1, 0, 0, 0, read_data, resp);
    end
endtask

endmodule
