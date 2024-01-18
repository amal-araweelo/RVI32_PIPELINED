library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;

entity execute is
  port
  (
    -- Inputs
    ALU_src_1_ctrl                                     : in std_logic; -- select signal for operand 1
    ALU_src_2_ctrl                                     : in std_logic; -- select signal for operand 2
    REG_src_1                                          : in std_logic_vector(31 downto 0);
    REG_src_2                                          : in std_logic_vector(31 downto 0);
    do_branch                                          : in std_logic;
    do_jmp                                             : in std_logic;
    imm                                                : in std_logic_vector(31 downto 0);
    op_ctrl                                            : in std_logic_vector(3 downto 0);
    pc                                                 : in std_logic_vector(31 downto 0);
    forward_1                                          : in std_logic_vector(1 downto 0);
    forward_2                                          : in std_logic_vector(1 downto 0);
    WB_reg                                             : in std_logic_vector(31 downto 0); -- to be forwarded from WB stage
    MEM_reg                                            : in std_logic_vector(31 downto 0); -- to be forwarded from MEM stage

    -- Ouputs
    sel_pc                                             : out std_logic; -- select signal for pc
    ALU_res_out                                        : out std_logic_vector(31 downto 0);
    REG_src_2_out                                          : out std_logic_vector(31 downto 0)
  );
end execute;

architecture behavorial of execute is

  -- Component declarations

  -- ALU component declaration

  component alu is
    port
    (
      op_1, op_2 : in std_logic_vector(31 downto 0);
      ctrl       : in std_logic_vector(3 downto 0);
      res        : out std_logic_vector(31 downto 0)
    );
  end component;

  -- MUX2 component declaration
  component mux2 is
    port
    (
      sel    : in std_logic;
      a      : in std_logic_vector(31 downto 0);
      b      : in std_logic_vector(31 downto 0);
      output : out std_logic_vector(31 downto 0)
    );
  end component;

  -- MUX3 component declaration
  component mux3 is
    port
    (
      sel    : in std_logic_vector(1 downto 0);
      a      : in std_logic_vector(31 downto 0);
      b      : in std_logic_vector(31 downto 0);
      c      : in std_logic_vector(31 downto 0);
      output : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Comparator component declaration
  component comparator is
    port
    (
      ctrl : in std_logic_vector(3 downto 0);
      op_1 : in std_logic_vector(31 downto 0);
      op_2 : in std_logic_vector(31 downto 0);
      res  : out std_logic -- if branch is taken, result is true
    );
  end component;

  -- Inputs to the ALU
  signal op_1_alu : std_logic_vector(31 downto 0);
  signal op_2_alu : std_logic_vector(31 downto 0);


  -- Outputs of the MUX3's
  signal op_1_br : std_logic_vector(31 downto 0);
  signal op_2_br : std_logic_vector(31 downto 0);

  -- Branch taken signal
  signal branch_taken : std_logic := '0';

  -- ALU result
  signal ALU_res : std_logic_vector(31 downto 0);

begin

  -- Components instantiation
  inst_mux3_1 : mux3 port map
  (
    a => WB_reg, b => REG_src_1, c => MEM_reg, sel => forward_1, output => op_1_br
  );

  inst_mux3_2 : mux3 port
  map(
  a => WB_reg, b => REG_src_2, c => MEM_reg, sel => forward_2, output => op_2_br
  );

  inst_mux2_1 : mux2 port
  map(
  a => pc, b => op_1_br, sel => ALU_src_1_ctrl, output => op_1_alu
  );
  inst_mux2_2 : mux2 port
  map(
  a => op_2_br, b => imm, sel => ALU_src_2_ctrl, output => op_2_alu
  );

  inst_alu : alu port
  map(
  op_1 => op_1_alu, op_2 => op_2_alu, ctrl => op_ctrl, res => ALU_res
  );

  inst_comparator : comparator port
  map(
  ctrl => op_ctrl, op_1 => op_1_br, op_2 => op_2_br, res => branch_taken
  );

  process (all)
  begin
    -- Outputs
    sel_pc <= std_logic((branch_taken and do_branch) or do_jmp);
    ALU_res_out <= ALU_res;
    REG_src_2_out <= op_2_br;
	report "[ALU] PC = " & to_string(pc); -- TODO: Delete
	report "[ALU] op_1 = " & to_string(op_1_alu); -- TODO: Delete
	report "[ALU] op_2 = " & to_string(op_2_alu); -- TODO: Delete
	report "[ALU] imm = " & to_string(imm); -- TODO: Delete
	report "[ALU] op_ctrl = " & to_string(op_ctrl); -- TODO: Delete
	report "[ALU] ALU_src_1_ctrl = " & to_string(ALU_src_1_ctrl); -- TODO: Delete
	report "[ALU] ALU_src_2_ctrl = " & to_string(ALU_src_2_ctrl); -- TODO: Delete
	report "[ALU] ALU_res = " & to_string(ALU_res); -- TODO: Delete
	report "[ALU] ALU_res_out = " & to_string(ALU_res_out); -- TODO: Delete
	report "[ALU] sel_pc = " & to_string(sel_pc); -- TODO: Delete
	report "[ALU] branch_taken = " & to_string(branch_taken); -- TODO: Delete
	report "[ALU] do_branch = " & to_string(do_branch); -- TODO: Delete
	report "[ALU] do_jmp = " & to_string(do_jmp); -- TODO: Delete
	report "[ALU] forward_1 = " & to_string(forward_1); -- TODO: Delete
	report "[ALU] forward_2 = " & to_string(forward_2); -- TODO: Delete
  end process;
end behavorial;
