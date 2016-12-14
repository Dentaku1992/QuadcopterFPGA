----------------------------------------------------------------------------------
-- Engineer: 	Gert-Jan Andries <info@gertjanandries.com>
-- Project: 	Quadcopter autopilot
-- Description: A four axis PID controller
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY FOUR_AXIX_PID_CONTROLLER IS
   GENERIC(
    	data_width 			: INTEGER := 32;
    	internal_data_width	: INTEGER := 16
    );
 
	PORT(
	    clock      			:  IN  STD_LOGIC;
	    reset      			:  IN  STD_LOGIC;

	    roll_kp  		 	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    roll_ki        		:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    roll_kd        		:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    roll_setpoint   	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    roll_actual_value 	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    roll_output   		:  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
	    
	    pitch_kp  		 	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    pitch_ki        	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    pitch_kd        	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    pitch_setpoint   	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    pitch_actual_value 	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    pitch_output   		:  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
	    
	    yaw_kp  		 	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    yaw_ki        		:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    yaw_kd        		:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    yaw_setpoint   		:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    yaw_actual_value 	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    yaw_output   		:  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
	    
	    height_kp  		 	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    height_ki        	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    height_kd        	:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    height_setpoint   	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    height_actual_value :  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    height_output   	:  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);

	    values_ready		:  OUT STD_LOGIC
  	);

END FOUR_AXIX_PID_CONTROLLER;

ARCHITECTURE behavioral OF FOUR_AXIX_PID_CONTROLLER IS

	COMPONENT PID_CONTROLLER IS
	   GENERIC(
	    	data_width 			: INTEGER := 32;
	    	internal_data_width	: INTEGER := 16
	    );
	 
		PORT(
		    clock      			:  IN  STD_LOGIC;
		    reset      			:  IN  STD_LOGIC;

		    kp  		 		:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
		    ki        			:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
		    kd        			:  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);

		    data_setpoint   	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
		    data_actual_value 	:  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
		    data_output   		:  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		    data_ready			:  OUT STD_LOGIC
	  	);
	END COMPONENT;

		SIGNAL s_data_ready_roll : STD_LOGIC := '0';
		SIGNAL s_data_ready_pitch : STD_LOGIC := '0';
		SIGNAL s_data_ready_yaw : STD_LOGIC := '0';
		SIGNAL s_data_ready_height : STD_LOGIC := '0';

	BEGIN

		roll_pid : PID_CONTROLLER
			PORT MAP(
			    clock      			=> clock,
			    reset      			=> reset,

			    kp  		 		=> roll_kp,
			    ki        			=> roll_ki,
			    kd        			=> roll_kd,      	

			    data_setpoint   	=> roll_setpoint,   
			    data_actual_value 	=> roll_actual_value,
			    data_output   		=> roll_output,  	
			    data_ready			=> s_data_ready_roll 
		  	);

	  	pitch_pid : PID_CONTROLLER
			PORT MAP(
			    clock      			=> clock,
			    reset      			=> reset,

			    kp  		 		=> pitch_kp,
			    ki        			=> pitch_ki,
			    kd        			=> pitch_kd,      	

			    data_setpoint   	=> pitch_setpoint,   
			    data_actual_value 	=> pitch_actual_value,
			    data_output   		=> pitch_output,  	
			    data_ready			=> s_data_ready_pitch 
		  	);

	  	yaw_pid : PID_CONTROLLER
			PORT MAP(
			    clock      			=> clock,
			    reset      			=> reset,

			    kp  		 		=> yaw_kp,
			    ki        			=> yaw_ki,
			    kd        			=> yaw_kd,      	

			    data_setpoint   	=> yaw_setpoint,   
			    data_actual_value 	=> yaw_actual_value,
			    data_output   		=> yaw_output,  	
			    data_ready			=> s_data_ready_yaw  
		  	);

	  	height_pid : PID_CONTROLLER
			PORT MAP(
			    clock      			=> clock,
			    reset      			=> reset,

			    kp  		 		=> height_kp,
			    ki        			=> height_ki,
			    kd        			=> height_kd,      	

			    data_setpoint   	=> height_setpoint,   
			    data_actual_value 	=> height_actual_value,
			    data_output   		=> height_output,  	
			    data_ready			=> s_data_ready_height
		  	);

		if rising_edge(clock) then
			if s_data_ready_roll = 1 and s_data_ready_pitch = 1 and s_data_ready_yaw = 1 and s_data_ready_height = 1 then
				values_ready <= '1';
			else 
				values_ready <= '0';
			end if;
		end if;


END behavioral;