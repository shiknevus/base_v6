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

//the total number of send and receive bytes is 2920 bytes.
//so the number of bytes received or sent is 2920/2 = 1460 bytes.
//so the depth of the buffer received or sent is 512 , and data width is 32; total byter is 512*4 = 2048.
//////`define EACH_CHILD_DEPOT_SIZE   512     //unit:4byte.  total 4096 bytes //each size of send or receive buffer

`define DEPOT_BIAS_ID           0
`define DEPOT_SIZE_ID           1
`define DEPOT_BIAS_DO           (`DEPOT_BIAS_ID + `DEPOT_SIZE_ID)
`define DEPOT_SIZE_DO           2
`define DEPOT_BIAS_DI           (`DEPOT_BIAS_DO + `DEPOT_SIZE_DO)
`define DEPOT_SIZE_DI           3
`define DEPOT_BIAS_AO           (`DEPOT_BIAS_DI + `DEPOT_SIZE_DI)
`define DEPOT_SIZE_AO           4
`define DEPOT_BIAS_AI           (`DEPOT_BIAS_AO + `DEPOT_SIZE_AO)
`define DEPOT_SIZE_AI           4

`define DEPOT_BIAS_AXIS_1ST     (`DEPOT_BIAS_AI + `DEPOT_SIZE_AI)
`define DEPOT_SIZE_AXIS_1ST     32
`define DEPOT_BIAS_AXIS_2ND     (`DEPOT_BIAS_AXIS_1ST + `DEPOT_SIZE_AXIS_1ST)
`define DEPOT_SIZE_AXIS_2ND     32
`define DEPOT_BIAS_AXIS_3RD     (`DEPOT_BIAS_AXIS_2ND + `DEPOT_SIZE_AXIS_2ND)
`define DEPOT_SIZE_AXIS_3RD     32
`define DEPOT_BIAS_AXIS_4TH     (`DEPOT_BIAS_AXIS_3RD + `DEPOT_SIZE_AXIS_3RD)
`define DEPOT_SIZE_AXIS_4TH     32

`define DEPOT_BIAS_RS232_1ST    (`DEPOT_BIAS_AXIS_4TH + `DEPOT_SIZE_AXIS_4TH)
`define DEPOT_SIZE_RS232_1ST    32
`define DEPOT_BIAS_RS232_2ND    (`DEPOT_BIAS_RS232_1ST + `DEPOT_SIZE_RS232_1ST)
`define DEPOT_SIZE_RS232_2ND    32
`define DEPOT_BIAS_RS232_3RD    (`DEPOT_BIAS_RS232_2ND + `DEPOT_SIZE_RS232_2ND)
`define DEPOT_SIZE_RS232_3RD    32
`define DEPOT_BIAS_RS232_4TH    (`DEPOT_BIAS_RS232_3RD + `DEPOT_SIZE_RS232_3RD)
`define DEPOT_SIZE_RS232_4TH    32
`define DEPOT_BIAS_RS232_5TH    (`DEPOT_BIAS_RS232_4TH + `DEPOT_SIZE_RS232_4TH)
`define DEPOT_SIZE_RS232_5TH    32
`define DEPOT_BIAS_RS232_6TH    (`DEPOT_BIAS_RS232_5TH + `DEPOT_SIZE_RS232_5TH)
`define DEPOT_SIZE_RS232_6TH    32
`define DEPOT_BIAS_RS232_7TH    (`DEPOT_BIAS_RS232_5TH + `DEPOT_SIZE_RS232_5TH)
`define DEPOT_SIZE_RS232_7TH    32
`define DEPOT_BIAS_RS232_8TH    (`DEPOT_BIAS_RS232_7TH + `DEPOT_SIZE_RS232_7TH)
`define DEPOT_SIZE_RS232_8TH    32

`define DEPOT_BIAS_RS485_1ST    (`DEPOT_BIAS_RS232_7TH + `DEPOT_SIZE_RS232_7TH)
`define DEPOT_SIZE_RS485_1ST    32



/*
`define DEPOT_BIAS_SEND_1ST     0       //mapping to protocol local logic ram bus
`define DEPOT_BIAS_RCV_1ST      256
`define DEPOT_BIAS_SEND_2ND     `DEPOT_BIAS_SEND_1ST + (`EACH_CHILD_DEPOT_SIZE*2)*1       //mapping to protocol local logic ram bus
`define DEPOT_BIAS_RCV_2ND      `DEPOT_BIAS_RCV_2ND  + (`EACH_CHILD_DEPOT_SIZE*2)*1
`define DEPOT_BIAS_SEND_3RD     `DEPOT_BIAS_SEND_1ST + (`EACH_CHILD_DEPOT_SIZE*2)*2       //mapping to protocol local logic ram bus
`define DEPOT_BIAS_RCV_3RD      `DEPOT_BIAS_RCV_2ND  + (`EACH_CHILD_DEPOT_SIZE*2)*2
`define DEPOT_BIAS_SEND_4TH     `DEPOT_BIAS_SEND_1ST + (`EACH_CHILD_DEPOT_SIZE*2)*3       //mapping to protocol local logic ram bus
`define DEPOT_BIAS_RCV_4TH      `DEPOT_BIAS_RCV_2ND  + (`EACH_CHILD_DEPOT_SIZE*2)*3
`define DEPOT_BIAS_SEND_5TH     `DEPOT_BIAS_SEND_1ST + (`EACH_CHILD_DEPOT_SIZE*2)*4       //mapping to protocol local logic ram bus
`define DEPOT_BIAS_RCV_5TH      `DEPOT_BIAS_RCV_2ND  + (`EACH_CHILD_DEPOT_SIZE*2)*4
`define DEPOT_BIAS_SEND_6TH     `DEPOT_BIAS_SEND_1ST + (`EACH_CHILD_DEPOT_SIZE*2)*5       //mapping to protocol local logic ram bus
`define DEPOT_BIAS_RCV_6TH      `DEPOT_BIAS_RCV_2ND  + (`EACH_CHILD_DEPOT_SIZE*2)*5
*/
