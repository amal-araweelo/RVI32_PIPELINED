library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity write_back_tb is
  -- Testbench has no ports
end write_back_tb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity write_back_tb is
end write_back_tb;

architecture behavioral of write_back_tb is
  signal WB_src_ctrl    : std_logic_vector(1 downto 0)  := "00";
  signal pc             : std_logic_vector(31 downto 0) := (others => '0');
  signal ALU_res        : std_logic_vector(31 downto 0) := (others => '0');
  signal MEM_out        : std_logic_vector(31 downto 0) := (others => '0');
  signal REG_write_data : std_logic_vector(31 downto 0) := (others => '0');

  -- Instantiate the write_back_5 component
  component write_back
    port
    (
      WB_src_ctrl    : in std_logic_vector(1 downto 0);
      pc             : in std_logic_vector(31 downto 0);
      ALU_res        : in std_logic_vector(31 downto 0);
      MEM_out        : in std_logic_vector(31 downto 0);
      REG_write_data : out std_logic_vector(31 downto 0)
    );
  end component;

  -- clk period definitions
  constant clk_period : time := 100 ns;

begin
  uut : write_back
  port map
  (
    WB_src_ctrl, pc, ALU_res, MEM_out, REG_write_data
  );
  -- Stimulus process
  process
  begin
    -- Test 1 
    WB_src_ctrl <= "00";
    pc          <= x"00000000";
    ALU_res     <= x"00000000";
    MEM_out     <= x"12345678";
    wait for 10 ns;
    assert REG_write_data = x"00000004" report "Selecting pc result failed" severity error;

    report "Test 1 [PASSED]";

    -- Test 2
    WB_src_ctrl <= "01";
    wait for 10 ns;
    assert REG_write_data = x"00000000" report "Selecting ALU result failed" severity error;
    report "Test 2 [PASSED]";

    -- Test 3
    WB_src_ctrl <= "10";
    wait for 10 ns;
    assert REG_write_data = x"12345678" report "Selecting data from memory failed" severity error;
    report "Test 3 [PASSED]";
    std.env.stop(0);
    wait;
  end process;
end behavioral;