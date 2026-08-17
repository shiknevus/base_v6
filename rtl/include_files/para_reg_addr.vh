`define SYS_ALARM_LOCK     50   //enable alarm stop
`define SYS_ALARM_UNLOCK   51   //disable alarm stop
`define SYS_STOP_LOCK      52   //enable emerge stop 
`define SYS_STOP_UNLOCK    53   //disable emerge stop
`define SYS_RUN_LOCK       54   //enable component 
`define SYS_RESET_LOCK     56   //disable component
`define SYS_DEBUG_BEGIN    58   //enable debug mode 
`define SYS_DEBUG_END      59   //disable debug mode

`define MOTOR_STOP         60 //debug mode
`define MOTOR_FORWARD      61 //debug mode
`define MOTOR_REVERSE      62 //debug mode
`define YZ_FORWARD         63 //debug mode
`define YZ_REVERSE         64 //debug mode
`define YZ_STOP            65 //debug mode
`define QG_UP              66 //debug mode
`define QG_DOWN            67 //debug mode

`define SCAN               68 //debug mode
`define WEIGHT             69 //debug mode
`define HEIGHT             70 //debug mode
`define OPEN_LID           71 //debug mode
`define CLOSE_LID          72 //debug mode
`define ENCODER_CLR        73 //debug mode
`define ENCODER_CNT_RD     74 //debug mode
`define OPEN_SWING         75 //debug mode
`define CLOSE_SWING        76 //debug mode
`define WHITE_LIST_CLR     77 //debug mode
`define WHITE_LIST_FIND    78 //debug mode
`define INSIDE_CLR         79 //debug mode
`define OPEN_DOOR          80 //debug mode
`define CLOSE_DOOR         81 //debug mode

`define MOVE_OUT_REDO      57
`define SC_STATUS_REG	  	9'hC	//PL实时将当前组件状态（状�?�表中的状�?�）实时写入此寄存器，由PS按需读取
`define SC_INTER_APPLY 		9'h10	//PL中断申请后PS响应反馈
`define SC_POS1_INTER_APPLY	9'h14	//控件的操作位、信息位等位�?1,PL中断申请后PS响应反馈
`define SC_POS2_INTER_APPLY	9'h18	//控件的操作位、信息位等位�?2,PL中断申请后PS响应反馈
`define SC_POS3_INTER_APPLY	9'h1C	//控件的操作位、信息位等位�?3,PL中断申请后PS响应反馈
`define SC_POS4_INTER_APPLY	9'h20	//控件的操作位、信息位等位�?4,PL中断申请后PS响应反馈
`define SC_POS5_INTER_APPLY	9'h24	//控件的操作位、信息位等位�?5,PL中断申请后PS响应反馈
`define SC_POS6_INTER_APPLY	9'h28	//控件的操作位、信息位等位�?6,PL中断申请后PS响应反馈
`define SC_POS7_INTER_APPLY	9'h2C	//控件的操作位、信息位等位�?7,PL中断申请后PS响应反馈
`define SC_POS8_INTER_APPLY	9'h30	//控件的操作位、信息位等位�?8,PL中断申请后PS响应反馈
`define SC_BH_TASK_PARA		9'h34	//线体、控制流执行调试执行行为时所下发的相关行为参数�?�命�?
`define SC_BH_STATUS			9'h38	//PL实时将当前组件行为状态（状�?�表中的状�?�）实时写入此寄存器，由PS按需读取
`define SC_BH_TASK_START	    9'h3C	//调试行为�?�?
`define SC_IRQ_INFO1			9'h80	//线体、控制流执行过程中PL将控件�?�控制流相关的控制流类型、编号�?�行为序号�?�组件类型�?�组件编号�?�组件行为编号�?�行为动作编号等不同内容通过中断信息反馈PS
`define SC_IRQ_INFO2			9'h84	//线体、控制流执行过程中PL将控件�?�控制流相关的控制流类型、编号�?�行为序号�?�组件类型�?�组件编号�?�组件行为编号�?�行为动作编号等不同内容通过中断信息反馈PS
`define FLOW_START			9'hA0	//控制流启动控制参�?
`define FLOW_END				9'hB0	//控制流结束控制参�?
//`define OL_OUT_PATH     2'b
`define OL_OUT_PATH     2'b01
`define OC_OUT_PATH     2'b10
`define OR_OUT_PATH     2'b11
`define NO_OUT_PATH     2'b00

`define STATION_SEL      9'h88          //参数编号:P004193,参数名称:选择4
`define MODE_SEL         9'hc0          //参数编号:P004193,参数名称:选择4
`define DS_DRI_MODE_SEL      9'hbc          //参数编号:P004192,参数名称:选择3,功能描述:0气缸顶升、正反电机顶升模式，1凸轮顶升模式�?2使能方向顶升模式
`define YZ_DRI_MODE_SEL      9'hb8          //参数编号:P004191,参数名称:选择2,功能描述:0正反转模式，1使能方向模式
`define ZX_DRI_MODE_SEL      9'hb4          //参数编号:P004190,参数名称:选择1,功能描述:0正反转模式，1使能方向模式
`define CON_PARAM1      9'h1d8          //参数编号:P004189,参数名称:配置参数1
<<<<<<< HEAD
`define STATUS5      9'h1f8          //参数编号:P004144,参数名称:状�??5,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS4      9'h1f4          //参数编号:P004143,参数名称:状�??4,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS3      9'h1f0          //参数编号:P004142,参数名称:状�??3,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS2      9'h1ec          //参数编号:P004141,参数名称:状�??2,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS1      9'h1e8          //参数编号:P004140,参数名称:状�??1,功能描述:PL向PS汇�?�反馈的状�??
// `define PARAM4      9'h1e4          //参数编号:P004139,参数名称:参数4,功能描述:状�?��?�参数等
// `define PARAM3      9'h1e0          //参数编号:P004138,参数名称:参数3,功能描述:状�?��?�参数等
// `define PARAM2      9'h1dc          //参数编号:P004137,参数名称:参数2,功能描述:状�?��?�参数等
// `define PARAM1      9'h1d8          //参数编号:P004136,参数名称:参数1,功能描述:状�?��?�参数等
`define NUM_VALUE1      9'h1c0          //参数编号:P004135,参数名称:数�??1,功能描述:重量、高度�?�长度�?�厚度�?�位移�?�扭矩�?�扭力�?�功率�?�角度�?�负载�?��?�度等业务功能所�?数�?�参�?
=======
`define STATUS5      9'h1f8          //参数编号:P004144,参数名称:状�??5,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS4      9'h1f4          //参数编号:P004143,参数名称:状�??4,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS3      9'h1f0          //参数编号:P004142,参数名称:状�??3,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS2      9'h1ec          //参数编号:P004141,参数名称:状�??2,功能描述:PL向PS汇�?�反馈的状�??
`define STATUS1      9'h1e8          //参数编号:P004140,参数名称:状�??1,功能描述:PL向PS汇�?�反馈的状�??
//`define PARAM4      9'h1e4          //参数编号:P004139,参数名称:参数4,功能描述:状�?��?�参数等
//`define PARAM3      9'h1e0          //参数编号:P004138,参数名称:参数3,功能描述:状�?��?�参数等
//`define PARAM2      9'h1dc          //参数编号:P004137,参数名称:参数2,功能描述:状�?��?�参数等
//`define PARAM1      9'h1d8          //参数编号:P004136,参数名称:参数1,功能描述:状�?��?�参数等
`define NUM_VALUE1      9'h1c0          //参数编号:P004135,参数名称:数�??1,功能描述:重量、高度�?�长度�?�厚度�?�位移�?�扭矩�?�扭力�?�功率�?�角度�?�负载�?��?�度等业务功能所�?数�?�参�?
>>>>>>> origin/cgliu
`define SC_POS8_INF      9'h74          //参数编号:P004134,参数名称:组件位置8参数,功能描述:组件位置8令牌等信息寄存器
`define SC_POS7_INF      9'h70          //参数编号:P004133,参数名称:组件位置7参数,功能描述:组件位置7令牌等信息寄存器
`define SC_POS6_INF      9'h6c          //参数编号:P004132,参数名称:组件位置6参数,功能描述:组件位置6令牌等信息寄存器
`define SC_POS5_INF      9'h68          //参数编号:P004131,参数名称:组件位置5参数,功能描述:组件位置5令牌等信息寄存器
`define SC_POS4_INF      9'h64          //参数编号:P004130,参数名称:组件位置4参数,功能描述:组件位置4令牌等信息寄存器
`define SC_POS3_INF      9'h60          //参数编号:P004129,参数名称:组件位置3参数,功能描述:组件位置3令牌等信息寄存器
`define SC_POS2_INF      9'h5c          //参数编号:P004128,参数名称:组件位置2参数,功能描述:组件位置2令牌等信息寄存器
`define SC_POS1_INF      9'h58          //参数编号:P004127,参数名称:组件位置1参数,功能描述:组件位置1令牌等信息寄存器
`define RS485_DATA_REG_ADDR      9'h1c4          //参数编号:P004126,参数名称:数�??2,功能描述:RS485数据
`define SC_START      9'h54          //参数编号:P004093,参数名称:组件启动,功能描述:由业务系统远程下发的控制指令
`define SC_QSTOP      9'h50          //参数编号:P004092,参数名称:组件急停,功能描述:由业务系统远程下发的控制指令
`define SC_RESET      9'h4c          //参数编号:P004091,参数名称:组件复位,功能描述:由业务系统远程下发的控制指令
`define SC_PAUSE      9'h48          //参数编号:P004090,参数名称:组件暂停,功能描述:由业务系统远程下发的控制指令
`define SC_RESUM      9'h44          //参数编号:P004089,参数名称:组件继续,功能描述:由业务系统远程下发的控制指令
`define RESULT4      9'hfc          //参数编号:P004087,参数名称:结果4,功能描述:比对结果、拍照结果等结果参数
`define IL_MAT_ARRIVED_DELAY      9'h1a8          //参数编号:P004086,参数名称:延时时间3,功能描述:行为执行延迟时间，线体组件IL移入延迟到位时间
`define RESULT3      9'hf8          //参数编号:P004085,参数名称:结果3,功能描述:比对结果、拍照结果等结果参数
`define RESULT2      9'hf4          //参数编号:P004084,参数名称:结果2,功能描述:比对结果、拍照结果等结果参数
//`define RESULT1      9'hf0          //参数编号:P004083,参数名称:结果1,功能描述:比对结果、拍照结果等结果参数
`define IC_MAT_ARRIVED_DELAY      9'h1a4          //参数编号:P004082,参数名称:延时时间2,功能描述:行为执行延迟时间，线体组件IC移入延迟到位时间
//`define SER_NUM4      9'hdc          //参数编号:P004077,参数名称:编号4,功能描述:位置、点位�?�路径�?�设备型号�?�文件编号等编号
//`define SER_NUM3      9'hd8          //参数编号:P004076,参数名称:编号3,功能描述:位置、点位�?�路径�?�设备型号�?�文件编号等编号
`define MAT_ERROR_TIMEOUT      9'h188          //参数编号:P004075,参数名称:�?大执行时�?3,功能描述:线体组件物料取走后变为空闲状态时�?
//`define SER_NUM2      9'hd4          //参数编号:P004074,参数名称:编号2,功能描述:位置、点位�?�路径�?�设备型号�?�文件编号等编号
`define PATH_MSG_REG_ADDR       9'hd0          //参数编号:P004073,参数名称:编号1,功能描述:线体用组件PS下发路径方向信息
`define QG_ACT_TIMEOUT       9'h184          //参数编号:P004072,参数名称:�?大执行时�?2,功能描述:线体组件气缸顶升�?大超时时间，超时报警
//`define SER_NUM1      9'hd0          //参数编号:P004071,参数名称:编号1,功能描述:位置、点位�?�路径�?�设备型号�?�文件编号等编号
`define COD_NUM3      9'hcc          //参数编号:P004070,参数名称:码�??3,功能描述:二维码�?�条形码、RFID等码�?
`define COD_NUM2      9'hc8          //参数编号:P004069,参数名称:码�??2,功能描述:二维码�?�条形码、RFID等码�?
`define COD_NUM1      9'hc4          //参数编号:P004068,参数名称:码�??1,功能描述:二维码�?�条形码、RFID等码�?
`define TASK_TOK_WR      9'h58          //参数编号:P004067,参数名称:任务令牌�?2,功能描述:物料传�?�令牌号写入
`define TASK_TOK_WR_2    9'h5c          //参数编号:P004067,参数名称:任务令牌�?2,功能描述:物料传�?�令牌号写入
`define SEL2      9'hb8          //参数编号:P004066,参数名称:选择2,功能描述:包含程序选择、�?�道选择等不同的业务选择功能
`define SEL1      9'hb4          //参数编号:P004065,参数名称:选择1,功能描述:包含程序选择、�?�道选择等不同的业务选择功能
`define MAX_TIME4      9'h18c          //参数编号:P004064,参数名称:�?大执行时�?4,功能描述:行为�?大执行时间，超时报警，动态业务参�?
`define MOVE_IN_TIMEOUT      9'h180          //参数编号:P004063,参数名称:�?大执行时�?1,功能描述:线体组件移入�?大超时时间，超时报警
`define AI_DATA_REG_ADDR      9'h1c0          //参数编号:P004062,参数名称:数�??1,功能描述:模拟量数据读�?
`define RS232_DATA_REG_ADDR_2      9'hc8          //参数编号:P004061,参数名称:码�??2,功能描述:线体用读码器码�??
`define RS232_DATA_REG_ADDR      9'hc4          //参数编号:P004060,参数名称:码�??1,功能描述:线体用读码器码�??
`define TASK_TOK_RD      9'h160          //参数编号:P004059,参数名称:任务令牌�?1,功能描述:物料传�?�令牌号读取
`define IR_MAT_ARRIVED_DELAY      9'h1a0          //参数编号:P004058,参数名称:延迟时间1,功能描述:行为执行延迟时间，线体组件IR移入延迟到位时间
`define HEIGHT_DATA_0      9'h100
`define HEIGHT_DATA_1      9'h104
`define HEIGHT_DATA_2      9'h108

`define DELAY_TIM8      9'h1bc          //参数编号:P004030,参数名称:延迟时间8,功能描述:组件行为延迟执行时间
`define DELAY_TIM7      9'h1b8          //参数编号:P004029,参数名称:延迟时间7,功能描述:组件行为延迟执行时间
`define DELAY_TIM6      9'h1b4          //参数编号:P004028,参数名称:延迟时间6,功能描述:组件行为延迟执行时间
`define DELAY_TIM5      9'h1b0          //参数编号:P004027,参数名称:延迟时间5,功能描述:组件行为延迟执行时间
`define DELAY_TIM4      9'h1ac          //参数编号:P004026,参数名称:延迟时间4,功能描述:组件行为延迟执行时间
`define DELAY_TIM3      9'h1a8          //参数编号:P004025,参数名称:延迟时间3,功能描述:组件行为延迟执行时间
`define DELAY_TIM2      9'h1a4          //参数编号:P004024,参数名称:延迟时间2,功能描述:组件行为延迟执行时间
`define DELAY_TIM1      9'h1a0          //参数编号:P004023,参数名称:延迟时间1,功能描述:组件行为延迟执行时间
`define MAX_TIME_8      9'h19c          //参数编号:P004022,参数名称:�?大执行时�?8,功能描述:行为超时告警时间
`define MAX_TIME_7      9'h198          //参数编号:P004021,参数名称:�?大执行时�?7,功能描述:行为超时告警时间
`define MAX_TIME_6      9'h194          //参数编号:P004020,参数名称:�?大执行时�?6,功能描述:行为超时告警时间
`define MAX_TIME_5      9'h190          //参数编号:P004019,参数名称:�?大执行时�?5,功能描述:行为超时告警时间
`define MAX_TIME_4      9'h18c          //参数编号:P004018,参数名称:�?大执行时�?4,功能描述:行为超时告警时间
`define MAX_TIME_3      9'h188          //参数编号:P004017,参数名称:�?大执行时�?3,功能描述:行为超时告警时间
`define MAX_TIME_2      9'h184          //参数编号:P004016,参数名称:�?大执行时�?2,功能描述:行为超时告警时间
`define MAX_TIME_1      9'h180          //参数编号:P004015,参数名称:�?大执行时�?1,功能描述:行为超时告警时间
`define SC_POS_NUM8      9'h17c          //参数编号:P004014,参数名称:组件位置信息8,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM7      9'h178          //参数编号:P004013,参数名称:组件位置信息7,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM6      9'h174          //参数编号:P004012,参数名称:组件位置信息6,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM5      9'h170          //参数编号:P004011,参数名称:组件位置信息5,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM4      9'h16c          //参数编号:P004010,参数名称:组件位置信息4,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM3      9'h168          //参数编号:P004009,参数名称:组件位置信息3,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM2      9'h164          //参数编号:P004008,参数名称:组件位置信息2,功能描述:组件操作位寄存器，设备�?�物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define SC_POS_NUM1      9'h160          //参数编号:P004007,参数名称:组件位置信息1,功能描述:组件信息位�?�操作位寄存器，优先信息位，设备、物料�?�令牌�?�未执行、执行申请�?�执行中、执行反馈�?�执行完成等状�?�信�?
`define PS_COMMAND_REG      9'h0          //参数编号:P001222,参数名称:组件使能,功能描述:组件安全参数（使�?1复位0），报警50，报警清�?51，�?�停52，�?�停清除53，使�?54，复�?56，调试模�?58，自动模�?59，首段设�?80，首段设置解�?81
`define RD_POINT      9'h158          //参数编号:P000201,参数名称:坐标�?1,功能描述:读取电机实时位置脉冲�?
`define SM_CUR_MODE      9'h144          //参数编号:P001081,参数名称:电机曲线模式,功能描述:模式�?0 �? T型曲线，1 �? S型曲�?
`define MV_DEC      9'h134          //参数编号:P001080,参数名称:移动减�?�度
`define MV_ACC      9'h130          //参数编号:P001079,参数名称:移动加�?�度
`define MV_SPEED      9'h12c          //参数编号:P001078,参数名称:移动速度
`define DOT_DEC      9'h128          //参数编号:P001077,参数名称:点动减�?�度
`define DOT_ACC      9'h124          //参数编号:P001076,参数名称:点动加�?�度
`define DOT_SPEED      9'h120          //参数编号:P001075,参数名称:点动速度
`define ZERO_DEC      9'h11c          //参数编号:P001074,参数名称:回零减�?�度
`define ZERO_ACC      9'h118          //参数编号:P001073,参数名称:回零加�?�度
`define ZERO_SPEED      9'h114          //参数编号:P001072,参数名称:回零速度
`define TOUCH_DEC      9'h148          //参数编号:P001071,参数名称:触位减�?�度
`define MAX_DEC      9'h140          //参数编号:P001070,参数名称:�?大减速度
`define MAX_ACC      9'h13c          //参数编号:P001069,参数名称:�?大加速度
`define MAX_SPEED      9'h138          //参数编号:P001068,参数名称:�?大�?�度
`define SM_PAUSE      9'h108          //参数编号:P001065,参数名称:电机暂停,功能描述:电机专用系统远程下发指令
`define SM_DR_RESET      9'h104          //参数编号:P001064,参数名称:电机驱动复位,功能描述:电机专用驱动复位
`define SM_DR_EN      9'h100          //参数编号:P001062,参数名称:电机驱动使能,功能描述:电机专用驱动使能
`define DOT_POINT      9'h150          //参数编号:P001061,参数名称:点动点位,功能描述:点动相对点位距离
`define MV_POINT      9'h154          //参数编号:P001060,参数名称:移动点位,功能描述:移动绝对点位距离
`define SM_DIR      9'h14c          //参数编号:P001058,参数名称:电机方向,功能描述:电机方向
`define SM_RESUM      9'h10c          //参数编号:P001029,参数名称:电机继续运行,功能描述:电机专用系统远程下发指令
`define SM_QSTOP      9'h110          //参数编号:P001027,参数名称:电机急停,功能描述:电机专用系统远程下发指令
`define ALM_NUM      9'h40          //参数编号:P001019,参数名称:报警编号,功能描述:控制流控件告警上传，�?个控件一个，上传告警内容值，�?100等，自动生成，不用配�?

`define IRQ_SCAN              35 // ɨ����֤��У������
`define IRQ_PATH_REQUEST      37
`define IRQ_STD_IN_SUCCESS    38
`define IRQ_DEPOT_IN_SUCCESS  39
`define IRQ_STD_OUT_SUCCESS   40
`define IRQ_CONTROL_STREAM    41
`define IRQ_BOX_CLOSE_ERROR   42
`define IRQ_DEPOT_OUT_READY   44
`define IRQ_DEPOT_IN_READY    45
`define IRQ_PICK_3IN1_HEIGHT  46
`define IRQ_IC_IN_SUCCESS     47
`define IRQ_OC_OUT_SUCCESS    48
`define IRQ_MAT_ERROR         49       //take material away from component by human
`define IRQ_ALARM             50
`define IRQ_WEIGHT            51
`define IRQ_HEIGHT            52
`define IRQ_TIME_REQUEST      53
`define IRQ_MOVE_OUT_REQUEST  54
`define IRQ_SCAN_REQUEST      55  //    ��������
 

`define IRQ_ACK_EXIT          64 // EXIT,Give up to perform
`define IRQ_ACK_RELEASE       65 // Release,Do the next action
`define IRQ_ACK_REDO          66 // Redo
`define IRQ_ACK_PATH          67 // Path have been set
`define IRQ_ACK_TOKEN         68 // Token have been set

`define IRQ_ACK_OK            1
`define IRQ_ACK_INVALID       2
`define IN_CHECK_ERROR        2
`define MOVE_OUT_TIMEOUT      3
`define INTERACT_TIMEOUT      4
`define REQ_PARAM_ERROR       5
`define TOKEN_ERROR           6
`define QG_UP_TIMEOUT         7
`define QG_DOWN_TIMEOUT       8
`define SCAN_ERROR            9
`define DEPOT_OUT_ERROR       10
`define QG_UP_N_VALID         11
`define HEIGHT_ERROR          12
`define BOX_OPEN_ERROR        13
`define IC_IN_N_MATCH         14
`define WEIGHT_ERROR          15
`define LOOP_JUDGE_FAIL       16
`define MOTO_ALARM            17

`define IRQ_ACK_FAIL         26  // ARM interrupt processing failure, return value 26
