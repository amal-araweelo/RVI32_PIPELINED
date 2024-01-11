-- Data memory (only supports words right now)
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity data_mem is
  port
  (
    -- Inputs
    clk         : in std_logic                     := '0'; -- clock
    pc          : in std_logic_vector(31 downto 0) := (others => '0');
    MEM_we      : in std_logic                     := '0'; -- write enable
    MEM_op      : in std_logic_vector(3 downto 0)  := (others => '0'); -- memory operation
    MEM_data_in : in std_logic_vector(31 downto 0) := (others => '0');
    MEM_addr    : in std_logic_vector(31 downto 0) := (others => '0'); -- address (it is the value stored in register 2)

    -- Outputs
    MEM_data_out : out std_logic_vector(31 downto 0) := (others => '0');
    blinky : out std_logic
  );
end data_mem;

architecture impl of data_mem is
  type ram_type is array(2 ** 10 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);
  signal ram : ram_type;


begin
  process (clk, blinky) begin
       -- Changes
       blinky <= ram(0)(0);
    if (rising_edge(clk)) then
      MEM_data_out <= ram(to_integer(unsigned(MEM_addr))); -- data is always loaded from memory given addr
      case MEM_op is -- only implemented store word for now
        when sw =>
          if (MEM_we = '1') then
            ram(to_integer(unsigned(MEM_addr))) <= MEM_data_in;
	    -- report "[DATA MEM] Storing " & to_string(MEM_data_in) & " at address " & to_string(MEM_addr); -- TODO: Delete
          end if;
        when others =>
          null;
      end case;
    end if;
  end process;
end architecture;
