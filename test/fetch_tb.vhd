library ieee;
use ieee.std_logic_1164.all;

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
        clock => clock,
        branch => branch,
        reset => reset,
        we => we,
        pc_out => pc_out,
        data_input => data_input,
        branch_address => branch_address,
        instruction => instruction
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
        -- hold reset state for 100 ns.
        wait for 100 ns;
        reset <= '0';

        -- Insert stimulus here 
        wait for clock_period*10;
        branch <= '1';
        branch_address <= x"00000004";

        wait for clock_period*10;
        branch <= '0';

        -- add more test scenarios as needed

        -- finish simulation
        wait;
    end process;

end behavior;
