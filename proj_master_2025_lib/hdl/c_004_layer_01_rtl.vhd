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
      g_layer_index       : integer := 1;
      g_layer_length_cur  : integer := 4;
      g_layer_length_prev : integer := 2;
      g_layer_bias        : t_array_integer := (0,0,0,0);
      g_layer_weights     : t_array2D_integer := ((0,0),(0,0),(0,0),(0,0))
   );
   port( 
      clk           : in  std_logic;
      reset         : in  std_logic;
      enable        : in  std_logic;
      dst_RX        : in  std_logic;
      src_TX        : in  std_logic;
      ready_to_TX   : out std_logic := '0';
      ready_to_RX   : out std_logic := '1';
      layer_in      : in  t_array_data_stdlv(0 to g_layer_length_prev-1);
      layer_out     : out t_array_data_stdlv(0 to g_layer_length_cur-1) := (others=>(others=>'0'))
   );

-- Declarations
end entity c_004_layer_01;

--
architecture rtl of c_004_layer_01 is
  SIGNAL NEX_state, CUR_state : t_stm_layer;
  SIGNAL NEX_node_prev : integer := 0;
  SIGNAL CUR_node_prev : integer := 0;
  
  SIGNAL NEX_ready_to_RX : std_logic := '0';
  SIGNAL NEX_ready_to_TX : std_logic := '0';
  SIGNAL NEX_layer_out   : t_array_data_stdlv(0 to g_layer_length_cur-1) := (others=>(others=>'0'));
  
  --SIGNAL node_idx    : integer := 0;
  SIGNAL CUR_data_in      : t_array_data_signed(0 to g_layer_length_prev-1);
  SIGNAL NEX_data_in      : t_array_data_signed(0 to g_layer_length_prev-1);
  SIGNAL CUR_data_acum    : t_array_data_signed_dw(0 to g_layer_length_cur-1);
  SIGNAL NEX_data_acum    : t_array_data_signed_dw(0 to g_layer_length_cur-1);
  -- CONST  c_WEIGHTS    : t_array_weight_layer := c_A_WEIGHTS(g_layer_index);
begin
  P_STM : process(CUR_state, CUR_node_prev)
  begin
    -- -- default assignments
    -- internal signals
    NEX_state     <= CUR_state;
    NEX_node_prev <= CUR_node_prev;
    
    NEX_data_in   <= CUR_data_in;
    NEX_data_acum <= CUR_data_acum;
    
    -- signals to outputs
    NEX_ready_to_RX <= ready_to_RX;
    NEX_ready_to_TX <= ready_to_TX;
    NEX_layer_out <= layer_out;
    
    case(CUR_state) is
      -- we send our result, until it is accepted
      when IDLE_TX =>
        NEX_ready_to_TX <= '1';
        
        if dst_RX = '1' then
          -- goto reveicer mode
          NEX_ready_to_TX <= '0';
          NEX_state <= IDLE_RX;
        end if;
        
      -- we wait until we receive new data
      when IDLE_RX =>
        if src_TX = '1' then
          NEX_ready_to_RX <= '1'; -- set to 1 during transition
          
          NEX_data_in <= layer_in; -- store input
          NEX_state <= BIAS_SETUP;
        end if;
        
      -- we fill our acummulators with bias value
      when BIAS_SETUP =>
        NEX_ready_to_RX <= '0'; -- reset
        
        -- initialize bias in layer nodes
        LOOP_BIAS : FOR idx_node_cur in 0 to (g_layer_length_cur-1) LOOP
          -- we create first entry:
          -- BIAS * ONE (Fixed Point) - results in double width
          --NEX_data_acum(node_this) <=  c_A_BIAS(g_layer_index, node_this) * c_FP_ONE ;
          NEX_data_acum(idx_node_cur) <= STD_LOGIC_VECTOR( SHIFT_LEFT(TO_SIGNED( g_layer_bias(idx_node_cur), 2*c_DATA_WIDTH), c_DATA_Q) );
        end LOOP;
        
        NEX_state <= ACUM;
        
        -- nodes of PREVIOUS LAYER, which are decremented in ACUM
        NEX_node_prev <= g_layer_length_prev-1;
        
      -- we accumulate the node values times their weights
      when ACUM =>
        -- loop through nodes of THIS LAYER
        LOOP_Node : FOR idx_node_cur in 0 to (g_layer_length_cur-1) LOOP
          -- Data (THIS LAYER node) = Data (THIS LAYER node) + Weight (of PREV LAYER node, relative to THIS LAYER node) * Data (PREV LAYER node)
          -- NEX_data_acum(node_this) <= CUR_data_acum(node_this) + c_A_WEIGHTS(g_layer_index, node_this, CUR_node_prev) * CUR_data_in(CUR_node_prev) ;
          NEX_data_acum(idx_node_cur) <= CUR_data_acum(idx_node_cur) + TO_SIGNED(g_layer_weights( idx_node_cur, CUR_node_prev)) * CUR_data_in(CUR_node_prev) ;
        end LOOP;
        
        -- decrement node of PREVIOUS LAYER
        NEX_node_prev <= CUR_node_prev - 1;
        -- exit if we have reached Zero
        if CUR_node_prev = 0 then
          NEX_state     <= ACT_FUNC;
          NEX_node_prev <= 0;
        end if;
        
      when ACT_FUNC =>
        -- reminder: "CUR_data_acum" has 2x width of "layer_out" !
		    case c_ACT_FUNC is
		      when SIGN =>
		        -- When: Sign Function
		        LOOP_ACT_SIGN : FOR node_this in 0 to (g_layer_length_cur-1) LOOP
		          -- check if the whole slice is Zero
  		          if CUR_data_acum(node_this)(CUR_data_acum'range) = (CUR_data_acum'range => '0') then
  		            -- is zero
    		          NEX_layer_out <= c_FP_ZERO;
    	          elsif CUR_data_acum(node_this)(CUR_data_acum'left) = '1' then
    	            -- is negative
    	            NEX_layer_out <= c_FP_N_ONE;
    	          else
    	            -- ELSE: is positive
    	            NEX_layer_out <= c_FP_P_ONE;
    	          end if;
	           end loop;
	          
		      when RELU =>
		        -- When: ReLu Function
		        if CUR_data_acum(CUR_data_acum'left) = '1' then
	            -- is negative
	            NEX_layer_out <= c_FP_ZERO;
	          else
	            -- ELSE: is positive
	            NEX_layer_out <= CUR_data_acum(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q);
	          end if;
	          
		      when other =>
		        -- When: Identity Function
		        NEX_layer_out <= CUR_data_acum(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q);
        end case;
        NEX_state <= IDLE_TX;
        
      when DONE =>
        -- empty case
        
    end case;
    
  end process;
  
  P_CLK : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- internal signals
        CUR_state <= IDLE_RX; -- default state: try to receive
        CUR_node_prev <= 0;
        
        CUR_data_in   <= (others=>(others=>'0'));
        CUR_data_acum <= (others=>(others=>'0'));
        
        -- outputs
        ready_to_TX <= '0';
        ready_to_RX <= '1';
        layer_out <= (others=>(others=>'0'));
      else
        -- internal signals
        CUR_state     <= NEX_state;
        CUR_node_prev <= NEX_node_prev;
        
        CUR_data_in   <= NEX_data_in;
        CUR_data_acum <= NEX_data_acum;
        
        -- outputs
        ready_to_TX <= NEX_ready_to_RX;
        ready_to_RX <= NEX_ready_to_TX;
        layer_out   <= NEX_layer_out;
      end if;
    end if;
    
  end process;
end architecture rtl;

