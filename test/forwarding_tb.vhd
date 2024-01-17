library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity forwarding_unit_tb is
end forwarding_unit_tb;

architecture tb_architecture of forwarding_unit_tb is

  component forwarding_unit
    port
    (
      REG_src_idx_1     : in std_logic_vector(4 downto 0);
      REG_src_idx_2     : in std_logic_vector(4 downto 0);
      WB_reg_we         : in std_logic;
      MEM_reg_we        : in std_logic;
      WB_dst_idx        : in std_logic_vector(4 downto 0);
      MEM_dst_idx       : in std_logic_vector(4 downto 0);
      forward_reg_src_1 : out std_logic_vector(1 downto 0);
      forward_reg_src_2 : out std_logic_vector(1 downto 0)
    );
  end component;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal REG_src_idx_1, REG_src_idx_2         : std_logic_vector(4 downto 0) := (others => '0');
  signal WB_reg_we, MEM_reg_we                : std_logic                    := '0';
  signal WB_dst_idx, MEM_dst_idx              : std_logic_vector(4 downto 0) := (others => '0');
  signal forward_reg_src_1, forward_reg_src_2 : std_logic_vector(1 downto 0);

begin
  dut : forwarding_unit
  port map
  (
    REG_src_idx_1     => REG_src_idx_1,
    REG_src_idx_2     => REG_src_idx_2,
    WB_reg_we         => WB_reg_we,
    MEM_reg_we        => MEM_reg_we,
    WB_dst_idx        => WB_dst_idx,
    MEM_dst_idx       => MEM_dst_idx,
    forward_reg_src_1 => forward_reg_src_1,
    forward_reg_src_2 => forward_reg_src_2
  );

  clock_process : process
  begin
    while now < 100 ns loop
      clk <= not clk;
      wait for 5 ns;
    end loop;
    wait;
  end process;

  stimulus_process : process
  begin
    -- Initialize inputs
    REG_src_idx_1 <= "00000";
    REG_src_idx_2 <= "00001";
    WB_reg_we     <= '0';
    MEM_reg_we    <= '0';
    WB_dst_idx    <= "00000";
    MEM_dst_idx   <= "00000";

    -- Apply stimulus
    REG_src_idx_1 <= "00001";
    MEM_reg_we    <= '1';
    wait for 10 ns;
    assert (forward_reg_src_1 = "01" and forward_reg_src_2 = "01") report "Test 1 failed for MEM forwarding" severity failure;

    REG_src_idx_1 <= "00010";
    WB_reg_we     <= '1';
    wait for 10 ns;
    assert (forward_reg_src_1 = "01" and forward_reg_src_2 = "01") report "Test 2 failed for WB forwarding" severity failure;

    REG_src_idx_2 <= "00010";
    WB_reg_we     <= '1';
    wait for 10 ns;
    assert (forward_reg_src_1 = "01" and forward_reg_src_2 = "01") report "Test 3 failed for WB forwarding" severity failure;

    wait;
  end process;

end tb_architecture;
