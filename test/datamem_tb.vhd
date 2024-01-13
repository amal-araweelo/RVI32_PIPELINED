library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity datamem_tb is
  -- Testbench has no ports
end datamem_tb;

architecture behavorial of datamem_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component data_mem is
    port
    (
      -- Inputs
      clk         : in std_logic                     := '0'; -- clock
      MEM_we      : in std_logic                     := '0'; -- write enable
      MEM_op      : in std_logic_vector              := "000"; -- memory operation
      MEM_data_in : in std_logic_vector(31 downto 0) := (others => '0');
      MEM_addr    : in std_logic_vector(31 downto 0) := (others => '0'); -- address (it is the value stored in register 2)

      -- Outputs
      MEM_data_out : out std_logic_vector(31 downto 0) := (others => '0')
    );
  end component;

  -- Inputs
  signal clk         : std_logic                     := '0'; -- clock
  signal MEM_we      : std_logic                     := '0'; -- write enable
  signal MEM_op      : std_logic_vector(2 downto 0)  := (others => '0'); -- memory operation
  signal MEM_data_in : std_logic_vector(31 downto 0) := (others => '0');
  signal MEM_addr    : std_logic_vector(31 downto 0) := (others => '0'); -- address (it is the value stored in register 2)

  -- Outputs
  signal MEM_data_out : std_logic_vector(31 downto 0) := (others => '0');

  -- clk period definitions
  constant clk_period : time := 100 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : data_mem port map
  (
    clk          => clk,
    MEM_we       => MEM_we,
    MEM_op       => MEM_op,
    MEM_data_in  => MEM_data_in,
    MEM_addr     => MEM_addr,
    MEM_data_out => MEM_data_out
  );

  -- Clock process
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  --   Stimulus process
  stimulus : process
  begin

    -- Test for load and store word
    MEM_op      <= sw; -- Store word operation
    MEM_we      <= '1';
    MEM_data_in <= x"12345678"; -- Example data for store word
    MEM_addr    <= x"00000000";
    wait for clk_period;

    MEM_we   <= '0';
    MEM_op   <= lw; -- Load word operation
    MEM_addr <= x"00000000";
    wait for clk_period;

    assert MEM_data_out = x"12345678" report "Test for store word and load word failed" severity error;
    report "Test for store word and load word [PASSED]";

    -- Test for load and store half-word
    MEM_op      <= sh; -- Store half-word operation
    MEM_we      <= '1';
    MEM_data_in <= x"0000ABCD"; -- Example data for store half-word
    MEM_addr    <= x"00000004"; -- Address for storing half-word
    wait for clk_period;

    MEM_we   <= '0';
    MEM_op   <= lh; -- Load half-word operation
    MEM_addr <= x"00000004"; -- Address for loading half-word
    wait for clk_period;

    assert MEM_data_out = x"FFFFABCD" report "Test for store half-word and load half-word failed" severity error;
    report "Test for store half-word and load half-word [PASSED]";

    MEM_op <= lhu; -- Load half-word unsigned operation
    wait for clk_period;
    assert MEM_data_out = x"0000ABCD" report "Test for load half-word unsigned failed" severity error;
    report "Test for store half-word and load half-word [PASSED]";

    -- Test for store byte and load byte
    MEM_op      <= sb; -- Store byte operation
    MEM_we      <= '1';
    MEM_data_in <= x"000000EF"; -- Example data for store byte
    MEM_addr    <= x"00000008"; -- Address for storing byte
    wait for clk_period;

    -- Test for store byte and load byte
    MEM_op      <= sb; -- Store byte operation
    MEM_we      <= '1';
    MEM_data_in <= x"000000EF"; -- Example data for store byte
    MEM_addr    <= x"00000008"; -- Address for storing byte
    wait for clk_period;

    MEM_we   <= '0';
    MEM_op   <= lb; -- Load byte operation
    MEM_addr <= x"00000008"; -- Address for loading byte
    wait for clk_period;
    assert MEM_data_out = x"FFFFFFEF" report "Test for store byte and load byte failed" severity error;
    report "Test for store byte and load byte [PASSED]";

    MEM_op   <= lbu; -- Load byte unsigned operation
    MEM_addr <= x"00000008"; -- Address for loading byte
    wait for clk_period;
    assert MEM_data_out = x"000000EF" report "Test for load unsigned byte failed" severity error;
    report "Test for store byte and load byte [PASSED]";

    std.env.stop(0);
  end process;

end behavorial;