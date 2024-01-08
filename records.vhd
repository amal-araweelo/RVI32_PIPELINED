library ieee;
use ieee.std_logic_1164.all;

package records_pkg is
	
	-- Outputs from decoder
	type t_from_decoder is record
		ALUsrc1: std_logic;						
		ALUsrc2: std_logic;
		ALUop: std_logic_vector(3 downto 0);
		rd: std_logic_vector(4 downto 0);		-- destination register
		REG_we: std_logic;						-- Register file write enable
		immediate: std_logic_vector (31 downto 0); 	-- immediate value
	end record t_from_decoder;

	type t_from_id is record
			decoded: t_from_decoder;
			reg_rs1: std_logic_vector (31 downto 0);
			reg_rs2: std_logic_vector (31 downto 0);
			-- pc: std_logic_vector (31 downto 0); -- not needed for now (only implemented for branch)
  end record t_from_id;

	type t_from_ex is record 
	    ALU_result: std_logic_vector (31 downto 0);
	    data_in: std_logic_vector (31 downto 0);
	    data_we: std_logic;
	    reg_we: std_logic;
	    rd : std_logic_vector (4 downto 0);
	    -- pc : std_logic_vector (31 downto 0);
	end record t_from_ex;

	type t_from_mem is record
	    reg_we : std_logic;
	    reg_wr_src_crtl : std_logic;
	    mem_do_write    : std_logic;
	    mem_op          : std_logic_vector(3 downto 0); -- TODO: Move this to t_from_ex
	    alures          : std_logic_vector(31 downto 0);
	    r2              : std_logic_vector(31 downto 0);
	    wr_reg_idx      : std_logic_vector(4 downto 0); -- register ID
	    -- pc              : in std_logic_vector(31 downto 0);
  end record t_from_mem;

  end package records_pkg;
