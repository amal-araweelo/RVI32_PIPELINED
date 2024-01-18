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
  type rom_type is array(2 ** 7 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);

  signal rom : rom_type := (
  0      => x"00000093", -- li ra,0
  1      => x"00100113", -- li sp,1
  2      => x"00000193", -- li gp,0
  3      => x"000081b7", -- lui        gp,0x8
  4      => x"00018193", -- mv gp,gp
  5      => x"00000213", -- li tp,0
  6      => x"000002b7", -- lui        t0,0x0
  7      => x"1f428293", -- addi       t0,t0,500 # 1f4 <waitloop+0x1b8>
  8      => x"00100113", -- li sp,1
  9      => x"0020a023", -- sw sp,0(ra)
  10     => x"00000a63", -- beqz      zero,3c <waitloop>
  11     => x"00000213", -- li        tp,0
  12     => x"00111113", -- slli      sp,sp,0x1
  13     => x"0020a023", -- sw        sp,0(ra)
  14     => x"00000263", -- beqz      zero,3c <waitloop>
  15     => x"00120213", -- addi      tp,tp,1 # 1 <reset-0x1f>
  16     => x"fe521ee3", -- bne       tp,t0,3c <waitloop>
  17     => x"00000213", -- li        tp,0
  18     => x"fc310ce3", -- beq       sp,gp,20 <reset>
  19     => x"fe0000e3", -- beqz      zero,2c <blinkloop>
  others => (x"00000000")
  );
  --attribute rom_style        : string;
  --attribute rom_style of ROM : signal is "block";

begin
  process (all) begin
    MEM_instr_out <= rom(to_integer(unsigned(MEM_addr))); -- data is always loaded from memory given addr
  end process;
end architecture;