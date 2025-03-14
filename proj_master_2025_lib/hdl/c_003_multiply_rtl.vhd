--
-- VHDL Architecture proj_master_2025_lib.c_003_multiply.rtl
--
-- Created:
--          by - Admin.UNKNOWN (LAPTOP-7KFJT032)
--          at - 15:52:43 12.03.2025
--
-- using Mentor Graphics HDL Designer(TM) 2017.1a (Build 5)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity c_003_multiply is
   generic( 
      data_width_g : integer := 16;
      Q_width_g    : integer := 8
   );
   port( 
      clk       : in     std_logic;
      reset     : in     std_logic;
      enable    : in     std_logic;
      weight_in : in     std_logic_vector (data_width_g-1 downto 0);
      data_in   : in     std_logic_vector (data_width_g-1 downto 0);
      data_out  : out    std_logic_vector (data_width_g-1 downto 0)
   );

-- Declarations
end entity c_003_multiply;

--
architecture rtl of c_003_multiply is
  -- define internal signals and constants here
  --signal  result_s  : signed(data_width_g - 1 downto 0) := (others => '0');
  
begin
  PROCESS_1 : process(clk)
    -- process variable for the Multiplication Result
    variable mul_v : signed(2*data_width_g - 1 downto 0);  -- the leftmost two bits are both sign bits
    
  begin
    if rising_edge(clk) then
      if reset = '1' then
        data_out <= (others => '0');
        
      else
        if enable = '1' then
          mul_v := signed(weight_in) * signed(data_in);
          

          data_out <= mul_v(data_width_g + Q_width_g - 1 downto Q_width_g);
        else
          data_out <= (others => '0');
        end if;
      end if; -- if "enable"
    end if; -- rising edge
    
    -- connect internal signal to output port (synchronously)
  end process;
  
end architecture rtl;

