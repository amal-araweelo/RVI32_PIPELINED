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
  type quad_port_ram_type is array(2 ** 10 downto 0) -- 1 KiB
  of std_logic_vector (7 downto 0);
  signal quad_port_ram : ram_type;
  signal read_data     : std_logic_vector(31 downto 0);
  signal write_data    : std_logic_vector(31 downto 0);
  signal MEM_IO        : std_logic_vector(31 downto 0);
  --alias MEM_sel     : std_logic is MEM_addr(31);

  -- To be loaded from or stored at different bytes
  signal load_from_0 : std_logic_vector(7 downto 0);
  signal load_from_1 : std_logic_vector(7 downto 0);
  signal load_from_2 : std_logic_vector(7 downto 0);
  signal load_from_3 : std_logic_vector(7 downto 0);

  signal store_at_0 : std_logic_vector(7 downto 0);
  signal store_at_1 : std_logic_vector(7 downto 0);
  signal store_at_2 : std_logic_vector(7 downto 0);
  signal store_at_3 : std_logic_vector(7 downto 0);

  -- Write enable for the 4 bytes
  signal we_0 : std_logic;
  signal we_1 : std_logic;
  signal we_2 : std_logic;
  signal we_3 : std_logic;

begin
  -- Synchronous write
  process (clk) begin
    if (rising_edge(clk)) then
      if (MEM_we = '1') then
        if (MEM_addr = x"00000000") then
          MEM_IO <= write_data;
          elsif (we_0 = '1') then
          quad_port_ram(to_integer(unsigned(MEM_addr))) <= store_at_0;
          elsif (we_1 = '1') then
          quad_port_ram(to_integer(unsigned(MEM_addr))) <= store_at_1;
          elsif (we_2 = '1') then
          quad_port_ram(to_integer(unsigned(MEM_addr))) <= store_at_2;
          elsif (we_3 = '1') then
          quad_port_ram(to_integer(unsigned(MEM_addr))) <= store_at_3;
          --ram(to_integer(unsigned(MEM_addr))) <= write_data;
        end if;
      end if;
    end if;
  end process;

  -- Asynchronous read
  process (all) begin
    -- Intialization
    load_from_0 <= x"0000";
    load_from_1 <= x"0000";
    load_from_2 <= x"0000";
    load_from_3 <= x"0000";

    store_at_0 <= x"0000";
    store_at_1 <= x"0000";
    store_at_2 <= x"0000";
    store_at_3 <= x"0000";

    we_0 <= '0';
    we_1 <= '0';
    we_2 <= '0';
    we_3 <= '0';

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
        we_b0 <= '1'; -- enable write to all bytes
        we_b1 <= '1';
        we_b2 <= '1';
        we_b3 <= '1';

        store_at_3 <= MEM_data_in(31 downto 24);
        store_at_2 <= MEM_data_in(25 downto 16);
        store_at_1 <= MEM_data_in(15 downto 8);
        store_at_0 <= MEM_data_in(7 downto 0);
        write_data <= MEM_data_in(31 downto 0);
      when sh =>
        we_b0 <= '1'; -- only enable write to byte 0 and byte 1
        we_b1 <= '1';
        we_b2 <= '0';
        we_b3 <= '0';

        store_at_1 <= MEM_data_in(15 downto 8);
        store_at_0 <= MEM_data_in(7 downto 0);

        write_data(15 downto 0)   <= MEM_data_in(15 downto 0);
        write_data (31 downto 16) <= (others => '0'); -- fill up with 0's
      when sb                              =>
        we_b0 <= '1'; -- only enable write to byte 0
        we_b1 <= '0';
        we_b2 <= '0';
        we_b3 <= '0';

        store_at_0 <= MEM_data_in(7 downto 0);

        write_data(7 downto 0)    <= MEM_data_in(7 downto 0);
        write_data (31 downto 16) <= (others => '0'); -- fill up with 0's
      when others                          =>
        null;
        --write_data <= x"00000000";
        --read_data  <= x"00000000";
    end case;
    MEM_data_out <= read_data;
    MEM_IO_out   <= MEM_IO;
  end process;
end architecture;