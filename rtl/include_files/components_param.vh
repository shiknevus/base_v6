// ---------------- FPGA Version ---------------------
// The FPGA version is represented by 32-bit register
// bit[31:28] is F or D,F is Final version,D is Debug version
// bit[27: 4] is the version release date,e.g. 220923 is September 23, 2022
// bit[ 3: 0] is the number of releases on the same date
`define FPGA_VERSION 32'hF2505131

//`define ENB_SIM_MODULE   // Enable simulation debug
//`define ENB_IO_DBG_SUPPORT   // Enable simulation debug
`define SET_DEBUG_CMD 9'h90
//`define IO_DEBUG_USE_RS232
//`define IO_DEBUG_USE_RS485_1
`define IO_DEBUG_USE_RS485_2

`define IN_BEH_SUC_EVENT           38
`define IN_EVENT_MORE_PATH         37
`define SCAN_TOKEN_EVENT           35
`define OUT_BEH_SUC_EVENT          40
`define ROLL_SORT_IN_EVENT         41
`define BOX_CLOSE_ERR_EVENT        42
`define ROLL_LIB_IN_EVENT          39
`define VALVE_LIB_OUT_EVENT        44
`define VALVE_LIB_IN_EVENT         45
`define EXTERNAL_MEASURE           46
`define ENDPOINT_IN_SUC_EVENT      47
`define STARTPOINT_OUT_SUC_EVENT   48
`define EXTERNAL_WEIGHT            49
`define WEIGHT_CK_EVENT            51
`define BOX_OPEN_ERR_EVENT         65      //64+1
`define GEN_SCAN_ERR_EVENT         66
`define VALVE_UP_ERR_EVENT         68
`define PS_CFG_MSG_ERR_EVENT       69
`define IN_CKSF_ERR_EVENT          70
`define IN_BEH_ERR_EVENT           71
`define OUT_CKSF_ERR_EVENT         72
`define OUT_BEH_ERR_EVENT          73
`define WEIGHT_ERR_EVENT           77
`define OUTBOUND_ERR_EVENT         78

`define YELLOW_LIGHT   100
`define GREEN_LIGHT    101
`define RED_LIGHT      102


`define DEPOT_BIAS_RS232_00 `DEPOT_BIAS_RS232_1ST
`define DEPOT_BIAS_RS232_01 `DEPOT_BIAS_RS232_2ND
`define DEPOT_BIAS_RS232_02 `DEPOT_BIAS_RS232_3RD
`define DEPOT_BIAS_RS232_03 `DEPOT_BIAS_RS232_4TH
`define DEPOT_BIAS_RS232_04 `DEPOT_BIAS_RS232_5TH
`define DEPOT_BIAS_RS232_05 `DEPOT_BIAS_RS232_6TH
`define DEPOT_BIAS_RS232_06 `DEPOT_BIAS_RS232_7TH
`define DEPOT_BIAS_RS232_07 `DEPOT_BIAS_RS232_8TH



`define INT_TYPE_LOG            0
`define INT_TYPE_QUERY_PATH     1
`define INT_TYPE_ALARM          2

//components bias address
`define PL_CFG_BASE_ADDR    {32'hB010_0000  }
`define REG_SPACE_SIZE      512     //{5'h0,4'd0} //{12'h200}

//master app register /////////////////////////////
`define MST_APP_REG_BIAS        {20'h0_0000     }   //master station application register config bias address
`define MST_APP_REG_SIZE        512*2

`define MST_APP_REG_BASE         `PL_CFG_BASE_ADDR + `MST_APP_REG_BIAS
`define DEBUG_DATA_ADDR          {5'h00,4'h4}
`define FPGA_VERSION_RD_ADDR     {5'h00,4'h8} // write only,0x000000FF read master board version,0x00000000~0x000000FE read slave board version
`define FPGA_VERSION_DATA_ADDR   {5'h00,4'hC} // read only, return 32bit FPGA version
`define BOARD_TEMPERATURE_ADDR   {5'h01,4'h0} // read only, return board temprature,temperature is equal to return value multiple 0.0625
`define BOARD_IO_SELECT_ADDR     {5'h01,4'h4} // write IO pin level control
`define BOARD_READ_IO_DATA_ADDR  {5'h01,4'h8} // read address, return IO pin level
`define BOARD_WRITE_IO_DATA_ADDR {5'h01,4'hC} // write address, set output pin level
`define SLV_STA_NUM_ADDR         {5'h02,4'h0}
`define MST_APP_MODE_ADDR        {5'h03,4'h0}
`define PS_TX_REQ_ADDR           {5'h04,4'h0}
`define LINK_STATUS_ADDR         {5'h05,4'h0}  //OPTICAL_FIBER_
`define STAT_TIME_ADDR           {5'h06,4'h0}
`define PS_RD_DEPOT_FLAG_ADDR    {5'h07,4'h0}
`define OPT_INTF_INIT_EN_ADDR    {5'h08,4'h0}
`define CHECK_SYSTERM_ADDR       {5'h09,4'h0}
`define HB_SCAN_REQ_ADDR         {5'h0A,4'h0}  // PS manual heartbeat scan trigger
`define CACHE_SLV_ID_BIAS_ADDR   {5'h10,4'h0}

//generater optical fiber data------------------
`define GEN_OPT_DAT_BIAS    {20'h0_4000     }

`define SLV1ST_DO_DAT_CFG_ADDR  {5'h01,4'h0}
`define SLV1ST_DI_DAT_CFG_ADDR  {5'h02,4'h0}
`define SLV1ST_AO_DAT_CFG_ADDR  {5'h03,4'h0}
`define SLV1ST_AI_DAT_CFG_ADDR  {5'h04,4'h0}

`define SLV2ND_DO_DAT_CFG_ADDR  {5'h08,4'h0}
`define SLV2ND_DI_DAT_CFG_ADDR  {5'h09,4'h0}
`define SLV2ND_AO_DAT_CFG_ADDR  {5'h0A,4'h0}
`define SLV2ND_AI_DAT_CFG_ADDR  {5'h0B,4'h0}


//roller register define
`define COMP_WK_EN_ADDR         {5'h00,4'h0}
`define RS232_START_BIAS        {6'h01,4'd0}
`define PATH_MSG_ADDR           {6'h02,4'd0}
`define PS_CFG_WK_MODE_ADDR     {6'h03,4'd0}
`define AI1_MEASURE_ADDR        {6'h04,4'd0}
`define AI2_MEASURE_ADDR        {6'h05,4'd0}
`define AI3_MEASURE_ADDR        {6'h06,4'd0}
`define INT_TYPE_ADDR           {6'h07,4'd0}
`define INT_ACK_ADDR            {6'h08,4'd0}
`define CUR_COMP_ID             {6'h09,4'd0}
`define BEH_DLY_TIME            {6'h0a,4'd0}
`define COMP_WK_STATE_ADDR      {6'h0b,4'd0}
`define DEBUG_CMD_1ST           {6'h0c,4'd0}
`define DEBUG_CMD_2ND           {6'h0d,4'd0}
`define RS232_END_BIAS          {6'h0e,4'd0}
`define DEBUG_MSG               {6'h0f,4'd0}

`define COMMAND_ADDR            {5'h00,4'h0}

//Flow Register define
`define RSERV_SAFETY                9'h00  // system safe enable
`define COMP_DISABLE                9'h04  // component disable
`define RINTR_STATUS                9'h10  // PS interrupt act register
`define RINTR_STATUS1               9'h14  // Position 1 interrupt act register
`define RINTR_STATUS2               9'h18  // Position 2 interrupt act register
`define RINTR_STATUS3               9'h1c  // Position 3 interrupt act register
`define RINTR_STATUS4               9'h20  // Position 4 interrupt act register
`define RINTR_STATUS5               9'h24  // Position 5 interrupt act register
`define RINTR_STATUS6               9'h28  // Position 6 interrupt act register
`define RINTR_STATUS7               9'h2C  // Position 7 interrupt act register
`define RINTR_STATUS8               9'h30  // Position 8 interrupt act register

`define TASK_FUNC                   9'h34  //����???????????????��
`define TASK_START                  9'h3c  //����??????????????
`define RSERV_ALARM                 9'h40  // type of alarm
`define RSERV_RESULT                9'h1d8 //����Ĵ���
`define RINTR_INST0                 9'h80  //??����?????????????��1
`define RINTR_INST1                 9'h84  //??����?????????????��2
//`define GET_TEMPERATUE              9'h88  // Read sensor temperature address
//`define RS232_ADDR                  9'h8C  // Read sensor temperature address
`define LOOP_TIMES                  9'h90

`define BH_TIMEOUT                  9'h180  // 384
`define BH_TIMEDLY                  9'ha0  //???��?????��
`define COMP_WK_STATE               9'hb0
`define LOOK_IN_GPIO                9'h1f0
`define LOOK_OUT_GPIO               9'h1f4
`define M2S_0TMP                    9'h1e0
`define S2M_10TMP                   9'h1e4
`define BH_SELCHAN                  9'hb4
`define BH_SEL2                     9'hb8
`define BH_SELMODE                  9'hc0
//`define EC_MAT_ARRIVED_TIME         9'h17c  
//`define EC_MOVE_IN_TIMEOUT          9'h178 

// register for read data from controller
`define READ_DATA_REG          9'h0c4 // 196
`define READ_DATA_REG2         9'h0c8 // 200


//`define READ_DATA_REG_5          9'h110 
//`define READ_DATA_REG_6          9'h114 
//`define READ_DATA_REG_7          9'h118 
//`define READ_DATA_REG_8          9'h11C 
//`define READ_DATA_REG_9          9'h120 

// register for write data to controller
//`define WRITE_DATA_REG_1          9'h124 
//`define WRITE_DATA_REG_2          9'h128
//`define WRITE_DATA_REG_3          9'h12C 
//`define WRITE_DATA_REG_4          9'h130 
//`define WRITE_DATA_REG_5          9'h134 
//`define WRITE_DATA_REG_6          9'h138 
//`define WRITE_DATA_REG_7          9'h13C 
//`define WRITE_DATA_REG_8          9'h140 
//`define WRITE_DATA_REG_9          9'h144 

       

// Register for Write Only
`define BH_TIMEOUT_1                9'h180  //Set the timeout time for position 1
`define BH_TIMEOUT_2                9'h184  //Set the timeout time for position 2
`define BH_TIMEOUT_3                9'h188  //Set the timeout time for position 3
`define BH_TIMEOUT_4                9'h18c  //Set the timeout time for position 4
`define BH_TIMEOUT_5                9'h190  //Set the timeout time for position 5
`define BH_TIMEOUT_6                9'h194  //Set the timeout time for position 6
`define BH_TIMEOUT_7                9'h198  //Set the timeout time for position 7
`define BH_TIMEOUT_8                9'h19c  //Set the timeout time for position 8

`define BH_TIMEDLY1                9'h1a0  //Set the delay time for position 1
`define BH_TIMEDLY2                9'h1a4  //Set the delay time for position 2
`define BH_TIMEDLY3                9'h1a8  //Set the delay time for position 3
`define BH_TIMEDLY4                9'h1ac  //Set the delay time for position 4
`define BH_TIMEDLY_1                9'h1a0  //Set the delay time for position 1   416
`define BH_TIMEDLY_2                9'h1a4  //Set the delay time for position 2   420
`define BH_TIMEDLY_3                9'h1a8  //Set the delay time for position 3
`define BH_TIMEDLY_4                9'h1ac  //Set the delay time for position 4
//`define BH_TIMEDLY_5                9'h1b0  //Set the delay time for position 5
//`define BH_TIMEDLY_6                9'h1b4  //Set the delay time for position 6
//`define BH_TIMEDLY_7                9'h1b8  //Set the delay time for position 7
//`define BH_TIMEDLY_8                9'h1bc  //Set the delay time for position 8

`define PROG1_SPEED                 9'h100
`define PROG2_SPEED                 9'h104
`define PROG3_SPEED                 9'h108
`define PROG4_SPEED                 9'h10c
`define PROG5_SPEED                 9'h110
`define PROG6_SPEED                 9'h114
`define PROG7_SPEED                 9'h118

`define DRIVE_START                 9'ha8
`define DRIVE_STOP                  9'hac
`define DRIVE_ON                    9'h100
`define DRIVE_RESET                 9'h104
`define DRIVE_PAUSE                 9'h108
`define DRIVE_RESUME                9'h10c
`define DRIVE_QUICKSTOP             9'h110
`define HOME_SPD                    9'h114
`define HOME_ACC                    9'h118
`define HOME_DEC                    9'h11c
`define JOG_SPD                     9'h120
`define JOG_ACC                     9'h124
`define JOG_DEC                     9'h128
`define MOVE_SPD                    9'h12c
`define MOVE_ACC                    9'h130
`define MOVE_DEC                    9'h134
`define SPD_MAX                     9'h138
`define ACC_MAX                     9'h13c
`define DEC_MAX                     9'h140
`define PF_MODE                     9'h144
`define STOP_DEC                    9'h148
`define RSERV_DIR                   9'h14c
`define STEP_PULSE                  9'h150
`define TARGET_PULSE                9'h154
`define RSERV_ABSPOS                9'h158
`define RSERV_DRIVE_ALARM           9'h15c


`define ERR_RANGE  9'h050 // 80
// `define PARAM_1 9'h1d8 // 472
// `define PARAM_2 9'h1dc // 476
// `define PARAM_3 9'h1e0 // 480
// `define PARAM_4 9'h1e4 // 484


`define CON_PARAM_4 9'h1e8 // 488

`define SER_NUM1 9'h0d0 // 208
`define SER_NUM2 9'h0d4 // 212
`define SER_NUM3 9'h0d8 // 216
`define SER_NUM4 9'h0dc // 220

`define DATA_WR_ADDR1     9'h60 
`define DATA_WR_ADDR2     9'h64 
`define DATA_WR_ADDR3     9'h68 

//`define PARAM_5 9'h170 // 368
// Register for Read Only
//`define LOC_STATUS_1                9'h1c0 // Read the status register at position 1
//`define LOC_STATUS_2                9'h1c4 // Read the status register at position 2
//`define LOC_STATUS_3                9'h1c8 // Read the status register at position 3
//`define LOC_STATUS_4                9'h1cc // Read the status register at position 4
//`define LOC_STATUS_5                9'h1d0 // Read the status register at position 5
//`define LOC_STATUS_6                9'h1d4 // Read the status register at position 6
//`define LOC_STATUS_7                9'h1d8 // Read the status register at position 7
//`define LOC_STATUS_8                9'h1dc // Read the status register at position 8

//`define LOC_STATUS_1                   9'h1e8 // Read the behavior register at position 1
//`define LOC_STATUS_2                   9'h1ec // Read the behavior register at position 2
`define LOC_STATUS_1                   9'h1f0 // Read the behavior register at position 3
`define LOC_STATUS_2                   9'h1f4 // Read the behavior register at position 4
`define LOC_STATUS_3                   9'h1f0 // Read the behavior register at position 3
`define LOC_STATUS_4                   9'h1f4 // Read the behavior register at position 4
//`define LOC_STATUS_5                   9'h1f8 // Read the behavior register at position 5
//`define LOC_STATUS_6                   9'h1fc // Read the behavior register at position 6
//`define LOC_STATUS_7                  10'h200 // Read the behavior register at position 7

`define LOC_BEH_1                   9'h160 // Read the behavior register at position 1
`define LOC_BEH_2                   9'h164 // Read the behavior register at position 2
`define LOC_BEH_3                   9'h168 // Read the behavior register at position 3
`define LOC_BEH_4                   9'h16c // Read the behavior register at position 4
//`define LOC_BEH_5                   9'h170 // Read the behavior register at position 5
//`define LOC_BEH_6                   9'h174 // Read the behavior register at position 6
//`define LOC_BEH_7                  10'h178 // Read the behavior register at position 7
//`define LOC_BEH_8                  10'h204 // Read the behavior register at position 8



`define UNIT_EMERGENCY_CTRL         9'h170  // W   ��Ԫ�������ƣ�1:��ͣ,2:��ͣ,3:����,4:ͣ��
`define UNIT_STATUS                 9'h174  // W   ��Ԫ״̬��    1:����,2:ִ����,3:��Ԫ����
`define EQUIPMENT_EMERGENCY_CTRL    9'h178  // W   �豸�������ƣ�1:��ͣ,2:��ͣ,3:����,4:ͣ��
`define EQUIPMENT_STATUS            9'h17c  // W   �豸״̬��    1:����,2:ִ����,3:�豸����
`define EQUIPMENT_ID                9'h1b0  // R   �豸���
`define SET_WORK_MODE               9'h1b4  // R/W ����ģʽ��1:����,2:����,3:�ֶ�,4:�ػ�
`define LOCAL_SECURITY              9'h1b8  // R/W ���ذ�ȫ��0:Σ��,1:��ȫ
`define LINK_SECURITY               9'h1bc  // W   ������ȫ��0:Σ��,1:��ȫ
`define TASK_OCCUPY                 9'h1d0  // R/W ����ռ�ã�0:����,1:ռ��
`define LINK_LOCK                   9'h1d4  // W   ����������0:����,1:����,
`define TASK_ID                     9'h1f8  // W   ������
`define SC_STATUS_1                 9'h038  // R   ���״̬1
`define SC_STATUS_2                 9'h03C  // R   ���״̬2
`define HEART_TIME                  9'h0F0  // W   ����ʱ�䣺ÿ�����ʱ�䷢��һ��������ѯ�ж�,0:����������
`define GATHER_TIME                 9'h0F4  // W   ����ʱ�䣺ÿ�����ʱ�䷢��һ�����ݲɼ��ж�,0:������ɼ�
`define HEART_STATUS                9'h0F8  // W   ����״̬���أ�0��������1���쳣
`define GATHER_STATUS               9'h0FC  // W   ����״̬���أ�0��������1���쳣

`define RESULT1                   9'h19c // Read the behavior register at position 1
`define RESULT_1                   9'h0F0 // Read 

`define NUM_VALUE2                9'h1c4
`define NUM_VALUE3                9'h1c8

// Flow Base Address
`define FLOW_CTRL_ADDR        {20'h4_0600}    // 263680

// Flow infomation offset
`define BH_STOP_OREG0               9'h80  // For Read, when Flow end interrupt is assert,PS will read this addr
`define BH_STOP_OREG1               9'h84  // For Read, when Flow end interrupt is assert,PS will read this addr
`define FW_CURRENT                  9'ha4  // For Read, when Flow end interrupt is assert,PS will read this addr
`define FW_START_ADDR               9'ha0  // For Write,PS write Flow id and start flag to start flow ctrl
`define FW_STOP_ADDR                9'hb0  // For Write,PS write Flow id and break or cancel flag to break or cancel flow ctrl
`define FW_LOOP_TIMES               9'hc0  // For Write,PS write Flow id and break or cancel flag to break or cancel flow ctrl
`define FW_PS_WR_ADDR1              9'h60  // For Write,PS write Flow information to PL BRAM
`define FW_PS_WR_ADDR2              9'h64  // For Write,PS write Flow information to PL BRAM
`define FW_PS_WR_ADDR3              9'h68  // For Write,PS write Flow information to PL BRAM
`define FLOW_SELECT                 9'h70  // For Write,PS write Flow information to PL BRAM
`define FLOW_STATUS_RD_LOW          9'h74  // For Read ,PS write Flow information to PL BRAM
`define FLOW_STATUS_RD_HIGH         9'h78  // For Read ,PS write Flow information to PL BRAM


//master components address map------------------
`define ROLLER_2126_REG_BIAS        {20'h0_0800}
`define ROLLER_2037_REG_BIAS        {20'h0_0A00}
`define ROLLER_3018_REG_BIAS        {20'h0_0C00}
`define ROLLER_3168_REG_BIAS        {20'h0_0E00}
`define ROLLER_3189_REG_BIAS        {20'h0_1000}
`define ROLLER_2108_REG_BIAS        {20'h0_1200}
`define ROLLER_2113_REG_BIAS        {20'h0_1400}
`define ROLLER_2095_REG_BIAS        {20'h0_1600}
`define ROLLER_3135_REG_BIAS        {20'h0_1800}
`define ROLLER_3048_REG_BIAS        {20'h0_1A00}
`define ROLLER_3050_REG_BIAS        {20'h0_1C00}
`define ROLLER_3078_REG_BIAS        {20'h0_1E00}
`define ROLLER_3106_REG_BIAS        {20'h0_2000}
`define ROLLER_2009_REG_BIAS        {20'h0_2200}
`define ROLLER_2060_REG_BIAS        {20'h0_2400}
`define ROLLER_2094_REG_BIAS        {20'h0_2600}
`define ROLLER_3212_REG_BIAS        {20'h0_2800}
`define ROLLER_3119_REG_BIAS        {20'h0_2A00}
`define ROLLER_3155_REG_BIAS        {20'h0_2C00}
`define ROLLER_2156_REG_BIAS        {20'h0_2E00}
`define ROLLER_1037_REG_BIAS        {20'h0_3000}
`define ROLLER_3060_REG_BIAS        {20'h0_3200}
`define ROLLER_1052_REG_BIAS        {20'h0_3400}
`define ROLLER_2127_REG_BIAS        {20'h0_3600}
`define ROLLER_2042_REG_BIAS        {20'h0_3800}
`define ROLLER_1029_REG_BIAS        {20'h0_3A00}
`define ROLLER_3002_REG_BIAS        {20'h0_3C00}
`define ROLLER_1088_REG_BIAS        {20'h0_3E00}
`define ROLLER_3095_REG_BIAS        {20'h0_4000}
`define ROLLER_2066_REG_BIAS        {20'h0_4200}
`define ROLLER_2144_REG_BIAS        {20'h0_4400}
`define ROLLER_3170_REG_BIAS        {20'h0_4600}
`define ROLLER_3022_REG_BIAS        {20'h0_4800}
`define ROLLER_3131_REG_BIAS        {20'h0_4A00}
`define ROLLER_3011_REG_BIAS        {20'h0_4C00}
`define ROLLER_1108_REG_BIAS        {20'h0_4E00}
`define ROLLER_2052_REG_BIAS        {20'h0_5000}
`define ROLLER_2014_REG_BIAS        {20'h0_5200}
`define ROLLER_2093_REG_BIAS        {20'h0_5400}
`define ROLLER_3169_REG_BIAS        {20'h0_5600}
`define ROLLER_3005_REG_BIAS        {20'h0_5800}
`define ROLLER_2010_REG_BIAS        {20'h0_5A00}
`define ROLLER_2070_REG_BIAS        {20'h0_5C00}
`define ROLLER_2073_REG_BIAS        {20'h0_5E00}
`define ROLLER_3096_REG_BIAS        {20'h0_6000}
`define ROLLER_1008_REG_BIAS        {20'h0_6200}
`define ROLLER_3013_REG_BIAS        {20'h0_6400}
`define ROLLER_1076_REG_BIAS        {20'h0_6600}
`define ROLLER_2155_REG_BIAS        {20'h0_6800}
`define ROLLER_3006_REG_BIAS        {20'h0_6A00}
`define ROLLER_2030_REG_BIAS        {20'h0_6C00}
`define ROLLER_3103_REG_BIAS        {20'h0_6E00}
`define ROLLER_2003_REG_BIAS        {20'h0_7000}
`define ROLLER_1000_REG_BIAS        {20'h0_7200}
`define ROLLER_3082_REG_BIAS        {20'h0_7400}
`define ROLLER_2089_REG_BIAS        {20'h0_7600}
`define ROLLER_3028_REG_BIAS        {20'h0_7800}
`define ROLLER_3220_REG_BIAS        {20'h0_7A00}
`define ROLLER_1110_REG_BIAS        {20'h0_7C00}
`define ROLLER_2084_REG_BIAS        {20'h0_7E00}
`define ROLLER_3008_REG_BIAS        {20'h0_8000}
`define ROLLER_2034_REG_BIAS        {20'h0_8200}
`define ROLLER_1002_REG_BIAS        {20'h0_8400}
`define ROLLER_2004_REG_BIAS        {20'h0_8600}
`define ROLLER_3062_REG_BIAS        {20'h0_8800}
`define ROLLER_3159_REG_BIAS        {20'h0_8A00}
`define ROLLER_3122_REG_BIAS        {20'h0_8C00}
`define ROLLER_3127_REG_BIAS        {20'h0_8E00}
`define ROLLER_2152_REG_BIAS        {20'h0_9000}
`define ROLLER_1085_REG_BIAS        {20'h0_9200}
`define ROLLER_1072_REG_BIAS        {20'h0_9400}
`define ROLLER_3164_REG_BIAS        {20'h0_9600}
`define ROLLER_1013_REG_BIAS        {20'h0_9800}
`define ROLLER_2150_REG_BIAS        {20'h0_9A00}
`define ROLLER_1049_REG_BIAS        {20'h0_9C00}
`define ROLLER_3074_REG_BIAS        {20'h0_9E00}
`define ROLLER_2091_REG_BIAS        {20'h0_A000}
`define ROLLER_2118_REG_BIAS        {20'h0_A200}
`define ROLLER_3072_REG_BIAS        {20'h0_A400}
`define ROLLER_1011_REG_BIAS        {20'h0_A600}
`define ROLLER_2063_REG_BIAS        {20'h0_A800}
`define ROLLER_2106_REG_BIAS        {20'h0_AA00}
`define ROLLER_2162_REG_BIAS        {20'h0_AC00}
`define ROLLER_1084_REG_BIAS        {20'h0_AE00}
`define ROLLER_2149_REG_BIAS        {20'h0_B000}
`define ROLLER_2077_REG_BIAS        {20'h0_B200}
`define ROLLER_3023_REG_BIAS        {20'h0_B400}
`define ROLLER_3039_REG_BIAS        {20'h0_B600}
`define ROLLER_3213_REG_BIAS        {20'h0_B800}
`define ROLLER_3116_REG_BIAS        {20'h0_BA00}
`define ROLLER_2099_REG_BIAS        {20'h0_BC00}
`define ROLLER_1025_REG_BIAS        {20'h0_BE00}
`define ROLLER_2139_REG_BIAS        {20'h0_C000}
`define ROLLER_2092_REG_BIAS        {20'h0_C200}
`define ROLLER_3086_REG_BIAS        {20'h0_C400}
`define ROLLER_1078_REG_BIAS        {20'h0_C600}
`define ROLLER_3133_REG_BIAS        {20'h0_C800}
`define ROLLER_1059_REG_BIAS        {20'h0_CA00}
`define ROLLER_2081_REG_BIAS        {20'h0_CC00}
`define ROLLER_1086_REG_BIAS        {20'h0_CE00}
`define ROLLER_2130_REG_BIAS        {20'h0_D000}
`define ROLLER_1007_REG_BIAS        {20'h0_D200}
`define ROLLER_2101_REG_BIAS        {20'h0_D400}
`define ROLLER_2018_REG_BIAS        {20'h0_D600}
`define ROLLER_3120_REG_BIAS        {20'h0_D800}
`define ROLLER_3094_REG_BIAS        {20'h0_DA00}
`define ROLLER_1032_REG_BIAS        {20'h0_DC00}
`define ROLLER_1014_REG_BIAS        {20'h0_DE00}
`define ROLLER_1109_REG_BIAS        {20'h0_E000}
`define ROLLER_2024_REG_BIAS        {20'h0_E200}
`define ROLLER_1044_REG_BIAS        {20'h0_E400}
`define ROLLER_3079_REG_BIAS        {20'h0_E600}
`define ROLLER_1055_REG_BIAS        {20'h0_E800}
`define ROLLER_1101_REG_BIAS        {20'h0_EA00}
`define ROLLER_1080_REG_BIAS        {20'h0_EC00}
`define ROLLER_3056_REG_BIAS        {20'h0_EE00}
`define ROLLER_1074_REG_BIAS        {20'h0_F000}
`define ROLLER_1020_REG_BIAS        {20'h0_F200}
`define ROLLER_2131_REG_BIAS        {20'h0_F400}
`define ROLLER_1015_REG_BIAS        {20'h0_F600}
`define ROLLER_2025_REG_BIAS        {20'h0_F800}
`define ROLLER_3080_REG_BIAS        {20'h0_FA00}
`define ROLLER_3059_REG_BIAS        {20'h0_FC00}
`define ROLLER_1058_REG_BIAS        {20'h0_FE00}
`define ROLLER_1033_REG_BIAS        {20'h1_0000}
`define ROLLER_3058_REG_BIAS        {20'h1_0200}
`define ROLLER_3215_REG_BIAS        {20'h1_0400}
`define ROLLER_1062_REG_BIAS        {20'h1_0600}
`define ROLLER_1107_REG_BIAS        {20'h1_0800}
`define ROLLER_2013_REG_BIAS        {20'h1_0A00}
`define ROLLER_1028_REG_BIAS        {20'h1_0C00}
`define ROLLER_2134_REG_BIAS        {20'h1_0E00}
`define ROLLER_3203_REG_BIAS        {20'h1_1000}
`define ROLLER_3046_REG_BIAS        {20'h1_1200}
`define ROLLER_2007_REG_BIAS        {20'h1_1400}
`define ROLLER_2032_REG_BIAS        {20'h1_1600}
`define ROLLER_1030_REG_BIAS        {20'h1_1800}
`define ROLLER_3042_REG_BIAS        {20'h1_1A00}
`define ROLLER_2107_REG_BIAS        {20'h1_1C00}
`define ROLLER_3161_REG_BIAS        {20'h1_1E00}
`define ROLLER_3083_REG_BIAS        {20'h1_2000}
`define ROLLER_1099_REG_BIAS        {20'h1_2200}
`define ROLLER_2047_REG_BIAS        {20'h1_2400}
`define ROLLER_3134_REG_BIAS        {20'h1_2600}
`define ROLLER_1093_REG_BIAS        {20'h1_2800}
`define ROLLER_3197_REG_BIAS        {20'h1_2A00}
`define ROLLER_3021_REG_BIAS        {20'h1_2C00}
`define ROLLER_3206_REG_BIAS        {20'h1_2E00}
`define ROLLER_3043_REG_BIAS        {20'h1_3000}
`define ROLLER_3158_REG_BIAS        {20'h1_3200}
`define ROLLER_1036_REG_BIAS        {20'h1_3400}
`define ROLLER_3044_REG_BIAS        {20'h1_3600}
`define ROLLER_3061_REG_BIAS        {20'h1_3800}
`define ROLLER_1042_REG_BIAS        {20'h1_3A00}
`define ROLLER_3057_REG_BIAS        {20'h1_3C00}
`define ROLLER_3211_REG_BIAS        {20'h1_3E00}
`define ROLLER_3152_REG_BIAS        {20'h1_4000}
`define ROLLER_1057_REG_BIAS        {20'h1_4200}
`define ROLLER_1105_REG_BIAS        {20'h1_4400}
`define ROLLER_2111_REG_BIAS        {20'h1_4600}
`define ROLLER_2045_REG_BIAS        {20'h1_4800}
`define ROLLER_3098_REG_BIAS        {20'h1_4A00}
`define ROLLER_3110_REG_BIAS        {20'h1_4C00}
`define ROLLER_3105_REG_BIAS        {20'h1_4E00}
`define ROLLER_3129_REG_BIAS        {20'h1_5000}
`define ROLLER_3171_REG_BIAS        {20'h1_5200}
`define ROLLER_3138_REG_BIAS        {20'h1_5400}
`define ROLLER_3033_REG_BIAS        {20'h1_5600}
`define ROLLER_3151_REG_BIAS        {20'h1_5800}
`define ROLLER_1045_REG_BIAS        {20'h1_5A00}
`define ROLLER_2078_REG_BIAS        {20'h1_5C00}
`define ROLLER_1104_REG_BIAS        {20'h1_5E00}
`define ROLLER_3090_REG_BIAS        {20'h1_6000}
`define ROLLER_2138_REG_BIAS        {20'h1_6200}
`define ROLLER_2105_REG_BIAS        {20'h1_6400}
`define ROLLER_2008_REG_BIAS        {20'h1_6600}
`define ROLLER_3030_REG_BIAS        {20'h1_6800}
`define ROLLER_1081_REG_BIAS        {20'h1_6A00}
`define ROLLER_1006_REG_BIAS        {20'h1_6C00}
`define ROLLER_1092_REG_BIAS        {20'h1_6E00}
`define ROLLER_2120_REG_BIAS        {20'h1_7000}
`define ROLLER_2146_REG_BIAS        {20'h1_7200}
`define ROLLER_1004_REG_BIAS        {20'h1_7400}
`define ROLLER_3038_REG_BIAS        {20'h1_7600}
`define ROLLER_3112_REG_BIAS        {20'h1_7800}
`define ROLLER_1038_REG_BIAS        {20'h1_7A00}
`define ROLLER_2085_REG_BIAS        {20'h1_7C00}
`define ROLLER_3004_REG_BIAS        {20'h1_7E00}
`define ROLLER_2087_REG_BIAS        {20'h1_8000}
`define ROLLER_3066_REG_BIAS        {20'h1_8200}
`define ROLLER_2137_REG_BIAS        {20'h1_8400}
`define ROLLER_1010_REG_BIAS        {20'h1_8600}
`define ROLLER_2062_REG_BIAS        {20'h1_8800}
`define ROLLER_2090_REG_BIAS        {20'h1_8A00}
`define ROLLER_2098_REG_BIAS        {20'h1_8C00}
`define ROLLER_1106_REG_BIAS        {20'h1_8E00}
`define ROLLER_3201_REG_BIAS        {20'h1_9000}
`define ROLLER_3073_REG_BIAS        {20'h1_9200}
`define ROLLER_3034_REG_BIAS        {20'h1_9400}
`define ROLLER_2023_REG_BIAS        {20'h1_9600}
`define ROLLER_1053_REG_BIAS        {20'h1_9800}
`define ROLLER_3049_REG_BIAS        {20'h1_9A00}
`define ROLLER_3051_REG_BIAS        {20'h1_9C00}
`define ROLLER_2163_REG_BIAS        {20'h1_9E00}
`define ROLLER_3148_REG_BIAS        {20'h1_A000}
`define ROLLER_2011_REG_BIAS        {20'h1_A200}
`define ROLLER_3165_REG_BIAS        {20'h1_A400}
`define ROLLER_2031_REG_BIAS        {20'h1_A600}
`define ROLLER_1065_REG_BIAS        {20'h1_A800}
`define ROLLER_1035_REG_BIAS        {20'h1_AA00}
`define ROLLER_2001_REG_BIAS        {20'h1_AC00}
`define ROLLER_2017_REG_BIAS        {20'h1_AE00}
`define ROLLER_1075_REG_BIAS        {20'h1_B000}
`define ROLLER_2054_REG_BIAS        {20'h1_B200}
`define ROLLER_2124_REG_BIAS        {20'h1_B400}
`define ROLLER_1067_REG_BIAS        {20'h1_B600}
`define ROLLER_2064_REG_BIAS        {20'h1_B800}
`define ROLLER_2016_REG_BIAS        {20'h1_BA00}
`define ROLLER_3143_REG_BIAS        {20'h1_BC00}
`define ROLLER_3100_REG_BIAS        {20'h1_BE00}
`define ROLLER_3180_REG_BIAS        {20'h1_C000}
`define ROLLER_3140_REG_BIAS        {20'h1_C200}
`define ROLLER_3108_REG_BIAS        {20'h1_C400}
`define ROLLER_1043_REG_BIAS        {20'h1_C600}
`define ROLLER_3091_REG_BIAS        {20'h1_C800}
`define ROLLER_2071_REG_BIAS        {20'h1_CA00}
`define ROLLER_1098_REG_BIAS        {20'h1_CC00}
`define ROLLER_1063_REG_BIAS        {20'h1_CE00}
`define ROLLER_1073_REG_BIAS        {20'h1_D000}
`define ROLLER_3175_REG_BIAS        {20'h1_D200}
`define ROLLER_1034_REG_BIAS        {20'h1_D400}
`define ROLLER_3054_REG_BIAS        {20'h1_D600}
`define ROLLER_3065_REG_BIAS        {20'h1_D800}
`define ROLLER_2100_REG_BIAS        {20'h1_DA00}
`define ROLLER_2153_REG_BIAS        {20'h1_DC00}
`define ROLLER_3139_REG_BIAS        {20'h1_DE00}
`define ROLLER_3208_REG_BIAS        {20'h1_E000}
`define ROLLER_2160_REG_BIAS        {20'h1_E200}
`define ROLLER_3099_REG_BIAS        {20'h1_E400}
`define ROLLER_2000_REG_BIAS        {20'h1_E600}
`define ROLLER_2116_REG_BIAS        {20'h1_E800}
`define ROLLER_2097_REG_BIAS        {20'h1_EA00}
`define ROLLER_2140_REG_BIAS        {20'h1_EC00}
`define ROLLER_2041_REG_BIAS        {20'h1_EE00}
`define ROLLER_3178_REG_BIAS        {20'h1_F000}
`define ROLLER_2158_REG_BIAS        {20'h1_F200}
`define ROLLER_3202_REG_BIAS        {20'h1_F400}
`define ROLLER_3177_REG_BIAS        {20'h1_F600}
`define ROLLER_3179_REG_BIAS        {20'h1_F800}
`define ROLLER_2012_REG_BIAS        {20'h1_FA00}
`define ROLLER_1079_REG_BIAS        {20'h1_FC00}
`define ROLLER_1091_REG_BIAS        {20'h1_FE00}
`define ROLLER_3146_REG_BIAS        {20'h2_0000}
`define ROLLER_3142_REG_BIAS        {20'h2_0200}
`define ROLLER_3162_REG_BIAS        {20'h2_0400}
`define ROLLER_3111_REG_BIAS        {20'h2_0600}
`define ROLLER_1012_REG_BIAS        {20'h2_0800}
`define ROLLER_2115_REG_BIAS        {20'h2_0A00}
`define ROLLER_1087_REG_BIAS        {20'h2_0C00}
`define ROLLER_3037_REG_BIAS        {20'h2_0E00}
`define ROLLER_2082_REG_BIAS        {20'h2_1000}
`define ROLLER_3123_REG_BIAS        {20'h2_1200}
`define ROLLER_2145_REG_BIAS        {20'h2_1400}
`define ROLLER_3193_REG_BIAS        {20'h2_1600}
`define ROLLER_3160_REG_BIAS        {20'h2_1800}
`define ROLLER_3176_REG_BIAS        {20'h2_1A00}
`define ROLLER_1082_REG_BIAS        {20'h2_1C00}
`define ROLLER_2122_REG_BIAS        {20'h2_1E00}
`define ROLLER_3000_REG_BIAS        {20'h2_2000}
`define ROLLER_3187_REG_BIAS        {20'h2_2200}
`define ROLLER_1005_REG_BIAS        {20'h2_2400}
`define ROLLER_1111_REG_BIAS        {20'h2_2600}
`define ROLLER_3041_REG_BIAS        {20'h2_2800}
`define ROLLER_3055_REG_BIAS        {20'h2_2A00}
`define ROLLER_3153_REG_BIAS        {20'h2_2C00}
`define ROLLER_1066_REG_BIAS        {20'h2_2E00}
`define ROLLER_3115_REG_BIAS        {20'h2_3000}
`define ROLLER_1061_REG_BIAS        {20'h2_3200}
`define ROLLER_2051_REG_BIAS        {20'h2_3400}
`define ROLLER_2044_REG_BIAS        {20'h2_3600}
`define ROLLER_3107_REG_BIAS        {20'h2_3800}
`define ROLLER_3009_REG_BIAS        {20'h2_3A00}
`define ROLLER_3015_REG_BIAS        {20'h2_3C00}
`define ROLLER_647 _REG_BIAS        {20'h2_3E00}
`define ROLLER_2104_REG_BIAS        {20'h2_4000}
`define ROLLER_2015_REG_BIAS        {20'h2_4200}
`define ROLLER_3198_REG_BIAS        {20'h2_4400}
`define ROLLER_3205_REG_BIAS        {20'h2_4600}
`define ROLLER_3121_REG_BIAS        {20'h2_4800}
`define ROLLER_2114_REG_BIAS        {20'h2_4A00}
`define ROLLER_1064_REG_BIAS        {20'h2_4C00}
`define ROLLER_3141_REG_BIAS        {20'h2_4E00}
`define ROLLER_3064_REG_BIAS        {20'h2_5000}
`define ROLLER_1056_REG_BIAS        {20'h2_5200}
`define ROLLER_1090_REG_BIAS        {20'h2_5400}
`define ROLLER_1050_REG_BIAS        {20'h2_5600}
`define ROLLER_1041_REG_BIAS        {20'h2_5800}
`define ROLLER_2055_REG_BIAS        {20'h2_5A00}
`define ROLLER_3113_REG_BIAS        {20'h2_5C00}
`define ROLLER_3010_REG_BIAS        {20'h2_5E00}
`define ROLLER_2103_REG_BIAS        {20'h2_6000}
`define ROLLER_2102_REG_BIAS        {20'h2_6200}
`define ROLLER_3147_REG_BIAS        {20'h2_6400}
`define ROLLER_3012_REG_BIAS        {20'h2_6600}
`define ROLLER_2143_REG_BIAS        {20'h2_6800}
`define ROLLER_3053_REG_BIAS        {20'h2_6A00}
`define ROLLER_2038_REG_BIAS        {20'h2_6C00}
`define ROLLER_2110_REG_BIAS        {20'h2_6E00}
`define ROLLER_3084_REG_BIAS        {20'h2_7000}
`define ROLLER_1018_REG_BIAS        {20'h2_7200}
`define ROLLER_2159_REG_BIAS        {20'h2_7400}
`define ROLLER_2135_REG_BIAS        {20'h2_7600}
`define ROLLER_2040_REG_BIAS        {20'h2_7800}
`define ROLLER_3102_REG_BIAS        {20'h2_7A00}
`define ROLLER_1023_REG_BIAS        {20'h2_7C00}
`define ROLLER_3097_REG_BIAS        {20'h2_7E00}
`define ROLLER_1022_REG_BIAS        {20'h2_8000}
`define ROLLER_2128_REG_BIAS        {20'h2_8200}
`define ROLLER_3210_REG_BIAS        {20'h2_8400}
`define ROLLER_1040_REG_BIAS        {20'h2_8600}
`define ROLLER_3200_REG_BIAS        {20'h2_8800}
`define ROLLER_3124_REG_BIAS        {20'h2_8A00}
`define ROLLER_3185_REG_BIAS        {20'h2_8C00}
`define ROLLER_2043_REG_BIAS        {20'h2_8E00}
`define ROLLER_3036_REG_BIAS        {20'h2_9000}
`define ROLLER_2033_REG_BIAS        {20'h2_9200}
`define ROLLER_3029_REG_BIAS        {20'h2_9400}
`define ROLLER_1017_REG_BIAS        {20'h2_9600}
`define ROLLER_1097_REG_BIAS        {20'h2_9800}
`define ROLLER_3183_REG_BIAS        {20'h2_9A00}
`define ROLLER_2119_REG_BIAS        {20'h2_9C00}
`define ROLLER_1027_REG_BIAS        {20'h2_9E00}
`define ROLLER_3130_REG_BIAS        {20'h2_A000}
`define ROLLER_3071_REG_BIAS        {20'h2_A200}
`define ROLLER_2065_REG_BIAS        {20'h2_A400}
`define ROLLER_3087_REG_BIAS        {20'h2_A600}
`define ROLLER_3077_REG_BIAS        {20'h2_A800}
`define ROLLER_1071_REG_BIAS        {20'h2_AA00}
`define ROLLER_2056_REG_BIAS        {20'h2_AC00}
`define ROLLER_3109_REG_BIAS        {20'h2_AE00}
`define ROLLER_2059_REG_BIAS        {20'h2_B000}
`define ROLLER_3163_REG_BIAS        {20'h2_B200}
`define ROLLER_3019_REG_BIAS        {20'h2_B400}
`define ROLLER_3027_REG_BIAS        {20'h2_B600}
`define ROLLER_2074_REG_BIAS        {20'h2_B800}
`define ROLLER_3031_REG_BIAS        {20'h2_BA00}
`define ROLLER_3003_REG_BIAS        {20'h2_BC00}
`define ROLLER_3093_REG_BIAS        {20'h2_BE00}
`define ROLLER_2164_REG_BIAS        {20'h2_C000}
`define ROLLER_3070_REG_BIAS        {20'h2_C200}
`define ROLLER_3181_REG_BIAS        {20'h2_C400}
`define ROLLER_1026_REG_BIAS        {20'h2_C600}
`define ROLLER_3199_REG_BIAS        {20'h2_C800}
`define ROLLER_2029_REG_BIAS        {20'h2_CA00}
`define ROLLER_2048_REG_BIAS        {20'h2_CC00}
`define ROLLER_3032_REG_BIAS        {20'h2_CE00}
`define ROLLER_2088_REG_BIAS        {20'h2_D000}
`define ROLLER_3194_REG_BIAS        {20'h2_D200}
`define ROLLER_3216_REG_BIAS        {20'h2_D400}
`define ROLLER_2005_REG_BIAS        {20'h2_D600}
`define ROLLER_3154_REG_BIAS        {20'h2_D800}
`define ROLLER_2072_REG_BIAS        {20'h2_DA00}
`define ROLLER_1094_REG_BIAS        {20'h2_DC00}
`define ROLLER_1077_REG_BIAS        {20'h2_DE00}
`define ROLLER_3191_REG_BIAS        {20'h2_E000}
`define ROLLER_2083_REG_BIAS        {20'h2_E200}
`define ROLLER_1070_REG_BIAS        {20'h2_E400}
`define ROLLER_2117_REG_BIAS        {20'h2_E600}
`define ROLLER_3137_REG_BIAS        {20'h2_E800}
`define ROLLER_3196_REG_BIAS        {20'h2_EA00}
`define ROLLER_3144_REG_BIAS        {20'h2_EC00}
`define ROLLER_1060_REG_BIAS        {20'h2_EE00}
`define ROLLER_2096_REG_BIAS        {20'h2_F000}
`define ROLLER_1009_REG_BIAS        {20'h2_F200}
`define ROLLER_3195_REG_BIAS        {20'h2_F400}
`define ROLLER_3118_REG_BIAS        {20'h2_F600}
`define ROLLER_1031_REG_BIAS        {20'h2_F800}
`define ROLLER_1069_REG_BIAS        {20'h2_FA00}
`define ROLLER_3081_REG_BIAS        {20'h2_FC00}
`define ROLLER_2039_REG_BIAS        {20'h2_FE00}
`define ROLLER_2132_REG_BIAS        {20'h3_0000}
`define ROLLER_2067_REG_BIAS        {20'h3_0200}
`define ROLLER_3204_REG_BIAS        {20'h3_0400}
`define ROLLER_3063_REG_BIAS        {20'h3_0600}
`define ROLLER_3016_REG_BIAS        {20'h3_0800}
`define ROLLER_2028_REG_BIAS        {20'h3_0A00}
`define ROLLER_3045_REG_BIAS        {20'h3_0C00}
`define ROLLER_1103_REG_BIAS        {20'h3_0E00}
`define ROLLER_3035_REG_BIAS        {20'h3_1000}
`define ROLLER_2053_REG_BIAS        {20'h3_1200}
`define ROLLER_35  _REG_BIAS        {20'h3_1400}
`define ROLLER_3128_REG_BIAS        {20'h3_1600}
`define ROLLER_1024_REG_BIAS        {20'h3_1800}
`define ROLLER_2147_REG_BIAS        {20'h3_1A00}
`define ROLLER_2142_REG_BIAS        {20'h3_1C00}
`define ROLLER_1047_REG_BIAS        {20'h3_1E00}
`define ROLLER_2157_REG_BIAS        {20'h3_2000}
`define ROLLER_3207_REG_BIAS        {20'h3_2200}
`define ROLLER_3150_REG_BIAS        {20'h3_2400}
`define ROLLER_3052_REG_BIAS        {20'h3_2600}
`define ROLLER_3192_REG_BIAS        {20'h3_2800}
`define ROLLER_2133_REG_BIAS        {20'h3_2A00}
`define ROLLER_2022_REG_BIAS        {20'h3_2C00}
`define ROLLER_1046_REG_BIAS        {20'h3_2E00}
`define ROLLER_1068_REG_BIAS        {20'h3_3000}
`define ROLLER_1021_REG_BIAS        {20'h3_3200}
`define ROLLER_3024_REG_BIAS        {20'h3_3400}
`define ROLLER_3156_REG_BIAS        {20'h3_3600}
`define ROLLER_2046_REG_BIAS        {20'h3_3800}
`define ROLLER_3114_REG_BIAS        {20'h3_3A00}
`define ROLLER_3117_REG_BIAS        {20'h3_3C00}
`define ROLLER_2026_REG_BIAS        {20'h3_3E00}
`define ROLLER_3075_REG_BIAS        {20'h3_4000}
`define ROLLER_2020_REG_BIAS        {20'h3_4200}
`define ROLLER_2068_REG_BIAS        {20'h3_4400}
`define ROLLER_2109_REG_BIAS        {20'h3_4600}
`define ROLLER_2075_REG_BIAS        {20'h3_4800}
`define ROLLER_1083_REG_BIAS        {20'h3_4A00}
`define ROLLER_3188_REG_BIAS        {20'h3_4C00}
`define ROLLER_3167_REG_BIAS        {20'h3_4E00}
`define ROLLER_2035_REG_BIAS        {20'h3_5000}
`define ROLLER_2148_REG_BIAS        {20'h3_5200}
`define ROLLER_1096_REG_BIAS        {20'h3_5400}
`define ROLLER_2049_REG_BIAS        {20'h3_5600}
`define ROLLER_3182_REG_BIAS        {20'h3_5800}
`define ROLLER_2058_REG_BIAS        {20'h3_5A00}
`define ROLLER_3085_REG_BIAS        {20'h3_5C00}
`define ROLLER_3132_REG_BIAS        {20'h3_5E00}
`define ROLLER_3166_REG_BIAS        {20'h3_6000}
`define ROLLER_3184_REG_BIAS        {20'h3_6200}
`define ROLLER_3157_REG_BIAS        {20'h3_6400}
`define ROLLER_2079_REG_BIAS        {20'h3_6600}
`define ROLLER_1001_REG_BIAS        {20'h3_6800}
`define ROLLER_2021_REG_BIAS        {20'h3_6A00}
`define ROLLER_2057_REG_BIAS        {20'h3_6C00}
`define ROLLER_3020_REG_BIAS        {20'h3_6E00}
`define ROLLER_2125_REG_BIAS        {20'h3_7000}
`define ROLLER_1039_REG_BIAS        {20'h3_7200}
`define ROLLER_1054_REG_BIAS        {20'h3_7400}
`define ROLLER_2050_REG_BIAS        {20'h3_7600}
`define ROLLER_1095_REG_BIAS        {20'h3_7800}
`define ROLLER_3136_REG_BIAS        {20'h3_7A00}
`define ROLLER_3088_REG_BIAS        {20'h3_7C00}
`define ROLLER_3104_REG_BIAS        {20'h3_7E00}
`define ROLLER_1016_REG_BIAS        {20'h3_8000}
`define ROLLER_2129_REG_BIAS        {20'h3_8200}
`define ROLLER_2069_REG_BIAS        {20'h3_8400}
`define ROLLER_2027_REG_BIAS        {20'h3_8600}
`define ROLLER_3014_REG_BIAS        {20'h3_8800}
`define ROLLER_2019_REG_BIAS        {20'h3_8A00}
`define ROLLER_2161_REG_BIAS        {20'h3_8C00}
`define ROLLER_3017_REG_BIAS        {20'h3_8E00}
`define ROLLER_3092_REG_BIAS        {20'h3_9000}
`define ROLLER_3125_REG_BIAS        {20'h3_9200}
`define ROLLER_2002_REG_BIAS        {20'h3_9400}
`define ROLLER_1019_REG_BIAS        {20'h3_9600}
`define ROLLER_2123_REG_BIAS        {20'h3_9800}
`define ROLLER_3149_REG_BIAS        {20'h3_9A00}
`define ROLLER_2112_REG_BIAS        {20'h3_9C00}
`define ROLLER_3190_REG_BIAS        {20'h3_9E00}
`define ROLLER_1051_REG_BIAS        {20'h3_A000}
`define ROLLER_1089_REG_BIAS        {20'h3_A200}
`define ROLLER_2121_REG_BIAS        {20'h3_A400}
`define ROLLER_3001_REG_BIAS        {20'h3_A600}
`define ROLLER_3076_REG_BIAS        {20'h3_A800}
`define ROLLER_2154_REG_BIAS        {20'h3_AA00}
`define ROLLER_2061_REG_BIAS        {20'h3_AC00}
`define ROLLER_3218_REG_BIAS        {20'h3_AE00}
`define ROLLER_3145_REG_BIAS        {20'h3_B000}
`define ROLLER_3067_REG_BIAS        {20'h3_B200}
`define ROLLER_3101_REG_BIAS        {20'h3_B400}
`define ROLLER_3047_REG_BIAS        {20'h3_B600}
`define ROLLER_2151_REG_BIAS        {20'h3_B800}
`define ROLLER_2136_REG_BIAS        {20'h3_BA00}
`define ROLLER_2036_REG_BIAS        {20'h3_BC00}
`define ROLLER_2086_REG_BIAS        {20'h3_BE00}
`define ROLLER_3025_REG_BIAS        {20'h3_C000}
`define ROLLER_3186_REG_BIAS        {20'h3_C200}
`define ROLLER_2141_REG_BIAS        {20'h3_C400}
`define ROLLER_3040_REG_BIAS        {20'h3_C600}
`define ROLLER_3026_REG_BIAS        {20'h3_C800}
`define ROLLER_3209_REG_BIAS        {20'h3_CA00}
`define ROLLER_3126_REG_BIAS        {20'h3_CC00}
`define ROLLER_2076_REG_BIAS        {20'h3_CE00}
`define ROLLER_2080_REG_BIAS        {20'h3_D000}
`define ROLLER_3007_REG_BIAS        {20'h3_D200}
`define ROLLER_3089_REG_BIAS        {20'h3_D400}
`define ROLLER_3214_REG_BIAS        {20'h3_D600}
`define ROLLER_1048_REG_BIAS        {20'h3_D800}
`define ROLLER_1003_REG_BIAS        {20'h3_DA00}
`define ROLLER_3221_REG_BIAS        {20'h3_DC00}
`define ROLLER_3217_REG_BIAS        {20'h3_DE00}
`define ROLLER_3219_REG_BIAS        {20'h3_E000}
`define ROLLER_2168_REG_BIAS        {20'h3_E200}
`define ROLLER_2167_REG_BIAS        {20'h3_E400}
`define ROLLER_2165_REG_BIAS        {20'h3_E600}
`define ROLLER_2166_REG_BIAS        {20'h3_E800}
`define ROLLER_2006_REG_BIAS        {20'h3_EA00}
`define ROLLER_1100_REG_BIAS        {20'h3_EC00}
`define ROLLER_1102_REG_BIAS        {20'h3_EE00}



