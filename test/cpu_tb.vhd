library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;
use work.records_pkg.all;

entity cpu_tb is
  -- Testbench has no ports
end cpu_tb;

architecture behavior of cpu_tb is

  component fetcher is
    port
    (
      clk, sel_pc, reset, en : in std_logic;
      branch_addr            : in std_logic_vector (31 downto 0);
      instr                  : out std_logic_vector (31 downto 0);
      pc                     : out std_logic_vector (31 downto 0)
    );
  end component;

  component reg_ifid is
    port
    (
      clk, clr, en    : in std_logic;
      in_ifid_record  : in t_ifid;
      out_ifid_record : out t_ifid
    );
  end component;

  component decoder is
    port
    (
      instr                        : in std_logic_vector(31 downto 0);
      decoder_out                  : out t_decoder;
      REG_src_idx_1, REG_src_idx_2 : out std_logic_vector (4 downto 0)
    );
  end component;

  component reg_file is
    generic
    (
      B : integer := 32; -- no. of bits in register
      W : integer := 5 -- no. of address bits (5 bits=32 addresses)
    );
    port
    (
      clk, REG_we                  : in std_logic;
      REG_src_idx_1, REG_src_idx_2 : in std_logic_vector(4 downto 0);
      REG_dst_idx                  : in std_logic_vector(4 downto 0);
      REG_write_data               : in std_logic_vector(B - 1 downto 0);
      REG_src_1, REG_src_2         : out std_logic_vector(B - 1 downto 0)
    );
  end component;

  component reg_idex is
    port
    (
      clk, clr, en    : in std_logic;
      in_idex_record  : in t_idex;
      out_idex_record : out t_idex
    );
  end component;

  -- Execute
  component execute is
    port
    (
      -- Inputs
      ALU_src_1_ctrl : in std_logic;
      ALU_src_2_ctrl : in std_logic;
      REG_src_1      : in std_logic_vector(31 downto 0);
      REG_src_2      : in std_logic_vector(31 downto 0);
      do_branch      : in std_logic;
      do_jmp         : in std_logic;
      imm            : in std_logic_vector(31 downto 0);
      op_ctrl        : in std_logic_vector(3 downto 0);
      pc             : in std_logic_vector(31 downto 0);
      -- more to come with forwarding, hazard and memory
      forward_1 : in std_logic_vector(1 downto 0);
      forward_2 : in std_logic_vector(1 downto 0);
      WB_reg    : in std_logic_vector(31 downto 0);
      MEM_reg   : in std_logic_vector(31 downto 0);

      -- Ouputs
      sel_pc      : out std_logic;
      ALU_res_out : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Hazard Unit
component hazard_unit is
  port
  (

    -------------------- Inputs ---------------------------
    sel_pc           : in std_logic;
    ID_REG_src_idx_1 : in std_logic_vector(4 downto 0);
    ID_REG_src_idx_2 : in std_logic_vector(4 downto 0);
    EX_REG_dst_idx   : in std_logic_vector(4 downto 0);
    MEM_rd           : in std_logic;
    -------------------- Outputs ---------------------------

    -- ID/EX register
    hazard_idex_en  : out std_logic;
    hazard_idex_clr : out std_logic;

    -- IF/ID register
    hazard_ifid_en  : out std_logic;
    hazard_ifid_clr : out std_logic;

    -- PC
    hazard_fetch_en : out std_logic -- hazard fetch enable (PC)
  );
end component;

  -- Forwarding Unit

component forwarding_unit is
  port
  (
    -- Inputs
    REG_src_idx_1 : in std_logic_vector(4 downto 0); -- rs2 ID
    REG_src_idx_2 : in std_logic_vector(4 downto 0); -- rs1 ID
    WB_REG_we     : in std_logic; -- REG_we from the write back stage
    MEM_REG_we    : in std_logic; -- REG_we from the memory stage

    WB_dst_idx  : in std_logic_vector(4 downto 0);
    MEM_dst_idx : in std_logic_vector(4 downto 0);

    -- Outputs
    forward_reg_src_1 : out std_logic_vector(1 downto 0);
    forward_reg_src_2 : out std_logic_vector(1 downto 0)
  );
end component;

  -- Register EX/MEM

  component reg_exmem is
    port
    (
      clk, clr, en     : in std_logic;
      in_exmem_record  : in t_exmem;
      out_exmem_record : out t_exmem
    );
  end component;

  -- Memory
  component data_mem is
    port
    (
      -- Inputs
      clk         : in std_logic; -- clock
      MEM_we      : in std_logic; -- write enable
      MEM_op      : in std_logic_vector(3 downto 0); -- memory operation
      MEM_data_in : in std_logic_vector(31 downto 0);
      MEM_addr    : in std_logic_vector(31 downto 0); -- address (it is the value stored in register 2)

      -- Outputs
      MEM_data_out : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Register MEM/WB
  component reg_memwb is
    port
    (
      clk, clr, en     : in std_logic;
      in_memwb_record  : in t_memwb;
      out_memwb_record : out t_memwb
    );
  end component;

  -- Writeback

  component write_back is
    port
    (
      WB_src_ctrl : in std_logic_vector(1 downto 0);
      pc          : in std_logic_vector(31 downto 0);
      ALU_res     : in std_logic_vector(31 downto 0);
      MEM_out     : in std_logic_vector(31 downto 0); -- data_out from datamem

      REG_write_data : out std_logic_vector(31 downto 0) -- data to be written to the register file
    );
  end component;

  -- Reset signal
  signal reset : std_logic := '0';

  -- Clock signal
  signal clk          : std_logic := '0';
  constant clk_period : time      := 10 ns;

  -- Fetcher signals
  signal fetch_stage_out : t_ifid;

  -- Register IF/ID signals
  signal ifid_out : t_ifid;

  -- Decoder signals
  signal decode_stage_out             : t_idex;
  signal REG_src_idx_1, REG_src_idx_2 : std_logic_vector(4 downto 0);

  -- Register ID/EX signals
  signal idex_out : t_idex;

  -- Execute signals
  signal execute_stage_out_sel_pc : std_logic;

  -- Hazard Unit signals
  signal hazard_idex_en, hazard_idex_clr : std_logic;
  signal hazard_ifid_en, hazard_ifid_clr : std_logic;
  signal hazard_fetch_en                : std_logic;

  -- Forwarding Unit signals
  signal forward_reg_src_1, forward_reg_src_2 : std_logic_vector(1 downto 0);

  -- Register EX/MEM signals
  signal execute_stage_out : t_exmem;
  signal exmem_out         : t_exmem;

  -- Register MEM/WB signals
  signal memory_stage_out : t_memwb;
  signal memwb_out        : t_memwb;

  -- Writeback signals
  signal write_back_out : std_logic_vector(31 downto 0);

begin

  -- Fetcher
  fetcher_inst : fetcher port map
  (
    clk         => clk,
    sel_pc      => execute_stage_out_sel_pc,
    reset       => reset,
    en          => hazard_fetch_en,
    branch_addr => execute_stage_out.ALU_res,
    instr       => fetch_stage_out.instr,
    pc          => fetch_stage_out.pc
  );

  -- Register IF/ID
  reg_ifid_inst : reg_ifid port
  map
  (
  clk             => clk,
  clr             => hazard_ifid_clr,
  en              => hazard_ifid_en,
  in_ifid_record  => fetch_stage_out,
  out_ifid_record => ifid_out
  );

  -- Register File
  reg_file_inst : reg_file port
  map
  (
  clk            => clk,
  REG_we         => memwb_out.REG_we,
  REG_src_idx_1  => REG_src_idx_1,
  REG_src_idx_2  => REG_src_idx_2,
  REG_dst_idx    => memwb_out.REG_dst_idx,
  REG_write_data => write_back_out,
  REG_src_1      => decode_stage_out.REG_src_1,
  REG_src_2      => decode_stage_out.REG_src_2
  );

  -- Decoder
  decode_inst : decoder port
  map
  (
  instr         => ifid_out.instr,
  decoder_out   => decode_stage_out.decoder_out,
  REG_src_idx_1 => REG_src_idx_1,
  REG_src_idx_2 => REG_src_idx_2
  );

  decode_stage_out.pc <= ifid_out.pc;
  decode_stage_out.REG_src_idx_1 <= REG_src_idx_1;
  decode_stage_out.REG_src_idx_2 <= REG_src_idx_2;

  -- Register ID/EX
  reg_idex_inst : reg_idex
  port
  map
  (
  clk             => clk,
  clr             => hazard_idex_clr,
  en              => hazard_fetch_en,
  in_idex_record  => decode_stage_out,
  out_idex_record => idex_out
  );

  -- Execute
  execute_inst : execute
  port
  map
  (
  ALU_src_1_ctrl => idex_out.decoder_out.ALU_src_1_ctrl,
  ALU_src_2_ctrl => idex_out.decoder_out.ALU_src_2_ctrl,
  REG_src_1      => idex_out.REG_src_1,
  REG_src_2      => idex_out.REG_src_2,
  do_branch      => idex_out.decoder_out.do_branch,
  do_jmp         => idex_out.decoder_out.do_jmp,
  imm            => idex_out.decoder_out.imm,
  op_ctrl        => idex_out.decoder_out.op_ctrl,
  pc             => idex_out.pc,
  forward_1      => forward_reg_src_1,
  forward_2      => forward_reg_src_2,
  WB_reg         => write_back_out,
  MEM_reg        => exmem_out.ALU_res,

  sel_pc      => execute_stage_out_sel_pc,
  ALU_res_out => execute_stage_out.ALU_res
  );

  hazard_unit_inst : hazard_unit
  port 
  map
  (
	sel_pc => execute_stage_out_sel_pc,
	ID_REG_src_idx_1 => REG_src_idx_1,
	ID_REG_src_idx_2 => REG_src_idx_2,
	EX_REG_dst_idx => idex_out.decoder_out.REG_dst_idx,
	MEM_rd => exmem_out.MEM_we,

	hazard_idex_en => hazard_idex_en,
	hazard_idex_clr => hazard_idex_clr,
	hazard_ifid_en => hazard_ifid_en,
	hazard_ifid_clr => hazard_ifid_clr,
	hazard_fetch_en => hazard_fetch_en
  );


  forwarding_unit_inst : forwarding_unit
  port
  map
  (
    REG_src_idx_1 => idex_out.REG_src_idx_1,
    REG_src_idx_2 => idex_out.REG_src_idx_2,
    WB_REG_we => memwb_out.REG_we,
    MEM_REG_we => exmem_out.REG_we,
    WB_dst_idx => memwb_out.REG_dst_idx,
    MEM_dst_idx => exmem_out.REG_dst_idx,

    forward_reg_src_1 => forward_reg_src_1,
    forward_reg_src_2 => forward_reg_src_2
  );

  execute_stage_out.REG_we      <= idex_out.decoder_out.REG_we;
  execute_stage_out.MEM_we      <= idex_out.decoder_out.MEM_we;
  execute_stage_out.WB_src_ctrl <= idex_out.decoder_out.WB_src_ctrl;
  execute_stage_out.MEM_op      <= idex_out.decoder_out.MEM_op;
  execute_stage_out.REG_dst_idx <= idex_out.decoder_out.REG_dst_idx;
  execute_stage_out.pc          <= idex_out.pc;
  execute_stage_out.REG_src_2   <= idex_out.REG_src_2;

  -- Register EX/MEM
  reg_exmem_inst : reg_exmem
  port
  map
  (
  clk              => clk,
  clr              => '0',
  en               => '1',
  in_exmem_record  => execute_stage_out,
  out_exmem_record => exmem_out
  );

  memory_stage_out.REG_we      <= exmem_out.REG_we;
  memory_stage_out.MEM_we      <= exmem_out.MEM_we;
  memory_stage_out.WB_src_ctrl <= exmem_out.WB_src_ctrl;
  memory_stage_out.REG_dst_idx <= exmem_out.REG_dst_idx;
  memory_stage_out.pc          <= exmem_out.pc;
  memory_stage_out.ALU_res     <= exmem_out.ALU_res;

  -- Memory
  memory_inst : data_mem
  port
  map
  (
  clk          => clk,
  MEM_we       => exmem_out.MEM_we,
  MEM_op       => exmem_out.MEM_op,
  MEM_data_in  => exmem_out.REG_src_2,
  MEM_addr     => exmem_out.ALU_res,
  MEM_data_out => memory_stage_out.MEM_out
  );

  -- Register MEM/WB
  reg_memwb_inst : reg_memwb
  port
  map
  (
  clk              => clk,
  en               => '1',
  clr              => '0',
  in_memwb_record  => memory_stage_out,
  out_memwb_record => memwb_out
  );

  -- Writeback
  write_back_inst : write_back
  port
  map
  (
  WB_src_ctrl    => memwb_out.WB_src_ctrl,
  pc             => memwb_out.pc,
  ALU_res        => memwb_out.ALU_res,
  MEM_out        => memwb_out.MEM_out,
  REG_write_data => write_back_out
  );

  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    reset <= '1';
    wait for 1 ns;
    reset <= '0';

    wait;
    -- wait for 100*clk_period;

    -- First instruction
    report "--------- CLOCK CYCLE ---------";
      report "Instruction = " & to_string(fetch_stage_out.instr);
    report "IFID.instr = " & to_string(ifid_out.instr);
    report "IFID.pc = " & to_string(ifid_out.pc);
    report "decode_stage_out.decoder_out.REG_dst_idx = " & to_string(decode_stage_out.decoder_out.REG_dst_idx);
    report "decode_stage_out.decoder.imm = " & to_string(decode_stage_out.decoder_out.imm);
    report "idex_out.decoder_out.imm = " & to_string(idex_out.decoder_out.imm);
    report "execute_stage_out.ALU_res_out = " & to_string(execute_stage_out.ALU_res);
    report "execute_stage_out_sel_pc = " & to_string(execute_stage_out_sel_pc);
    report "exmem_out.ALU_res = " & to_string(exmem_out.ALU_res);
    report "memwb_out.WB_src_ctrl = " & to_string(memwb_out.WB_src_ctrl);
    report "memwb_out.ALU_res = " & to_string(memwb_out.ALU_res);
    report "write_back_out = " & to_string(write_back_out);
    report "--------- CLOCK CYCLE ---------";

      -- Second instruction
    wait for clk_period;
    report "Instruction = " & to_string(fetch_stage_out.instr);
    report "IFID.instr = " & to_string(ifid_out.instr);
    report "IFID.pc = " & to_string(ifid_out.pc);
    report "decode_stage_out.decoder_out.REG_dst_idx = " & to_string(decode_stage_out.decoder_out.REG_dst_idx);
    report "decode_stage_out.decoder.imm = " & to_string(decode_stage_out.decoder_out.imm);
    report "idex_out.decoder_out.imm = " & to_string(idex_out.decoder_out.imm);
    report "execute_stage_out.ALU_res_out = " & to_string(execute_stage_out.ALU_res);
    report "execute_stage_out_sel_pc = " & to_string(execute_stage_out_sel_pc);
    report "write_back_out = " & to_string(write_back_out);
    report "exmem_out.WB_src_ctrl = " & to_string(exmem_out.WB_src_ctrl);
    report "idex_out.decoder_out.WB_src_ctrl = " & to_string(idex_out.decoder_out.WB_src_ctrl);
    report "memwb_out.WB_src_ctrl = " & to_string(memwb_out.WB_src_ctrl);
    report "mwmwb_out.ALU_res = " & to_string(memwb_out.ALU_res);
    report "memory_stage_out.ALU_res = " & to_string(memory_stage_out.ALU_res);

    std.env.stop(0);
  end process;

end behavior;
