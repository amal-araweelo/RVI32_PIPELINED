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
    MEM_SW_in   : in std_logic_vector(31 downto 0); -- in-signal for switch values
    -- Outputs
    MEM_data_out : out std_logic_vector(31 downto 0);
    MEM_IO_out   : out std_logic_vector(31 downto 0)

  );
end data_mem;

architecture impl of data_mem is
  type ram_type is array(2 ** 10 downto 0) -- 1 KiB
  of std_logic_vector (7 downto 0);
  signal ram        : ram_type := (others => (others => '0'));
  signal read_data  : std_logic_vector(31 downto 0);
  signal write_data : std_logic_vector(31 downto 0);
  signal MEM_IO     : std_logic_vector(31 downto 0);
  signal MEM_SW     : std_logic_vector(31 downto 0);

  -- To be loaded from or stored at different bytes
  signal load_from_0 : std_logic_vector(7 downto 0); -- LSB
  signal load_from_1 : std_logic_vector(7 downto 0);
  signal load_from_2 : std_logic_vector(7 downto 0);
  signal load_from_3 : std_logic_vector(7 downto 0); -- MSB

  signal store_at_0 : std_logic_vector(7 downto 0); -- LSB
  signal store_at_1 : std_logic_vector(7 downto 0);
  signal store_at_2 : std_logic_vector(7 downto 0);
  signal store_at_3 : std_logic_vector(7 downto 0); -- MSB

  -- Write enable for the 4 bytes to be stored
  signal we_0 : std_logic;
  signal we_1 : std_logic;
  signal we_2 : std_logic;
  signal we_3 : std_logic;

  -- Memory address for the 4 bytes
  signal MEM_addr_0 : std_logic_vector(31 downto 0);
  signal MEM_addr_1 : std_logic_vector(31 downto 0);
  signal MEM_addr_2 : std_logic_vector(31 downto 0);
  signal MEM_addr_3 : std_logic_vector(31 downto 0);

  -- Signals for switches
  signal switch_0 : std_logic_vector(7 downto 0); -- LSB
  signal switch_1 : std_logic_vector(7 downto 0);
  signal switch_2 : std_logic_vector(7 downto 0);
  signal switch_3 : std_logic_vector(7 downto 0); -- MSB

  signal SW_ADDR_0 : std_logic_vector(31 downto 0);
  signal SW_ADDR_1 : std_logic_vector(31 downto 0);
  signal SW_ADDR_2 : std_logic_vector(31 downto 0);
  signal SW_ADDR_3 : std_logic_vector(31 downto 0);

begin
  -- Synchronous write
  process (clk) begin
    if (rising_edge(clk)) then
      -- Always write the state of the switches into memory when we are not storing
      if (MEM_we = '0') then
        ram(to_integer(unsigned(SW_ADDR_0))) <= switch_0;
        ram(to_integer(unsigned(SW_ADDR_1))) <= switch_1;
        ram(to_integer(unsigned(SW_ADDR_2))) <= switch_2;
        ram(to_integer(unsigned(SW_ADDR_3))) <= switch_3;
      elsif (MEM_we = '1') then
        if (MEM_addr = x"00000000") then
	    report "[MEMORY] Writing to MEM(" & to_string(MEM_addr) & ") <= " & to_string(MEM_data_in);
          MEM_IO <= write_data;
        end if;
        if (we_0 = '1') then
          ram(to_integer(unsigned(MEM_addr_0))) <= store_at_0;
        end if;
        if (we_1 = '1') then
          ram(to_integer(unsigned(MEM_addr_1))) <= store_at_1;
        end if;
        if (we_2 = '1') then
          ram(to_integer(unsigned(MEM_addr_2))) <= store_at_2;
        end if;
        if (we_3 = '1') then
          ram(to_integer(unsigned(MEM_addr_3))) <= store_at_3;
        end if;
      end if;
    end if;
  end process;

  -- Asynchronous read
  process (all)
  begin
    -- Intialization of bytes to be loaded from or stored in memory
    load_from_0 <= x"00";
    load_from_1 <= x"00";
    load_from_2 <= x"00";
    load_from_3 <= x"00";

    store_at_0 <= x"00";
    store_at_1 <= x"00";
    store_at_2 <= x"00";
    store_at_3 <= x"00";

    -- Initialization of write-enables
    we_0 <= '0';
    we_1 <= '0';
    we_2 <= '0';
    we_3 <= '0';

    -- Initialization of the memory adress of the 4 bytes
    MEM_addr_0 <= MEM_addr;
    MEM_addr_1 <= std_logic_vector(unsigned(MEM_addr) + to_unsigned(1, 31)); -- offset with 1 byte
    MEM_addr_2 <= std_logic_vector(unsigned(MEM_addr) + to_unsigned(2, 31)); -- offset with 2 bytes
    MEM_addr_3 <= std_logic_vector(unsigned(MEM_addr) + to_unsigned(3, 31)); -- offset with 3 bytes

    -- Initialization of switch address
    SW_ADDR_0 <= x"00000004";
    SW_ADDR_1 <= std_logic_vector(unsigned(SW_ADDR_0) + to_unsigned(1, 31)); -- offset with 1 byte
    SW_ADDR_2 <= std_logic_vector(unsigned(SW_ADDR_0) + to_unsigned(2, 31)); -- offset with 2 bytes
    SW_ADDR_3 <= std_logic_vector(unsigned(SW_ADDR_0) + to_unsigned(3, 31)); -- offset with 3 bytes

    case MEM_op is
      when lw => -- Load word

        load_from_0 <= ram(to_integer(unsigned(MEM_addr_0)));
        load_from_1 <= ram(to_integer(unsigned(MEM_addr_1)));
        load_from_2 <= ram(to_integer(unsigned(MEM_addr_2)));
        load_from_3 <= ram(to_integer(unsigned(MEM_addr_3)));
      when lh => -- Load half word (signed)

        load_from_0 <= ram(to_integer(unsigned(MEM_addr_0)));
        load_from_1 <= ram(to_integer(unsigned(MEM_addr_1)));

        if load_from_1(7) = '1' then -- Sign-extension for negative value
          load_from_2 <= (others => '1');
          load_from_3 <= (others => '1');
        else
          load_from_2 <= (others => '0');-- Sign-extension for positive value
          load_from_3 <= (others => '0');
        end if;

      when lhu => -- Load half word (unsigned)

        load_from_0 <= ram(to_integer(unsigned(MEM_addr_0)));
        load_from_1 <= ram(to_integer(unsigned(MEM_addr_1)));
        load_from_2 <= (others => '0');
        load_from_3 <= (others => '0');

      when lb => -- Load byte (signed)
        load_from_0 <= ram(to_integer(unsigned(MEM_addr_0)));

        if load_from_0(7) = '1' then
          load_from_1 <= (others => '1'); -- Sign extension for negative value
          load_from_2 <= (others => '1');
          load_from_3 <= (others => '1');
        else
          load_from_1 <= (others => '0'); -- Sign extension for positive value
          load_from_2 <= (others => '0');
          load_from_3 <= (others => '0');
        end if;

      when lbu => -- Load byte (unsigned)
        load_from_0 <= ram(to_integer(unsigned(MEM_addr_0)));
        load_from_1 <= (others => '0');
        load_from_2 <= (others => '0');
        load_from_3 <= (others => '0');

      when sw => -- Store word
        we_0 <= '1'; -- enable write to all bytes
        we_1 <= '1';
        we_2 <= '1';
        we_3 <= '1';

        store_at_3 <= MEM_data_in(31 downto 24);
        store_at_2 <= MEM_data_in(23 downto 16);
        store_at_1 <= MEM_data_in(15 downto 8);
        store_at_0 <= MEM_data_in(7 downto 0);
      when sh => -- Store half word
        we_0 <= '1'; -- only enable write to byte 0 and byte 1
        we_1 <= '1';
        we_2 <= '0';
        we_3 <= '0';

        store_at_1 <= MEM_data_in(15 downto 8);
        store_at_0 <= MEM_data_in(7 downto 0);

      when sb => -- Store byte
        we_0 <= '1'; -- only enable write to byte 0
        we_1 <= '0';
        we_2 <= '0';
        we_3 <= '0';

        store_at_0 <= MEM_data_in(7 downto 0);

      when others =>
        null;
    end case;

    switch_3 <= MEM_SW_in(31 downto 24);
    switch_2 <= MEM_SW_in(23 downto 16);
    switch_1 <= MEM_SW_in(15 downto 8);
    switch_0 <= MEM_SW_in(7 downto 0);

    --MEM_SW       <= MEM_SW_in;
    MEM_data_out <= load_from_3 & load_from_2 & load_from_1 & load_from_0; -- concatenate the four bytes read from memory
    write_data   <= store_at_3 & store_at_2 & store_at_1 & store_at_0;
    MEM_IO_out   <= MEM_IO;
  end process;
end architecture;