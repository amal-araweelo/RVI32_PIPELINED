-- The MEM/WB stage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

entity reg_memwb is
  port
  (
    clk : in std_logic; -- clock
		in_from_mem: in t_from_mem;
		out_to_wb : out t_from_mem
  );
end reg_memwb;

architecture behavorial of reg_memwb is
  signal reg : t_from_mem;
begin
  process (clk) begin
    if (rising_edge(clk)) then
			reg <= in_from_mem;
    end if;
  end process;
	out_to_wb <= reg;
end architecture;
