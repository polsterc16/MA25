--
-- VHDL Architecture proj_master_2025_lib.c_004_layer_01.rtl
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 08:52:41 14.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library proj_master_2025_lib;
use proj_master_2025_lib.p_002_generic_01.all;

entity c_004_layer_01 is
   generic( 
      g_layer_index : integer := 1
   );
   port( 
      clk           : in  std_logic;
      reset         : in  std_logic;
      enable        : in  std_logic;
      dst_rx        : in  std_logic;
      src_tx        : in  std_logic;
      ready_to_tx   : out std_logic := '0';
      ready_to_rx   : out std_logic := '1';
      layer_in      : in  t_array_data(0 to c_A_LAYER_SIZE(g_layer_index)-1);
      layer_out     : out t_array_data(0 to c_A_LAYER_SIZE(g_layer_index+1)-1) := (others=>(others=>'0'))
   );

-- Declarations
end entity c_004_layer_01;

--
architecture rtl of c_004_layer_01 is
  SIGNAL next_state, current_state : t_stm_layer;
  SIGNAL next_node_prev  : integer := 0;
  SIGNAL current_node_prev : integer := 0;
  
  --SIGNAL node_idx    : integer := 0;
  SIGNAL data_in      : t_array_data(0 to c_A_LAYER_SIZE(g_layer_index-1)-1);
  SIGNAL data_acum    : t_array_data_dw(0 to c_A_LAYER_SIZE(g_layer_index)-1);
  -- CONST  c_WEIGHTS    : t_array_weight_layer := c_A_WEIGHTS(g_layer_index);
begin
  P_STM : process(current_state, current_node_prev)
  begin
    -- default assignments
    ready_to_rx <= '0';
    
    case(current_state) is
      -- we send our result, until it is accepted
      when IDLE_TX =>
        ready_to_tx <= '1';
        
        if dst_rx = '1' then
          -- goto reveicer mode
          ready_to_tx <= '0';
          next_state <= IDLE_RX;
        end if;
        
      -- we wait until we receive new data
      when IDLE_RX =>
        if src_tx = '1' then
          ready_to_rx <= '1'; -- set to 1 during transition
          
          data_in <= layer_in; -- store input
          next_state <= BIAS_SETUP;
        end if;
        
      -- we fill our acummulators with bias value
      when BIAS_SETUP =>
        -- initialize bias in layer nodes
        LOOP_BIAS : FOR node_idx in 0 to (c_A_LAYER_SIZE(g_layer_index)-1) LOOP
          -- we create first entry:
          -- BIAS times ONE - results in double width
          data_acum(node_idx) <=  c_A_BIAS(g_layer_index, node_idx) * c_FP_ONE ;
        end LOOP;
        next_state <= ACUM;
        -- nodes of PREVIOUS LAYER, which are decremented in ACUM
        next_node_prev <= c_A_LAYER_SIZE(g_layer_index-1)-1;
        
      -- we accumulate the node values times their weights
      when ACUM =>
        -- loop through nodes of THIS LAYER
        LOOP_Node : FOR node_this in 0 to (c_A_LAYER_SIZE(g_layer_index)-1) LOOP
          -- Data (THIS LAYER node) = Data (THIS LAYER node) + Weight (PREV LAYER node, relative to THIS LAYER node) * Data (PREV LAYER node)
          data_acum(node_this) <= data_acum(node_this) + c_A_WEIGHTS(g_layer_index, node_this,current_node_prev) * data_in(current_node_prev) ;
        end LOOP;
        
        -- decrement node of PREVIOUS LAYER
        next_node_prev <= current_node_prev - 1;
        -- exit if we have reached Zero
        if next_node_prev = 0 then
          next_state <= ACT_FUNC;
        end if;
        
      when ACT_FUNC =>
        
      when DONE =>
        
    end case;
    
  end process;
  
  P_CLK : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        current_state <= IDLE_RX;
        current_node_prev <= 0;
        next_node_prev <= 0;
        
        
        ready_to_tx <= '0';
        ready_to_rx <= '1';
        data_in <= (others=>(others=>'0'));
        data_acum <= (others=>(others=>'0'));
        layer_out <= (others=>(others=>'0'));
      else
        current_state <= next_state;
        current_node_prev <= next_node_prev;
      end if;
    end if;
    
  end process;
end architecture rtl;

