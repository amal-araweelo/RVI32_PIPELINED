-- STC = Subject To Change

-- DECODE STAGE

library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all;

-- Port and signal naming copies from ripes



----- Entity declarations -----

-- Overall decode stage entity
-- TODO
--	Declare 'external' signals (Make ports for all signals external to the stage)

-- FI/DI register

entity reg_ifid is
	port (
	in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);		-- register inputs
	out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0);	-- register outputs
	clk, en, clear : in std_logic												-- enable, clear
	); 
end reg_ifid;

library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all;

entity decoder is
	port (
	instruction: in std_logic_vector(31 downto 0);
	decoder_out: out t_from_decoder
	);
end decoder;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Register file with no reset
entity reg_file is -- Kindly borrowed and adapted from FPGA prototyping by VHDL examples (Xilinx spartan(tm)-3 version) by Pong P. Chu, at University of Cleveland
	generic(
	B: integer:= 32; 	-- no. of bits in register
	W: integer:= 5		-- no. of address bits (5 bits=32 addresses)
	);
	port (
		clk, we: in std_logic;
		instruction: in std_logic_vector(31 downto 0);
		w_addr: in std_logic_vector(4 downto 0);
		w_data: in std_logic_vector(B-1 downto 0);
		rs1_out, rs2_out: out std_logic_vector(B-1 downto 0)
	);
end reg_file;



-- IF/ID register
architecture behavioral of reg_ifid is
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
	end behavioral;

library ieee;
use ieee.numeric_std.all;

architecture behavioral of decoder is
	signal opcode: std_logic_vector(6 downto 0);
	signal func3: std_logic_vector(2 downto 0);
	begin
		process(instruction)
		begin
				opcode <= instruction(6 downto 0); 		-- update opcode
				func3 <= instruction(14 downto 12);

				case opcode is	
				-- I-type
				when "0000011" | "0001111" | "0010011" | "0011011" | "1100111" | "1110011" =>
				decoder_out.rd <= instruction(11 downto 7);
				decoder_out.ALUsrc1 <= '0';
				decoder_out.ALUsrc2 <= '1';
				decoder_out.immediate <= std_logic_vector(signed(instruction(31 downto 20))); -- typecasting to sign-extend immediate

				--instructiontype <= "001";
					case func3 is
						-- addi
						when "000" =>
						decoder_out.ALUop <=  "0010"; -- STC

						when others =>
							report "Undefined func3: I-type";
					end case;

				when others =>
					report "undefined opcode";
				end case;
	end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture behavioral of reg_file is
	type registerfile_type is array (2**W-1 downto 0) of
		std_logic_vector(B-1 downto 0);
	signal array_register: registerfile_type;

	begin
		process(clk)
		begin
			if (rising_edge(clk)) then
				if (we='1') then
					array_register(to_integer(unsigned(w_addr))) <= w_data; 
				end if;
			end if;
		end process;
	rs1_out <= array_register(to_integer(unsigned(instruction(19 downto 15))));
	rs2_out <= array_register(to_integer(unsigned(instruction(24 downto 20))));
end behavioral;

