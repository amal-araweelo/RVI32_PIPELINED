-- STC = Subject To Change

-- DECODE STAGE

-- TODO: ADD REST OF U-TYPE RECORD LOGIC
-- TODO: ADD REST OF S-TYPE RECORD LOGIC
-- TODO: ADD REST OF UJ-TYPE RECORD LOGIC

library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use work.const_decoder.all;


----- Entity declarations -----


-- ID/ID register
entity reg_ifid is
	port (
	in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);		-- register inputs
	out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0);	-- register outputs
	clock, en, clear : in std_logic												-- enable, clear
	); 
end reg_ifid;

library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all;

entity decoder is
	port (
	instruction: in std_logic_vector(31 downto 0);
	decoder_out: out t_from_decoder;
  REG_rs1, REG_rs2: out std_logic_vector (4 downto 0)
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
		clock, we: in std_logic;
		instruction: in std_logic_vector(31 downto 0);
		w_addr: in std_logic_vector(4 downto 0);
		w_data: in std_logic_vector(B-1 downto 0);
		rs1_out, rs2_out: out std_logic_vector(B-1 downto 0)
	);
end reg_file;



-- IF/ID register
architecture behavioral of reg_ifid is
begin
    process(clock, clear, en)
	begin
	if (rising_edge(clock)) then		-- do stuff on rising clock edge
	    if (clear = '0')  then		-- if the signal is not to clear the reg
				if (en = '1') then		-- do stuff if enabled
						out_pc <= in_pc;
						out_pc4 <= in_pc4;
						out_instruction <= in_instruction;
				end if;
  	else						-- clear the reg
		out_pc <= (others=>'0');
		out_pc4 <= (others=>'0');
		out_instruction <= (others=>'0');
	  end if;	
		end if;
    end process;
end behavioral;

-- Re-includes bc VHDL do be like that
library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use work.const_decoder.all;

architecture behavioral of decoder is

	signal opcode: std_logic_vector(6 downto 0);
	signal func3: std_logic_vector(2 downto 0);
	signal func7: std_logic_vector(6 downto 0);
	begin
	process(all) -- TODO: Remove process and replace case with select
		begin
				-- Initialize internal signals
				opcode <= instruction(6 downto 0); 
				func3 <= (others => '0');
				func7 <= (others => '0');

				-- Set default values for decoder's outputs (all 0's)
				-- ALUsrc and ALUop not set here, as it is always set (TODO check if true)
				decoder_out.immediate(11 downto 0) <= (others => '0');
				decoder_out.rd <= (others => '0');
				decoder_out.REG_we <= '0';
				REG_rs1 <= "00000";
				REG_rs2 <= "00000";

				-- TODO set any new values when expanding decoder
									
				case opcode is	
				-- I-type
				when DEC_I_LOAD | DEC_I_ADD_SHIFT_LOGICOPS | DEC_I_ADDW_SHIFTW | DEC_I_JALR => 
				decoder_out.rd <= instruction(11 downto 7);
				decoder_out.REG_we <= '1';
				decoder_out.ALUsrc1 <= '0';	-- register
				decoder_out.ALUsrc2 <= '1';	-- immediate
				decoder_out.immediate(11 downto 0) <= instruction(31 downto 20);
				REG_rs1 <= instruction(19 downto 15);
				-- Handle immediate sign extension
				if (decoder_out.immediate(11) = '1') then
				    decoder_out.immediate(31 downto 12) <= (others => '1');
				else
				    decoder_out.immediate(31 downto 12) <= (others => '0');
				end if;

				-- case: func3
					func3 <= instruction(14 downto 12);
					case func3 is
						-- addi
						when "000" =>
						decoder_out.ALUop <=  ALU_ADD;
						
						-- xori
						when "100" =>
						decoder_out.ALUop <= ALU_XOR;

						-- ori
						when "110" =>
						decoder_out.ALUop <= ALU_OR;
						
						-- andi
						when "111" =>
						decoder_out.ALUop <= ALU_AND;
						



						when others =>
							report "Undefined func3: I-type";
					end case;
				
				-- R-type
				when DEC_R_OPS | DEC_R_OPSW => 
					decoder_out.rd <= instruction(11 downto 7);
					decoder_out.REG_we <= '1';
					decoder_out.ALUsrc1 <= '0';	-- register
					decoder_out.ALUsrc2 <= '0';	-- register
					REG_rs1 <= instruction(19 downto 15);
					REG_rs2 <= instruction(24 downto 20);

					func3 <= instruction(14 downto 12);
					func7 <= instruction(31 downto 25);

						-- case func3: R
						case func3 is
						-- add and sub
						when "000" =>
							-- add
							if (func7 = "0000000") then
							decoder_out.ALUop <=  ALU_ADD; 
							
							-- sub
							elsif (func7 = "0100000") then
							decoder_out.ALUop <=  ALU_SUB; 
							
							else report "undefined func7: R-type, func3=000";
							end if;
						
						-- xor
						when  "100" =>
							if (func7="0000000") then
								decoder_out.ALUop <= ALU_XOR;
							else report "Illegal func7: R xor";
						end if;

						-- or
						when "110" =>
						if (func7="0000000") then
							decoder_out.ALUop <= ALU_OR;
						else report "Illegal func7: R or";
						end if;

						-- and 
						when "111" =>
						if (func7="0000000") then
							decoder_out.ALUop <= ALU_AND;
						else report "Illegal func7: R and";
						end if;
						
						when others =>
							report "undefined func3: R-type";
						
						end case;

				-- U-type (auipc, lui)
				when DEC_U_AUIPC | DEC_U_LUI =>
					decoder_out.rd <= instruction(11 downto 7);
					decoder_out.immediate(31 downto 12) <= instruction(31 downto 12);
					decoder_out.immediate(11 downto 0) <= (others => '0');
					-- TODO: ADD REST OF RECORD LOGIC, if statement on opcode to do one or the other


				-- S-type (store)
				when DEC_S =>
					decoder_out.REG_we <= '0';
					decoder_out.ALUsrc1 <= '0';	-- register
					decoder_out.ALUsrc2 <= '0';	-- register
					REG_rs1 <= instruction(19 downto 15);
					REG_rs2 <= instruction(24 downto 20);
					decoder_out.immediate(4 downto 0) 	<= instruction(11 downto 7);
					decoder_out.immediate(11 downto 5) 	<= instruction(31 downto 25);
					-- Handle immediate sign extension
					if (decoder_out.immediate(11) = '1') then
						decoder_out.immediate(31 downto 12) <= (others => '1');
					else
						decoder_out.immediate(31 downto 12) <= (others => '0');
					end if;

					-- TODO: ADD REST OF RECORD LOGIC 
					

					func3 <= instruction(14 downto 12);
					case func3 is
						-- TODO: ADD REST OF LOGIC
						when others =>
						report "undefined func3: S-type";
					end case;
				
				-- UJ-type (jal)
				when DEC_UJ =>
					decoder_out.rd <= instruction(11 downto 7);
					--construct immediate
					decoder_out.immediate(20) <= instruction(31);					
					decoder_out.immediate(10 downto 1) <= instruction(30 downto 21);					
					decoder_out.immediate(11) <= instruction(20);					
					decoder_out.immediate(19 downto 12) <= instruction(19 downto 12);					
					-- Handle immediate sign extension
					if (decoder_out.immediate(20) = '1') then
						decoder_out.immediate(31 downto 21) <= (others => '1');
					else
						decoder_out.immediate(31 downto 21) <= (others => '0');
					end if;
					
					
					
					-- TODO: ADD REST OF RECORD LOGIC

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
    process(clock)
    begin
	    if (rising_edge(clock)) then
		    if (we = '1') then
			    array_register(to_integer(unsigned(w_addr))) <= w_data; 
		    end if;
	    end if;
    end process;
    rs1_out <= array_register(to_integer(unsigned(instruction(19 downto 15))));
    rs2_out <= array_register(to_integer(unsigned(instruction(24 downto 20))));

end behavioral;
