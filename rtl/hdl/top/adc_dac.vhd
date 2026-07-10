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

entity adc_dac is
  Port ( 
             clk10m:in std_logic;--shi zhong
             locked:in std_logic;--fu wei didianpingyouxiao
             -- locked1:out std_logic;
              
             -- load:out std_logic;
              --clr:out std_logic;
             --  dac_sclk:out std_logic;
             --  dac_din:out std_logic;
               --syn:out std_logic;
           
             sclk:out std_logic;
             sdin1:out std_logic;
             sdout1:in std_logic;
             cs1:out std_logic;    --biaozhiwei
             
             ch_1:out std_logic_vector(12 downto 0);
             ch_2:out std_logic_vector(12 downto 0)
  
  
  );
end adc_dac;

architecture Behavioral of adc_dac is

--component clk_wiz_0 
-- port(
  
--        clk_out1:out std_logic;
  
--        locked:out std_logic;

--        clk_in1_p:in std_logic;
--        clk_in1_n:in std_logic
-- );
--end component;

--signal clk10m:std_logic;
--signal locked:std_logic;

constant s0             :  std_logic_vector(7 DOWNTO 0):="00000000";
constant s1              :  std_logic_vector(7 DOWNTO 0):="00000001";  
constant s2               :  std_logic_vector(7 DOWNTO 0):="00000010";
constant s3               :  std_logic_vector(7 DOWNTO 0):="00000011";
constant s4              :  std_logic_vector(7 DOWNTO 0):="00000100";
constant s5              :  std_logic_vector(7 DOWNTO 0):="00000101";
constant s6              :  std_logic_vector(7 DOWNTO 0):="00000110";



signal  state             :  std_logic_vector(7 downto 0);
attribute MARK_DEBUG : string;
attribute MARK_DEBUG of state: signal is "TRUE";

signal sdin: std_logic;
signal         sdout: std_logic;
  signal       cs: std_logic;
  
  signal jishu:integer range 0 to 1000000;
  signal data1:std_logic_vector(15 downto 0);
signal data2:std_logic_vector(15 downto 0);
signal data3:std_logic_vector(15 downto 0);
signal ch0:std_logic_vector(12 downto 0);
signal ch1:std_logic_vector(12 downto 0);
signal d1:std_logic;
 signal jishu1:integer range 0 to 100000;
 
 
 
 signal  state1             :  std_logic_vector(7 downto 0);



--constant s00             :  std_logic_vector(7 DOWNTO 0):="00000000";
--constant s11              :  std_logic_vector(7 DOWNTO 0):="00000001";  
--constant s22               :  std_logic_vector(7 DOWNTO 0):="00000010";
--constant s33               :  std_logic_vector(7 DOWNTO 0):="00000011";
--constant s44              :  std_logic_vector(7 DOWNTO 0):="00000100";
--constant s55              :  std_logic_vector(7 DOWNTO 0):="00000101";
--constant s66              :  std_logic_vector(7 DOWNTO 0):="00000110";
 
  signal count:integer range 0 to 100000;
  signal dac_data1:std_logic_vector(23 downto 0);
  signal dac_data2:std_logic_vector(23 downto 0);
    signal dac_data3:std_logic_vector(23 downto 0);
    signal dac_data4:std_logic_vector(23 downto 0);
  signal dac_data5:std_logic_vector(23 downto 0);
  signal dac_data6:std_logic_vector(11 downto 0);
  signal dac_data7:std_logic_vector(23 downto 0);
  signal dac_data8:std_logic_vector(23 downto 0);

begin


--locked1<=locked;

sdin1<=sdin;
cs1<=cs;
  
sdout<=sdout1;
sclk<=clk10m;
--dac_sclk<=clk10m;

--clr<='1';
--load<='0';
--myclk: clk_wiz_0 
-- port map(
  
--        clk_out1=>clk10m,
  
--        locked=>locked,

--        clk_in1_p=>clk_p,
--        clk_in1_n=>clk_n
-- );


process(locked,clk10m)
begin
if(locked='0')then
       --  sclk<='1';
         sdin<='0';
         
         cs<='1';
 jishu<=0;
 -- data1<="1011100110000000";------range
  data1<="1010000000000000";------range+-10V
  data3<="1000010000101000";------control
state<=s0;
elsif(rising_edge(clk10m))then

        case state is
        
         when s0=>
                     if(jishu<10000)then
                       jishu<=jishu+1;
                     else
                       jishu<=0;
                       state<=s1;
                     end if; 
         when s1=>  
                       if(jishu<16)then
                         cs<='0';
                         sdin<=data1(15-jishu);
                 --    data2(15-jishu)<=sdout;
                        jishu<=jishu+1;
                      elsif(jishu<50)then
                        cs<='1';
                        jishu<=jishu+1;
                        sdin<='0';
                     else
                       cs<='1';
                        state<=s2;
                        jishu<=0;
                        sdin<='0';
                     end if; 
         when s2=>
                     if(jishu<16)then
                     cs<='0';
                     sdin<=data3(15-jishu);
                   --  data2(15-jishu)<=sdout;
                      jishu<=jishu+1;
                     elsif(jishu<50)then
                      cs<='1';
                     jishu<=jishu+1;
                      
                      sdin<='0';
                     else
                     cs<='1';
                     state<=s3;
                      jishu<=0;
                      sdin<='0';
                     end if;
         when s3=>
                       if(jishu<16)then
                         cs<='0';
                        d1<='0';
                    -- data2(15-jishu)<=sdout;
                      jishu<=jishu+1;
                     elsif(jishu<50)then
                      cs<='1';
                     jishu<=jishu+1;
                      d1<='1';
--                          if(data2(13)='0')then
--                         ch0<=data2(11 downto 0);
--                         else
--                         ch1<=data2(11 downto 0);
--                         end if;
                              sdin<='0';
                             else
                             cs<='1';
                             d1<='0';
                              jishu<=0;
                              sdin<='0';
                             end if;
         when others=>  state<=s0;
                            --   sclk<='1';
                                 sdin<='0';
                                 data1<="1011100110000000";------range
                                 data3<="1000010000101000";------control
                                 cs<='1';
         
         end case;

end if;
end process;
process(cs,clk10m)
begin
if(cs='1')then
          if(data2(13)='0')then
          ch0<=data2(12 downto 0);
          else
          ch1<=data2(12 downto 0);
          end if;
 jishu1<=0;
elsif(falling_edge(clk10m))then
  if(cs='0')then
          data2(15-jishu1)<=sdout;
          jishu1<=jishu1+1;
         
  end if;

end if;
end process;

 ch_1<=ch0;
 ch_2<=ch1;

----------------------------------------------------------------------------DAC

--process(locked,clk10m)
--begin
--if(locked='0')then
--count<=0;
--syn<='1';
--dac_din<='0';
--dac_data1<="000100000000001010100101";---power
--dac_data2<="000001000000000000000000";
--dac_data3<="000001001111111111110000";
--dac_data4<="000011000000000000000100";----range
--dac_data5<="000110000000000000000000";----control
--dac_data6<=(others=>'0');
--state1<=s00;
--elsif(rising_edge(clk10m))then

--        case state1 is
        
--         when s00=>
--         if(count<1000)then
--         count<=count+1;
         
--         else
--         count<=0;
--         state1<=s11;
--         end if;
       
         
--         syn<='1';
         
--         when s11=>
         
--          if(count<24)then
--         syn<='0';
--         dac_din<=dac_data1(23-count);
    
--          count<=count+1;
--          elsif(count<100)then
--            syn<='1';
--         count<=count+1;
          
          
--         else
         
--         state1<=s22;
--          count<=0;
          
--         end if;
         
         
         
         
--        when s22=> 
         
         
--          if(count<24)then
--         syn<='0';
--         dac_din<=dac_data4(23-count);
    
--          count<=count+1;
--          elsif(count<100)then
--            syn<='1';
--         count<=count+1;
          
          
--         else
         
--         state1<=s33;
--          count<=0;
          
--         end if;
         
         
      
        
         
--         when s33=>
         
         
         
----           if(count<50)then
----         count<=count+1;
         
----         else
----         count<=0;
----         state1<=s44;
----         end if;
       
         
----         syn<='1';
         
         
--               if(count<24)then
--         syn<='0';
--         dac_din<=dac_data5(23-count);
    
--          count<=count+1;
--          elsif(count<100)then
--            syn<='1';
--         count<=count+1;
          
          
--         else
         
--         state1<=s44;
--          count<=0;
          
--         end if;
      
        
--         when s44=>
   
         
--          if(count<24)then
--         syn<='0';
----         dac_din<=dac_data2(23-count);
--       dac_din<=dac_data7(23-count);
--       dac_data7<="00000000" &ch0(12 downto 1)&"0000";
--          count<=count+1;
----          elsif(count<4000)then
--elsif(count<30)then
--            syn<='1';
--         count<=count+1;
          
          
--         else
         
--         state1<=s55;
--          count<=0;
--          dac_data6<=dac_data6+1;
--         end if;
         
         
--         when s55=>
         
--           if(count<24)then
--         syn<='0';
----         dac_din<=dac_data3(23-count);
--       dac_din<=dac_data8(23-count);
--       dac_data8<="00000010" &ch1(12 downto 1)&"0000";
--          count<=count+1;
----          elsif(count<4000)then
--elsif(count<30)then
--            syn<='1';
--         count<=count+1;
          
          
--         else
         
--         state1<=s44;
--          count<=0;
--          dac_data6<=dac_data6+1;
--         end if;
         
         
         
         
--         when others=>state1<=s00;
         
--         end case;

--end if;
--end process;
end Behavioral;
