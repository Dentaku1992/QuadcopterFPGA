----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: A standard SPI slave 
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

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

ARCHITECTURE Behavioral OF spi_slave IS
    
    signal s_old_sclk : std_logic := '0';
    signal bit_counter : integer range 0 to 7 := 0;
    signal s_data_out : std_logic_vector(7 downto 0) := (others => '0');

    BEGIN
        process(clock, reset)
        begin
        if(rising_edge(clock)) then
            if reset = '1' then
                data_out <= (others => '0');
                bit_counter <= 0;
                done <= '0';
            else
                if slave_select <= '0' then
                    miso <= data_in(7-bit_counter);
                    if sclk = '1' and s_old_sclk = '0' then
                        if(bit_counter < 7) then
                            s_data_out <= s_data_out(6 downto 0) & mosi;
                            bit_counter <= bit_counter + 1;
                        else
                            bit_counter <= 0;
                            done <= '1';
                            data_out <= s_data_out(6 downto 0) & mosi;
                        end if;
                    else
                        s_data_out <= s_data_out;                     
                    end if;
                else
                    done <= '0';
                    miso <= '0';
                end if;
            end if;
            s_old_sclk <= sclk;
        end if;
        end process;

END ARCHITECTURE;
