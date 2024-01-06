library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.records_pkg.all;


entity cpu is 
    port (clock : in std_logic);
end cpu;

architecture behavioral of cpu is 

component reg_file is 
	generic(
	B: integer:= 32;
	W: integer:= 5
	);
	port (
		clock, we: in std_logic;
		instruction: in std_logic_vector(31 downto 0);
		w_addr: in std_logic_vector(4 downto 0);
		w_data: in std_logic_vector(B-1 downto 0);
		rs1_out, rs2_out: out std_logic_vector(B-1 downto 0)
	);
end component;


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
     data_input: in std_logic_vector (31 downto 0);
     branch_address: in std_logic_vector (31 downto 0);
     pc_out : out std_logic_vector (31 downto 0);
     instruction: out std_logic_vector (31 downto 0)
     );
end component;

component reg_ifid is
	port (
	clock, en, clear : in std_logic;						-- enable, clear
	in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);	-- register inputs
	out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0)	-- register outputs
	); 
end component;

component decoder is
	port (
	instruction: in std_logic_vector(31 downto 0);
	decoder_out: out t_from_decoder;
  REG_rs1, REG_rs2: out std_logic_vector (4 downto 0)
	);
end component;


-- Signals for interconnection
    signal branch, reset, we, en, clear : std_logic;
    signal data_input, branch_address, in_pc4 : std_logic_vector(31 downto 0);
    signal pc_out, instruction, out_pc, out_pc4, out_instruction : std_logic_vector(31 downto 0);
		signal decoder_out : t_from_decoder;
		signal REG_rs1, REG_rs2 : std_logic_vector (4 downto 0);
		signal w_addr : std_logic_vector (4 downto 0);
		signal w_data : std_logic_vector (31 downto 0);
		signal reg1_out, reg2_out : std_logic_vector (31 downto 0);

begin

    -- Fetcher
    fetcher_inst: fetcher
        port map (
            clock => clock,
            branch => branch,
            reset => reset,
            we => we,
            data_input => data_input,
            branch_address => branch_address,
            pc_out => pc_out,
            instruction => instruction
        );

  	-- Register File

		reg_file_inst : reg_file 
				generic map (
						B => 32,
						W => 5
				)
				port map (
						clock => clock,
						we => we,
						instruction => out_instruction,
						w_addr => w_addr,
						w_data => w_data,
						rs1_out => reg1_out,
						rs2_out => reg2_out
				);

    -- Register IF/ID
     reg_ifid_inst: reg_ifid
        port map (
            clock => clock,
            en => en,
            clear => clear,
            in_pc => pc_out,
            in_pc4 => in_pc4,
            in_instruction => instruction,
            out_pc => out_pc,
            out_pc4 => out_pc4,
            out_instruction => out_instruction
        );

		-- Decoder
		decoder_inst: decoder 
				port map (
						instruction => out_instruction,
						decoder_out => decoder_out,
						REG_rs1 => REG_rs1,
						REG_rs2 => REG_rs2
			 );

			reset <= '0';
			branch <= '0';
			en <= '1';
			clear <= '0';
			branch_address <= x"00000000";
			we <= '0';


		 process(clock) is
		 begin 
		
		   if (rising_edge(clock)) then

					 report "PC: " & to_string(out_pc);
					 report "Instruction: " & to_string(out_instruction);
					 report "Immediate: " & to_string(decoder_out.immediate);
					 report "Register 1: " & to_string(reg1_out);
					 report "Register 2: " & to_string(reg2_out);
			 
			-- Instruction Fetch

			-- Instruction Decode

			-- Execute 

			-- Memory and Write Back
		  
		  end if;
		 end process;

end behavioral;
