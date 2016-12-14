----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: A generator to generate a PWM signal
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY PWM_GENERATOR IS
  GENERIC (
	  		base_clock		: INTEGER := 100000000;	--(Hz)
	  		pwm_frequency 	: INTEGER := 200000;	--(Hz)
	  		resolution		: INTEGER := 8);		-- Resolutie van de duty cycle  		
  PORT (
  			clock 			: IN STD_LOGIC;
  			reset			: IN STD_LOGIC;
  			enable			: IN STD_LOGIC;
  			duty_cycle		: IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
  			pwm_out			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  			pwm_inverse_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
END PWM_GENERATOR;

ARCHITECTURE behavioral OF PWM_GENERATOR IS
		CONSTANT period : INTEGER := base_clock/pwm_frequency;
		TYPE counter IS ARRAY (0 DOWNTO 0) OF INTEGER RANGE 0 TO period -1;
		TYPE half_duty_cycle_values IS ARRAY (0 TO 0) OF INTEGER RANGE 0 TO period/2;
		
		SIGNAL count : counter := (OTHERS => 0);
		SIGNAL half_duty_cycle_new : INTEGER RANGE 0 to period/2 := 0;
		SIGNAL half_duty_cycle : half_duty_cycle_values := (OTHERS => 0);
	BEGIN
		PROCESS(clock, reset)
			BEGIN
				IF(reset = '1') THEN
					count <= (OTHERS => 0);
					pwm_out <= (OTHERS => '0');
					pwm_inverse_out <= (OTHERS => '0');				
				ELSIF(rising_edge(clock)) THEN
					IF(enable = '1') THEN
						half_duty_cycle_new <= conv_integer(duty_cycle)*period/(2**resolution)/2;					
					END IF;					
					IF(count(0) = period - 1) THEN
						count(0) <= 0;
						half_duty_cycle(0) <= half_duty_cycle_new;
					ELSE
						count(0) <= count(0) + 1;
					END IF;

					IF(count(0) = half_duty_cycle(0)) THEN
						pwm_out(0) <= '0';
						pwm_inverse_out(0) <= '1';
					ELSIF(count(0) = period - half_duty_cycle(0)) THEN
						pwm_out(0) <= '1';
						pwm_inverse_out(0) <= '0';
					END IF;
				END IF;
		END PROCESS;
END behavioral;