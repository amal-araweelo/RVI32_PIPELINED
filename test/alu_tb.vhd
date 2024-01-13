library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.env.stop;

library work;
use work.alu_ctrl_const.all;

entity alu_tb is
  -- Testbench has no ports
end alu_tb;

architecture behavior of alu_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component alu is
    port
    (
      op_1, op_2 : in std_logic_vector(31 downto 0);
      ctrl       : in std_logic_vector(3 downto 0);
      res        : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Inputs
  signal clk  : std_logic                     := '0';
  signal op_1 : std_logic_vector(31 downto 0) := (others => '0');
  signal op_2 : std_logic_vector(31 downto 0) := (others => '0');
  signal ctrl : std_logic_vector(3 downto 0)  := (others => '0');

  -- Outputs
  signal res : std_logic_vector(31 downto 0);

  -- clk period definitions
  constant clk_period : time := 100 ns;
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : alu port map
  (
    op_1, op_2, ctrl,
    res
  );

  -- clk process definitions
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

    -- Test Addition
    op_1 <= x"00000001";
    op_2 <= x"00000001";
    ctrl <= alu_add;
    wait for clk_period;
    assert res = x"00000002" report "Addition failed" severity error;
    report "Test 1 [PASSED]";

    -- Test subtraction
    op_1 <= x"00000005";
    op_2 <= x"00000001";
    ctrl <= alu_sub;
    wait for clk_period;
    assert res = x"00000004" report "Subtraction failed" severity error;
    report "Test 2 [PASSED]";

    -- Test shift left logical
    op_1 <= x"00000010";
    op_2 <= x"00000001";
    ctrl <= alu_sl;
    wait for clk_period;
    assert res = x"00000020" report "Shift left logical failed" severity error;
    report "Test 3 [PASSED]";

    -- Test SLT signed
    op_1 <= x"00000005";
    op_2 <= x"FFFFFFFB"; -- minus 5
    ctrl <= alu_slt_s;
    wait for clk_period;
    assert res = x"00000000" report "SLT signed failed" severity error;
    report "Test 4 [PASSED]";

    -- Test SLT unsigned
    op_1 <= x"00000005";
    op_2 <= x"0000000A";
    ctrl <= alu_slt_u;
    wait for clk_period;
    assert res = x"00000001" report "SLT unsigned failed" severity error;
    report "Test 5 [PASSED]";

    -- Test XOR
    op_1 <= x"0000000A";
    op_2 <= x"00000005";
    ctrl <= alu_xor;
    wait for clk_period;
    assert res = x"0000000F" report "XOR failed" severity error;
    report "Test 6 [PASSED]";

    -- Test SR (shift right logical)
    op_1 <= x"00000020";
    op_2 <= x"00000001";
    ctrl <= alu_sr;
    wait for clk_period;
    assert res = x"00000010" report "Shift right logical failed" severity error;
    report "Test 7 [PASSED]";

    -- Test SRA (shift right arithmetic)
    op_1 <= x"FFFFFFFE";
    op_2 <= x"00000001";
    ctrl <= alu_sra;
    wait for clk_period;
    assert res = x"FFFFFFFF" report "Shift right arithmetic failed" severity error;
    report "Test 8 [PASSED]";

    -- Test OR
    op_1 <= x"0000000F";
    op_2 <= x"00000001";
    ctrl <= alu_or;
    wait for clk_period;
    assert res = x"0000000F" report "OR failed" severity error;
    report "Test 9 [PASSED]";

    -- Test AND
    op_1 <= x"0000000F";
    op_2 <= x"00000005";
    ctrl <= alu_and;
    wait for clk_period;
    assert res = x"00000005" report "AND failed" severity error;
    report "Test 10 [PASSED]";
    -- finish simulation
    std.env.stop(0);
  end process;
end behavior;
