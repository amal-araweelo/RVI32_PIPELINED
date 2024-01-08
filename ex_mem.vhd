library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

entity reg_exmem is 
		port (
				clk, en, clear : std_logic;
				in_from_ex : in t_from_ex;
				out_to_mem : out t_from_ex
	 );
end reg_exmem;

architecture behavioral of reg_exmem is 
		signal reg : t_from_ex;
begin
		process(clk, clear, en)
		begin
				if (clear = '1') then
					reg.ALU_result <= (others => '0');
					reg.data_in <= (others => '0');
					reg.data_we <= '0';
					reg.reg_we <= '0';
					reg.rd <= (others => '0');
				end if;

				if (rising_edge(clk)) then
						if (clear = '0' and en = '1') then
								reg <= in_from_ex;
						end if;
				end if;
		end process;

		out_to_mem <= reg;
end behavioral;
