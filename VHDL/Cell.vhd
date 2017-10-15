library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Cell IS 
	GENERIC(Nb:INTEGER:=9);
	PORT(
		CLK, RST_n : IN STD_LOGIC;
		DIN : IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
		SUM_IN: IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
		Bi: IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
		REG_OUT : BUFFER STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
		ADD_OUT: OUT STD_LOGIC_VECTOR(Nb-1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE beh OF Cell IS

	SIGNAL mult: STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
	SIGNAL sum_tmp:	STD_LOGIC_VECTOR(Nb DOWNTO 0);

	COMPONENT adder_n IS
		GENERIC(
			N: INTEGER := 9
		);
		PORT(
			in_a: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			in_b: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			sum_out: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT mult_n IS
	GENERIC(
		N: INTEGER := 9
	);
	PORT(
		in_a: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		in_b: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		mult_out: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT Reg_n IS
	GENERIC(N: INTEGER :=9);
	PORT(
		CLK, RST_n: IN STD_LOGIC;
		DIN: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		DOUT: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
	);
	END COMPONENT; 
BEGIN
	Reg: Reg_n GENERIC MAP(N => Nb)
			   PORT MAP(DIN => DIN, CLK => CLK, RST_n => RST_n, DOUT => REG_OUT);
	
	Product: mult_n GENERIC MAP(N => Nb)
					PORT MAP(in_a => REG_OUT, in_b => Bi, mult_out => mult);
					
	Sum: adder_n GENERIC MAP(N => Nb)
				 PORT MAP(in_a => SUM_IN, in_b => mult, sum_out => ADD_OUT);
				
END beh;	