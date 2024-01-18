library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;
use work.records_pkg.all;

entity cpu_tb is
  -- Testbench has no ports
end cpu_tb;

architecture behavior of cpu_tb is

    component cpu is
      port
      (
	--    clk: in std_logic
	clk   : in std_logic;
	reset : in std_logic;
	led   : out std_logic_vector(15 downto 0)
      );
    end component;

  -- Reset signal
  signal reset : std_logic := '0';

  -- Clock signal
  signal clk          : std_logic := '0';
  constant clk_period : time      := 10 ns;


begin

  -- Instantiate the Unit Under Test (UUT)
  uut: cpu port map (
	clk   => clk,
	reset => reset,
	led   => open
  );

  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    reset <= '1';
    wait for 1 ns;
    reset <= '0';

    wait; 
  end process;

end behavior;
