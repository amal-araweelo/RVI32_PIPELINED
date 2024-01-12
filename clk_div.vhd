library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The basys 3 board has a 100 MHz oscillator
-- For the MVP we will generate a clock signal which is much lower (1 Hz)

entity clk_div is
  port
  (
    clk_in : in std_logic:='0';
    clk_out       : out std_logic
    );
end clk_div;

architecture behavorial of clk_div is
  signal count_current : integer   := 0;
  signal count_next: integer:=0;
  signal tmp   : std_logic := '0';

begin 
  process(all)
  begin
    if (count_current = 12500000-1) then 
      tmp   <= not(tmp);
      count_next <= 0;
    else
      count_next <= count_current + 1;
    end if;

  end process;

  process (clk_in)
  begin
    if (rising_edge(clk_in)) then
      clk_out <= tmp;
      count_current <=count_next; 
    end if;
  end process;
end architecture;
