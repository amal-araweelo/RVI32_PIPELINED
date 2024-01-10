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
    MEM_addr : in std_logic_vector(31 downto 0) := (others => '0'); -- address (it is the value stored in register 2)

    -- Outputs
    MEM_instr_out : out std_logic_vector(31 downto 0) := (others => '0')
  );
end instr_mem;

architecture impl of instr_mem is
  type rom_type is array(2 ** 10 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);
  signal rom : rom_type := (
    1  => x"00000113", -- addi x2, x0, 0
    2  => x"00100093", -- addi x1, x0, 1
    3  => x"00000013", -- addi x0, x0, 0
    4  => x"00000013", -- addi x0, x0, 0
    5  => x"00108093", -- addi x1, x1, 1
    6  => x"00000013", -- addi x0, x0, 0
    7 => x"00000013", -- nop
    8 => x"00508463",
    9 => x"fe0008e3",
    10 => x"00100113", 
    11 => x"00000013",
    12 => x"00000013",
    13 =>  x"00000013",
    14 => x"fc0006e3",
  	    others => (x"00000000") 
    );

begin
  process (clk) begin
    if (rising_edge(clk)) then
      MEM_instr_out <= rom(to_integer(unsigned(MEM_addr(31 downto 2)))); -- data is always loaded from memory given addr
    end if;
  end process;
end architecture;
