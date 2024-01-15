library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity hazard_unit is
  port
  (

    -------------------- Inputs ---------------------------
    sel_pc           : in std_logic;
    ID_REG_src_idx_1 : in std_logic_vector(4 downto 0);
    ID_REG_src_idx_2 : in std_logic_vector(4 downto 0);
    EX_REG_dst_idx   : in std_logic_vector(4 downto 0);
    MEM_rd           : in std_logic;
    -------------------- Outputs ---------------------------

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
    hazard_ifid_clr <= '0';
    hazard_idex_clr <= '0';

    -- Enabling the state registers by default
    hazard_idex_en  <= '1';
    hazard_ifid_en  <= '1';
    hazard_fetch_en <= '1';

    -- Load-Use Hazard (Stalls the pipeline for 1 clock cycle and inserts nop in between)
    if ((MEM_rd = '1') and ((EX_REG_dst_idx = ID_REG_src_idx_1) or (EX_REG_dst_idx = ID_REG_src_idx_2))) then
      hazard_ifid_en  <= '0'; -- disable IF/ID register
      hazard_idex_en  <= '0'; -- disable ID/EX register
      hazard_fetch_en <= '0'; -- disable PC
      hazard_idex_clr <= '1'; -- clear ID/EX register (inserts nop)
    end if;

    -- Control Hazard (flush IF and ID stage in case of branch, jump)
    if (sel_pc = '1') then
      hazard_idex_clr <= '1';
      hazard_ifid_clr <= '1';
    end if;
  end process;
end behavorial;