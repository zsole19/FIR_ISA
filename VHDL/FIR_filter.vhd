LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY FIR_filter IS
GENERIC(
		N: INTEGER := 8; --Filter Order
		Nb: INTEGER := 9 --# of bits
		);
PORT(
	CLK, RST_n:	IN STD_LOGIC;
	VIN:	IN STD_LOGIC;
	DIN : IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
	Coeffs:	IN	STD_LOGIC_VECTOR(((N+1)*Nb)-1 DOWNTO 0); --# of coeffs IS N+1
	VOUT: OUT STD_LOGIC;
	DOUT:	OUT STD_LOGIC_VECTOR(Nb-1 DOWNTO 0)
	
);
END ENTITY;

ARCHITECTURE beh OF FIR_filter IS
	
	TYPE sig_array IS ARRAY (N DOWNTO 0) OF STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
	
	SIGNAL Bi: sig_array; -- there IS N instead of N-1 becaUSE the coeffs are N+1
	SIGNAL REG_OUT_array: sig_array;
	SIGNAL SUM_OUT_array: sig_array;
	
	SIGNAL DIN_mult: STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
	SIGNAL VIN_Delay: STD_LOGIC_VECTOR(N DOWNTO 0);
	
	COMPONENT Cell IS 
		GENERIC(Nb:INTEGER:=9);
		PORT(
			CLK, RST_n : IN STD_LOGIC;
			DIN : IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
			SUM_IN: IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
			Bi: IN STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
			REG_OUT : BUFFER STD_LOGIC_VECTOR(Nb-1 DOWNTO 0);
			ADD_OUT: OUT STD_LOGIC_VECTOR(Nb-1 DOWNTO 0)
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

BEGIN
	-- DOUT Generation
	
	Coeff_gen: FOR i IN 0 to N GENERATE
		Bi(i) <= Coeffs(((i+1)*Nb)-1 DOWNTO (i*Nb));
	END GENERATE;
	
	DIN_mult_gen: mult_n GENERIC MAP(N => Nb)
						 PORT MAP(in_a => DIN, in_b => Bi(0), mult_out => DIN_mult);
	
	REG_OUT_array(0) <= DIN;
	SUM_OUT_array(0) <= DIN_mult;
	
	Cells_gen: FOR j IN 0 to N-1 GENERATE
			Single_cell: Cell GENERIC MAP(Nb => 9)
						PORT MAP(CLK => CLK, RST_n => RST_n, DIN => REG_OUT_array(j),
						SUM_IN => SUM_OUT_array(j), Bi => Bi(j+1), REG_OUT => REG_OUT_array(j+1),
						ADD_OUT => SUM_OUT_array(j+1));
	END GENERATE;
	
	DOUT <= SUM_OUT_array(N);
	
	-- VOUT Generation 
	
	VIN_Delay(0) <= VIN;

	FFS_gen: FOR k IN 0 TO N-1 GENERATE
			Single_cell: Reg_n GENERIC MAP(N => 1)
				   PORT MAP(CLK => CLK, RST_n => RST_n, DIN => VIN_Delay(k DOWNTO k), DOUT => VIN_Delay(k+1 DOWNTO k+1));
	END GENERATE;
	
	VOUT <= VIN_Delay(N);
	
END beh;