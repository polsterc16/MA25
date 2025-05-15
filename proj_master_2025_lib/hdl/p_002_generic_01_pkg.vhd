--
-- VHDL Package Header proj_master_2025_lib.p_002_generic_01
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 08:58:51 14.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE p_002_generic_01 IS
  
  constant c_DATA_WIDTH : integer := 16;  -- {$c_DATA_WIDTH}
  constant c_DATA_QF    : integer := 8;   -- {$c_DATA_QF}
  
  constant c_FP_INT_MAX : integer := 2**(c_DATA_WIDTH-1) - 1;
  constant c_FP_INT_MIN : integer := -2**(c_DATA_WIDTH-1);
  subtype t_fp_int is integer range c_FP_INT_MIN to c_FP_INT_MAX;
    
  type t_array_integer is array(natural range <>) of t_fp_int;
  type t_array2D_integer is array(natural range <>, natural range <>) of t_fp_int;
  
  type t_array_data_stdlv is array(natural range <>) of std_logic_vector(c_DATA_WIDTH-1 downto 0);
  type t_array_data_stdlv_dw is array(natural range <>) of std_logic_vector(2*c_DATA_WIDTH-1 downto 0);
  
  type t_array_data_signed is array(natural range <>) of signed(c_DATA_WIDTH-1 downto 0);
  type t_array_data_signed_dw is array(natural range <>) of signed(2*c_DATA_WIDTH-1 downto 0);
    
  type t_stm_layer is (
    RESET_STATE, -- default state to fall back on
    IDLE_TX,  -- we have finished calculation and wait for our output to be received
    IDLE_RX,  -- we are awaiting a valid input
    BIAS_SETUP,  -- we are awaiting a valid input
    MAC,     -- we are calculating the nodes
    ACT_FUNC  -- performing activation function
  );
  
  type t_activation_function is (
    AF_IDENTITY,
    AF_SIGN,
    AF_RELU,
    AF_HARD_SIGMOID
  );
  
END p_002_generic_01;
