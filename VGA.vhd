LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VGA IS
-----SYNC PARAMETERS FOR 640x480 VGA DISPLAY (25MHz clock)-----
	GENERIC(
		Ha:	INTEGER:=96;  	-- Hpulse
		Hb:	INTEGER:=143; 	-- Hpulse+Hbp
		Hc:	INTEGER:=783; 	-- Hpulse+Hbp+Hactive
		Hd:	INTEGER:=800; 	-- Hpulse+Hbp+Hactive+Hfp
		Va:	INTEGER:=2;		-- Vpulse
		Vb:	INTEGER:=35;	-- Vpulse+Vbp
		Vc:	INTEGER:=515;	-- Vpulse+Vbp+Vactive 
		Vd:	INTEGER:=525); -- Vpulse+Vbp+Vactive+Vfp
	PORT(
		CLK_VGA					:	IN STD_LOGIC;
		Hsync,Vsync				: 	BUFFER STD_LOGIC;
		BLANK,SYNC				:	BUFFER STD_LOGIC;
		Xcnt, Ycnt				:	OUT INTEGER
		);
END VGA;

ARCHITECTURE MAIN OF VGA IS
	SIGNAL Hactive, Vactive: STD_LOGIC;
BEGIN
---------------------------------
--      CONTROL GENERATOR      --
---------------------------------
-- Static signals for DACs:	
BLANK <= Hactive AND Vactive;
SYNC <= '0';
-- Horizontal signal generation
PROCESS(CLK_VGA)
	VARIABLE Hcnt:	INTEGER RANGE 0 TO Hd;
BEGIN
IF RISING_EDGE(CLK_VGA) THEN
	Hcnt:=Hcnt+1;
	IF (Hcnt=Ha)THEN
		Hsync<='1';
	ELSIF(Hcnt=Hb) THEN
		Hactive<='1';
	ELSIF(Hcnt=Hc) THEN
		Hactive<='0';
	ELSIF(Hcnt=Hd) THEN
		Hsync<='0';
		Hcnt:=0;
	END IF;
	IF (Hcnt>=Hb AND Hcnt<Hc) THEN
		Xcnt<=Hcnt-Hb;						-- Xcnt 0 --> 639
	ELSE
		Xcnt<=0;
	END IF;
END IF;
END PROCESS;
--	Vertical signal generation 
PROCESS(Hsync)
	VARIABLE Vcnt:	INTEGER RANGE 0 TO Vd;
BEGIN
IF FALLING_EDGE(Hsync) THEN
	Vcnt:=Vcnt+1;
	IF (Vcnt=Va)THEN
		Vsync<='1';
	ELSIF(Vcnt=Vb) THEN
		Vactive<='1';
	ELSIF(Vcnt=Vc) THEN
		Vactive<='0';
	ELSIF(Vcnt=Vd) THEN
		Vsync<='0';
		Vcnt:=0;
	END IF;
	IF (Vcnt>=Vb AND Vcnt<Vc) THEN
		Ycnt<=Vcnt-Vb;						-- Ycnt 0 --> 479
	ELSE
		Ycnt<=0;
	END IF;
END IF;
END PROCESS;
END MAIN;