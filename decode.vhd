-- DECODE STAGE

library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all; -- USING PACKAGE HERE!

-- Port and signal naming copies from ripes



----- Entity declarations -----

-- Overall decode stage entity
-- TODO
--	Declare 'external' signals (Make ports for all signals external to the stage)

-- FI/DI register
entity ifidreg is
	port (
	in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);		-- register inputs
	out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0);	-- register outputs
	clk, en, clear : in std_logic												-- enable, clear
	); 
end ifidreg;



-- IF/ID register
architecture arch of ifidreg is
	begin
		process(clk, clear, en)
		begin
			if (rising_edge(clk)) then		-- do stuff on rising clock edge
				if (clear = '0')  then		-- if the signal is not to clear the reg
					if (en = '1') then		-- do stuff if enabled
						out_pc <= in_pc;
						out_pc4 <= in_pc4;
						out_instruction <= in_instruction;
					end if;
				else 						-- clear the reg
					out_pc <= (others=>'0');
					out_pc4 <= (others=>'0');
					out_instruction <= (others=>'0');
				end if;	
		end if;
	end process;
	end arch;