library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

-- IF/ID register
entity reg_ifid is
  port
  (
    clk, clr, en    : in std_logic;
    in_ifid_record  : in t_ifid;
    out_ifid_record : out t_ifid
  );
end reg_ifid;

architecture behavioral of reg_ifid is
  -- Intermediate signal
  signal intermediate_ifid_record : t_ifid;
begin

  -- Clock process
  process(clk)
    begin
    if(rising_edge(clk)) then
      out_ifid_record <= intermediate_ifid_record;
    end if;
  end process;
    -- Combinatorial process
  process(all)
    begin
      intermediate_ifid_record <= in_ifid_record;
      if (clr = '1') then
        intermediate_ifid_record.pc <= (others => '0');
        intermediate_ifid_record.instr <= (others => '0');
      end if;

      if (clr='0' and en='1') then
        intermediate_ifid_record <= in_ifid_record;
      end if;
   end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

-- ID/EX register
entity reg_idex is
  port
  (
    clk, clr, en    : in std_logic;
    in_idex_record  : in t_idex;
    out_idex_record : out t_idex
  );
end reg_idex;

architecture behavioral of reg_idex is
  -- Intermediate signal
  signal intermediate_idex_record : t_idex;
  begin
  -- Clock process
  process(clk)
    begin
    if (rising_edge(clk)) then
      out_idex_record <= intermediate_idex_record;
    end if;
  end process;

  -- Combinatorial process
  process(all) 
    begin
      intermediate_idex_record <= in_idex_record;
      if (clr = '1') then
        -- Zero out specific fields in the decoder_out record
        intermediate_idex_record.decoder_out.ALU_src_1_ctrl <= '0';
        intermediate_idex_record.decoder_out.ALU_src_2_ctrl <= '0';
        intermediate_idex_record.decoder_out.op_ctrl       <= (others => '0');
        intermediate_idex_record.decoder_out.REG_we        <= '0';
        intermediate_idex_record.decoder_out.imm           <= (others => '0');
        intermediate_idex_record.decoder_out.WB_src_ctrl   <= (others => '0');
        intermediate_idex_record.decoder_out.MEM_op        <= (others => '0');
        intermediate_idex_record.decoder_out.MEM_we        <= '0';
        intermediate_idex_record.decoder_out.do_jmp        <= '0';
        intermediate_idex_record.decoder_out.do_branch     <= '0';
        --out_idex_record.decoder_out.opcode        <= (others => '0');
        intermediate_idex_record.decoder_out.MEM_rd      <= '0';
      end if; 

      if (clr = '0' and en = '1') then
        intermediate_idex_record <= in_idex_record;
      end if;
  end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

-- EX/MEM register
entity reg_exmem is
  port
  (
    clk, clr, en     : in std_logic;
    in_exmem_record  : in t_exmem;
    out_exmem_record : out t_exmem
  );
end reg_exmem;

architecture behavioral of reg_exmem is
-- Intermediate signal
signal intermediate_exmem_record: t_exmem;

begin
  intermediate_exmem_record <= in_exmem_record;
  -- Clock process
  process(clk)
    begin
    if(rising_edge(clk)) then
      out_exmem_record <= intermediate_exmem_record;
    end if;
  end process;

  -- Combinatorial process
  process(all)
    begin
      if (clr = '1') then
        intermediate_exmem_record.REG_we      <= '0'; 
        intermediate_exmem_record.MEM_we      <= '0'; 
        intermediate_exmem_record.WB_src_ctrl <= (others => '0'); 
        intermediate_exmem_record.MEM_op      <= (others => '0'); 
        intermediate_exmem_record.REG_dst_idx <= (others => '0'); 
        intermediate_exmem_record.pc          <= (others => '0'); 
        intermediate_exmem_record.ALU_res     <= (others => '0'); 
        intermediate_exmem_record.REG_src_2   <= (others => '0'); 
      end if;

      if (clr = '0' and en = '1') then 
        intermediate_exmem_record <=  in_exmem_record;
        intermediate_exmem_record.REG_we      <= in_exmem_record.REG_we;
        intermediate_exmem_record.WB_src_ctrl <= in_exmem_record.WB_src_ctrl;
        intermediate_exmem_record.REG_dst_idx <= in_exmem_record.REG_dst_idx;
        intermediate_exmem_record.pc          <= in_exmem_record.pc;

	      intermediate_exmem_record.ALU_res   <= in_exmem_record.ALU_res;
	      intermediate_exmem_record.REG_src_2 <= in_exmem_record.REG_src_2;
        intermediate_exmem_record.MEM_op    <= in_exmem_record.MEM_op;
        intermediate_exmem_record.MEM_we    <= in_exmem_record.MEM_we;
      end if;
  end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.records_pkg.all;

-- MEM/WB register
entity reg_memwb is
  port
  (
    clk, clr, en     : in std_logic;
    in_memwb_record  : in t_memwb;
    out_memwb_record : out t_memwb
  );
end reg_memwb;

architecture behavioral of reg_memwb is
  -- Intermediate signal
  signal intermediate_memwb_record : t_memwb;
begin
  intermediate_memwb_record <= in_memwb_record;
  -- Clock process
  process(clk)
    begin
    if(rising_edge(clk)) then
      out_memwb_record <= intermediate_memwb_record;
    end if;
  end process;

  -- Combinatorial process
  process(all)
    begin
      -- TODO: insert what happens when we clear
      if (clr = '0' and en = '1') then -- if the signal is not to clr the reg
        out_memwb_record <= intermediate_memwb_record;  
      end if;
    end process;
end behavioral;
