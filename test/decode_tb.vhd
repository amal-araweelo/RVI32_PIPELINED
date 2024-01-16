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
    decoder_out => decoder_out,
    REG_src_idx_1 => REG_src_idx_1,
    REG_src_idx_2 => REG_src_idx_2
  );

  -- clk process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;





  -- <<<<< REPORT TEMPLATES >>>>>
--report lf & "Instrucbits is : 10987654321098765432109876543210" & lf & "Instruction is : " & to_string(instr);
  -- report "REG_src_idx_1 is: " & to_string(REG_src_idx_1) & " FROM TB";
  -- report "ALU_src_1_ctrl is: " & to_string(decoder_out.ALU_src_1_ctrl) & " FROM TB";


  stim_proc : process
  begin
    wait for 1 ns;

    -- Instruction test: addi x1, x2, 5
    instr <= x"00510093";
    wait for clk_period;
    
    assert decoder_out.REG_dst_idx = "00001" report "T1 REG_dst_idx is not correct" severity failure;
    assert REG_src_idx_1 = "00010" report "T1 REG_src_idx_1 is not correct" severity failure;
    assert REG_src_idx_2 = "00000" report "T1 REG_src_idx_2 is not correct" severity failure;
    assert decoder_out.ALU_src_1_ctrl = '1' report "T1 ALU_src_1_ctrl is not correct" severity failure;
    assert decoder_out.ALU_src_2_ctrl = '1' report "T1 ALU_src_2_ctrl is not correct (needs to be 1 for I-type)" severity failure;
    assert decoder_out.op_ctrl = ALU_ADD report "T1 op_ctrl is not correct (needs to be ADD)" severity failure;
    assert decoder_out.REG_we = '1' report "T1 REG_we is not correct" severity failure;
    assert decoder_out.imm = x"00000005" report "T1 imm is not correct" severity failure;
    assert decoder_out.WB_src_ctrl = "01" report "T1 WB_src_ctrl is not correct" severity failure;
    assert decoder_out.MEM_op = "000" report "T1 MEM_op is not correct" severity failure;
    assert decoder_out.MEM_we = '0' report "T1 MEM_we is not correct" severity failure;
    assert decoder_out.do_jmp = '0' report "T1 do_jmp is not correct" severity failure;
    assert decoder_out.do_branch = '0' report "T1 do_branch is not correct" severity failure;
    assert decoder_out.MEM_rd = '0' report "T1 MEM_rd is not correct" severity failure;
    report "Test 1 [PASSED] (addi)" severity note;

    -- Instruction test: add x1, x5, x3
    instr <= x"003280b3";
    wait for clk_period;

    assert decoder_out.REG_dst_idx    = "00001" report "T1 REG_dst_idx not correct" severity failure;
    assert REG_src_idx_1              = "00101" report "T1 REG_src_idx_1 not correct" severity failure;
    assert REG_src_idx_2              = "00011" report "T1 REG_src_idx_2 not correct" severity failure;
    assert decoder_out.ALU_src_1_ctrl = '1'     report "T1 ALU_src_1_ctrl not correct" severity failure;
    assert decoder_out.ALU_src_2_ctrl = '0'     report "T1 ALU_src_2_ctrl not correct" severity failure;
    assert decoder_out.op_ctrl        = ALU_ADD report "T1 op_ctrl not correct" severity failure;
    assert decoder_out.REG_we         = '1'     report "T1 REG_we not correct" severity failure;
    assert decoder_out.imm            = x"00000000" report "T1 imm not correct" severity failure;
    assert decoder_out.WB_src_ctrl    = "01"    report "T1 WB_src_ctrl not correct" severity failure;
    assert decoder_out.MEM_op         = "000"   report "T1 MEM_op not correct" severity failure;
    assert decoder_out.MEM_we         = '0'     report "T1 MEM_we not correct" severity failure;
    assert decoder_out.do_jmp         = '0'     report "T1 do_jmp not correct" severity failure;
    assert decoder_out.do_branch      = '0'     report "T1 do_branch not correct" severity failure;
    assert decoder_out.MEM_rd         = '0'     report "T1 MEM_rd not correct" severity failure;
    report "Test 2 [PASSED]" severity note;

    -- Instruction test: or x2, x2, x3
    instr <= x"00316133";
    wait for clk_period;
    assert decoder_out.REG_dst_idx    = "00010" report "T3 REG_dst_idx not correct" severity failure;
    assert REG_src_idx_1              = "00010" report "T3 REG_src_idx_1 not correct" severity failure;
    assert REG_src_idx_2              = "00011" report "T3 REG_src_idx_2 not correct" severity failure;
    assert decoder_out.ALU_src_1_ctrl = '1'     report "T3 ALU_src_1_ctrl not correct" severity failure;
    assert decoder_out.ALU_src_2_ctrl = '0'     report "T3 ALU_src_2_ctrl not correct" severity failure;
    assert decoder_out.op_ctrl        = ALU_OR report "T3 op_ctrl not correct" severity failure;
    assert decoder_out.REG_we         = '1'     report "T3 REG_we not correct" severity failure;
    assert decoder_out.imm            = x"00000000" report "T3 imm not correct" severity failure;
    assert decoder_out.WB_src_ctrl    = "01"    report "T3 WB_src_ctrl not correct" severity failure;
    assert decoder_out.MEM_op         = "000"   report "T3 MEM_op not correct" severity failure;
    assert decoder_out.MEM_we         = '0'     report "T3 MEM_we not correct" severity failure;
    assert decoder_out.do_jmp         = '0'     report "T3 do_jmp not correct" severity failure;
    assert decoder_out.do_branch      = '0'     report "T3 do_branch not correct" severity failure;
    assert decoder_out.MEM_rd         = '0'     report "T3 MEM_rd not correct" severity failure;
    report "Test 3 [PASSED]" severity note;

  -- Instruction test: lbu x1 49(x4)
  instr <= x"03124083";
  wait for clk_period;
  --report "TEST 4: LBU" & lf & "Instrucbits is : 10987654321098765432109876543210" & lf & "Instruction is : " & to_string(instr);
  assert decoder_out.REG_dst_idx    = "00001" report "T4 REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00100" report "T4 REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "T4 REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '1'     report "T4 ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "T4 ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "T4 op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '1'     report "T4 REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00000031" report "T4 imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "10"    report "T4 WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "110"   report "T4 MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "T4 MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '0'     report "T4 do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "T4 do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '1'     report "T4 MEM_rd not correct" severity failure;
  report "Test 4 [PASSED]" severity note;

  -- Instruction test: auipc x10, 0xFFFFF
  instr <= x"fffff517";
  wait for clk_period;
  -- report "TEST 5: AUIPC" & lf & "Instrucbits is : 10987654321098765432109876543210" & lf & "Instruction is : " & to_string(instr);
  assert decoder_out.REG_dst_idx    = "01010" report "T1 REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00000" report "T1 REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "T1 REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '0'     report "T1 ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "T1 ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "T1 op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '1'     report "T1 REG_we not correct" severity failure;
  assert decoder_out.imm            = x"FFFFF000" report "T1 imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "01"    report "T1 WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "000"   report "T1 MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "T1 MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '0'     report "T1 do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "T1 do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "T1 MEM_rd not correct" severity failure;
  report "Test 5 [PASSED] (auipc)" severity note;

--  Instruction test slt x4 x5 x7
instr <= x"0072a233";
wait for clk_period;

assert decoder_out.REG_dst_idx    = "00100" report "T1 REG_dst_idx not correct" severity failure;
assert REG_src_idx_1              = "00101" report "T1 REG_src_idx_1 not correct" severity failure;
assert REG_src_idx_2              = "00111" report "T1 REG_src_idx_2 not correct" severity failure;
assert decoder_out.ALU_src_1_ctrl = '1'     report "T1 ALU_src_1_ctrl not correct" severity failure;
assert decoder_out.ALU_src_2_ctrl = '0'     report "T1 ALU_src_2_ctrl not correct" severity failure;
assert decoder_out.op_ctrl        = ALU_SLT_S report "T1 op_ctrl not correct" severity failure;
assert decoder_out.REG_we         = '1'     report "T1 REG_we not correct" severity failure;
assert decoder_out.imm            = x"00000000" report "T1 imm not correct" severity failure;
assert decoder_out.WB_src_ctrl    = "01"    report "T1 WB_src_ctrl not correct" severity failure;
assert decoder_out.MEM_op         = "000"   report "T1 MEM_op not correct" severity failure;
assert decoder_out.MEM_we         = '0'     report "T1 MEM_we not correct" severity failure;
assert decoder_out.do_jmp         = '0'     report "T1 do_jmp not correct" severity failure;
assert decoder_out.do_branch      = '0'     report "T1 do_branch not correct" severity failure;
assert decoder_out.MEM_rd         = '0'     report "T1 MEM_rd not correct" severity failure;
report "Test 6 [PASSED] (slt)" severity note;

-- Instruction test:  sub x7 x9 x13
instr <= x"40d483b3";
wait for clk_period;

assert decoder_out.REG_dst_idx    = "00111" report "REG_dst_idx not correct" severity failure;
assert REG_src_idx_1              = "01001" report "REG_src_idx_1 not correct" severity failure;
assert REG_src_idx_2              = "01101" report "REG_src_idx_2 not correct" severity failure;
assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
assert decoder_out.ALU_src_2_ctrl = '0'     report "ALU_src_2_ctrl not correct" severity failure;
assert decoder_out.op_ctrl        = ALU_SUB report "op_ctrl not correct" severity failure;
assert decoder_out.REG_we         = '1'     report "REG_we not correct" severity failure;
assert decoder_out.imm            = x"00000000" report "imm not correct" severity failure;
assert decoder_out.WB_src_ctrl    = "01"    report "WB_src_ctrl not correct" severity failure;
assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
report "Test 7 [PASSED] (sub)" severity note;


-- Instruction test srai x7 x22 4
instr <= x"404b5393";
wait for clk_period;
--report lf & "Instrucbits is : 10987654321098765432109876543210" & lf & "Instruction is : " & to_string(instr);
assert decoder_out.REG_dst_idx    = "00111" report "REG_dst_idx not correct" severity failure;
assert REG_src_idx_1              = "10110" report "REG_src_idx_1 not correct" severity failure;
assert REG_src_idx_2              = "00000" report "REG_src_idx_2 not correct" severity failure;
assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
assert decoder_out.op_ctrl        = ALU_SRA report "op_ctrl not correct" severity failure;
assert decoder_out.REG_we         = '1'     report "REG_we not correct" severity failure;
report "imm is: " & to_string(decoder_out.imm) & " FROM TB";
assert decoder_out.imm            = x"00000004" report "imm not correct" severity failure;
assert decoder_out.WB_src_ctrl    = "01"    report "WB_src_ctrl not correct" severity failure;
assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
report "Test 8 [PASSED] (srai)" severity note;

-- Instruction test bgeu x19 x6 8
instr <= x"0069f463";
wait for clk_period;

assert decoder_out.REG_dst_idx    = "00000" report "REG_dst_idx not correct" severity failure;
assert REG_src_idx_1              = "10011" report "REG_src_idx_1 not correct" severity failure;
assert REG_src_idx_2              = "00110" report "REG_src_idx_2 not correct" severity failure;
assert decoder_out.ALU_src_1_ctrl = '0'     report "ALU_src_1_ctrl not correct" severity failure;
assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
assert decoder_out.op_ctrl        = ALU_BGE_U report "op_ctrl not correct" severity failure;
assert decoder_out.REG_we         = '0'     report "REG_we not correct" severity failure;
assert decoder_out.imm            = x"00000008" report "imm not correct" severity failure;
assert decoder_out.WB_src_ctrl    = "00"    report "WB_src_ctrl not correct" severity failure;
assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
assert decoder_out.do_branch      = '1'     report "do_branch not correct" severity failure;
assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
report "Test 9 [PASSED] (bgeu)" severity note;

  -- Instruction test: lui x3 0x500
  instr <= x"005001b7";
  wait for clk_period;

  assert decoder_out.REG_dst_idx    = "00011" report "REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00000" report "REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '1'     report "REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00500000" report "imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "01"    report "WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
  report "Test 10 [PASSED] (lui)" severity note;

  -- Instruction test: sh x8 0x87 x16
  instr <= x"088813a3";
  wait for clk_period;

  assert decoder_out.REG_dst_idx    = "00000" report "REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "10000" report "REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "01000" report "REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '0'     report "REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00000087" report "imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "01"    report "WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "001"   report "MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '1'     report "MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
  report "Test 11 [PASSED] (sh)" severity note;


  -- Instruction test: slli x6 x7 8
  instr <= x"00839313";
  wait for clk_period;

  assert decoder_out.REG_dst_idx    = "00110" report "REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00111" report "REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_sl report "op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '1'     report "REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00000008" report "imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "01"    report "WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
  report "Test 12 [PASSED] (slli)" severity note;
  

  -- Instruction test: jal x4 4
  instr <= x"0040026f";
  wait for clk_period;

  assert decoder_out.REG_dst_idx    = "00100" report "REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00000" report "REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '0'     report "ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '1'     report "REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00000004" report "imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "00"    report "WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '1'     report "do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
  report "Test 13 [PASSED] (jal)" severity note;

  
  -- Instruction test: jalr x1 x3 5
  instr <= x"005180e7";
  wait for clk_period;
  --report lf & "Instrucbits is : 10987654321098765432109876543210" & lf & "Instruction is : " & to_string(instr);
  assert decoder_out.REG_dst_idx    = "00001" report "REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00011" report "REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '1'     report "ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '1'     report "REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00000005" report "imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "00"    report "WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '1'     report "do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
  report "Test 14 [PASSED] (jalr)" severity note;



  -- Instruction test: fillme
  instr <= x"fillme";
  wait for clk_period;

  assert decoder_out.REG_dst_idx    = "00000" report "REG_dst_idx not correct" severity failure;
  assert REG_src_idx_1              = "00000" report "REG_src_idx_1 not correct" severity failure;
  assert REG_src_idx_2              = "00000" report "REG_src_idx_2 not correct" severity failure;
  assert decoder_out.ALU_src_1_ctrl = '1'     report "ALU_src_1_ctrl not correct" severity failure;
  assert decoder_out.ALU_src_2_ctrl = '0'     report "ALU_src_2_ctrl not correct" severity failure;
  assert decoder_out.op_ctrl        = ALU_ADD report "op_ctrl not correct" severity failure;
  assert decoder_out.REG_we         = '0'     report "REG_we not correct" severity failure;
  assert decoder_out.imm            = x"00000000" report "imm not correct" severity failure;
  assert decoder_out.WB_src_ctrl    = "01"    report "WB_src_ctrl not correct" severity failure;
  assert decoder_out.MEM_op         = "000"   report "MEM_op not correct" severity failure;
  assert decoder_out.MEM_we         = '0'     report "MEM_we not correct" severity failure;
  assert decoder_out.do_jmp         = '0'     report "do_jmp not correct" severity failure;
  assert decoder_out.do_branch      = '0'     report "do_branch not correct" severity failure;
  assert decoder_out.MEM_rd         = '0'     report "MEM_rd not correct" severity failure;
  report "Test 15 [PASSED] (bne)" severity note;

    std.env.stop(0);
  end process;

end behavioral;