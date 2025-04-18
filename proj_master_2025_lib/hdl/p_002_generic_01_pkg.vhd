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
  constant c_DATA_Q     : integer := 8;   -- {$c_DATA_Q}
  
  constant c_FP_INT_MAX : integer := 2**(c_DATA_WIDTH-1) - 1;
  constant c_FP_INT_MIN : integer := -2**(c_DATA_WIDTH-1);
  subtype t_fp_int is integer range c_FP_INT_MIN to c_FP_INT_MAX;
  
  
  type t_array_integer is array(natural range <>) of t_fp_int;
  type t_array2D_integer is array(natural range <>, natural range <>) of t_fp_int;
  
  --constant c_ADDR_WIDTH : integer := 4;  -- {$c_ADDR_WIDTH}
  --constant c_NUM_LAYERS : integer := 4;   -- {$c_NUM_LAYERS}
  --constant c_NUM_NODES_MAX : integer := 8;   -- {$c_NUM_NODES_MAX}
  
--  constant c_FP_ZERO  : signed (c_DATA_WIDTH-1 downto 0) := (others=>'0');
--  constant c_FP_P_ONE : signed (c_DATA_WIDTH-1 downto 0) := (c_DATA_Q => '1', others => '0');
--  constant c_FP_N_ONE : signed (c_DATA_WIDTH-1 downto 0) := ( c_DATA_WIDTH-1 downto c_DATA_Q => (others => '1'), others => '0');
  
  type t_array_data_stdlv is array(natural range <>) of std_logic_vector(c_DATA_WIDTH-1 downto 0);
  type t_array_data_stdlv_dw is array(natural range <>) of std_logic_vector(2*c_DATA_WIDTH-1 downto 0);
  
  type t_array_data_signed is array(natural range <>) of signed(c_DATA_WIDTH-1 downto 0);
  type t_array_data_signed_dw is array(natural range <>) of signed(2*c_DATA_WIDTH-1 downto 0);
  
  --type t_array_layer_size is array(0 to c_NUM_LAYERS-1) of integer;
  --constant c_A_LAYER_SIZE : t_array_layer_size := ( 4,8,8,1 ); -- {$c_A_LAYER_SIZE}
  
  --type t_array_weight_layer is array(0 to c_NUM_NODES_MAX-1, 0 to c_NUM_NODES_MAX-1) of signed;
--  type t_array_weight_all is array(0 to c_NUM_LAYERS-1, 0 to c_NUM_NODES_MAX-1, 0 to c_NUM_NODES_MAX-1) of signed;
--  type t_array_bias_all is array(0 to c_NUM_LAYERS-1, 0 to c_NUM_NODES_MAX-1) of signed;
  
  --constant c_A_WEIGHTS : t_array_weight_all := (
--    ((1,1),(1,1)),
--    ((1,1),(1,1))
--  );constant c_A_WEIGHTS : t_array_weight_all := (
--    ((1,1),(1,1)),
--    ((1,1),(1,1))
--  );
--  constant c_A_BIAS : t_array_bias_all := (
--    (1,1),(1,1)
--  );
--  constant c_A_BIAS : t_array_bias_all := (
--    (1,1),(1,1)
--  );
  
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
  --constant c_ACT_FUNC : t_activation_function := AF_RELU;  -- {$c_ACT_FUNC}
  
  
END p_002_generic_01;
