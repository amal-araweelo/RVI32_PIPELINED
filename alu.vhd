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
  -- Temporary result signal
  signal res_temp : std_logic_vector(32 downto 0) := (others => '0');

begin
  process (all)
  begin
    case ctrl is
      when alu_add =>
        res <= std_logic_vector(signed(op_1) + signed(op_2)); -- sign-extension of both operands
      when alu_sub =>
        res <= std_logic_vector(signed(op_1) - signed(op_2)); -- sign-extension of both operands

      when alu_sl =>
        res <= std_logic_vector(shift_left(unsigned(op_1), to_integer(unsigned(op_2))));

      when alu_slt_s =>
        res_temp <= std_logic_vector(signed(op_1) - signed(op_2));
        if (res_temp(32) = '1') then -- if the result of the signed subtraction is negative
          res <= x"00000001"; -- result is set to 1, since op_1 < op_2
        else
          res <= x"00000000";-- result is set to 0, since op_2 < op_1
        end if;

      when alu_slt_u =>
        res_temp <= std_logic_vector(unsigned('0' & op_1) - unsigned('0' & op_2));
        if (res_temp(32) = '1') then -- if the result of the unsigned subtraction is negative
          res <= x"00000001"; -- result is set to 1, since op_1 < op_2
        else
          res <= x"00000000"; -- result is set to 0, since op_2 < op_2
        end if;

      when alu_xor =>
        res <= op_1 xor op_2;

      when alu_sr =>
        res <= std_logic_vector(shift_right(unsigned(op_1), to_integer(unsigned(op_2))));

      when alu_sra =>
        res <= std_logic_vector(shift_right(signed(op_1), to_integer(unsigned(op_2))));

      when alu_or =>
        res <= op_1 or op_2;

      when alu_and =>
        res <= op_1 and op_2;

      when others =>
        res_temp(32 downto 0) <= (others => '0');
        res                   <= res_temp(31 downto 0);
    end case;
  end process;
end behavorial;
