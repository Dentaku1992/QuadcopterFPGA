ENTITY PID_CONTROLLER IS
   GENERIC(
    	data_width 				: INTEGER := 32;
    	internal_data_width	: INTEGER := 16
    );
 
	PORT(
	    clock  :  IN  STD_LOGIC;
	    reset  :  IN  STD_LOGIC;

	    kp     :  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    ki     :  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);
	    kd     :  IN STD_LOGIC_VECTOR(internal_data_width-1 DOWNTO 0);

	    data_setpoint     :  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    data_actual_value :  IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0); 
	    data_output   	  :  OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0)
  	);
END PID_CONTROLLER;