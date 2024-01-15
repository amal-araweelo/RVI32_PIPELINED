library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- DOESNT WORK YET

entity hazard_unit is
  port
  (

    -------------------- Inputs ---------------------------
    do_branch        : in std_logic;
    opcode           : in std_logic_vector(6 downto 0);
    ID_REG_src_idx_1 : in std_logic_vector(4 downto 0);
    ID_REG_src_idx_2 : in std_logic_vector(4 downto 0);
    EX_REG_dst_idx   : in std_logic_vector(4 downto 0);
    EX_MEM_rd        : in std_logic;
    MEM_REG_we       : in std_logic;
    WB_REG_we        : in std_logic;

    -------------------- Outputs ---------------------------
    -- EX/MEM register
    hazard_exmem_clr : out std_logic;

    -- ID/EX register
    hazard_idex_en  : out std_logic;
    hazard_idex_clr : out std_logic;

    -- IF/ID register
    hazard_ifid_en  : out std_logic;
    hazard_ifid_clr : out std_logic;

    -- PC
    hazard_fetch_en : out std_logic -- hazard fetch enable (PC)
  );
end hazard_unit;

architecture behavorial of hazard_unit is
begin
  process (all)
  begin
    -- Disabling the clear signals by default
    hazard_exmem_clr <= '0';
    hazard_ifid_clr  <= '0';

    -- Enabling the state registers by default
    hazard_idex_en  <= '1';
    hazard_ifid_en  <= '1';
    hazard_fetch_en <= '1';

    -- TODO: Look at the first three and test them

    -- Load-Use Hazard
    if ((EX_MEM_rd = '1') and (EX_REG_dst_idx = ID_REG_src_idx_1) or (EX_REG_dst_idx = ID_REG_src_idx_2)) then
      hazard_exmem_clr <= '1'; -- Stall pipeline
      hazard_idex_en   <= '0';
      hazard_fetch_en  <= '0';

      -- EX/MEM Hazard
    elsif ((MEM_REG_we = '1') and (EX_REG_dst_idx = ID_REG_src_idx_1) or (EX_REG_dst_idx = ID_REG_src_idx_2)) then
      hazard_exmem_clr <= '1';
      hazard_idex_en   <= '0';
      hazard_fetch_en  <= '0';

      -- MEM/WB Hazard
    elsif ((WB_REG_we = '1') and (EX_REG_dst_idx = ID_REG_src_idx_1) or (EX_REG_dst_idx = ID_REG_src_idx_2)) then
      hazard_exmem_clr <= '1';
      hazard_idex_en   <= '0';
      hazard_fetch_en  <= '0';

      -- Flush IF and ID stage in case of a branch
    elsif (do_branch = '1') then
      hazard_idex_clr <= '1';
      hazard_ifid_clr <= '1';
    end if;
  end process;
end behavorial;