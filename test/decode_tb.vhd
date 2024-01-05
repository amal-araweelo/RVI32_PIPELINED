library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.env.stop;
use work.records_pkg.all;
use ieee.numeric_std.all;

entity decode_tb is
    -- Testbench has no ports
end decode_tb;

architecture behavioral of decode_tb is 

    component decoder
	port (
	instruction: in std_logic_vector(31 downto 0);
	decoder_out: out t_from_decoder;
  REG_rs1, REG_rs2: out std_logic_vector (4 downto 0)
	);
    end component;

    component reg_file is 
	generic(
	B: integer:= 32; 	-- no. of bits in register
	W: integer:= 5		-- no. of address bits (5 bits=32 addresses)
	);
	port (
		clock, we: in std_logic;
		instruction: in std_logic_vector(31 downto 0);
		w_addr: in std_logic_vector(4 downto 0);
		w_data: in std_logic_vector(B-1 downto 0);
		rs1_out, rs2_out: out std_logic_vector(B-1 downto 0)
	);
    end component;

    -- Inputs
    signal instruction : std_logic_vector(31 downto 0) := x"00000000";
    signal clk : std_logic := '0';
    signal we : std_logic := '0';
    signal w_addr : std_logic_vector(4 downto 0) := "00000";
    signal w_data : std_logic_vector(31 downto 0) := x"00000000";
    
    -- Outputs
    signal decoder_out : t_from_decoder := (rd => "00000",
    ALUsrc1 => '0',
    ALUsrc2  => '0',
    ALUop  => "0000",
    REG_we => '0',
    immediate => x"00000000"
);

		signal REG_rs1 : std_logic_vector(4 downto 0) := "00000";
		signal REG_rs2 : std_logic_vector(4 downto 0) := "00000";
    signal rs1_out : std_logic_vector(31 downto 0) := x"00000000";
    signal rs2_out : std_logic_vector(31 downto 0) := x"00000000";

    -- clk period definitions
    constant clock_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : decoder port map (
    instruction => instruction,
    decoder_out => decoder_out
    );

    uut_reg_file : reg_file port map (
	clock => clk,
	we => we,
	instruction => instruction,
	w_addr => w_addr,
	w_data => w_data,
	rs1_out => rs1_out,
	rs2_out => rs2_out
	);

	-- Clock process definitions
	clk_process :process
	begin
	    clk <= '0';
	    wait for clock_period/2;
	    clk <= '1';
	    wait for clock_period/2;
	end process;

    stim_proc: process
    begin 

	instruction <= x"00308113"; -- Needed to read the correct registers

	we <= '1';
	w_addr <= "00001";
	w_data <= x"00000001";
	wait for clock_period;

	we <= '1';
	w_addr <= "00011";
	w_data <= x"00000003";
	wait for clock_period;

	assert rs1_out = x"00000001" report "rs1_out is not correct" severity error;
	assert rs2_out = x"00000003" report "rs2_out is not correct" severity error;
	report "Test 1 [PASSED]" severity note;
	
	instruction <= x"00308113";
	wait for clock_period;

  assert decoder_out.rd = "00010" report "rd is not correct" severity error;
	assert decoder_out.ALUsrc1 = '0' report "ALUsrc1 is not correct" severity error;
	assert decoder_out.ALUsrc2 = '1' report "ALUsrc2 is not correct (needs to be 1 for I-type)" severity error;
	assert decoder_out.ALUop = "0000" report "ALUop is not correct (needs to be ADD)" severity error;
	assert decoder_out.REG_we = '1' report "REG_we is not correct" severity error;
	assert decoder_out.immediate = x"00000003" report "immediate is not correct" severity error;
	report "Test 2 [PASSED]" severity note;

	std.env.stop(0);
    end process;

end behavioral;
    
	


