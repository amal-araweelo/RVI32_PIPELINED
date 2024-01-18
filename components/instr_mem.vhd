-- Data memory (only supports words right now)
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity instr_mem is
  port
  (
    -- Inputs
    clk      : in std_logic;
    MEM_addr : in std_logic_vector(31 downto 0);

    -- Outputs
    MEM_instr_out : out std_logic_vector(31 downto 0)
  );
end instr_mem;

architecture impl of instr_mem is
  type rom_type is array(2 ** 10 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);

  signal rom : rom_type := (

0 => x"00100137", -- lui	sp,0x100
1 => x"008000ef", -- jal	ra,c <main>
2 => x"ff9ff0ef", -- jal	ra,0 <main-0xc>
3 => x"fe010113", -- addi	sp,sp,-32 # fffe0 <main+0xfffd4>
4 => x"00812e23", -- sw	s0,28(sp)
5 => x"02010413", -- addi	s0,sp,32
6 => x"00100793", -- li	a5,1
7 => x"fef42623", -- sw	a5,-20(s0)
8 => x"fec42783", -- lw	a5,-20(s0)
9 => x"00178793", -- addi	a5,a5,1
10 => x"fef42623", -- sw	a5,-20(s0)
11 => x"00000793", -- li	a5,0
12 => x"00078513", -- mv	a0,a5
13 => x"01c12403", -- lw	s0,28(sp)
14 => x"02010113", -- addi	sp,sp,32
15 => x"00008067", -- ret
  
  others => (x"00000000")
  );

begin
  process (all) begin
    MEM_instr_out <= rom(to_integer(unsigned(MEM_addr))); -- data is always loaded from memory given addr
  end process;
end architecture;
