--
-- VHDL Architecture proj_master_2025_lib.c_007_mediator.rtl
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 13:57:03 10.04.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library proj_master_2025_lib;
use proj_master_2025_lib.p_002_generic_01.all;

entity c_007_mediator is
   generic( 
      g_layer_length_first : integer           := 4;
      g_layer_length_last  : integer           := 2;
      g_inputs             : t_array2D_integer := ((0,0,0,0),(0,0,0,0))
   );
   port( 
      clk           : in     std_logic;
      reset         : in     std_logic;
      dst_RX        : in     std_logic;
      src_TX        : in     std_logic;
      ready_to_TX   : out    std_logic;
      ack_RX        : out    std_logic;
      layer_provide : out    t_array_data_stdlv (0 to g_layer_length_first-1);
      layer_accept  : in     t_array_data_stdlv (0 to g_layer_length_last-1)
   );

-- Declarations

end c_007_mediator ;

--
architecture rtl of c_007_mediator is
  --SIGNAL NEX_state, CUR_state : t_stm_layer;
  signal cnt: integer := 0;
  
  signal src_TX_last: std_logic;
begin
  P_CLK : process(clk)
  begin
    if rising_edge(clk) then
      src_TX_last <= src_TX;
      
      if reset = '1' then
        cnt <= 0;
        ready_to_TX <= '0';
        ack_RX <= '0';
        layer_provide <= (others => (others => '0'));
      else
        ready_to_TX <= '1';
        ack_RX <= '1';
        
        if cnt < g_inputs'LENGTH(1) then
          -- we are at "g_inputs(cnt,:)"
          LOOP_1 : FOR idx in 0 to g_inputs'LENGTH(2)-1 LOOP
            layer_provide(idx) <= STD_LOGIC_VECTOR( TO_SIGNED(g_inputs( cnt, idx), c_DATA_WIDTH) );
          end loop;
        else
          layer_provide <= (others => (others => '0'));
        end if;
        
        if src_TX = '1' and src_TX_last = '0' then
          cnt <= cnt + 1;
        end if;
      end if; -- if reset else
    end if; -- if CLK
  end process;
end architecture rtl;

