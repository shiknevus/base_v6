`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  
// 
// Create Date: 2025/06/17 09:15:38
// Design Name: 
// Module Name: ec_ethercat_servo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 支持毛重/净重读取、中断管理、寄存器映射
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 行为1：读毛重
// 行为2：读净重
//////////////////////////////////////////////////////////////////////////////////
`include "components_param.vh"
`include "para_reg_addr.vh"
module ec_xgn_dzc#(

     parameter  REG_SPACE_BIAS = 200
    ,parameter  REG_SPACE_SIZE = 512
    ,parameter  P_MODULE_ID    = 8'd7
    ,parameter  P_SEAT_NUM     = 4'd1
    ,parameter  COMP_TYPE      = 4'd1 // 组件类型: 1:控制流组件, 2:线体组件, 3:皮带组件
    //称重
    ,parameter  TIME_1MS_TIMER = 100000
    ,parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  LOCK_SCAN_ADDR  =  0
)(
    input                    clk
   ,input                   reset   
   ,input                   aurora_clk
   ,input                   aurora_reset
   ,input                   i_time_1ms_vld
   ,input                   i_time_1s_vld
   // FLOW INTERFACE
   ,input  wire             i_st_start
   ,input  wire             i_st_stop
   ,input  wire [23:0]      i_st_flow
   ,input  wire [15:0]      i_st_func
   ,input  wire [31:0]      i_loop_times
   ,input  wire [7:0]       i_next_beh
   ,output reg  [7:0]       o_next_beh
   ,output wire [3:0]       o_st_seat
   ,output reg              o_st_start
   ,output wire             o_st_busy
   ,output reg              o_st_done
   ,output wire [31:0]      o_st_result
   
   ,input  wire             i_st_wr_en
   ,input  wire [19:0]      i_st_wr_addr
   ,input  wire [31:0]      i_st_wr_data
   ,input  wire             i_st_rd_en
   ,input  wire [19:0]      i_st_rd_addr
   ,output reg              o_st_rd_vld
   ,output reg  [31:0]      o_st_rd_data
   ,output wire             o_intr_irq

   // io interface
   ,output  wire            o_user_req
   ,input  wire             i_user_grant
   ,input  wire             i_uart_rx
   ,output wire             o_uart_tx
   ,output wire             o_uart_de


    );
    
   localparam BEHA_TYPE_0 = 4'd0;  // 主动行为
   localparam BEHA_TYPE_1 = 4'd1;  // 定时行为
   localparam BEHA_TYPE_2 = 4'd2;  // 条件行为

   reg  rd_en_d1;
   reg  rd_en_d2;
   wire rd_space_select;
   wire wr_space_select;
   wire wr_task_vld;
   reg  [19:0] rd_addr_d1;
   reg  [19:0] rd_addr_d2;
   wire [19:0] rd_task_addr;
   wire [19:0] wr_task_addr;
   
   assign  rd_space_select = ((i_st_rd_addr >= REG_SPACE_BIAS) & (i_st_rd_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'b1 : 1'b0;
   assign  wr_space_select = ((i_st_wr_addr >= REG_SPACE_BIAS) & (i_st_wr_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'b1 : 1'b0;
   assign  rd_task_addr = i_st_rd_addr - REG_SPACE_BIAS;
   assign  wr_task_addr = i_st_wr_addr - REG_SPACE_BIAS;
   assign  wr_task_vld  = wr_space_select & i_st_wr_en;
   
   // for register read
   always @(posedge clk)begin
       rd_en_d1  <= i_st_rd_en & rd_space_select;
       rd_en_d2  <= rd_en_d1;
       o_st_rd_vld  <= rd_en_d2;
   end
    
   always @(posedge clk)begin
       rd_addr_d1 <= rd_task_addr;
       rd_addr_d2 <= rd_addr_d1;
   end
    
   // write register
   reg [ 3: 0] unit_emergency_ctrl         ;
   reg [ 3: 0] unit_status                 ;
   
   reg [ 3: 0] equipment_emergency_ctrl    ;
   reg [ 3: 0] equipment_status            ;
   reg [15: 0] equipment_id                ;
   reg [ 3: 0] set_work_mode  ;
   reg [ 0: 0] local_security              ;
   reg [ 0: 0] link_security  ;
   reg [ 0: 0] task_occupy                 ;
   
   reg [ 0: 0] reg_reset_n;
   reg [ 0: 0] link_lock;   
   reg [31 :0] rcfg_timeout;
   reg [ 0: 0] reg_execu_valid;
   reg [31: 0] reg_execu_func; 
   reg [31: 0] rintr_status[1:0];
   
   reg [31 :0] reg_heart_time;
   reg [31 :0] reg_gather_time[7:0];
//   reg        ex_act_valid;
   reg        heart_error;
   reg        heart_status_ack;
   reg        gather_error;
   reg        gather_status_ack;
   
// 称重专用寄存器
reg              reset_done;
reg              rserv_safety;
reg              r_task_start;
reg  [31:0]      r_task_func; 
reg  [15:0]      rintr_status_seat[P_SEAT_NUM:0];
reg  [15:0]      rcfg_timedly[P_SEAT_NUM:1];
reg              rintr_irq_latch;
reg              ridle_irq;
reg              ridle_irq_latch;
reg  [1:0]       rintr_irq_d;
reg  [7:0]       station_select;

   always@(posedge clk) begin
       if(reset) begin
           unit_emergency_ctrl       <= 'b0;
           unit_status               <= 'b0;
           
           equipment_emergency_ctrl <= 'b0;
           equipment_status         <= 'b0; //0:IDLE  1:BUSY   2:ALARM
           equipment_id             <= 'b0;
           set_work_mode            <= 'b1;  // == 1:single auto, == 2:link auto, == 3:manual
           local_security           <= 'b0;
           link_security            <= 1'b1;
           task_occupy              <= 'b0;
           
           reg_reset_n              <= 1'b0;
           link_lock                <= 1'b0;
           rcfg_timeout             <= 60;
           reg_execu_valid          <= 1'b0;
           reg_execu_func           <= 0;
           rintr_status[0]          <= 0;
           rintr_status[1]          <= 0;
           
           reg_heart_time           <= 0;
           
           reg_gather_time[0]       <= 0;
           reg_gather_time[1]       <= 0;
           reg_gather_time[2]       <= 0;
           reg_gather_time[3]       <= 0;
           reg_gather_time[4]       <= 0;
           reg_gather_time[5]       <= 0;
           reg_gather_time[6]       <= 0;
           reg_gather_time[7]       <= 0;
//           ex_act_valid             <= 0;
           heart_error              <= 0;
           gather_error             <= 0;
           heart_status_ack         <= 0;
           gather_status_ack        <= 0;
            // 称重专用寄存器初始化
            reset_done   <= 1'b0;
            rserv_safety <= 1'b0;
            r_task_start <= 1'b0;
            r_task_func  <= 0;
            rintr_status_seat[0] <= 0;
            rintr_status_seat[1] <= 0;
            rintr_status_seat[2] <= 0;
            rintr_status_seat[3] <= 0;
            rintr_status_seat[4] <= 0;
            rcfg_timedly[1] <= 60000;
            rcfg_timedly[2] <= 60000;
            rcfg_timedly[3] <= 60000;
            rcfg_timedly[4] <= 60000;
            station_select <= 1;
           
       end else begin 
//单元紧急控制	    UNIT_EMERGENCY_CTRL		  写	控制单元急停/暂停/开线/停线
//单元状态	        UNIT_STATUS		          写	空闲/执行中/单元报警
//设备紧急控制	    EQUIPMENT_EMERGENCY_CTRL  写	控制设备急停/暂停/开线/停线
//设备状态	        EQUIPMENT_STATUS		  写	空闲0/执行中1/设备报警2
//设备编号	        EQUIPMENT_ID		      读	
//工作模式设置	    SET_WORK_MODE		      读/写	单机1/联线2/手动3/关机4（ARM设置寄存器，外部旋钮）
//本地安全	        LOCAL_SECURITY		      读/写	本地组件触发设备处于不安全的状态
//关联安全	        LINK_SECURITY		      写	其他设备向本设备传输的状态
//任务占用	        TASK_OCCUPY		          读/写	
//复位使能	        ENABLE		              写	控制组件复位使能
//关联锁定	        LINK_LOCK		          写	解锁/锁定
//执行最大时间设置	EXECU_TIME		          写	每个行为对应一个执行超时时间
//执行许可	        EXECU_VALID	  	          写	
//许可行为编号	    BEH_ID		              写	行为编号,任务编号
//组件状态	        COMP_STATUS		          读	空闲/准备中/执行中/组件报警
//应答寄存器	    ACT_NT_REG		          写	交互应答
//中断信息	        INTR_INFO0/INTR_INFO1	  读	两个寄存器，包括任务编号，组件编号，行为编号，中断类型，组件类型，行为动作编号
//告警信息	        ALARM_INFO		          读	告警编号，对应实际的报警信息

             unit_emergency_ctrl      <= (wr_task_vld & wr_task_addr== `UNIT_EMERGENCY_CTRL      ) ? i_st_wr_data[3:0] : unit_emergency_ctrl; 
             unit_status              <= (wr_task_vld & wr_task_addr== `UNIT_STATUS              ) ? i_st_wr_data[3:0] : unit_status; 
             
             equipment_emergency_ctrl <= (wr_task_vld & wr_task_addr== `EQUIPMENT_EMERGENCY_CTRL ) ? i_st_wr_data[3:0] : equipment_emergency_ctrl; 
             equipment_status         <= (wr_task_vld & wr_task_addr== `EQUIPMENT_STATUS         ) ? i_st_wr_data[3:0] : equipment_status; 
             equipment_id             <= (wr_task_vld & wr_task_addr== `EQUIPMENT_ID             ) ? i_st_wr_data[3:0] : equipment_id; 
             set_work_mode            <= (wr_task_vld & wr_task_addr== `SET_WORK_MODE            ) ? i_st_wr_data[3:0] : set_work_mode; 
             local_security           <= (wr_task_vld & wr_task_addr== `LOCAL_SECURITY           ) ? i_st_wr_data[3:0] : local_security; 
             link_security            <= (wr_task_vld & wr_task_addr== `LINK_SECURITY            ) ? i_st_wr_data[0] : link_security; 
             task_occupy              <= (wr_task_vld & wr_task_addr== `TASK_OCCUPY              ) ? i_st_wr_data[0] : task_occupy; 
             
             reg_reset_n              <= (wr_task_vld & wr_task_addr== `RSERV_SAFETY             ) ? i_st_wr_data[0] : reg_reset_n; 
             link_lock                <= (wr_task_vld & wr_task_addr== `LINK_LOCK                ) ? i_st_wr_data[0] : link_lock; 
             rcfg_timeout             <= (wr_task_vld & wr_task_addr== `BH_TIMEOUT               ) ? i_st_wr_data[31:0] : rcfg_timeout;
//             reg_execu_valid          <= (wr_task_vld & wr_task_addr== `TASK_START               ) ? i_st_wr_data[0]    : 1'b0;
             reg_execu_valid          <= (wr_task_vld & wr_task_addr== `TASK_FUNC                ) ? ((i_st_wr_data[7:0]>0)&&(i_st_wr_data[7:0]<129)) : 1'b0;
             reg_execu_func           <= (wr_task_vld & wr_task_addr== `TASK_FUNC                ) ? i_st_wr_data[31:0] : reg_execu_func;
             rintr_status[0]          <= (wr_task_vld & wr_task_addr== `RINTR_STATUS             ) ? i_st_wr_data[31:0] : 0;
             rintr_status[1]          <= (wr_task_vld & wr_task_addr== `RINTR_STATUS1            ) ? i_st_wr_data[31:0] : 0;
             
             reg_heart_time           <= (wr_task_vld & wr_task_addr== `HEART_TIME               ) ? i_st_wr_data[31:0] : reg_heart_time;
             heart_error              <= (wr_task_vld & wr_task_addr== `HEART_STATUS             ) ? i_st_wr_data[31:0] : heart_error;
             heart_status_ack         <= (wr_task_vld & wr_task_addr== `HEART_STATUS             ) ? 1'b1 : 0;
             reg_gather_time[0]       <= (wr_task_vld & wr_task_addr== `GATHER_TIME              ) ? i_st_wr_data[31:0] : reg_gather_time[0];
             gather_error             <= (wr_task_vld & wr_task_addr== `GATHER_STATUS            ) ? i_st_wr_data[31:0] : gather_error;
             gather_status_ack        <= (wr_task_vld & wr_task_addr== `GATHER_STATUS            ) ? 1'b1 : 0;
//             ex_act_valid             <= (wr_task_vld & wr_task_addr== `EXT_ACT                  ) ? i_st_wr_data[31:0] : ex_act_valid;
            
            // 称重专用寄存器写逻辑
            // reset_done            <= (wr_task_vld & wr_task_addr== `RSERV_SAFETY) ? i_st_wr_data[0] : 1'b0;
            // rserv_safety          <= (wr_task_vld & wr_task_addr== `RSERV_SAFETY) ? i_st_wr_data[0] : rserv_safety; 
            // r_task_start          <= (wr_task_vld & wr_task_addr== `TASK_START) ? i_st_wr_data[0] : 1'b0;
            // r_task_func           <= (wr_task_vld & wr_task_addr== `TASK_FUNC) ? i_st_wr_data[31:0] : r_task_func;
            // rintr_status_seat[0]  <= (wr_task_vld & wr_task_addr== `RINTR_STATUS) ? i_st_wr_data[15:0] : 0;
            // rcfg_timedly[1]       <= (wr_task_vld & wr_task_addr== `BH_TIMEDLY_1 ) ? i_st_wr_data[15:0] : rcfg_timedly[1];
            station_select        <= (wr_task_vld & wr_task_addr== `STATION_SEL  ) ? i_st_wr_data[7:0]  : station_select;

       end
   end
   
// ----------------------------------------- Register set done -----------------------------------------
  
   
// ----------------------------------------- Button Detect Start -----------------------------------------
   wire ps_reg_clk   = clk;
   wire ps_reg_reset = !reg_reset_n;
    
   // wire emerge_stop_key_value;
   // wire emerge_stop_key_trigger;
   // key_debounce #(
   //  .DELAY_TIME(15) // ms :filter time
   // )u_emerge_stop(
   //  .sys_clk        (ps_reg_clk), 
   //  .sys_rst_n      (~ps_reg_reset),
   //  .i_time_1ms_vld (i_time_1ms_vld),
   //  .i_time_1s_vld (i_time_1s_vld)
    
   //  ,.iv_rcfg_timeout     ( rcfg_timeout      )  // 单位s，电平保持时，超过该时间，退出重新检测
   //  ,.iv_int_delay_time   ( 1     )  // ms,满足被动触发条件后，延时该时间，在发起中断
   //  ,.iv_silence_period   ( 20    )  // 触发后静默时间
   //  ,.iv_valid_level_time ( 500   )  // ms,高低电平一直有效改时间后表示有效电平触发生效
   //  ,.iv_trigger_mode     ( 0     )  // 0:上升沿，1：下降沿，2：高电平，3：低电平, 4:双边沿触发
    
   //  ,.key             ( i_emerge_stop_signal    )
   //  ,.key_value       ( emerge_stop_key_value    )
   //  ,.o_key_trigger   ( emerge_stop_key_trigger   )
   //  );
    

   // wire reset_key_value;
   // wire reset_key_trigger;
   // key_debounce #(
   //  .DELAY_TIME(15) // ms :filter time
   // )u_reset_key(
   //  .sys_clk        (ps_reg_clk), 
   //  .sys_rst_n      (~ps_reg_reset),
   //  .i_time_1ms_vld (i_time_1ms_vld),
   //  .i_time_1s_vld (i_time_1s_vld)
    
   //  ,.iv_rcfg_timeout     ( rcfg_timeout      )  // 单位s，电平保持时，超过该时间，退出重新检测
   //  ,.iv_int_delay_time   ( 50    )  // ms,满足被动触发条件后，延时该时间，在发起中断
   //  ,.iv_silence_period   ( 100   )  // 触发后静默时间
   //  ,.iv_valid_level_time ( 500   )  // ms,高低电平一直有效改时间后表示有效电平触发生效
   //  ,.iv_trigger_mode     ( 0     )  // 0:上升沿，1：下降沿，2：高电平，3：低电平, 4:双边沿触发
    
   //  ,.key             ( i_reset_signal      )
   //  ,.key_default     ( i_reset_signal    )
   //  ,.key_value       ( reset_key_value     )
   //  ,.o_key_trigger   ( reset_key_trigger   )
   //  );
    
    
   // wire stop_start_key_value;
   // wire stop_start_key_trigger;
   // key_debounce #(
   //  .DELAY_TIME(15) // ms :filter time
   // )u_stop_start_key(
   //  .sys_clk        (ps_reg_clk), 
   //  .sys_rst_n      (~ps_reg_reset),
   //  .i_time_1ms_vld (i_time_1ms_vld),
   //  .i_time_1s_vld (i_time_1s_vld)
    
   //  ,.iv_rcfg_timeout     ( rcfg_timeout      )  // 单位s，电平保持时，超过该时间，退出重新检测
   //  ,.iv_int_delay_time   ( 1    )  // ms,满足被动触发条件后，延时该时间，在发起中断
   //  ,.iv_silence_period   ( 1   )  // 触发后静默时间
   //  ,.iv_valid_level_time ( 500   )  // ms,高低电平一直有效改时间后表示有效电平触发生效
   //  ,.iv_trigger_mode     ( 4     )  // 0:上升沿，1：下降沿，2：高电平，3：低电平, 4:双边沿触发
    
   //  ,.key             ( i_stop_start_singal      )
   //  ,.key_value       ( stop_start_key_value     )
   //  ,.o_key_trigger   ( stop_start_key_trigger   )
   //  );
   


   // wire auto_manual_rising_trigger;
   // key_debounce #(
   //  .DELAY_TIME(20) // ms :filter time
   // )u_auto_manual_rising_sig(
   //  .sys_clk        (ps_reg_clk     ), 
   //  .sys_rst_n      (~ps_reg_reset  ),
   //  .i_time_1ms_vld (i_time_1ms_vld ),
   //  .i_time_1s_vld  (i_time_1s_vld  )
    
   //  ,.iv_rcfg_timeout     ( rcfg_timeout      )  // 单位s，电平保持时，超过该时间，退出重新检测
   //  ,.iv_int_delay_time   ( 10    )  // ms,满足被动触发条件后，延时该时间，在发起中断
   //  ,.iv_silence_period   ( 10   )  // 触发后静默时间
   //  ,.iv_valid_level_time ( 10   )  // ms,高低电平一直有效改时间后表示有效电平触发生效
   //  ,.iv_trigger_mode     ( 0     )  // 0:上升沿，1：下降沿，2：高电平，3：低电平, 4:双边沿触发
    
   //  ,.key             ( i_auto_manual_singal      )
   //  ,.key_default     ( 1'b0    )
   //  ,.key_value       (      )
   //  ,.o_key_trigger   ( auto_manual_rising_trigger   )
   //  );
    
   
   // wire auto_manual_falling_trigger;
   // key_debounce #(
   //  .DELAY_TIME(20) // ms :filter time
   // )u_auto_manual_falling_sig(
   //  .sys_clk        (ps_reg_clk     ), 
   //  .sys_rst_n      (~ps_reg_reset  ),
   //  .i_time_1ms_vld (i_time_1ms_vld ),
   //  .i_time_1s_vld  (i_time_1s_vld  )
    
   //  ,.iv_rcfg_timeout     ( rcfg_timeout      )  // 单位s，电平保持时，超过该时间，退出重新检测
   //  ,.iv_int_delay_time   ( 10    )  // ms,满足被动触发条件后，延时该时间，在发起中断
   //  ,.iv_silence_period   ( 10   )  // 触发后静默时间
   //  ,.iv_valid_level_time ( 10   )  // ms,高低电平一直有效改时间后表示有效电平触发生效
   //  ,.iv_trigger_mode     ( 1     )  // 0:上升沿，1：下降沿，2：高电平，3：低电平, 4:双边沿触发
    
   //  ,.key             ( i_auto_manual_singal      )
   //  ,.key_default     ( 1'b0    )
   //  ,.key_value       (      )
   //  ,.o_key_trigger   ( auto_manual_falling_trigger   )
   //  );
// ----------------------------------------- Button Detect End -------------------------------------------

//=========== weight ctrl ============================================================================

localparam INTR_TYPE_BEHA_ACT = 8'd1;
localparam INTR_TYPE_TASK_ACT = 8'd3;
localparam ACT_START        = 8'd10;
localparam ACT_EXE          = 8'd20;
localparam ACT_CHECK        = 8'd25;
localparam ACT_DONE         = 8'd30;
localparam ACT_ALARM        = 8'd40;
localparam ACT_NOTE         = 8'd50;

localparam ACTION_DELAY     = 12;   // 12ms

localparam ALARM_DRIVE         = 8'd100;
// localparam ALARM_LIM_F         = 8'd101; //正极限超限
// localparam ALARM_LIM_B         = 8'd102; //负极限超限
localparam ALARM_READ_WEIGHT_FAIL    = 8'd101; // 毛重报警
localparam ALARM_READ_WEIGHT_2_FAIL  = 8'd102; // 净重报警
localparam ALARM_ESTOP               = 8'd112;
localparam ALARM_BEHATMOUT           = 8'd120;

localparam ALARM_ING                = 8'd200; //ALARMING
localparam ALARM_NOT_ENB            = 8'd201; //NOT_ENB
localparam ALARM_BUSY               = 8'd202; //BUSY
localparam ALARM_LOCK               = 8'd203; //LINK_LOCK
localparam ALARM_MANUAL             = 8'd204; //MANUAL 

reg [7:0] beh_number        ;
reg [7:0] curr_beh_number   ;
reg [7:0] last_beh_number   ;
reg [7:0] last_2_beh_number ;
reg [7:0] last_3_beh_number ;

reg [7:0] alarm_type        ;

reg       irq_normal        ;
reg       irq_alarm_pl      ;
reg [7:0] irq_normal_type   ;
reg [1:0] edge_irq_normal   ;

reg       irq_alarm_ps      ;
reg [1:0] edge_irq_alarm_ps ;
reg       irq_done          ;
reg       irq_redo          ;
reg       beh_redo          ;
reg       beh_redo_in_process;

reg       irq_in_procss     ;
wire      irq_busy          ;
wire      irq_alarm         ;
reg       irq_alarm_in_process ;
reg [7:0] alarm_type_pl     ;


//==============weight_ctrl  =======================================================================
wire [ 1:0] execu_result     ;
wire        execu_result_vld ;
reg         cmd_start        ;
reg  [ 2:0] act_cmd          ;
wire [63:0] r_weight         ;

ex_xgn_rs485_weight_ctrl #(
 .RAM_DEPTH             (RAM_DEPTH          ) 
,.RAM_DWIDTH            (RAM_DWIDTH         )
)U_ex_xgn_rs485_weight_ctrl(
  .ps_reg_clk           (ps_reg_clk         )
 ,.ps_reg_reset         (ps_reg_reset       )
 ,.i_time_1s_vld        (i_time_1s_vld      )
 ,.i_time_1ms_vld       (i_time_1ms_vld     )
 ,.rcfg_timeout         (rcfg_timeout       )
 
 ,.o_user_req           (o_user_req         )
 ,.i_user_grant         (i_user_grant       )
 ,.i_uart_rx            (i_uart_rx          )
 ,.o_uart_tx            (o_uart_tx          )
 ,.o_uart_de            (o_uart_de          )

 ,.iv_station_select    (station_select     )//sub addr
 ,.ov_weight            (r_weight           )
 ,.i_cmd_start          (cmd_start          ) 
 ,.iv_act_cmd           (act_cmd            ) 
 ,.ov_execu_result      (execu_result       )
 ,.o_execu_result_vld   (execu_result_vld   )

);

//==============任务解析与调度  =====================================================
   reg          estop       ;
   reg [23:0]   estop_cnt   ;
   reg [7:0]    task_index  ;
   reg [15:0]   task_id     ; // 任务编程编号
   reg [7:0]    rintr_type  ;
   reg [7:0]    rintr_action;
   reg [7:0]    rintr_beha  ;

   reg          action_done ;
   reg          done_done   ;
   reg          comp_irq    ;
 
   reg          execu_timeout;
   reg [1:0]    edge_comp_irq;

// 结果输出
   reg   busy;
   wire  st_busy = 1'b0;

   assign o_st_busy = st_busy | busy ;
   assign o_st_result = {task_index,task_id   ,8'd0};
   // assign o_intr_irq = edge_comp_irq==2'b01 ; // interrupt valid in rising edge 

   assign irq_busy = irq_normal | irq_alarm_pl | irq_alarm_ps | irq_in_procss ;
   assign irq_alarm = irq_alarm_pl | irq_alarm_ps | irq_alarm_in_process ;

//任务参数解析
   reg [31:0] loop_times;
//    reg [3:0]  seat_id   ;
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         task_index <= 'b0 ;
         task_id    <= 'b0 ;
         rintr_type <= 'b0 ;
         rintr_beha <= 'b0 ;
//         seat_id    <= 'b0 ;
         o_next_beh <= 'b0 ;
         loop_times <= 'b0 ;
      end
      else begin
        if(curr_beh_number > 8'd1 && beh_number == 8'd1) begin
               task_index <= 'd0;
               task_id    <= 'd0;
               rintr_type <= INTR_TYPE_BEHA_ACT ;
               rintr_beha <= reg_execu_func[7:0] ;
               o_next_beh <= 'b0 ;
               loop_times <= i_loop_times ;
//                seat_id    <= <= i_st_func[11:8] ;
        end 
        else if(beh_number == 8'd1) begin//仅在待机状态
            if(i_st_start) begin//流程启动触发
                task_index <= i_st_flow[23:16] ;  
                task_id    <= i_st_flow[15:0] ;   
                rintr_type <= INTR_TYPE_BEHA_ACT ;
                rintr_beha <= i_st_func[7:0] ;    
//                seat_id    <= <= i_st_func[11:8] ;
                o_next_beh <= i_next_beh ;        
                loop_times <= i_loop_times ;
            end
            else if(reg_execu_valid) begin // arm启动触发
               task_index <= reg_execu_func[31:24] ;
               task_id    <= reg_execu_func[23:8] ;
               rintr_type <= INTR_TYPE_BEHA_ACT ;
               rintr_beha <= reg_execu_func[7:0] ;
//               seat_id    <= i_st_func[11:8] ;
               o_next_beh <= i_next_beh;
               loop_times <= i_loop_times ;
            end
         end
      end
   end
   
//执行主题（FPFA/ARM协同）   
   reg       int_disable;
   reg       fpga_execu;
   reg       arm_execu;
   reg [2:0] fpga_beh;
   always @(*)begin
        case(rintr_beha[7:0])
            1,2:begin// 行为编号1-2：FPGA执行，不禁用中断
                fpga_execu = 1'b1;
                arm_execu = 1'b0;
                fpga_beh = rintr_beha[2:0];
                int_disable = 1'b0;
            end
            3,4,5:begin// 行为编号3-5：FPGA执行，禁用中断
                fpga_execu = 1'b1;
                arm_execu = 1'b0;
                fpga_beh = rintr_beha[2:0];
                int_disable = 1'b1;
            end
            default:begin// 其他行为编号：ARM执行
                fpga_execu = 1'b0;
                arm_execu = 1'b1;
                fpga_beh = 'd0;
                int_disable = 'd0;
            end
        endcase
   end

//执行开始
   reg execu_valid ; 
   reg st_stop     ;
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         execu_valid <= 'b0 ;
         o_st_start  <= 'b0 ;
         o_st_done   <= 'b0 ;
      end
      else begin
         
         if(link_lock)begin
            execu_valid <= 'b0 ;
            o_st_start  <= 'b0 ;
         end else if((reg_execu_valid || i_st_start) && beh_number == 8'd1) begin
            execu_valid <= 'b1 ;
            o_st_start  <= 'b1 ;
         end
         else if(beh_number == 8'd2 || irq_alarm || i_st_stop) begin
            execu_valid <= 'b0 ;
            o_st_start  <= 'b0 ;
         end
         else begin
            execu_valid <= execu_valid ;
            o_st_start  <= 'b0 ;
         end

         if(i_st_stop) begin
            st_stop <= 'b1 ;
         end
         else if(beh_number == 8'd1) begin
            st_stop <= 'b0 ;
         end
         else begin
            st_stop <= st_stop ;
         end
         
         if(curr_beh_number > 8'd1 && beh_number == 8'd1) begin
            o_st_done <= 'b1 ;
         end
         else begin
            o_st_done <= 'b0 ;
         end
      end
   end
   
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         beh_redo <= 'b0 ;
      end else begin
        if(irq_redo)
            beh_redo <= 1'b1;
        else if(beh_redo_in_process)
            beh_redo <= 'b0;
        else 
            beh_redo <= beh_redo ;
      end
   end

   
   always @ (posedge ps_reg_clk)
   begin
      curr_beh_number <= beh_number ;
      
      if(beh_number != curr_beh_number) begin
         last_beh_number <= curr_beh_number ;
         last_2_beh_number <= last_beh_number ;
         last_3_beh_number <= last_2_beh_number ;
      end
      else begin
         last_beh_number <= last_beh_number ;
         last_2_beh_number <= last_2_beh_number ;
         last_3_beh_number <= last_3_beh_number ;
      end
  end
    
   wire  auto_manual;
   //set_work_mode == 1:single auto, == 2:link auto, == 3:manual
   assign auto_manual = set_work_mode == 3;
//   assign auto_manual = i_auto_manual_singal;
  
//    wire fpga_exec = rintr_beha == 2; // beha==2,寻零行为
   
   
//    reg [7:0] servo_limb_n;
//    reg [7:0] servo_limf_n;
//    wire rising_limb = servo_limb_n[0]&(~servo_limb_n[7]);
//    wire rising_limf = servo_limf_n[0]&(~servo_limf_n[7]);
//    always @ (posedge ps_reg_clk)
//    begin
//       if(ps_reg_reset) begin
//          servo_limb_n  <= 'b0 ;
//          servo_limf_n  <= 'b0 ;
//       end
//       else begin
//          servo_limb_n  <= {servo_limb_n[6:0],i_servo_limb} ;
//          servo_limf_n  <= {servo_limf_n[6:0],i_servo_limf} ;
//       end
//    end
   
   reg [22:0] status_list ;
   //new add
   reg start_in_process     ;
   reg start_in_process_n   ;
   reg execu_in_process     ;
   reg action_in_process    ;
   reg action_timeout       ;
   reg ps_alarm             ;
   reg ps_alarm_in_process  ;

   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         status_list <= 'b0 ;
      end
      else begin
        status_list[0] <= link_security;//rserv_safety ;
        status_list[1] <= 1'b0;//  emerge stop 
        status_list[2] <= irq_busy ;
        status_list[3] <= irq_alarm ;
        
        status_list[4] <= ps_alarm  ;
        status_list[5] <= execu_valid  ;        // st_start
        status_list[6] <= i_st_stop ;           // auto_manual;       
        status_list[7] <= start_in_process ;
        
        status_list[8] <= action_done ;
        status_list[9] <= action_timeout ;
        status_list[10] <= done_done ;
        status_list[11] <= execu_timeout ;
        
        status_list[12] <= action_in_process ;
        status_list[13] <= link_lock;//1'b0 ;
        status_list[14] <= fpga_execu ;
        status_list[15] <= arm_execu ;
        
        status_list[16] <= fpga_beh[0];
        status_list[17] <= fpga_beh[1];
        status_list[18] <= fpga_beh[2];
        status_list[19] <= execu_result_vld ;
        
        status_list[20] <= execu_result[0] ;
        status_list[21] <= execu_result[1] ;
        status_list[22] <= beh_redo ;
   
      end
   end
      
   localparam COMP_RESET_STATE            = 23'b0xx_xxxx_xxxx_xxxx_xxxx_xxx0 ;
   localparam COMP_IDLE_STATE             = 23'b0xx_xxxx_xxxx_x1xx_x000_00x1 ;
   localparam COMP_START_STATE            = 23'b0xx_xxxx_xxxx_x1x0_001x_00x1 ;
   localparam BEH_REDO                    = 23'b1xx_xxxx_xxxx_xxxx_xxxx_0001 ;
                                                
   localparam DEVICE_READ_1_START         = 23'b0xx_0001_01xx_x0x0_10xx_0001 ;
   localparam DEVICE_READ_1_SUCCESS       = 23'b001_1001_01xx_x0x0_0xxx_0001 ;
   localparam DEVICE_READ_1_FAIL          = 23'b01x_1001_01xx_x0x0_0xxx_0001 ;
   
   localparam DEVICE_READ_2_START         = 23'b0xx_0010_01xx_x0x0_10xx_0001 ;
   localparam DEVICE_READ_2_SUCCESS       = 23'b001_1010_01xx_x0x0_0xxx_0001 ;
   localparam DEVICE_READ_2_FAIL          = 23'b01x_1010_01xx_x0x0_0xxx_0001 ;
                                          
   localparam PS_ALARM                    = 23'bxxx_xxxx_xxxx_xxxx_xxx1_xx0x ;
   localparam COMP_DONE_STATE             = 23'bxxx_xxxx_xx0x_0011_x0xx_0001 ;
   localparam COMP_STOP_STATE             = 23'b0xx_xxxx_xxxx_xxxx_x1xx_xx01 ;  // 外部停止
   localparam COMP_ESTOP_STATE            = 23'bxxx_xxxx_xxx1_xxxx_xxxx_xx1x ;  // 外部急停
   localparam COMP_TIMEOUT_STATE          = 23'bxxx_xxxx_xxx1_1xxx_xxxx_xx01 ;  // 行为超时
                           
   
   reg [7:0] done_beha;
   
      always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         beh_number <= 'd0 ;
         irq_normal <= 'b0 ;
         irq_normal_type  <= 'b0 ;
         irq_alarm_pl     <= 'b0 ;
         alarm_type_pl    <= 'b0;
         start_in_process <= 'b0;
         execu_in_process <= 'b0;
         done_done   <= 'b1;
         action_done <= 'b0;
         ps_alarm_in_process <= 'b0;
         action_in_process   <= 'b0;
         cmd_start   <= 0;
         act_cmd     <= 0;
         beh_redo_in_process <= 'b0;
      end
      else begin

         casex(status_list)
            COMP_RESET_STATE : begin
               beh_number       <= 'd0;
               irq_normal       <= 'b0;
               irq_normal_type  <= 'b0;
               irq_alarm_pl     <= 'b0;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done    <= 'b1;
               action_done  <= 'b0;
               ps_alarm_in_process  <= 'b0;
               action_in_process    <= 'b0;
               cmd_start    <= 1'b0;
               act_cmd      <= 3'b000;
               beh_redo_in_process  <= 'b0;
            end
            
            COMP_IDLE_STATE : begin
               beh_number       <= 'd1 ;
               irq_normal       <= 'b0 ;
               irq_normal_type  <= 'b0 ;
               irq_alarm_pl     <= 'b0 ;
               alarm_type_pl    <= 'd0;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done    <= 'b1;
               action_done  <= 'b0;
               ps_alarm_in_process  <= 'b0;
               action_in_process    <= 'b0;
               cmd_start    <= 1'b0;
               act_cmd      <= 3'b000;
               beh_redo_in_process  <= 'b0;
            end
            
            COMP_START_STATE : begin
               beh_number       <= 'd2 ;
               irq_normal       <=  'b1 ;
               irq_normal_type  <= ACT_START ;
               irq_alarm_pl     <= 'b0 ;
               alarm_type_pl    <= 'd0;
               start_in_process <= 'b1;
               execu_in_process <= 'b0;
               done_done   <= 'b0;
               action_done <= 'b0;
               ps_alarm_in_process <= 'b0;
               action_in_process    <= 'b1;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
               beh_redo_in_process <= 'b0;
            end
            
            
            // ------------------------- 1 毛重----------------------
            DEVICE_READ_1_START:begin 
               beh_number <= 'd3 ;
               irq_normal <= 'b0 ;
               irq_normal_type <= 'd0;
               irq_alarm_pl  <= 'b0 ;
               alarm_type_pl <= 'd0;
               start_in_process <= 'b0;
               execu_in_process <= 'b1;
               done_done   <= 'b0;
               action_done <= 'b0;
               cmd_start   <= 1'b1;
               act_cmd     <= 3'b001;
               beh_redo_in_process <= 'b0;
            end
            
            DEVICE_READ_1_SUCCESS:begin 
               beh_number <= 'd4 ;
               irq_normal <= 'b1 ;
               irq_normal_type <= ACT_EXE;
               irq_alarm_pl  <= 'b0 ;
               alarm_type_pl <= 'd0;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b0;
               action_done <= 'b1;
               cmd_start   <= 1'b0;
               beh_redo_in_process <= 'b0;
            end
            
            DEVICE_READ_1_FAIL:begin
               beh_number <= 'd5 ;
               irq_normal <= 'b0 ;
               irq_normal_type <= 'd0;
               irq_alarm_pl  <= 'b1 ;
               alarm_type_pl <= ALARM_READ_WEIGHT_FAIL;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               beh_redo_in_process <= 'b0;
            end
               
            
            // ------------------------- 2 净重----------------------
            DEVICE_READ_2_START:begin 
               beh_number <= 'd4 ;
               irq_normal <= 'b0 ;
               irq_normal_type <= 'd0;
               irq_alarm_pl  <= 'b0 ;
               alarm_type_pl <= 'd0;
               start_in_process <= 'b0;
               execu_in_process <= 'b1;
               done_done   <= 'b0;
               action_done <= 'b0;
               cmd_start   <= 1'b1;
               act_cmd     <= 3'b010;
               beh_redo_in_process <= 'b0;
            end
            
            DEVICE_READ_2_SUCCESS:begin 
               beh_number <= 'd5 ;
               irq_normal <= 'b1 ;
               irq_normal_type <= ACT_EXE;
               irq_alarm_pl  <= 'b0 ;
               alarm_type_pl <= 'd0;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b0;
               action_done <= 'b1;
               cmd_start   <= 1'b0;
               beh_redo_in_process <= 'b0;
            end
            
            DEVICE_READ_2_FAIL:begin
               beh_number <= 'd6 ;
               irq_normal <= 'b0 ;
               irq_normal_type <= 'd0;
               irq_alarm_pl  <= 'b1 ;
               alarm_type_pl <= ALARM_READ_WEIGHT_2_FAIL;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               beh_redo_in_process <= 'b0;
            end  
            
            BEH_REDO : begin
               beh_number <= 'd15 ;
               irq_normal <= 'b1 ;
               irq_normal_type <= ACT_START ;
               irq_alarm_pl  <= 'b0 ;
               alarm_type_pl <= 'd0;
               start_in_process <= 'b1;
               execu_in_process <= 'b0;
               done_done   <= 'b0;
               action_done <= 'b0;
               ps_alarm_in_process <= 'b0;
               action_in_process   <= 'b1;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
               beh_redo_in_process <= 'b1;
            end
            

            PS_ALARM:begin
               beh_number <= 'd50 ;
               irq_normal <= 'b0 ;
               irq_normal_type <= 'd0;
               irq_alarm_pl  <= 'b0 ;
               alarm_type_pl <= 'd0;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
               ps_alarm_in_process <= 'b1;
            end
            
            COMP_DONE_STATE : begin
               beh_number <= 'd51 ;
               irq_normal <= 'b1 ;
               irq_normal_type <= ACT_DONE ;
               irq_alarm_pl <= 'b0 ;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
            end
            
            COMP_STOP_STATE : begin
               beh_number   <= 'd52 ;
               irq_alarm_pl <= 'b0 ;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
            end
            
            COMP_ESTOP_STATE : begin
               beh_number   <= 'd53 ;
               irq_alarm_pl <= 'b1 ;
               alarm_type_pl <= ALARM_ESTOP;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
            end
            
            COMP_TIMEOUT_STATE : begin
               beh_number   <= 'd54 ;
               irq_alarm_pl <= 'b1 ;
               alarm_type_pl <= ALARM_BEHATMOUT;
               start_in_process <= 'b0;
               execu_in_process <= 'b0;
               done_done   <= 'b1;
               action_done <= 'b0;
               cmd_start   <= 1'b0;
               act_cmd     <= 3'b000;
            end
            
            default : begin
               beh_number <= beh_number ;
               irq_normal <= 'b0 ;
               irq_alarm_pl <= 'b0 ;
            end
         endcase
      end
   end
 
   
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         ps_alarm <= 'b0;
      end
      else begin
         if(edge_irq_alarm_ps == 2'b01)begin
             ps_alarm <= 'b1;
         end else if(ps_alarm_in_process)begin
             ps_alarm <= 'b0;
         end
      end
   end
   
   
   wire comp_irq_grant;
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         edge_irq_normal <= 'b0 ;
         edge_irq_alarm_ps <= 'b0 ;
         comp_irq      <= 'b0 ;
         edge_comp_irq <= 'b0 ;
         irq_in_procss <= 'b0 ;
         rintr_action <= 'b0 ;
      end
      else begin
         
         edge_irq_normal    <= {edge_irq_normal[0],irq_normal} ;
         edge_irq_alarm_ps  <= {edge_irq_alarm_ps[0],irq_alarm_ps} ;
         edge_comp_irq      <= {edge_comp_irq[0],comp_irq} ;
         if(irq_normal || irq_alarm_pl || edge_irq_alarm_ps == 2'b01) begin
            comp_irq <= 'b1 ;
         end
         else if(comp_irq_grant) begin
            comp_irq <= 'b0 ;
         end
         else begin
            comp_irq <= comp_irq ;
         end
         
         if(irq_normal) begin
            rintr_action <= irq_normal_type ;
         end
         else if(irq_alarm_pl || irq_alarm_ps) begin
            rintr_action <= ACT_ALARM ;
         end
         else begin
            rintr_action <= rintr_action ;
         end
         
         if(irq_normal || irq_alarm_pl || edge_irq_alarm_ps == 2'b01) begin
            irq_in_procss <= 'b1 ;
         end
         else if(irq_done) begin
            irq_in_procss <= 'b0 ;
         end
         else begin
            irq_in_procss <= irq_in_procss ;
         end
      end
   end
   

   
   wire [ 7:0] rintr_ack_beh_id = rintr_status[1][ 7: 0];
   wire [ 7:0] rintr_ack_action = rintr_status[1][15: 8];
   wire [15:0] rintr_ack_result = rintr_status[1][31:16];
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         irq_alarm_ps <= 'b0 ;
         alarm_type <= 'b0 ;
         irq_done <= 'b0 ;
         irq_redo <= 'b0 ;
      end
      else begin
         
         if((rintr_ack_result != 0) & (rintr_ack_beh_id <= 128)) begin
            if(rintr_ack_result == `IRQ_ACK_OK) begin
               irq_alarm_ps <= 'b0 ;
               alarm_type <= 'b0 ;
               irq_done <= 'b1 ;
               irq_redo <= 'b0 ;
            end else if(rintr_ack_result == `IRQ_ACK_INVALID) begin
               irq_alarm_ps <= irq_alarm_ps ;
               alarm_type <= alarm_type ;
               irq_done <= irq_done ;
               irq_redo <= 'b0 ;
            end else if(rintr_ack_result == `IRQ_ACK_REDO)begin
               irq_alarm_ps <= 'b0 ;
               alarm_type <= 'b0 ;
               irq_done <= 'b1 ;
               irq_redo <= 'b1 ;
            end else begin
               irq_alarm_ps <= 'b1 ;
               alarm_type <= rintr_ack_result ;
               irq_done <= 'b0 ;
               irq_redo <= 'b0 ;
            end
         end
         else if(irq_alarm_pl) begin
            alarm_type <= alarm_type_pl ;
         end
         else begin
            irq_alarm_ps <= 'b0 ;
            alarm_type <= alarm_type ;
            irq_done <= 'b0 ;
            irq_redo <= 'b0 ;
         end
         
      end
   end
   

   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         irq_alarm_in_process <= 'b0 ;
      end
      else begin
         
         if(irq_alarm_pl || irq_alarm_ps) begin
            irq_alarm_in_process <= 'b1 ;
         end
         else if(irq_alarm_in_process && irq_done) begin
            irq_alarm_in_process <= 'b0 ;
         end
         else begin
            irq_alarm_in_process <= irq_alarm_in_process ;
         end
         
      end
   end
   
   reg  [31:0]  action_time_cnt;
   reg  [26:0]  rintr_onesec_count; // 10ns * 10^8 = 1 sec
   reg  [31:0]  rintr_actime;
   always @ (posedge ps_reg_clk)
   begin
      if(ps_reg_reset) begin
         execu_timeout <= 'b0 ;
//         open_close_timeout <= 'b0;
      end
      else begin
         
         if(action_done)begin
            if(action_time_cnt == ACTION_DELAY)begin
            	action_time_cnt <= action_time_cnt;
            	action_timeout <= 1'b1;
            end else begin
            	action_time_cnt <= action_time_cnt + i_time_1ms_vld;
            	action_timeout <= 1'b0;
            end
         end else begin
            action_time_cnt <= 'd0;
            action_timeout <= 'b0;
         end
         if(execu_in_process) begin
             if(rintr_actime == rcfg_timeout) begin
                 rintr_actime <= rintr_actime;
                 execu_timeout <= 'b1;
            //  end else if(i_emerge_stop_signal|i_stop_start_singal)begin
            //      rintr_actime  <= rintr_actime;
            //      execu_timeout <= execu_timeout;
             end else begin
                 rintr_actime <= rintr_actime + i_time_1s_vld;
                 execu_timeout <= 'b0;
             end
             
//             if(rintr_actime == rcfg_timeout-1) begin
//                 open_close_timeout <= 'b1;
//             end else begin
//                 open_close_timeout <= 'b0;
//             end
             
          end else begin
             rintr_actime <= 'd0;
             execu_timeout <= 'b0;
//             open_close_timeout <= 'b0;
          end
         
      end
   end

  
   
   // ----------------------------- riddle start ------------------------------
   reg [31:0] instruction0_ridle;
   reg [31:0] instruction1_ridle;
   reg [31:0] rserv_alarm_ridle;
   reg        ext_irq;
   wire       ext_irq_grant;
   
   reg [3:0] irq_state=0;
   reg [7:0] irq_cnt;
   always @(posedge ps_reg_clk)begin
        case(irq_state)
            0:begin
                if(reg_execu_valid || i_st_start)begin
                    if(ps_reg_reset)begin
                        irq_state <= 'd1;
                    end else if(irq_alarm )begin
                        irq_state <= 'd2;
                    end else if(auto_manual )begin
                        irq_state <= 'd3;
                    end else if(link_lock )begin
                        irq_state <= 'd5;
                    end else if(busy )begin
                        irq_state <= 'd4;
                    end else begin
                        irq_state <= 'd0;
                    end
                end else begin
                    irq_state    <= 'd0;
                end
                instruction0_ridle <= 'd0 ;
                instruction1_ridle <= 'd0 ;
                rserv_alarm_ridle  <= 'd0 ;
                ext_irq            <= 'd0 ;
                irq_cnt            <= 'd0 ;
            end
            1:begin
                if(ps_reg_reset)begin
                    instruction0_ridle <= {reg_execu_func[31:24],reg_execu_func[23:8],INTR_TYPE_BEHA_ACT}                          ;
                    instruction1_ridle <= {ACT_ALARM,reg_execu_func[7:0],BEHA_TYPE_2,P_MODULE_ID,COMP_TYPE} ;
                    rserv_alarm_ridle  <= {16'd0,8'b0,ALARM_NOT_ENB}                   ; // 201
                    
                end
//                 else if(i_emerge_stop_signal)begin
//                    instruction0_ridle <= {reg_execu_func[31:24],reg_execu_func[23:8],INTR_TYPE_BEHA_ACT}                          ;
//                    instruction1_ridle <= {ACT_ALARM,reg_execu_func[7:0],BEHA_TYPE_2,P_MODULE_ID,COMP_TYPE} ;
//                    rserv_alarm_ridle  <= {16'd0,8'b0,ALARM_ESTOP}                   ; // 102
//                end
                ext_irq            <= 1'b1;
                irq_cnt            <= 'd0 ;
                irq_state          <= 'd15;
            end
            2:begin
                instruction0_ridle <= {reg_execu_func[31:24],reg_execu_func[23:8],INTR_TYPE_BEHA_ACT}                          ;
                instruction1_ridle <= {ACT_ALARM,reg_execu_func[7:0],BEHA_TYPE_2,P_MODULE_ID,COMP_TYPE} ;
                rserv_alarm_ridle  <= {16'd0,8'b0,ALARM_ING}                       ; // 200 
                ext_irq            <= 1'b1;
                irq_cnt            <= 'd0 ;
                irq_state          <= 'd15;
            end
            3:begin
                instruction0_ridle <= {reg_execu_func[31:24],reg_execu_func[23:8],INTR_TYPE_BEHA_ACT}                          ;
                instruction1_ridle <= {ACT_ALARM,reg_execu_func[7:0],BEHA_TYPE_2,P_MODULE_ID,COMP_TYPE} ;
                rserv_alarm_ridle  <= {16'd0,8'b0,ALARM_MANUAL}                      ; // 204
                ext_irq            <= 1'b1;
                irq_cnt            <= 'd0 ;
                irq_state          <= 'd15;
            end
            4:begin
                instruction0_ridle <= {reg_execu_func[31:24],reg_execu_func[23:8],INTR_TYPE_BEHA_ACT}                          ;
                instruction1_ridle <= {ACT_ALARM,reg_execu_func[7:0],BEHA_TYPE_2,P_MODULE_ID,COMP_TYPE} ;
                rserv_alarm_ridle  <= {16'd0,8'b0,ALARM_BUSY}                      ; // 202
                ext_irq            <= 1'b1;
                irq_cnt            <= 'd0 ;
                irq_state          <= 'd15;
            end
            5:begin
                instruction0_ridle <= {reg_execu_func[31:24],reg_execu_func[23:8],INTR_TYPE_BEHA_ACT}                          ;
                instruction1_ridle <= {ACT_ALARM,reg_execu_func[7:0],BEHA_TYPE_2,P_MODULE_ID,COMP_TYPE} ;
                rserv_alarm_ridle  <= {16'd0,8'b0,ALARM_LOCK}                      ; // 203
                ext_irq            <= 1'b1;
                irq_cnt            <= 'd0 ;
                irq_state          <= 'd15;
            end
            15:begin
                if(ext_irq_grant)begin
                     irq_state        <= 'd0 ;
                     ext_irq            <= 1'b0;
                end else begin
                     irq_state        <= irq_state ;
                     ext_irq            <= 1'b1;
                end
                irq_cnt            <= 'd0 ;
            end
            default:begin
                instruction0_ridle <= 'd0 ;
                instruction1_ridle <= 'd0 ;
                rserv_alarm_ridle  <= 'd0 ;
                ext_irq            <= 'd0 ;
                irq_cnt            <= 'd0 ;
                irq_state          <= 'd0 ;
            end
        endcase
        
   end

   // ----------------------------- riddle end ------------------------------
   
   
   
   // ----------------------------- timer behavior start ------------------------------
 
   reg        timer0_irq;
   wire       timer0_irq_grant;
   timeTask#(
        .TIMER_WIDTH(32)
   ) U_timeTask(
        .clk            ( ps_reg_clk     )
       ,.reset          ( ps_reg_reset   )
       ,.i_time_1ms_vld ( i_time_1ms_vld )
       
       ,.i_irq_ack           (timer0_irq_grant    )
       ,.i_beha_ack          ((rintr_ack_result == 1) & (rintr_ack_beh_id==129)               )
       ,.iv_task_circle_time (reg_gather_time[0] )
       ,.o_task_irq          (timer0_irq    )
   );
   wire [31:0] instruction0_timer0 = {8'd0,16'd0,INTR_TYPE_BEHA_ACT}                             ;
   wire [31:0] instruction1_timer0 = {ACT_EXE,8'd129,BEHA_TYPE_1,P_MODULE_ID,COMP_TYPE} ;
   wire [31:0] rserv_alarm_timer0  = {16'd0,8'b0,8'd0};                                    ;
   
   // ----------------------------- timer behavior end ------------------------------
  
  
     
   // ----------------------------- Conditional behavior start ------------------------------
   // conditional_beh_process#(
   //      .COMP_TYPE          (COMP_TYPE)
   //     ,.P_MODULE_ID        (P_MODULE_ID)
   //     ,.BEHA_TYPE          (BEHA_TYPE_2)
   //     ,.INTR_TYPE_BEHA_ACT (INTR_TYPE_BEHA_ACT)
   // )  U_conditional_beh_process_1(
   //       .ps_reg_clk          (ps_reg_clk      )
   //      ,.ps_reg_reset        (ps_reg_reset    )
   //      ,.i_time_1ms_vld      (i_time_1ms_vld  )
   //      ,.iv_task_index       (task_index      )
   //      ,.iv_task_id          (task_id         )
        
   //      ,.iv_beha_id          (8'd161 )
   //      ,.i_trigger_enb       (1'b1   )
   //      ,.i_trigger_signal    (emerge_stop_key_trigger)
   //      ,.iv_rintr_ack_result (rintr_ack_result)
   //      ,.iv_rintr_ack_beh_id (rintr_ack_beh_id)
        
   //      ,.i_con_irq_grant     (o_intr_grant_t           [3])
   //      ,.o_con_irq           (i_intr_irq_t             [3])
   //      ,.ov_instruction0_con (iv_rintr_instruction0_t  [3])
   //      ,.ov_instruction1_con (iv_rintr_instruction1_t  [3])
   //      ,.ov_rserv_alarm_con  (iv_rserv_alarm_t         [3])
   // );
   
   
   // conditional_beh_process#(
   //      .COMP_TYPE          (COMP_TYPE)
   //     ,.P_MODULE_ID        (P_MODULE_ID)
   //     ,.BEHA_TYPE          (BEHA_TYPE_2)
   //     ,.INTR_TYPE_BEHA_ACT (INTR_TYPE_BEHA_ACT)
   // )  U_conditional_beh_process_2(
   //       .ps_reg_clk          (ps_reg_clk      )
   //      ,.ps_reg_reset        (ps_reg_reset    )
   //      ,.i_time_1ms_vld      (i_time_1ms_vld  )
   //      ,.iv_task_index       (task_index      )
   //      ,.iv_task_id          (task_id         )
        
   //      ,.iv_beha_id          (8'd162 )
   //      ,.i_trigger_enb       (1'b1 )
   //      ,.i_trigger_signal    (reset_key_trigger)
   //      ,.iv_rintr_ack_result (rintr_ack_result)
   //      ,.iv_rintr_ack_beh_id (rintr_ack_beh_id)
        
   //      ,.i_con_irq_grant     (o_intr_grant_t           [4])
   //      ,.o_con_irq           (i_intr_irq_t             [4])
   //      ,.ov_instruction0_con (iv_rintr_instruction0_t  [4])
   //      ,.ov_instruction1_con (iv_rintr_instruction1_t  [4])
   //      ,.ov_rserv_alarm_con  (iv_rserv_alarm_t         [4])
   // );
   
   
   // conditional_beh_process#(
   //      .COMP_TYPE          (COMP_TYPE)
   //     ,.P_MODULE_ID        (P_MODULE_ID)
   //     ,.BEHA_TYPE          (BEHA_TYPE_2)
   //     ,.INTR_TYPE_BEHA_ACT (INTR_TYPE_BEHA_ACT)
   // )  U_conditional_beh_process_3(
   //       .ps_reg_clk          (ps_reg_clk      )
   //      ,.ps_reg_reset        (ps_reg_reset    )
   //      ,.i_time_1ms_vld      (i_time_1ms_vld  )
   //      ,.iv_task_index       (task_index      )
   //      ,.iv_task_id          (task_id         )
        
   //      ,.iv_beha_id          (i_stop_start_singal ? 8'd163 : 8'd164 )
   //      ,.i_trigger_enb       (0);//(i_emerge_stop_signal==0 )
   //      ,.i_trigger_signal    (stop_start_key_trigger)
   //      ,.iv_rintr_ack_result (rintr_ack_result)
   //      ,.iv_rintr_ack_beh_id (rintr_ack_beh_id)
        
   //      ,.i_con_irq_grant     (o_intr_grant_t           [5])
   //      ,.o_con_irq           (i_intr_irq_t             [5])
   //      ,.ov_instruction0_con (iv_rintr_instruction0_t  [5])
   //      ,.ov_instruction1_con (iv_rintr_instruction1_t  [5])
   //      ,.ov_rserv_alarm_con  (iv_rserv_alarm_t         [5])
   // );
   
   
   // conditional_beh_process#(
   //      .COMP_TYPE          (COMP_TYPE)
   //     ,.P_MODULE_ID        (P_MODULE_ID)
   //     ,.BEHA_TYPE          (BEHA_TYPE_2)
   //     ,.INTR_TYPE_BEHA_ACT (INTR_TYPE_BEHA_ACT)
   // )  U_conditional_beh_process_7(
   //       .ps_reg_clk          (ps_reg_clk      )
   //      ,.ps_reg_reset        (ps_reg_reset    )
   //      ,.i_time_1ms_vld      (i_time_1ms_vld  )
   //      ,.iv_task_index       (task_index      )
   //      ,.iv_task_id          (task_id         )
        
   //      ,.iv_beha_id          ( 8'd168)  // 手动
   //      ,.i_trigger_enb       (1'b1 )
   //      ,.i_trigger_signal    (auto_manual_rising_trigger)
   //      ,.iv_rintr_ack_result (rintr_ack_result)
   //      ,.iv_rintr_ack_beh_id (rintr_ack_beh_id)
        
   //      ,.i_con_irq_grant     (o_intr_grant_t           [6])
   //      ,.o_con_irq           (i_intr_irq_t             [6])
   //      ,.ov_instruction0_con (iv_rintr_instruction0_t  [6])
   //      ,.ov_instruction1_con (iv_rintr_instruction1_t  [6])
   //      ,.ov_rserv_alarm_con  (iv_rserv_alarm_t         [6])
   // );
   
   
   
   // conditional_beh_process#(
   //      .COMP_TYPE          (COMP_TYPE)
   //     ,.P_MODULE_ID        (P_MODULE_ID)
   //     ,.BEHA_TYPE          (BEHA_TYPE_2)
   //     ,.INTR_TYPE_BEHA_ACT (INTR_TYPE_BEHA_ACT)
   // )  U_conditional_beh_process_8(
   //       .ps_reg_clk          (ps_reg_clk      )
   //      ,.ps_reg_reset        (ps_reg_reset    )
   //      ,.i_time_1ms_vld      (i_time_1ms_vld  )
   //      ,.iv_task_index       (task_index      )
   //      ,.iv_task_id          (task_id         )
        
   //      ,.iv_beha_id          ( 8'd169) //自动
   //      ,.i_trigger_enb       (1'b1 )
   //      ,.i_trigger_signal    (auto_manual_falling_trigger)
   //      ,.iv_rintr_ack_result (rintr_ack_result)
   //      ,.iv_rintr_ack_beh_id (rintr_ack_beh_id)
        
   //      ,.i_con_irq_grant     (o_intr_grant_t           [7])
   //      ,.o_con_irq           (i_intr_irq_t             [7])
   //      ,.ov_instruction0_con (iv_rintr_instruction0_t  [7])
   //      ,.ov_instruction1_con (iv_rintr_instruction1_t  [7])
   //      ,.ov_rserv_alarm_con  (iv_rserv_alarm_t         [7])
   // );
   
   // ----------------------------- Conditional behavior end --------------------------------
   
   
  
  // -------------------------------- bind your independent interrupt port ----------------------
  localparam USER_NUMBER = 3; // Max Value is 16
  wire [USER_NUMBER-1:0]       i_intr_irq_t           ;
  wire [USER_NUMBER-1:0]       o_intr_grant_t         ;
  wire [31:0] iv_rintr_instruction0_t[USER_NUMBER-1:0]; 
  wire [31:0] iv_rintr_instruction1_t[USER_NUMBER-1:0]; 
  wire [31:0] iv_rserv_alarm_t[USER_NUMBER-1:0]       ;

  assign comp_irq_grant  = o_intr_grant_t   [0];
  assign i_intr_irq_t                       [0] = comp_irq;
  assign iv_rintr_instruction0_t            [0] = {task_index,task_id   ,rintr_type};
  assign iv_rintr_instruction1_t            [0] = {rintr_action,rintr_beha,BEHA_TYPE_0,P_MODULE_ID,COMP_TYPE};
  assign iv_rserv_alarm_t                   [0] = {16'd0,8'b0,alarm_type};

  assign ext_irq_grant   = o_intr_grant_t   [1];
  assign i_intr_irq_t                       [1] = ext_irq;
  assign iv_rintr_instruction0_t            [1] = instruction0_ridle;
  assign iv_rintr_instruction1_t            [1] = instruction1_ridle;
  assign iv_rserv_alarm_t                   [1] = rserv_alarm_ridle ;
         
  
  assign timer0_irq_grant   = o_intr_grant_t[2];
  assign i_intr_irq_t                       [2] = timer0_irq;
  assign iv_rintr_instruction0_t            [2] = instruction0_timer0 ;
  assign iv_rintr_instruction1_t            [2] = instruction1_timer0 ;
  assign iv_rserv_alarm_t                   [2] = rserv_alarm_timer0  ;
  
//  assign con_irq_grant   = o_intr_grant_t   [3];
//  assign i_intr_irq_t                       [3] = con_irq;
//  assign iv_rintr_instruction0_t            [3] = instruction0_con ;
//  assign iv_rintr_instruction1_t            [3] = instruction1_con ;
//  assign iv_rserv_alarm_t                   [3] = rserv_alarm_con  ;
  
  
   wire [31:0] o_rintr_instruction0 ; 
   wire [31:0] o_rintr_instruction1 ; 
   wire [31:0] rserv_alarm          ; 

   wire [7:0]  current_irq_beh_id = o_rintr_instruction1[23:16];
   
   wire [ 7:0] rintr_rec_ack_beh_id = rintr_status[0][ 7: 0];
   wire [ 7:0] rintr_rec_ack_action = rintr_status[0][15: 8];
   wire [15:0] rintr_rec_ack_result = rintr_status[0][31:16];
   
    wire irq_receive_ack = (rintr_rec_ack_beh_id == current_irq_beh_id);
   
   
   wire irq_req_busy;
   irq_arbitor #(
        .USER_NUMBER(USER_NUMBER)
   ) U_irq_arbitor(
          .clk                   ( ps_reg_clk        ),
          .reset                 ( aurora_reset      ),
          .ps_reg_reset          ( ps_reg_reset      ),
          
          .i_irq_receive_ack     (irq_receive_ack        ),
          .o_irq_req_busy        (irq_req_busy           ),
          
          .i_intr_irq             (i_intr_irq_t            ),
          .o_intr_grant           (o_intr_grant_t          ),
          .iv_rintr_instruction0  (iv_rintr_instruction0_t ),
          .iv_rintr_instruction1  (iv_rintr_instruction1_t ),
          .iv_rserv_alarm         (iv_rserv_alarm_t        ),
          
          .o_intr_irq             (o_intr_irq           ),
          .ov_rintr_instruction0  (o_rintr_instruction0 ),
          .ov_rintr_instruction1  (o_rintr_instruction1 ),
          .ov_rserv_alarm         (rserv_alarm          )
   );
   
// --------------- For REG Read ----------------------------------

   // wire [31:0] sig_arr_status;
   // wire [31:0] sig_arr_status_p = {30'b0,i_stop_start_singal,i_reset_signal,1'b0,1'b0,1'b0,1'b0,1'b0}; 
   // keep_level #(
   //     .KEEP_TIME_MS        (1000        )
   //    ,.KEEP_IO_NUM         (10          )
   // )U_keep_level(
   //      .clk		   	 (ps_reg_clk		    )
   //      ,.reset		 	 (ps_reg_reset      	)
   //      ,.i_time_1ms_vld (i_time_1ms_vld        )
   //      ,.iv_sig         (sig_arr_status_p      )
   //      ,.ov_sig         (sig_arr_status        )
   // );
   


wire [39:0] sc_status;
assign sc_status[0] = busy;
assign sc_status[1] = irq_alarm;
assign sc_status[2] = 1'b0; //i_emerge_stop_signal;
assign sc_status[3] = 1'b0; //i_stop_start_singal;
assign sc_status[4] = local_security;
assign sc_status[5] = link_security;
assign sc_status[6] = link_lock;
assign sc_status[7] = reg_reset_n;

assign sc_status[ 8] = irq_req_busy;
assign sc_status[ 9] = irq_busy;
assign sc_status[10] = 1'b0;
assign sc_status[11] = 1'b0;
assign sc_status[12] = 1'b0;
assign sc_status[13] = 1'b0;
assign sc_status[14] = 1'b0;
assign sc_status[15] = 1'b0;

assign sc_status[16] = 1'b0;
assign sc_status[17] = 1'b0;
assign sc_status[18] = 1'b0;
assign sc_status[19] = 1'b0;
assign sc_status[20] = 1'b0;
assign sc_status[21] = 1'b0;
assign sc_status[22] = 1'b0;
assign sc_status[23] = 1'b0;

                         
always @(posedge ps_reg_clk) begin
   // Address decoding for reading registers
   case ( rd_addr_d2[19:0] )
       `RINTR_INST0              : o_st_rd_data <= o_rintr_instruction0;
       `RINTR_INST1              : o_st_rd_data <= o_rintr_instruction1;
       `RSERV_ALARM              : o_st_rd_data <= rserv_alarm;
       `UNIT_EMERGENCY_CTRL      : o_st_rd_data <= unit_emergency_ctrl; 
       `UNIT_STATUS              : o_st_rd_data <= unit_status; 
       
       `EQUIPMENT_EMERGENCY_CTRL : o_st_rd_data <= equipment_emergency_ctrl; 
       `EQUIPMENT_STATUS         : o_st_rd_data <= equipment_status; 
       `EQUIPMENT_ID             : o_st_rd_data <= equipment_id; 
       `SET_WORK_MODE            : o_st_rd_data <= set_work_mode; 
       `LOCAL_SECURITY           : o_st_rd_data <= local_security | irq_alarm;
       `LINK_SECURITY            : o_st_rd_data <= link_security;
       `TASK_OCCUPY              : o_st_rd_data <= task_occupy; 
       
       `SC_STATUS_1             : o_st_rd_data <= {task_index,task_id,8'b0};
       `SC_STATUS_2             : o_st_rd_data <= sc_status[31:0];
       `READ_DATA_REG           : o_st_rd_data <= r_weight[31:0]; //unit: mm  offset: 196  0xC4   //sig_arr_status;
       `READ_DATA_REG2          : o_st_rd_data <= r_weight[63:32];//unit: mm  offset: 200  0xC8   //sig_arr_status;
       
       `LOC_STATUS_1             : o_st_rd_data <= status_list ;
       `LOC_STATUS_2             : o_st_rd_data <= status_list ;
       `LOC_BEH_1                : o_st_rd_data <= {last_3_beh_number,last_2_beh_number,last_beh_number,curr_beh_number} ;
       default : o_st_rd_data <= 32'h7FFF_FFFF;
   endcase    
end   


endmodule
