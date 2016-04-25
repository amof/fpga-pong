library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Pong is
port
	(
		iCLK_50,iCLK_28				: IN std_logic;
		iKEY								: IN unsigned(3 downto 0);
		oLEDR								: OUT std_logic_vector(17 downto 0);
		oVGA_B							: OUT unsigned(9 downto 0);
		oVGA_G							: OUT unsigned(9 downto 0);
		oVGA_R							: OUT unsigned(9 downto 0);
		oVGA_HS 							: OUT STD_LOGIC;
		oVGA_VS 							: OUT STD_LOGIC;
		oVGA_CLOCK 						: OUT STD_LOGIC;
		oVGA_SYNC_N 					: OUT STD_LOGIC;
		oVGA_BLANK_N 					: OUT STD_LOGIC

		); 
		  
END Pong;

ARCHITECTURE ARCH OF Pong IS


SIGNAL UP, DOWN : STD_logic;
SIGNAL UPd, DOWNd : STD_logic;
SIGNAL RST_N, MCLK : STD_logic;
SIGNAL CPT		: integer := 0;
SIGNAL clk_25MHz:std_LOGIC;
SIGNAL Xcnt, Ycnt:	INTEGER ;
	
----déclaration des composants BUTTONS et SEGMENTS 
COMPONENT VGA 	PORT(
		CLK_VGA					:	IN STD_LOGIC;
		Hsync,Vsync				: 	BUFFER STD_LOGIC;
		BLANK,SYNC				:	BUFFER STD_LOGIC;
		Xcnt, Ycnt				:	OUT INTEGER
		);
END COMPONENT;

COMPONENT VGA_ctrl 	PORT(
	VGA_R : OUT unsigned(9 downto 0);
	VGA_B : OUT unsigned(9 downto 0);
	VGA_G : OUT unsigned(9 downto 0);
	UP, DOWN : IN STD_LOGIC;
	UPd, DOWNd : IN STD_LOGIC;
	PIX_X, PIX_Y : IN integer ;
	VGA_CLK : IN std_logic;
	clk:IN std_LOGIC
);
END COMPONENT;

COMPONENT BUTTONS PORT
(
	BOUTONS : IN unsigned(3 downto 0);
	UP, DOWN : OUT STD_LOGIC;
	UPd, DOWNd : OUT STD_LOGIC;
	--------SYSTEMS signals
	RST_N : IN STD_LOGIC;
	MCLK : IN STD_LOGIC
);
END COMPONENT;

COMPONENT ClockPrescaler PORT
(
	clk_25MHZ : OUT STD_LOGIC;
	--------SYSTEMS signals
	RST_N : IN STD_LOGIC;
	MCLK : IN STD_LOGIC
);
END COMPONENT;



begin

---instantiations composants

U0 : BUTTONS PORT MAP(iKEY, UP, DOWN, UPd, DOWNd, RST_N, MCLK);
U1 : VGA PORT MAP(clk_25MHz, oVGA_HS, oVGA_VS, oVGA_BLANK_N, oVGA_SYNC_N, Xcnt,Ycnt );
U2 : ClockPrescaler PORT MAP(clk_25MHz, RST_N, MCLK);
U3 : VGA_ctrl PORT MAP(oVGA_R, oVGA_B, oVGA_G, UP, DOWN, UPd, DOWNd, Xcnt, Ycnt, MCLK, clk_25MHz);

---affectation des signaux 

MCLK<=iCLK_50;
oVGA_CLOCK<=clk_25MHz;

---créer le RST_N avec un process

	PROCESS (MCLK)
	BEGIN
		IF rising_edge(MCLK) THEN 			
			IF CPT < 1000 THEN
				RST_N <= '0';
				CPT <= CPT + 1;
				oLEDR(0) <= '1';
			ELSE
				RST_N <= '1';
				oLEDR(0) <= '0';
			END IF;		
		END IF;	
	END PROCESS;	
	
end ARCH;