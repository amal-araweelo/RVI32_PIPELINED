-- 3 to 1 Multiplexor (will be used as a 3 to 1 multiplexor)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux3 is
  port
  (
    sel    : in std_logic_vector(1 downto 0);
    a      : in std_logic_vector(31 downto 0);
    b      : in std_logic_vector(31 downto 0);
    c      : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0)
  );
end mux3;

architecture behavorial of mux3 is
begin
  with sel select
    output <=
    a when "00",
    b when "01",
    c when "10",
    x"00000000" when others;
end behavorial;
