library ieee;
library work;
use ieee.std_logic_1164.all;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use work.const_decoder.all;
use work.reg_file_pkg.all;
use work.mem_op_const.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Register file with no reset
entity reg_file is -- Kindly borrowed and adapted from FPGA prototyping by VHDL examples (Xilinx spartan(tm)-3 version) by Pong P. Chu, at University of Cleveland
  generic
  (
    B : integer := 32; -- no. of bits in register
    W : integer := 5 -- no. of address bits (5 bits =32 addresses)
  );
  port
  (
    clk, REG_we                  : in std_logic;
    REG_src_idx_1, REG_src_idx_2 : in std_logic_vector(4 downto 0);
    REG_dst_idx                  : in std_logic_vector(4 downto 0);
    REG_write_data               : in std_logic_vector(B - 1 downto 0);
    REG_src_1, REG_src_2         : out std_logic_vector(B - 1 downto 0)
    --blinky                       : out std_logic -- TODO DELETE MEE :)))
  );
end reg_file;

architecture behavioral of reg_file is
  type registerfile_type is array (2 ** W - 1 downto 0) of
  std_logic_vector(B - 1 downto 0);
  signal array_register         : registerfile_type := (others => (others => '0'));
  signal do_forward_reg_current : std_logic;
  signal do_forward_reg_next    : std_logic;

begin
  -- Clock process
  process (clk)
  begin
    if rising_edge(clk) then
      if (REG_we = '1') then
        --report "[REG FILE] Reg(" & to_string(REG_dst_idx) & ") <= " & to_string(REG_write_data);
        array_register(to_integer(unsigned(REG_dst_idx))) <= REG_write_data;
      end if;

    end if;
  end process;

  process (all)
  begin
    -- Handling case where we write and read to same register
    if (REG_we = '1' and (REG_src_idx_1 = REG_dst_idx)) then
      REG_src_1 <= REG_write_data;
    end if;
    if (REG_we = '1' and (REG_src_idx_2 = REG_dst_idx)) then
      REG_src_2 <= REG_write_data;
    end if;

    -- Handling x0
    if (REG_src_idx_1 = "00000") then
      REG_src_1 <= x"00000000";
    end if;

    if (REG_src_idx_2 = "00000") then
      REG_src_2 <= x"00000000";
    end if;
    -- Asynchronous read
    REG_src_1 <= array_register(to_integer(unsigned(REG_src_idx_1)));
    REG_src_2 <= array_register(to_integer(unsigned(REG_src_idx_2)));
  end process;
end behavioral;