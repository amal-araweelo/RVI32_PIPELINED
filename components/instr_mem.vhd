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
  0      => x"00000093", -- li	ra,0
  1      => x"00500113", -- li	sp,5
  2      => x"00108093", -- addi	ra,ra,1
  3      => x"00000013", -- nop
  4      => x"00000013", -- nop
  5      => x"00000013", -- nop
  6      => x"fe2098e3", -- bne	ra,sp,8 <loop>
  others => (x"00000000")
  );
  attribute rom_style        : string;
  attribute rom_style of ROM : signal is "block";

begin
  process (all) begin
    MEM_instr_out <= rom(to_integer(unsigned(MEM_addr))); -- data is always loaded from memory given addr
  end process;
end architecture;