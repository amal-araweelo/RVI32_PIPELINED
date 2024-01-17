library ieee;
library work;
use ieee.std_logic_1164.all;
use std.env.stop;
use work.mem_op_const.all;

entity data_mem_tb is
end data_mem_tb;

architecture tb_arch of data_mem_tb is
  signal clk          : std_logic                     := '0';
  signal MEM_we       : std_logic                     := '0';
  signal MEM_op       : std_logic_vector(2 downto 0)  := (others => '0');
  signal MEM_data_in  : std_logic_vector(31 downto 0) := (others => '0');
  signal MEM_addr     : std_logic_vector(31 downto 0) := (others => '0');
  signal MEM_data_out : std_logic_vector(31 downto 0);
  signal MEM_IO_out   : std_logic_vector(31 downto 0);

  constant CLK_PERIOD : time := 10 ns;

  component data_mem
    port
    (
      clk          : in std_logic;
      MEM_we       : in std_logic;
      MEM_op       : in std_logic_vector(2 downto 0);
      MEM_data_in  : in std_logic_vector(31 downto 0);
      MEM_addr     : in std_logic_vector(31 downto 0);
      MEM_data_out : out std_logic_vector(31 downto 0);
      MEM_IO_out   : out std_logic_vector(31 downto 0)
    );
  end component;

begin
  UUT : data_mem port map
  (
    clk          => clk,
    MEM_we       => MEM_we,
    MEM_op       => MEM_op,
    MEM_data_in  => MEM_data_in,
    MEM_addr     => MEM_addr,
    MEM_data_out => MEM_data_out,
    MEM_IO_out   => MEM_IO_out
  );

  -- clk_in process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  process
  begin
    wait for 5 * CLK_PERIOD;

    -- Test 1: Store word in memory and load same word from memory
    MEM_we      <= '1';
    MEM_data_in <= x"12345678";
    MEM_op      <= sw;
    MEM_addr    <= x"00000008";

    wait for 5 * CLK_PERIOD;

    MEM_we <= '0';
    MEM_op <= lw;

    wait for CLK_PERIOD;

    if MEM_data_out = x"12345678" then
      report "Test 1 [PASSED]";
    else
      report "Test 1 [FAILED]:  MEM_data_out = " & to_string(MEM_data_out);
      std.env.stop(1);
    end if;

    -- Test 2: Load half word from memory (unsigned)
    MEM_we <= '0';
    MEM_op <= lhu;

    wait for CLK_PERIOD;
    if MEM_data_out = x"00005678" then
      report "Test 2 [PASSED]";
    else
      report "Test 2 [FAILED]: MEM_data_out =" & to_string(MEM_data_out);
      std.env.stop(1);
    end if;

    -- Test 3: Store half word and load half word from memory (signed)
    MEM_we      <= '1';
    MEM_data_in <= x"0000D6F8";
    MEM_op      <= sh;
    MEM_addr    <= x"00000002";

    wait for CLK_PERIOD;
    MEM_we <= '0';
    MEM_op <= lh;

    wait for CLK_PERIOD;
    if MEM_data_out = x"FFFFD6F8" then
      report "Test 3 [PASSED]";
    else
      report "Test 3 [FAILED]: MEM_data_out =" & to_string(MEM_data_out);
      std.env.stop(1);
    end if;

    -- Test 4: Load byte from memory (signed)
    MEM_we <= '0';
    MEM_op <= lb;

    wait for CLK_PERIOD;
    if MEM_data_out = x"FFFFFFF8" then
      report "Test 4 [PASSED]";
    else
      report "Test 4 [FAILED]: MEM_data_out =" & to_string(MEM_data_out);
      std.env.stop(1);
    end if;

    -- Test 5: Load byte unsigned from memory (unsigned)
    MEM_op <= lbu;
    wait for CLK_PERIOD;
    if MEM_data_out = x"000000F8" then
      report "Test 5 [PASSED]";
    else
      report "Test 5 [FAILED]: MEM_data_out =" & to_string(MEM_data_out);
      std.env.stop(1);
    end if;
    wait;
  end process;
end tb_arch;