//2026/9/20
//cgliu

module uart_1byte_tx(
    input	      	i_clk     
    ,input         	i_rst     
    ,input         	i_tx_vld
    ,input  [7:0]  	i_tx_da   
    ,output        	o_tx_done 
    ,output        	o_uart_tx 
    );
  
//==================================================================================================
//------------------------------------------ user set begin -----------------------------------------
//==================================================================================================

//baud
parameter  CLK_FREQ = 156_250_000;            //ϵͳʱ��Ƶ��
parameter  UART_BPS = 115200;                //���ڲ�����

//pority
parameter  PARITY = "NONE" ;
//parameter  PARITY = "EVEN" ;
//parameter  PARITY = "ODD" ;


//==================================================================================================
//------------------------------------------ user set end -----------------------------------------
//==================================================================================================


wire uart_tx_busy  ;
wire uart_tx_ready ;
reg	uart_tx_ready_r;
wire sys_rst_n = !i_rst;
wire sys_clk = i_clk;
wire uart_en = i_tx_vld;
wire [7:0] uart_din = i_tx_da;
reg   uart_txd ;

assign o_uart_tx = uart_txd;

reg	tx_done;

assign o_tx_done = tx_done;

always@(posedge i_clk)
begin
	if(i_rst)
		tx_done <= 0;
	else if(uart_tx_ready_r == 0 && uart_tx_ready == 1)
		tx_done <= 1;
	else
		tx_done <= 0;
end


always@(posedge i_clk)
begin
	uart_tx_ready_r <= uart_tx_ready;
end



localparam  BPS_CNT  = CLK_FREQ/UART_BPS;   //Ϊ�õ�ָ�������ʣ���ϵͳʱ�Ӽ���BPS_CNT��

//reg define
generate
    if(PARITY=="ODD")begin:Odd
        reg        uart_en_d0; 
        reg        uart_en_d1;  
        reg [15:0] clk_cnt;                         //ϵͳʱ�Ӽ�����
        reg [ 3:0] tx_cnt;                          //�������ݼ�����
        reg        tx_flag;                         //���͹��̱�־�ź�
        reg [ 7:0] tx_data;                         //�Ĵ淢������
        
        //wire define
        wire       en_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //�ڴ��ڷ��͹����и���æ״̬��־
        reg tx_busy_pre;
        assign uart_tx_busy = tx_flag;
        assign uart_tx_ready = (~tx_flag)&(~tx_busy_pre);
        
        //����uart_en�����أ��õ�һ��ʱ�����ڵ������ź�
        assign en_flag = (~uart_en_d1) & uart_en_d0;
        
        //�Է���ʹ���ź�uart_en�ӳ�����ʱ������
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin
                uart_en_d0 <= 1'b0;                                  
                uart_en_d1 <= 1'b0;
            end                                                      
            else begin                                               
                uart_en_d0 <= uart_en;                               
                uart_en_d1 <= uart_en_d0;                            
            end
        end
        
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin
                tx_busy_pre <= 1'b0;
            end                                                      
            else begin                                               
                if(uart_en)tx_busy_pre <= 1'b1;    
                else if(tx_flag)tx_busy_pre <= 1'b0;                          
            end
        end
        
        reg parity;
        //�������ź�en_flag����ʱ,�Ĵ�����͵����ݣ������뷢�͹���          
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin                                  
                tx_flag <= 1'b0;
                tx_data <= 8'd0;
                parity <= 1'b0;
            end 
            else if (en_flag) begin                 //��⵽����ʹ��������                      
                    tx_flag <= 1'b1;                //���뷢�͹��̣���־λtx_flag����
                    tx_data <= uart_din;            //�Ĵ�����͵�����
                    parity <= !(^uart_din);
                end
                                                    //������ֹͣλ����ʱ��ֹͣ���͹���
                else if ((tx_cnt == 4'd10) && (clk_cnt == BPS_CNT -(BPS_CNT/16))) begin                                       
                    tx_flag <= 1'b0;                //���͹��̽�������־λtx_flag����
                    tx_data <= 8'd0;
                    parity  <= 1'b0;
                end
                else begin
                    tx_flag <= tx_flag;
                    tx_data <= tx_data;
                    parity  <= parity;
                end 
        end
        
        //���뷢�͹��̺�����ϵͳʱ�Ӽ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                             
                clk_cnt <= 16'd0;                                  
            else if (tx_flag) begin                 //���ڷ��͹���
                if (clk_cnt < BPS_CNT - 1)
                    clk_cnt <= clk_cnt + 1'b1;
                else
                    clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
            end
            else                             
                clk_cnt <= 16'd0; 				    //���͹��̽���
        end
        
        //���뷢�͹��̺������������ݼ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                             
                tx_cnt <= 4'd0;
            else if (tx_flag) begin                 //���ڷ��͹���
                if (clk_cnt == BPS_CNT - 1)			//��ϵͳʱ�Ӽ�����һ������������
                    tx_cnt <= tx_cnt + 1'b1;		//��ʱ�������ݼ�������1
                else
                    tx_cnt <= tx_cnt;       
            end
            else                              
                tx_cnt  <= 4'd0;				    //���͹��̽���
        end
        
        //���ݷ������ݼ���������uart���Ͷ˿ڸ�ֵ
        always @(posedge sys_clk or negedge sys_rst_n) begin        
            if (!sys_rst_n)  
                uart_txd <= 1'b1;        
            else if (tx_flag)
                case(tx_cnt)
                    4'd0: uart_txd <= 1'b0;         //��ʼλ 
                    4'd1: uart_txd <= tx_data[0];   //����λ���λ
                    4'd2: uart_txd <= tx_data[1];
                    4'd3: uart_txd <= tx_data[2];
                    4'd4: uart_txd <= tx_data[3];
                    4'd5: uart_txd <= tx_data[4];
                    4'd6: uart_txd <= tx_data[5];
                    4'd7: uart_txd <= tx_data[6];
                    4'd8: uart_txd <= tx_data[7];   //����λ���λ
                    4'd9: uart_txd <= parity;         //У��λ
                    4'd10: uart_txd <= 1'b1;        //ֹͣλ
                    default: ;
                endcase
            else 
                uart_txd <= 1'b1;                   //����ʱ���Ͷ˿�Ϊ�ߵ�ƽ
        end
    end else if(PARITY =="EVEN")begin:Even
        reg        uart_en_d0; 
        reg        uart_en_d1;  
        reg [15:0] clk_cnt;                         //ϵͳʱ�Ӽ�����
        reg [ 3:0] tx_cnt;                          //�������ݼ�����
        reg        tx_flag;                         //���͹��̱�־�ź�
        reg [ 7:0] tx_data;                         //�Ĵ淢������
        
        //wire define
        wire       en_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //�ڴ��ڷ��͹����и���æ״̬��־
        reg tx_busy_pre;
        assign uart_tx_busy = tx_flag;
        assign uart_tx_ready = (~tx_flag)&(~tx_busy_pre);
        
        //����uart_en�����أ��õ�һ��ʱ�����ڵ������ź�
        assign en_flag = (~uart_en_d1) & uart_en_d0;
        
        //�Է���ʹ���ź�uart_en�ӳ�����ʱ������
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin
                uart_en_d0 <= 1'b0;                                  
                uart_en_d1 <= 1'b0;
            end                                                      
            else begin                                               
                uart_en_d0 <= uart_en;                               
                uart_en_d1 <= uart_en_d0;                            
            end
        end
        
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin
                tx_busy_pre <= 1'b0;
            end                                                      
            else begin                                               
                if(uart_en)tx_busy_pre <= 1'b1;    
                else if(tx_flag)tx_busy_pre <= 1'b0;                          
            end
        end
        
        reg parity;
        //�������ź�en_flag����ʱ,�Ĵ�����͵����ݣ������뷢�͹���          
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin                                  
                tx_flag <= 1'b0;
                tx_data <= 8'd0;
                parity <= 1'b0;
            end 
            else if (en_flag) begin                 //��⵽����ʹ��������                      
                    tx_flag <= 1'b1;                //���뷢�͹��̣���־λtx_flag����
                    tx_data <= uart_din;            //�Ĵ�����͵�����
                    parity <= ^uart_din;
                end
                                                    //������ֹͣλ����ʱ��ֹͣ���͹���
                else if ((tx_cnt == 4'd10) && (clk_cnt == BPS_CNT -(BPS_CNT/16))) begin                                       
                    tx_flag <= 1'b0;                //���͹��̽�������־λtx_flag����
                    tx_data <= 8'd0;
                    parity  <= 1'b0;
                end
                else begin
                    tx_flag <= tx_flag;
                    tx_data <= tx_data;
                    parity  <= parity;
                end 
        end
        
        //���뷢�͹��̺�����ϵͳʱ�Ӽ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                             
                clk_cnt <= 16'd0;                                  
            else if (tx_flag) begin                 //���ڷ��͹���
                if (clk_cnt < BPS_CNT - 1)
                    clk_cnt <= clk_cnt + 1'b1;
                else
                    clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
            end
            else                             
                clk_cnt <= 16'd0; 				    //���͹��̽���
        end
        
        //���뷢�͹��̺������������ݼ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                             
                tx_cnt <= 4'd0;
            else if (tx_flag) begin                 //���ڷ��͹���
                if (clk_cnt == BPS_CNT - 1)			//��ϵͳʱ�Ӽ�����һ������������
                    tx_cnt <= tx_cnt + 1'b1;		//��ʱ�������ݼ�������1
                else
                    tx_cnt <= tx_cnt;       
            end
            else                              
                tx_cnt  <= 4'd0;				    //���͹��̽���
        end
        
        //���ݷ������ݼ���������uart���Ͷ˿ڸ�ֵ
        always @(posedge sys_clk or negedge sys_rst_n) begin        
            if (!sys_rst_n)  
                uart_txd <= 1'b1;        
            else if (tx_flag)
                case(tx_cnt)
                    4'd0: uart_txd <= 1'b0;         //��ʼλ 
                    4'd1: uart_txd <= tx_data[0];   //����λ���λ
                    4'd2: uart_txd <= tx_data[1];
                    4'd3: uart_txd <= tx_data[2];
                    4'd4: uart_txd <= tx_data[3];
                    4'd5: uart_txd <= tx_data[4];
                    4'd6: uart_txd <= tx_data[5];
                    4'd7: uart_txd <= tx_data[6];
                    4'd8: uart_txd <= tx_data[7];   //����λ���λ
                    4'd9: uart_txd <= parity;         //У��λ
                    4'd10:uart_txd <= 1'b1;         //ֹͣλ
                    default: ;
                endcase
            else 
                uart_txd <= 1'b1;                   //����ʱ���Ͷ˿�Ϊ�ߵ�ƽ
        end
    end else begin:None
        reg        uart_en_d0; 
        reg        uart_en_d1;  
        reg [15:0] clk_cnt;                         //ϵͳʱ�Ӽ�����
        reg [ 3:0] tx_cnt;                          //�������ݼ�����
        reg        tx_flag;                         //���͹��̱�־�ź�
        reg [ 7:0] tx_data;                         //�Ĵ淢������
        
        //wire define
        wire       en_flag;
        
        //*****************************************************
        //**                    main code
        //*****************************************************
        //�ڴ��ڷ��͹����и���æ״̬��־
        reg tx_busy_pre;
        assign uart_tx_busy = tx_flag;
        assign uart_tx_ready = (~tx_flag)&(~tx_busy_pre);
        
        //����uart_en�����أ��õ�һ��ʱ�����ڵ������ź�
        assign en_flag = (~uart_en_d1) & uart_en_d0;
        
        //�Է���ʹ���ź�uart_en�ӳ�����ʱ������
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin
                uart_en_d0 <= 1'b0;                                  
                uart_en_d1 <= 1'b0;
            end                                                      
            else begin                                               
                uart_en_d0 <= uart_en;                               
                uart_en_d1 <= uart_en_d0;                            
            end
        end
        
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin
                tx_busy_pre <= 1'b0;
            end                                                      
            else begin                                               
                if(uart_en)tx_busy_pre <= 1'b1;    
                else if(tx_flag)tx_busy_pre <= 1'b0;                          
            end
        end
        
        //�������ź�en_flag����ʱ,�Ĵ�����͵����ݣ������뷢�͹���          
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n) begin                                  
                tx_flag <= 1'b0;
                tx_data <= 8'd0;
            end 
            else if (en_flag) begin                 //��⵽����ʹ��������                      
                    tx_flag <= 1'b1;                //���뷢�͹��̣���־λtx_flag����
                    tx_data <= uart_din;            //�Ĵ�����͵�����
                end
                                                    //������ֹͣλ����ʱ��ֹͣ���͹���
                else if ((tx_cnt == 4'd9) && (clk_cnt == BPS_CNT -(BPS_CNT/16))) begin                                       
                    tx_flag <= 1'b0;                //���͹��̽�������־λtx_flag����
                    tx_data <= 8'd0;
                end
                else begin
                    tx_flag <= tx_flag;
                    tx_data <= tx_data;
                end 
        end
        
        //���뷢�͹��̺�����ϵͳʱ�Ӽ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                             
                clk_cnt <= 16'd0;                                  
            else if (tx_flag) begin                 //���ڷ��͹���
                if (clk_cnt < BPS_CNT - 1)
                    clk_cnt <= clk_cnt + 1'b1;
                else
                    clk_cnt <= 16'd0;               //��ϵͳʱ�Ӽ�����һ�����������ں�����
            end
            else                             
                clk_cnt <= 16'd0; 				    //���͹��̽���
        end
        
        //���뷢�͹��̺������������ݼ�����
        always @(posedge sys_clk or negedge sys_rst_n) begin         
            if (!sys_rst_n)                             
                tx_cnt <= 4'd0;
            else if (tx_flag) begin                 //���ڷ��͹���
                if (clk_cnt == BPS_CNT - 1)			//��ϵͳʱ�Ӽ�����һ������������
                    tx_cnt <= tx_cnt + 1'b1;		//��ʱ�������ݼ�������1
                else
                    tx_cnt <= tx_cnt;       
            end
            else                              
                tx_cnt  <= 4'd0;				    //���͹��̽���
        end
        
        //���ݷ������ݼ���������uart���Ͷ˿ڸ�ֵ
        always @(posedge sys_clk or negedge sys_rst_n) begin        
            if (!sys_rst_n)  
                uart_txd <= 1'b1;        
            else if (tx_flag)
                case(tx_cnt)
                    4'd0: uart_txd <= 1'b0;         //��ʼλ 
                    4'd1: uart_txd <= tx_data[0];   //����λ���λ
                    4'd2: uart_txd <= tx_data[1];
                    4'd3: uart_txd <= tx_data[2];
                    4'd4: uart_txd <= tx_data[3];
                    4'd5: uart_txd <= tx_data[4];
                    4'd6: uart_txd <= tx_data[5];
                    4'd7: uart_txd <= tx_data[6];
                    4'd8: uart_txd <= tx_data[7];   //����λ���λ
                    4'd9: uart_txd <= 1'b1;         //ֹͣλ
                    default: ;
                endcase
            else 
                uart_txd <= 1'b1;                   //����ʱ���Ͷ˿�Ϊ�ߵ�ƽ
        end
    end
endgenerate
endmodule	          