
library ieee;
library work;
use std.env.stop;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;

entity execute_tb is
  -- Testbench has no ports
end execute_tb;

architecture behavorial of execute_tb is
  component execute is
    port
    (
      -- Inputs
      forward_1       : in std_logic_vector(1 downto 0);
      forward_2       : in std_logic_vector(1 downto 0);
      do_jmp_in       : in std_logic;
      do_branch_in    : in std_logic;
      alu_ctrl_in     : in std_logic_vector(3 downto 0);
      alu_op1_ctrl_in : in std_logic; -- select signal for operand 1
      alu_op2_ctrl_in : in std_logic; -- select signal for operand 2
      pc_in           : in std_logic_vector(31 downto 0);
      r1_in           : in std_logic_vector(31 downto 0);
      r2_in           : in std_logic_vector(31 downto 0);
      imm_in          : in std_logic_vector(31 downto 0);
      wb_reg_in       : in std_logic_vector(31 downto 0); -- to be forwarded from WB stage
      mem_reg_in      : in std_logic_vector(31 downto 0); -- to be forwarded from MEM stage
      -- more to come with forwarding, hazard and memory

      -- Ouputs
      sel_pc_out : out std_logic; -- select signal for pc
      alures_out : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Inputs
  signal forward_1       : std_logic_vector(1 downto 0)  := "00";
  signal forward_2       : std_logic_vector(1 downto 0)  := "00";
  signal do_jmp_in       : std_logic                     := '0';
  signal do_branch_in    : std_logic                     := '0';
  signal alu_ctrl_in     : std_logic_vector(3 downto 0)  := (others => '0');
  signal alu_op1_ctrl_in : std_logic                     := '0';
  signal alu_op2_ctrl_in : std_logic                     := '0';
  signal pc_in           : std_logic_vector(31 downto 0) := (others => '0');
  signal r1_in           : std_logic_vector(31 downto 0) := (others => '0');
  signal r2_in           : std_logic_vector(31 downto 0) := (others => '0');
  signal imm_in          : std_logic_vector(31 downto 0) := (others => '0');
  signal wb_reg_in       : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_reg_in      : std_logic_vector(31 downto 0) := (others => '0');
  -- more to come with forwarding, hazard and memory

  -- Ouputs
  signal sel_pc_out : std_logic                     := '0'; -- select signal for pc
  signal alures_out : std_logic_vector(31 downto 0) := (others => '0');

  -- clk period definitions
  constant clk_period : time := 10 ns;

begin
  inst_execute : execute port map
    (forward_1, forward_2, do_jmp_in, do_branch_in, alu_ctrl_in, alu_op1_ctrl_in, alu_op2_ctrl_in, pc_in, r1_in, r2_in, imm_in, wb_reg_in, mem_reg_in, sel_pc_out, alures_out);
  -- Stimulus process
  stim_proc : process
  begin
    -- Test add
    forward_1       <= "01";
    forward_2       <= "01";
    r1_in           <= x"00000001"; -- 1
    r2_in           <= x"00000011"; -- 17
    alu_op1_ctrl_in <= '1';
    alu_op2_ctrl_in <= '0';
    pc_in           <= x"00000000";
    imm_in          <= x"00000001";
    alu_ctrl_in     <= alu_add;
    wait for clk_period;
    assert alures_out = "00000000000000000000000000010010" report "The value of res is now: " & to_string(alures_out) severity error; -- expect 18
    report "Test 1 [PASSED]" severity note;

    -- Test add immediate
    r1_in           <= x"00000001";
    alu_op1_ctrl_in <= '1';
    alu_op2_ctrl_in <= '1';
    wait for clk_period;
    assert alures_out = "00000000000000000000000000000010" report "The value of res is now: " & to_string(alures_out) severity error; -- expect 1
    report "Test 2 [PASSED]" severity note;

    -- Tests for beq
    do_branch_in    <= '1';
    forward_1       <= "01";
    forward_2       <= "01";
    r1_in           <= x"00000001";
    r2_in           <= x"00000001";
    alu_op1_ctrl_in <= '0';
    alu_op2_ctrl_in <= '1';
    pc_in           <= x"00000000";
    imm_in          <= x"00000001";
    alu_ctrl_in     <= alu_beq;
    wait for clk_period;
    assert sel_pc_out = '1' report "The value of sel_pc_out is now: " & to_string(sel_pc_out) severity error; -- branch taken
    report "Test 3 [PASSED]" severity note;

    do_branch_in <= '0';
    wait for clk_period;
    report "The value of sel_pc_out is now: " & to_string(0); -- branch not taken
    report "Test 4 [PASSED]" severity note;

    do_branch_in <= '1';
    r2_in        <= x"00000011";
    wait for clk_period;
    assert sel_pc_out = '0' report "The value of sel_pc_out is now: " & to_string(sel_pc_out) severity error; -- branch not taken
    report "Test 5 [PASSED]" severity note;
    std.env.stop(0);
  end process;
end architecture;