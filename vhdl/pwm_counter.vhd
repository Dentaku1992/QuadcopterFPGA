----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: A PWM counter to read a PWM signal
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity PWM_COUNTER is
   GENERIC(
   		component_clock		: INTEGER := 1_000_000_000;    --Hz
    	pwm_frequency		: INTEGER := 1_000_000;		   --Hz
    	output_width		: INTEGER := 16   			   --Bits
    );
    Port( 
			CLK: in STD_LOGIC;
			RST: in STD_LOGIC;
			PWM_IN: in STD_LOGIC;
			PWM_COUNT : out STD_LOGIC_VECTOR(output_width - 1 downto 0)		
	 );
end PWM_COUNTER;


architecture Behavioral of PWM_COUNTER is
	
	CONSTANT sample_period : INTEGER := pwm_frequency * (2**output_width);
	CONSTANT samples_to_count : INTEGER := component_clock / sample_period;
	CONSTANT half_samples_to_count : INTEGER := (samples_to_count / 2) + 1;
	SIGNAL s_sample_clock_tick_counter : INTEGER range 0 to samples_to_count + 1 := 0;
	
	SIGNAL s_sample_clock : STD_LOGIC := '0';
    SIGNAL s_pwm_count : STD_LOGIC_VECTOR(output_width - 1 downto 0) := (others => '0');


	CONSTANT number_of_ticks : INTEGER := component_clock/pwm_frequency;
	SIGNAL tick_counter : INTEGER range 0 to number_of_ticks := 0;
	SIGNAL s_previous_pwm_in : STD_LOGIC := '0';

	BEGIN
	   PWM_COUNT <= s_pwm_count;
		sample_clocking : process(CLK)
		BEGIN
			if(rising_edge(CLK)) THEN
				s_sample_clock_tick_counter <= s_sample_clock_tick_counter + 1;
				IF(s_sample_clock_tick_counter < half_samples_to_count) THEN
					s_sample_clock <= '1';
				ELSE
					s_sample_clock <= '0';
				END IF;
			END IF;
		END PROCESS;

		sampling : process(s_sample_clock, RST)
		BEGIN
		IF(rising_edge(s_sample_clock)) THEN
			IF(RST = '1') THEN
				s_pwm_count <= (others => '0');
			ELSE
				IF(PWM_IN = '1' and s_previous_pwm_in ='0') THEN
					--rising edge on pwm
					tick_counter <= 1;
				ELSIF(PWM_IN = '1' and s_previous_pwm_in ='1') THEN
					--pwm is high
					tick_counter <= tick_counter + 1;
				ELSIF(PWM_IN = '0' and s_previous_pwm_in = '1') THEN
					--pwm goto low
					s_pwm_count <= STD_LOGIC_VECTOR(to_unsigned(tick_counter,16));
				ELSE
					s_pwm_count <= s_pwm_count;
				END IF;
			END IF;
			s_previous_pwm_in <= PWM_IN;
		END IF;
		END PROCESS;
	
end Behavioral;
