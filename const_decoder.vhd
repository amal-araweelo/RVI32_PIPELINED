
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
    constant DEC_U_AUIPC                : std_logic_vector(6 downto 0) := "0010111";
    constant DEC_U_LUI                  : std_logic_vector(6 downto 0) := "0110111";
    constant DEC_S                      : std_logic_vector(6 downto 0) := "0100011";
    constant DEC_UJ                     : std_logic_vector(6 downto 0) := "1101111";

end package const_decoder;

