library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_back is
  port
  (
    WB_src_ctrl : in std_logic_vector(1 downto 0)  := (others => '0');
    PC              : in std_logic_vector(31 downto 0) := (others => '0');
    ALU_res          : in std_logic_vector(31 downto 0) := (others => '0');
    MEM_out        : in std_logic_vector(31 downto 0) := (others => '0'); -- data_out from datamem

    WB_data_out : out std_logic_vector(31 downto 0) := (others => '0') -- data to be written to the register file
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
    a => PC, b => ALU_res, c => MEM_out, sel => WB_src_ctrl, output => WB_data_out
  );
end architecture;