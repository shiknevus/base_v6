`timescale 1 ns / 1 ps
module slave_rs485_arbiter #(
    parameter RAM_DWIDTH    = 32          // 消息位宽
   ,parameter NUM_BOARDS    = 32          // 从板数量（通道第一维）
   ,parameter CH_PER_BOARD  = 4           // 每从板最大模块数（通道第二维）
   ,parameter RFLAG_BOARD_W = 3           // r_flag 携带的板号位宽（取自 PS 访问地址位宽）
)(
     input  wire                        clk
    ,input  wire                        rst

    // ======================================================
    // Shared side - 全局共享侧
    //   sh_rs485_s2m_msg[b]  <- rs485_00_msg[b]        (pkg_route 输出)
    //   sh_rs485_m2s_msg[b]  -> rs485_00_send_msg[b]   (仲裁后唯一输出)
    //   r_flag : PS 读 RS485 depot 的全局 ACK 信号（广播信号）
    //   r_flag_board : PS 访问地址的高位 slv_cfg_msg_addr[RAM_AWIDTH-1:9]
    //                  用于配合 r_flag 精确命中目标从板
    //   flag   : PS 写 s2m depot 的全局广播信号（先经 flow_comp 内部过滤）
    // ======================================================
    ,input  wire                        sh_rs485_r_flag
    ,input  wire [RFLAG_BOARD_W-1:0]    sh_rs485_r_flag_board
    ,input  wire                        sh_rs485_flag
    ,input  wire [RAM_DWIDTH-1:0]       sh_rs485_s2m_msg [NUM_BOARDS-1:0]
    ,output reg  [RAM_DWIDTH-1:0]       sh_rs485_m2s_msg [NUM_BOARDS-1:0]

    // ======================================================
    // Channel side - 二维 [从板号][模块仲裁号]
    //   flow_comp <-> ch_rs485_XX[board][ch]
    //   同一从板多模块轮询时使用，保证同板不冲突，跨板隔离
    // ======================================================
    ,output reg                         ch_rs485_r_flag  [NUM_BOARDS-1:0][CH_PER_BOARD-1:0]
    ,output reg                         ch_rs485_flag    [NUM_BOARDS-1:0][CH_PER_BOARD-1:0]
    ,output reg  [RAM_DWIDTH-1:0]       ch_rs485_s2m_msg [NUM_BOARDS-1:0][CH_PER_BOARD-1:0]
    ,input  wire [RAM_DWIDTH-1:0]       ch_rs485_m2s_msg [NUM_BOARDS-1:0][CH_PER_BOARD-1:0]
);

    // ==================================================
    // Derived
    // ==================================================
    localparam NUM_CH = NUM_BOARDS * CH_PER_BOARD;
    localparam OW     = (CH_PER_BOARD <= 1) ? 1 : $clog2(CH_PER_BOARD);

    // ==================================================
    // FSM states
    // ==================================================
    localparam ST_IDLE = 1'b0,
               ST_BUSY = 1'b1;

    // ==================================================
    // r_flag 板号解码：只有 PS 读目标从板才可产生 ACK
    // 超出板号地址可达范围的板，直接置 0
    // ==================================================
    wire [NUM_BOARDS-1:0] rflag_hit;

    genvar gb;
    generate
        for (gb=0; gb<NUM_BOARDS; gb=gb+1) begin: gen_rflag
            if (gb < (1<<RFLAG_BOARD_W)) begin: in_range
                assign rflag_hit[gb] = sh_rs485_r_flag
                                     & (sh_rs485_r_flag_board == gb[RFLAG_BOARD_W-1:0]);
            end else begin: out_of_range
                assign rflag_hit[gb] = 1'b0;
            end
        end
    endgenerate

    // ==================================================
    // Per-channel state (flat index i = b*CH_PER_BOARD + k)
    // ==================================================
    reg [RAM_DWIDTH-1:0]   ch_prev_m2s   [NUM_CH-1:0];
    reg [NUM_CH-1:0]       ch_ack_1cycle;
    reg [NUM_CH-1:0]       pend;

    // ==================================================
    // Per-board FSM 寄存器（每板独立仲裁产生 BUSY）
    // ==================================================
    reg                    state_b     [NUM_BOARDS-1:0];
    reg [OW-1:0]           owner_b     [NUM_BOARDS-1:0];
    reg [OW-1:0]           last_owner_b[NUM_BOARDS-1:0];

    // ==================================================
    // Effective m2s: Z/x 态归零，保证安全 + 综合无警告
    // ==================================================
    wire [RAM_DWIDTH-1:0]  m2s_eff [NUM_CH-1:0];

    genvar gi;
    generate
        for (gi=0; gi<NUM_CH; gi=gi+1) begin: gen_eff
            localparam GB = gi / CH_PER_BOARD;
            localparam GC = gi % CH_PER_BOARD;
            assign m2s_eff[gi] = (ch_rs485_m2s_msg[GB][GC] === {RAM_DWIDTH{1'bz}})
                               ? {RAM_DWIDTH{1'b0}}
                               : ch_rs485_m2s_msg[GB][GC];
        end
    endgenerate

    // ==================================================
    // Per-channel request detection
    //   (a) m2s 变为新的非零值 -> 新请求
    //   (b) ACK 拉过 1 且 m2s 与上次值相同 -> 同值重发
    //   两者 nonzero(!=0) 才算"有效"请求
    // ==================================================
    wire [NUM_CH-1:0] ch_to_nonzero;
    wire [NUM_CH-1:0] ch_ack_same_retry;

    generate
        for (gi=0; gi<NUM_CH; gi=gi+1) begin: gen_req
            assign ch_to_nonzero[gi] = (m2s_eff[gi] != ch_prev_m2s[gi])
                                     && (|m2s_eff[gi]);
            assign ch_ack_same_retry[gi] = ch_ack_1cycle[gi]
                                        && (m2s_eff[gi] == ch_prev_m2s[gi])
                                        && (|m2s_eff[gi]);
        end
    endgenerate

    // ==================================================
    // Per-board round-robin grant
    //   当前 owner 仍有数据时保持所有权（多拍传输不被打断）
    //   当前 owner 数据结束后轮询下一个 pending 通道
    //   轮询序号 = (last_owner_b[b] + 1 + k) % CH_PER_BOARD
    // ==================================================
    reg             grant_v [NUM_BOARDS-1:0];
    reg [OW-1:0]    grant_i [NUM_BOARDS-1:0];
    integer         b;
    integer         k;
    integer         rr;

    always @(*) begin
        for (b=0; b<NUM_BOARDS; b=b+1) begin
            grant_v[b] = 1'b0;
            grant_i[b] = {OW{1'b0}};
            // 当前 owner 仍有数据：保持所有权（多拍传输进行中）
            if (|m2s_eff[b*CH_PER_BOARD + owner_b[b]]) begin
                grant_i[b] = owner_b[b];
                grant_v[b] = 1'b1;
            end else begin
                // 当前 owner 数据结束：轮询下一个 pending 通道
                for (k=0; k<CH_PER_BOARD; k=k+1) begin
                    rr = (last_owner_b[b] + 1 + k) % CH_PER_BOARD;
                    if (!grant_v[b] && pend[b*CH_PER_BOARD + rr]) begin
                        grant_i[b] = rr[OW-1:0];
                        grant_v[b] = 1'b1;
                    end
                end
            end
        end
    end

    // ==================================================
    // Sequential logic
    // ==================================================
    integer i;
    integer ib;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<NUM_CH; i=i+1)
                ch_prev_m2s[i] <= {RAM_DWIDTH{1'b0}};
            ch_ack_1cycle <= {NUM_CH{1'b0}};
            pend          <= {NUM_CH{1'b0}};
            for (ib=0; ib<NUM_BOARDS; ib=ib+1) begin
                state_b[ib]      <= ST_IDLE;
                owner_b[ib]      <= {OW{1'b0}};
                last_owner_b[ib] <= {OW{1'b0}};
            end
        end else begin
            // --- 每通道锁存上一次 m2s 值 ---
            for (i=0; i<NUM_CH; i=i+1)
                ch_prev_m2s[i] <= m2s_eff[i];

            // --- 每通道产生ACK 脉冲 / pending 更新（按通道独立判断） ---
            // ACK 来临时若同值则保留 pending，保证流水下一条消息不漏
            // m2s 归零表示该通道无有效数据，立即清除 pending，避免死锁
            for (i=0; i<NUM_CH; i=i+1) begin
                if (state_b[i/CH_PER_BOARD] == ST_BUSY
                    && owner_b[i/CH_PER_BOARD] == (i % CH_PER_BOARD)
                    && rflag_hit[i/CH_PER_BOARD]) begin
                    ch_ack_1cycle[i] <= 1'b1;
                    if (!(ch_to_nonzero[i] || ch_ack_same_retry[i]))
                        pend[i] <= 1'b0;
                end else begin
                    ch_ack_1cycle[i] <= 1'b0;
                    if (ch_to_nonzero[i] || ch_ack_same_retry[i])
                        pend[i] <= 1'b1;
                    else if (~|m2s_eff[i])
                        pend[i] <= 1'b0;
                end
            end

            // --- 每板 FSM 转移并校验：IDLE->BUSY->(产生 ACK)->IDLE ---
            for (ib=0; ib<NUM_BOARDS; ib=ib+1) begin
                case (state_b[ib])
                    ST_IDLE: begin
                        if (grant_v[ib]) begin
                            state_b[ib]      <= ST_BUSY;
                            owner_b[ib]      <= grant_i[ib];
                            last_owner_b[ib] <= grant_i[ib];
                        end
                    end

                    ST_BUSY: begin
                        if (rflag_hit[ib] || (~|m2s_eff[ib*CH_PER_BOARD + owner_b[ib]]))
                            state_b[ib] <= ST_IDLE;
                    end

                    default: state_b[ib] <= ST_IDLE;
                endcase
            end
        end
    end

    // ==================================================
    // Output mux/demux (combinational) - 持续输出
    //
    // owner_b 在 BUSY->IDLE 后保持不变，继续传 r_flag 给通道
    // 事实原因：PS 读 depot 的操作可能晚于 flow 前级信号
    // FSM/pend 均以 BUSY 时收到 ACK 为准
    //
    // m2s:  sh_m2s_msg[b] = b 板 owner 通道数据（仲裁并消除冲突）
    // s2m:  ch_s2m_msg[b][k] = sh_s2m_msg[b]（广播扇出）
    // flag: 全局广播扇出（flow_comp 内部有 slv_board_id 过滤）
    // r_flag: 只有 b 板的 owner 通道收到 rflag_hit[b]
    // ==================================================
    integer ob;
    integer ok;

    always @(*) begin
        for (ob=0; ob<NUM_BOARDS; ob=ob+1) begin
            sh_rs485_m2s_msg[ob] = m2s_eff[ob*CH_PER_BOARD + owner_b[ob]];
            for (ok=0; ok<CH_PER_BOARD; ok=ok+1) begin
                ch_rs485_r_flag[ob][ok]  = 1'b0;
                ch_rs485_flag[ob][ok]    = sh_rs485_flag;
                ch_rs485_s2m_msg[ob][ok] = sh_rs485_s2m_msg[ob];
            end
            ch_rs485_r_flag[ob][owner_b[ob]] = rflag_hit[ob];
        end
    end

endmodule
