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
//      THESE DEFINE IS ONLY  USED BY MASTER DEPOT             //
/////////////////////////////////////////////////////////////////

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
`define DEPOT_BIAS_RS232_CH0    (`DEPOT_BIAS_AI + `DEPOT_SIZE_AI)
`define DEPOT_SIZE_RS232_CH0    16
`define DEPOT_BIAS_RS232_CH1    (`DEPOT_BIAS_RS232_CH0 + `DEPOT_SIZE_RS232_CH0)
`define DEPOT_SIZE_RS232_CH1    16
`define DEPOT_BIAS_RS232_CH2    (`DEPOT_BIAS_RS232_CH1 + `DEPOT_SIZE_RS232_CH1)
`define DEPOT_SIZE_RS232_CH2    16
`define DEPOT_BIAS_RS232_CH3    (`DEPOT_BIAS_RS232_CH2 + `DEPOT_SIZE_RS232_CH2)
`define DEPOT_SIZE_RS232_CH3    16
`define DEPOT_BIAS_RS232_CH4    (`DEPOT_BIAS_RS232_CH3 + `DEPOT_SIZE_RS232_CH3)
`define DEPOT_SIZE_RS232_CH4    16
`define DEPOT_BIAS_RS232_CH5    (`DEPOT_BIAS_RS232_CH4 + `DEPOT_SIZE_RS232_CH4)
`define DEPOT_SIZE_RS232_CH5    16
`define DEPOT_BIAS_RS232_CH6    (`DEPOT_BIAS_RS232_CH5 + `DEPOT_SIZE_RS232_CH5)
`define DEPOT_SIZE_RS232_CH6    16
`define DEPOT_BIAS_RS232_CH7    (`DEPOT_BIAS_RS232_CH6 + `DEPOT_SIZE_RS232_CH6)
`define DEPOT_SIZE_RS232_CH7    16
`define DEPOT_BIAS_RS485_CH8    (`DEPOT_BIAS_RS232_CH7 + `DEPOT_SIZE_RS232_CH7)
`define DEPOT_SIZE_RS485_CH8    16
`define DEPOT_BIAS_PUL_MOTOR0   (`DEPOT_BIAS_RS485_CH8 + `DEPOT_SIZE_RS485_CH8)
`define DEPOT_SIZE_PUL_MOTOR0   16
`define DEPOT_BIAS_PUL_MOTOR1   (`DEPOT_BIAS_PUL_MOTOR0 + `DEPOT_SIZE_PUL_MOTOR0)
`define DEPOT_SIZE_PUL_MOTOR1   16
`define DEPOT_BIAS_PUL_MOTOR2   (`DEPOT_BIAS_PUL_MOTOR1 + `DEPOT_SIZE_PUL_MOTOR1)
`define DEPOT_SIZE_PUL_MOTOR2   16
`define DEPOT_BIAS_PUL_MOTOR3   (`DEPOT_BIAS_PUL_MOTOR2 + `DEPOT_SIZE_PUL_MOTOR2)
`define DEPOT_SIZE_PUL_MOTOR3   16


`define DEPOT_ACTIVE_BYTE_NUM   (`DEPOT_SIZE_ID + `DEPOT_SIZE_DO + `DEPOT_SIZE_DI  + `DEPOT_SIZE_AI +  + (`DEPOT_SIZE_RS232_CH0 * 9) + (`DEPOT_SIZE_PUL_MOTOR0 * 4))*4
