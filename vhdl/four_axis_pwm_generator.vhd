----------------------------------------------------------------------------------
-- Engineer:    Gert-Jan Andries <info@gertjanandries.com>
-- Project:     Quadcopter autopilot
-- Description: A four axis PWM generator to control
--              the quadcopters BLDC engines, needs a input clock of 10 Mhz
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY FOUR_AXIS_PWM_GENERATOR IS
    GENERIC (
        base_clock        : INTEGER := 10000000; --(Hz)
        pwm_frequency       : INTEGER := 65;  --(Hz)
        resolution        : INTEGER := 8);    -- Resolutie van de duty cycle      
    PORT (
        clock           : IN STD_LOGIC;
        reset         : IN STD_LOGIC;
        enable          : IN STD_LOGIC;
        
        motor1_duty_cycle   : IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
        motor1_pwm_out      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        motor1_pwm_inverse_out  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);

        motor2_duty_cycle   : IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
        motor2_pwm_out      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        motor2_pwm_inverse_out  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);

        motor3_duty_cycle   : IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
        motor3_pwm_out      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        motor3_pwm_inverse_out  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);

        motor4_duty_cycle   : IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
        motor4_pwm_out      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        motor4_pwm_inverse_out  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
        );
END FOUR_AXIS_PWM_GENERATOR;

ARCHITECTURE behavioral OF FOUR_AXIS_PWM_GENERATOR IS
  
  COMPONENT PWM_GENERATOR IS
    GENERIC (
          base_clock    : INTEGER := base_clock;  --(Hz)
          pwm_frequency   : INTEGER := pwm_frequency; --(Hz)
          resolution    : INTEGER := resolution);   -- Resolutie van de duty cycle      
    PORT (
          clock       : IN STD_LOGIC;
          reset     : IN STD_LOGIC;
          enable      : IN STD_LOGIC;
          duty_cycle    : IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
          pwm_out     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
          pwm_inverse_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
  END COMPONENT;

  BEGIN 

    motor1_pwm : PWM_GENERATOR
      PORT MAP (
        clock       => clock,
        reset     => reset,
        enable      => enable,
        duty_cycle    => motor1_duty_cycle,
        pwm_out     => motor1_pwm_out,
        pwm_inverse_out => motor1_pwm_inverse_out );

    motor2_pwm : PWM_GENERATOR
      PORT MAP (
        clock       => clock,
        reset     => reset,
        enable      => enable,
        duty_cycle    => motor2_duty_cycle,
        pwm_out     => motor2_pwm_out,
        pwm_inverse_out => motor2_pwm_inverse_out );

    motor3_pwm : PWM_GENERATOR
      PORT MAP (
        clock       => clock,
        reset     => reset,
        enable      => enable,
        duty_cycle    => motor3_duty_cycle,
        pwm_out     => motor3_pwm_out,
        pwm_inverse_out => motor3_pwm_inverse_out );

    motor4_pwm : PWM_GENERATOR
      PORT MAP (
        clock       => clock,
        reset     => reset,
        enable      => enable,
        duty_cycle    => motor4_duty_cycle,
        pwm_out     => motor4_pwm_out,
        pwm_inverse_out => motor4_pwm_inverse_out );

END behavioral;