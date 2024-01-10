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
    pc                   : out std_logic_vector (31 downto 0);
    branch_addr : in std_logic_vector (31 downto 0);
    instr       : out std_logic_vector (31 downto 0)
  );
end fetcher;

architecture behavioral of fetcher is
  signal length  : std_logic_vector(31 downto 0) := x"00000004";
  signal pc_reg  : std_logic_vector(31 downto 0) := x"00000000";
  signal pc_next : std_logic_vector(31 downto 0);

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
  inst_instr_mem : instr_mem port map
    (clk, pc, instr);

  process (sel_pc, pc_reg, branch_addr) begin
    if (sel_pc = '1') then
      pc_next <= branch_addr;
    else
      pc_next <= std_logic_vector(unsigned(pc_reg) + unsigned(length));
    end if;
  end process;

  process (clk, clr, en)
  begin
    if (clr = '1') then
      pc_reg <= (others => '0');
    elsif (rising_edge(clk) and en = '1') then
      pc_reg <= pc_next;
    end if;
  end process;

  pc <= pc_reg;
end behavioral;
