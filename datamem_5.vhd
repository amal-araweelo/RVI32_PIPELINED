-- Data memory (only supports words right now)
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity datamem_5 is
  port
  (
    pc_in : std_logic_vector(31 downto 0) := (others => '0');
    r1_in : std_logic_vector(31 downto 0) := (others => '0');
    r2_in : std_logic_vector(31 downto 0) := (others => '0');

    mem_do_write_in : std_logic                    := '0'; -- write enable
    mem_op_in       : std_logic_vector(2 downto 0) := (others => '0'); -- memory operation

    clk      : in std_logic                      := '0'; -- clock
    data_in  : in std_logic_vector(31 downto 0)  := (others => '0');
    data_out : out std_logic_vector(31 downto 0) := (others => '0');
    addr     : in std_logic_vector(31 downto 0)  := (others => '0') -- address
  );
end datamem_5;

architecture impl of datamem_5 is
  type ram_type is array(8388608 downto 0) -- 1 MiB (note: ask Martin about size of memory for instr and data)
  of std_logic_vector (31 downto 0);
  signal ram : ram_type;

begin
  process (clk) begin
    case mem_op_in is -- only implemented store word for now
      when sw =>
        if (rising_edge(clk)) then
          if (mem_do_write_in = '1') then
            ram(to_integer(unsigned(addr))) <= data_in;
          end if;
        end if;
      when others =>
        data_out <= ram(to_integer(unsigned(addr))); -- data is always loaded from memory given addr
    end case;
  end process;
end architecture;