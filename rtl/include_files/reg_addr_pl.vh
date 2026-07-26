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


`define		IRQ_REG1			10'h0
`define		IRQ_REG2			10'h4
`define		RST_EN          	10'h8
`define		EC_ID           	10'hc
`define		SC_ID				10'h10
`define		BHV_PRIORITY		10'h14
`define		UNIT_ID	        	10'h18
`define		UNIT_ECTRL      	10'h1c
`define		UNIT_ST         	10'h20
`define		M_ID	        	10'h24
`define		M_ECTRL         	10'h28
`define		M_ST            	10'h2c
`define		M_WK_MOD        	10'h30
`define		BHV_EN          	10'h34
`define		M_SAF_ST        	10'h38
`define		LINK_M_SAF_ST   	10'h3c
`define		A_TASK_ID       	10'h7c
`define		A_TASK_BHV_ID   	10'h80
`define		A_EN            	10'h84
`define		EC_CHA_ST			10'h88
`define		A_TX_OT         	10'h8c
`define		A_TX_RSULT_RPT  	10'h90
`define		A_ALM_NUM       	10'h94
`define		A_TX_ID         	10'h98
`define		A_BHV_ID        	10'h9c
`define		B_EN            	10'hcc
`define		EC_CHB_ST       	10'hd0
`define		B_TX_OT         	10'hd4
`define		B_TX_RSULT_RPT  	10'hd8
`define		B_ALM_NUM       	10'hdc
`define		B_TX_ID         	10'he0
`define		B_BHV_ID        	10'he4
`define		C_EN            	10'h11c
`define		EC_CHC_ST       	10'h120
`define		C_TX_OT         	10'h124
`define		C_TX_RSULT_RPT  	10'h128
`define		C_ALM_NUM       	10'h12c
`define		C_TX_ID				10'h130
`define		C_BHV_ID        	10'h134
`define		C_GAP_CRL       	10'h138
`define		PARAM1				10'h16c
`define		PARAM2				10'h170
`define		PARAM3				10'h174
`define     PARAM4				10'h178
`define     PARAM5				10'h17c
`define     PARAM6				10'h180
`define     PARAM7				10'h184
`define     PARAM8				10'h188
`define     PARAM9				10'h18c
`define     PARAM10				10'h190
`define     PARAM11				10'h194
`define     PARAM12				10'h198
`define     PARAM13				10'h19c
`define     PARAM14				10'h1a0
`define     PARAM15				10'h1a4
`define     PARAM16				10'h1a8
`define     PARAM17				10'h1ac
`define     PARAM18				10'h1b0
`define     PARAM19				10'h1b4
`define     PARAM20				10'h1b8
`define     PARAM21				10'h1bc
`define     PARAM22				10'h1c0
`define     PARAM23				10'h1c4
`define     PARAM24				10'h1c8
`define     PARAM25				10'h1cc
`define     PARAM26				10'h1d0
`define     PARAM27				10'h1d4
`define     PARAM28				10'h1d8
`define     PARAM29				10'h1dc
`define     PARAM30				10'h1e0
`define		PARAM51				10'h234
`define		PARAM52         	10'h238
`define		PARAM53         	10'h23c
`define		PARAM54         	10'h240
`define		PARAM55         	10'h244
`define		PARAM56         	10'h248
`define		PARAM57         	10'h24c
`define		PARAM58         	10'h250
`define		PARAM59         	10'h254
`define		PARAM60         	10'h258
`define		PARAM61         	10'h25c
`define		PARAM62         	10'h260
`define		PARAM63         	10'h264
`define		PARAM64         	10'h268
`define		PARAM65         	10'h26c
`define		PARAM66         	10'h270
`define		PARAM67         	10'h274
`define		PARAM68         	10'h278
`define		PARAM69         	10'h27c
`define		PARAM70         	10'h280




























































































