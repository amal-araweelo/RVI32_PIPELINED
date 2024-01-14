-- Fetch stage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- read binary file
-- Hardcode an addi instruction

entity fetcher is
  port
  (
    clk, sel_pc, clr, en : in std_logic;
    branch_addr          : in std_logic_vector (31 downto 0);
    pc                   : out std_logic_vector (31 downto 0);
    instr                : out std_logic_vector (31 downto 0)
  );
end fetcher;

architecture behavioral of fetcher is
  signal length     : std_logic_vector(31 downto 0) := x"00000004";
  signal pc_current : std_logic_vector(31 downto 0) := x"00000000";
  signal pc_next    : std_logic_vector(31 downto 0);

  -- Instruction memory
  component instr_mem is
    port
    (
      -- Inputs
      clk      : in std_logic;
      MEM_addr : in std_logic_vector(31 downto 0); -- address (it is the value stored in register 2)

      -- Outputs
      MEM_instr_out : out std_logic_vector(31 downto 0)
    );
  end component;

begin

  instr_mem_inst : instr_mem port map
  (
    clk           => clk,
    MEM_addr      => "00" & pc_current(31 downto 2),
    MEM_instr_out => instr
  );

  process (all) begin
    pc_next <= pc;
    if (en = '1') then
      if (sel_pc = '1') then
	report "[FETCH] BRANCHING to: " & to_string(branch_addr);
        pc_next <= branch_addr;
      else
        pc_next <= std_logic_vector(unsigned(pc_current) + unsigned(length));
      end if;
    end if;

    if (clr = '1') then
      pc_next <= (others => '0');
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      pc_current <= pc_next;
      report "[FETCH] PC: " & to_string(unsigned(pc_next));
    end if;
  end process;
  pc <= pc_current;
end behavioral;
