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
//          ѡ����ͣ���Ч��define��Ӧ��Ӧ�Ļ���               //
/////////////////////////////////////////////////////////////////
// SLAVE station config. MASTER mirror: ../globe_includes.vh
// (values differ on purpose: ETHCAT_INIT_DG_LEN / DEFAULT_SUPPORT_SLV_NUM)
`ifndef GLOBAL_INCLUDES_SLV_VH
`define GLOBAL_INCLUDES_SLV_VH

//TEST DEFINE
`define LOOPBACK_MODE   0
`define TESE_HEARTBEAT_MODE  0

`define TEST_SLV_NUM        4

//length unit : 1B(8bit)
`define ETHCAT_HEAD_LEN 4
`define DATAGRAM_HEAD_LEN 12
`define DATAGRAM_WKC_LEN 4

`define ETHCAT_TYPE_HEARTBEAT    8
`define ETHCAT_TYPE_INITIAL      10
`define ETHCAT_TYPE_DATAGRAM     13

//ethcat operation command
`define ETHCAT_CMD_APRW     8'h3    
`define ETHCAT_CMD_FPRW     8'h6    

//ethcat frame process result
`define ETHCAT_PRCS_CRC_FAIL    1
`define ETHCAT_PRCS_SUCCESS     2
`define ETHCAT_PRCS_WKC_ERR     3

`define ETHCAT_INIT_DG_LEN      8   //ethcat initial datagram package length  unit:1BYTE
`define DEFAULT_SUPPORT_SLV_NUM 30  //the number ofdefault support slave station is 30

`define ETHCAT_HB_DG_LEN      8   //ethcat initial datagram package length  unit:1BYTE

`endif //GLOBAL_INCLUDES_SLV_VH
