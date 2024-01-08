-- The ID/EX stage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

entity reg_idex is 
		port (
				clk, en, clear : std_logic;
				in_from_id : in t_from_id;
				out_to_ex : out t_from_id
	 );
end reg_idex;

architecture behavioral of reg_idex is 
begin
  process(clk, clear, en)
	begin

  if (clear = '1') then
			out_to_ex.decoded.ALUsrc1 <= '0'; 
			out_to_ex.decoded.ALUsrc2 <= '0';
			out_to_ex.decoded.ALUop <= (others => '0');
			out_to_ex.decoded.rd <= (others => '0');
			out_to_ex.decoded.REG_we <= '0';
			out_to_ex.decoded.immediate <= (others => '0');
			out_to_ex.reg_rs1 <= (others => '0');
			out_to_ex.reg_rs2 <= (others => '0');
  end if;

	if (rising_edge(clk)) then
		if (clear = '0' and en = '1') then
				out_to_ex <= in_from_id;
			end if;
	end if;

  end process;

end behavioral;
