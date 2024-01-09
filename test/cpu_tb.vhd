library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;
use work.records_pkg.all;

entity cpu_tb is
    -- Testbench has no ports
end cpu_tb;

architecture behavior of cpu_tb is 

component fetcher is
  port
  (
    clk, sel_pc, clr, en : in std_logic;
    branch_addr          : in std_logic_vector (31 downto 0);
    instr                : out std_logic_vector (31 downto 0);
    pc                   : out std_logic_vector (31 downto 0)
  );
end component;

component reg_ifid is
  port
  (
    clk, clr, en    : in std_logic;
    in_ifid_record  : in t_ifid_reg;
    out_ifid_record : out t_ifid_reg
  );
end component;

component decoder is
port (
	instr: in std_logic_vector(31 downto 0);
	decoder_out: out t_decoder;
	REG_src_idx_1, REG_src_idx_2: out std_logic_vector (4 downto 0)
	);
end component;

component reg_file is
	generic(
	B: integer:= 32; 	-- no. of bits in register
	W: integer:= 5		-- no. of address bits (5 bits=32 addresses)
	);
	port (
		clk, REG_we: in std_logic;
		instr: in std_logic_vector(31 downto 0);
		REG_dst_idx: in std_logic_vector(4 downto 0);
		REG_write_data: in std_logic_vector(B-1 downto 0);
		REG_src_1, REG_src_2: out std_logic_vector(B-1 downto 0)
	);
end component;


-- Clock signal
signal clk : std_logic := '0';
constant clk_period : time := 10 ns;

-- Fetcher signals
signal fetch_out : t_ifid_reg;

-- Register IF/ID signals
signal ifid_out : t_ifid_reg;

-- Decoder signals
signal dec_out : t_idex_reg;
signal REG_src_idx_1, REG_src_idx_2 : std_logic_vector(4 downto 0);

begin

fetcher_inst: fetcher port map
(
    clk => clk,
    sel_pc => '0',
    clr => '0',
    en => '1',
    branch_addr => (others => '0'),
    instr => fetch_out.instr,
    pc => fetch_out.pc
);

reg_ifid_inst: reg_ifid port map
(
    clk => clk,
    clr => '0',
    en => '1',
    in_ifid_record => fetch_out,
    out_ifid_record => ifid_out
);

-- Register FILE

reg_file_inst : reg_file port map
(
    clk => clk,
    REG_we => '0', -- TODO: get from WB
    instr => ifid_out.instr,
    REG_dst_idx => "00000", -- TODO: get from WB
    REG_write_data => x"00000000", -- TODO: get from WB
    REG_src_1 => dec_out.REG_src_1,
    REG_src_2 => dec_out.REG_src_2
);

-- Decoder
decode_inst: decoder port map
(
    instr => ifid_out.instr,
    decoder_out => dec_out.decoder_out,
    REG_src_idx_1 => REG_src_idx_1,
    REG_src_idx_2 => REG_src_idx_2
);

-- Register ID/EX
-- reg_idex_inst : reg_idex
-- port map
-- (
-- 
-- );

clk_process : process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

stim_proc: process
begin
    wait for clk_period;

    wait for clk_period;
    report "IFID.instr = " & to_string(ifid_out.instr);
    report "IFID.pc = " & to_string(ifid_out.pc);
    report "dec_out.decoder_out.REG_dst_idx = " & to_string(dec_out.decoder_out.REG_dst_idx);
    report "dec_out.decoder.imm = " & to_string(dec_out.decoder_out.imm);

    report "dec_out.REG_src_1 = " & to_string(dec_out.REG_src_1);
    report "dec_out.REG_src_2 = " & to_string(dec_out.REG_src_2);

    wait for clk_period;
    report "IFID.instr = " & to_string(ifid_out.instr);
    report "IFID.pc = " & to_string(ifid_out.pc);
    report "dec_out.decoder_out.REG_dst_idx = " & to_string(dec_out.decoder_out.REG_dst_idx);
    report "dec_out.decoder.imm = " & to_string(dec_out.decoder_out.imm);

    wait for clk_period;
    report "IFID.instr = " & to_string(ifid_out.instr);
    report "IFID.pc = " & to_string(ifid_out.pc);
    report "dec_out.decoder_out.REG_dst_idx = " & to_string(dec_out.decoder_out.REG_dst_idx);

    wait for clk_period;
    report "IFID.instr = " & to_string(ifid_out.instr);
    report "IFID.pc = " & to_string(ifid_out.pc);

    std.env.stop(0);
end process;

end behavior;
