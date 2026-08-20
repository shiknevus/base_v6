
`timescale 1 ns / 1 ns
`include "../../../rtl/include_files/components_param.vh"
`include "../../../rtl/include_files/reg_addr_pl.vh"
`include "../../../rtl/include_files/globe_includes.vh"

module tb_ec_1do_slave;
//********************************Defines*********************************
`define EC_1DO_PATH tb_ec_1do_slave.emcc_mst_top_u.emcc_mix_top_u.ec_1do_u1
`define SLV_DO_PATH tb_ec_1do_slave.SLV_STA[0].emmcc_slv_top_u.do_regoin_msg
`define MST_DO_TX_PATH tb_ec_1do_slave.emcc_mst_top_u.emcc_mix_top_u.do_regoin_r_msg[0][0]
`define TIMEDELAY 50000
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

//Dut2: slave stations
localparam      SLV_STA_NUM = `SIM_SLV_STA_NUM;
wire            rxp_1st_i[0:SLV_STA_NUM-1];
wire            rxn_1st_i[0:SLV_STA_NUM-1];
wire            txp_1st_i[0:SLV_STA_NUM-1];
wire            txn_1st_i[0:SLV_STA_NUM-1];
wire            rxp_2nd_i[0:SLV_STA_NUM-1];
wire            rxn_2nd_i[0:SLV_STA_NUM-1];
wire            txp_2nd_i[0:SLV_STA_NUM-1];
wire            txn_2nd_i[0:SLV_STA_NUM-1];
reg [SLV_STA_NUM-1:0] gen_link_error = 0;

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
always #(INIT_CLOCKPERIOD / 2.0) init_clk_p = !init_clk_p;
assign init_clk_n =  !init_clk_p;

//____________________________Resets____________________________
initial begin
    reset_i = 1'b1;
  #1000 reset_i = 1'b0;
end

//________________________Instantiate Dut: master + slave loopback_______
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

generate
    genvar j;
    for (j=0; j < SLV_STA_NUM; j=j+1) begin: SLV_STA
        if(j==0) begin
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
            `ifdef SIM_PLATFORM_MST
                .INIT_CLK_P(init_clk_p),
                .INIT_CLK_N(init_clk_n),
            `else
            `endif
                .GT_REFCLK_P(reference_clk_2_p_r),
                .GT_REFCLK_N(reference_clk_2_n_r),
                .RXP_0(rxp_1st_i[j]),
                .RXN_0(rxn_1st_i[j]),
                .TXP_0(txp_1st_i[j]),
                .TXN_0(txn_1st_i[j]),
                .RXP_1(rxp_2nd_i[j]),
                .RXN_1(rxn_2nd_i[j]),
                .TXP_1(txp_2nd_i[j]),
                .TXN_1(txn_2nd_i[j]),
                .uart_rtl_0_txd     (),
                .uart_rtl_0_rxd     (rs232_rxd_dat),
                .uart_rtl_1_txd     (),
                .uart_rtl_1_rxd     (0),
                .dataout            (),
                .datain             (64'hfefe_efef_baba_abab+j)
            );
    end
endgenerate

assign  rxn_11_i                    =   txn_2nd_i[SLV_STA_NUM-1];
assign  rxp_11_i                    =   txp_2nd_i[SLV_STA_NUM-1];
assign  rxn_2nd_i[SLV_STA_NUM-1]    =    txn_11_i;
assign  rxp_2nd_i[SLV_STA_NUM-1]    =    txp_11_i;

localparam EC_1DO_BIAS_ADDR = `PL_CFG_BASE_ADDR + {20'hc00};  // ec_1do_u1

reg tb_ACLK;
reg tb_ARESETn;
reg [1:0] resp1;
reg [31:0] rddata;
reg [7:0] a_done_bhv;   // set by responder on A result
reg       bus_read_busy = 1'b0;   // AXI read mutex

initial begin
    tb_ACLK = 1'b0;
end

always #10 tb_ACLK = !tb_ACLK;

initial begin
    $display ("running tb_ec_1do_slave");
    tb_ARESETn = 1'b0;
    repeat(20)@(posedge tb_ACLK);
    tb_ARESETn = 1'b1;
    @(posedge tb_ACLK);
    repeat(5) @(posedge tb_ACLK);

    tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.set_debug_level_info(1'b0);
    tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    #200;
    tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b0);
    tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h1);
    #2000;
    tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.por_srstb_reset(1'b1);
    tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.fpga_soft_reset(32'h0);
    #2000;

    //PS RX PORT
     wait (tb_ec_1do_slave.emcc_mst_top_u.prot_clk_rst == 0)
    fork
        begin
            wait (tb_ec_1do_slave.emcc_mst_top_u.axi_clk_0 === 1'b1);
            $display("  [%0t] axi_clk_0 up", $time);
        end
        begin #500000; $display("WARN: axi_clk_0 not seen, continue"); end
    join_any
    disable fork;
    $display("  [%0t] axi_clk_0=%b prot_clk_rst=%b (before force)", $time,
             tb_ec_1do_slave.emcc_mst_top_u.axi_clk_0,
             tb_ec_1do_slave.emcc_mst_top_u.prot_clk_rst);
    force tb_ec_1do_slave.emcc_mst_top_u.prot_clk_rst = 1'b0;

    //---- link up + slave init (aurora flow) ----
    wait_mst_aurora_link;
    ps_write_word(`MST_APP_REG_BASE + `OPT_INTF_INIT_EN_ADDR, 32'h0000_0001, resp1);
    $display("  [%0t] PS enable optical fiber interface initialization", $time);
    ps_write_word(`MST_APP_REG_BASE + `MST_APP_MODE_ADDR, 32'h0000_0001, resp1);
    $display("  [%0t] PS enable transfer port", $time);
    wait_all_slv_initial_done;

    //---- IRQ responder: acks whatever IRQ_REG1 shows ----
    fork
        irq_responder();
    join_none

    //---- init: common regs ----
    ps_write_word(EC_1DO_BIAS_ADDR + `RST_EN,       32'h0000_0001, resp1);
    ps_write_word(EC_1DO_BIAS_ADDR + `EC_ID,        32'h0000_3FFF, resp1);
    ps_write_word(EC_1DO_BIAS_ADDR + `SC_ID,        32'h0000_0004, resp1);
    ps_write_word(EC_1DO_BIAS_ADDR + `BHV_PRIORITY, 32'h0000_0000, resp1);
    ps_write_word(EC_1DO_BIAS_ADDR + `A_TX_OT,      32'hFFFF_0000, resp1);  // A: no timeout
    ps_write_word(EC_1DO_BIAS_ADDR + `A_EN,         32'h0000_0001, resp1);

    #5000;

    //--------------------------------------------  A: beh 1 DO on  ----------------------------
    $display("== A channel: beh 1 DO on ==");
    a_run(8'd1);
    check_do(1'b1, "beh1");
    check_tx(1'b1, "beh1");
    #`TIMEDELAY;
    //--------------------------------------------  A: beh 2 DO off  ----------------------------
    $display("== A channel: beh 2 DO off ==");
    a_run(8'd2);
    check_do(1'b0, "beh2");
    check_tx(1'b0, "beh2");
    #`TIMEDELAY;
    //--------------------------------------------  A: beh 1 DO on again  ----------------------------
    $display("== A channel: beh 1 DO on again ==");
    a_run(8'd1);
    check_do(1'b1, "beh1 again");
    check_tx(1'b1, "beh1 again");
    #`TIMEDELAY;
    //--------------------------------------------  A: beh 2 DO off again  ----------------------------
    $display("== A channel: beh 2 DO off again ==");
    a_run(8'd2);
    check_do(1'b0, "beh2 again");
    check_tx(1'b0, "beh2 again");
    #`TIMEDELAY;

    $display("== tb_ec_1do_slave done ==");
    #2000;
    $finish;
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

//A FSM current state
initial begin
    $monitor("  [%0t] FSM_A %s", $time,
             fsm_a_name(`EC_1DO_PATH.proactive_beh_1do_u0.state_monitor_o[7:0]));
end

//DO output edge catcher
always @(`EC_1DO_PATH.o_sig_dri) begin
    $display("  [%0t] s_1do_do -> %b", $time, `EC_1DO_PATH.o_sig_dri);
end

//slave received DO edge catcher
always @(`SLV_DO_PATH[0]) begin
    $display("  [%0t] slv do_regoin_msg[0] -> %b", $time, `SLV_DO_PATH[0]);
end

//IRQ latch catcher
always @(`EC_1DO_PATH.irq_3i1o_arbitrator_u0.irq_reg1_o) begin
    $display("  [%0t] IRQ_LATCH 0x%08x | a_irq=%b a_bhv=%d a_tx=0x%02x",
             $time, `EC_1DO_PATH.irq_3i1o_arbitrator_u0.irq_reg1_o,
             `EC_1DO_PATH.proactive_beh_1do_u0.irq_o,
             `EC_1DO_PATH.proactive_beh_1do_u0.a_bhv_id_r,
             `EC_1DO_PATH.proactive_beh_1do_u0.a_tx_id);
end

//wait master aurora link up: LINK_STATUS_ADDR[1:0]==3
task automatic wait_mst_aurora_link;
    reg [31:0] read_data;
    begin
        read_data = 0;
        while(read_data[1:0] !== 2'b11) begin
            ps_read_word(`MST_APP_REG_BASE + `LINK_STATUS_ADDR, read_data);
            $display("  [%0t] master link status 0x%x", $time, read_data);
        end
        $display("  [%0t] master aurora link up", $time);
    end
endtask

//wait all slaves initialized: SLV_STA_NUM_ADDR != 0
task automatic wait_all_slv_initial_done;
    reg [31:0] read_data;
    reg [31:0] slv_num;
    begin
        read_data = 0;
        while(read_data == 0) begin
            ps_read_word(`MST_APP_REG_BASE + `SLV_STA_NUM_ADDR, read_data);
            #500;
        end
        slv_num = read_data;
        $display("  [%0t] slave station number = %0d", $time, slv_num);
    end
endtask

//IRQ responder: IRQ_REG1/2 driven, ack after FSM-state cross-check
// irq1={ec_id,sc_id,bhv[7:0]} irq2={tx[31:24],alarm[23:16]};
task automatic irq_responder;
    reg [31:0] irq1;
    reg [31:0] irq2;
    reg [31:0] sta;
    reg [31:0] bhv_r;
    reg [7:0]  bhv;
    reg [7:0]  tx;
    reg [7:0]  exp_tx;
    forever begin
        #500;
        ps_read_word(EC_1DO_BIAS_ADDR + `IRQ_REG1, irq1);
        if(irq1 != 32'd0) begin
            if(irq1[31:18] !== 14'h3FFF || irq1[17:8] !== 10'h4)
                $display("  [%0t] WARN IRQ_REG1 packing mismatch: 0x%08x", $time, irq1);
            bhv = irq1[7:0];
            ps_read_word(EC_1DO_BIAS_ADDR + `IRQ_REG2, irq2);
            tx  = irq2[31:24];
            ps_read_word(EC_1DO_BIAS_ADDR + `DEBUG_REG1, sta);
            exp_tx = (sta[7:0] == 8'd3)  ? 8'd10 :
                     (sta[7:0] == 8'd9)  ? 8'd30 :
                     (sta[7:0] == 8'd11) ? 8'd40 : 8'd0;
            if(exp_tx != 8'd0 && tx == exp_tx) begin
                ps_read_word(EC_1DO_BIAS_ADDR + `A_BHV_ID, bhv_r);
                if(bhv_r[7:0] == bhv) begin
                    ps_write_word(EC_1DO_BIAS_ADDR + `A_TX_RSULT_RPT,{bhv, tx, (tx == 8'd30) ? 16'h5100 : 16'h51f1}, resp1);
                    if(tx == 8'd30 || tx == 8'd40) a_done_bhv = bhv;
                    $display("  [%0t] IRQ A bhv=%0d tx=0x%02x ACK", $time, bhv, tx);
                end
            end
        end
    end
endtask

//A: trigger + wait result
task automatic a_run(input [7:0] beh_id);
    begin
        a_done_bhv = 8'd0;
        ps_write_word(EC_1DO_BIAS_ADDR + `A_BHV_ID, {24'd0, beh_id}, resp1);
        wait(a_done_bhv == beh_id);
    end
endtask

//DO check: hier signal + PARAM66 readback
task automatic check_do(input bit exp, input string tag);
    begin
        ps_read_word(EC_1DO_BIAS_ADDR + `PARAM66, rddata);
        if(`EC_1DO_PATH.o_sig_dri == exp && rddata[0] == exp)
            $display("PASS: %s  s_1do_do=%b PARAM66[0]=%b", tag, `EC_1DO_PATH.o_sig_dri, rddata[0]);
        else
            $display("FAIL: %s  s_1do_do=%b PARAM66[0]=%b (expect %b)", tag, `EC_1DO_PATH.o_sig_dri, rddata[0], exp);
    end
endtask

//TX check: master TX depot bit + slave RX bit (do_regoin_msg[0]=~s_1do_do)
task automatic check_tx(input bit exp, input string tag);
    integer tmo;
    begin
        tmo = 0;
        while(`SLV_DO_PATH[0] !== ~exp && tmo < 50000) begin   // poll up to 50us
            #500;
            tmo = tmo + 500;
        end
        if(`SLV_DO_PATH[0] === ~exp && `MST_DO_TX_PATH === ~exp)
            $display("PASS: %s TX  mst_tx_bit=%b slv_rcv[0]=%b (expect %b)", tag,
                     `MST_DO_TX_PATH, `SLV_DO_PATH[0], ~exp);
        else
            $display("FAIL: %s TX  mst_tx_bit=%b slv_rcv[0]=%b (expect %b, tmo=%0t)", tag,
                     `MST_DO_TX_PATH, `SLV_DO_PATH[0], ~exp, tmo);
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
        tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.write_burst_strb(
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
        tb_ec_1do_slave.emcc_mst_top_u.mststa_mpsoc_u.zynq_ultra_ps_e_0.inst.read_burst
            (rd_addr, 0, 2, 1, 0, 0, 0, read_data, resp);
        bus_read_busy = 1'b0;
    end
endtask

endmodule
