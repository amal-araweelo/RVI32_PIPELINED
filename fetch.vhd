-- Fetch stage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- read binary file
-- Hardcode an addi instruction
-- addi x1, x0, 10 -> 0x00A00093

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
signal pc : std_logic_vector (31 downto 0) := x"00000000";
signal my_instruction : std_logic_vector (31 downto 0) := x"00A00093"; -- addi x1, x0, 10
signal length : std_logic_vector(31 downto 0) := x"00000004";

component memory is
  port
  (
    clk    : in std_logic;
    we     : in std_logic;
    rdData : out std_logic_vector(31 downto 0);
    wrData : in std_logic_vector(31 downto 0);
    addr   : in std_logic_vector(31 downto 0)
  );
end component;

begin

instruction <= my_instruction;

-- Instruction_Memory: memory port map (clock, we, instruction, data_input, pc); -- TODO: Add this

process (clock, reset)
begin 
    if (reset = '1') then
  	pc_out <= x"00000000";
    elsif (rising_edge(clock)) then
	if (branch = '1') then
	    pc_out <= branch_address;
	else
	    pc_out <= std_logic_vector(unsigned(pc_out) + unsigned(length));
	end if;
    end if;
end process;

end behavioral;
