-- Data memory (only supports words right now)

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_op_const.all;

entity data_mem is
  port
  (
    -- Inputs
    clk         : in std_logic; -- clock
    MEM_we      : in std_logic; -- write enable
    MEM_op      : in std_logic_vector(2 downto 0); -- memory operation
    MEM_data_in : in std_logic_vector(31 downto 0);
    MEM_addr    : in std_logic_vector(31 downto 0); -- address (it is the value stored in register 2)

    -- Outputs
    MEM_data_out : out std_logic_vector(31 downto 0);
    MEM_IO_out   : out std_logic_vector(31 downto 0)

  );
end data_mem;

architecture impl of data_mem is
  type ram_type is array(2 ** 8 downto 0) -- 1 KiB
  of std_logic_vector (31 downto 0);
  signal ram        : ram_type;
  signal read_data  : std_logic_vector(31 downto 0);
  signal write_data : std_logic_vector(31 downto 0);
  signal MEM_IO     : std_logic_vector(31 downto 0);
  --alias MEM_sel     : std_logic is MEM_addr(31);

begin
  -- Synchronous write
  process (clk) begin
    if (rising_edge(clk)) then
      if (MEM_we = '1') then
        if (MEM_addr = x"00000000") then
          MEM_IO <= write_data;
        else
          ram(to_integer(unsigned(MEM_addr))) <= write_data;
        end if;
      end if;
    end if;
  end process;

  -- Asynchronous read
  process (all) begin
    -- Initialize write_data to a default value
    write_data <= (others => '0');
    read_data  <= (others => '0');
    case MEM_op is
      when lw =>
        read_data <= ram(to_integer(unsigned(MEM_addr)));
      when lh =>
        read_data(15 downto 0) <= ram(to_integer(unsigned(MEM_addr)))(15 downto 0);
        if read_data(15) = '1' then
          -- Sign extension for negative value
          read_data(31 downto 16) <= (others => '1');
        else
          read_data(31 downto 16) <= (others => '0');
        end if;
      when lhu =>
        read_data(15 downto 0)  <= ram(to_integer(unsigned(MEM_addr)))(15 downto 0);
        read_data(31 downto 16) <= (others => '0'); -- Zero-extend
      when lb                            =>
        read_data(7 downto 0) <= ram(to_integer(unsigned(MEM_addr)))(7 downto 0);
        if read_data(7) = '1' then
          -- Sign extension for negative value
          read_data(31 downto 8) <= (others => '1');
        else
          read_data(31 downto 8) <= (others => '0');
        end if;
      when lbu =>
        read_data(7 downto 0)  <= ram(to_integer(unsigned(MEM_addr)))(7 downto 0);
        read_data(31 downto 8) <= (others => '0'); -- Zero-extend
      when sw                           =>
        write_data <= MEM_data_in(31 downto 0);
      when sh =>
        write_data(15 downto 0)   <= MEM_data_in(15 downto 0);
        write_data (31 downto 16) <= (others => '0'); -- fill up with 0's
      when sb                              =>
        write_data(7 downto 0)    <= MEM_data_in(7 downto 0);
        write_data (31 downto 16) <= (others => '0'); -- fill up with 0's
      when others                          =>
        write_data <= x"00000000";
        read_data  <= x"00000000";
    end case;
    MEM_data_out <= read_data;
    MEM_IO_out   <= MEM_IO;
  end process;
end architecture;