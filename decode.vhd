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
use work.mem_op_const.all;


----- Entity declarations -----

entity decoder is
port (
	instr: in std_logic_vector(31 downto 0);
	decoder_out: out t_decoder;
	REG_src_idx_1, REG_src_idx_2: out std_logic_vector (4 downto 0)
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
		clk, REG_we: in std_logic;
		REG_src_idx_1, REG_src_idx_2: in std_logic_vector(4 downto 0);
		REG_dst_idx: in std_logic_vector(4 downto 0);
		REG_write_data: in std_logic_vector(B-1 downto 0);
		REG_src_1, REG_src_2: out std_logic_vector(B-1 downto 0);
		-- blinky : out std_logic -- TODO DELETE MEE :)))
	);
end reg_file;


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
				opcode <= instr(6 downto 0); 
				func3 <= (others => '0');
				func7 <= (others => '0');

				-- <<< Set default values for decoder outputs >>>
				decoder_out.REG_dst_idx <= (others => '0');							-- Destination register
				decoder_out.ALU_src_1_ctrl <= '0';	-- register						-- ctrl signal for ALU input selector mux 1 (0=reg, 1=pc)
				decoder_out.ALU_src_2_ctrl <= '0';	-- register						-- ctrl signal for ALU input selector mux 2 (0=reg, 1=imm)
				-- Op_ctrl not set here, as it is always set (TODO check if true)	-- operation control for ALU and Comparator (both receive same signal)
				decoder_out.REG_we 		<= '0';										-- Register file write enable
				decoder_out.imm(31 downto 0) <= (others => '0');					-- immediate value

				decoder_out.WB_src_ctrl <= "01";		--default is ALU			-- ctrl signal for WB input selector mux (2=read from mem, 1=ALU, 0=jump/branch)
				decoder_out.MEM_op 		<= "0000";									-- ctrl signal for MEM operation type (eg. lw, sh ...)
				decoder_out.MEM_we 		<= '0';										-- Memory Write enable
				decoder_out.do_jmp 		<= '0';										-- Enable if is a jump instruction
				decoder_out.do_branch 	<= '0';										-- Enable if is a branch instruction
				decoder_out.MEM_rd 		<= '0';										-- Enable if is a load instruction (for hazard unit)
				-- opcode may need to be passed. TODO undecided, use or delete.
				-- <<< Set default values for decoder outputs >>>

				REG_src_idx_1 <= "00000";
				REG_src_idx_2 <= "00000";

				-- TODO set any new values when expanding decoder
									
			-- I-type -- TODO check all fields are set
				case opcode is	
				when DEC_I_LOAD | DEC_I_ADD_SHIFT_LOGICOPS | DEC_I_ADDW_SHIFTW | DEC_I_JALR => 
					decoder_out.REG_dst_idx <= instr(11 downto 7);
					decoder_out.REG_we <= '1';
					decoder_out.ALU_src_2_ctrl <= '1';	-- imm
					REG_src_idx_1 <= instr(19 downto 15);
					
					decoder_out.imm(11 downto 0) <= instr(31 downto 20);
					-- Handle imm sign extension
					if (decoder_out.imm(11) = '1') then
						decoder_out.imm(31 downto 12) <= (others => '1');
					else
						decoder_out.imm(31 downto 12) <= (others => '0');
					end if;

					func3 <= instr(14 downto 12);
					-- is DEC_I_LOAD
					if (not(opcode(4) or opcode(5))) then
						decoder_out.WB_src_ctrl <= "10";		--read from mem
						decoder_out.MEM_rd 	<= '1';	
						report "[DECODE] WB_src_ctrl " & to_string(decoder_out.WB_src_ctrl);
						case func3 is
							-- lw
							when "010" => 
							decoder_out.MEM_op 	<= lw;		
							
							-- TODO CONTINUE HERE
							when others => 
								report "Undefined func3: I-type, DEC_I_LOAD";
						end case;
					
					-- is DEC_I_ADD_SHIFT_LOGICOPS
					elsif (opcode(4) and (not(opcode(5)))) then 
						case func3 is
							-- addi
							when "000" =>
							decoder_out.op_ctrl <=  ALU_ADD;
							-- xori
							when "100" =>
							decoder_out.op_ctrl <= ALU_XOR;
							-- ori
							when "110" =>
							decoder_out.op_ctrl <= ALU_OR;
							-- andi
							when "111" =>
							decoder_out.op_ctrl <= ALU_AND;
							----- shifts
							-- slli
							when "001" => 
							decoder_out.op_ctrl <=  ALU_SL;
							when "101" => 
								if (instr(30)) then
									-- srai
									decoder_out.op_ctrl <=  ALU_SRA;
								else
									-- srli
									decoder_out.op_ctrl <=  ALU_SR;
								end if;
							----- set if's
							-- slti
							when "010" => 
							decoder_out.op_ctrl <=  ALU_SLT_S;
							-- sltiu
							when "011" => 
							decoder_out.op_ctrl <=  ALU_SLT_U;
						
							
							when others =>
								report "Undefined func3: I-type, ADD_SHIFT_LOGICOPS";
						end case;
					-- DEC_I_ADDW_SHIFTW
		--			elsif 
					-- DEC_I_JALR
		--			elsif
					-- Undefined opcode
		--			else --report undefined opcode
					end if;
				
			-- R-type
				when DEC_R_OPS | DEC_R_OPSW => 
					decoder_out.REG_dst_idx <= instr(11 downto 7);
					-- ALU_src_ctrl_x is register as standard
					decoder_out.REG_we <= '1';
					
					REG_src_idx_1 <= instr(19 downto 15);
					REG_src_idx_2 <= instr(24 downto 20);

					func3 <= instr(14 downto 12);
					func7 <= instr(31 downto 25);

					-- case func3: R
					case func3 is
						-- add and sub
						when "000" =>
							-- add
							if (func7 = "0000000") then
							decoder_out.op_ctrl <=  ALU_ADD; 
							
							-- sub
							elsif (func7 = "0100000") then
							decoder_out.op_ctrl <=  ALU_SUB; 
							
							else report "undefined func7: R-type, func3=000";
							end if;
						
						-- xor
						when  "100" =>
							if (func7="0000000") then
								decoder_out.op_ctrl <= ALU_XOR;
							else report "Illegal func7: R xor";
						end if;

						-- or
						when "110" =>
						if (func7="0000000") then
							decoder_out.op_ctrl <= ALU_OR;
						else report "Illegal func7: R or";
						end if;

						-- and 
						when "111" =>
						if (func7="0000000") then
							decoder_out.op_ctrl <= ALU_AND;
						else report "Illegal func7: R and";
						end if;
						
						when others =>
							report "undefined func3: R-type";
						
					end case;

			-- U-type (auipc, lui) 
				when DEC_U_AUIPC | DEC_U_LUI =>
					decoder_out.REG_dst_idx <= instr(11 downto 7);
					decoder_out.ALU_src_2_ctrl <= '1';	-- imm
					decoder_out.REG_we <= '1';
					decoder_out.op_ctrl <= ALU_add;

					decoder_out.imm(31 downto 12) <= instr(31 downto 12);
					decoder_out.imm(11 downto 0) <= (others => '0');
					
					-- auipc
					if (not(opcode(1))) then
						decoder_out.ALU_src_1_ctrl <= '1';	-- pc
					-- lui
					else 
						-- ALU src 1 is register, x0 is default. The add is set above, so there is no unique code here :)
						null;
					end if;


			-- S-type (store) -- TODO: ADD REST OF RECORD LOGIC (have sw)
				when DEC_S =>
					decoder_out.REG_we <= '0';
					decoder_out.ALU_src_2_ctrl <= '1';	-- imm for calculating address
					REG_src_idx_1 <= instr(19 downto 15);
					REG_src_idx_2 <= instr(24 downto 20);

					decoder_out.MEM_we 		<= '1';	
										
					-- construct immediate
					decoder_out.imm(4 downto 0) 	<= instr(11 downto 7);
					decoder_out.imm(11 downto 5) 	<= instr(31 downto 25);
					-- Handle imm sign extension
					if (decoder_out.imm(11) = '1') then
						decoder_out.imm(31 downto 12) <= (others => '1');
					else
						decoder_out.imm(31 downto 12) <= (others => '0');
					end if;

					
					func3 <= instr(14 downto 12);
					

					case func3 is -- TODO: ADD REST OF LOGIC
						-- sw
						when "010" => 
						decoder_out.op_ctrl <= ALU_ADD; 
						decoder_out.MEM_op <= sw;
						when others =>
						report "undefined func3: S-type";
					end case;
				
				
			-- SB-type (branches) -- should be finished
				when DEC_SB => 
					decoder_out.do_branch <=  '1';
					decoder_out.WB_src_ctrl <= "00";
					
					-- construct imm
					decoder_out.imm(12) <= instr(31);					
					decoder_out.imm(10 downto 5) <= instr(30 downto 25);					
					decoder_out.imm(4 downto 1) <= instr(11 downto 8);					
					decoder_out.imm(11) <= instr(7);
					decoder_out.imm(0) <= '0';					
					-- Handle imm sign extension
					if (decoder_out.imm(12) = '1') then
						decoder_out.imm(31 downto 13) <= (others => '1');
					else
						decoder_out.imm(31 downto 13) <= (others => '0');
					end if;

					REG_src_idx_1 <= instr(19 downto 15);
					REG_src_idx_2 <= instr(24 downto 20);

					func3 <= instr(14 downto 12);
					case func3 is
						when "000" => 
							decoder_out.op_ctrl <= ALU_BEQ;
						when "001" => 
							decoder_out.op_ctrl <= ALU_BNE;
						when "100" => 
							decoder_out.op_ctrl <= ALU_BLT;
						when "101" => 
							decoder_out.op_ctrl <= ALU_BGE;
						when "110" => 
							decoder_out.op_ctrl <= ALU_BLT_U;
						when "111" => 
							decoder_out.op_ctrl <= ALU_BGE_U;
						when others => 
							report "undefined func3: SB-type";
					end case;

				
				-- UJ-type (jal)
				when DEC_UJ =>
					decoder_out.REG_dst_idx <= instr(11 downto 7);
					--construct imm
					decoder_out.imm(20) <= instr(31);					
					decoder_out.imm(10 downto 1) <= instr(30 downto 21);					
					decoder_out.imm(11) <= instr(20);					
					decoder_out.imm(19 downto 12) <= instr(19 downto 12);					
					-- Handle imm sign extension
					if (decoder_out.imm(20) = '1') then
						decoder_out.imm(31 downto 21) <= (others => '1');
					else
						decoder_out.imm(31 downto 21) <= (others => '0');
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
signal array_register: registerfile_type := (others => (others => '0'));

begin
    process(clk)
    begin
    if (rising_edge(clk)) then
	if (REG_we = '1' and REG_dst_idx /= "00000") then
	    -- report "[REG FILE] Register(" & to_string(REG_dst_idx) & ") <= " & to_string(REG_write_data); -- TODO: Delete
	    array_register(to_integer(unsigned(REG_dst_idx))) <= REG_write_data; 
	end if;
    end if;
	
    end process;

    REG_src_1 <= array_register(to_integer(unsigned(REG_src_idx_1)));
    REG_src_2 <= array_register(to_integer(unsigned(REG_src_idx_2)));
	
    -- blinky <= array_register(2)(0);
end behavioral;
