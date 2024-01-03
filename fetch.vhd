library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Hardcode an addi instruction
-- addi x1, x0, 10 -> 0x00A00093

entity fetcher is 
    port (
     clock, branch, reset : in std_logic;
     we : in std_logic; 
     pc_out : out std_logic_vector (31 downto 0);
     data_input: in std_logic_vector (31 downto 0);
     branch_address: in std_logic_vector (31 downto 0);
     instruction: out std_logic_vector (31 downto 0)
     );
end fetcher;

architecture behavioral of fetcher is 
signal pc : std_logic_vector (31 downto 0) := (others => '0');
signal my_instruction : std_logic_vector (31 downto 0) := x"00A00093"; -- addi x1, x0, 10

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
pc_out <= pc;
instruction <= my_instruction;

-- Instruction_Memory: memory port map (clock, we, instruction, data_input, pc);

process (clock, reset, branch, branch_address)
begin 
    if (reset = '0') then
	PC <= (others => '0');
    elsif (rising_edge(clock)) then
	if (branch = '1') then
	    PC <= branch_address;
	else
	    PC <= PC + 4;
	end if;
    end if;
end process;

end behavioral;
