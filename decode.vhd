-- STC = Subject To Change

-- DECODE STAGE

-- TODO implement Ecall (is an I-type)

library ieee;
use ieee.std_logic_1164.all;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use work.const_decoder.all;
use work.mem_op_const.all;

----- Entity declarations -----

entity decoder is
  port
  (
    instr                        : in std_logic_vector(31 downto 0);
    decoder_out                  : out t_decoder;
    REG_src_idx_1, REG_src_idx_2 : out std_logic_vector (4 downto 0) 
  );
end decoder;

architecture behavioral of decoder is

  signal opcode : std_logic_vector(6 downto 0);
  signal func3  : std_logic_vector(2 downto 0);
  signal func7  : std_logic_vector(6 downto 0);
begin
  process (all)
  begin
    -- Initialize internal signals
    opcode <= instr(6 downto 0);
    func3  <= (others => '0');
    func7  <= (others => '0');

    -- <<< Set default values for decoder outputs >>>
    decoder_out.REG_dst_idx      <= (others => '0'); -- Destination register
    decoder_out.ALU_src_1_ctrl   <= '1'; -- register						-- ctrl signal for ALU input selector mux 1 (1=reg, 0=pc)
    decoder_out.ALU_src_2_ctrl   <= '0'; -- register						-- ctrl signal for ALU input selector mux 2 (0=reg, 1=imm)
    decoder_out.op_ctrl          <= alu_add; 								-- operation control for ALU and Comparator (both receive same signal)
    decoder_out.REG_we           <= '0'; -- Register file write enable
    decoder_out.imm(31 downto 0) <= (others => '0'); -- immediate value

    decoder_out.WB_src_ctrl <= "01"; --default is ALU			-- ctrl signal for WB input selector mux (2=read from mem, 1=ALU, 0=jump/branch)
    decoder_out.MEM_op      <= "000"; -- ctrl signal for MEM operation type (eg. lw, sh ...)
    decoder_out.MEM_we      <= '0'; -- Memory Write enable
    decoder_out.do_jmp      <= '0'; -- Enable if is a jump instruction
    decoder_out.do_branch   <= '0'; -- Enable if is a branch instruction
    decoder_out.MEM_rd      <= '0'; -- Enable if is a load instruction (for hazard unit)
    
    REG_src_idx_1 <= "00000";
    REG_src_idx_2 <= "00000";
    -- <<< Set default values for decoder outputs >>>

    
    case opcode is
	-- I-type
      when DEC_I_LOAD | DEC_I_ADD_SHIFT_LOGICOPS | DEC_I_JALR =>
        decoder_out.REG_dst_idx    <= instr(11 downto 7);
        decoder_out.REG_we         <= '1';
        decoder_out.ALU_src_2_ctrl <= '1'; -- imm
        REG_src_idx_1              <= instr(19 downto 15);
		--report "decoder_out.REG_src_idx_1 should be: " & to_string(instr(19 downto 15)) & " FROM DECODER";
		--report "decoder_out.REG_src_idx_1 is: " & to_string(REG_src_idx_1) & " FROM DECODER";
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
				-- lb
				when "000" => 
				decoder_out.MEM_op 	<= lb;		
				-- lh
				when "001" => 
				decoder_out.MEM_op 	<= lh;
				-- lw
				when "010" => 
				decoder_out.MEM_op 	<= lw;		
				-- lbu
				when "100" => 
				decoder_out.MEM_op 	<= lbu;
				-- lhu
				when "101" => 
				decoder_out.MEM_op 	<= lhu;
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
		-- DEC_I_JALR
		elsif (opcode(6) and (opcode(5))) then 
			decoder_out.op_ctrl <=  ALU_ADD;
			-- TODO how to set lsb of result to 0? Add XOR with JAL on that bits signal?
		
		else 
			report "undefined opcode - I-type";
		end if; -- End I-type
				
	-- R-type
		when DEC_R_OPS => 
			decoder_out.REG_dst_idx <= instr(11 downto 7);
			-- ALU_src_ctrl_x is register as standard
			decoder_out.REG_we <= '1';
			
			REG_src_idx_1 <= instr(19 downto 15);
			REG_src_idx_2 <= instr(24 downto 20);

			func3 <= instr(14 downto 12);
			func7 <= instr(31 downto 25);
			-- case func3: DEC_R_OPS
			case func3 is
				----- R: Arithm and logical ops
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
						decoder_out.op_ctrl <= ALU_XOR;

					-- or
					when "110" =>
						decoder_out.op_ctrl <= ALU_OR;

					-- and 
					when "111" =>
						decoder_out.op_ctrl <= ALU_AND;

				----- R: Shifts
					-- sll
					when "001" => 
						decoder_out.op_ctrl <=  ALU_SL;
					-- srl/sra
					when "101" => 
						-- sra
						if (func7(5)) then
							decoder_out.op_ctrl <=  ALU_SRA;
						-- srl
						else
							decoder_out.op_ctrl <=  ALU_SR;
						end if;

				----- R: sets
					-- slt
					when "010" => 
						decoder_out.op_ctrl <=  ALU_SLT_S;
					-- sltu
					when "011" => 
						decoder_out.op_ctrl <=  ALU_SLT_U;

				when others =>
					null;

				end case;-- case func3: DEC_R_OPS

	-- U-type (auipc, lui) 
		when DEC_U_AUIPC | DEC_U_LUI =>
			decoder_out.REG_dst_idx    <= instr(11 downto 7);
			decoder_out.ALU_src_2_ctrl <= '1'; -- imm
			decoder_out.REG_we         <= '1';
			decoder_out.op_ctrl        <= ALU_add;

			decoder_out.imm(31 downto 12) <= instr(31 downto 12);
			decoder_out.imm(11 downto 0)  <= (others => '0');

			report "[DECODER] hello from U-type";
			-- auipc
			if (not(opcode(5))) then
				report "[DECODER] Hello from auipc start";
				decoder_out.ALU_src_1_ctrl <= '0'; -- pc
			-- lui
			else
			-- ALU src 1 is register, x0 is default. The add is set above, so there is no unique code here :)
			null;
			end if;
	-- S-type (store) 
		when DEC_S =>
				decoder_out.ALU_src_2_ctrl <= '1'; -- imm for calculating address
				REG_src_idx_1              <= instr(19 downto 15);
				REG_src_idx_2              <= instr(24 downto 20);

				decoder_out.MEM_we <= '1';

				-- construct immediate
				decoder_out.imm(4 downto 0)  <= instr(11 downto 7);
				decoder_out.imm(11 downto 5) <= instr(31 downto 25);
				-- Handle imm sign extension
				if (decoder_out.imm(11) = '1') then
				decoder_out.imm(31 downto 12) <= (others => '1');
				else
				decoder_out.imm(31 downto 12) <= (others => '0');
				end if;
				func3 <= instr(14 downto 12);
				case func3 is 
					-- sb
					when "000" => 
						decoder_out.MEM_op  <= sb;
					-- sh
					when "001" => 
						decoder_out.MEM_op  <= sh;
					-- sw
					when "010" =>
						decoder_out.MEM_op  <= sw;
				when others =>
					null;
				end case;

	-- SB-type (branches) -- should be finished
		when DEC_SB =>
				decoder_out.do_branch   <= '1';
				decoder_out.WB_src_ctrl <= "00";

				-- construct imm
				decoder_out.imm(12)          <= instr(31);
				decoder_out.imm(10 downto 5) <= instr(30 downto 25);
				decoder_out.imm(4 downto 1)  <= instr(11 downto 8);
				decoder_out.imm(11)          <= instr(7);
				decoder_out.imm(0)           <= '0';

				-- Set ALU src
				decoder_out.ALU_src_1_ctrl <= '0'; -- pc
				decoder_out.ALU_src_2_ctrl <= '1'; -- imm

				-- Handle imm sign extension
				if (decoder_out.imm(12) = '1') then
				decoder_out.imm(31 downto 13) <= (others => '1');
				else
				decoder_out.imm(31 downto 13) <= (others => '0');
				end if;

				report "[DECODE] BRANCH imm: " & to_string(decoder_out.imm);

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
					null;
				end case;

	-- UJ-type (jal)
		when DEC_UJ =>
			decoder_out.REG_dst_idx <= instr(11 downto 7);
			decoder_out.reg_WE <=  '1';
			decoder_out.ALU_src_2_ctrl <=  '1';					 -- imm
			-- ALU_ADD is default op_ctrl
			decoder_out.do_jmp <=  '1';
			
			--construct imm
			decoder_out.imm(20)           <= instr(31);
			decoder_out.imm(10 downto 1)  <= instr(30 downto 21);
			decoder_out.imm(11)           <= instr(20);
			decoder_out.imm(19 downto 12) <= instr(19 downto 12);
			-- Handle imm sign extension
			if (decoder_out.imm(20) = '1') then
			decoder_out.imm(31 downto 21) <= (others => '1');
			else
			decoder_out.imm(31 downto 21) <= (others => '0');
			end if;

		when others =>
			-- [AMAL] sets a default value for opcode in case it's not covered. it resulted in a latch

    end case;
  end process;
end behavioral;
