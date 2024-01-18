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

  -- INSERT PROGRAM

  others => (x"00000000")
  );

begin
  process (all) begin
    MEM_instr_out <= rom(to_integer(unsigned(MEM_addr))); -- data is always loaded from memory given addr
  end process;
end architecture;
