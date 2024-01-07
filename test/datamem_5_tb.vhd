library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity datamem_5_tb is
  -- Testbench has no ports
end datamem_5_tb;

architecture behavorial of datamem_5_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component datamem_5 is
    port
    (
      pc_in : in std_logic_vector(31 downto 0);
      r1_in : in std_logic_vector(31 downto 0);
      r2_in : in std_logic_vector(31 downto 0);

      mem_do_write_in : in std_logic; -- write enable
      mem_op_in       : in std_logic_vector(2 downto 0); -- memory operation

      clk      : in std_logic; -- clock
      data_in  : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(31 downto 0);
      addr     : in std_logic_vector(31 downto 0) -- address
    );
  end component;

  signal pc_in : std_logic_vector(31 downto 0) := (others => '0');
  signal r1_in : std_logic_vector(31 downto 0) := (others => '0');
  signal r2_in : std_logic_vector(31 downto 0) := (others => '0');

  signal mem_do_write_in : std_logic                    := '0'; -- write enable
  signal mem_op_in       : std_logic_vector(2 downto 0) := (others => '0'); -- memory operation

  signal clk      : std_logic                     := '0'; -- clock
  signal data_in  : std_logic_vector(31 downto 0) := (others => '0');
  signal data_out : std_logic_vector(31 downto 0) := (others => '0');
  signal addr     : std_logic_vector(31 downto 0) := (others => '0'); -- address

  -- clk period definitions
  constant clk_period : time := 100 ns;

begin
  -- Instantiate the Unit Under Test (UUT)
  uut : datamem_5 port map
  (
    pc_in, r1_in, r2_in, mem_do_write_in, mem_op_in, clk, data_in, data_out, addr
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
    mem_do_write_in <= '1';
    mem_op_in       <= sw; -- Store word operation
    data_in         <= x"12345678"; -- Example data
    addr            <= x"00000000"; -- Memory address
    wait for clk_period;

    -- Read same word from memory
    mem_do_write_in <= '0';
    mem_op_in       <= lw; -- Load word operation
    wait for clk_period;

    assert data_out = x"12345678" report "Read or store word failed" severity error;
    report "Test 1 [PASSED]";
    std.env.stop(0);
  end process;
end behavorial;