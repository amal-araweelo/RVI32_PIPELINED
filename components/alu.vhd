library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;

entity alu is
  port
  (
    op_1, op_2 : in std_logic_vector(31 downto 0);
    ctrl       : in std_logic_vector(3 downto 0);
    res        : out std_logic_vector(31 downto 0)
  );
end alu;

architecture behavorial of alu is
begin
  process (all)
  begin

    case ctrl is
      when alu_add | alu_bne | alu_beq | alu_bge | alu_bge_u | alu_blt | alu_blt_u =>
        res <= std_logic_vector(signed(op_1) + signed(op_2));
      when alu_sub =>
        res <= std_logic_vector(signed(op_1) - signed(op_2)); -- sign-extension of both operands
      when alu_sl =>
        res <= std_logic_vector(shift_left(unsigned(op_1), to_integer(unsigned(op_2(4 downto 0)))));
      when alu_slt_s =>
        if (signed(op_1) < signed(op_2)) then -- if the result of the signed subtraction is negative
          res <= x"00000001"; -- result is set to 1, since op_1 < op_2
        else
          res <= x"00000000"; -- result is set to 0, since op_2 < op_1
        end if;
      when alu_slt_u =>
        if (unsigned(op_1) < unsigned(op_2)) then
          res <= x"00000001"; -- result is set to 1, since op_1 < op_2
        else
          res <= x"00000000"; -- result is set to 0, since op_2 < op_2
        end if;
      when alu_xor =>
        res <= op_1 xor op_2;
      when alu_sr =>
        res <= std_logic_vector(shift_right(unsigned(op_1), to_integer(unsigned(op_2(4 downto 0)))));
      when alu_sra =>
        res <= std_logic_vector(shift_right(signed(op_1), to_integer(unsigned(op_2(4 downto 0)))));
      when alu_or =>
        res <= op_1 or op_2;
      when alu_and =>
        res <= op_1 and op_2;
      when others    =>
        res <= (others => '0');
    end case;
  end process;
end behavorial;