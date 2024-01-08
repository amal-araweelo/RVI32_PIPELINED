-- ALU control constants

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package alu_ctrl_const is
  constant alu_add   : std_logic_vector(3 downto 0) := "0000";
  constant alu_or    : std_logic_vector(3 downto 0) := "0001";
  constant alu_and   : std_logic_vector(3 downto 0) := "0010";
  constant alu_sub   : std_logic_vector(3 downto 0) := "0011";
  constant alu_sl    : std_logic_vector(3 downto 0) := "0100";
  constant alu_sr    : std_logic_vector(3 downto 0) := "0101";
  constant alu_slt_s : std_logic_vector(3 downto 0) := "0110";
  constant alu_slt_u : std_logic_vector(3 downto 0) := "0111";
  constant alu_xor   : std_logic_vector(3 downto 0) := "1000";
  constant alu_sra   : std_logic_vector(3 downto 0) := "1001";
  constant alu_beq   : std_logic_vector(3 downto 0) := "1010";
  constant alu_bne   : std_logic_vector(3 downto 0) := "1011";
  constant alu_blt   : std_logic_vector(3 downto 0) := "1100";
  constant alu_blt_u : std_logic_vector(3 downto 0) := "1101";
  constant alu_bge_u : std_logic_vector(3 downto 0) := "1110";
  constant alu_bge   : std_logic_vector(3 downto 0) := "1111";
end alu_ctrl_const;

package const_decoder is 
  -- OPCODES
  constant DEC_I_LOAD                 : std_logic_vector(6 downto 0) := "0000011";
  constant DEC_I_ADD_SHIFT_LOGICOPS   : std_logic_vector(6 downto 0) := "0010011";
  constant DEC_I_ADDW_SHIFTW          : std_logic_vector(6 downto 0) := "0011011";
  constant DEC_I_JALR                 : std_logic_vector(6 downto 0) := "1100111";
  constant DEC_R_OPS                  : std_logic_vector(6 downto 0) := "0110011";
  constant DEC_R_OPSW                 : std_logic_vector(6 downto 0) := "0111011";
  constant DEC_U_AUIPC                : std_logic_vector(6 downto 0) := "0010111";
  constant DEC_U_LUI                  : std_logic_vector(6 downto 0) := "0110111";
  constant DEC_S                      : std_logic_vector(6 downto 0) := "0100011";
  constant DEC_UJ                     : std_logic_vector(6 downto 0) := "1101111";

end package const_decoder;




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

	type t_from_id is record
			decoded: t_from_decoder;
			reg_rs1: std_logic_vector (31 downto 0);
			reg_rs2: std_logic_vector (31 downto 0);
			-- pc: std_logic_vector (31 downto 0); -- not needed for now (only implemented for branch)
  end record t_from_id;

  end package records_pkg;
