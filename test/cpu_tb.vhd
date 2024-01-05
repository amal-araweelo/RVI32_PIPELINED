library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity cpu_tb is
    -- Testbench has no ports
end cpu_tb;

architecture behavior of cpu_tb is 

component cpu is 
    port (clock : in std_logic);
end component;

signal clock : std_logic := '0';

constant clock_period : time := 10 ns;

begin

uut: cpu port map (clock => clock);

clock_process : process
begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
end process;


stim_proc: process
begin
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;

    std.env.stop(0);
end process;

end behavior;
