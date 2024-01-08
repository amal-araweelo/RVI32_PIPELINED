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
    clock, en, clear : in std_logic;                        -- enable, clear
    in_pc, in_pc4, in_instruction : in std_logic_vector (31 downto 0);    -- register inputs
    out_pc, out_pc4, out_instruction : out std_logic_vector (31 downto 0)    -- register outputs
    ); 
end component;

component decoder is
    port (
    instruction: in std_logic_vector(31 downto 0);
    decoder_out: out t_from_decoder;
  REG_rs1, REG_rs2: out std_logic_vector (4 downto 0)
    );
end component;

component reg_idex is 
        port (
                clk, en, clear : std_logic;
                in_from_id : in t_from_id;
                out_to_ex : out t_from_id
     );
end component;

component alu is
  port
  (
    op_1, op_2 : in std_logic_vector(31 downto 0);
    ctrl       : in std_logic_vector(3 downto 0);
    res        : out std_logic_vector(31 downto 0)
  );
end component;

component datamem is
  port
  (
    clk    : in std_logic; -- clock
    we     : in std_logic; -- write enable
    wrData : in std_logic_vector(31 downto 0); -- write data
    addr   : in std_logic_vector(31 downto 0); -- address
    mem_op : in std_logic_vector(2 downto 0); -- memory operation
    rdData : out std_logic_vector(31 downto 0) -- read data
  );
end component;

component execute is
  port
  (
    -- Inputs
    -- the first two will be removed (only for testing);
    forward_1       : in std_logic_vector(1 downto 0);
    forward_2       : in std_logic_vector(1 downto 0);
    do_jmp_in       : in std_logic                     := '0';
    do_branch_in    : in std_logic                     := '0';
    alu_ctrl_in     : in std_logic_vector(3 downto 0)  := (others => '0');
    alu_op1_ctrl_in : in std_logic                     := '0'; -- select signal for operand 1
    alu_op2_ctrl_in : in std_logic                     := '0'; -- select signal for operand 2
    pc_in           : in std_logic_vector(31 downto 0) := (others => '0');
    r1_in           : in std_logic_vector(31 downto 0) := (others => '0');
    r2_in           : in std_logic_vector(31 downto 0) := (others => '0');
    imm_in          : in std_logic_vector(31 downto 0) := (others => '0');
    wb_reg_in       : in std_logic_vector(31 downto 0) := (others => '0'); -- to be forwarded from WB stage
    mem_reg_in      : in std_logic_vector(31 downto 0) := (others => '0'); -- to be forwarded from MEM stage
    -- more to come with forwarding, hazard and memory

    -- Ouputs
    sel_pc_out : out std_logic                     := '0'; -- select signal for pc
    alures_out : out std_logic_vector(31 downto 0) := (others => '0')
  );
end component;

component write_back is
  port
  (
    mem_wr_src_ctrl_in : in std_logic_vector(1 downto 0); 
    pc_in              : in std_logic_vector(31 downto 0);
    alures_in          : in std_logic_vector(31 downto 0);
    mem_read_in        : in std_logic_vector(31 downto 0); -- data_out from datamem

    wr_data : out std_logic_vector(31 downto 0) -- data to be written to the register file
  );
end component;

component reg_exmem is
        port (
                clk, en, clear : std_logic;
                in_from_ex : in t_from_ex;
                out_to_mem : out t_from_ex
     );
end component;

component reg_memwb is
  port
  (
    clk : in std_logic; -- clock
    in_from_mem: in t_from_mem;
    out_to_wb : out t_from_mem
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
    signal reg_idex_out : t_from_id;
    signal clear_idex : std_logic;
    signal execute_sel_pc_out : std_logic;
    signal execute_alures_out : std_logic_vector (31 downto 0);
    signal reg_exmem_out : t_from_ex;
    -- Signals for RAM
    signal ram_rdData : std_logic_vector(31 downto 0);
    -- Signal for MEM/WB
    signal memwb_out : t_from_mem;
    -- Signal for WB
    signal wb_data : std_logic_vector(31 downto 0);

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
            we => memwb_out.reg_we,
            instruction => out_instruction,
            w_addr => memwb_out.wr_reg_idx,
            w_data => wb_data,
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

        -- Register ID/EX
        reg_idex_inst: reg_idex
                port map (
                        clk => clock,
                        en => en,
                        clear => clear_idex,
                        in_from_id.decoded => decoder_out, 
                        in_from_id.reg_rs1 => reg1_out,
                        in_from_id.reg_rs2 => reg2_out,
                        out_to_ex => reg_idex_out
             );

        -- Execute
        exec_inst: execute
                port map (
                        forward_1 => "01",
                        forward_2 => "01",
                        do_jmp_in => '0',
                        do_branch_in => '0',
                        alu_ctrl_in => reg_idex_out.decoded.ALUOp,
                        alu_op1_ctrl_in => reg_idex_out.decoded.ALUSrc1,
                        alu_op2_ctrl_in => reg_idex_out.decoded.ALUSrc2,
                        pc_in => out_pc,
                        r1_in => reg1_out,
                        r2_in => reg2_out,
                        imm_in => decoder_out.immediate,
                        wb_reg_in => x"00000000",
                        mem_reg_in => x"00000000",
                        sel_pc_out => execute_sel_pc_out,
                        alures_out => execute_alures_out
                );

-- Register EX/MEM
exmem_inst: reg_exmem
				port map (
	clk => clock,
	en => '1',
	clear => '0',
	in_from_ex.ALU_result => execute_alures_out,
	in_from_ex.data_in => reg2_out,
	in_from_ex.data_we => '0',
	in_from_ex.reg_we => reg_idex_out.decoded.REG_we,
	in_from_ex.rd => reg_idex_out.decoded.rd,
	out_to_mem => reg_exmem_out
		 );

	-- RAM
	ram_inst : datamem
	    port map(
		clk => clock,
		we => reg_exmem_out.data_we,
		addr => reg_exmem_out.ALU_result,
		wrData => reg_exmem_out.data_in,
		mem_op => "111",
		rdData => ram_rdData
	    );
	
	-- Register MEM/WB
	memwb_inst : reg_memwb
	    port map(
		clk => clock,
		in_from_mem.reg_we => reg_exmem_out.reg_we,
		in_from_mem.reg_wr_src_crtl => '0',
		in_from_mem.mem_do_write => reg_exmem_out.data_we,
		in_from_mem.mem_op => "1111",
		in_from_mem.alures => reg_exmem_out.ALU_result,
		in_from_mem.r2 => ram_rdData,
		in_from_mem.wr_reg_idx => reg_exmem_out.rd,
		out_to_wb => memwb_out
	);

	-- Write Back
	write_back_inst : write_back
	port map(
	    mem_wr_src_ctrl_in => "01",
	    pc_in => x"00000000",
	    alures_in => memwb_out.alures,
	    mem_read_in => ram_rdData,
	    wr_data => wb_data
	);

	reset <= '0';
	branch <= '0';
	en <= '1';
	clear <= '0';
	branch_address <= x"00000000";
	we <= '0';
	clear_idex <= '0';


         process(clock) is
         begin
           if (rising_edge(clock)) then

                     report "PC: " & to_string(out_pc);
                     report "Instruction: " & to_string(out_instruction);
                     report "Immediate: " & to_string(decoder_out.immediate);
                     report "Register 1: " & to_string(reg1_out);
                     report "Register 2: " & to_string(reg2_out);
                     report "Out from ID/EX: " & to_string(reg_idex_out.decoded.immediate);
                     report "ALU Src 1: " & to_string(reg_idex_out.decoded.ALUSrc1);
                     report "ALU Src 2: " & to_string(reg_idex_out.decoded.ALUSrc2);
                     report "ALU Op: " & to_string(reg_idex_out.decoded.ALUOp);
		     report "Register WE: " & to_string(reg_idex_out.decoded.REG_we);
		     report "Register WE: " & to_string(reg_exmem_out.reg_we);
		     report "Register WE: " & to_string(memwb_out.reg_we);

		     report "Register Destination: " & to_string(memwb_out.wr_reg_idx);
		     report "ALU Result: " & to_string(memwb_out.alures);
		     report "WB Data: " & to_string(wb_data);

                     report "Execute SEL PC: " & to_string(execute_sel_pc_out);
          end if;
         end process;

end behavioral;
