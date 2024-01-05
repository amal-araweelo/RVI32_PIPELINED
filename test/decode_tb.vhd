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
	decoder_out: out t_from_decoder
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
    immediate => x"00000000",
    REG_rs1 => "00000",
    REG_rs2 => "00000"
);

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
	report "Value for rs1_out is " & to_string(rs1_out);
	report "Value for rs2_out is " & to_string(rs2_out);

	we <= '1';
	w_addr <= "00001";
	w_data <= x"00000001";
	wait for clock_period;

	report "Value for rs1_out is " & to_string(rs1_out);
	report "Value for rs2_out is " & to_string(rs2_out);

	we <= '1';
	w_addr <= "00011";
	w_data <= x"00000003";
	wait for clock_period;

	report "Value for rs1_out is " & to_string(rs1_out);
	report "Value for rs2_out is " & to_string(rs2_out);
	
	w_addr <= "00010";
	w_data <= x"00000002";
	instruction <= x"00308113";
	wait for clock_period;
	wait for clock_period;
	wait for clock_period;

	report "Value for rs1_out is " & to_string(rs1_out);
	report "Value for rs2_out is " & to_string(rs2_out);

	instruction <= x"00308113";
	report "Instruction is " & to_string(instruction);
	report "Value for rd is " & to_string(decoder_out.rd);
	report "Value for ALUsrc1 is " & to_string(decoder_out.ALUsrc1);
	report "Value for ALUsrc2 is " & to_string(decoder_out.ALUsrc2);
	report "Value for ALUop is " & to_string(decoder_out.ALUop);
	report "Value for REG_we is " & to_string(decoder_out.REG_we);
	report "Value for immediate is " & to_string(decoder_out.immediate);
	report "Value for REG_rs1 is " & to_string(decoder_out.REG_rs1);
	report "Value for REG_rs2 is " & to_string(decoder_out.REG_rs2);


	std.env.stop(0);
    end process;

end behavioral;
    
	


