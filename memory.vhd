-- Data memory (only supports words right now)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity datamem is
  port
  (
    clk    : in std_logic; -- clock
    we     : in std_logic; -- write enable
    rdData : out std_logic_vector(31 downto 0); -- read data
    wrData : in std_logic_vector(31 downto 0); -- write data
    addr   : in std_logic_vector(31 downto 0) -- address
  );
end datamem;

architecture impl of datamem is
  type ram_type is array(2**10 downto 0) -- 1K
  of std_logic_vector (31 downto 0);
  signal ram : ram_type;

begin
  process (clk) begin
    if (rising_edge(clk)) then
      if (we = '1') then
        ram(to_integer(unsigned(addr))) <= wrData;
      end if;
    end if;
    rdData <= ram(to_integer(unsigned(addr))); -- available only after addr_reg is updated
  end process;
end architecture;

