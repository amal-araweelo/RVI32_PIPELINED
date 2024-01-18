library ieee;
library work;
use ieee.std_logic_1164.all;
use work.records_pkg.all;
use work.alu_ctrl_const.all;
use work.const_decoder.all;
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
    ECALL_en              	 : in std_logic;
    REG_src_1, REG_src_2         : out std_logic_vector(B - 1 downto 0)
  );
end reg_file;

architecture behavioral of reg_file is
  type registerfile_type is array (2 ** W - 1 downto 0) of
  std_logic_vector(B - 1 downto 0);
  signal array_register : registerfile_type := (others => (others => '0'));
  signal zero 		: std_logic_vector(B - 1 downto 0) := (others => '0');

begin
  -- Clock process
  process (clk)
  begin
    if rising_edge(clk) then
      if (REG_we = '1') then
	-- if (REG_dst_idx /= "00000") then
	--     report "[REG FILE] REG(" & to_hex_string(REG_dst_idx) & ") <= " & to_hex_string(REG_write_data);
	-- end if;
        array_register(to_integer(unsigned(REG_dst_idx))) <= REG_write_data;
      end if;
    end if;
  end process;

  process (all)
  begin
    -- Asynchronous read
    REG_src_1 <= array_register(to_integer(unsigned(REG_src_idx_1)));
    REG_src_2 <= array_register(to_integer(unsigned(REG_src_idx_2)));

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

    if (ECALL_en = '1') then
	  report "REG(0) = " & to_hex_string(zero);
	  report "REG(1) = " & to_hex_string(array_register(1));
	  report "REG(2) = " & to_hex_string(array_register(2));
	  report "REG(3) = " & to_hex_string(array_register(3));
	  report "REG(4) = " & to_hex_string(array_register(4));
	  report "REG(5) = " & to_hex_string(array_register(5));
	  report "REG(6) = " & to_hex_string(array_register(6));
	  report "REG(7) = " & to_hex_string(array_register(7));
	  report "REG(8) = " & to_hex_string(array_register(8));
	  report "REG(9) = " & to_hex_string(array_register(9));
	  report "REG(10) = " & to_hex_string(array_register(10));
	  report "REG(11) = " & to_hex_string(array_register(11));
	  report "REG(12) = " & to_hex_string(array_register(12));
	  report "REG(13) = " & to_hex_string(array_register(13));
	  report "REG(14) = " & to_hex_string(array_register(14));
	  report "REG(15) = " & to_hex_string(array_register(15));
	  report "REG(16) = " & to_hex_string(array_register(16));
	  report "REG(17) = " & to_hex_string(array_register(17));
	  report "REG(18) = " & to_hex_string(array_register(18));
	  report "REG(19) = " & to_hex_string(array_register(19));
	  report "REG(20) = " & to_hex_string(array_register(20));
	  report "REG(21) = " & to_hex_string(array_register(21));
	  report "REG(22) = " & to_hex_string(array_register(22));
	  report "REG(23) = " & to_hex_string(array_register(23));
	  report "REG(24) = " & to_hex_string(array_register(24));
	  report "REG(25) = " & to_hex_string(array_register(25));
	  report "REG(26) = " & to_hex_string(array_register(26));
	  report "REG(27) = " & to_hex_string(array_register(27));
	  report "REG(28) = " & to_hex_string(array_register(28));
	  report "REG(29) = " & to_hex_string(array_register(29));
	  report "REG(30) = " & to_hex_string(array_register(30));
	  report "REG(31) = " & to_hex_string(array_register(31));

	  std.env.stop(0);
    end if;
  end process;
end behavioral;
