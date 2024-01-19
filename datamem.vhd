-- Data memory (supports different instruction types)

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
    MEM_SW_in   : in std_logic_vector(15 downto 0)  -- SWCHG made this
    -- Outputs
    MEM_data_out : out std_logic_vector(31 downto 0);
    MEM_IO_out   : out std_logic_vector(15 downto 0) -- LED was 31 down
  );
end data_mem;

architecture impl of data_mem is
  type ram_type is array(2 ** 8 downto 0)
  of std_logic_vector (7 downto 0);

  -- Four banks for the datamemory
  signal bank0 : ram_type;
  signal bank1 : ram_type;
  signal bank2 : ram_type;
  signal bank3 : ram_type;

  -- Signals to store read data from each bank
  signal read_data_0 : std_logic_vector(7 downto 0);
  signal read_data_1 : std_logic_vector(7 downto 0);
  signal read_data_2 : std_logic_vector(7 downto 0);
  signal read_data_3 : std_logic_vector(7 downto 0);

  -- Signals to write data to each bank
  signal write_data_0 : std_logic_vector(7 downto 0);
  signal write_data_1 : std_logic_vector(7 downto 0);
  signal write_data_2 : std_logic_vector(7 downto 0);
  signal write_data_3 : std_logic_vector(7 downto 0);

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

  -- Internal signal for the MEM_IO data
  signal MEM_IO : std_logic_vector(15 downto 0);    -- LED was 31 down
  signal MEM_SW : std_logic_vector(15 downto 0);    -- SWCHG made this

  -- LED data
  signal write_data : std_logic_vector(15 downto 0); -- LED uses this, 15 down did not work

begin
  -- Synchronous write
  process (clk) begin
    if (rising_edge(clk)) then
      -- Always write the state of the switches into memory when we are not storing

      if (MEM_we = '1') then
        if (MEM_addr = x"00000000") then
          MEM_IO <= write_data(15 downto 0);
        end if;
        end if;
        end if;
        if (we_0) then
          bank0(to_integer(unsigned(MEM_addr_0))) <= write_data_0; -- writing byte 0 to bank 0
        end if;
        if (we_1) then
          bank1(to_integer(unsigned(MEM_addr_1))) <= write_data_1; -- writing byte 1 to bank 1
        end if;
        if (we_2) then
          bank2(to_integer(unsigned(MEM_addr_2))) <= write_data_2; -- writing byte 2 to bank 2
        end if;
        if (we_3) then
          bank3(to_integer(unsigned(MEM_addr_3))) <= write_data_3; -- writing byte 3 to bank 3
        end if;
      end if;
    else    -- SWCHG made this else and its contents
      bank0(to_integer(unsigned(x"00000004"))) <= MEM_SW(7 downto 0);
      bank1(to_integer(unsigned(x"00000005"))) <= MEM_SW(15 downto 8);
      bank2(to_integer(unsigned(x"00000006"))) <= (others => '0');
      bank3(to_integer(unsigned(x"00000007"))) <= (others => '0');
    end if;
  end process;

  -- Asynchronous read process
  process (all)
  begin
    -- Intialization of read data bytes
    read_data_0 <= (others => '0');
    read_data_1 <= (others => '0');
    read_data_2 <= (others => '0');
    read_data_3 <= (others => '0');

    write_data_0 <= (others => '0');
    write_data_1 <= (others => '0');
    write_data_2 <= (others => '0');
    write_data_3 <= (others => '0');

    -- Initialization of write-enables
    we_0 <= '0';
    we_1 <= '0';
    we_2 <= '0';
    we_3 <= '0';

    -- Initialization of the memory adress of the 4 bytes
    MEM_addr_0 <= MEM_addr;
    MEM_addr_1 <= std_logic_vector(unsigned(MEM_addr_0) + to_unsigned(1, 31)); -- offset with 1 byte
    MEM_addr_2 <= std_logic_vector(unsigned(MEM_addr_0) + to_unsigned(2, 31)); -- offset with 2 bytes
    MEM_addr_3 <= std_logic_vector(unsigned(MEM_addr_0) + to_unsigned(3, 31)); -- offset with 3 bytes

    -- Intiaalize memory i/o
    --MEM_IO <= x"00000000";
    --write_data <= x"00000000";
    case MEM_op is
      when lw => -- Load word
        read_data_0 <= bank0(to_integer(unsigned(MEM_addr_0)));
        read_data_1 <= bank1(to_integer(unsigned(MEM_addr_1)));
        read_data_2 <= bank2(to_integer(unsigned(MEM_addr_2)));
        read_data_3 <= bank3(to_integer(unsigned(MEM_addr_3)));
      when lh => -- Load half word (signed)

        read_data_0 <= bank0(to_integer(unsigned(MEM_addr_0)));
        read_data_1 <= bank1(to_integer(unsigned(MEM_addr_1)));

        if read_data_1(7) = '1' then -- Sign-extension for negative value
          read_data_2 <= (others => '1');
          read_data_3 <= (others => '1');
        else
          read_data_2 <= (others => '0');
          read_data_3 <= (others => '0');
        end if;

      when lhu => -- Load half word (unsigned)

        read_data_0 <= bank0(to_integer(unsigned(MEM_addr_0)));
        read_data_1 <= bank1(to_integer(unsigned(MEM_addr_1)));
        read_data_2 <= (others => '0');
        read_data_3 <= (others => '0');

      when lb => -- Load byte (signed)
        read_data_0 <= bank0(to_integer(unsigned(MEM_addr_0)));

        if read_data_0(7) = '1' then
          read_data_1 <= (others => '1'); -- Sign extension for negative value
          read_data_2 <= (others => '1');
          read_data_3 <= (others => '1');
        else
          read_data_1 <= (others => '0');
          read_data_2 <= (others => '0');
          read_data_3 <= (others => '0');
        end if;

      when lbu => -- Load byte (unsigned)
        read_data_0 <= bank0(to_integer(unsigned(MEM_addr_0)));
        read_data_1 <= (others => '0');
        read_data_2 <= (others => '0');
        read_data_3 <= (others => '0');

      when sw => -- Store word
        we_0 <= '1'; -- enable write to all bytes
        we_1 <= '1';
        we_2 <= '1';
        we_3 <= '1';

        write_data_3 <= MEM_data_in(31 downto 24);
        write_data_2 <= MEM_data_in(23 downto 16);
        write_data_1 <= MEM_data_in(15 downto 8);
        write_data_0 <= MEM_data_in(7 downto 0);
      when sh => -- Store half word
        we_0 <= '1'; -- only enable write to byte 0 and byte 1
        we_1 <= '1';
        we_2 <= '0';
        we_3 <= '0';

        write_data_1 <= MEM_data_in(15 downto 8);
        write_data_0 <= MEM_data_in(7 downto 0);

      when sb => -- Store byte
        we_0 <= '1'; -- only enable write to byte 0
        we_1 <= '0';
        we_2 <= '0';
        we_3 <= '0';

        write_data_0 <= MEM_data_in(7 downto 0);
      when others =>
        
    end case;

    -- Concatenate read data from all banks based on the memory operation type
    MEM_data_out <= read_data_3 & read_data_2 & read_data_1 & read_data_0;
    write_data   <= write_data_1 & write_data_0;
    MEM_IO_out   <= MEM_IO;
    

  end process;
end architecture;