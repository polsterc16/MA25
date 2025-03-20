--
-- VHDL Architecture proj_master_2025_lib.c_005_node_01.rtl
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 13:23:46 18.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
-- Weights and Bias are stored in "Node" via generic
--
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library proj_master_2025_lib;
use proj_master_2025_lib.p_002_generic_01.all;

entity c_005_node_01 is
   generic( 
      array_int_bias_weight_g : proj_master_2025_lib.p_002_generic_01.t_array_integer := (0,1,2,3)
   );
   port( 
      clk         : in     std_logic;
      reset       : in     std_logic;
      
      calc        : in     std_logic;
      set_to_bias : in     std_logic;
      address     : in     std_logic_vector (c_ADDR_WIDTH-1 downto 0);
      val_in      : in     std_logic_vector (c_DATA_WIDTH-1 downto 0);
      val_out     : out    std_logic_vector (c_DATA_WIDTH-1 downto 0)
   );
end entity c_005_node_01;

--
architecture rtl of c_005_node_01 is
begin
  PROCESS_1 : process(clk)
    -- process variable for the Multiplication Result
    --variable mul_v  : signed(2*c_DATA_WIDTH - 1 downto 0);  -- the leftmost two bits are both sign bits
    --variable bias_v : signed(2*c_DATA_WIDTH - 1 downto 0);
    
  begin
    if rising_edge(clk) then
      if reset = '1' then
        val_out <= (others => '0');
        
      else
        if set_to_bias = '1' then
          -- BIAS: convert to "signed" of double length, then left_shift to correct position
          -- BIAS is stored as last element of generic array :: at index array'HIGH
          --bias_v := SHIFT_LEFT(TO_SIGNED( array_int_bias_weight_g(array_int_bias_weight'high), 2*data_width_g), Q_width_g);
          val_out <= SHIFT_LEFT(TO_SIGNED( array_int_bias_weight_g(array_int_bias_weight'high), 2*c_DATA_WIDTH), c_DATA_Q);
        elsif calc = '1' then
          -- val_out[stdv:16] = val_out[signed:16] + val_in[signed:8] * weight(adress[int:4])[signed:8]
          val_out <= SIGNED(val_out) + SIGNED(val_in) * TO_SIGNED(array_int_bias_weight_g(TO_INTEGER( UNSIGNED(address) )), c_DATA_WIDTH);
        end if;
      end if; -- esle "reset"
    end if; -- rising edge
    
    -- connect internal signal to output port (synchronously)
  end process;
end architecture rtl;

