--
-- VHDL Package Header proj_master_2025_lib.p_001_test_package
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 10:34:23 11.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE p_001_test_package IS
  type t_array_001 is array(0 to 7) of integer;
  
  constant c_PIXELS : integer := 65536;
  constant c_START : integer := 7;
  
  constant c_array : t_array_001 := (0,1,2,3,4,5,6,7);
END p_001_test_package;

