--
-- VHDL Architecture proj_master_2025_lib.c_002_ROM_generic.rtl
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 10:26:42 11.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
library work;
use work.p_001_test_package.all;

entity c_002_ROM_generic is
  port( 
    clk  : in     std_logic;
    addr : in     std_logic_vector (4-1 downto 0)  := (others => '0');
    data : out    std_logic_vector (16-1 downto 0) := (others => '0')
  );
end entity c_002_ROM_generic;

--
architecture rtl of c_002_ROM_generic is
begin
  PROCESS_01 : process(clk)
  variable v_var : integer;
  begin
    v_var := c_PIXELS;
  end process;
end architecture rtl;

