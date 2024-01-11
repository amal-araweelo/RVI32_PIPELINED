library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- DOESNT WORK YET

entity hazard_unit is
  port
  (
    -- Inputs
    ex_do_read_mem_en : in std_logic;
    ex_reg_wr_idx     : in std_logic_vector(4 downto 0);
    opcode            : in std_logic_vector(5 downto 0);
    id_reg1_idx       : in std_logic_vector(4 downto 0);
    id_reg2_idx       : in std_logic_vector(4 downto 0);

    -- Outputs
    mem_do_reg_write    : in std_logic;
    hazard_ex_mem_clear : in std_logic;
    hazard_id_ex_enable : in std_logic;
    hazard_fe_enable    : in std_logic
  );
end hazard_unit;

architecture behavorial of hazard is

begin
  process (all)
  begin

  end process;
end architecture;