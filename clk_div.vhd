library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The basys 3 board has a 100 MHz oscillator
-- For the MVP we will generate a clock signal which is much lower (1 Hz)

entity clk_div is
  port
  (
    clk_in, reset : in std_logic;
    clk_out       : out std_logic);
end clk_div;

architecture behavorial of clk_div is

  signal count : integer   := 0;
  signal tmp   : std_logic := '0';

begin
  process (clk_in, reset)
  begin
    if (reset = '1') then
      count <= 1;
      tmp   <= '0';
    elsif (rising_edge(clk_in)) then
      count <= count + 1;
      if (count = 125000000 - 1) then 
        tmp   <= not(tmp);
        count <= 0;
      end if;
    end if;
    clk_out <= tmp;
  end process;
end architecture;