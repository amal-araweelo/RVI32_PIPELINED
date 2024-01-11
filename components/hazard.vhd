library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- DOESNT WORK YET

entity hazard_unit is
  port
  (
    -- Inputs
    opcode            : in std_logic_vector(6 downto 0);
    id_reg1_idx       : in std_logic_vector(4 downto 0);
    id_reg2_idx       : in std_logic_vector(4 downto 0);
    ex_reg_wr_idx     : in std_logic_vector(4 downto 0);
    ex_do_read_mem_en : in std_logic;
    mem_do_reg_write    : in std_logic;
    wb_do_reg_write : in std_logic;

    -- Outputs
    hazard_ex_mem_clear : out std_logic;
    hazard_id_ex_enable : out std_logic;
    hazard_fe_enable    : out std_logic -- hazard fetch enable (PC)
  );
end hazard_unit;

architecture behavorial of hazard is

begin
  process (all)
  begin
    hazard_ex_mem_clear <= '0';
    hazard_id_ex_enable <= '1';
    hazard_fe_enable <= '1';

    if id_reg1_idx = "00000" then
	null;
    else
	-- Load-Use Hazard
        if ex_do_read_mem_en = '1' and (ex_reg_wr_idx = id_reg1_idx or ex_reg_wr_idx = id_reg2_idx) then
            hazard_ex_mem_clear <= '1';  -- Stall pipeline
            hazard_id_ex_enable <= '0';
            hazard_fe_enable    <= '0';
        -- EX/MEM Hazard
        elsif mem_do_reg_write = '1' and (ex_reg_wr_idx = id_reg1_idx or ex_reg_wr_idx = id_reg2_idx) then
            hazard_ex_mem_clear <= '1';
            hazard_id_ex_enable <= '0';
            hazard_fe_enable    <= '0';
        -- MEM/WB Hazard
        elsif wb_do_reg_write = '1' and (ex_reg_wr_idx = id_reg1_idx or ex_reg_wr_idx = id_reg2_idx) then
            hazard_ex_mem_clear <= '1';
            hazard_id_ex_enable <= '0';
            hazard_fe_enable    <= '0';
        end if;
    end if;
  end process;
end architecture;
