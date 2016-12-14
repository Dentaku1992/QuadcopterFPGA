----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: An one channel PID controller
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
	
	type states is (	new_data, 
						kp_stage_1,
						kp_stage_2,
						kp_stage_3,
						ki_stage_1,
						ki_stage_2,
						ki_stage_3,
						kd_stage_1,
						kd_stage_2,
						kd_stage_3,
						calculations_ready,
						output_ready);
	SIGNAL current_state : states := new_data;

	SIGNAL s_setpoint : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_actual_value : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0) := (OTHERS => '0') ;
	SIGNAL s_error : STD_LOGIC_VECTOR (data_width-1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_old_error : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_old_output_i_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL s_kp :STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_ki :STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_kd :STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_output_p_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL s_output_i_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_output_d_controller : STD_LOGIC_VECTOR(data_width -1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_to_multiplier_a :STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_to_multiplier_b: STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_result_multiplier: STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_output : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');


	COMPONENT multiplier
	PORT (
		 clk : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 p : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	  );
	END COMPONENT;

	BEGIN

		mult : multiplier
		PORT MAP (
			clk => clock,
			a => s_to_multiplier_a,
			b => s_to_multiplier_b,
			p => s_result_multiplier);

		PROCESS(clock, reset)
			BEGIN
				if(rising_edge(clock)) then
					IF(reset = '1') THEN
						s_output <= (OTHERS => '0');
						s_output_p_controller <= (OTHERS => '0');
						s_output_i_controller <= (OTHERS => '0');
						s_output_d_controller <= (OTHERS => '0');
						s_old_error <= (OTHERS => '0');
					ELSE
						case( current_state ) is 
							when new_data =>  
								s_kp <= kp;
								s_ki <= ki;
								s_kd <= kd;
								s_setpoint <= data_setpoint;
								s_actual_value <= data_actual_value;
								s_old_error <= s_error;
								s_old_output_i_controller <= s_output_i_controller;
								s_error <= 	STD_LOGIC_VECTOR(SIGNED(data_setpoint) - SIGNED(data_actual_value));
								current_state <= kp_stage_1;
							when kp_stage_1 =>
								--maak klaar voor multiplier:
								s_to_multiplier_a(data_width-1 DOWNTO 0) <= s_error;
								s_to_multiplier_b(internal_data_width-1 DOWNTO 0) <= s_kp;
								current_state <= kp_stage_2;
							when kp_stage_2 =>
								--multiplier in action
								current_state <= kp_stage_3;
							when kp_stage_3 =>
								--multiplier output valid
								s_output_p_controller <= s_result_multiplier(data_width-1 DOWNTO 0);
								current_state <= ki_stage_1;
							when ki_stage_1 =>
								--maak klaar voor multiplier:
								s_to_multiplier_a(data_width-1 DOWNTO 0) <= s_error;
								s_to_multiplier_b(internal_data_width-1 DOWNTO 0) <= s_ki;
								current_state <= ki_stage_2;
							when ki_stage_2 =>
								--multiplier in action
								current_state <= ki_stage_3;
							when kp_stage_3 =>
								--multiplier output valid
								s_output_i_controller <= STD_LOGIC_VECTOR(SIGNED(s_result_multiplier(data_width-1 DOWNTO 0)) + signed(s_old_output_i_controller));
								current_state <= kd_stage_1;
							when kd_stage_1 =>
								--maak klaar voor multiplier:
								s_to_multiplier_a(data_width-1 DOWNTO 0) <= STD_LOGIC_VECTOR(SIGNED(s_error) - SIGNED(s_old_error));
								s_to_multiplier_b(internal_data_width-1 DOWNTO 0) <= s_kd;
								current_state <= kd_stage_2;
							when kd_stage_2 =>
								--multiplier in action
								current_state <= kd_stage_3;
							when kd_stage_3 =>
								--multiplier output valid
								s_output_d_controller <= s_result_multiplier(data_width-1 DOWNTO 0);
								current_state <= calculations_ready;
							when  calculations_ready =>
								s_output <= STD_LOGIC_VECTOR(SIGNED(s_output_p_controller) + SIGNED(s_output_i_controller) + SIGNED(s_output_d_controller));
								current_state <= output_ready;
							when output_ready =>
								data_output <= s_output;
								current_state <= new_data;
							when others => 
								current_state <= new_data; 
						end case ;
					END IF;
				end if;
		END PROCESS;

END behavioral;