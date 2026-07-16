/////////////////////////////////////////////////////////////////
// Company:       
// Engineer:      	cgliu
// Creat Date:		2026/6/22    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//
//Register address table
// Revision:      
/////////////////////////////////////////////////////////////////
//AXI BASE ADDR B010_0000
//Each component can have up to 256 register addresses, and a project can instantiate up to 1024 components.


//Interrupt Request Register + Basic parameters(30)
`define		IRQ_REG1		4*0
`define		IRQ_REG2		4*1
`define		RST_EN          4*2
`define		EC_ID           4*3
`define		SC_ID			4*4
`define		BHV_PRIORITY	4*5
`define		UNIT_ID	        4*6
`define		UNIT_ECTRL      4*7
`define		UNIT_ST         4*8
`define		M_ID	        4*9
`define		M_ECTRL         4*10
`define		M_ST            4*11
`define		M_WK_MOD        4*12
`define		BHV_EN          4*13
`define		M_SAF_ST        4*14
`define		LINK_M_SAF_ST   4*15

//Channel A Register(20)
`define		A_TASK_ID       4*31
`define		A_TASK_BHV_ID   4*32
`define		A_EN            4*33
`define		EC_CHA_ST		4*34
`define		A_TX_OT         4*35
`define		A_TX_RSULT_RPT  4*36
`define		A_ALM_NUM       4*37
`define		A_TX_ID         4*38
`define		A_BHV_ID        4*39

//Channel B Register(20)
`define		B_EN            4*51
`define		EC_CHB_ST       4*52
`define		B_TX_OT         4*53
`define		B_TX_RSULT_RPT  4*54
`define		B_ALM_NUM       4*55
`define		B_TX_ID         4*56
`define		B_BHV_ID        4*57

//Channel C Register(20)
`define		C_EN            4*71
`define		EC_CHC_ST       4*72
`define		C_TX_OT         4*73
`define		C_TX_RSULT_RPT  4*74
`define		C_ALM_NUM       4*75
`define		C_TX_ID			4*76
`define		C_BHV_ID        4*77
`define		C_GAP_CRL       4*78

//PS-PL parameters(40)
`define		PARAM1			4*91
`define		PARAM2			4*92
`define		PARAM3			4*93
`define     PARAM4			4*94
`define     PARAM5			4*95
`define     PARAM6			4*96
`define     PARAM7			4*97
`define     PARAM8			4*98
`define     PARAM9			4*99
`define     PARAM10			4*100
`define     PARAM11			4*101
`define     PARAM12			4*102
`define     PARAM13			4*103
`define     PARAM14			4*104
`define     PARAM15			4*105
`define     PARAM16			4*106
`define     PARAM17			4*107
`define     PARAM18			4*108
`define     PARAM19			4*109
`define     PARAM20			4*110
`define     PARAM21			4*111
`define     PARAM22			4*112
`define     PARAM23			4*113
`define     PARAM24			4*114
`define     PARAM25			4*115
`define     PARAM26			4*116
`define     PARAM27			4*117
`define     PARAM28			4*118
`define     PARAM29			4*119
`define     PARAM30			4*120

//PS-PL parameters(40)
`define		PARAM50			4*141
`define		PARAM51         4*142
`define		PARAM52         4*143
`define		PARAM53         4*144
`define		PARAM54         4*145
`define		PARAM55         4*146
`define		PARAM56         4*147
`define		PARAM57         4*148
`define		PARAM58         4*149
`define		PARAM59         4*150
`define		PARAM60         4*151
`define		PARAM61         4*152
`define		PARAM62         4*153
`define		PARAM63         4*154
`define		PARAM64         4*155
`define		PARAM65         4*156
`define		PARAM66         4*157
`define		PARAM67         4*158
`define		PARAM68         4*159
`define		PARAM69         4*160
`define		PARAM70         4*161


