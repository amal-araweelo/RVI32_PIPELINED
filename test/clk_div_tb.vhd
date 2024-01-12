library ieee;
use ieee.std_logic_1164.all;

entity clk_div_tb is
  -- Testbench has no ports
end clk_div_tb;

architecture behavior of clk_div_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component clk_div is
    port
    (
      clk_in  : in  std_logic := '0';
      clk_out : out std_logic
    );
  end component;

  -- Inputs
  signal clk_in : std_logic := '0';

  -- Outputs
  signal clk_out : std_logic;

  -- clk period definitions
  constant clk_period : time := 2000 ms;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : clk_div port map
  (
    clk_in  => clk_in,
    clk_out => clk_out
  );

  -- clk_in process definitions
  clk_in_process : process
  begin
    clk_in <= '0';
    wait for clk_period/2;
    clk_in <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  stim_proc : process
  begin
    wait for clk_period;
    -- Check clock output
    assert clk_out = '0' report "Initial assertion failed " & to_string(clk_out) severity error;
    wait for 0.5 * clk_period;
    wait for 5 ps;

    -- Check if the divided clock toggled
    assert clk_out = '1' report "Clock division 1 failed "  & to_string(clk_out) severity error;
    wait for 0.5 * clk_period;
    wait for 1 ns;

       -- Check if the divided clock toggled
       assert clk_out = '0' report "Clock division 2 failed "  & to_string(clk_out) severity error;
       wait for 0.5 * clk_period;
       wait for 1 ns;

    -- Check if the divided clock toggled again
    assert clk_out = '1' report "Clock division 3 failed " & to_string(clk_out) severity error;

    -- Finish simulation
    std.env.stop(0);
  end process;

end behavior;
