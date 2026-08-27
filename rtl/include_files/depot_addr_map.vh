/////////////////////////////////////////////////////////////////
// Company:       
// Engineer:      
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//
//
// Revision:      
/////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////
//      SINGLE depot address map for master & slave (merged 20260826,   //
/////////////////////////////////////////////////////////////////
`ifndef DEPOT_ADDR_MAP_VH
`define DEPOT_ADDR_MAP_VH
//`define RS232_NUM 7
`define CHILD_DEPOT_NUM         5       //this value corresponds to the number of slave station
//so the number of bytes received or sent is 1460 bytes.
//so the depth of the buffer received or sent is 512 , and data width is 32; total byter is 512*4 = 2048.
`define EACH_CHILD_DEPOT_SIZE   512     //unit:4byte.  total 2048 bytes //each size of send or receive buffer
`define DEPOT_BIAS_ID           0
`define DEPOT_SIZE_ID           1
`define DEPOT_BIAS_DO           (`DEPOT_BIAS_ID + `DEPOT_SIZE_ID)
`define DEPOT_SIZE_DO           2
`define DEPOT_BIAS_DI           (`DEPOT_BIAS_DO + `DEPOT_SIZE_DO)
`define DEPOT_SIZE_DI           3
`define DEPOT_BIAS_AI           (`DEPOT_BIAS_DI + `DEPOT_SIZE_DI)
`define DEPOT_SIZE_AI           4
`define DEPOT_BIAS_RS232_1ST    (`DEPOT_BIAS_AI + `DEPOT_SIZE_AI)
`define DEPOT_SIZE_RS232_1ST    16
`define DEPOT_BIAS_RS232_2ND    (`DEPOT_BIAS_RS232_1ST + `DEPOT_SIZE_RS232_1ST)
`define DEPOT_SIZE_RS232_2ND    16
`define DEPOT_BIAS_RS232_3RD    (`DEPOT_BIAS_RS232_2ND + `DEPOT_SIZE_RS232_2ND)
`define DEPOT_SIZE_RS232_3RD    16
`define DEPOT_BIAS_RS232_4TH    (`DEPOT_BIAS_RS232_3RD + `DEPOT_SIZE_RS232_3RD)
`define DEPOT_SIZE_RS232_4TH    16
`define DEPOT_BIAS_RS232_5TH    (`DEPOT_BIAS_RS232_4TH + `DEPOT_SIZE_RS232_4TH)
`define DEPOT_SIZE_RS232_5TH    16
`define DEPOT_BIAS_RS232_6TH    (`DEPOT_BIAS_RS232_5TH + `DEPOT_SIZE_RS232_5TH)
`define DEPOT_SIZE_RS232_6TH    16
`define DEPOT_BIAS_RS232_7TH    (`DEPOT_BIAS_RS232_6TH + `DEPOT_SIZE_RS232_6TH)
`define DEPOT_SIZE_RS232_7TH    16
`define DEPOT_BIAS_RS232_8TH    (`DEPOT_BIAS_RS232_7TH + `DEPOT_SIZE_RS232_7TH)
`define DEPOT_SIZE_RS232_8TH    16
`define DEPOT_BIAS_RS485_1ST    (`DEPOT_BIAS_RS232_8TH + `DEPOT_SIZE_RS232_8TH)
`define DEPOT_SIZE_RS485_1ST    16

`define DEPOT_BIAS_PUL_MOTOR0   (`DEPOT_BIAS_RS485_1ST + `DEPOT_SIZE_RS485_1ST)
`define DEPOT_SIZE_PUL_MOTOR0   16
`define DEPOT_BIAS_PUL_MOTOR1   (`DEPOT_BIAS_PUL_MOTOR0 + `DEPOT_SIZE_PUL_MOTOR0)
`define DEPOT_SIZE_PUL_MOTOR1   16
`define DEPOT_BIAS_PUL_MOTOR2   (`DEPOT_BIAS_PUL_MOTOR1 + `DEPOT_SIZE_PUL_MOTOR1)
`define DEPOT_SIZE_PUL_MOTOR2   16
`define DEPOT_BIAS_PUL_MOTOR3   (`DEPOT_BIAS_PUL_MOTOR2 + `DEPOT_SIZE_PUL_MOTOR2)
`define DEPOT_SIZE_PUL_MOTOR3   16

//`define DEPOT_BIAS_RESEVE_DATA_1ST    (`DEPOT_BIAS_RS232_8TH + `DEPOT_SIZE_RS232_8TH)
//`define DEPOT_SIZE_RESEVE_DATA_1ST   32

//`define DEPOT_SIZE_RSV          32

//`define DEPOT_ACTIVE_BYTE_NUM   (`DEPOT_SIZE_ID + `DEPOT_SIZE_DO + `DEPOT_SIZE_DI  + `DEPOT_SIZE_AI +  + (`DEPOT_SIZE_RS232_1ST * 8) + `DEPOT_SIZE_RSV)*4

`define DEPOT_ACTIVE_BYTE_NUM   (`DEPOT_SIZE_ID + `DEPOT_SIZE_DO + `DEPOT_SIZE_DI  + `DEPOT_SIZE_AI + (`DEPOT_SIZE_RS232_1ST * 9) + (`DEPOT_SIZE_PUL_MOTOR0 * 4))*4

`endif //DEPOT_ADDR_MAP_VH


