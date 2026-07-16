
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

entity io_code is
--generic(
--instruction_1:std_logic_vector(31 downto 0):=X"00000001";--start_1--ack1
--instruction_2:std_logic_vector(31 downto 0):=X"00000002";--start_2--ack1

           

--);
 Port ( 
 clk:in std_logic;
 rstn:in std_logic;



data_start:in std_logic_vector(15 downto 0);

data_reg:in std_logic;
data_address:in std_logic_vector(15 downto 0);
data_in:in std_logic_vector(31 downto 0);


data_reg1:in std_logic;
data_address1:in std_logic_vector(15 downto 0);


data_out_in:out std_logic_vector(31 downto 0);
data_out_out:out std_logic_vector(31 downto 0);

data_out_vd:out std_logic;


data_out_drive:out std_logic_vector(31 downto 0);
data_in_drive:in std_logic_vector(63 downto 0)


 

 );
end io_code;

architecture Behavioral of io_code is

signal state:std_logic_vector(7 downto 0);
signal state1:std_logic_vector(7 downto 0);
--type row is array (0 to 127) of std_logic_vector(7 downto 0);

--type row1 is array (0 to 31) of std_logic_vector(31 downto 0);

--signal data1:row;
--signal data2:row;

--signal data3:row1;
--signal data4:row1;

--signal i:integer range 0 to 255;
--signal k:integer range 0 to 255;
--signal j:integer range 0 to 255;
--signal flag:std_logic;
--signal count:std_logic_vector(31 downto 0);

signal z1:std_logic;
signal z2:std_logic;
signal zz:std_logic;


signal zz1:std_logic;
signal zz2:std_logic;
signal zzz:std_logic;


signal data_mid1:std_logic_vector(31 downto 0);
signal data_mid2:std_logic_vector(31 downto 0);
signal data_mid3:std_logic_vector(31 downto 0);
signal data_mid4:std_logic_vector(31 downto 0);

begin


data_out_drive<=data_mid1;
data_mid2<=data_in_drive(63 downto 32);
data_mid3<=data_in_drive(31 downto 0);
--process(clk,rstn)


--begin
--if(rstn='0')then

--state<=X"00";
--i<=0;
--count<=(others=>'0');
--flag<='0';

--for w1 in 0 to 31 loop
--data3(w1)<=X"00000000";
--end loop;

--for w2 in 0 to 31 loop
--data4(w2)<=X"00000000";
--end loop;


--elsif(rising_edge(clk))then



--case  state is

--                                when X"00"=>
                                
                          
                                

--                                when X"01"=>
                                
                            
                                
--                             when X"02"=>
                             
                       
                             
                             
                             
--                             when X"03"=>
                             
--                                if(flag='0')then
--                                                 if(k<32)then
--                                                 data4(k)<=data1(0+k*4)&data1(1+k*4)&data1(2+k*4)&data1(3+k*4);
                                                 
--                                                 k<=k+1;
                                                 
--                                                 else
--                                                 k<=0;
--                                                 state<=X"04";
--                                                 flag<='1';
--                                                 end if;
                                
                                
                                
--                                else
                                         
--                                                 if(k<32)then
--                                                 data3(k)<=data1(0+k*4)&data1(1+k*4)&data1(2+k*4)&data1(3+k*4);
                                                 
--                                                 k<=k+1;
                                                 
--                                                 else
                                                 
--                                                 k<=0;
--                                                 state<=X"04";
--                                                 flag<='0';
                                                 
--                                                 end if;
                                
                                
--                                end if;
                             
                             
                             
                             
                             
--                             when X"04"=>
                             
--                              state<=X"ff";
                             
                          
                             
--                             when X"05"=>
                             
                             
                             
                             
                             
--                          when X"ff"=>
--                            if(k<128)then
--                             data1(k)<=X"00";
--                             k<=k+1;
--                             else
--                             k<=0;
--                             state<=X"00";
--                             i<=0;
--                            end if;
                          
                     
--                                when others=>
                               
--                                state<=X"00";
--                                i<=0;
                                
--end case;


--end if;
--end process;
---------------------------------------------------------data_in
 process(clk,rstn)
begin

                    if(rstn='0')then
                    
                    state<=X"00";
             
                  
                   data_out_in<=X"00000000";
              
                    
                    elsif(rising_edge(clk))then
                    
                    case state  is
                    
                      when X"00"=>
                      
                         if(zzz='1')then
                        state<=X"01";
                      
                      end if;
                     
                    
                    
                      
                      when X"01"=>
                      
                      
                        if(data_address1=X"0003")then
                        
                        state<=X"02";
                      end if;
                      
                      
                    
                      
                      when X"02"=>
                      
                        state<=X"03";
                    data_out_in<=data_mid3;
                     
                      
                   when X"03"=>
                     state<=X"04";
                    data_out_in<=data_mid2;
                   
                   
                   
                   
                   when X"04"=>
                   
                    state<=X"05";
                    data_out_in<=X"00000000";
                   
                   
                   
                    when X"05"=>
                    
                     state<=X"00";
                   
                    
                    
                    when others=>
                         state<=X"00";
                    
                    end case;
                    
                    
                    end if;
 end process;
 



----------------------------------------------------------------------data_out
 
 
 process(clk,rstn)
begin

                    if(rstn='0')then
                    
                    state1<=X"00";
                    data_mid1<=X"00000000";
                    data_out_vd<='0';
                --    data_out_in<=X"00000000";
                    data_out_out<=X"00000000";
                    
                    elsif(rising_edge(clk))then
                    
                    case state1  is
                    
                      when X"00"=>
                      if(zz='1')then
                        state1<=X"01";
                      
                      end if;
                      data_out_vd<='0';
                    
                      
                      when X"01"=>
                      if(data_address=X"0001")then
                        data_mid1<=data_in;
                        state1<=X"02";
                      end if;
                      
                      when X"02"=>
                      data_mid4<=data_in;
                     data_out_vd<='1';
                     data_out_out<=data_mid1;
                      state1<=X"03";
                      
                      when X"03"=>
                      
                      state1<=X"04";
                      data_out_out<=data_mid1;
                      
                      
                      
                    when X"04"=>
                    
                       state1<=X"05";
                   --   data_out_in<=data_mid2;
                    
                    when X"05"=>
                    state1<=X"06";
                --      data_out_in<=data_mid3;
                    
                    
                    
                    when X"06"=>
                      
                      state1<=X"07";
                 --     data_out_in<=X"00000000";
                      
                    
                    when X"07"=>
                    data_out_vd<='0';
                     state1<=X"00";
                    
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
 
 
 
 
 
  process(clk,rstn)
begin

                    if(rstn='0')then
                    
                   
                    zzz<='0';
                    elsif(rising_edge(clk))then
                    zz1<=data_reg1;
                    zz2<=zz1;
                    zzz<= zz1 and (not zz2);
                    
                    
                    
                    end if;
 end process;
 
 
 
  



end Behavioral;
