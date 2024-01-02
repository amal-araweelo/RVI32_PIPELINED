-- DECODE STAGE

library ieee;
use ieee.std_logic_1164.all;

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
	en, clear : in std_logic												-- enable, clear
	); 
end ifidreg;

-- Decoder
entity decoder is 
	port (
	in_instruction : in std_logic_vector (31 downto 0);							-- instruction
	out_wr_reg_idx, out_r1idx, out_r2idx : out std_logic_vector (4 downto 0);	-- register numbers: destination, operand 1, operand 2
	out_opcode: out std_logic_vector (5 downto 0)								-- opcode
	);
end decoder;

-- Immediate value decoder
entity immvaldecoder is
	port(
	in_opcode: in std_logic_vector (5 downto 0);
	in_instruction: in std_logic_vector (31 downto 0);
	out_imm: out std_logic_vector (31 downto 0)
	);
end immvaldecoder;

-- Register file
entity registerfile is
port(
	in_wrdata: in std_logic_vector (31 downto 0);					-- data to write
	in_wridx, in_r1idx, in_r2idx: in std_logic_vector (4 downto 0); -- register numbers: destination, operand 1, operand 2
	wr_en: in std_logic;											-- write enable
	out_reg1, out_reg2: out std_logic_vector(31 downto 0);			-- register content outputs: operand 1, operand 2
);
end registerfile;

-- Control unit
entity controlunit is
port(
	-- in
	in_opcode: in std_logic_vector (5 downto 0);
	-- out
	reg_do_write_ctrl, mem_do_write_ctrl, mem_do_read_ctrl, do_jump, do_branch, alu_op1_ctrl, alu_op2_ctrl: out std_logic;
	reg_wr_src_ctrl: out std_logic_vector (1 downto 0);
	comp_ctrl: out std_logic_vector (2 downto 0);
	mem_ctrl: out std_logic_vector (3 downto 0);
	alu_ctrl: out std_logic_vector (4 downto 0)
);
end controlunit;

----- Architecture declarations -----

-- Overall decode stage entity
-- TODO
--  Declare internal signals

--	Instantiate internal componens (see chu pg. 6) Connect internal units together
-- 	Connect external signals to units


-- IF/ID register
architecture arch of ifidreg is
process(clk)
	begin
		if (rising_edge(clk)) then		-- do stuff on rising clock edge
			if (clear = '0') then		
				if (en = '1') then		-- do stuff if enabled
					out_pc <= in_pc;
					out_pc4 <= in_pc4;
					out_instruction <= in_instruction;
				end if;
			else 
				out_pc, out_pc4, out_instruction <= '0';
			end if;	
	end if;
end process;
end arch;

-- Decoder
-- TODO
architecture arch of decoder is
	process(clk)
	if (risingedge(clk)) then	
	
	end if;
end process;
end arch;
--	Make a switch for the different types
-- 	In the switch, sort signals depending on encoding	

-- Immediate value decoder
-- TODO
architecture arch of immvaldecoder is
	process(clk)
	if (risingedge(clk)) then	
	
	end if;
end process;
end arch;

-- Register file
-- TODO
architecture arch of registerfile is
	process(clk)
	if (risingedge(clk)) then	
	
	end if;
end process;
end arch;

-- Control unit
-- TODO - might need help on this
architecture arch of controlunit is
	process(clk)
	if (risingedge(clk)) then	
	
	end if;
end process;
end arch;


