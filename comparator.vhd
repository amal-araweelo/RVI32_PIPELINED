library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;

-- note: this block is called 'branch' in Ripes

entity comparator is
  port
  (
    ctrl : in std_logic_vector(3 downto 0)  := (others => '0');
    op_1 : in std_logic_vector(31 downto 0) := (others => '0');
    op_2 : in std_logic_vector(31 downto 0) := (others => '0');
    res  : out std_logic                    := '0' -- if branch is taken, result is true
  );
end comparator;

architecture behavior of comparator is
begin
  process (all)
  begin
    case ctrl is
      when alu_beq => -- BEQ
        if (op_1 = op_2) then
          res <= '1';
        else
          res <= '0';
        end if;
      when alu_bne => -- BNE
        if (op_1 /= op_2) then
          res <= '1';
        else
          res <= '0';
        end if;
      when alu_blt => -- BLT
        if (signed(op_1) < signed(op_2)) then
          res <= '1';
        else
          res <= '0';
        end if;
      when alu_bge => -- BGE
        if (signed(op_1) >= signed(op_2)) then
          res <= '1';
        else
          res <= '0';
        end if;
      when alu_blt_u => -- BLT_U
        if (unsigned(op_1) < unsigned(op_2)) then
          res <= '1';
        else
          res <= '0';
        end if;
      when alu_bge_u => -- BGE_U
        if (unsigned(op_1) >= unsigned(op_2)) then
          res <= '1';
        else
          res <= '0';
        end if;
      when others =>
        res <= '0';
    end case;
  end process;
end behavior;
