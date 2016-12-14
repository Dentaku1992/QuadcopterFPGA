#Design of a quadcopter controller in VHDL

###Overview

In this project, a quad copter flight controller was designed in 'pure' hardware making use of a FPGA (Mojo development board). A PID control unit was used in order to provide stabilization around the three axes of movement of the quad copter. Due to the limited resources that are available on the FPGA (Spartan 6 SLX9), different approaches are used to fit the PID controllers into the FPGA. It was investigated whether there can be made use of the high-speed DSP48 slices available in the Spartan 6 or the Xilinx IP Core multiplier. In order to achieve a minimal resource design, the different channels of the FPGA were multiplexed.

In addition to the design of a PID controller, various other system components were designed as well. 
	
	*A PWM generator to control the BLDC engines.
	*A mixing unit, to generate the correct control signal for each engine.
	*An SPI slave interface to communicate with different sensors and make it possible to access the quadcopter's register.
	*A PWM reader in order to read the incomming signal from te remote control.

All hardware was simulated and then tested on an FPGA. Using Matlab and Simulink the necessary calculations and simulations are made before the VHDL implementation was done. In addition to the hardware, the quadcopterframe is fully designed as well. This frame is designed in such a way that it consists of several parts which can be manufactured by a 3D printer.


###Author

Gert-Jan Andries - http://www.gertjanandries.com - info@gertjanandries.com
