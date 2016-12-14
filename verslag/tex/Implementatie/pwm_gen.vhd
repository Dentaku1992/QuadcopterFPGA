ENTITY PWM_GENERATOR IS
  GENERIC (
	  		base_clock		: INTEGER := 100000000;
	  		pwm_frequency  : INTEGER := 200000;	
	  		resolution		: INTEGER := 8);
  PORT (
  			clock 		: IN STD_LOGIC;
  			reset			: IN STD_LOGIC;
  			enable		: IN STD_LOGIC;
  			duty_cycle: IN STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0);
  			pwm_out		: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  			pwm_inverse_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
END PWM_GENERATOR;