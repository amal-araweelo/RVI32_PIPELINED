library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart is
end entity;

architecture testbench of tb_uart is
  signal clk_tb   : std_logic := '0';
  signal reset_tb : std_logic := '0';

  -- SimpCon interface signals
  signal address_tb : std_logic_vector(7 downto 0) := (others => '0');
  signal wr_data_tb : std_logic_vector(31 downto 0);
  signal rd_data_tb : std_logic_vector(31 downto 0);
  signal rdy_cnt_tb : unsigned(1 downto 0);
  signal rd_tb      : std_logic := '0';
  signal wr_tb      : std_logic := '0';

  -- UART signals
  signal txd_tb  : std_logic;
  signal rxd_tb  : std_logic := '1'; -- Start with idle high
  signal ncts_tb : std_logic := '1';
  signal nrts_tb : std_logic;

  -- UART component
  component sc_uart
    generic
    (
      addr_bits : integer := 8;
      clk_freq  : integer := 50000000;
      baud_rate : integer := 9600;
      txf_depth : integer := 16;
      txf_thres : integer := 8;
      rxf_depth : integer := 16;
      rxf_thres : integer := 8
    );
    port
    (
      clk     : in std_logic;
      reset   : in std_logic;
      address : in std_logic_vector(addr_bits - 1 downto 0);
      wr_data : in std_logic_vector(31 downto 0);
      rd_data : out std_logic_vector(31 downto 0);
      rdy_cnt : out unsigned(1 downto 0);
      txd     : out std_logic;
      rxd     : in std_logic;
      ncts    : in std_logic;
      nrts    : out std_logic;
      rd      : out std_logic;
      wr      : out std_logic
    );
  end component;

begin
  -- Clock generation
  process
  begin
    wait for 5 ns;
    clk_tb <= not clk_tb;
  end process;

  -- Instantiate UART module
  uut : sc_uart
  generic
  map (
  addr_bits => 8,
  clk_freq  => 50000000, -- Adjust based on your clock frequency
  baud_rate => 9600, -- Adjust based on your baud rate requirement
  txf_depth => 16,
  txf_thres => 8,
  rxf_depth => 16,
  rxf_thres => 8
  )
  port map
  (
    clk     => clk_tb,
    reset   => reset_tb,
    address => address_tb,
    wr_data => wr_data_tb,
    rd_data => rd_data_tb,
    rdy_cnt => rdy_cnt_tb,
    txd     => txd_tb,
    rxd     => rxd_tb,
    ncts    => ncts_tb,
    nrts    => nrts_tb,
    rd      => rd_tb,
    wr      => wr_tb
  );

  -- Testbench process
  process
  begin
    -- Initialize UART
    wait for 10 ns;
    reset_tb <= '1';
    wait for 10 ns;
    reset_tb <= '0';

    -- Send a character
    wr_data_tb <= (others => 'H');
    address_tb <= "00000000"; -- Set the address for writing data
    wr_tb      <= '1';
    wait for 100 us;
    wr_tb <= '0';

    -- Wait for a while to receive characters
    wait for 200 ns;

    -- Print transmitted and received characters
    report "Transmitted character: " & to_string(wr_data_tb(7 downto 0));
    report "Received character: " & to_string(rd_data_tb(7 downto 0)); -- should be 0 ofc
    wait;
  end process;

end testbench;