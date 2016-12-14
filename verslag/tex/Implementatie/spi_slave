ENTITY spi_slave IS
  PORT(
        clock : in std_logic;
        reset : in std_logic;

        slave_select : in std_logic;
        mosi : in std_logic;
        miso : out std_logic;
        sclk : in std_logic;

        done : out std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0)
    );
END spi_slave;