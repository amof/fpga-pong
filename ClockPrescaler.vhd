library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ClockPrescaler IS PORT
(
	clk_25MHZ : OUT STD_LOGIC;
	GPIO_0: out unsigned(31 downto 0);
	--------SYSTEMS signals
	RST_N : IN STD_LOGIC;
	MCLK : IN STD_LOGIC
	
);

END ClockPrescaler;

ARCHITECTURE ARCH of ClockPrescaler IS
	SIGNAL clk : std_logic;
	
begin

	PROCESS (MCLK, RST_N)
	VARIABLE timeCount : integer;
	
	BEGIN
		IF RST_N='0' THEN
			timeCount := 0;
			clk <='0';
		ELSE
			IF rising_edge(MCLK) THEN
			timeCount := timeCount+1;
			
				IF timeCount = 1 THEN 
					clk <= not clk;
					timeCount:=0;
				END IF;
				
			END IF;
		END IF;
	END PROCESS;	
	
	clk_25MHZ<=clk; 
END ARCH;