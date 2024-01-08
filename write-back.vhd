library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_back is
  port
  (
    mem_wr_src_ctrl_in : in std_logic_vector(1 downto 0)  := (others => '0');
    pc_in              : in std_logic_vector(31 downto 0) := (others => '0');
    alures_in          : in std_logic_vector(31 downto 0) := (others => '0');
    mem_read_in        : in std_logic_vector(31 downto 0) := (others => '0'); -- data_out from datamem

    wr_data : out std_logic_vector(31 downto 0) := (others => '0') -- data to be written to the register file
  );
end write_back;

architecture behavorial of write_back is
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
  inst_mux3 : mux3 port map
  (
    a => pc_in, b => alures_in, c => mem_read_in, sel => mem_wr_src_ctrl_in, output => wr_data
  );
end architecture;
