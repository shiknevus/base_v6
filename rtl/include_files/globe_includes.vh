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
//          选择机型，起效的define对应相应的机型               //
/////////////////////////////////////////////////////////////////

//////////////////////////////`define SIM_SLVSTA_ONLY
`define SIM_SLV_STA_NUM     3
//////////////////////////////
//length unit : 1B(8bit)
`define ETHCAT_HEAD_LEN 4
`define DATAGRAM_HEAD_LEN 12
`define DATAGRAM_WKC_LEN 4

`define ETHCAT_TYPE_HEARTBEAT    8
`define ETHCAT_TYPE_INITIAL      10
`define ETHCAT_TYPE_DATAGRAM     13

//ethcat operation command
`define ETHCAT_CMD_APRW     8'h3    //主站使用顺序寻址与从站交互数据
`define ETHCAT_CMD_FPRW     8'h6    //主站使用设置寻址与从站交互数据

//ethcat frame process result
`define ETHCAT_PRCS_CRC_FAIL    1
`define ETHCAT_PRCS_SUCCESS     2
`define ETHCAT_PRCS_WKC_ERR     3

//`define ETHCAT_INIT_DG_LEN      8   //ethcat initial datagram package length  unit:1BYTE
`define ETHCAT_INIT_DG_LEN      12   //ethcat initial datagram package length  unit:1BYTE
`define DEFAULT_SUPPORT_SLV_NUM 32  //the number ofdefault support slave station is 30

`define ETHCAT_HB_DG_LEN      8   //ethcat initial datagram package length  unit:1BYTE
`define AIDEN_FIX
