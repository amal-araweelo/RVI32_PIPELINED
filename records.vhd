
library ieee;
use ieee.std_logic_1164.all;

package records_pkg is
	
	-- Outputs from decoder
	type t_from_decoder is record
		rd: std_logic_vector(4 downto 0);		-- destination register
		ALUsrc1: std_logic;						
		ALUsrc2: std_logic;
		ALUop: std_logic_vector(3 downto 0);
		REG_we: std_logic;						-- Register file write enable
		immediate: std_logic_vector (31 downto 0); 	-- immediate value
		REG_rs1: std_logic_vector (4 downto 0);
		REG_rs2: std_logic_vector (4 downto 0);
	end record t_from_decoder;

  end package records_pkg;
