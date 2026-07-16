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


`define		IRQ_REG1			10'd0
`define		IRQ_REG2			10'd4
`define		RST_EN          	10'd8
`define		EC_ID           	10'd12
`define		SC_ID				10'd16
`define		BHV_PRIORITY		10'd20
`define		UNIT_ID	        	10'd24
`define		UNIT_ECTRL      	10'd28
`define		UNIT_ST         	10'd32
`define		M_ID	        	10'd36
`define		M_ECTRL         	10'd40
`define		M_ST            	10'd44
`define		M_WK_MOD        	10'd48
`define		BHV_EN          	10'd52
`define		M_SAF_ST        	10'd56
`define		LINK_M_SAF_ST   	10'd60
`define		A_TASK_ID       	10'd124
`define		A_TASK_BHV_ID   	10'd128
`define		A_EN            	10'd132
`define		EC_CHA_ST			10'd136
`define		A_TX_OT         	10'd140
`define		A_TX_RSULT_RPT  	10'd144
`define		A_ALM_NUM       	10'd148
`define		A_TX_ID         	10'd152
`define		A_BHV_ID        	10'd156
`define		B_EN            	10'd204
`define		EC_CHB_ST       	10'd208
`define		B_TX_OT         	10'd212
`define		B_TX_RSULT_RPT  	10'd216
`define		B_ALM_NUM       	10'd220
`define		B_TX_ID         	10'd224
`define		B_BHV_ID        	10'd228
`define		C_EN            	10'd284
`define		EC_CHC_ST       	10'd288
`define		C_TX_OT         	10'd292
`define		C_TX_RSULT_RPT  	10'd296
`define		C_ALM_NUM       	10'd300
`define		C_TX_ID				10'd304
`define		C_BHV_ID        	10'd308
`define		C_GAP_CRL       	10'd312
`define		PARAM1				10'd364
`define		PARAM2				10'd368
`define		PARAM3				10'd372
`define     PARAM4				10'd376
`define     PARAM5				10'd380
`define     PARAM6				10'd384
`define     PARAM7				10'd388
`define     PARAM8				10'd392
`define     PARAM9				10'd396
`define     PARAM10				10'd400
`define     PARAM11				10'd404
`define     PARAM12				10'd408
`define     PARAM13				10'd412
`define     PARAM14				10'd416
`define     PARAM15				10'd420
`define     PARAM16				10'd424
`define     PARAM17				10'd428
`define     PARAM18				10'd432
`define     PARAM19				10'd436
`define     PARAM20				10'd440
`define     PARAM21				10'd444
`define     PARAM22				10'd448
`define     PARAM23				10'd452
`define     PARAM24				10'd456
`define     PARAM25				10'd460
`define     PARAM26				10'd464
`define     PARAM27				10'd468
`define     PARAM28				10'd472
`define     PARAM29				10'd476
`define     PARAM30				10'd480
`define		PARAM51				10'd564
`define		PARAM52         	10'd568
`define		PARAM53         	10'd572
`define		PARAM54         	10'd576
`define		PARAM55         	10'd580
`define		PARAM56         	10'd584
`define		PARAM57         	10'd588
`define		PARAM58         	10'd592
`define		PARAM59         	10'd596
`define		PARAM60         	10'd600
`define		PARAM61         	10'd604
`define		PARAM62         	10'd608
`define		PARAM63         	10'd612
`define		PARAM64         	10'd616
`define		PARAM65         	10'd620
`define		PARAM66         	10'd624
`define		PARAM67         	10'd628
`define		PARAM68         	10'd632
`define		PARAM69         	10'd636
`define		PARAM70         	10'd640




























































































