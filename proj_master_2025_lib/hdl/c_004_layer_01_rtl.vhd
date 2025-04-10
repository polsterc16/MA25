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
      g_layer_length_cur  : integer               := 4;
      g_layer_length_prev : integer               := 2;
      g_layer_bias        : t_array_integer       := (0,0,0,0);
      g_layer_weights     : t_array2D_integer     := ((0,0),(0,0),(0,0),(0,0));
      g_act_func          : t_activation_function := AF_RELU
   );
   port( 
      clk         : in     std_logic;
      reset       : in     std_logic;
      --enable      : in     std_logic;
      dst_RX      : in     std_logic;
      src_TX      : in     std_logic;
      ready_to_TX : out    std_logic;
      ack_RX      : out    std_logic;
      layer_in    : in     t_array_data_stdlv (0 to g_layer_length_prev-1);
      layer_out   : out    t_array_data_stdlv (0 to g_layer_length_cur-1)
   );

-- Declarations

end c_004_layer_01 ;

--
architecture rtl of c_004_layer_01 is
  SIGNAL NEX_state, CUR_state : t_stm_layer;
  SIGNAL NEX_node_prev : integer range -1 to g_layer_length_prev-1 := 0;
  SIGNAL CUR_node_prev : integer range -1 to g_layer_length_prev-1 := 0;
  
  SIGNAL NEX_ack_RX : std_logic := '0';
  SIGNAL NEX_ready_to_TX : std_logic := '0';
  SIGNAL NEX_layer_out   : t_array_data_stdlv(0 to g_layer_length_cur-1) := (others=>(others=>'0'));
  
  SIGNAL CUR_data_in    : t_array_data_signed(0 to g_layer_length_prev-1);
  SIGNAL NEX_data_in    : t_array_data_signed(0 to g_layer_length_prev-1);
  SIGNAL CUR_data_accum  : t_array_data_signed_dw(0 to g_layer_length_cur-1);
  SIGNAL NEX_data_accum  : t_array_data_signed_dw(0 to g_layer_length_cur-1);
  
--  CONSTANT c_ACT_FUNC   : t_activation_function := g_act_func;
  CONSTANT c_pos_one : STD_LOGIC_VECTOR := STD_LOGIC_VECTOR( SHIFT_LEFT(TO_SIGNED(  1, c_DATA_WIDTH), c_DATA_Q) );
  CONSTANT c_neg_one : STD_LOGIC_VECTOR := STD_LOGIC_VECTOR( SHIFT_LEFT(TO_SIGNED( -1, c_DATA_WIDTH), c_DATA_Q) );
  
  CONSTANT c_s_dw_pos_3     : SIGNED :=  SHIFT_LEFT(TO_SIGNED(  3, 2*c_DATA_WIDTH), 2*c_DATA_Q);
  CONSTANT c_s_dw_neg_3     : SIGNED :=  SHIFT_LEFT(TO_SIGNED( -3, 2*c_DATA_WIDTH), 2*c_DATA_Q);
  CONSTANT c_s_pos_half  : SIGNED :=  TO_SIGNED( (2**(c_DATA_Q))/2, c_DATA_WIDTH );
  CONSTANT c_s_pos_sixth : SIGNED :=  TO_SIGNED( (2**(c_DATA_Q))/6, c_DATA_WIDTH );
  
begin
  P_STM : process(CUR_state, CUR_node_prev, src_TX, CUR_data_accum, dst_RX, CUR_data_in, ack_RX, ready_to_TX, layer_out, layer_in)
    VARIABLE v_dw_AF_temp1 : SIGNED (c_DATA_WIDTH-1 downto 0);
    VARIABLE v_dw_AF_temp2 : SIGNED (2*c_DATA_WIDTH-1 downto 0);
  
  begin
    -- -- default assignments
    -- internal signals
    NEX_state     <= CUR_state;
    NEX_node_prev <= CUR_node_prev;
    
    NEX_data_in   <= CUR_data_in;
    NEX_data_accum <= CUR_data_accum;
    
    -- signals to outputs
    NEX_ack_RX <= ack_RX;
    NEX_ready_to_TX <= ready_to_TX;
    NEX_layer_out <= layer_out;
    
    case(CUR_state) is
      -- Default reset state
      when RESET_STATE =>
        -- always try to go to RX mode
        NEX_state <= IDLE_RX;
        
      -- we send our result, until it is accepted
      when IDLE_TX =>
        
        if dst_RX = '1' then
          -- goto reveicer mode
          NEX_ready_to_TX <= '0';
          NEX_state <= IDLE_RX;
        end if;
        
      -- we wait until we receive new data
      when IDLE_RX =>
        if src_TX = '1' then
          NEX_ack_RX <= '1'; -- set to 1 during transition
          
          --NEX_data_in <= layer_in; -- store input
          for idx in layer_in'RANGE loop
            NEX_data_in(idx) <= SIGNED(layer_in(idx));
          end loop;
          
          NEX_state <= BIAS_SETUP;
        end if;
        
      -- we fill our accummulators with bias value
      when BIAS_SETUP =>
        NEX_ack_RX <= '0'; -- reset
        
        -- initialize bias in layer nodes
        LOOP_BIAS : FOR idx_node_cur in 0 to (g_layer_length_cur-1) LOOP
          -- we create first entry:
          -- BIAS * ONE (Fixed Point) - results in double width
          --NEX_data_accum(node_this) <=  c_A_BIAS(g_layer_index, node_this) * c_FP_ONE ;
          NEX_data_accum(idx_node_cur) <=  SHIFT_LEFT(TO_SIGNED( g_layer_bias(idx_node_cur), 2*c_DATA_WIDTH), c_DATA_Q);
        end LOOP;
        
        NEX_state <= MAC;
        
        -- nodes of PREVIOUS LAYER, which are decremented in MAC
        NEX_node_prev <= g_layer_length_prev-1;
        
      -- we accumulate the node values times their weights
      when MAC =>
        -- loop through nodes of THIS LAYER
        LOOP_Node : FOR idx_node_cur in 0 to (g_layer_length_cur-1) LOOP
          -- Data (THIS LAYER node) = Data (THIS LAYER node) + Weight (of PREV LAYER node, relative to THIS LAYER node) * Data (PREV LAYER node)
          -- NEX_data_accum(node_this) <= CUR_data_accum(node_this) + c_A_WEIGHTS(g_layer_index, node_this, CUR_node_prev) * CUR_data_in(CUR_node_prev) ;
          NEX_data_accum(idx_node_cur) <= CUR_data_accum(idx_node_cur) + TO_SIGNED(g_layer_weights( idx_node_cur, CUR_node_prev), c_DATA_WIDTH) * CUR_data_in(CUR_node_prev) ;
        end LOOP;
        
        -- decrement node of PREVIOUS LAYER
        NEX_node_prev <= CUR_node_prev - 1;
        -- exit if we have reached Zero
        if CUR_node_prev = 0 then
          NEX_state     <= ACT_FUNC;
          NEX_node_prev <= 0;
        end if;
        
      when ACT_FUNC =>
        -- reminder: "CUR_data_accum" has 2x width of "layer_out" !
        case g_act_func is
          when AF_SIGN =>
            -- When: Sign Function
            LOOP_AF_SIGN : FOR idx_node_this in 0 to (g_layer_length_cur-1) LOOP
              -- check if the whole slice is Zero
              if CUR_data_accum(idx_node_this)(CUR_data_accum(idx_node_this)'RANGE) = (CUR_data_accum(idx_node_this)'range => '0') then
                -- is zero
                NEX_layer_out(idx_node_this) <= (others => '0');
              elsif CUR_data_accum(idx_node_this)(CUR_data_accum(idx_node_this)'HIGH) = '1' then
                -- is negative
                --NEX_layer_out(idx_node_this) <= STD_LOGIC_VECTOR( SHIFT_LEFT(TO_SIGNED( -1, 2*c_DATA_WIDTH), c_DATA_Q) );
                NEX_layer_out(idx_node_this) <= c_neg_one;
              else
                -- ELSE: is positive
                NEX_layer_out(idx_node_this) <= c_pos_one;
              end if;
            end loop;

          when AF_RELU =>
            -- When: ReLu Function
            LOOP_AF_RELU : FOR idx_node_this in 0 to (g_layer_length_cur-1) LOOP
              if CUR_data_accum(idx_node_this)(CUR_data_accum(idx_node_this)'HIGH) = '1' then
                -- is negative
                NEX_layer_out(idx_node_this) <= (others => '0');
              else
                -- ELSE: is positive
                NEX_layer_out(idx_node_this) <= STD_LOGIC_VECTOR( CUR_data_accum(idx_node_this)(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q) );
              end if;
            end loop;

          when AF_HARD_SIGMOID =>
            -- When: hard sigmoid Function
            -- https://keras.io/api/layers/activations/#hardsigmoid-function
            -- 0 if if x <= -3
            -- 1 if x >= 3
            -- (x/6) + 0.5 if -3 < x < 3
            
            LOOP_AF_HARD_SIGMOID : FOR idx_node_this in 0 to (g_layer_length_cur-1) LOOP
              if CUR_data_accum(idx_node_this) < c_s_dw_neg_3 then
                -- IF is less than "-3": return "0"
                NEX_layer_out(idx_node_this) <= (others => '0');
              elsif CUR_data_accum(idx_node_this) > c_s_dw_pos_3 then
                -- IF is greater than "+3": return "1"
                NEX_layer_out(idx_node_this) <= c_pos_one;
              else
                -- ELSE: linear function: y = (x/6) + 0.5
                v_dw_AF_temp1 := signed(STD_LOGIC_VECTOR(CUR_data_accum(idx_node_this)(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q)));
                v_dw_AF_temp2 := v_dw_AF_temp1 * c_s_pos_sixth;
                v_dw_AF_temp1 := c_s_pos_half + v_dw_AF_temp2(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q);
                NEX_layer_out(idx_node_this) <= STD_LOGIC_VECTOR( v_dw_AF_temp1 );
                
                --NEX_layer_out(idx_node_this) <= STD_LOGIC_VECTOR(CUR_data_accum(idx_node_this)(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q));
              end if;
            end loop;

          when others =>
            -- When: Identity Function
            LOOP_AF_IDENTITY : FOR idx_node_this in 0 to (g_layer_length_cur-1) LOOP
              NEX_layer_out(idx_node_this) <= STD_LOGIC_VECTOR( CUR_data_accum(idx_node_this)(c_DATA_WIDTH + c_DATA_Q - 1 downto c_DATA_Q) );
            end loop;
        end case;
        
        NEX_ready_to_TX <= '1';
        NEX_state <= IDLE_TX;
        
      when others =>
        -- default catch others
        NEX_state <= RESET_STATE;
        
    end case;
    
  end process;
  
  P_CLK : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- internal signals
        CUR_state <= RESET_STATE; -- default state: reset
        CUR_node_prev <= 0;
        
        CUR_data_in   <= (others=>(others=>'0'));
        CUR_data_accum <= (others=>(others=>'0'));
        
        -- outputs
        ready_to_TX <= '0';
        ack_RX <= '0';
        layer_out <= (others=>(others=>'0'));
      else
        -- internal signals
        CUR_state     <= NEX_state;
        CUR_node_prev <= NEX_node_prev;
        
        CUR_data_in   <= NEX_data_in;
        CUR_data_accum <= NEX_data_accum;
        
        -- outputs
        ready_to_TX <= NEX_ready_to_TX;
        ack_RX <= NEX_ack_RX;
        layer_out   <= NEX_layer_out;
      end if;
    end if;
    
  end process;
end architecture rtl;

