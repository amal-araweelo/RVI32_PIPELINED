library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use work.const_decoder.all;
use work.mem_op_const.all;

entity reg_file_tb is
end entity reg_file_tb;

architecture tb_arch of reg_file_tb is
  signal clk            : std_logic                     := '0';
  signal REG_we         : std_logic                     := '0';
  signal REG_src_idx_1  : std_logic_vector(4 downto 0)  := "00000";
  signal REG_src_idx_2  : std_logic_vector(4 downto 0)  := "00001";
  signal REG_dst_idx    : std_logic_vector(4 downto 0)  := "00010";
  signal REG_write_data : std_logic_vector(31 downto 0) := x"DEADBEEF";
  signal REG_src_1      : std_logic_vector(31 downto 0);
  signal REG_src_2      : std_logic_vector(31 downto 0);

  component reg_file
    generic
    (
      B : integer := 32;
      W : integer := 5
    );
    port
    (
      clk, REG_we                  : in std_logic;
      REG_src_idx_1, REG_src_idx_2 : in std_logic_vector(4 downto 0);
      REG_dst_idx                  : in std_logic_vector(4 downto 0);
      REG_write_data               : in std_logic_vector(B - 1 downto 0);
      REG_src_1, REG_src_2         : out std_logic_vector(B - 1 downto 0)
    );
  end component;

  constant CLK_PERIOD : time := 10 ns;

begin
  -- Instantiate the reg_file component
  uut : reg_file
  generic
  map (
  B => 32,
  W => 5
  )
  port map
  (
    clk            => clk,
    REG_we         => REG_we,
    REG_src_idx_1  => REG_src_idx_1,
    REG_src_idx_2  => REG_src_idx_2,
    REG_dst_idx    => REG_dst_idx,
    REG_write_data => REG_write_data,
    REG_src_1      => REG_src_1,
    REG_src_2      => REG_src_2
  );

  -- Clock process
  process
  begin
    while now < 1000 ns loop
      clk <= not clk;
      wait for CLK_PERIOD / 2;
    end loop;
    wait;
  end process;

  -- Stimulus process
  process
  begin
    wait for CLK_PERIOD; -- Wait for initial signals to settle

    -- Test: Write to register at address "00010"
    REG_we         <= '1';
    REG_dst_idx    <= "00010";
    REG_write_data <= x"12345678";
    wait for CLK_PERIOD;
    REG_we <= '0';

    -- Test: Read from registers at addresses "00000" and "00001"
    REG_src_idx_1 <= "00001";
    REG_src_idx_2 <= "00010";
    wait for CLK_PERIOD;
    assert REG_src_1 = "00000000000000000000000000000000" report "Test 1 failed" severity failure;
    assert REG_src_2 = "00010010001101000101011001111000" report "Test 2 failed" severity failure;
    wait for CLK_PERIOD;
    assert REG_src_1 = "00000000000000000000000000000000" report "Test 3 failed" severity failure;
    assert REG_src_2 = "00010010001101000101011001111000" report "Test 4 failed" severity failure;

    -- Test: Write to register while reading from two registers
    REG_we         <= '1';
    REG_dst_idx    <= "00011";
    REG_write_data <= x"12345678";
    assert REG_src_1 = "00000000000000000000000000000000" report "Test 5 failed" severity failure;
    assert REG_src_2 = "00010010001101000101011001111000" report "Test 6 failed" severity failure;

    wait for CLK_PERIOD;
    REG_src_idx_2 <= "00011";
    assert REG_src_1 = "00000000000000000000000000000000" report "Test 7 failed" severity failure;
    assert REG_src_2 = "00010010001101000101011001111000" report "Test 8 failed" severity failure;
    REG_src_idx_2 <= "00010";
    wait for CLK_PERIOD;
    assert REG_src_2 = "00010010001101000101011001111000" report "Test 9 failed" severity failure;

    wait;
  end process;

end tb_arch;