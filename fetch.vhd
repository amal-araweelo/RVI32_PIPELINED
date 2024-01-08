-- Fetch stage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- read binary file
-- Hardcode an addi instruction

entity fetcher is 
    port (
     clock, branch, reset, we : in std_logic;
     pc_out : out std_logic_vector (31 downto 0);
     data_input: in std_logic_vector (31 downto 0);
     branch_address: in std_logic_vector (31 downto 0);
     instruction: out std_logic_vector (31 downto 0)
     );
end fetcher;

architecture behavioral of fetcher is 
signal my_instruction : std_logic_vector (31 downto 0) := x"00100093"; -- addi x1, x0, 1
signal length : std_logic_vector(31 downto 0) := x"00000004";
signal reg : std_logic_vector(31 downto 0) := x"00000000";
signal pc_next : std_logic_vector(31 downto 0);

component instrmem is
  port
  (
    rdAddr   : in std_logic_vector(31 downto 0);
    rdData : out std_logic_vector(31 downto 0)
  );
end component;

begin

Instruction_Memory: instrmem port map ( rdData => instruction, rdAddr => reg);

process(branch, reg, branch_address) begin
		if (branch = '1') then
				pc_next <= branch_address;
		else
				pc_next <= std_logic_vector(unsigned(reg) + unsigned(length));
		end if;
end process;

process (clock, reset)
begin 
  if (reset = '1') then
					reg <= (others => '0');
  elsif (rising_edge(clock)) then
					reg <= pc_next;
  end if;
end process;

pc_out <= reg;
-- instruction <= my_instruction;

end behavioral;
