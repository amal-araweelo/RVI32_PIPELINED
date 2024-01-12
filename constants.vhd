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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package const_decoder is
  -- OPCODES
  constant DEC_I_LOAD               : std_logic_vector(6 downto 0) := "0000011";
  constant DEC_I_ADD_SHIFT_LOGICOPS : std_logic_vector(6 downto 0) := "0010011";
  constant DEC_I_ADDW_SHIFTW        : std_logic_vector(6 downto 0) := "0011011";
  constant DEC_I_JALR               : std_logic_vector(6 downto 0) := "1100111";
  constant DEC_R_OPS                : std_logic_vector(6 downto 0) := "0110011";
  constant DEC_R_OPSW               : std_logic_vector(6 downto 0) := "0111011";
  constant DEC_U_AUIPC              : std_logic_vector(6 downto 0) := "0010111";
  constant DEC_U_LUI                : std_logic_vector(6 downto 0) := "0110111";
  constant DEC_S                    : std_logic_vector(6 downto 0) := "0100011";
  constant DEC_SB                   : std_logic_vector(6 downto 0) := "1100011";
  constant DEC_UJ                   : std_logic_vector(6 downto 0) := "1101111";

end package const_decoder;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Memory operation control constants

package mem_op_const is
  constant sb  : std_logic_vector(2 downto 0) := "000";
  constant sh  : std_logic_vector(2 downto 0) := "001";
  constant sw  : std_logic_vector(2 downto 0) := "010";
  constant lb  : std_logic_vector(2 downto 0) := "011";
  constant lh  : std_logic_vector(2 downto 0) := "100";
  constant lw  : std_logic_vector(2 downto 0) := "101";
  constant lbu : std_logic_vector(2 downto 0) := "110";
  constant lhu : std_logic_vector(2 downto 0) := "111";
end mem_op_const;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package records_pkg is

  -- Outputs from decoder
  type t_decoder is record
    REG_dst_idx   : std_logic_vector(4 downto 0);   -- Destination register
    ALU_src_1_ctrl : std_logic;                     -- ctrl signal for ALU input selector mux 1 (0=reg, 1=pc)
    ALU_src_2_ctrl : std_logic;                     -- ctrl signal for ALU input selector mux 2 (0=reg, 1=imm)
    op_ctrl       : std_logic_vector(3 downto 0);   -- operation control for ALU and Comparator (both receive same signal)
    REG_we        : std_logic;                      -- Register file write enable
    imm           : std_logic_vector (31 downto 0); -- immediate value

    WB_src_ctrl : std_logic_vector(1 downto 0);     -- ctrl signal for WB input selector mux  (2=read from mem, 1=ALU, 0=jump/branch)
    MEM_op      : std_logic_vector(2 downto 0);     -- ctrl signal for MEM operation type (eg. lw, sh ...)
    MEM_we      : std_logic;                        -- Memory Write enable
    do_jmp      : std_logic;                        -- Enable if is a jump instruction
    do_branch   : std_logic;                        -- Enable if is a branch instruction
    --opcode      : std_logic_vector(6 downto 0);   -- could be different -- Opcode for passing on if needed (unknown if needed so is outcommented for now TODO use or delete)
    MEM_rd : std_logic;                             -- Enable if is a load instruction (for hazard unit)

  end record t_decoder;

  type t_ifid_reg is record
    pc, instr : std_logic_vector (31 downto 0); -- register inputs
  end record t_ifid_reg;

  type t_idex_reg is record
    decoder_out              : t_decoder;
    pc, REG_src_1, REG_src_2 : std_logic_vector(31 downto 0);
  end record t_idex_reg;

  type t_exmem_reg is record
    REG_we, MEM_we         : std_logic;
    WB_src_ctrl            : std_logic_vector(1 downto 0);
    MEM_op                 : std_logic_vector(2 downto 0);
    REG_dst_idx            : std_logic_vector(4 downto 0);
    pc, ALU_res, REG_src_2 : std_logic_vector(31 downto 0);
  end record t_exmem_reg;

  type t_memwb_reg is record
    REG_we, MEM_we       : std_logic;
    WB_src_ctrl          : std_logic_vector(1 downto 0);
    REG_dst_idx          : std_logic_vector(4 downto 0);
    pc, ALU_res, MEM_out : std_logic_vector(31 downto 0);
  end record t_memwb_reg;
end package records_pkg;
