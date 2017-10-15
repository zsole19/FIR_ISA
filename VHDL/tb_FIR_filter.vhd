library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY tb_FIR_filter IS

END ENTITY;

ARCHITECTURE test OF tb_FIR_filter IS

	SIGNAL CLK, RST_n: STD_LOGIC;
	
BEGIN
	CLK_gen: PROCESS
	BEGIN
		CLK <= '0';
		WAIT FOR 10 ns;
		CLK <= '1';
		WAIT FOR 10 ns;
	END PROCESS;
	
	RST_n_gen: PROCESS
	BEGIN
		RST_n <= '0';
		wait for 15 ns;
		RST_n <= '1';
		wait;
	END PROCESS;
	
	Input_gen:
END test;