library ieee;
library work;
use std.env.stop;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;

entity execute_tb is
  -- Testbench has no ports
end execute_tb;

architecture behavioral of execute_tb is
  component execute
    port
    (
      -- Inputs
      alu_src_1_ctrl    : in std_logic := '0';
      alu_src_2_ctrl    : in std_logic := '0';
      reg_src_1         : in std_logic_vector(31 downto 0) := (others => '0');
      reg_src_2         : in std_logic_vector(31 downto 0) := (others => '0');
      do_branch         : in std_logic := '0';
      do_jmp            : in std_logic := '0';
      imm               : in std_logic_vector(31 downto 0) := (others => '0');
      op_ctrl           : in std_logic_vector(3 downto 0) := (others => '0');
      pc                : in std_logic_vector(31 downto 0) := (others => '0');
      forward_1         : in std_logic_vector(1 downto 0);
      forward_2         : in std_logic_vector(1 downto 0);
      wb_reg            : in std_logic_vector(31 downto 0) := (others => '0');
      mem_reg           : in std_logic_vector(31 downto 0) := (others => '0');

      -- Outputs
      sel_pc            : out std_logic := '0';
      alu_res_out       : out std_logic_vector(31 downto 0) := (others => '0')
    );
  end component;

   -- Inputs
   signal alu_src_1_ctrl    : std_logic := '0';
   signal alu_src_2_ctrl    : std_logic := '0';
   signal reg_src_1         : std_logic_vector(31 downto 0) := (others => '0');
   signal reg_src_2         : std_logic_vector(31 downto 0) := (others => '0');
   signal do_branch         : std_logic := '0';
   signal do_jmp            : std_logic := '0';
   signal imm               : std_logic_vector(31 downto 0) := (others => '0');
   signal op_ctrl           : std_logic_vector(3 downto 0) := (others => '0');
   signal pc                : std_logic_vector(31 downto 0) := (others => '0');
   signal forward_1         : std_logic_vector(1 downto 0) := "00";
   signal forward_2         : std_logic_vector(1 downto 0) := "00";
   signal wb_reg            : std_logic_vector(31 downto 0) := (others => '0');
   signal mem_reg           : std_logic_vector(31 downto 0) := (others => '0');
 
   -- Outputs
   signal sel_pc            : std_logic := '0';
   signal alu_res_out       : std_logic_vector(31 downto 0) := (others => '0');
 
   -- clk period definitions
   constant clk_period : time := 10 ns;

begin
  inst_execute : execute
    port map (alu_src_1_ctrl, alu_src_2_ctrl, reg_src_1, reg_src_2, do_branch, do_jmp, imm, op_ctrl, pc,
    forward_1, forward_2, wb_reg, mem_reg, sel_pc, alu_res_out);

  -- Stimulus process
  stim_proc : process
  begin
    -- Test add
    forward_1       <= "01";
    forward_2       <= "01";
    reg_src_1           <= x"00000001";
    reg_src_2           <= x"00000011";
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl <= '0';
    pc           <= x"00000000";
    imm          <= x"00000001";
    op_ctrl     <= alu_add;
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000010010" report "Test 1 failed"; -- expect 18
    report "Test 1 [PASSED]" severity note;

    -- Test add immediate
    reg_src_1           <= x"00000001";
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl  <= '1';
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000000010" report "Test 2 failed"; -- expect 1
    report "Test 2 [PASSED]" severity note;

    -- Tests for beq
    do_branch    <= '1';
    forward_1       <= "01";
    forward_2       <= "01";
    reg_src_1           <= x"00000001";
    reg_src_2           <= x"00000001";
    alu_src_1_ctrl <= '0';
    alu_src_2_ctrl <= '1';
    pc           <= x"00000000";
    imm          <= x"00000001";
    op_ctrl     <= alu_beq;
    wait for clk_period;
    assert SEL_PC = '1' report "Test 3 failed"; -- branch taken
    report "Test 3 [PASSED]" severity note;

    do_branch <= '0';
    wait for clk_period;
    assert SEL_PC = '0' report "Test 4 failed"; -- branch not taken
    report "Test 4 [PASSED]" severity note;

    do_branch <= '1';
    reg_src_2        <= x"00000011";
    wait for clk_period;
    assert SEL_PC = '0' report "Test 5 failed"; -- branch not taken
    report "Test 5 [PASSED]" severity note;

    -- Test subtraction
    do_branch <= '0';
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl <= '0';
    reg_src_1           <= x"0000000A";
    reg_src_2           <= x"00000005";
    op_ctrl    <= alu_sub;
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000000101" report "Test 6 failed";
    report "Test 6 [PASSED]" severity note;

    -- Test AND operation
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl <= '0';
    reg_src_1           <= x"0000000A";
    reg_src_2           <= x"00000005";
    op_ctrl    <= alu_and;
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000000000" report "Test 7 failed";
    report "Test 7 [PASSED]" severity note;

    -- Test OR operation
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl <= '0';
    reg_src_1           <= x"0000000A";
    reg_src_2           <= x"00000005";
    op_ctrl     <= alu_or;
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000001111" report "Test 8 failed";
    report "Test 8 [PASSED]" severity note;

    -- Test XOR operation
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl <= '0';
    reg_src_1           <= x"0000000A";
    reg_src_2           <= x"00000005";
    op_ctrl     <= alu_xor;
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000001111" report "Test 9 failed";
    report "Test 9 [PASSED]" severity note;

    -- Test SLTU operation
    alu_src_1_ctrl <= '1';
    alu_src_2_ctrl <= '0';
    reg_src_1           <= x"00000005";
    reg_src_2           <= x"0000000A";
    op_ctrl     <= alu_slt_u;
    wait for clk_period;
    assert ALU_RES_out = "00000000000000000000000000000001" report "Test 10 failed ";
    report "Test 10 [PASSED]" severity note;

    std.env.stop(0);
  end process;
end behavioral;
