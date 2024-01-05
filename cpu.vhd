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
     clk, branch, reset, we : in std_logic;
     data_input: in std_logic_vector (31 downto 0);
     branch_address: in std_logic_vector (31 downto 0);
     pc_out : out std_logic_vector (31 downto 0);
     instruction: out std_logic_vector (31 downto 0)
     );
end component;

component reg_ifid is
	port (
	clk, en, clear : in std_logic;						-- enable, clear
	in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);	-- register inputs
	out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0)	-- register outputs
	); 
end component;

-- Signals for interconnection
    signal branch, reset, we, en, clear : std_logic;
    signal data_input, branch_address, in_pc4 : std_logic_vector(31 downto 0);
    signal pc_out, instruction, out_pc, out_pc4, out_instruction : std_logic_vector(31 downto 0);

begin

    -- Instruction Fetch
    fetcher_inst: fetcher
        port map (
            clk => clock,
            branch => branch,
            reset => reset,
            we => we,
            data_input => data_input,
            branch_address => branch_address,
            pc_out => pc_out,
            instruction => instruction
        );

    -- Register IF/ID

     reg_ifid_inst: reg_ifid
        port map (
            clk => clock,
            en => en,
            clear => clear,
            in_pc => pc_out,
            in_pc4 => in_pc4,
            in_instruction => instruction,
            out_pc => out_pc,
            out_pc4 => out_pc4,
            out_instruction => out_instruction
        );

    
    -- Instruction Decode

    -- Execute 

    -- Memory and Write Back

end behavioral;
