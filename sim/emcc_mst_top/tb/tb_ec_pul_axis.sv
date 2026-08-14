
`timescale 1 ns / 1 ns
`include "../../../rtl/include_files/components_param.vh"
`include "../../../rtl/include_files/reg_addr_pl.vh"

module tb_ec_pul_axis;
//********************************Defines*********************************
`define EC_COMP_INST_PATH tb_ec_pul_axis.emcc_mst_top_u.emcc_mix_top_u.ec_pul_axis_u0
//*************************Parameter Declarations**************************
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
reg [7:0] a_done_bhv;   // set by responder on A result
reg       b_done;       // set by responder on B result
reg       bus_read_busy = 1'b0;   // AXI read mutex

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

    //---- IRQ responder: acks whatever IRQ_REG1 shows ----
    fork
        irq_responder();
    join_none

    //---- init: common regs ----
    ps_write_word(EC_BIAS_ADDR + `RST_EN,      32'h0000_0001, resp1);
    ps_write_word(EC_BIAS_ADDR + `SC_ID,        32'h0000_0066, resp1);
    ps_write_word(EC_BIAS_ADDR + `EC_ID,        32'h0000_0088, resp1);
    ps_write_word(EC_BIAS_ADDR + `BHV_PRIORITY,  32'h0000_0000, resp1);

    //---- motion params (new register map) ----
    ps_write_word(EC_BIAS_ADDR + `PARAM1,       32'h001E_8480, resp1);  // spd_max 2M pps
    ps_write_word(EC_BIAS_ADDR + `PARAM2,       32'h001E_8480, resp1);  // acc_max
    ps_write_word(EC_BIAS_ADDR + `PARAM3,       32'h001E_8480, resp1);  // dec_max
    ps_write_word(EC_BIAS_ADDR + `PARAM5,       32'h001E_8480, resp1);  // acc 2M
    ps_write_word(EC_BIAS_ADDR + `PARAM33,      32'h000F_4240, resp1);  // touch_spd 1M
    ps_write_word(EC_BIAS_ADDR + `PARAM34,      32'h001E_8480, resp1);  // dec 2M
    ps_write_word(EC_BIAS_ADDR + `PARAM35,      32'h0001_86A0, resp1);  // spd 100k pps
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

    #5000;   // init son consumed by responder

    //============================================  A: beh 1 HOME  ============================
    $display("== A channel: beh 1 HOME ==");
    a_run(8'd1);            // org stimulus block below drives i_axis_org
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after HOME: abspos=%d (expect 0)", $time, $signed(rddata));

    //============================================  A: beh 30 GETPOS  ============================
    $display("== A channel: beh 30 GETPOS ==");
    a_run(8'd30);

    //============================================  A: beh 2 JOG (+step)  ============================
    $display("== A channel: beh 2 JOG ==");
    a_run(8'd2);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after JOG: abspos=%d (expect +100, +-1 profile tolerance)", $time, $signed(rddata));

    //============================================  A: beh 3 MOVE  ============================
    $display("== A channel: beh 3 MOVE to 100 ==");
    a_run(8'd3);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after MOVE: abspos=%d (expect 100)", $time, $signed(rddata));

    //============================================  A: beh 20 safe JOG  ============================
    $display("== A channel: beh 20 safe JOG ==");
    a_run(8'd20);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after safe JOG: abspos=%d (expect 200)", $time, $signed(rddata));

    //============================================  A: beh 21 safe MOVE  ============================
    $display("== A channel: beh 21 safe MOVE to 100 ==");
    a_run(8'd21);
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after safe MOVE: abspos=%d (expect 100)", $time, $signed(rddata));

    //============================================  B: beh 100/101 pause+resume during real MOVE  ============================
    $display("== B channel: beh 100 pause / 101 resume during MOVE ==");
    ps_write_word(EC_BIAS_ADDR + `PARAM36, 32'h0000_07D0, resp1);  // target 2000 (1900 pulses to go)
    a_done_bhv = 8'd0;
    ps_write_word(EC_BIAS_ADDR + `A_BHV_ID, {24'd0, 8'd3}, resp1);  // MOVE background
    wait(`EC_COMP_INST_PATH.ec_cha_st == 1'b1);                     // A busy
    @(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos);    // motion started
    b_done = 1'b0;
    ps_write_word(EC_BIAS_ADDR + `PARAM26, 32'h0000_0001, resp1);
    wait(b_done);                                                   // pause
    $display("  [%0t] after beh100: b_pause=%b", $time,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_pause);
    // freeze check
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    #20000;
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata2);
    if(rddata == rddata2)
        $display("PASS: abspos frozen during pause (%d)", $signed(rddata));
    else
        $display("FAIL: abspos moved during pause (%d -> %d)", $signed(rddata), $signed(rddata2));
    b_done = 1'b0;
    ps_write_word(EC_BIAS_ADDR + `PARAM28, 32'h0000_0001, resp1);  // P28 first: else 100 steals P26
    ps_write_word(EC_BIAS_ADDR + `PARAM26, 32'h0000_0001, resp1);
    wait(b_done);                                                   // resume
    $display("  [%0t] after beh101: b_pause=%b", $time,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_pause);
    wait(a_done_bhv == 8'd3);                                       // MOVE completes
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after resume+move: abspos=%d (expect 2000)", $time, $signed(rddata));

    //============================================  B: beh 103 stop during real MOVE  ============================
    $display("== B channel: beh 103 stop during MOVE ==");
    ps_write_word(EC_BIAS_ADDR + `PARAM36, 32'h0000_0BB8, resp1);  // target 3000 (1000 pulses to go)
    a_done_bhv = 8'd0;
    ps_write_word(EC_BIAS_ADDR + `A_BHV_ID, {24'd0, 8'd3}, resp1);
    wait(`EC_COMP_INST_PATH.ec_cha_st == 1'b1);                     // A busy
    @(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos);    // motion started
    b_done = 1'b0;
    ps_write_word(EC_BIAS_ADDR + `PARAM27, 32'h0000_0001, resp1);  // P27 first: else 100 steals P26
    ps_write_word(EC_BIAS_ADDR + `PARAM26, 32'h0000_0001, resp1);
    wait(b_done);            // stop (A's aborted result acked by responder)
    #3000;                                                          // let the stop take effect
    ps_read_word(EC_BIAS_ADDR + `PARAM51, rddata);
    $display("  [%0t] after beh103 stop: abspos=%d (partial move, real pulses)", $time, $signed(rddata));
    $display("  [%0t] RTL r_pf_abspos=%d (read cross check)", $time,
             $signed(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos));

    //============================================  B: beh 102 drive reset  ============================
    $display("== B channel: beh 102 drive reset ==");
    b_done = 1'b0;
    ps_write_word(EC_BIAS_ADDR + `PARAM29, 32'h0000_0001, resp1);
    wait(b_done);
    ps_write_word(EC_BIAS_ADDR + `PARAM29, 32'h0000_0000, resp1);  // no auto-clear: PS re-arms
    $display("INFO: beh102 done, PARAM29 cleared by PS");

    //============================================  B: beh 105 soff / beh 104 son  ============================
    $display("== B channel: beh 105 soff / beh 104 son ==");
    b_done = 1'b0;
    ps_write_word(EC_BIAS_ADDR + `PARAM30, 32'h0000_0000, resp1);  // drive off -> one-shot 105
    wait(b_done);
    $display("  [%0t] beh105 done, o_dv_son=%b (expect 1=disabled)", $time, `EC_COMP_INST_PATH.o_dv_son);
    b_done = 1'b0;
    ps_write_word(EC_BIAS_ADDR + `PARAM30, 32'h0000_0001, resp1);  // drive on -> one-shot 104
    wait(b_done);
    $display("  [%0t] beh104 done, o_dv_son=%b (expect 0=enabled)", $time, `EC_COMP_INST_PATH.o_dv_son);

    #2000;
    $finish;
end

//HOME org stimulus: hold org=1, falling edge finishes the search
initial begin
    wait(`EC_COMP_INST_PATH.a_bhv_id_r == 8'd1);
    #50000;
    force `EC_COMP_INST_PATH.i_axis_org = 1'b1;
    #20000;
    force `EC_COMP_INST_PATH.i_axis_org = 1'b0;
    $display("  [%0t] org released", $time);
end

//A FSM state name
function string fsm_a_name(input [7:0] s);
    case(s)
        8'd0:  return "IDLE";
        8'd1:  return "PRE_DET";
        8'd2:  return "RDY_10";
        8'd3:  return "RDY_10_ACK";
        8'd4:  return "EXE_20";
        8'd5:  return "EXE";
        8'd6:  return "EXE_20_ACK";
        8'd7:  return "POST_DET";
        8'd8:  return "SUCC_30";
        8'd9:  return "SUCC_30_ACK";
        8'd10: return "ALERT_40";
        8'd11: return "ALERT_40_ACK";
        default: return "??";
    endcase
endfunction

//B FSM state name
function string fsm_b_name(input [7:0] s);
    case(s)
        8'd0:  return "IDLE";
        8'd1:  return "PRE_DET";
        8'd2:  return "RDY_10";
        8'd3:  return "RDY_10_ACK";
        8'd4:  return "EXE_20";
        8'd5:  return "EXE_20_ACK";
        8'd6:  return "POST_DET";
        8'd7:  return "SUCC_30";
        8'd8:  return "SUCC_30_ACK";
        8'd9:  return "ALERT_40";
        8'd10: return "ALERT_40_ACK";
        8'd11: return "EXE";
        default: return "??";
    endcase
endfunction

//A/B FSM current state
initial begin
    $monitor("  [%0t] FSM_A %s | FSM_B %s", $time,
             fsm_a_name(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.state_monitor_o[7:0]),
             fsm_b_name(`EC_COMP_INST_PATH.status_beh_pul_axis_u0.state_monitor_o[7:0]));
end

//abspos abnormal jump catcher
reg [31:0] abspos_prev = 32'd0;
always @(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos) begin
    if(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos != abspos_prev + 32'd1 &&
       `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos != abspos_prev - 32'd1)
        $display("  [%0t] ABSPOS JUMP %d -> %d (pstart=%b pdone=%b dir=%b)",
                 $time, $signed(abspos_prev),
                 $signed(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos),
                 `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.o_rc_pulse_start,
                 `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.i_rc_pulse_done,
                 `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.o_rc_pulse_dir);
    abspos_prev = `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos;
end

//IRQ latch catcher
always @(`EC_COMP_INST_PATH.irq_3i1o_arbitrator_u0.irq_reg1_o) begin
    $display("  [%0t] IRQ_LATCH 0x%08x | ga=%b gb=%b | a_irq=%b a_bhv=%d a_tx=0x%02x | b_irq=%b b_bhv=%d b_tx=0x%02x",
             $time, `EC_COMP_INST_PATH.irq_3i1o_arbitrator_u0.irq_reg1_o,
             `EC_COMP_INST_PATH.irq_3i1o_arbitrator_u0.irq_a_grant_o,
             `EC_COMP_INST_PATH.irq_3i1o_arbitrator_u0.irq_b_grant_o,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.irq_o,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.a_bhv_id_r,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.a_tx_id,
             `EC_COMP_INST_PATH.status_beh_pul_axis_u0.irq_o,
             `EC_COMP_INST_PATH.status_beh_pul_axis_u0.b_bhv_id,
             `EC_COMP_INST_PATH.status_beh_pul_axis_u0.b_tx_id);
end

//MOVE path debug
always @(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.move_u.fsm_st or
         `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.fsm_st or
         `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.move_u.o_pf_start or
         `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.i_pf_start) begin
    $display("  [%0t] MOVE_DBG mstart=%b mfsm=%d mpulse=%d | pstart=%b ppulse=%d pfsm=%d | abspos=%d",
             $time,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.move_start,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.move_u.fsm_st,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.move_u.r_pf_pulse,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.i_pf_start,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.i_pf_pulse,
             `EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.pos_u.fsm_st,
             $signed(`EC_COMP_INST_PATH.proactive_beh_pul_axis_u0.r_pf_abspos));
end

//IRQ responder: poll + ack by IRQ_REG1 content
task automatic irq_responder;
    reg [31:0] irq1;
    reg [31:0] handled;
    reg [7:0]  tx;
    forever begin
        #500;
        ps_read_word(EC_BIAS_ADDR + `IRQ_REG1, irq1);
        if(irq1 == handled || irq1 == 32'd0) begin
            // nothing new
        end else begin
            tx = irq1[7:0];
            if(irq1[15:8] >= 8'd100) begin
                ps_write_word(EC_BIAS_ADDR + `B_TX_RSULT_RPT,
                              {irq1[15:8], tx, (tx == 8'd30) ? 16'h5100 : 16'h5101}, resp1);
                if(tx == 8'd30 || tx == 8'd40) b_done = 1'b1;
                $display("  [%0t] IRQ B bhv=%0d tx=0x%02x ACK", $time, irq1[15:8], tx);
            end else begin
                ps_write_word(EC_BIAS_ADDR + `A_TX_RSULT_RPT,
                              {irq1[15:8], tx, (tx == 8'd30) ? 16'h5100 : 16'h5101}, resp1);
                if(tx == 8'd30 || tx == 8'd40) a_done_bhv = irq1[15:8];
                $display("  [%0t] IRQ A bhv=%0d tx=0x%02x ACK", $time, irq1[15:8], tx);
            end
            handled = irq1;
        end
    end
endtask

//A: trigger + wait result
task automatic a_run(input [7:0] beh_id);
    begin
        a_done_bhv = 8'd0;
        ps_write_word(EC_BIAS_ADDR + `A_BHV_ID, {24'd0, beh_id}, resp1);
        wait(a_done_bhv == beh_id);
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
        while(bus_read_busy) #100;   // serialize AXI reads
        bus_read_busy = 1'b1;
        tb_ec_pul_axis.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst
            (rd_addr, 0, 2, 1, 0, 0, 0, read_data, resp);
        bus_read_busy = 1'b0;
    end
endtask

endmodule
