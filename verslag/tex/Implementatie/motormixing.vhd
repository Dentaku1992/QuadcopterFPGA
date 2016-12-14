entity MOTOR_MIXING is
	GENERIC(
		data_width_in	: INTEGER := 8;
		output_data_width : INTEGER := 8
	);
	PORT( 
		clock: in STD_LOGIC;
		reset: in STD_LOGIC;
		roll_correction : IN STD_LOGIC_VECTOR(data_width_in-1 DOWNTO 0);
		pitch_corrention : IN STD_LOGIC_VECTOR(data_width_in-1 DOWNTO 0);
		yaw_correction : IN STD_LOGIC_VECTOR(data_width_in-1 DOWNTO 0);
		height_correction : IN STD_LOGIC_VECTOR(data_width_in-1 DOWNTO 0);
		throttle_value : in STD_LOGIC_VECTOR (data_width_in-1 DOWNTO 0);
		motor_front_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);
		motor_left_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);
		motor_back_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);
		motor_right_out : OUT STD_LOGIC_VECTOR(output_data_width DOWNTO 0);		
		motor_max : IN (STD_LOGIC_VECTOR(output_data_width-1 DOWNTO 0))				
	 );
end MOTOR_MIXING;