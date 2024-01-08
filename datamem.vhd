-- Data memory (only supports words right now)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity datamem is
  port
  (
    clk    : in std_logic; -- clock
    we     : in std_logic; -- write enable
    wrData : in std_logic_vector(31 downto 0); -- write data
    addr   : in std_logic_vector(31 downto 0); -- address
    mem_op : in std_logic_vector(2 downto 0); -- memory operation
    rdData : out std_logic_vector(31 downto 0) -- read data
  );
end datamem;

architecture impl of datamem is
  type ram_type is array(2**10 downto 0) -- 1K
  of std_logic_vector (31 downto 0);
  signal ram : ram_type;

begin
  process (clk) begin
    if (rising_edge(clk)) then
	case mem_op is -- only implemented store word for now
	    when sw =>
		if (we = '1') then
		    ram(to_integer(unsigned(addr))) <= wrData;
		end if;
	    when others =>
		null;
	end case;
    end if;
  end process;
	rdData <= ram(to_integer(unsigned(addr))); -- data is always loaded from memory given addr
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrmem is
port 
(
    rdAddr : in std_logic_vector(31 downto 0);
    rdData : out std_logic_vector(31 downto 0)
);
end instrmem;

architecture impl of instrmem is
    -- Initialize the memory with the program
    type ram_type is array(2**10-1 downto 0)
    of std_logic_vector (31 downto 0);

    signal instructions : ram_type := (
		    0 => x"00000000", 
		    1 => x"00200113", -- addi x2, x0, 2
		    2 => x"00100093", -- addi x1, x0, 1
		    others => (x"00000000") 
    );

begin
		rdData <= instructions(to_integer(unsigned(rdAddr(31 downto 2))));
end architecture;
