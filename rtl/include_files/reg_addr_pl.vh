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


<<<<<<< HEAD
`define		IRQ_REG1			9'h000  //0
`define		IRQ_REG2			9'h004  //4
`define		RST_EN          	9'h008  //8
`define		EC_ID           	9'h00C  //12
`define		SC_ID				9'h010  //16
`define		BHV_PRIORITY		9'h014  //20
`define		UNIT_ID	        	9'h018  //24
`define		UNIT_ECTRL      	9'h01C  //28
`define		UNIT_ST         	9'h020  //32
`define		M_ID	        	9'h024  //36
`define		M_ECTRL         	9'h028  //40
`define		M_ST            	9'h02C  //44
`define		M_WK_MOD        	9'h030  //48
`define		BHV_EN          	9'h034  //52
`define		M_SAF_ST        	9'h038  //56
`define		LINK_M_SAF_ST   	9'h03C  //60
`define		A_TASK_ID       	9'h054  //84
`define		A_TASK_BHV_ID   	9'h058  //88
`define		A_EN            	9'h05C  //92
`define		EC_CHA_ST			9'h060  //96
`define		A_TX_OT         	9'h064  //100
`define		A_TX_RSULT_RPT  	9'h068  //104
`define		A_ALM_NUM       	9'h06C  //108
`define		A_TX_ID         	9'h070  //112
`define		A_BHV_ID        	9'h074  //116
`define		B_EN            	9'h084  //132
`define		EC_CHB_ST       	9'h088  //136
`define		B_TX_OT         	9'h08C  //140
`define		B_TX_RSULT_RPT  	9'h090  //144
`define		B_ALM_NUM       	9'h094  //148
`define		B_TX_ID         	9'h098  //152
`define		B_BHV_ID        	9'h09C  //156
`define		C_EN            	9'h0AC  //172
`define		EC_CHC_ST       	9'h0B0  //176
`define		C_TX_OT         	9'h0B4  //180
`define		C_TX_RSULT_RPT  	9'h0B8  //184
`define		C_ALM_NUM       	9'h0BC  //188
`define		C_TX_ID				9'h0C0  //192
`define		C_BHV_ID        	9'h0C4  //196
`define		C_GAP_CRL       	9'h0C8  //200
`define		PARAM1				9'h0D8  //216
`define		PARAM2				9'h0DC  //220
`define		PARAM3				9'h0E0  //224
`define     PARAM4				9'h0E4  //228
`define     PARAM5				9'h0E8  //232
`define     PARAM6				9'h0EC  //236
`define     PARAM7				9'h0F0  //240
`define     PARAM8				9'h0F4  //244
`define     PARAM9				9'h0F8  //248
`define     PARAM10				9'h0FC  //252
`define     PARAM11				9'h100  //256
`define     PARAM12				9'h104  //260
`define     PARAM13				9'h108  //264
`define     PARAM14				9'h10C  //268
`define     PARAM15				9'h110  //272
`define     PARAM16				9'h114  //276
`define     PARAM17				9'h118  //280
`define     PARAM18				9'h11C  //284
`define     PARAM19				9'h120  //288
`define     PARAM20				9'h124  //292
`define     PARAM21				9'h128  //296
`define     PARAM22				9'h12C  //300
`define     PARAM23				9'h130  //304
`define     PARAM24				9'h134  //308
`define     PARAM25				9'h138  //312
`define     PARAM26				9'h13C  //316
`define     PARAM27				9'h140  //320
`define     PARAM28				9'h144  //324
`define     PARAM29				9'h148  //328
`define     PARAM30				9'h14C  //332

`define		PARAM31				9'h1A0  //416
`define		PARAM32				9'h1A4  //420
`define		PARAM33				9'h1A8  //424
`define     PARAM34				9'h1AC  //428
`define     PARAM35				9'h1B0  //432
`define     PARAM36				9'h1B4  //436
`define     PARAM37				9'h1B8  //440

`define		PARAM51				9'h150  //336
`define		PARAM52         	9'h154  //340
`define		PARAM53         	9'h158  //344
`define		PARAM54         	9'h15C  //348
`define		PARAM55         	9'h160  //352
`define		PARAM56         	9'h164  //356
`define		PARAM57         	9'h168  //360
`define		PARAM58         	9'h16C  //364
`define		PARAM59         	9'h170  //368
`define		PARAM60         	9'h174  //372
`define		PARAM61         	9'h178  //376
`define		PARAM62         	9'h17C  //380
`define		PARAM63         	9'h180  //384
`define		PARAM64         	9'h184  //388
`define		PARAM65         	9'h188  //392
`define		PARAM66         	9'h18C  //396
`define		PARAM67         	9'h190  //400
`define		PARAM68         	9'h194  //404
`define		PARAM69         	9'h198  //408
`define		PARAM70         	9'h19C  //412
`define		DEBUG_REG1         	9'h1EC  //492
`define		DEBUG_REG2         	9'h1F0  //496
`define		DEBUG_REG3         	9'h1F4  //500
`define		DEBUG_REG4         	9'h1F8  //504
`define		DEBUG_REG5         	9'h1FC  //508
=======
`define		IRQ_REG1			9'h000
`define		IRQ_REG2			9'h004
`define		RST_EN          	9'h008
`define		EC_ID           	9'h00C
`define		SC_ID				9'h010
`define		BHV_PRIORITY		9'h014
`define		UNIT_ID	        	9'h018
`define		UNIT_ECTRL      	9'h01C
`define		UNIT_ST         	9'h020
`define		M_ID	        	9'h024
`define		M_ECTRL         	9'h028
`define		M_ST            	9'h02C
`define		M_WK_MOD        	9'h030
`define		BHV_EN          	9'h034
`define		M_SAF_ST        	9'h038
`define		LINK_M_SAF_ST   	9'h03C
`define		A_TASK_ID       	9'h054
`define		A_TASK_BHV_ID   	9'h058
`define		A_EN            	9'h05C
`define		EC_CHA_ST			9'h060
`define		A_TX_OT         	9'h064
`define		A_TX_RSULT_RPT  	9'h068
`define		A_ALM_NUM       	9'h06C
`define		A_TX_ID         	9'h070
`define		A_BHV_ID        	9'h074
`define		B_EN            	9'h084
`define		EC_CHB_ST       	9'h088
`define		B_TX_OT         	9'h08C
`define		B_TX_RSULT_RPT  	9'h090
`define		B_ALM_NUM       	9'h094
`define		B_TX_ID         	9'h098
`define		B_BHV_ID        	9'h09C
`define		C_EN            	9'h0AC
`define		EC_CHC_ST       	9'h0B0
`define		C_TX_OT         	9'h0B4
`define		C_TX_RSULT_RPT  	9'h0B8
`define		C_ALM_NUM       	9'h0BC
`define		C_TX_ID				9'h0C0
`define		C_BHV_ID        	9'h0C4
`define		C_GAP_CRL       	9'h0C8

`define		PARAM1				9'h0D8
`define		PARAM2				9'h0DC
`define		PARAM3				9'h0E0
`define     PARAM4				9'h0E4
`define     PARAM5				9'h0E8
`define     PARAM6				9'h0EC
`define     PARAM7				9'h0F0
`define     PARAM8				9'h0F4
`define     PARAM9				9'h0F8
`define     PARAM10				9'h0FC
`define     PARAM11				9'h100
`define     PARAM12				9'h104
`define     PARAM13				9'h108
`define     PARAM14				9'h10C
`define     PARAM15				9'h110
`define     PARAM16				9'h114
`define     PARAM17				9'h118
`define     PARAM18				9'h11C
`define     PARAM19				9'h120
`define     PARAM20				9'h124
`define     PARAM21				9'h128
`define     PARAM22				9'h12C
`define     PARAM23				9'h130
`define     PARAM24				9'h134
`define     PARAM25				9'h138
`define     PARAM26				9'h13C
`define     PARAM27				9'h140
`define     PARAM28				9'h144
`define     PARAM29				9'h148
`define     PARAM30				9'h14C
`define     PARAM31				9'h150
`define     PARAM32				9'h154
`define     PARAM33				9'h158
`define     PARAM34				9'h15C
`define     PARAM35				9'h160
`define     PARAM36				9'h164
`define     PARAM37				9'h168
`define     PARAM38				9'h16C
`define     PARAM39				9'h170
`define     PARAM40				9'h174

`define		PARAM51				9'h178
`define		PARAM52         	9'h17C
`define		PARAM53         	9'h180
`define		PARAM54         	9'h184
`define		PARAM55         	9'h188
`define		PARAM56         	9'h18C
`define		PARAM57         	9'h190
`define		PARAM58         	9'h194
`define		PARAM59         	9'h198
`define		PARAM60         	9'h19C
`define		PARAM61         	9'h1A0
`define		PARAM62         	9'h1A4
`define		PARAM63         	9'h1A8
`define		PARAM64         	9'h1AC
`define		PARAM65         	9'h1B0
`define		PARAM66         	9'h1B4
`define		PARAM67         	9'h1B8
`define		PARAM68         	9'h1BC
`define		PARAM69         	9'h1C0
`define		PARAM70         	9'h1C4

`define		DEBUG_REG1         	9'h1EC
`define		DEBUG_REG2         	9'h1F0
`define		DEBUG_REG3         	9'h1F4
`define		DEBUG_REG4         	9'h1F8
`define		DEBUG_REG5         	9'h1FC
















































































>>>>>>> origin/cgliu

