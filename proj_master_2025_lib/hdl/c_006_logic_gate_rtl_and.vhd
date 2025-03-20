--
-- VHDL Architecture proj_master_2025_lib.c_006_logic_gate.rtl_and
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 11:36:29 20.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity c_006_logic_gate is
   port( 
      in1  : in     std_logic;
      in2  : in     std_logic;
      out1 : out    std_logic
   );
end entity c_006_logic_gate;

--
architecture rtl_and of c_006_logic_gate is
begin
  out1 <= in1 and in2;
end architecture rtl_and;

architecture rtl_or of c_006_logic_gate is
begin
  out1 <= in1 or in2;
end architecture rtl_or;

