--
-- VHDL Architecture proj_master_2025_lib.c_001_binary_counter.rtl
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 08:57:36 11.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
--USE ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library proj_master_2025_lib;
use proj_master_2025_lib.p_001_test_package.all;

entity c_001_binary_counter is
   generic( 
      nbits_g : integer := 8
   );
   port( 
      clk    : in     std_logic;
      reset  : in     std_logic;
      enable : in     std_logic;
      dir    : in     std_logic;
      cnt    : out    std_logic_vector (nbits_g-1 downto 0) := (others => '0')
   );

-- Declarations

end c_001_binary_counter ;

--
architecture rtl of c_001_binary_counter is
  -- define internal signals here
  signal counter: signed(cnt'range) := (others => '0');
  
begin
  -- universal synchronous up/down counter with
  -- synchronous reset and count enable
  process(clk)
    variable v_count : signed(cnt'range) := (others => '0');
  begin
    if rising_edge(clk) then
      v_count := counter;
      
      if reset = '1' then
        --v_count := (others => '0');
        v_count := TO_SIGNED(c_START, nbits_g);
      elsif enable = '1' then
        if dir = '1' then
          v_count := counter+1;
        else
          v_count := counter-1;
        end if;
        
      end if;
      counter <= v_count;
      cnt <= std_logic_vector(counter);
    end if;
  end process;
  
  -- connect internal signal to output port
  
end architecture rtl;

