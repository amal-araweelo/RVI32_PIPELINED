library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ctrl_const.all;

entity execute is
  port
  (
    -- Inputs
    -- the first two will be removed (only for testing);
    forward_1       : in std_logic_vector(1 downto 0);
    forward_2       : in std_logic_vector(1 downto 0);
    do_jmp_in       : in std_logic                     := '0';
    do_branch_in    : in std_logic                     := '0';
    alu_ctrl_in     : in std_logic_vector(3 downto 0)  := (others => '0');
    alu_op1_ctrl_in : in std_logic                     := '0'; -- select signal for operand 1
    alu_op2_ctrl_in : in std_logic                     := '0'; -- select signal for operand 2
    pc_in           : in std_logic_vector(31 downto 0) := (others => '0');
    r1_in           : in std_logic_vector(31 downto 0) := (others => '0');
    r2_in           : in std_logic_vector(31 downto 0) := (others => '0');
    imm_in          : in std_logic_vector(31 downto 0) := (others => '0');
    wb_reg_in       : in std_logic_vector(31 downto 0) := (others => '0'); -- to be forwarded from WB stage
    mem_reg_in      : in std_logic_vector(31 downto 0) := (others => '0'); -- to be forwarded from MEM stage
    -- more to come with forwarding, hazard and memory

    -- Ouputs
    sel_pc_out : out std_logic                     := '0'; -- select signal for pc
    alures_out : out std_logic_vector(31 downto 0) := (others => '0')
  );
end execute;

architecture behavorial of execute is

  -- Components
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
  signal op_1_alu : std_logic_vector(31 downto 0) := (others => '0');
  signal op_2_alu : std_logic_vector(31 downto 0) := (others => '0');

  -- Output from forwarding unit to be used as select signals for the MUX3's
  -- signal forward_1 : std_logic_vector(1 downto 0) := (others => '0');
  -- signal forward_2 : std_logic_vector(1 downto 0) := (others => '0');
  -- for now just an input to the execute stage for testing

  -- Outputs of the MUX3's
  signal op_1_br : std_logic_vector(31 downto 0) := (others => '0');
  signal op_2_br : std_logic_vector(31 downto 0) := (others => '0');

  -- Branch taken signal
  signal branch_taken : std_logic := '0';

  -- ALU result
  signal alures : std_logic_vector(31 downto 0) := (others => '0');

begin

  -- Components instantiation
  inst_mux3_1 : mux3 port map
  (
    a => wb_reg_in, b => r1_in, c => mem_reg_in, sel => forward_1, output => op_1_br
  );

  inst_mux3_2 : mux3 port
  map(
  a => wb_reg_in, b => r2_in, c => mem_reg_in, sel => forward_2, output => op_2_br
  );

  inst_mux2_1 : mux2 port
  map(
  a => pc_in, b => op_1_br, sel => alu_op1_ctrl_in, output => op_1_alu
  );
  inst_mux2_2 : mux2 port
  map(
  a => op_2_br, b => imm_in, sel => alu_op2_ctrl_in, output => op_2_alu
  );

  inst_alu : alu port
  map(
  op_1 => op_1_alu, op_2 => op_2_alu, ctrl => alu_ctrl_in, res => alures
  );

  inst_comparator : comparator port
  map(
  ctrl => alu_ctrl_in, op_1 => op_1_br, op_2 => op_2_br, res => branch_taken
  );

  -- inst_forwarding : forwarding_unit port

  process (all)
  begin
    -- Outputs
    sel_pc_out <= std_logic((branch_taken and do_branch_in) or do_jmp_in);
    alures_out <= alures;
  end process;
end behavorial;