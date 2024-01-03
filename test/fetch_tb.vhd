library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.env.stop;

entity fetcher_tb is
    -- Testbench has no ports
end fetcher_tb;

architecture behavior of fetcher_tb is 

    -- Component Declaration for the Unit Under Test (UUT)
    component fetcher
        port (
            clock, branch, reset : in std_logic;
            we : in std_logic; 
            pc_out : out std_logic_vector (31 downto 0);
            data_input: in std_logic_vector (31 downto 0);
            branch_address: in std_logic_vector (31 downto 0);
            instruction: out std_logic_vector (31 downto 0)
        );
    end component;

    -- Inputs
    signal clock : std_logic := '0';
    signal branch : std_logic := '0';
    signal reset : std_logic := '1';
    signal we : std_logic := '0';
    signal data_input : std_logic_vector(31 downto 0) := (others => '0');
    signal branch_address : std_logic_vector(31 downto 0) := (others => '0');

    -- Outputs
    signal pc_out : std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clock_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: fetcher port map (
        clock, branch, reset,
        we,
        pc_out,
        data_input,
        branch_address,
        instruction
    );

    -- Clock process definitions
    clock_process : process
    begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        reset <= '1';
        branch <= '0';
	we <= '1';
        wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);

	reset <= '0';
        wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);
        
        wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);
	
        wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);
        
	wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);

	wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);

        branch <= '1';
	branch_address <= x"00000123";
	wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);

	wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);

        branch <= '0';
	branch_address <= x"00000123";
	wait for clock_period*1;
	report "The value of PC is now: " & to_string(pc_out);

        -- finish simulation
	std.env.stop(0);
    end process;

end behavior;
