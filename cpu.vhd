-- RISC-V CPU

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

entity cpu is
    port 
    (
	clk_in: in std_logic;
	led_status : out std_logic
    );
end cpu;

architecture behavioral of cpu is 

  -- Clock divider

  component clk_div is
    port
    (
      clk_in : in std_logic; -- Connect to board clk
      clk_out       : out std_logic
      );
  end component;

component fetcher is
  port
  (
    clk, sel_pc, clr, en : in std_logic;
    branch_addr          : in std_logic_vector (31 downto 0);
    instr                : out std_logic_vector (31 downto 0);
    pc                   : out std_logic_vector (31 downto 0)
  );
end component;

component reg_ifid is
  port
  (
    clk, clr, en    : in std_logic;
    in_ifid_record  : in t_ifid_reg;
    out_ifid_record : out t_ifid_reg
  );
end component;

component decoder is
port (
	instr: in std_logic_vector(31 downto 0);
	decoder_out: out t_decoder;
	REG_src_idx_1, REG_src_idx_2: out std_logic_vector (4 downto 0)
	);
end component;

component reg_file is
	generic(
	B: integer:= 32; 	-- no. of bits in register
	W: integer:= 5		-- no. of address bits (5 bits=32 addresses)
	);
	port (
		clk, REG_we: in std_logic;
		REG_src_idx_1, REG_src_idx_2: in std_logic_vector(4 downto 0);
		REG_dst_idx: in std_logic_vector(4 downto 0);
		REG_write_data: in std_logic_vector(B-1 downto 0);
		REG_src_1, REG_src_2: out std_logic_vector(B-1 downto 0);
    blinky: out std_logic
	);
end component;

component reg_idex is
  port
  (
    clk, clr, en    : in std_logic;
    in_idex_record  : in t_idex_reg;
    out_idex_record : out t_idex_reg
  );
end component;

-- Execute
component execute is
  port
  (
    -- Inputs
    ALU_src_1_ctrl                                     : in std_logic;                      
    ALU_src_2_ctrl                                     : in std_logic;                      
    REG_src_1                                          : in std_logic_vector(31 downto 0);
    REG_src_2                                          : in std_logic_vector(31 downto 0);
    do_branch                                          : in std_logic;                      
    do_jmp                                             : in std_logic;                      
    imm                                                : in std_logic_vector(31 downto 0);
    op_ctrl                                            : in std_logic_vector(3 downto 0);  
    pc                                                 : in std_logic_vector(31 downto 0);  
    -- more to come with forwarding, hazard and memory
    forward_1                                          : in std_logic_vector(1 downto 0);
    forward_2                                          : in std_logic_vector(1 downto 0);
    WB_reg                                             : in std_logic_vector(31 downto 0);
    MEM_reg                                            : in std_logic_vector(31 downto 0);

    -- Ouputs
    sel_pc                                             : out std_logic;
    ALU_res_out                                        : out std_logic_vector(31 downto 0)
  );
end component;

-- Register EX/MEM

component reg_exmem is
  port
  (
    clk, clr, en     : in std_logic;
    in_exmem_record  : in t_exmem_reg;
    out_exmem_record : out t_exmem_reg
  );
end component;

-- Memory
component data_mem is
  port
  (
    -- Inputs
    clk         : in std_logic; -- clock
    pc          : in std_logic_vector(31 downto 0);
    MEM_we      : in std_logic; -- write enable
    MEM_op      : in std_logic_vector(3 downto 0); -- memory operation
    MEM_data_in : in std_logic_vector(31 downto 0);
    MEM_addr    : in std_logic_vector(31 downto 0); -- address (it is the value stored in register 2)

    -- Outputs
    MEM_data_out : out std_logic_vector(31 downto 0);

    -- Changes
    blinky: out std_logic
  );
end component;

-- Register MEM/WB
component reg_memwb is
  port
  (
    clk, clr, en     : in std_logic;
    in_memwb_record  : in t_memwb_reg;
    out_memwb_record : out t_memwb_reg
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

-- Fetcher signals
signal fetch_stage_out : t_ifid_reg;

-- Register IF/ID signals
signal ifid_out : t_ifid_reg;

-- Decoder signals
signal decode_stage_out : t_idex_reg;
signal REG_src_idx_1, REG_src_idx_2 : std_logic_vector(4 downto 0);

-- Register ID/EX signals
signal idex_out : t_idex_reg;

-- Execute signals
signal execute_stage_out_sel_pc : std_logic;

-- Register EX/MEM signals
signal execute_stage_out : t_exmem_reg;
signal exmem_out : t_exmem_reg;

-- Register MEM/WB signals
signal memory_stage_out : t_memwb_reg;
signal memwb_out : t_memwb_reg;

-- Writeback signals
signal write_back_out : std_logic_vector(31 downto 0);

-- Clock signal
signal clk : std_logic;

begin

  -- Clock divider
  inst_clk_div: clk_div port map(
    clk_in, clk
  );

-- Fetcher
fetcher_inst: fetcher port map
(
    clk => clk,
    sel_pc => execute_stage_out_sel_pc,
    clr => '0',
    en => '1',
    branch_addr => (others => '0'),
    instr => fetch_stage_out.instr,
    pc => fetch_stage_out.pc
);

-- Register IF/ID
reg_ifid_inst: reg_ifid port map
(
    clk => clk,
    clr => '0',
    en => '1',
    in_ifid_record => fetch_stage_out,
    out_ifid_record => ifid_out
);

-- Register File
reg_file_inst : reg_file port map
(
    clk => clk,
    REG_we => memwb_out.REG_we,
    REG_src_idx_1 => REG_src_idx_1,
    REG_src_idx_2 => REG_src_idx_2,
    REG_dst_idx => memwb_out.REG_dst_idx,
    REG_write_data => write_back_out,
    REG_src_1 => decode_stage_out.REG_src_1,
    REG_src_2 => decode_stage_out.REG_src_2,
    --blinky => led_status
);

-- Decoder
decode_inst: decoder port map
(
    instr => ifid_out.instr,
    decoder_out => decode_stage_out.decoder_out,
    REG_src_idx_1 => REG_src_idx_1,
    REG_src_idx_2 => REG_src_idx_2
);

-- Register ID/EX
reg_idex_inst : reg_idex
port map
(
    clk => clk,
    clr => '0',
    en => '1',
    in_idex_record => decode_stage_out,
    out_idex_record => idex_out
);

-- Execute
execute_inst : execute 
port map
(
    ALU_src_1_ctrl => idex_out.decoder_out.ALU_src_1_ctrl,
    ALU_src_2_ctrl => idex_out.decoder_out.ALU_src_2_ctrl,
    REG_src_1 => idex_out.REG_src_1,
    REG_src_2 => idex_out.REG_src_2,
    do_branch => idex_out.decoder_out.do_branch,
    do_jmp => idex_out.decoder_out.do_jmp,
    imm => idex_out.decoder_out.imm,
    op_ctrl => idex_out.decoder_out.op_ctrl,
    pc => idex_out.pc,
    forward_1 => "01",
    forward_2 => "01",
    WB_reg => x"00000000",
    MEM_reg => x"00000000",

    sel_pc => execute_stage_out_sel_pc,
    ALU_res_out => execute_stage_out.ALU_res
);

execute_stage_out.REG_we <= idex_out.decoder_out.REG_we;
execute_stage_out.MEM_we <= idex_out.decoder_out.MEM_we;
execute_stage_out.WB_src_ctrl <= idex_out.decoder_out.WB_src_ctrl;
execute_stage_out.MEM_op <= idex_out.decoder_out.MEM_op;
execute_stage_out.REG_dst_idx <= idex_out.decoder_out.REG_dst_idx;
execute_stage_out.pc <= idex_out.pc;
execute_stage_out.REG_src_2 <= idex_out.REG_src_2;

-- Register EX/MEM
reg_exmem_inst : reg_exmem
port map
(
    clk => clk,
    clr => '0',
    en => '1',
    in_exmem_record => execute_stage_out,
    out_exmem_record => exmem_out
);

memory_stage_out.REG_we <= exmem_out.REG_we;
memory_stage_out.MEM_we <= exmem_out.MEM_we;
memory_stage_out.WB_src_ctrl <= exmem_out.WB_src_ctrl;
memory_stage_out.REG_dst_idx <= exmem_out.REG_dst_idx;
memory_stage_out.pc <= exmem_out.pc;
memory_stage_out.ALU_res <= exmem_out.ALU_res;

-- Memory
memory_inst : data_mem
port map 
(
    clk => clk,
    pc => exmem_out.pc,
    MEM_we => exmem_out.MEM_we,
    MEM_op => exmem_out.MEM_op,
    MEM_data_in => exmem_out.REG_src_2,
    MEM_addr => exmem_out.ALU_res,
    MEM_data_out => memory_stage_out.MEM_out,
    blinky => led_status 
);

-- Register MEM/WB
reg_memwb_inst : reg_memwb
port map
(
    clk => clk,
    en => '1',
    clr => '0',
    in_memwb_record => memory_stage_out,
    out_memwb_record => memwb_out
);

-- Writeback
write_back_inst : write_back
port map
(
    WB_src_ctrl => memwb_out.WB_src_ctrl,
    pc => memwb_out.pc,
    ALU_res => memwb_out.ALU_res,
    MEM_out => memwb_out.MEM_out,
    REG_write_data => write_back_out
);

process(clk)
begin

end process;
end behavioral;
