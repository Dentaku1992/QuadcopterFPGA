----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: Toplevel for quadcopter autopilot
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY top IS
	PORT(
			clock				: IN STD_LOGIC;
			reset				: IN STD_LOGIC;
			spi_mosi			: IN STD_LOGIC;
			spi_miso			: OUT STD_LOGIC;
			spi_sclk			: IN STD_LOGIC;
			spi_slave_select	: IN STD_LOGIC
		);
END top;

ARCHITECTURE Behavioral OF top IS

	COMPONENT spi_slave IS
	  PORT(
	        clock : IN STD_LOGIC;
	        reset : IN STD_LOGIC;

	        slave_select : IN STD_LOGIC;
	        mosi : IN STD_LOGIC;
	        miso : OUT STD_LOGIC;
	        sclk : IN STD_LOGIC;

	        done : OUT STD_LOGIC;
	        data_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

	        motor_1_out : OUT STD_LOGIC;
	        motor_2_out : OUT STD_LOGIC;
	        motor_3_out : OUT STD_LOGIC;
	        motor_4_out : OUT STD_LOGIC

	    );
	END COMPONENT;

	COMPONENT Delay is
	    Port ( 
	    CLK 		: in  	STD_LOGIC; 
	    RST 		: in 	STD_LOGIC;  
	    DELAY_MS 	: in  	STD_LOGIC_VECTOR (11 DOWNTO 0); 
	    DELAY_EN 	: in  	STD_LOGIC; 
	    DELAY_FIN 	: out  	STD_LOGIC); 
	END COMPONENT;

	COMPONENT FOUR_AXIS_PWM_GENERATOR IS
  	GENERIC (
	  		base_clock				: INTEGER := 100000000;	--(Hz)
	  		pwm_frequency 			: INTEGER := 200000;	--(Hz)
	  		resolution				: INTEGER := 8);		-- Resolutie van de duty cycle  		
  	PORT (
  			clock 					: IN STD_LOGIC;
  			reset					: IN STD_LOGIC;
  			enable					: IN STD_LOGIC;
  			
  			motor1_duty_cycle		: IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
  			motor1_pwm_out			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  			motor1_pwm_inverse_out 	: OUT STD_LOGIC_VECTOR(0 DOWNTO 0).

  			motor2_duty_cycle		: IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
  			motor2_pwm_out			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  			motor2_pwm_inverse_out 	: OUT STD_LOGIC_VECTOR(0 DOWNTO 0).

  			motor3_duty_cycle		: IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
  			motor3_pwm_out			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  			motor3_pwm_inverse_out 	: OUT STD_LOGIC_VECTOR(0 DOWNTO 0).

  			motor4_duty_cycle		: IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
  			motor4_pwm_out			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  			motor4_pwm_inverse_out 	: OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  			);
	END COMPONENT;

	--clocking
	SIGNAL s_clock_10mhz : STD_LOGIC := '0';

	--delay signals
	SIGNAL s_delay_reset  	: std_logic := '0';	
	SIGNAL s_delay_ms 	 	: std_logic_vector(11 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_delay_en 	 	: std_logic := '0';
	SIGNAL s_delay_fin 	 	: std_logic := '0';

	--spi signals
	SIGNAL s_sti_data_in : std_logic_vector(7 DOWNTO '0') := (OTHERS => '0');
	SIGNAL s_spi_data_out : std_logic_vector(7 DOWNTO '0') := (OTHERS => '0');
	SIGNAL s_spi_done : std_logic := '0';

	--spi command controller logic
	type states is (	init_stage_1,
						init_stage_2,
						waiting_for_spi,
						spi_receive_first_message,
						--engine settings
						spi_set_motor_1,
						spi_set_motor_2,
						spi_set_motor_3,
						spi_set_motor_4,

						);
	SIGNAL current_state : states := init_stage_1;

	--pwm generation signals
	SIGNAL s_pwm_generator_enable	: std_logic := '0';
	SIGNAL s_motor1_duty_cycle		: std_logic_vector( 7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor1_pwm_inverse_out	: std_logic_vector( 0 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor2_duty_cycle		: std_logic_vector( 7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor2_pwm_inverse_out	: std_logic_vector( 0 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor3_duty_cycle		: std_logic_vector( 7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor3_pwm_inverse_out	: std_logic_vector( 0 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor4_duty_cycle		: std_logic_vector( 7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_motor4_pwm_inverse_out	: std_logic_vector( 0 DOWNTO 0) := (OTHERS => '0');

BEGIN
	spi_controller : spi_slave 
	  PORT MAP(
	        clock  => s_clock_10mhz,
	        reset  => reset,

	        slave_select  =>spi_slave_select ,
	        mosi => spi_mosi,
	        miso  => spi_miso,
	        sclk  => spi_sclk,

	        done  => s_spi_done,
	        data_in  => s_sti_data_in,
	        data_out  => s_spi_data_out
	    );
	motor_controller : FOUR_AXIS_PWM_GENERATOR 
  	GENERIC (
	  		base_clock				=> 100_000_000;	
	  		pwm_frequency 			=> 65;	
	  		resolution				=> 8);		 		
  	PORT MAP(
  			clock 					=> s_clock_10mhz,
  			reset					=> reset,
  			enable					=> s_pwm_generator_enable,
  			
  			motor1_duty_cycle		=> s_motor1_duty_cycle,
  			motor1_pwm_out			=> motor_1_out,
  			motor1_pwm_inverse_out 	=> s_motor1_pwm_inverse_out,

  			motor2_duty_cycle		=> s_motor2_duty_cycle,
  			motor2_pwm_out			=> motor_2_out,
  			motor2_pwm_inverse_out 	=> s_motor2_pwm_inverse_out,

  			motor3_duty_cycle		=> s_motor3_duty_cycle,
  			motor3_pwm_out			=> motor_3_out,
  			motor3_pwm_inverse_out 	=>s_motor3_pwm_inverse_out ,

  			motor4_duty_cycle		=> s_motor4_duty_cycle,
  			motor4_pwm_out			=> motor_4_out ,
  			motor4_pwm_inverse_out 	=> s_motor4_pwm_inverse_out
  			);
	
	motor_init_delay : Delay 
	    PORT MAP ( 
		    CLK 		=> s_clock_10mhz,
		    RST 		=> s_delay_reset,
		    DELAY_MS 	=> s_delay_ms,
		    DELAY_EN 	=> s_delay_en,
		    DELAY_FIN 	=> s_delay_fin);
	
 	BEGIN 

 		PROCESS (clock, reset)
 			IF(rising_edge(clock)) THEN
 				IF(reset = '1') THEN
 					--todo: reset
 				ELSE 
 					CASE( current_state ) is 
 						WHEN waiting_for_spi =>  
 							IF(s_spi_done <= '1') THEN
 								current_state <= spi_receive_first_message;
 							ELSE 	
 								current_state <= current_state;
 							END IF;
 						---------------------------------------------------------------
 						WHEN init_stage_1 =>
 							s_delay_reset <= '0';
 							s_delay_ms  <= "0001_1110_1000";  --0011_1110_1000
 							current_state <= init_stage_2
 						---------------------------------------------------------------
 						WHEN init_stage_2 =>
 							s_delay_en <= '1';
 							motor1_duty_cycle <= "0001_1001"; 
 							motor2_duty_cycle <= "0001_1001";
 							motor3_duty_cycle <= "0001_1001";
 							motor4_duty_cycle <= "0001_1001";

 							IF(s_delay_fin <= '1') THEN
 								current_state <= waiting_for_spi
 								s_delay_en <= '0';
 								s_delay_reset <= '1';
 							ELSE 
 								current_state <= current_state;
 							END IF;
 						---------------------------------------------------------------							
 						WHEN  spi_receive_first_message => 
 							IF    (s_spi_data_out = "0000_0001") THEN current_state <= spi_set_motor_1; --0x01
 							ELSIF (s_spi_data_out = "0000_0010") THEN current_state <= spi_set_motor_2; --0x02
 							ELSIF (s_spi_data_out = "0000_0011") THEN current_state <= spi_set_motor_3; --0x03
 							ELSIF (s_spi_data_out = "0000_0100") THEN current_state <= spi_set_motor_4; --0x04
 							ELSE current_state <= waiting_for_spi;
 							END IF;
						---------------------------------------------------------------
						WHEN spi_set_motor_1 =>
							IF(s_spi_done = '1') THEN
								motor1_duty_cycle <= s_spi_data_out;
								current_state <= waiting_for_spi;
							ELSE 
								current_state <= current_state;
							END IF;
						---------------------------------------------------------------
						WHEN spi_set_motor_2 =>
							IF(s_spi_done = '1') THEN
								motor2_duty_cycle <= s_spi_data_out;
								current_state <= waiting_for_spi;
							ELSE 
								current_state <= current_state;
							END IF;
						---------------------------------------------------------------
						WHEN spi_set_motor_3 =>
							IF(s_spi_done = '1') THEN
								motor3_duty_cycle <= s_spi_data_out;
								current_state <= waiting_for_spi;
							ELSE 
								current_state <= current_state;
							END IF;
						---------------------------------------------------------------
						WHEN spi_set_motor_4 =>
							IF(s_spi_done = '1') THEN
								motor4_duty_cycle <= s_spi_data_out;
								current_state <= waiting_for_spi;
							ELSE 
								current_state <= current_state;
							END IF;
						---------------------------------------------------------------		
 						WHEN OTHERS =>
 							current_state <= init_stage_1;
 					END CASE ;
 				END IF;
 			END IF;
 		END PROCESS;

END Behavioral;
