library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY myUART115200_rx IS
PORT (
      bclk                     : IN std_logic;   --clk=band*16
    reset                   : IN std_logic;   
    rxd  :in std_logic;
    txd:out std_logic;
	 rx_dout:out std_logic_vector(7 downto 0);
     rx_ready :out std_logic
    
      ); 
END myUART115200_rx;

ARCHITECTURE arch OF myUART115200_rx IS

   
	
   constant s_idle               :  std_logic_vector(2 DOWNTO 0):="000";
   constant s_sample              :  std_logic_vector(2 DOWNTO 0):="001";  
   constant s_wait               :  std_logic_vector(2 DOWNTO 0):="010";
   constant s_shift               :  std_logic_vector(2 DOWNTO 0):="011";
  constant s_stop               :  std_logic_vector(2 DOWNTO 0):="100";
  constant Lframe              : integer:=8;
  constant test512:std_logic:='1';
  
   SIGNAL state                 :  std_logic_vector(2 downto 0); 
   SIGNAL cnt                 :  integer range 0 to 2000; 
   SIGNAL dcnt                 :  integer range 0 to 2000; 
	 SIGNAL num                 :  integer range 0 to  8000;
   SIGNAL data                 :  std_logic_vector(7 downto 0);   
	SIGNAL data1                 :  std_logic_vector(7 downto 0);   
  signal reg :std_logic;
  signal z1:std_logic;
  signal z2:std_logic;
  signal z3:std_logic;
  signal z4:std_logic;
  signal zz:std_logic;
  
BEGIN
   rx_dout<=data;
	rx_ready<=reg;
	txd<=test512;
 PROCESS(bclk,reset)
   BEGIN
      IF ( reset = '0') THEN
         state<=s_idle ;
			cnt<=0;
			dcnt<=0;
			num<=0;
			data1<="00000000";
			reg<='0';
			
      ELSIF(rising_edge(bclk))THEN
        
   
            CASE state IS
				
               WHEN s_idle => 
					
					  z1<=rxd;
					  z2<=z1;
					  z3<=z2;
					  z4<=z3;
					  reg<='0';
					  zz<=( not z1 )and ( not z2) and  (  z3) and   (z4);
					  if(zz='1')then state<=s_sample;
					  else state<=s_idle;
					  end if;
					        
					
               WHEN s_sample => 
                 if(num=1068)then data1(0)<=rxd;num<=num+1;
					  elsif(num=1936)then data1(1)<=rxd;num<=num+1;
					  elsif(num=2804)then data1(2)<=rxd;num<=num+1;
					  elsif(num=3672)then data1(3)<=rxd;num<=num+1;
					  elsif(num=4540)then data1(4)<=rxd;num<=num+1;
					  elsif(num=5408)then data1(5)<=rxd;num<=num+1;
					  elsif(num=6276)then data1(6)<=rxd;num<=num+1;
					  elsif(num=7144)then data1(7)<=rxd;num<=num+1;
					  elsif(num>7150)then state<=s_stop;data<=data1;num<=0;
					  else num<=num+1;
					  end if;
					  
							  
							  
						
				
               
								  
               WHEN s_stop=> 
                      if(num=20)then reg<='1';
						           state<=s_idle;num<=0;
							 else   num<=num+1; state<=s_stop;
							 end if;
                       
               when others=> state<=s_idle;  reg<='0';
             
            END CASE;
        END IF;
END PROCESS;


END arch;