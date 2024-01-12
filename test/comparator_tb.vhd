library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;


entity comparator_tb is
  -- Testbench has no ports
end comparator_tb;

architecture behavior of comparator_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component comparator is
    port
    (
      ctrl : in std_logic_vector(3 downto 0)  := (others => '0');
      op_1 : in std_logic_vector(31 downto 0) := (others => '0');
      op_2 : in std_logic_vector(31 downto 0) := (others => '0');
      res  : out std_logic                    := '0'
    );
  end component;

  -- Inputs
  signal ctrl : std_logic_vector(3 downto 0)  := (others => '0');
  signal op_1 : std_logic_vector(31 downto 0) := (others => '0');
  signal op_2 : std_logic_vector(31 downto 0) := (others => '0');

  -- Outputs
  signal res : std_logic := '0';

  -- clk period definitions
  constant clk_period : time := 100 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : comparator port map
  (
    ctrl,
    op_1,
    op_2,
    res
  );

  -- Stimulus process
  stim_proc : process
  begin

    -- Test BEQ (Branch if Equal)
    op_1 <= x"00000005";
    op_2 <= x"00000005";
    ctrl <= alu_beq;
    wait for clk_period;
    assert res = '1' report "BEQ failed" severity error;
    report "Test BEQ [PASSED]";

    -- Test BNE (Branch if Not Equal)
    op_1 <= x"00000005";
    op_2 <= x"00000002";
    ctrl <= alu_bne;
    wait for clk_period;
    assert res = '1' report "BNE failed" severity error;
    report "Test BNE [PASSED]";

    -- Test BLT (Branch if Less Than)
    op_1 <= x"00000002";
    op_2 <= x"00000005";
    ctrl <= alu_blt;
    wait for clk_period;
    assert res = '1' report "BLT failed" severity error;
    report "Test BLT [PASSED]";

    -- Test BGE (Branch if Greater or Equal)
    op_1 <= x"00000005";
    op_2 <= x"00000002";
    ctrl <= alu_bge;
    wait for clk_period;
    assert res = '1' report "BGE failed" severity error;
    report "Test BGE [PASSED]";

    -- Test BLT_U (Branch if Less Than Unsigned)
    op_1 <= x"00000002";
    op_2 <= x"00000005";
    ctrl <= alu_blt_u;
    wait for clk_period;
    assert res = '1' report "BLT_U failed" severity error;
    report "Test BLT_U [PASSED]";

    -- Test BGE_U (Branch if Greater or Equal Unsigned)
    op_1 <= x"00000005";
    op_2 <= x"00000002";
    ctrl <= alu_bge_u;
    wait for clk_period;
    assert res = '1' report "BGE_U failed" severity error;
    report "Test BGE_U [PASSED]";

    -- finish simulation
    std.env.stop(0);
  end process;

end behavior;
