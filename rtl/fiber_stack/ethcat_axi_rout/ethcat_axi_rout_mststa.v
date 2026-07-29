///////////////////////////////////////////////////////////////////////////////
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_EXAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//        
`timescale 1 ns / 1 ps
(* core_generation_info = "aurora_8b10b_0,aurora_8b10b_v11_1_6,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=31250,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
module ethcat_axi_rout_mststa
(
     input                  clk
    ,input                  rst
    ,input                  downstream_lane_up
    ,input                  downstream_link
    //from app
    ,input  wire            s_app_tx_tvalid
    ,output reg             s_app_tx_tready
    ,input  wire    [3:0]   s_app_tx_tkeep
    ,input  wire            s_app_tx_tlast
    ,input  wire    [31:0]  s_app_tx_tdata

    ,output reg            m_app_rx_tvalid
    ,output reg    [3:0]   m_app_rx_tkeep
    ,output reg            m_app_rx_tlast
    ,output reg    [31:0]  m_app_rx_tdata

    //AXI INTF  
    ,output reg [0:31]      m_axi_tx_tdata_0
    ,output reg [0:3]       m_axi_tx_tkeep_0
    ,output reg            m_axi_tx_tvalid_0
    ,output reg            m_axi_tx_tlast_0
    ,input                  m_axi_tx_tready_0
        //AXI RX
    ,input  [0:31]          s_axi_rx_tdata_0
    ,input  [0:3]           s_axi_rx_tkeep_0
    ,input                  s_axi_rx_tvalid_0
    ,input                  s_axi_rx_tlast_0

    //AXI INTF 
    ,output reg  [0:31]    m_axi_tx_tdata_1
    ,output reg  [0:3]     m_axi_tx_tkeep_1
    ,output reg            m_axi_tx_tvalid_1
    ,output reg            m_axi_tx_tlast_1
    ,input                  m_axi_tx_tready_1
        //AXI RX
    ,input  [0:31]          s_axi_rx_tdata_1
    ,input  [0:3]           s_axi_rx_tkeep_1
    ,input                  s_axi_rx_tvalid_1
    ,input                  s_axi_rx_tlast_1

);
	
	localparam  STM_IDLE     = 'd0;
    localparam  STM_DX       = 'd1;
    localparam  STM_KHG      = 'd2;
	localparam  STM_PG       = 'd3;
    localparam  STM_ED     	 = 'd4;

    localparam  STM_IDLE_F      = 'd0;
    localparam  STM_INIT        = 'd1;
    localparam  STM_JUDGE    	= 'd2;
    localparam  STM_END     	= 'd3;
	(* MARK_DEBUG="true" *)reg	[2:0]		wk_state;
	
	wire        m_cache_tvalid_0;
    reg         m_cache_tready_0;
    wire [3:0]  m_cache_tkeep_0;
    wire        m_cache_tlast_0;
    wire [31:0] m_cache_tdata_0;

    reg         m_cache_tready_1;
    wire [3:0]  m_cache_tkeep_1;
    wire        m_cache_tlast_1;
    wire [31:0] m_cache_tdata_1;
	wire		m_cache_tvalid_1;
	reg	[2:0]	stu;
	reg	[19:0]	cycle;

	(* MARK_DEBUG="true" *)reg		[1:0]				f_wk_state;
	(* MARK_DEBUG="true" *)reg		[1:0]				f_nstate;
	
	always @(posedge clk) begin
        if(rst)begin
			wk_state  			<=  STM_IDLE;
        end else begin
            case(wk_state)
			STM_IDLE:begin
                if(downstream_link&downstream_lane_up)begin
					wk_state  	<=  STM_KHG;//
				end else if(downstream_link&downstream_lane_up&s_axi_rx_tvalid_1)begin
					wk_state  	<=  STM_DX;//STM_DX-->STM_IDLE
				end else if(~downstream_link&downstream_lane_up)begin
					wk_state  	<=  STM_PG;
				end else if(downstream_link&~downstream_lane_up)begin
					wk_state  	<=  STM_ED;
				end else begin				
					wk_state  	<=  STM_IDLE;
				end
            end
			STM_DX:begin
				wk_state  		<= wk_state;
			end		
			STM_KHG:begin
				if(stu==1)begin
					wk_state  		<= wk_state;
				end else if((~downstream_link)|(~downstream_lane_up))begin
					wk_state  		<= STM_IDLE;
				end else begin
					wk_state  		<= wk_state;
				end
			end
			STM_PG:begin
				if(((downstream_link&downstream_lane_up))||((~downstream_link)&(~downstream_lane_up)))begin
					wk_state  		<= STM_IDLE;
				end else begin
					wk_state  		<= wk_state;
				end
			end
			STM_ED:begin
				if(((downstream_link&downstream_lane_up))||((~downstream_link)&(~downstream_lane_up)))begin
					wk_state  		<= STM_IDLE;
				end else begin
					wk_state  		<= wk_state;
				end
			end
            default: begin
                wk_state  		<=  STM_IDLE;
            end
            endcase
        end
	end

    always @( * )begin
		case(wk_state)
		STM_IDLE,STM_KHG:begin
			m_axi_tx_tdata_0	<= s_app_tx_tdata;
			m_axi_tx_tkeep_0	<= s_app_tx_tkeep;
			m_axi_tx_tvalid_0	<= s_app_tx_tvalid;
			m_axi_tx_tlast_0	<= s_app_tx_tlast;
			
			m_axi_tx_tdata_1	<= m_cache_tdata_0;
			m_axi_tx_tkeep_1	<= m_cache_tkeep_0;
			m_axi_tx_tvalid_1	<= m_cache_tvalid_0;
			m_axi_tx_tlast_1	<= m_cache_tlast_0;
			
			m_app_rx_tvalid 	<= m_cache_tvalid_1;
			m_app_rx_tkeep		<= m_cache_tkeep_1;
			m_app_rx_tlast		<= m_cache_tlast_1;
			m_app_rx_tdata		<= m_cache_tdata_1;
		end
/*		STM_IDLE:begin
			m_axi_tx_tdata_0	<= s_app_tx_tdata;
			m_axi_tx_tkeep_0	<= s_app_tx_tkeep;
			m_axi_tx_tvalid_0	<= s_app_tx_tvalid;
			m_axi_tx_tlast_0	<= s_app_tx_tlast;
			
			m_axi_tx_tdata_1	<= m_cache_tdata_0;
			m_axi_tx_tkeep_1	<= m_cache_tkeep_0;
			m_axi_tx_tvalid_1	<= m_cache_tvalid_0;
			m_axi_tx_tlast_1	<= m_cache_tlast_0;
			
			m_app_rx_tvalid 	<= m_cache_tvalid_1;
			m_app_rx_tkeep		<= m_cache_tkeep_1;
			m_app_rx_tlast		<= m_cache_tlast_1;
			m_app_rx_tdata		<= m_cache_tdata_1;
		end	*/	
		STM_PG:begin
			m_axi_tx_tdata_0	<= s_app_tx_tdata;
			m_axi_tx_tkeep_0	<= s_app_tx_tkeep;
			m_axi_tx_tvalid_0	<= s_app_tx_tvalid;
			m_axi_tx_tlast_0	<= s_app_tx_tlast;
			m_axi_tx_tdata_1	<= 'h0;
			m_axi_tx_tkeep_1	<= 'h0;
			m_axi_tx_tvalid_1	<= 'h0;
			m_axi_tx_tlast_1	<= 'h0;
			m_app_rx_tvalid 	<= m_cache_tvalid_0;
			m_app_rx_tkeep		<= m_cache_tkeep_0;
			m_app_rx_tlast		<= m_cache_tlast_0;
			m_app_rx_tdata		<= m_cache_tdata_0;
		end
		STM_ED:begin
			m_axi_tx_tdata_0	<= 'h0;
			m_axi_tx_tkeep_0	<= 'h0;
			m_axi_tx_tvalid_0	<= 'h0;
			m_axi_tx_tlast_0	<= 'h0;
			m_axi_tx_tdata_1	<= s_app_tx_tdata;
			m_axi_tx_tkeep_1	<= s_app_tx_tkeep;
			m_axi_tx_tvalid_1	<= s_app_tx_tvalid;
			m_axi_tx_tlast_1	<= s_app_tx_tlast;
			m_app_rx_tvalid 	<= m_cache_tvalid_1;
			m_app_rx_tkeep		<= m_cache_tkeep_1;
			m_app_rx_tlast		<= m_cache_tlast_1;
			m_app_rx_tdata		<= m_cache_tdata_1;
		end
        default: begin 
			m_axi_tx_tdata_0	<= 'h0;
			m_axi_tx_tkeep_0	<= 'h0;
			m_axi_tx_tvalid_0	<= 'h0;
			m_axi_tx_tlast_0	<= 'h0;
			m_axi_tx_tdata_1	<= 'h0;
			m_axi_tx_tkeep_1	<= 'h0;
			m_axi_tx_tvalid_1	<= 'h0;
			m_axi_tx_tlast_1	<= 'h0;
			m_app_rx_tvalid 	<= 'h0;
			m_app_rx_tkeep		<= 'h0;
			m_app_rx_tlast		<= 'h0;
			m_app_rx_tdata		<= 'h0;
        end
        endcase		
    end

    always @( * )begin        
		case(wk_state)
        STM_KHG:begin
                        s_app_tx_tready         <= m_axi_tx_tready_0;
                        m_cache_tready_0        <= m_axi_tx_tready_1;
			m_cache_tready_1	<= 1'b1;
		end
		STM_DX:begin
			m_cache_tready_1	<= 1'b1;
			s_app_tx_tready 	<= m_axi_tx_tready_0;
			m_cache_tready_0	<= m_axi_tx_tready_1;			
		end
		STM_PG:begin
			s_app_tx_tready 	<=  m_axi_tx_tready_0;
			m_cache_tready_0	<= 1'b1;
			m_cache_tready_1	<= 1'b0;
		end
		STM_ED:begin
			s_app_tx_tready 	<=  m_axi_tx_tready_1;
			m_cache_tready_0	<= 1'b0;
			m_cache_tready_1	<= 1'b1;
		end
        default: begin 
			s_app_tx_tready 	<= 1'b0;
			m_cache_tready_0	<= 1'b0;
			m_cache_tready_1	<= 1'b0;
        end
        endcase		
    end

	always @(posedge clk)begin
        if(rst)begin
			stu	<=  'd0; 
		end else begin
			case(f_wk_state)
			STM_IDLE_F:begin
				if(downstream_link&downstream_lane_up)begin
					stu <= 'd1;
				end	else begin
					stu <= stu;
				end
			end	
			STM_INIT:begin
				if(downstream_link&downstream_lane_up)begin
					stu <= 'd1;
				end else if(((~downstream_link)|(~downstream_lane_up))&&(cycle=='hffffff))begin
					stu <= 'h0;
				end else begin
					stu <= stu;
				end	
			end
			STM_JUDGE:begin
				stu <= stu;
			end
			STM_END:begin
				stu <= stu;
			end
			default:stu	<=  'd0;
		endcase
		end
	end	
	
	always @(posedge clk)begin
        if(rst)begin
            f_wk_state	<=  STM_IDLE_F; 
		end else begin
			f_wk_state	<=	f_nstate;
		end
	end
	
	always @ (*)begin
		f_nstate <= STM_IDLE_F;
		case(f_wk_state)
		STM_IDLE_F:begin
			if((~downstream_link)|(~downstream_lane_up))begin
				f_nstate <= STM_INIT;
			end	else begin
				f_nstate <= STM_IDLE_F;
			end
		end 
		STM_INIT:begin
			if(downstream_link&downstream_lane_up)begin
				f_nstate <= STM_END;
			end else if(((~downstream_link)|(~downstream_lane_up))&&(cycle=='hffffff))begin
				f_nstate <= STM_JUDGE;
			end	else begin
				f_nstate <= STM_INIT;
			end
		end
		STM_JUDGE:begin
			if(downstream_link&downstream_lane_up)begin
				f_nstate <= STM_END;
			end else begin
				f_nstate <= STM_JUDGE;
			end
		end
		STM_END:begin
			f_nstate <= STM_IDLE_F;
		end			
		default:f_nstate <= STM_IDLE_F;
		endcase
	end	

	always @(posedge clk) begin
        if(rst)begin
			cycle  	<=  'h0;
        end else begin
			if((~downstream_link)|(~downstream_lane_up))begin
				cycle	<= cycle + 1;
			end else begin
				cycle  	<=  'h0;
			end	
		end
	end

	axi_cache
        axi_cache_u0
        (
             .clk           (clk    			)
            ,.reset         (rst    			)

            ,.s_axi_tvalid  (s_axi_rx_tvalid_0  )
            ,.s_axi_tready  ( 					)//s_axi_rx_tready_0
            ,.s_axi_tkeep   (s_axi_rx_tkeep_0   )
            ,.s_axi_tlast   (s_axi_rx_tlast_0   )
            ,.s_axi_tdata   (s_axi_rx_tdata_0   )

            ,.m_axi_tvalid  (m_cache_tvalid_0	)
            ,.m_axi_tready  (m_cache_tready_0	)
            ,.m_axi_tkeep   (m_cache_tkeep_0	)
            ,.m_axi_tlast   (m_cache_tlast_0	)
            ,.m_axi_tdata   (m_cache_tdata_0	)
        );
	
	axi_cache
        axi_cache_u1
        (
             .clk           (clk    			)
            ,.reset         (rst    			)

            ,.s_axi_tvalid  (s_axi_rx_tvalid_1	)
            ,.s_axi_tready  ( 					)//s_axi_rx_tready_1
            ,.s_axi_tkeep   (s_axi_rx_tkeep_1   )
            ,.s_axi_tlast   (s_axi_rx_tlast_1   )
            ,.s_axi_tdata   (s_axi_rx_tdata_1   )

            ,.m_axi_tvalid  (m_cache_tvalid_1	)
            ,.m_axi_tready  (m_cache_tready_1	)
            ,.m_axi_tkeep   (m_cache_tkeep_1	)
            ,.m_axi_tlast   (m_cache_tlast_1	)
            ,.m_axi_tdata   (m_cache_tdata_1	)
        );

endmodule
