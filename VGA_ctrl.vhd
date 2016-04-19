library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY VGA_ctrl IS 
	GENERIC(
		Bar_H:	INTEGER:=40;  	-- Hpulse
		Bar_W:	INTEGER:=15;  	-- Hpulse
		Bar_A:	INTEGER:=1;  	-- Hpulse
		Bar_I_X:	INTEGER:=10;  	-- Hpulse
		Bar_I_Y:	INTEGER:=10;  -- Hpulse
		Bard_H:	INTEGER:=40;  	-- Hpulse
		Bard_W:	INTEGER:=15;  	-- Hpulse
		Bard_A:	INTEGER:=1;  	-- Hpulse
		Bard_I_X:	INTEGER:=610;  	-- Hpulse
		Bard_I_Y:	INTEGER:=10;  -- Hpulse
		Ball_H:	INTEGER:=20;  	-- Hpulse
		Ball_W:	INTEGER:=20;  	-- Hpulse
		Ball_A:	INTEGER:=1;  	-- Hpulse
		Ball_I_X:	INTEGER:=100;  	-- Hpulse
		Ball_I_Y:	INTEGER:=100);  -- Hpulse
PORT(
	VGA_R : OUT unsigned(9 downto 0);
	VGA_B : OUT unsigned(9 downto 0);
	VGA_G : OUT unsigned(9 downto 0);
	UP, DOWN : IN STD_LOGIC;
	UPd, DOWNd : IN STD_LOGIC;
	PIX_X, PIX_Y : IN integer ;
	VGA_CLK : IN std_logic;
	clk:IN std_logic
);
END VGA_ctrl;
ARCHITECTURE ARCH of VGA_ctrl IS
	TYPE T_LUT IS ARRAY (0 to 1) OF UNSIGNED (9 downto 0);
	SIGNAL MALUT : T_LUT := (
	"0000000000", -- WHITE
	"1111111111" -- BLACK
	);
	SIGNAL posbX : integer := Ball_I_X;
	SIGNAL posbY : integer := Ball_I_Y;
begin
	PROCESS (VGA_CLK,posbX,posbY)
	VARIABLE posX : integer := Bar_I_X;
	VARIABLE posY : integer := Bar_I_Y;
	VARIABLE posdX : integer := Bard_I_X;
	VARIABLE posdY : integer := Bard_I_Y;
	BEGIN
		IF rising_edge(VGA_CLK) THEN
			IF UP='1' THEN
				posY:= posY+5 ;
			ELSIF UPd='1' THEN
				posdY:= posdY+5 ;
			ELSIF DOWN='1' THEN
				posY:= posY-5;
			ELSIF DOWNd='1' THEN
				posdY:= posdY-5;
			END IF;
			IF (PIX_X < 5 or PIX_X >634 or PIX_Y <5 or PIX_Y > 474) THEN 
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= Bar_I_X and PIX_X <=(Bar_I_X+Bar_W)) and (PIX_Y >=posY and PIX_Y <= (posY+Bar_H)) THEN
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= Bard_I_X and PIX_X <=(Bard_I_X+Bard_W)) and (PIX_Y >=posdY and PIX_Y <= (posdY+Bard_H)) THEN
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= posbX and PIX_X <=(posbX+Ball_W)) and (PIX_Y >=posbY and PIX_Y <= (posbY+Ball_H)) THEN
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSE
				VGA_R<= MALUT(0);
				VGA_B<= MALUT(0);
				VGA_G<= MALUT(0);
			END IF;
		END IF;
	END PROCESS;
	PROCESS(clk)
		VARIABLE timeCount : integer:=0;
	   begIN
			if rising_edge(clk)then
				timeCount:=timeCount+1;
			end if;
--			if timeCount=2 then
			--posbX<=posbX+100;
			--posbY<=posbY+100;
			posbX<=posbX+100;
			posbY<=posbY+100;
			--end if;
	end proCESS;
END ARCH;