----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: A testbench for the PID controller
----------------------------------------------------------------------------------
LIBRARY UNISIM;
USE UNISIM.VCOMPONENTs.all;
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY tb_PID_CONTROLLER is
	GENERIC(
    		    data_width 		: INTEGER := 32;
    		    internal_data_width	: INTEGER := 16
    	   );  
END tb_PID_CONTROLLER;

ARCHITECTURE tb OF tb_PID_CONTROLLER IS

  COMPONENT PID_CONTROLLER
      
	PORT (
              clock             : IN STD_LOGIC;
              reset             : IN STD_LOGIC;
              kp                : IN STD_LOGIC_VECTOR (internal_data_width-1 DOWNTO 0);
              ki                : IN STD_LOGIC_VECTOR (internal_data_width-1 DOWNTO 0);
              kd                : IN STD_LOGIC_VECTOR (internal_data_width-1 DOWNTO 0);
              data_setpoint     : IN STD_LOGIC_VECTOR (data_width-1 DOWNTO 0);
              data_actual_value : IN STD_LOGIC_VECTOR (data_width-1 DOWNTO 0);
              data_output       : OUT STD_LOGIC_VECTOR (data_width-1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clock             : STD_LOGIC;
    SIGNAL reset             : STD_LOGIC;
    SIGNAL kp                : STD_LOGIC_VECTOR (internal_data_width-1 DOWNTO 0) := "0000000000001100";
    SIGNAL ki                : STD_LOGIC_VECTOR (internal_data_width-1 DOWNTO 0) := "0000000000000010";
    SIGNAL kd                : STD_LOGIC_VECTOR (internal_data_width-1 DOWNTO 0):= "0000000000000011";
    SIGNAL data_setpoint     : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0);
    SIGNAL data_actual_value : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0);
    SIGNAL data_output       : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0);

    CONSTANT TbPeriod : time := 10 ns;
    SIGNAL TbClock : STD_LOGIC := '0';

BEGIN

    dut : PID_CONTROLLER
    PORT MAP (
                clock             => clock,
                reset             => '0',
                kp                => "0000000000001100",
                ki                => "0000000000000010",
                kd                => "0000000000000011",
                data_setpoint     => "00000000000000001010110100110011",
                data_actual_value => "00000000000000000000110100110011",
                data_output       => data_output
              );

    TbClock <= NOT TbClock AFTER TbPeriod/2;
    clock <= TbClock;

    simulation : PROCESS
    BEGIN
        IF(RISING_EDGE(clock)) THEN
          data_actual_value <= STD_LOGIC_VECTOR(SIGNED(data_actual_value) + SIGNED (data_output(31 DOWNTO 0));
        END IF; 
        WAIT;
    END PROCESS;

END tb;
