-- ALU control constants

library ieee;
use ieee.std_logic_1164.all;
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
