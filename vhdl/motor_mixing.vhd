----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: Motor mixing unit to mix the signal comming form te different
--				POD modules into a signal for each BLDC engine
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity MOTOR_MIXING is
   GENERIC(
		data_width_of_correction_signal	: INTEGER := 8;
		data_width_of_controller_signal : INTEGER := 8;
		output_data_width : INTEGER := 8
    );
    PORT( 
			clock: in STD_LOGIC;
			reset: in STD_LOGIC;

			roll_correction : IN STD_LOGIC_VECTOR(data_width_of_correction_signal -1 DOWNTO 0);
			pitch_corrention : IN STD_LOGIC_VECTOR(data_width_of_correction_signal -1 DOWNTO 0);
			yaw_correction : IN STD_LOGIC_VECTOR(data_width_of_correction_signal -1 DOWNTO 0);
			height_correction : IN STD_LOGIC_VECTOR(data_width_of_correction_signal -1 DOWNTO 0);

			throttle_value : in STD_LOGIC_VECTOR (data_width_of_controller_signal - 1 DOWNTO 0);

			motor_front_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);
			motor_left_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);
			motor_back_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);
			motor_right_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);		

			motor_max : IN (STD_LOGIC_VECTOR(output_data_width -1 DOWNTO 0))				
	 );
end MOTOR_MIXING;


ARCHITECTURE behavioral OF MOTOR_MIXING IS

	type states is (calculate, check, update)
	signal current_state : states := calculate;

	signal s_motor_front_out : STD_LOGIC_VECTOR(output_data_width DOWNTO 0) := (others => '0');
	signal s_motor_left_out : STD_LOGIC_VECTOR(output_data_width DOWNTO 0) := (others => '0');
	signal s_motor_back_out : STD_LOGIC_VECTOR(output_data_width DOWNTO 0) := (others => '0');
	signal s_motor_right_out : STD_LOGIC_VECTOR(output_data_width DOWNTO 0) := (others => '0');	

	
	if(rising_edge(clock))
		case( current_state ) is 
			when calculate =>  
				s_motor_left_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) + signed(pitch_corrention) - signed(yaw_correction));
				s_motor_left_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) + signed(roll_correction) + signed(yaw_correction));
				s_motor_back_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) - signed(pitch_corrention) - signed(yaw_correction));
				s_motor_right_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) - signed(roll_correction) + signed(yaw_correction));
				current_state <= check;
			when check =>
				if(s_motor_left_out > motor_max) then
					s_motor_left_out <= motor_max;
				end if;
				if(s_motor_right_out > motor_max) then
					s_motor_right_out <= motor_max;
				end if;
				if(s_motor_back_out > motor_max) then
					s_motor_back_out <= motor_max;
				end if;
				if(s_motor_front_out > motor_max) then
					s_motor_front_out <= motor_max;
				end if;
				current_state <= update;
			when update =>
				motor_front_out <= s_motor_left_out ;
				motor_left_out  <= s_motor_left_out ;
				motor_back_out  <= s_motor_back_out ;
				motor_right_out <= s_motor_right_out;
				current_state <= calculate;
			when others => 
				current_state <= calculate;
		end case ;
		--motor_left_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) + signed(pitch_corrention) - signed(yaw_correction));
		--motor_left_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) + signed(roll_correction) + signed(yaw_correction));
		--motor_back_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) - signed(pitch_corrention) - signed(yaw_correction));
		--motor_right_out <= STD_LOGIC_VECTOR(signed(throttle_value) + signed(height_correction) - signed(roll_correction) + signed(yaw_correction));
	end if;
	
END behavioral;


