`timescale 1 ns / 1 ps
//==============================================================================
// tb_slave_rs485_arbiter
//   波形仿真, 无 $display。覆盖场景:
//     S1  下行广播扇出   : sh_flag / sh_s2m_msg -> 全部通道原样复制
//     S2  同板轮询仲裁   : b0 ch0 先发(ch2 途中请求, owner 不被打断),
//                          ACK 后轮询切换到 ch2
//     S3  跨板并行       : b0c1 与 b3c3 同时请求, 两板独立仲裁,
//                          ACK 按 r_flag_board 定向, 互不影响
//     S4  ACK 后同值重发 : ACK 时不撤数, pend 重新置位并再次授权
//     S5  无 ACK 撤数    : m2s 归零 -> pend 清除, FSM 回 IDLE, 上行回 0
//     S6  空闲 ACK       : 全通道 Z 时 ACK 仍打在保持的 owner 槽位上
//     S7  第二次广播     : 换值再观察扇出
//   空闲槽位保持 Z, 验证 Z->0 输入调理路径
//==============================================================================
module tb_slave_rs485_arbiter;

    // ---------------- 参数(缩小规模便于看波形, 实际 32 板 x 4 槽) ----------------
    localparam RAM_DWIDTH    = 32;
    localparam NUM_BOARDS    = 4;    // 实际 = RAM_DWIDTH = 32
    localparam CH_PER_BOARD  = 4;    // 与实际一致
    localparam RFLAG_BOARD_W = 2;    // 实际 = RAM_AWIDTH-9 = 3 (板 8~31 恒无 ACK)

    localparam CLK_PERIOD    = 10;   // 100 MHz

    localparam NUM_CH = NUM_BOARDS * CH_PER_BOARD;

    // ---------------- 时钟 / 复位 ----------------
    reg clk;
    reg rst;

    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---------------- 共享侧 (pkg_route rs485_00_*) ----------------
    reg                     sh_r_flag;
    reg  [RFLAG_BOARD_W-1:0] sh_r_flag_board;
    reg                     sh_flag;
    reg  [RAM_DWIDTH-1:0]   sh_s2m_msg [NUM_BOARDS-1:0];
    wire [RAM_DWIDTH-1:0]   sh_m2s_msg [NUM_BOARDS-1:0];

    // ---------------- 通道侧 [板][槽] ----------------
    wire                    ch_r_flag  [NUM_BOARDS-1:0][CH_PER_BOARD-1:0];
    wire                    ch_flag    [NUM_BOARDS-1:0][CH_PER_BOARD-1:0];
    wire [RAM_DWIDTH-1:0]   ch_s2m_msg [NUM_BOARDS-1:0][CH_PER_BOARD-1:0];
    reg  [RAM_DWIDTH-1:0]   ch_m2s_msg [NUM_BOARDS-1:0][CH_PER_BOARD-1:0];

    integer b;
    integer k;

    // ---------------- DUT ----------------
    slave_rs485_arbiter #(
        .RAM_DWIDTH    ( RAM_DWIDTH    ),
        .NUM_BOARDS    ( NUM_BOARDS    ),
        .CH_PER_BOARD  ( CH_PER_BOARD  ),
        .RFLAG_BOARD_W ( RFLAG_BOARD_W )
    ) u_dut (
        .clk                ( clk             ),
        .rst                ( rst             ),
        .sh_rs485_r_flag    ( sh_r_flag       ),
        .sh_rs485_r_flag_board( sh_r_flag_board),
        .sh_rs485_flag      ( sh_flag         ),
        .sh_rs485_s2m_msg   ( sh_s2m_msg      ),
        .sh_rs485_m2s_msg   ( sh_m2s_msg      ),
        .ch_rs485_r_flag    ( ch_r_flag       ),
        .ch_rs485_flag      ( ch_flag         ),
        .ch_rs485_s2m_msg   ( ch_s2m_msg      ),
        .ch_rs485_m2s_msg   ( ch_m2s_msg      )
    );

    // ---------------- 波形观察辅助: 关键内部状态 ----------------
    wire              dbg_state_b0 = u_dut.state_b[0];
    wire              dbg_state_b1 = u_dut.state_b[1];
    wire              dbg_state_b2 = u_dut.state_b[2];
    wire              dbg_state_b3 = u_dut.state_b[3];
    wire [1:0]        dbg_owner_b0 = u_dut.owner_b[0];
    wire [1:0]        dbg_owner_b1 = u_dut.owner_b[1];
    wire [1:0]        dbg_owner_b2 = u_dut.owner_b[2];
    wire [1:0]        dbg_owner_b3 = u_dut.owner_b[3];
    wire [NUM_CH-1:0] dbg_pend     = u_dut.pend;
    wire [NUM_CH-1:0] dbg_ack1c    = u_dut.ch_ack_1cycle;

    // ---------------- 激励 task ----------------
    // PS 读 ACK: 1 clk 脉冲 + 目标板号 (模拟 pkg_route 的 rs485_00_r_flag)
    task automatic ps_read_ack(input [RFLAG_BOARD_W-1:0] board);
        @(negedge clk);
        sh_r_flag       <= 1'b1;
        sh_r_flag_board <= board;
        @(negedge clk);
        sh_r_flag       <= 1'b0;
    endtask

    // ---------------- 主序列 ----------------
    initial begin
        rst            = 1'b1;
        sh_r_flag      = 1'b0;
        sh_r_flag_board= {RFLAG_BOARD_W{1'b0}};
        sh_flag        = 1'b0;
        for (b = 0; b < NUM_BOARDS; b = b + 1) begin
            sh_s2m_msg[b] = {RAM_DWIDTH{1'b0}};
            for (k = 0; k < CH_PER_BOARD; k = k + 1)
                ch_m2s_msg[b][k] = {RAM_DWIDTH{1'bz}};   // 空闲槽位 = Z
        end

        repeat (6) @(negedge clk);
        rst = 1'b0;

        // ============ S1: 下行广播扇出 ============
        @(negedge clk);
        sh_s2m_msg[0] <= 32'h5100_0000;                  // 每板不同数据便于区分
        sh_s2m_msg[1] <= 32'h5100_0001;
        sh_s2m_msg[2] <= 32'h5100_0002;
        sh_s2m_msg[3] <= 32'h5100_0003;
        sh_flag       <= 1'b1;
        @(negedge clk);
        sh_flag       <= 1'b0;
        repeat (2) @(negedge clk);

        // ============ S2: 同板轮询仲裁 (board0: ch0 -> ch2) ============
        ch_m2s_msg[0][0] <= 32'hA000_0001;               // ch0 请求
        repeat (2) @(negedge clk);                       // pend -> 授权 -> BUSY
        ch_m2s_msg[0][2] <= 32'hA000_0002;               // ch2 途中请求, owner 仍为 ch0
        repeat (4) @(negedge clk);                       // 观察 owner 保持不被打断
        ps_read_ack(2'd0);                               // ACK 板0 (打在 ch0)
        ch_m2s_msg[0][0] <= {RAM_DWIDTH{1'bz}};          // 模块收到 ACK 撤数
        repeat (3) @(negedge clk);                       // 观察轮询切换到 ch2
        ps_read_ack(2'd0);                               // ACK 板0 (打在 ch2)
        ch_m2s_msg[0][2] <= {RAM_DWIDTH{1'bz}};
        repeat (2) @(negedge clk);

        // ============ S3: 跨板并行 + ACK 定向 ============
        ch_m2s_msg[0][1] <= 32'hC000_0001;               // 板0 ch1 请求
        ch_m2s_msg[3][3] <= 32'hD000_0003;               // 板3 ch3 同时请求
        repeat (3) @(negedge clk);                       // 两板同时 BUSY
        ps_read_ack(2'd3);                               // 只 ACK 板3
        ch_m2s_msg[3][3] <= {RAM_DWIDTH{1'bz}};
        repeat (3) @(negedge clk);                       // 板0 仍 BUSY, 板3 已回 IDLE
        ps_read_ack(2'd0);                               // 再 ACK 板0
        ch_m2s_msg[0][1] <= {RAM_DWIDTH{1'bz}};
        repeat (2) @(negedge clk);

        // ============ S4: ACK 后同值重发 (board1/ch0) ============
        ch_m2s_msg[1][0] <= 32'hE000_0001;
        repeat (3) @(negedge clk);
        ps_read_ack(2'd1);                               // ACK 时不撤数
        repeat (4) @(negedge clk);                       // 观察 pend 重新置位并再次授权
        ps_read_ack(2'd1);
        ch_m2s_msg[1][0] <= {RAM_DWIDTH{1'bz}};
        repeat (2) @(negedge clk);

        // ============ S5: 无 ACK 撤数 (board2/ch1) ============
        ch_m2s_msg[2][1] <= 32'hF000_0002;
        repeat (3) @(negedge clk);
        ch_m2s_msg[2][1] <= {RAM_DWIDTH{1'bz}};          // 直接撤数, 无 ACK
        repeat (3) @(negedge clk);                       // 观察 pend 清除 / FSM 回 IDLE

        // ============ S6: 空闲 ACK (owner 保持) ============
        ps_read_ack(2'd2);                               // 全通道 Z, ACK 仍打在保持的 owner 上
        repeat (2) @(negedge clk);

        // ============ S7: 第二次广播 ============
        @(negedge clk);
        sh_s2m_msg[0] <= 32'h5200_0000;
        sh_s2m_msg[1] <= 32'h5200_0001;
        sh_s2m_msg[2] <= 32'h5200_0002;
        sh_s2m_msg[3] <= 32'h5200_0003;
        sh_flag       <= 1'b1;
        @(negedge clk);
        sh_flag       <= 1'b0;

        repeat (10) @(negedge clk);
        $finish;
    end

    // ---------------- 看门狗 ----------------
    initial begin
        #1_000_000;
        $finish;
    end

endmodule
