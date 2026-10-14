//2026/9/20
//cgliu
//起始位滤波开关(条件编译):定义本宏后,接收端在检测到下降沿后的第5/8个比特时间处复核电平,
//仍为低才承认是起始位,用于滤除rs485收发换向(de拉低)时rx上约40个时钟的窄低脉冲被误判为
//起始位的问题;判定点由CLK_FREQ/UART_BPS参数换算,随波特率设置自动变化。
//接上真传感器后如需恢复原始行为(仅凭下降沿即认为起始位),注释掉下面这行define重新编译即可。
`define UART_START_CHK_EN

module uart_1byte_rx(
    input				i_clk	                 //ϵͳʱ��
    ,input           	i_rst	               //ϵͳ��λ���͵�ƽ��Ч
    ,input           	i_uart_rx	                //UART���ն˿�
    ,output  			o_rx_done	               //����һ֡������ɱ�־�ź�
    ,output  [7:0]		o_rx_da               //���յ�����
    );
   
//==================================================================================================
//------------------------------------------ user set begin -----------------------------------------
//==================================================================================================


//baud
parameter  CLK_FREQ = 156_250_000;                 //ϵͳʱ��Ƶ��
parameter  UART_BPS = 115200;                     //���ڲ�����


//pority
parameter  PARITY = "NONE" ;
//parameter  PARITY = "EVEN" ;
//parameter  PARITY = "ODD" ;


//==================================================================================================
//------------------------------------------ user set end -----------------------------------------
//==================================================================================================




wire sys_clk = i_clk;
wire sys_rst_n	= !i_rst;
wire uart_rxd	= i_uart_rx;

reg	rx_done;

reg uart_done	;
reg uart_done_r	;
reg [7:0]	uart_data ;

assign o_rx_da = uart_data;
assign o_rx_done = rx_done;

always@(posedge i_clk)
begin
	if(i_rst)
		uart_done_r <= 0;
	else
		uart_done_r <= uart_done;
end

always@(posedge i_clk)
begin
	if(i_rst)
		rx_done <= 0;
	else if(uart_done_r == 0 && uart_done == 1)
		rx_done <= 1;
	else
		rx_done <= 0;
end


localparam BPS_CNT  = CLK_FREQ/UART_BPS;        //Ϊ�õ�ָ�������ʣ�
                                                //��Ҫ��ϵͳʱ�Ӽ���BPS_CNT��                                          
//reg define
`ifdef UART_START_CHK_EN
//起始位确认点=1bit时间的5/8,随CLK_FREQ/UART_BPS(波特率)自动换算;
//换向毛刺约40clk,在任何支持的波特率下都远短于5/8比特,会被该判据滤除。
localparam START_CHK_CNT = (CLK_FREQ/UART_BPS)*5/8;
`endif

generate
    if(PARITY=="ODD")begin:Odd
        reg        uart_rxd_d0;
        reg        uart_rxd_d1;
        reg [15:0] clk_cnt;                             //ϵͳʱ�Ӽ�����
        reg [ 3:0] rx_cnt;                              //�������ݼ�����
        reg        rx_flag;                             //���չ��̱�־�ź�
        reg [ 7:0] rxdata;                              //�������ݼĴ���
        
        //wire define
        wire       start_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //������ն˿��½���(��ʼλ)���õ�һ��ʱ�����ڵ������ź�
        assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    
        
        //��UART���ն˿ڵ������ӳ�����ʱ������
        always @(posedge sys_clk or negedge sys_rst_n) begin 
            if (!sys_rst_n) begin 
                uart_rxd_d0 <= 1'b0;
                uart_rxd_d1 <= 1'b0;          
            end
            else begin
                uart_rxd_d0  <= uart_rxd;                   
                uart_rxd_d1  <= uart_rxd_d0;
            end   
        end
        
        //�������ź�start_flag����ʱ��������չ���           
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                                  
                rx_flag <= 1'b0;
            else begin
                if(start_flag)                          //��⵽��ʼλ
                    rx_flag <= 1'b1;                    //������չ��̣���־λrx_flag����
`ifdef UART_START_CHK_EN
                else if((rx_cnt == 4'd0)&&(clk_cnt == START_CHK_CNT)&&(uart_rxd_d1))
                    rx_flag <= 1'b0;                    //起始位校验失败:5/8比特处已回高=毛刺,丢弃本次接收
`endif
                else if((rx_cnt == 4'd10)&&(clk_cnt == BPS_CNT/2))
                    rx_flag <= 1'b0;                    //������ֹͣλ�м�ʱ��ֹͣ���չ���
                else
                    rx_flag <= rx_flag;
            end
        end
        
        //������չ��̺�����ϵͳʱ�Ӽ�������������ݼ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin                             
                clk_cnt <= 16'd0;                                  
                rx_cnt  <= 4'd0;
            end                                                      
            else if ( rx_flag ) begin                   //���ڽ��չ���
                    if (clk_cnt < BPS_CNT - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                        rx_cnt  <= rx_cnt;
                    end
                    else begin
                        clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
                        rx_cnt  <= rx_cnt + 1'b1;       //��ʱ�������ݼ�������1
                    end
                end
                else begin                              //���չ��̽���������������
                    clk_cnt <= 16'd0;
                    rx_cnt  <= 4'd0;
                end
        end
        reg parity_bit;
        //���ݽ������ݼ��������Ĵ�uart���ն˿�����
        always @(posedge sys_clk or negedge sys_rst_n) begin 
            if ( !sys_rst_n)  begin
                rxdata <= 8'd0;                                     
                parity_bit <=  'b0;                                     
            end else if(rx_flag)                            //ϵͳ���ڽ��չ���
                if (clk_cnt == BPS_CNT/2) begin         //�ж�ϵͳʱ�Ӽ���������������λ�м�
                    case ( rx_cnt )
                     4'd0 : rxdata[0] <= uart_rxd_d1; // ��ʼλ
                     4'd1 : rxdata[0] <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     4'd2 : rxdata[1] <= uart_rxd_d1;
                     4'd3 : rxdata[2] <= uart_rxd_d1;
                     4'd4 : rxdata[3] <= uart_rxd_d1;
                     4'd5 : rxdata[4] <= uart_rxd_d1;
                     4'd6 : rxdata[5] <= uart_rxd_d1;
                     4'd7 : rxdata[6] <= uart_rxd_d1;
                     4'd8 : rxdata[7] <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     4'd9 : parity_bit <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     default:;                                    
                    endcase
                end
                else begin
                    rxdata <= rxdata;
                    parity_bit <= parity_bit;
                end
            else begin
                rxdata <= 8'd0;
                parity_bit <= 0;
            end
        end
        
        //���ݽ�����Ϻ������־�źŲ��Ĵ�������յ�������
        always @(posedge sys_clk or negedge sys_rst_n) begin        
            if (!sys_rst_n) begin
                uart_data <= 8'd0;                               
                uart_done <= 1'b0;
            end
            else if(rx_cnt == 4'd10) begin               //�������ݼ�����������ֹͣλʱ           
                uart_data <= rxdata;                    //�Ĵ�������յ�������
                uart_done <= 1'b1;                      //����������ɱ�־λ����
            end
            else begin
                uart_data <= 8'd0;                                   
                uart_done <= 1'b0; 
            end    
        end
    end else if(PARITY =="EVEN")begin:Even
        reg        uart_rxd_d0;
        reg        uart_rxd_d1;
        reg [15:0] clk_cnt;                             //ϵͳʱ�Ӽ�����
        reg [ 3:0] rx_cnt;                              //�������ݼ�����
        reg        rx_flag;                             //���չ��̱�־�ź�
        reg [ 7:0] rxdata;                              //�������ݼĴ���
        
        //wire define
        wire       start_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //������ն˿��½���(��ʼλ)���õ�һ��ʱ�����ڵ������ź�
        assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    
        
        //��UART���ն˿ڵ������ӳ�����ʱ������
        always @(posedge sys_clk or negedge sys_rst_n) begin 
            if (!sys_rst_n) begin 
                uart_rxd_d0 <= 1'b0;
                uart_rxd_d1 <= 1'b0;          
            end
            else begin
                uart_rxd_d0  <= uart_rxd;                   
                uart_rxd_d1  <= uart_rxd_d0;
            end   
        end
        
        //�������ź�start_flag����ʱ��������չ���           
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                                  
                rx_flag <= 1'b0;
            else begin
                if(start_flag)                          //��⵽��ʼλ
                    rx_flag <= 1'b1;                    //������չ��̣���־λrx_flag����
`ifdef UART_START_CHK_EN
                else if((rx_cnt == 4'd0)&&(clk_cnt == START_CHK_CNT)&&(uart_rxd_d1))
                    rx_flag <= 1'b0;                    //起始位校验失败:5/8比特处已回高=毛刺,丢弃本次接收
`endif
                else if((rx_cnt == 4'd10)&&(clk_cnt == BPS_CNT/2))
                    rx_flag <= 1'b0;                    //������ֹͣλ�м�ʱ��ֹͣ���չ���
                else
                    rx_flag <= rx_flag;
            end
        end
        
        //������չ��̺�����ϵͳʱ�Ӽ�������������ݼ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin                             
                clk_cnt <= 16'd0;                                  
                rx_cnt  <= 4'd0;
            end                                                      
            else if ( rx_flag ) begin                   //���ڽ��չ���
                    if (clk_cnt < BPS_CNT - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                        rx_cnt  <= rx_cnt;
                    end
                    else begin
                        clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
                        rx_cnt  <= rx_cnt + 1'b1;       //��ʱ�������ݼ�������1
                    end
                end
                else begin                              //���չ��̽���������������
                    clk_cnt <= 16'd0;
                    rx_cnt  <= 4'd0;
                end
        end
        reg parity_bit;
        //���ݽ������ݼ��������Ĵ�uart���ն˿�����
        always @(posedge sys_clk or negedge sys_rst_n) begin 
            if ( !sys_rst_n)  begin
                rxdata <= 8'd0;                                     
                parity_bit <=  'b0;                                     
            end else if(rx_flag)                            //ϵͳ���ڽ��չ���
                if (clk_cnt == BPS_CNT/2) begin         //�ж�ϵͳʱ�Ӽ���������������λ�м�
                    case ( rx_cnt )
                     4'd0 : rxdata[0] <= uart_rxd_d1; // ��ʼλ
                     4'd1 : rxdata[0] <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     4'd2 : rxdata[1] <= uart_rxd_d1;
                     4'd3 : rxdata[2] <= uart_rxd_d1;
                     4'd4 : rxdata[3] <= uart_rxd_d1;
                     4'd5 : rxdata[4] <= uart_rxd_d1;
                     4'd6 : rxdata[5] <= uart_rxd_d1;
                     4'd7 : rxdata[6] <= uart_rxd_d1;
                     4'd8 : rxdata[7] <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     4'd9 : parity_bit <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     default:;                                    
                    endcase
                end
                else begin
                    rxdata <= rxdata;
                    parity_bit <= parity_bit;
                end
            else begin
                rxdata <= 8'd0;
                parity_bit <= 0;
            end
        end
        
        //���ݽ�����Ϻ������־�źŲ��Ĵ�������յ�������
        always @(posedge sys_clk or negedge sys_rst_n) begin        
            if (!sys_rst_n) begin
                uart_data <= 8'd0;                               
                uart_done <= 1'b0;
            end
            else if(rx_cnt == 4'd10) begin               //�������ݼ�����������ֹͣλʱ           
                uart_data <= rxdata;                    //�Ĵ�������յ�������
                uart_done <= 1'b1;                      //����������ɱ�־λ����
            end
            else begin
                uart_data <= 8'd0;                                   
                uart_done <= 1'b0; 
            end    
        end
    end else begin:None
        reg        uart_rxd_d0;
        reg        uart_rxd_d1;
        reg [15:0] clk_cnt;                             //ϵͳʱ�Ӽ�����
        reg [ 3:0] rx_cnt;                              //�������ݼ�����
        reg        rx_flag;                             //���չ��̱�־�ź�
        reg [ 7:0] rxdata;                              //�������ݼĴ���
        
        //wire define
        wire       start_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //������ն˿��½���(��ʼλ)���õ�һ��ʱ�����ڵ������ź�
        assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    
        
        //��UART���ն˿ڵ������ӳ�����ʱ������
        always @(posedge sys_clk or negedge sys_rst_n) begin 
            if (!sys_rst_n) begin 
                uart_rxd_d0 <= 1'b0;
                uart_rxd_d1 <= 1'b0;          
            end
            else begin
                uart_rxd_d0  <= uart_rxd;                   
                uart_rxd_d1  <= uart_rxd_d0;
            end   
        end
        
        //�������ź�start_flag����ʱ��������չ���           
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                                  
                rx_flag <= 1'b0;
            else begin
                if(start_flag)                          //��⵽��ʼλ
                    rx_flag <= 1'b1;                    //������չ��̣���־λrx_flag����
`ifdef UART_START_CHK_EN
                else if((rx_cnt == 4'd0)&&(clk_cnt == START_CHK_CNT)&&(uart_rxd_d1))
                    rx_flag <= 1'b0;                    //起始位校验失败:5/8比特处已回高=毛刺,丢弃本次接收
`endif
                else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
                    rx_flag <= 1'b0;                    //������ֹͣλ�м�ʱ��ֹͣ���չ���
                else
                    rx_flag <= rx_flag;
            end
        end
        
        //������չ��̺�����ϵͳʱ�Ӽ�������������ݼ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin                             
                clk_cnt <= 16'd0;                                  
                rx_cnt  <= 4'd0;
            end                                                      
            else if ( rx_flag ) begin                   //���ڽ��չ���
                    if (clk_cnt < BPS_CNT - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                        rx_cnt  <= rx_cnt;
                    end
                    else begin
                        clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
                        rx_cnt  <= rx_cnt + 1'b1;       //��ʱ�������ݼ�������1
                    end
                end
                else begin                              //���չ��̽���������������
                    clk_cnt <= 16'd0;
                    rx_cnt  <= 4'd0;
                end
        end
        
        //���ݽ������ݼ��������Ĵ�uart���ն˿�����
        always @(posedge sys_clk or negedge sys_rst_n) begin 
            if ( !sys_rst_n)  
                rxdata <= 8'd0;                                     
            else if(rx_flag)                            //ϵͳ���ڽ��չ���
                if (clk_cnt == BPS_CNT/2) begin         //�ж�ϵͳʱ�Ӽ���������������λ�м�
                    case ( rx_cnt )
                     4'd1 : rxdata[0] <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     4'd2 : rxdata[1] <= uart_rxd_d1;
                     4'd3 : rxdata[2] <= uart_rxd_d1;
                     4'd4 : rxdata[3] <= uart_rxd_d1;
                     4'd5 : rxdata[4] <= uart_rxd_d1;
                     4'd6 : rxdata[5] <= uart_rxd_d1;
                     4'd7 : rxdata[6] <= uart_rxd_d1;
                     4'd8 : rxdata[7] <= uart_rxd_d1;   //�Ĵ�����λ���λ
                     default:;                                    
                    endcase
                end
                else 
                    rxdata <= rxdata;
            else
                rxdata <= 8'd0;
        end
        
        //���ݽ�����Ϻ������־�źŲ��Ĵ�������յ�������
        always @(posedge sys_clk or negedge sys_rst_n) begin        
            if (!sys_rst_n) begin
                uart_data <= 8'd0;                               
                uart_done <= 1'b0;
            end
            else if(rx_cnt == 4'd9) begin               //�������ݼ�����������ֹͣλʱ           
                uart_data <= rxdata;                    //�Ĵ�������յ�������
                uart_done <= 1'b1;                      //����������ɱ�־λ����
            end
            else begin
                uart_data <= 8'd0;                                   
                uart_done <= 1'b0; 
            end    
        end
    end
endgenerate

endmodule	