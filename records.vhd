
library ieee;
use ieee.std_logic_1164.all;

package records_pkg is
	
	-- Outputs from decoder
	type t_from_decoder is record
		rd: std_logic_vector(4 downto 0);		-- destination register
		ALU_src1_ctrl: std_logic;						
		ALU_src2_ctrl: std_logic;
		ALU_op_ctrl: std_logic_vector(3 downto 0);
		REG_we: std_logic;						-- Register file write enable
		immediate: std_logic_vector (31 downto 0); 	-- immediate value

	end record t_from_decoder;

  end package records_pkg;
