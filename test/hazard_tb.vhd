library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity hazard_unit_tb is
end entity hazard_unit_tb;

architecture testbench of hazard_unit_tb is
  component hazard_unit
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
  end component;

  signal sel_pc           : std_logic                    := '0';
  signal ID_REG_src_idx_1 : std_logic_vector(4 downto 0) := (others => '0');
  signal ID_REG_src_idx_2 : std_logic_vector(4 downto 0) := (others => '0');
  signal EX_REG_dst_idx   : std_logic_vector(4 downto 0) := (others => '0');
  signal MEM_rd           : std_logic                    := '0';

  signal hazard_idex_en  : std_logic;
  signal hazard_idex_clr : std_logic;
  signal hazard_ifid_en  : std_logic;
  signal hazard_ifid_clr : std_logic;
  signal hazard_fetch_en : std_logic;

begin
  -- Instantiate the Unit Under Test (UUT)
  uut : hazard_unit port map
  (
    sel_pc, ID_REG_src_idx_1, ID_REG_src_idx_2, EX_REG_dst_idx, MEM_rd, hazard_idex_en, hazard_idex_clr, hazard_ifid_en, hazard_ifid_clr, hazard_fetch_en
  );

  -- Stimulus process
  stim_proc : process
  begin

    wait for 5 ns;

    -- Test 1: No hazard
    ID_REG_src_idx_1 <= "00000";
    ID_REG_src_idx_2 <= "00000";
    EX_REG_dst_idx   <= "00000";
    MEM_rd           <= '0';
    sel_pc           <= '0';

    wait for 5 ns;
    assert (hazard_idex_en = '1' and hazard_idex_clr = '0' and hazard_ifid_en = '1' and hazard_ifid_clr = '0' and hazard_fetch_en = '1') report "Test 1 failed" severity error;

    -- Test 2: Load-Use Hazard
    ID_REG_src_idx_1 <= "00001";
    ID_REG_src_idx_2 <= "00000";
    EX_REG_dst_idx   <= "00001";
    MEM_rd           <= '1';
    sel_pc           <= '0';

    wait for 5 ns;
    assert (hazard_idex_en = '0' and hazard_idex_clr = '1' and hazard_ifid_en = '0' and hazard_ifid_clr = '0' and hazard_fetch_en = '0') report "Test 2 failed" severity error;

    -- Test 3: Control Hazard
    ID_REG_src_idx_1 <= "00010";
    ID_REG_src_idx_2 <= "00010";
    EX_REG_dst_idx   <= "00001";
    MEM_rd           <= '0';
    sel_pc           <= '1';
    wait for 5 ns;
    assert (hazard_idex_en = '1' and hazard_idex_clr = '1' and hazard_ifid_en = '1' and hazard_ifid_clr = '1' and hazard_fetch_en = '1') report "Test 3 failed" severity error;

    wait;
  end process;
end architecture;