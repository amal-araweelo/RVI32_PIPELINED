
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


package const_decoder is 
    -- OPCODES
    constant DEC_I_LOAD                 : std_logic_vector(6 downto 0) := "0000011";
    constant DEC_I_ADD_SHIFT_LOGICOPS   : std_logic_vector(6 downto 0) := "0010011";
    constant DEC_I_ADDW_SHIFTW          : std_logic_vector(6 downto 0) := "0011011";
    constant DEC_I_JALR                 : std_logic_vector(6 downto 0) := "1100111";
    constant DEC_R_OPS                  : std_logic_vector(6 downto 0) := "0110011";
    constant DEC_R_OPSW                 : std_logic_vector(6 downto 0) := "0111011";
    constant DEC_U                      : std_logic_vector(6 downto 0) := "0010111";
    constant DEC_S                      : std_logic_vector(6 downto 0) := "0100011";
    constant DEC_UJ                     : std_logic_vector(6 downto 0) := "1101111";

end package const_decoder;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

--TODO REMOVE FOLLOWING BEFORE MERGE
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