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
// Dependencies:寄存器地址表
//
//
// Revision:      
/////////////////////////////////////////////////////////////////

//基础参数 PS-PL
//`define		SC_ID			9'd4
//`define		EC_ID           9'd8
//`define		RST_EN          9'd12
`define		UNIT_ID	        9'd0
`define		UNIT_ECTRL      9'd0
`define		UNIT_ST         9'd0
`define		M_ID	        9'd0
`define		M_ECTRL         9'd0
`define		M_ST            9'd0
`define		M_WK_MOD        9'd0
`define		M_SAF_ST        9'd0
`define		LINK_M_SAF_ST   9'd0
//`define		A_BHV_ID        9'd64
`define		A_BHV_EN        9'd10
`define		A_TASK_ID       9'd11
//`define		A_TX_OT         9'd84
//`define		A_TX_RSULT_RPT  9'd92
//`define		B_TX_OT         9'd112
//`define		B_TX_RSULT_RPT  9'd116
//`define		C_TX_OT         9'd136
//`define		C_GAP_CRL       9'd140
//`define		C_TX_RSULT_RPT  9'd148

//基础参数 PL-PS	
//`define		EC_CHA_ST		9'd52
//`define		EC_CHB_ST       9'd56
//`define		EC_CHC_ST       9'd60
`define		A_BHV_TYP       9'd12
`define		A_BHV_ST        9'd13
//`define		A_TX_ID         9'd88
//`define		A_ALM_NUM       9'd96
//`define		B_BHV_ID        9'd100
`define		B_BHV_TYP       9'd14
`define		B_BHV_ST        9'd15
//`define		B_TX_ID         9'd208
//`define		B_ALM_NUM       9'd120
//`define		C_BHV_ID        9'd124
`define		C_BHV_TYP       9'd17
`define		C_BHV_ST        9'd18
//`define		C_TX_ID			9'd144
//`define		C_ALM_NUM       9'd152

//动态参数 PS-PL
//`define		PARAM1			9'd280
//`define		PARAM2			9'd284
`define		PARAM3			9'd19
`define     PARAM4			9'd20
`define     PARAM5			9'd21
`define     PARAM6			9'd22
`define     PARAM7			9'd23
`define     PARAM8			9'd24
`define     PARAM9			9'd25
`define     PARAM10			9'd26
`define     PARAM11			9'd27
`define     PARAM12			9'd28
`define     PARAM13			9'd29
`define     PARAM14			9'd30
`define     PARAM15			9'd31
`define     PARAM16			9'd40
`define     PARAM17			9'd33
`define     PARAM18			9'd34
`define     PARAM19			9'd35
`define     PARAM20			9'd36
`define     PARAM21			9'd37
`define     PARAM22			9'd39
`define     PARAM23			9'd38
`define     PARAM24			9'd41
`define     PARAM25			9'd42
`define     PARAM26			9'd43
`define     PARAM27			9'd44
`define     PARAM28			9'd45
`define     PARAM29			9'd46
`define     PARAM30			9'd48

//动态参数 PL-PS
//`define		PARAM50			9'd400
//`define		PARAM51         9'd404
`define		PARAM52         9'd0
`define		PARAM53         9'd0
`define		PARAM54         9'd0
`define		PARAM55         9'd0
`define		PARAM56         9'd0
`define		PARAM57         9'd0
`define		PARAM58         9'd0
`define		PARAM59         9'd0
`define		PARAM60         9'd0
`define		PARAM61         9'd0
`define		PARAM62         9'd0
`define		PARAM63         9'd0
`define		PARAM64         9'd0
`define		PARAM65         9'd0
`define		PARAM66         9'd0
`define		PARAM67         9'd0
`define		PARAM68         9'd0
`define		PARAM69         9'd0
`define		PARAM70         9'd0
`define		PARAM71         9'd0
`define		PARAM72         9'd0
`define		PARAM73         9'd0
`define		PARAM74         9'd0
`define		PARAM75         9'd0
`define		PARAM76         9'd0
`define		PARAM77         9'd0

`define		BHV_NUM         9'd0

`define		RINTR_STATUS1   9'd0
`define		RINTR_STATUS2   9'd0
//`define		B_EN		    9'd164
//`define		C_EN		    9'd168
//`define		IRQ_REG1		9'd172
//`define		IRQ_REG2		9'd176



`define		SC_ID			{5'h01,4'h0}
`define		EC_ID			{5'h02,4'h0}
`define		RST_EN			{5'h03,4'h0}
`define		A_BHV_ID		{5'h04,4'h0}
`define		A_TX_OT			{5'h05,4'h0}
`define		A_TX_RSULT_RPT	{5'h06,4'h0}
`define		B_TX_OT			{5'h07,4'h0}
`define		B_TX_RSULT_RPT	{5'h08,4'h0}
`define		B_EN			{5'h09,4'h0}
`define		C_GAP_CRL		{5'h0a,4'h0}
`define		C_TX_OT			{5'h0b,4'h0}
`define		C_TX_RSULT_RPT	{5'h0c,4'h0}
`define		C_EN			{5'h0d,4'h0}
`define		PARAM1			{5'h0e,4'h0}
`define		PARAM2			{5'h0f,4'h0}

`define 	EC_CHA_ST 		{5'h10,4'h0}
`define 	A_TX_ID   	    {5'h11,4'h0}
`define 	A_ALM_NUM 	    {5'h12,4'h0}
`define 	EC_CHB_ST       {5'h13,4'h0}
`define 	B_BHV_ID        {5'h14,4'h0}
`define 	B_TX_ID         {5'h15,4'h0}
`define 	B_ALM_NUM       {5'h16,4'h0}
`define 	EC_CHC_ST       {5'h17,4'h0}
`define 	C_BHV_ID 	    {5'h18,4'h0}
`define 	C_TX_ID	        {5'h19,4'h0}
`define 	C_ALM_NUM       {5'h1a,4'h0}
`define 	PARAM50         {5'h1b,4'h0}
`define 	PARAM51         {5'h1c,4'h0}
`define 	IRQ_REG1        {5'h1d,4'h0}
`define 	IRQ_REG2        {5'h1e,4'h0}

//, , , , , , 180, 184, 188, 192, 196, 200, 204,
//212, 216, 220, 224, 228, 232, 236, 240, 244, 248, 252, 256, 260, 264, 268, 272, 276,
//512
