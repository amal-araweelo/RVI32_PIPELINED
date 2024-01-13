library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.env.stop;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use ieee.numeric_std.all;

entity decode_tb is
  -- Testbench has no ports
end decode_tb;

architecture behavioral of decode_tb is

  component decoder
    port
    (
      instr                        : in std_logic_vector(31 downto 0);
      decoder_out                  : out t_decoder;
      REG_src_idx_1, REG_src_idx_2 : out std_logic_vector (4 downto 0)
    );
  end component;

  -- Inputs
  signal REG_src_idx_1  : std_logic_vector(4 downto 0)  := "00000";
  signal REG_src_idx_2  : std_logic_vector(4 downto 0)  := "00000";
  signal clk            : std_logic                     := '0';
  signal we             : std_logic                     := '0';
  signal REG_dst_idx    : std_logic_vector(4 downto 0)  := "00000";
  signal REG_write_data : std_logic_vector(31 downto 0) := x"00000000";

  -- Outputs
  signal decoder_out : t_decoder;

  signal REG_src_1 : std_logic_vector(31 downto 0) := x"00000000";
  signal REG_src_2 : std_logic_vector(31 downto 0) := x"00000000";

  -- clk period definitions
  constant clk_period : time                          := 10 ns;
  signal instr        : std_logic_vector(31 downto 0) := x"00000000";

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : decoder port map
  (
    instr       => instr,
    decoder_out => decoder_out
  );

  -- clk process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin

    instr <= x"00308113";
    wait for clk_period;

    assert decoder_out.REG_dst_idx = "00010" report "REG_dst_idx is not correct" severity error;
    assert decoder_out.ALU_src_1_ctrl = '0' report "ALU_src_1_ctrl is not correct" severity error;
    assert decoder_out.ALU_src_2_ctrl = '1' report "ALU_src_2_ctrl is not correct (needs to be 1 for I-type)" severity error;
    assert decoder_out.op_ctrl = ALU_ADD report "op_ctrl is not correct (needs to be ADD)" severity error;
    assert decoder_out.REG_we = '1' report "REG_we is not correct" severity error;
    assert decoder_out.imm = x"00000003" report "imm is not correct" severity error;
    report "Test 1 [PASSED]" severity note;

    instr <= x"00a00093";
    wait for clk_period;
    assert decoder_out.REG_dst_idx = "00001" report "REG_dst_idx is not correct" severity error;
    assert decoder_out.ALU_src_1_ctrl = '1' report "ALU_src_1_ctrl is not correct" severity error;
    assert decoder_out.ALU_src_2_ctrl = '1' report "ALU_src_2_ctrl is not correct (needs to be 1 for I-type)" severity error;
    assert decoder_out.op_ctrl = ALU_ADD report "op_ctrl is not correct (needs to be ADD)" severity error;
    assert decoder_out.REG_we = '1' report "REG_we is not correct" severity error;
    assert decoder_out.imm = x"0000000A" report "imm is not correct" severity error;
    report "Test 2 [PASSED]" severity note;

    std.env.stop(0);
  end process;

end behavioral;