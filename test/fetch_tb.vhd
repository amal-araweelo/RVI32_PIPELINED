library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.env.stop;

entity fetcher_tb is
  -- Testbench has no ports
end fetcher_tb;

architecture behavior of fetcher_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component fetcher
    port
    (
      clk, sel_pc, clr, en : in std_logic;
      pc                   : out std_logic_vector (31 downto 0);
      branch_addr          : in std_logic_vector (31 downto 0);
      instr                : out std_logic_vector (31 downto 0)
    );
  end component;

  -- Inputs
  signal clk         : std_logic                     := '0';
  signal sel_pc      : std_logic                     := '0';
  signal clr         : std_logic                     := '1';
  signal en          : std_logic                     := '0';
  signal branch_addr : std_logic_vector(31 downto 0) := (others => '0');

  -- Outputs
  signal pc_out : std_logic_vector(31 downto 0);
  signal instr  : std_logic_vector(31 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : fetcher port map
  (
    clk, sel_pc, clr,
    en,
    pc_out,
    branch_addr,
    instr
  );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  stim_proc : process
  begin
    clr    <= '1';
    sel_pc <= '0';
    en     <= '1';
    wait for clk_period;

    clr <= '0';

    -- Test 1

    if pc_out = x"00000000" then
      report "Test 1 [PASSED]";
    else
      report "Test 1 [FAILED]";
      std.env.stop(1);
    end if;

    -- Test 2

    clr <= '0';
    wait for clk_period;

    if pc_out = x"00000004" then
      report "Test 2 [PASSED]";
    else
      report "Test 2 [FAILED]";
      std.env.stop(1);
    end if;

    -- Test 3

    wait for clk_period;

    if pc_out = x"00000008" then
      report "Test 3 [PASSED]";
    else
      report "Test 3 [FAILED]";
      std.env.stop(1);
    end if;

    -- Test 4

    wait for clk_period;

    if pc_out = x"0000000C" then
      report "Test 4 [PASSED]";
    else
      report "Test 4 [FAILED]";
      std.env.stop(1);
    end if;

    -- Test 5
    sel_pc      <= '1';
    branch_addr <= x"00000123";
    wait for clk_period;

    if pc_out = x"00000123" then
      report "Test 5 [PASSED]";
    else
      report "Test 5 [FAILED]";
      std.env.stop(1);
    end if;

    -- Test 6

    wait for clk_period;

    sel_pc      <= '0';
    branch_addr <= x"00000123";
    wait for clk_period;

    if pc_out = x"00000127" then
      report "Test 6 [PASSED]";
    else
      report "Test 6 [FAILED]";
      std.env.stop(1);
    end if;

    -- finish simulation
    std.env.stop(0);
  end process;
end behavior;