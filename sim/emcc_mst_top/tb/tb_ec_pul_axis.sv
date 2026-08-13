
`timescale 1 ns / 1 ns
`include "../../../rtl/include_files/components_param.vh"
`include "../../../rtl/include_files/reg_addr_pl.vh"

module tb_ec_pul_axis;
//********************************Defines*********************************
`define EC_COMP_INST_PATH tb_ec_pul_axis.emcc_mst_top_u.emcc_mix_top_u.ec_pul_axis_u0
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

localparam EC_BIAS_ADDR = `PL_CFG_BASE_ADDR + {20'h1a00};

reg tb_ACLK;
reg tb_ARESETn;
reg [1:0] resp1;
reg [31:0] rddata;
reg [31:0] rddata2;

initial begin
    tb_ACLK = 1'b0;
end

always #10 tb_ACLK = !tb_ACLK;

initial begin
    $display ("running tb_ec_pul_axis");
    tb_ARESETn = 1'b0;
    repeat(20)@(posedge tb_ACLK);
    tb_ARESETn = 1'b1;
    @(posedge tb_ACLK);
    repeat(5) @(posedge tb_ACLK);

    tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.set_debug_level_info(1'b0);
    tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    #200;
    tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
    tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h1);
    #2000;
    tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h0);
    #2000;

    //PS RX PORT
    fork
        begin
            wait (tb_ec_pul_axis.emcc_mst_top_u.axi_clk_0 === 1'b1);
            $display("  [%0t] axi_clk_0 up", $time);
        end
        begin #500000; $display("WARN: axi_clk_0 not seen, continue"); end
    join_any
    disable fork;
    $display("  [%0t] axi_clk_0=%b prot_clk_rst=%b (before force)", $time,
             tb_ec_pul_axis.emcc_mst_top_u.axi_clk_0,
             tb_ec_pul_axis.emcc_mst_top_u.prot_clk_rst);
    force tb_ec_pul_axis.emcc_mst_top_u.prot_clk_rst = 1'b0;

    //---- init: common regs ----
    ps_write_word(EC_BIAS_ADDR + `RST_EN,      32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `SC_ID,        32'h0000_0066, resp1);
    ps_write_word(EC_BIAS_ADDR + `EC_ID,        32'h0000_0088, resp1);
    ps_write_word(EC_BIAS_ADDR + `BHV_PRIORITY,  32'h0000_0000, resp1);

    //---- motion params (new register map) ----
    ps_write_word(EC_BIAS_ADDR + `PARAM1,       32'h0000_07D0, resp1);  // spd_max 2000 kpps
    ps_write_word(EC_BIAS_ADDR + `PARAM2,       32'h0000_07D0, resp1);  // acc_max
    ps_write_word(EC_BIAS_ADDR + `PARAM3,       32'h0000_07D0, resp1);  // dec_max
    ps_write_word(EC_BIAS_ADDR + `PARAM5,       32'h0000_07D0, resp1);  // acc 2000
    ps_write_word(EC_BIAS_ADDR + `PARAM33,      32'h0000_03E8, resp1);  // touch_spd 1000
    ps_write_word(EC_BIAS_ADDR + `PARAM34,      32'h0000_07D0, resp1);  // dec 2000
    ps_write_word(EC_BIAS_ADDR + `PARAM35,      32'h0000_0064, resp1);  // spd 100 kpps
    ps_write_word(EC_BIAS_ADDR + `PARAM36,      32'h0000_0064, resp1);  // move target 100 pulses
    ps_write_word(EC_BIAS_ADDR + `PARAM37,      32'h0000_0064, resp1);  // jog step 100 pulses
    ps_write_word(EC_BIAS_ADDR + `PARAM16,      32'h0000_0001, resp1);  // rserv_dir = POS
    ps_write_word(EC_BIAS_ADDR + `PARAM26,      32'h0000_0000, resp1);  // pause req = 0
    ps_write_word(EC_BIAS_ADDR + `PARAM27,      32'h0000_0000, resp1);  // stop req = 0
    ps_write_word(EC_BIAS_ADDR + `PARAM28,      32'h0000_0000, resp1);  // resume req = 0
    ps_write_word(EC_BIAS_ADDR + `PARAM29,      32'h0000_0000, resp1);  // drive reset = 0
    ps_write_word(EC_BIAS_ADDR + `PARAM30,      32'h0000_0001, resp1);  // drive on = 1

    ps_write_word(EC_BIAS_ADDR + `A_TX_OT,      32'hFFFF_0000, resp1);  // A: no timeout
    ps_write_word(EC_BIAS_ADDR + `B_TX_OT,      32'h0000_0064, resp1);  // B: 100s
    ps_write_word(EC_BIAS_ADDR + `A_EN,         32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `B_EN,         32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `C_EN,         32'h0000_0000, resp1);

    #5000;   // let the init one-shot 104 transaction settle

    //============================================  A: beh 1 HOME  ============================
    $display("== A channel: beh 1 HOME ==");
    do_behavior(8'd1);            // org stimulus block below drives i_axis_org
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after HOME: abspos=%d (expect 0)", $time, $signed(rddata));

    //============================================  A: beh 30 GETPOS  ============================
    $display("== A channel: beh 30 GETPOS ==");
    do_behavior(8'd30);

    //============================================  A: beh 2 JOG (+step)  ============================
    $display("== A channel: beh 2 JOG ==");
    do_behavior(8'd2);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after JOG: abspos=%d (expect +100, +-1 profile tolerance)", $time, $signed(rddata));

    //============================================  A: beh 3 MOVE  ============================
    $display("== A channel: beh 3 MOVE to 100 ==");
    do_behavior(8'd3);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after MOVE: abspos=%d (expect 100)", $time, $signed(rddata));

    //============================================  A: beh 20 safe JOG  ============================
    $display("== A channel: beh 20 safe JOG ==");
    do_behavior(8'd20);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after safe JOG: abspos=%d (expect 200)", $time, $signed(rddata));

    //============================================  A: beh 21 safe MOVE  ============================
    $display("== A channel: beh 21 safe MOVE to 100 ==");
    do_behavior(8'd21);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after safe MOVE: abspos=%d (expect 100)", $time, $signed(rddata));

    //============================================  B: beh 100/101 pause+resume during real MOVE  ============================
    $display("== B channel: beh 100 pause / 101 resume during MOVE ==");
    ps_write_word(EC_BIAS_ADDR + `PARAM36, 32'h0000_07D0, resp1);  // target 2000 (1900 pulses to go)
    fire_a_behavior(8'd3);                                          // MOVE runs in background
    #5000;
    ps_write_word(EC_BIAS_ADDR + `PARAM26, 32'h0000_0001, resp1);
    do_b_behavior(8'd100);                                          // pause
    $display("  [%0t] after beh100: b_pause=%b", $time,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_pause);
    // freeze check: abspos must not move while paused
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    #20000;
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata2);
    if(rddata == rddata2)
        $display("PASS: abspos frozen during pause (%d)", $signed(rddata));
    else
        $display("FAIL: abspos moved during pause (%d -> %d)", $signed(rddata), $signed(rddata2));
    ps_write_word(EC_BIAS_ADDR + `PARAM28, 32'h0000_0001, resp1);  // P28 first: else 100 steals P26
    ps_write_word(EC_BIAS_ADDR + `PARAM26, 32'h0000_0001, resp1);
    do_b_behavior(8'd101);                                          // resume
    $display("  [%0t] after beh101: b_pause=%b", $time,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_pause);
    wait_a_result(8'd3, 2000000);                                   // MOVE completes
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after resume+move: abspos=%d (expect 2000)", $time, $signed(rddata));

    //============================================  B: beh 103 stop during real MOVE  ============================
    $display("== B channel: beh 103 stop during MOVE ==");
    ps_write_word(EC_BIAS_ADDR + `PARAM36, 32'h0000_0BB8, resp1);  // target 3000 (1000 pulses to go)
    fire_a_behavior(8'd3);
    #5000;
    ps_write_word(EC_BIAS_ADDR + `PARAM27, 32'h0000_0001, resp1);  // P27 first: else 100 steals P26
    ps_write_word(EC_BIAS_ADDR + `PARAM26, 32'h0000_0001, resp1);
    #3000;                                                          // B txn self-completes
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after beh103 stop: abspos=%d (partial move, real pulses)", $time, $signed(rddata));
    // blind-ACK A: it waits in S_SUCC_30_ACK on the ACK data match, and the
    // arbitrator may be showing B's irq instead of A's
    ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {8'd3, 8'h1e, 16'h5100}, resp1);
    #2000;
    ps_write_word(EC_BIAS_ADDR + `B_TX_RSULT_RPT, {8'd103, 8'h1e, 16'h5100}, resp1); // drop B irq

    //============================================  B: beh 102 drive reset  ============================
    $display("== B channel: beh 102 drive reset ==");
    ps_write_word(EC_BIAS_ADDR + `PARAM29, 32'h0000_0001, resp1);
    do_b_behavior(8'd102);
    ps_write_word(EC_BIAS_ADDR + `PARAM29, 32'h0000_0000, resp1);  // no auto-clear: PS re-arms
    $display("INFO: beh102 done, PARAM29 cleared by PS");

    //============================================  B: beh 105 soff / beh 104 son  ============================
    $display("== B channel: beh 105 soff / beh 104 son ==");
    ps_write_word(EC_BIAS_ADDR + `PARAM30, 32'h0000_0000, resp1);  // drive off -> one-shot 105
    do_b_behavior(8'd105);
    $display("  [%0t] beh105 done, o_dv_son=%b (expect 1=disabled)", $time, `EC_COMP_INST_PATH.o_dv_son);
    ps_write_word(EC_BIAS_ADDR + `PARAM30, 32'h0000_0001, resp1);  // drive on -> one-shot 104
    do_b_behavior(8'd104);
    $display("  [%0t] beh104 done, o_dv_son=%b (expect 0=enabled)", $time, `EC_COMP_INST_PATH.o_dv_son);

    #2000;
    $finish;
end

//HOME org stimulus - independent process (do_behavior's internal forks can't kill it).
//hold org=1 after HOME starts, release so the falling edge finishes the search.
initial begin
    wait(`EC_COMP_INST_PATH.a_bhv_id_r == 8'd1);
    #1000;
    force `EC_COMP_INST_PATH.i_axis_org = 1'b1;
    #200000;
    force `EC_COMP_INST_PATH.i_axis_org = 1'b0;
    $display("  [%0t] org released", $time);
end

//A-channel behavior: trigger + irq10 ACK + wait result (30/40).
//The waits poll the IRQ content so B-channel irq noise is ignored.
task automatic do_behavior;
    input [7:0] beh_id;
    reg [31:0] irq1, irq2;
    reg [7:0] tx;
    reg ok;
    integer t;
    begin
        ps_write_word(EC_BIAS_ADDR + `A_BHV_ID, {24'd0, beh_id}, resp1);
        // wait tx10 (A FSM holds in S_READY_10_ACK until ACK, data stable)
        ok = 1'b0; t = 0;
        while(!ok && t < 10000000) begin
            fork
                begin @(posedge `EC_COMP_INST_PATH.o_intr_irq); end
                begin #10000; end
            join_any
            disable fork;
            t = t + 10000;
            ps_read_word(EC_BIAS_ADDR + `IRQ_REG2, irq2);
            if(irq2 == 32'd0) begin
                ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
                if(irq1 == {8'h88, 8'h66, beh_id, 8'd10}) begin
                    ok = 1'b1;
                    ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {beh_id, 8'h0a, 16'h5100}, resp1);
                end
            end
        end
        if(!ok) begin $display("WARN: BHV %0d irq10 not seen", beh_id); return; end
        wait_a_result(beh_id, 10000000);
    end
endtask

//wait for the A result interrupt (tx 30 or 40) of the given behavior and ACK it
task automatic wait_a_result;
    input [7:0] beh_id;
    input integer timeout;
    reg [31:0] irq1, irq2;
    reg [7:0] tx;
    reg ok;
    integer t;
    begin
        ok = 1'b0; t = 0;
        while(!ok && t < timeout) begin
            fork
                begin @(posedge `EC_COMP_INST_PATH.o_intr_irq); end
                begin #10000; end
            join_any
            disable fork;
            t = t + 10000;
            ps_read_word(EC_BIAS_ADDR + `IRQ_REG2, irq2);
            if(irq2 == 32'd0) begin
                ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
                if(irq1[31:16] == {8'h88, 8'h66} && irq1[15:8] == beh_id &&
                   (irq1[7:0] == 8'd30 || irq1[7:0] == 8'd40)) begin
                    ok = 1'b1;
                    tx = irq1[7:0];
                    ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT,
                                  {beh_id, tx, (tx == 8'd30) ? 16'h5100 : 16'h5101}, resp1);
                    $display("  [%0t] BHV %0d -> %s", $time, beh_id,
                             (tx == 8'd30) ? "SUCCESS(30)" : "FAIL(40)");
                end
            end
        end
        if(!ok) $display("WARN: BHV %0d no result within %0d ns", beh_id, timeout);
    end
endtask

//B FSM self-clocks (match_10/20/30 hardwired 1), the transaction finishes
//~50ns after the request lands; wait a margin, then drop the B irq with one ACK.
task automatic do_b_behavior;
    input [7:0] beh_id;
    begin
        #3000;
        ps_write_word(EC_BIAS_ADDR + `B_TX_RSULT_RPT, {beh_id, 8'h1e, 16'h5100}, resp1);
    end
endtask

//A trigger + tx10 ACK; the motion then runs in background (result via wait_a_result)
task automatic fire_a_behavior;
    input [7:0] beh_id;
    reg [31:0] irq1, irq2;
    reg ok;
    integer t;
    begin
        ps_write_word(EC_BIAS_ADDR + `A_BHV_ID, {24'd0, beh_id}, resp1);
        ok = 1'b0; t = 0;
        while(!ok && t < 10000000) begin
            fork
                begin @(posedge `EC_COMP_INST_PATH.o_intr_irq); end
                begin #10000; end
            join_any
            disable fork;
            t = t + 10000;
            ps_read_word(EC_BIAS_ADDR + `IRQ_REG2, irq2);
            if(irq2 == 32'd0) begin
                ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
                if(irq1 == {8'h88, 8'h66, beh_id, 8'd10}) begin
                    ok = 1'b1;
                    ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT, {beh_id, 8'h0a, 16'h5100}, resp1);
                end
            end
        end
        if(!ok) $display("WARN: BHV %0d fire: irq10 not seen", beh_id);
    end
endtask

//Positioner internals dump while A busy (stuck diagnosis)
initial begin
    wait(`EC_COMP_INST_PATH.ec_cha_st == 1'b1);
    repeat(60) begin
        #20000;
        $display("  [%0t] POSDIAG A=%h J=%h fsm=%h spd=%0d tgt=%0d first=%b cnt=%0d per=%0d done=%b srdy=%b rrdy=%b prdy=%b sstart=%b den=%0d",
            $time,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.curr_state,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.jog_u.fsm_st,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.fsm_st,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_pf_spd,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_pf_spd_target,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_pf_pulse_first,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_pf_pulse_count,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_pf_pulse_period,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_pf_pulse_done,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.spd_div_ready,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.r_div_ready,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.period_div_ready,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.spd_div_start,
            `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.spd_div_den);
    end
end

//key A/B channel state monitor
initial begin
    $monitor("  [%0t] MON son=%b rst_o=%b pause=%b stop_p=%b bhvA=%d bhvB=%d chb=%b cha=%b P26=%d P27=%d P28=%d", $time,
        `EC_COMP_INST_PATH.o_dv_son,
        `EC_COMP_INST_PATH.o_dv_reset,
        `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_pause,
        `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_stop,
        `EC_COMP_INST_PATH.a_bhv_id_r,
        `EC_COMP_INST_PATH.status_beh_pul_axis_u0.b_bhv_id,
        `EC_COMP_INST_PATH.ec_chb_st,
        `EC_COMP_INST_PATH.ec_cha_st,
        `EC_COMP_INST_PATH.param26,
        `EC_COMP_INST_PATH.param27,
        `EC_COMP_INST_PATH.param28);
end

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
        tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_burst_strb(
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
        tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst
            (rd_addr, 0, 2, 1, 0, 0, 0, read_data, resp);
    end
endtask

endmodule
