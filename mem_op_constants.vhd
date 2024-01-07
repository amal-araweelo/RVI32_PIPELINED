-- Memory operation control constants
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mem_op_const is
  constant sw : std_logic_vector(2 downto 0) := "000";
  constant sh : std_logic_vector(2 downto 0) := "001";
  constant sb : std_logic_vector(2 downto 0) := "010";
  constant lw : std_logic_vector(2 downto 0) := "011";
  constant lh : std_logic_vector(2 downto 0) := "100";
  constant lb : std_logic_vector(2 downto 0) := "101";
end mem_op_const;