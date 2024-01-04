library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is 
    port (clock : in std_logic);
end cpu;

architecture behavioral of cpu is 

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

component fetcher is
    port (
     clock, branch, reset, we : in std_logic;
     pc_out : out std_logic_vector (31 downto 0);
     data_input: in std_logic_vector (31 downto 0);
     branch_address: in std_logic_vector (31 downto 0);
     instruction: out std_logic_vector (31 downto 0)
     );
end component;

component reg_ifid is
	port (
	in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);		-- register inputs
	out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0);	-- register outputs
	clk, en, clear : in std_logic												-- enable, clear
	); 
end component;


begin

    -- Instruction Fetch
    
    -- Instruction Decode

    -- Execute 

    -- Memory and Write Back

end behavioral;
