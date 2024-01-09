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
    in_ifid_record  : in t_ifid_reg;
    out_ifid_record : out t_ifid_reg
  );
end reg_ifid;

architecture behavioral of reg_ifid is
begin
  process (clk, clr, en)
  begin
    if (clr = '1') then
      out_ifid_record.pc          <= (others => '0');
      out_ifid_record.instr <= (others => '0');
    end if;
    if (rising_edge(clk)) then -- do stuff on rising clk edge
      if (clr = '0' and en = '1') then -- if the signal is not to clr the reg
        out_ifid_record <= in_ifid_record;
      end if;
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
    in_idex_record  : in t_idex_reg;
    out_idex_record : out t_idex_reg
  );
end reg_idex;

architecture behavioral of reg_idex is
begin
  process (clk, clr, en)
  begin
    if (clr = '1') then
      -- Zero out specific fields in the decoder_out record
      out_idex_record.decoder_out.ALU_src_1_ctrl <= '0';
      out_idex_record.decoder_out.ALU_src_2_ctrl <= '0';
      out_idex_record.decoder_out.op_ctrl       <= (others => '0');
      out_idex_record.decoder_out.REG_we        <= '0';
      out_idex_record.decoder_out.imm           <= (others => '0');
      out_idex_record.decoder_out.WB_src_ctrl   <= (others => '0');
      out_idex_record.decoder_out.MEM_op        <= (others => '0');
      out_idex_record.decoder_out.MEM_we        <= '0';
      out_idex_record.decoder_out.do_jmp        <= '0';
      out_idex_record.decoder_out.do_branch     <= '0';
      out_idex_record.decoder_out.opcode        <= (others => '0');
      out_idex_record.decoder_out.MEM_read      <= '0';
    end if;

    if (rising_edge(clk)) then -- do stuff on rising clk edge
      if (clr = '0' and en = '1') then -- if the signal is not to clr the reg
        out_idex_record <= in_idex_record;
      end if;
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
    in_exmem_record  : in t_exmem_reg;
    out_exmem_record : out t_exmem_reg
  );
end reg_exmem;

architecture behavioral of reg_exmem is

begin
  -- Asynchronous
  out_exmem_record.ALU_res   <= in_exmem_record.ALU_res;
  out_exmem_record.REG_src_2 <= in_exmem_record.REG_src_2;
  out_exmem_record.MEM_op    <= in_exmem_record.MEM_op;
  out_exmem_record.MEM_we    <= in_exmem_record.MEM_we;

  process (clk, clr, en)
  begin
    if (clr = '1') then
      out_exmem_record.REG_we      <= '0'; 
      out_exmem_record.MEM_we      <= '0'; 
      out_exmem_record.WB_src_ctrl <= (others => '0'); 
      out_exmem_record.MEM_op      <= (others => '0'); 
      out_exmem_record.REG_dst_idx <= (others => '0'); 
      out_exmem_record.pc          <= (others => '0'); 
      out_exmem_record.ALU_res     <= (others => '0'); 
      out_exmem_record.REG_src_2   <= (others => '0'); 
    end if;

    if (rising_edge(clk)) then -- do stuff on rising clk edge
      if (clr = '0' and en = '1') then -- if the signal is not to clr the reg
        --out_exmem_record <= in_exmem_record;
        out_exmem_record.REG_we      <= in_exmem_record.REG_we;
        out_exmem_record.WB_src_ctrl <= in_exmem_record.WB_src_ctrl;
        out_exmem_record.REG_dst_idx <= in_exmem_record.REG_dst_idx;
        out_exmem_record.pc          <= in_exmem_record.pc;
      end if;
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
    in_memwb_record  : in t_memwb_reg;
    out_memwb_record : out t_memwb_reg
  );
end reg_memwb;

architecture behavioral of reg_memwb is
begin
  process (clk, clr, en)
  begin
    if (rising_edge(clk)) then -- do stuff on rising clk edge
      if (clr = '0' and en = '1') then -- if the signal is not to clr the reg
        out_memwb_record <= in_memwb_record;
      end if;
    end if;
  end process;
end behavioral;
