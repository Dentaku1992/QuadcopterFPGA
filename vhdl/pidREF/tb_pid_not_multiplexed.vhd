----------------------------------------------------------------------------------
-- Engineer:  Gert-Jan Andries <info@gertjanandries.com>
-- Project:   Quadcopter autopilot
-- Description: Testbench for not multiplexed PID controller
----------------------------------------------------------------------------------
library UNISIM;
use UNISIM.VComponents.all;
library ieee;
use ieee.std_logic_1164.all;

entity tb_PID_CONTROLLER is
	GENERIC(
    		data_width 		: INTEGER := 32;
    		internal_data_width	: INTEGER := 16
    	);  
end tb_PID_CONTROLLER;

architecture tb of tb_PID_CONTROLLER is

    component PID_CONTROLLER
      
	port (     clock             : in std_logic;
              reset             : in std_logic;
              kp                : in std_logic_vector (internal_data_width-1 downto 0);
              ki                : in std_logic_vector (internal_data_width-1 downto 0);
              kd                : in std_logic_vector (internal_data_width-1 downto 0);
              data_setpoint     : in std_logic_vector (data_width-1 downto 0);
              data_actual_value : in std_logic_vector (data_width-1 downto 0);
              data_output       : out std_logic_vector (data_width-1 downto 0));
    end component;

    signal clock             : std_logic;
    signal reset             : std_logic;
    signal kp                : std_logic_vector (internal_data_width-1 downto 0) := "0000000000001100";
    signal ki                : std_logic_vector (internal_data_width-1 downto 0) := "0000000000000010";
    signal kd                : std_logic_vector (internal_data_width-1 downto 0):= "0000000000000011";
    signal data_setpoint     : std_logic_vector (data_width-1 downto 0);
    signal data_actual_value : std_logic_vector (data_width-1 downto 0);
    signal data_output       : std_logic_vector (data_width-1 downto 0);

    constant TbPeriod : time := 10 ns; 
    signal TbClock : std_logic := '0';

begin

    dut : PID_CONTROLLER
    port map (clock             => clock,
              reset             => '0',
              kp                => "0000000000001100",
              ki                => "0000000000000010",
              kd                => "0000000000000011",
              data_setpoint     => data_setpoint,
              data_actual_value => data_actual_value,
              data_output       => data_output);

    TbClock <= not TbClock after TbPeriod/2;

    clock <= TbClock;

    stimuli : process
    begin
        data_setpoint <=    "00000000000000001000010000000000";
        data_actual_value <="00000000000000000111111000001111";

        wait for 500 ns;
        
        data_actual_value <="00000000000000000100111000001111";
        
        wait for 500 ns;
        
        data_actual_value <="00000000000000001000010000000001";
        
        wait for 100 ns;
        data_actual_value <="00000000000000001000010000000001";
        wait for 100 ns;
        data_actual_value <="00000000000000001000010000000001";
        
        wait for 3000 ns;
        
        wait;
    end process;

end tb;

configuration cfg_tb_PID_CONTROLLER of tb_PID_CONTROLLER is
    for tb
    end for;
end cfg_tb_PID_CONTROLLER;
