----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/03/11 08:44:32
-- Design Name: 
-- Module Name: iic_rom - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity iic_rom is
 Port (
 clk:in std_logic;

 reset:in std_logic;
 scl:out std_logic;
 sda:inout std_logic;
 address_L:in std_logic_vector(7 downto 0);
 address_U:in std_logic_vector(7 downto 0);
 write_en:in std_logic;
read_en:in std_logic;
datain :in std_logic_vector(7 downto 0);
dataout:out std_logic_vector(7 downto 0);
iic_r_end:out std_logic;
iic_w_end:out std_logic
  );
end iic_rom;

architecture Behavioral of iic_rom is

signal  state             :  std_logic_vector(7 downto 0);
constant data1             :  std_logic_vector(7 DOWNTO 0):=X"A0";--write
constant data2             :  std_logic_vector(7 DOWNTO 0):=X"A1";--read

signal zz:std_logic;
signal z1:std_logic;
signal z2:std_logic;
signal jishu:integer range 0 to 1023;
signal sck:std_logic;

signal zzz:std_logic;
signal zz1:std_logic;
signal zz2:std_logic;
signal iic_r_end_1:std_logic;
signal iic_w_end_1:std_logic;
signal dataout1:std_logic_vector(7 downto 0);

attribute MARK_DEBUG : string;
attribute MARK_DEBUG of state: signal is "TRUE";

begin
dataout<=dataout1;
iic_r_end<=iic_r_end_1;
iic_w_end<=iic_w_end_1;
process(reset,clk)
begin
if(reset='0')then

scl<='1';
sda<='1';
state<=X"00";
jishu<=0;
dataout1<=X"00";

elsif(rising_edge(clk))then

        case state is
        
         when X"00"=>
         if(zz='1')then 
         iic_r_end_1<='0';
         iic_w_end_1<='0';
         state<=X"01";
         sda<='1';
         scl<='1';
        
         
          elsif(zzz='1')then 
         iic_r_end_1<='0';
         iic_w_end_1<='0';
         state<=X"07";
         sda<='1';
         scl<='1';
         else
         iic_r_end_1<='0';
         iic_w_end_1<='0';
         sda<='1';
         end if;
         jishu<=0;
         
        when X"01"=> ----write_start
         
         
        
          
         sda<='0';
         scl<='1';
         state<=X"02";
         
         when X"02"=>--data1
           
           if(jishu=0)then
           sda<=data1(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=data1(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=data1(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=data1(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=data1(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=data1(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=data1(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=data1(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"03";
           
           end if;
         
         when X"03"=>----address_u
         
            if(jishu=0)then
           sda<=address_U(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=address_U(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=address_U(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=address_U(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=address_U(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=address_U(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=address_U(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=address_U(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"04";
           
           end if;
         
  when X"04"=>-------address_L
                    if(jishu=0)then
           sda<=address_L(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=address_L(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=address_L(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=address_L(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=address_L(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=address_L(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=address_L(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=address_L(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"05";
           
           end if;
  
  when X"05"=>------datain
  
                       if(jishu=0)then
           sda<=datain(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=datain(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=datain(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=datain(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=datain(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=datain(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=datain(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=datain(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"06";
           
           end if;
  
  when X"06"=>-----stop
  
                  if(jishu=0)then
           sda<='0';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
            sda<='0';
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           iic_w_end_1<='1';
            sda<='1';
            state<=X"00";
            
          end  if;
  
  
  
    when X"07"=>----read  start
    
          sda<='0';
         scl<='1';
         state<=X"10";
         
     when X"08"=>
     
           if(jishu=0)then
           sda<=data2(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=data2(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=data2(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=data2(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=data2(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=data2(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=data2(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=data2(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"09";
           
           end if;
         
    when X"09"=>----read_data
    
           if(jishu=0)then
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
            dataout1(7)<=sda;
           jishu<=jishu+1;
           elsif(jishu=2)then
           
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
            dataout1(6)<=sda;
           jishu<=jishu+1;
           elsif(jishu=4)then
           
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
            dataout1(5)<=sda;
           jishu<=jishu+1;
           elsif(jishu=6)then
           
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
            dataout1(4)<=sda;
           jishu<=jishu+1;
           elsif(jishu=8)then
           
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
            dataout1(3)<=sda;
           jishu<=jishu+1;
           elsif(jishu=10)then
           
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
            dataout1(2)<=sda;
           jishu<=jishu+1;
           elsif(jishu=12)then
          
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
            dataout1(1)<=sda;
           jishu<=jishu+1;
           elsif(jishu=14)then
           
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
            dataout1(0)<=sda;
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='0';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           iic_r_end_1<='1';
           state<=X"00";
           end if;
   
  
    when X"10"=>
         
             if(jishu=0)then
           sda<=data1(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=data1(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=data1(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=data1(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=data1(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=data1(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=data1(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=data1(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"11";
           
           end if;
    
         when X"11"=>
            
               if(jishu=0)then
           sda<=address_U(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=address_U(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=address_U(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=address_U(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=address_U(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=address_U(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=address_U(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=address_U(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"12";
           
           end if;
         
         when X"12"=>
         
                     if(jishu=0)then
           sda<=address_L(7);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=2)then
           sda<=address_L(6);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=3)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=4)then
           sda<=address_L(5);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=5)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=6)then
           sda<=address_L(4);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=7)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=8)then
           sda<=address_L(3);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=9)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=10)then
           sda<=address_L(2);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=11)then
          
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=12)then
           sda<=address_L(1);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=13)then
        
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=14)then
           sda<=address_L(0);
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=15)then
           
            scl<='1';
           jishu<=jishu+1;
           elsif(jishu=16)then
           sda<='Z';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=17)then
           
            scl<='1';
           jishu<=0;
           state<=X"13";
           
           end if;
           
           
         when X"13"=>
         
                        if(jishu=0)then
           sda<='1';
            scl<='0';
           jishu<=jishu+1;
           elsif(jishu=1)then
           
            scl<='1';
           jishu<=0;
           state<=X"14";
           
           
         end if;
         
         
          when X"14"=>----read  start
    
          sda<='0';
         scl<='1';
         state<=X"08";
         
         
         when others=> 
                        scl<='1';
                        sda<='1';
                        state<=X"00";
                        jishu<=0;
         
         end case;

end if;
end process;



process(reset,clk)

begin
if(reset='0')then
 zz<='0';
elsif(rising_edge(clk))then
 z1<=write_en;
 z2<=z1;
         
 zz<=z1 and (not z2);

end if;
end process;


process(reset,clk)

begin
if(reset='0')then
 zzz<='0';
elsif(rising_edge(clk))then
 zz1<=read_en;
 zz2<=zz1;
         
 zzz<=zz1 and (not zz2);

end if;
end process;




end Behavioral;
