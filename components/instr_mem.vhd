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
    MEM_addr : in std_logic_vector(31 downto 0) := (others => '0');

    -- Outputs
    MEM_instr_out : out std_logic_vector(31 downto 0)
  );
end instr_mem;

architecture impl of instr_mem is
  type rom_type is array(2 ** 10 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);
  signal rom : rom_type := (
0 => x"00500113", -- li	sp,5
1 => x"00000013", -- nop
2 => x"00000013", -- nop
3 => x"00000013", -- nop
4 => x"00202023", -- sw	sp,0(zero) # 0 <.text>
5 => x"00000013", -- nop
6 => x"00000013", -- nop
7 => x"00000013", -- nop
8 => x"00002083", -- lw	ra,0(zero) # 0 <.text>
9 => x"00000013", -- nop
10 => x"00000013", -- nop
11 => x"00000013", -- nop
	others => (x"00000000") 
    );

begin
  process (clk) begin
    if (rising_edge(clk)) then
      MEM_instr_out <= rom(to_integer(unsigned(MEM_addr(31 downto 2)))); -- data is always loaded from memory given addr
    end if;
  end process;
end architecture;
