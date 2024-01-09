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
  component datamem is
    port
    (
      -- Inputs
      clk         : in std_logic                     := '0'; -- clock
      pc          : in std_logic_vector(31 downto 0) := (others => '0');
      MEM_we      : in std_logic                     := '0'; -- write enable
      MEM_op      : in std_logic_vector(3 downto 0)  := (others => '0'); -- memory operation
      MEM_data_in : in std_logic_vector(31 downto 0) := (others => '0');
      MEM_addr    : in std_logic_vector(31 downto 0) := (others => '0'); -- address (it is the value stored in register 2)

      -- Outputs
      MEM_data_out : out std_logic_vector(31 downto 0) := (others => '0')
    );
  end component;

  -- Inputs
  signal clk         : std_logic                     := '0'; -- clock
  signal pc          : std_logic_vector(31 downto 0) := (others => '0');
  signal MEM_we      : std_logic                     := '0'; -- write enable
  signal MEM_op      : std_logic_vector(3 downto 0)  := (others => '0'); -- memory operation
  signal MEM_data_in : std_logic_vector(31 downto 0) := (others => '0');
  signal MEM_addr    : std_logic_vector(31 downto 0) := (others => '0'); -- address (it is the value stored in register 2)

  -- Outputs
  signal MEM_data_out : std_logic_vector(31 downto 0) := (others => '0');

  -- clk period definitions
  constant clk_period : time := 100 ns;

begin
  -- Instantiate the Unit Under Test (UUT)
  uut : datamem port map
  (
    clk, pc, MEM_we, MEM_op, MEM_data_in, MEM_addr, MEM_data_out
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

    -- Store word in memory
    MEM_we      <= '1';
    MEM_op      <= sw; -- Store word operation
    MEM_data_in <= x"12345678"; -- Example data
    MEM_addr    <= x"00000000"; -- Memory address
    wait for clk_period;

    -- Read same word from memory
    MEM_we <= '0';
    MEM_op <= lw; -- Load word operation
    wait for clk_period;

    assert MEM_data_out = x"12345678" report "Read or store word failed" severity error;
    report "Test 1 [PASSED]";
    std.env.stop(0);
  end process;
end behavorial;