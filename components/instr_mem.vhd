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
  type rom_type is array(2 ** 7 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);

  signal rom : rom_type := (
    0 => x"00000093", -- li ra,0
    1 => x"00100113", -- li sp,1
    2 => x"00500193", -- li gp,5
    3 => x"00000013", -- nop
    4 => x"00000013", -- nop
    5 => x"00000013", -- nop
    6 => x"00202023", -- sw sp,0(zero) # 0 <reset>
    7 => x"00000013", -- nop
    8 => x"00000013", -- nop
    9 => x"00000013", -- nop
    10 => x"00000013", -- nop
    11 => x"00000013", -- nop
    12 => x"00108093", -- addi      ra,ra,1
    13 => x"00000013", -- nop
    14 => x"00000013", -- nop
    15 => x"00000013", -- nop
    16 => x"00308463", -- beq       ra,gp,48 <blink>
    17 => x"fe0002e3", -- beqz      zero,28 <loop>
    18 => x"00002103", -- lw        sp,0(zero) # 0 <reset>
    19 => x"00000013", -- nop
    20 => x"00000013", -- nop
    21 => x"00000013", -- nop
    22 => x"00000113", -- li        sp,0
    23 => x"fa0002e3", -- beqz      zero,0 <reset>
	others => (x"00000000") 
    );

    -- Sync
    signal sink : std_logic_vector(1 downto 0);
  
begin
  sink <= MEM_addr(1 downto 0);
  process (clk) begin
    if (rising_edge(clk)) then
      MEM_instr_out <= rom(to_integer(unsigned(MEM_addr(31 downto 2)))); -- data is always loaded from memory given addr
    end if;
  end process;
end architecture;
