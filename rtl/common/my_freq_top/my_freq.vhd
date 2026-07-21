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

entity my_freq is
 Port ( 
         clk:in std_logic;
         out_10Hz:out std_logic   
  );
end my_freq;

architecture Behavioral of my_freq is

signal jishu2:integer range 0 to 50000000;

begin

process(clk)
begin
if(rising_edge(clk))then
 if(jishu2<1000) then---------10Hz
 jishu2<=jishu2+1;
 out_10Hz<='0';
 elsif(jishu2<2000)then
jishu2<=jishu2+1;
 out_10Hz<='1';
else
 jishu2<=0;
 out_10Hz<='0';
end if;
end if;
end process;
end Behavioral;

