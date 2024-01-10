library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_back is
  port
  (
    WB_src_ctrl : in std_logic_vector(1 downto 0)  := (others => '0');
    pc          : in std_logic_vector(31 downto 0) := (others => '0');
    ALU_res     : in std_logic_vector(31 downto 0) := (others => '0');
    MEM_out     : in std_logic_vector(31 downto 0) := (others => '0'); -- data_out from datamem

    REG_write_data : out std_logic_vector(31 downto 0) := (others => '0') -- data to be written to the register file
  );
end write_back;

architecture behavorial of write_back is
  signal pc_next : std_logic_vector(31 downto 0) := (others => '0');
  signal length  : std_logic_vector(31 downto 0) := x"00000004";
  -- MUX3 component declaration
  component mux3 is
    port
    (
      sel    : in std_logic_vector(1 downto 0);
      a      : in std_logic_vector(31 downto 0);
      b      : in std_logic_vector(31 downto 0);
      c      : in std_logic_vector(31 downto 0);
      output : out std_logic_vector(31 downto 0)
    );
  end component;

begin
  pc_next <= std_logic_vector(unsigned(pc) + unsigned(length));

  inst_mux3 : mux3 port map
  (
    a => pc_next, b => ALU_res, c => MEM_out, sel => WB_src_ctrl, output => REG_write_data
  );
end architecture;
