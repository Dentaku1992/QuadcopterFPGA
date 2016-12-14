----------------------------------------------------------------------------------
-- Engineer: 	Gert-Jan Andries <info@gertjanandries.com>
-- Project: 	Quadcopter autopilot
-- Description: A not multiplexed PID controller 
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;  
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use UNISIM.Vcomponents.all;


ENTITY PID_CONTROLLER IS
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
	    data_output   		:  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0)
  	);
END PID_CONTROLLER;


ARCHITECTURE behavioral OF PID_CONTROLLER IS
	
	SIGNAL s_setpoint : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_actual_value : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0) := (OTHERS => '0') ;
	SIGNAL s_error : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_output : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0);
	SIGNAL s_output_p_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL s_output_i_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_output_d_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_temp_output_p_controller : STD_LOGIC_VECTOR(internal_data_width + data_width -1 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL s_temp_output_i_controller : STD_LOGIC_VECTOR(internal_data_width + data_width -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_temp_output_d_controller : STD_LOGIC_VECTOR(internal_data_width + data_width -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_temp_output : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL TEMP_1 : STD_LOGIC_VECTOR(63 - internal_data_width - data_width downto 0) := (OTHERS => '0');
    SIGNAL TEMP_2 : STD_LOGIC_VECTOR(63 - internal_data_width - data_width downto 0) := (OTHERS => '0');
    SIGNAL TEMP_3 : STD_LOGIC_VECTOR(63 - internal_data_width - data_width downto 0) := (OTHERS => '0');

	SIGNAL s_old_error : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_old_output_i_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0');
	
	SIGNAL s_d_operands : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0):= (OTHERS => '0');
	
	COMPONENT multiplier
	PORT (
		 clk : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 p : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	  );
	END COMPONENT;

	BEGIN	   
	   s_d_operands <=  STD_LOGIC_VECTOR(SIGNED(s_error) - SIGNED(s_old_error));
	   
		p_mult : multiplier
		PORT MAP (
			clk => clock,
			a(internal_data_width-1 downto 0) => kp,
			a(31 downto internal_data_width) => (others => '0'),
			b(data_width-1 DOWNTO 0) => s_error,			
			p(internal_data_width + data_width -1 DOWNTO 0) => s_temp_output_p_controller ,
			p(63 downto internal_data_width + data_width ) => TEMP_1);		
		i_mult : multiplier
		PORT MAP (
			clk => clock,
			a(internal_data_width-1 downto 0) => ki,
			a(31 downto internal_data_width) => (others => '0'),
			b(data_width-1 DOWNTO 0) => s_error,
			p(internal_data_width + data_width -1 DOWNTO 0) => s_temp_output_i_controller,
			p(63 downto internal_data_width + data_width ) => TEMP_2);		
		d_mult : multiplier
		PORT MAP (
			clk => clock,
			a(internal_data_width-1 downto 0) => kd,
			a(31 downto internal_data_width) => (others => '0'),
			b(data_width-1 DOWNTO 0) => s_d_operands,
			p(internal_data_width + data_width -1 DOWNTO 0) => s_temp_output_d_controller,
			p(63 downto internal_data_width + data_width ) => TEMP_3);
		
		data_output <= s_output;
		s_error <= STD_LOGIC_VECTOR(SIGNED(s_setpoint) - SIGNED(s_actual_value));
		s_setpoint <= data_setpoint;
		s_actual_value <= data_actual_value;

		PROCESS(clock)
			BEGIN								
				IF(rising_edge(clock)) THEN 
					IF(reset = '1') THEN
						s_output <= (OTHERS => '0');
						s_output_p_controller <= (OTHERS => '0');
						s_output_i_controller <= (OTHERS => '0');
						s_output_d_controller <= (OTHERS => '0');
						s_old_error <= (OTHERS => '0');
					ELSE
						s_output_p_controller(data_width-1 DOWNTO 0) <= s_temp_output_p_controller(data_width-1 DOWNTO 0);
						s_output_i_controller(data_width-1 DOWNTO 0) <= STD_LOGIC_VECTOR(SIGNED(s_temp_output_i_controller(data_width-1 DOWNTO 0)) + SIGNED(s_output_i_controller(data_width -1 DOWNTO 0)));
						s_output_d_controller(data_width-1 DOWNTO 0) <= s_temp_output_d_controller(data_width-1 DOWNTO 0);
						s_temp_output <= STD_LOGIC_VECTOR(SIGNED(s_output_p_controller) + SIGNED(s_output_i_controller) + SIGNED(s_output_d_controller));
						IF(s_temp_output > "00000000000000000001000000000000")THEN
							s_output <= s_temp_output(data_width-1 DOWNTO 0);
						ELSE
							s_output <= s_temp_output(data_width-1 DOWNTO 0);
						END IF;
						s_old_error <= s_error;
						s_old_output_i_controller <= s_output_i_controller;
					END IF;
				END IF;
		END PROCESS;
	
END behavioral;