////////////////////////////////////////////////////////////////////////////////
//

`timescale 1ns / 10ps
`define DLY #1

//***********************************Module Declaration*******************************
module tx_crc (
  DATA_DS,
  REM_DS,
  SOF_N_DS,
  EOF_N_DS,
  SRC_RDY_N_DS,
  
  DST_RDY_N_US,
  DATA_US,
  REM_US,
  SOF_N_US,
  EOF_N_US,
  SRC_RDY_N_US,
  DST_RDY_N_DS,
  RESET,
  CLK
);

parameter CRC_INIT  = 32'hFFFFFFFF;
 
output [31:0]     DATA_DS;
output [1:0]      REM_DS; 
  output      	  SOF_N_DS;
  output      	  EOF_N_DS;
  output      	  SRC_RDY_N_DS;
  input       	  DST_RDY_N_DS;
  output      	  DST_RDY_N_US;
input [31:0]     DATA_US;
input [1:0]      REM_US; 
  input           SOF_N_US;
  input           EOF_N_US;
  input           SRC_RDY_N_US;
  input       	  RESET;
  input       	  CLK;

 
reg [31:0]     DATA_DS;
reg [1:0]      REM_DS; 
  reg       	  SOF_N_DS;
  reg       	  EOF_N_DS;
  reg       	  SRC_RDY_N_DS;
 
  //__Signal declaration for one-hot encoded FSM__//
  reg   idle_r;
  reg   sc_frame_r;
  reg   sof_sc_r;
  reg   eof_sc_r;
  reg   wait_r;
  reg   sof_ds_r;
  reg   src_not_rdy_r;
  reg   data_r;
  reg   crc_r;
  reg   eof_ds_r;
 
  wire  idle_c;
  wire  sc_frame_c;
  wire  sof_sc_c;
  wire  eof_sc_c;
  wire  wait_c;
  wire  sof_ds_c;
  wire  src_not_rdy_c;
  wire  data_c;
  wire  crc_c;
  wire  eof_ds_c;
 
  //__internal register declaration__//
  reg     	  EOF_N_US_r;
reg [31:0]     DATA_US_r;
reg [31:0]     DATA_US_2r;
reg [1:0]      rem_in;
  reg [1:0]   count;
reg [31:0]     CRC_reg;
 
  //__internal wire declaration__//
  wire    	  ll_valid;
  wire    	  DST_RDY_N_US_i;
  wire [31:0] CRC1;      // CRC calculated for lane1
  wire    	  CRC_RESET;    //__reset to CRC block
  wire       CRC_DATAVALID1;      //__CRC datavalid for lane1
  wire [1:0] CRC_DATAWIDTH1;      //__CRC datawidth for lane1
  wire [31:0] CRC_DATA1;   //__data input to CRC block 1
  wire [31:0] final_CRC;

//____________Main code begins here________________//
 
    //__Initialization & state assignment for FSM__//
  always @(posedge CLK)
    if (RESET)
    begin
      idle_r      	<=  `DLY 1'b1;
      sc_frame_r  	<=  `DLY 1'b0;
      sof_sc_r    	<=  `DLY 1'b0;
      eof_sc_r    	<=  `DLY 1'b0;
      wait_r      	<=  `DLY 1'b0;
      sof_ds_r    	<=  `DLY 1'b0;
      src_not_rdy_r     <=  `DLY 1'b0;
      data_r      	<=  `DLY 1'b0;
      eof_ds_r    	<=  `DLY 1'b0;
      crc_r     	<=  `DLY 1'b0;
    end
    else if (!DST_RDY_N_DS)
    begin
      idle_r      	<=  `DLY idle_c;
      sc_frame_r        <=  `DLY sc_frame_c;
      sof_sc_r    	<=  `DLY sof_sc_c;
      eof_sc_r    	<=  `DLY eof_sc_c;
      wait_r      	<=  `DLY wait_c;
      sof_ds_r    	<=  `DLY sof_ds_c;
      src_not_rdy_r     <=  `DLY src_not_rdy_c;
      data_r      	<=  `DLY data_c;
      eof_ds_r    	<=  `DLY eof_ds_c;
      crc_r     	<=  `DLY crc_c;
    end
  //__Combinatorial logic for FSM__//
  assign  idle_c  = ((idle_r || eof_ds_r || eof_sc_r) &
								(SOF_N_US || !ll_valid));
           
  assign  sc_frame_c  = (idle_r || eof_ds_r || eof_sc_r) & !SOF_N_US &
									!EOF_N_US & ll_valid;
 
  assign  sof_sc_c  = sc_frame_r;
 
  assign  eof_sc_c    = sof_sc_r;
 
  assign  wait_c  = ((idle_r || eof_ds_r || eof_sc_r) & !SOF_N_US & EOF_N_US & ll_valid) || 
                    (wait_r & SRC_RDY_N_US);
 
  assign  sof_ds_c  = (wait_r & !SRC_RDY_N_US);
 
  assign  src_not_rdy_c = ((sof_ds_r || data_r) & SRC_RDY_N_US & EOF_N_US_r) ||
                (src_not_rdy_r & SRC_RDY_N_US);
 
  assign  data_c  = (sof_ds_r & EOF_N_US_r) ||
             (data_r & EOF_N_US_r & !SRC_RDY_N_US) ||
             (src_not_rdy_r & !SRC_RDY_N_US & EOF_N_US_r);
 
  assign  crc_c = (sof_ds_r || data_r || (src_not_rdy_r & !SRC_RDY_N_US)) & !EOF_N_US_r;
 
  assign  eof_ds_c  = crc_r;
 
  always @(posedge CLK)
  if (ll_valid)
  begin
    EOF_N_US_r  <=  `DLY EOF_N_US;
    DATA_US_r   <=  `DLY DATA_US;
  end
 
  always @(posedge CLK)
    if ( !DST_RDY_N_DS)
    begin
        DATA_US_2r  <=  `DLY DATA_US_r;    //--data pipe-II
  end
 
  always @(posedge CLK)
    if (!EOF_N_US & ll_valid)
      rem_in  <=  `DLY  REM_US;
 
  assign DST_RDY_N_US = DST_RDY_N_US_i;
  assign DST_RDY_N_US_i = DST_RDY_N_DS || (|count);
   
      //__deassert dst_rdy_n_us for 3 cycles after eof_n_us reception
        // to take care of crc insertion in DS-data__//
    always @(posedge CLK)
      if (RESET)
        count <=  `DLY 2'b00;
      else if (!EOF_N_US & ll_valid)
        count <=  `DLY 2'b10;
      else if (|count & !DST_RDY_N_DS)
        count <=  `DLY count >> 1;
       
    assign ll_valid = !SRC_RDY_N_US && !DST_RDY_N_US_i;

    assign CRC_RESET  = !SOF_N_US & ll_valid;

    assign CRC_DATAWIDTH1 = (!EOF_N_US & ll_valid) ? REM_US[1:0] : 2'b11;
    assign CRC_DATAVALID1 = ll_valid;
    assign CRC_DATA1      = DATA_US[31:0];

      //__CRC block instantiation for Lane1__//
    crc_top #(
          .CRC_INIT(CRC_INIT)
          ) tx_crc_gen1_i (
              .CRCRESET(CRC_RESET),
              .CRCCLK(CLK),
              .CRCDATAWIDTH(CRC_DATAWIDTH1),
              .CRCDATAVALID(CRC_DATAVALID1),
              //.CRCIN(CRC_DATA1),
              .CRCIN(CRC_DATA1),
              .CRCOUT(CRC1)
      );
  
assign final_CRC = {
		CRC1 }; 

      //__Register CRC calculated__//
    always @(posedge CLK)begin
        CRC_reg <=  `DLY final_CRC;
//        CRC_reg <=  `DLY 0;
    end
   
  //__Build DS output controls__/
    always @(posedge CLK)
      if (RESET)
      begin
        SOF_N_DS     <=  `DLY 1'b1;
        EOF_N_DS     <=  `DLY 1'b1;
        REM_DS       <=  `DLY 2'd3;
        SRC_RDY_N_DS <=  `DLY 1'b1;
      end
      else if (!DST_RDY_N_DS)
      begin
        SOF_N_DS     <=  `DLY !(sof_ds_r | sof_sc_r);
        EOF_N_DS     <=  `DLY !(eof_ds_r | eof_sc_r);
        REM_DS       <=  `DLY (eof_ds_r | eof_sc_r) ? rem_in : 2'd3;
        SRC_RDY_N_DS <=  `DLY idle_r | sc_frame_r | wait_r | src_not_rdy_r;
      end
  
    always @(posedge CLK)
      if (RESET)
        DATA_DS <=  `DLY 32'd0;
      else if (!DST_RDY_N_DS)
      begin
        if (sof_sc_r || crc_r)
          DATA_DS <=  `DLY 
                             (rem_in == 2'd0) ? {DATA_US_2r[31:24],final_CRC[31:8]} : 
                             (rem_in == 2'd1) ? {DATA_US_2r[31:16],final_CRC[31:16]} : 
                             (rem_in == 2'd2) ? {DATA_US_2r[31:8],final_CRC[31:24]} : DATA_US_2r; 
        else if (eof_sc_r || eof_ds_r)
          DATA_DS <=  `DLY 
                             (rem_in == 2'd0) ? {CRC_reg[7:0],24'd0} : 
                             (rem_in == 2'd1) ? {CRC_reg[15:0],16'd0} : 
                             (rem_in == 2'd2) ? {CRC_reg[23:0],8'd0} : CRC_reg; 
        else
          DATA_DS <=  `DLY DATA_US_2r;
      end

 
endmodule
