library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity memory_tb is
		-- Test bench has no ports
end memory_tb;

architecture testbench of memory_tb is
  signal clk    : std_logic := '0';
  signal we     : std_logic := '0';
  signal rdData : std_logic_vector(31 downto 0);
  signal wrData : std_logic_vector(31 downto 0);
  signal addr   : std_logic_vector(31 downto 0);

  constant clk_period : time := 100 ns;

  -- Instantiate the ram component
  component datamem
    port
    (
      clk    : in std_logic;
      we     : in std_logic;
      rdData : out std_logic_vector(31 downto 0);
      wrData : in std_logic_vector(31 downto 0);
      addr   : in std_logic_vector(31 downto 0)
    );
  end component;

begin

  -- Instantiate the ram component
  ram_inst : datamem
  port map
  (
    clk    => clk,
    we     => we,
    rdData => rdData,
    wrData => wrData,
    addr   => addr
  );

  -- Clock process
  process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  process
  begin
    wait for clk_period; -- Wait for initial stabilization

    -- Write data to memory
    we     <= '1';
    wrData <= x"ABCDEFAB";
    addr   <= x"00000000";
    wait for clk_period;
    we <= '0';

    -- Read data from memory
    addr <= x"00000000"; -- Change the address to match the write address
    wait for clk_period;
		assert rdData = x"ABCDEFAB" report "Memory read data does not match memory write data" severity error;
		report "Test 1 [PASSED]" severity note;

		-- Write data to memory
		we     <= '1';
		wrData <= x"12345678";
		addr   <= x"00000004";
		wait for clk_period;
		we <= '0';

		-- Read data from memory
		addr <= x"00000004"; -- Change the address to match the write address
		wait for clk_period;
		assert rdData = x"12345678" report "Memory read data does not match memory write data" severity error;
		report "Test 2 [PASSED]" severity note;
    
	std.env.stop(0);
  end process;

end architecture;
