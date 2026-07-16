
--------------------------------------------------------------------------------
-- Company: <Sunny_Intel>
-- Engineer: <Zhao_Cheng_Cheng>
--
-- Create Date: <2020.0511>
-- Design Name: <code_rx>
-- Component Name: <name_of_this_component>
-- Target Device: <target device>
-- Tool versions: <tool_versions>
-- Description:
--    <Description here>
-- Dependencies:
--    <Dependencies here>
-- Revision:
--    <Code_revision_information>
-- Additional Comments:
--    <Additional_comments>
--------------------------------------------------------------------------------
			
			



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity code_rx is
--generic(
--instruction_1:std_logic_vector(31 downto 0):=X"00000001";--start_1--ack1
--instruction_2:std_logic_vector(31 downto 0):=X"00000002";--start_2--ack1

           

--);
 Port ( 
 clk:in std_logic;
 rstn:in std_logic;

data_in:in std_logic_vector(7 downto 0);
data_vd:in std_logic;

data_start:in std_logic_vector(15 downto 0);

data_reg:in std_logic;
data_address:in std_logic_vector(15 downto 0);

data_out:out std_logic_vector(31 downto 0);
data_out_vd:out std_logic


 

 );
end code_rx;

architecture Behavioral of code_rx is

signal state:std_logic_vector(7 downto 0);
signal state1:std_logic_vector(7 downto 0);
type row is array (0 to 127) of std_logic_vector(7 downto 0);

type row1 is array (0 to 31) of std_logic_vector(31 downto 0);

signal data1:row;
signal data2:row;

signal data3:row1;
signal data4:row1;

signal i:integer range 0 to 255;
signal k:integer range 0 to 255;
signal j:integer range 0 to 255;
signal flag:std_logic;
signal count:std_logic_vector(31 downto 0);
signal id:std_logic_vector(31 downto 0);                   --------------
signal z1:std_logic;
signal z2:std_logic;
signal zz:std_logic;


begin




process(clk,rstn)


begin
if(rstn='0')then

state<=X"00";
i<=0;
count<=(others=>'0');
flag<='0';

for w1 in 0 to 31 loop
data3(w1)<=X"00000000";
end loop;

for w2 in 0 to 31 loop
data4(w2)<=X"00000000";
end loop;


elsif(rising_edge(clk))then



case  state is

                                when X"00"=>
                                
                                if(data_vd='1')then
                                    data1(i)<=data_in;
                                     i<=i+1;
                                
                                    
                                    state<=X"01";
                                    
                                    count<=(others=>'0');
                                
                                
                                end if;
                                

                                when X"01"=>
                                
                                  if(data_vd='1')then
                                          if(data_in/=X"0a")then
                                                    data1(i)<=data_in;
                                                     i<=i+1;
                                                
                                                   count<=(others=>'0');
                                           else
                                                   data1(i)<=data_in;
                                                     i<=i+1;
                                                
                                                   count<=(others=>'0');
                                                   state<=X"02";
                                           end if;
                                
                                else
                                        count<=count+1;
                                        if(count>X"f4240")then
                                        state<=X"ff";
                                        i<=0;
                                        k<=0;
                                        end if;
                                
                                
                                end if;
                                
                             when X"02"=>
                             
                             if(i<10)then-------delete_error
                                        state<=X"ff";
                                        i<=0;
                                        k<=0;
                             
                             else
                                 state<=X"03";
                                 id<=id+1;---------------------------------------------------------
                                  k<=0;
                             end if;
                             
                             
                             
                             
                             when X"03"=>
                             
                                if(flag='0')then
                                                 if(k<31)then
                                                 data4(0)<=id;----------------------------------------------------   
                                                 data4(k+1)<=data1(0+k*4)&data1(1+k*4)&data1(2+k*4)&data1(3+k*4);
                                                 
                                                 k<=k+1;
                                                 
                                                 else
                                                 k<=0;
                                                 
                                                 state<=X"04";
                                                 flag<='1';
                                                 end if;
                                
                                
                                
                                else
                                         
                                                 if(k<32)then
                                                    
                                                 data3(0)<=id;---------------------------------------------- 
                                                 data3(k+1)<=data1(0+k*4)&data1(1+k*4)&data1(2+k*4)&data1(3+k*4);
                                                 
                                                 k<=k+1;
                                                 
                                                 else
                                                 
                                                 k<=0;
                                                
                                                 state<=X"04";
                                                 flag<='0';
                                                 
                                                 end if;
                                
                                
                                end if;
                             
                             
                             
                             
                             
                             when X"04"=>
                             
                              state<=X"ff";
                             
                          
                             
                             when X"05"=>
                             
                             
                             
                             
                             
                          when X"ff"=>
                            if(k<128)then
                             data1(k)<=X"00";
                             k<=k+1;
                             else
                             k<=0;
                             state<=X"00";
                             i<=0;
                            end if;
                          
                     
                                when others=>
                               
                                state<=X"00";
                                i<=0;
                                
end case;


end if;
end process;





----------------------------------------------------------------------data_out
 
 
 process(clk,rstn)
begin

                    if(rstn='0')then
                    
                    state1<=X"00";
                    data_out<=(others=>'0');
                    data_out_vd<='0';
                    elsif(rising_edge(clk))then
                    
                    case state1  is
                    
                      when X"00"=>
                      if(zz='1')then
                        state1<=X"01";
                      
                      end if;
                      data_out_vd<='0';
                      j<=0;
                      
                      when X"01"=>
                      if(data_start=data_address)then
                      
                        state1<=X"02";
                      end if;
                      
                      when X"02"=>
                      
                      if(flag='0')then
                      
                                               if(j<32)then
                                                                 data_out_vd<='1';
                                                                 data_out<=data3(j);
                                                                j<=j+1;
                                                                 
                                                                 else
                                                                 data_out_vd<='0';
                                                                j<=0;
                                                                 state1<=X"03";
                                                                 
                                                                 
                                                end if;
                      
                      
                      else
                                                             if(j<32)then
                                                                         data_out_vd<='1';
                                                                         data_out<=data4(j);
                                                                        j<=j+1;
                                                                         
                                                                         else
                                                                         data_out_vd<='0';
                                                                        j<=0;
                                                                         state1<=X"03";
                                                                         
                                                                         
                                                        end if;
                      
                      
                      end if;
                      
                      
                      when X"03"=>
                      
                      
                      state1<=X"00";
                      
                      
                    --  when X"04"=>
                      
                      
                    
                    
                    when others=>
                         state1<=X"00";
                    
                    end case;
                    
                    
                    end if;
 end process;
 

 
 
 process(clk,rstn)
begin

                    if(rstn='0')then
                    
                   
                    zz<='0';
                    elsif(rising_edge(clk))then
                    z1<=data_reg;
                    z2<=z1;
                    zz<= z1 and (not z2);
                    
                    
                    
                    end if;
 end process;
 
 
 
 
  



end Behavioral;
