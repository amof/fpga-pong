library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY BUTTONS IS PORT
(
	BOUTONS : IN unsigned(3 downto 0);
	UP, DOWN : OUT STD_LOGIC;
	UPd, DOWNd : OUT STD_LOGIC;
	--------SYSTEMS signals
	RST_N : IN STD_LOGIC;
	MCLK : IN STD_LOGIC
);
END BUTTONS;
ARCHITECTURE ARCH of BUTTONS IS
SIGNAL PREC_BOUTON0 : STD_LOGIC;
SIGNAL PREC_BOUTON1 : STD_LOGIC;
SIGNAL PREC_BOUTON2 : STD_LOGIC;
SIGNAL PREC_BOUTON3 : STD_LOGIC;
begin
	PROCESS (MCLK, RST_N)
	VARIABLE timeCount : integer;
	BEGIN
		IF RST_N='0' THEN
			UP<='0';
			DOWN<='0';
			UPd<='0';
			DOWNd<='0';
			timeCount := 0;
			PREC_BOUTON0<='0';
			PREC_BOUTON1<='0';
			PREC_BOUTON2<='0';
			PREC_BOUTON3<='0';
		ELSE
			IF rising_edge(MCLK) THEN
			timeCount := timeCount+1;
				IF timeCount = 2500000 THEN 
					timeCount:=0;
					PREC_BOUTON0 <= BOUTONS(0);
					PREC_BOUTON1 <= BOUTONS(1);
					PREC_BOUTON2 <= BOUTONS(2);
					PREC_BOUTON3 <= BOUTONS(3);
					IF  BOUTONS(0)='0' AND (PREC_BOUTON0 = '0' or PREC_BOUTON0 = '1') THEN
						UPd<='1';
					END IF;
					IF  (BOUTONS(1)='0')  AND (PREC_BOUTON1 = '0' or PREC_BOUTON1 = '1') THEN
						DOWNd<='1';
					END IF;
					IF  BOUTONS(2)='0' AND (PREC_BOUTON2 = '0' or PREC_BOUTON2 = '1') THEN
						UP<='1';
					END IF;
					IF  (BOUTONS(3)='0')  AND (PREC_BOUTON3 = '0' or PREC_BOUTON3 = '1') THEN
						DOWN<='1';
					END IF;
				ELSE
					UP<='0';
					DOWN<='0';
					UPd<='0';
					DOWNd<='0';
				END IF;
			END IF;
		END IF;
	END PROCESS;	
END ARCH;