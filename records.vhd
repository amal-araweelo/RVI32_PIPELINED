
library ieee;
use ieee.std_logic_1164.all;

package records_pkg is
	
	-- Outputs from decoder
	type t_from_decoder is record
		rd: std_logic_vector(4 downto 0);		-- destination register
		ALUsrc1: std_logic;						
		ALUsrc2: std_logic;
		ALUop: std_logic_vector(3 downto 0);

	end record t_from_decoder;



   


--	constant c_FROM_FIFO_INIT : t_FROM_FIFO := (wr_full => '0',
--												rd_empty => '1',
--												rd_dv => '0',
--												rd_data => (others => '0'));
   

	
	 
  end package records_pkg;