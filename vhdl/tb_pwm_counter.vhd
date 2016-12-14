----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: A testbench for the PWM counter
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY tb_PWM_COUNTER IS
END tb_PWM_COUNTER;

ARCHITECTURE tb OF tb_PWM_COUNTER IS

    COMPONENT PWM_COUNTER
      GENERIC (
                component_clock   : INTEGER := 10_000_000;  --Hz
                pwm_frequency   : INTEGER := 1000;          --Hz
                output_width    : INTEGER := 16             --Bits
              );

      PORT    (
                CLK       : IN STD_LOGIC;
                RST       : IN STD_LOGIC;
                PWM_IN    : IN STD_LOGIC;
                PWM_COUNT : OUT STD_LOGIC_VECTOR (output_width - 1 DOWNTO 0)
             );
    END COMPONENT;

    SIGNAL CLK       : STD_LOGIC;
    SIGNAL RST       : STD_LOGIC;
    SIGNAL PWM_IN    : STD_LOGIC;
    SIGNAL PWM_COUNT : STD_LOGIC_vector (output_width - 1 DOWNTO 0);

    CONSTANT TbPeriod : time := 1 ns;
    SIGNAL TbClock : STD_LOGIC := '0';

    CONSTANT PWMPeriod : time := 10 ns; 
    SIGNAL PWMClock : STD_LOGIC := '0';

BEGIN

    dut : PWM_COUNTER
    PORT MAP (CLK       => CLK,
              RST       => RST,
              PWM_IN    => PWMClock,
              PWM_COUNT => PWM_COUNT);

    TbClock <= NOT TbClock AFTER TbPeriod/2;
    PWMClock <= NOT PWMClock AFTER PWMPeriod/2;

    CLK <= TbClock;
    pwm_frequency_gen : PROCESS

    stimuli : PROCESS
    BEGIN
          
        WAIT FOR 100 ms;

        WAIT;
    END PROCESS;

END tb;
