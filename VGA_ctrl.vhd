library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY VGA_ctrl IS 
	GENERIC(
	-- LEFT bar
		Bar_H:	INTEGER:=40;  	-- height of the bar
		Bar_W:	INTEGER:=15;  	-- width of the bar
		Bar_A:	INTEGER:=1;  	-- bar speed
		Bar_I_X:	INTEGER:=10;  	-- x bar position 
		Bar_I_Y:	INTEGER:=220;  	-- y bar postion
	-- RIGHT bar
		Bard_H:	INTEGER:=40;  	-- height of the bar
		Bard_W:	INTEGER:=15;  	-- width of the bar
		Bard_A:	INTEGER:=1;  	-- bar speed
		Bard_I_X:	INTEGER:=610;  	-- x bar position
		Bard_I_Y:	INTEGER:=220;  -- y bar postion
	-- BALL
		Ball_H:	INTEGER:=10;  	-- height of the ball
		Ball_W:	INTEGER:=10;  	-- width of the ball
		Ball_Speed_X_I:	INTEGER:=-5;  	-- bar speed X
		Ball_Speed_Y_I:	INTEGER:=0;  	-- bar speed Y
		Ball_I_X:	INTEGER:=220;  	-- x bar position
		Ball_I_Y:	INTEGER:=220);  -- y bar postion
PORT(
	VGA_R : OUT unsigned(9 downto 0);
	VGA_B : OUT unsigned(9 downto 0);
	VGA_G : OUT unsigned(9 downto 0);
	UP, DOWN : IN STD_LOGIC;
	UPd, DOWNd : IN STD_LOGIC;
	PIX_X, PIX_Y : IN integer ;
	MCLK : IN std_logic;
	clk_ball:IN std_logic
);
END VGA_ctrl;
ARCHITECTURE ARCH of VGA_ctrl IS
	TYPE T_LUT IS ARRAY (0 to 1) OF UNSIGNED (9 downto 0);
	SIGNAL MALUT : T_LUT := (
	"0000000000", -- WHITE
	"1111111111" -- BLACK
	);
	SIGNAL ball_clk : STD_logic;
begin
	PROCESS (MCLK, UP, UPd, DOWN, DOWNd, clk_ball)
	VARIABLE barLeft_X : integer := Bar_I_X;
	VARIABLE barLeft_Y : integer := Bar_I_Y;
	VARIABLE barRight_X : integer := Bard_I_X;
	VARIABLE barRight_Y : integer := Bard_I_Y;
	VARIABLE ball_X: integer := Ball_I_X;
	VARIABLE ball_Y: integer := Ball_I_Y;
	VARIABLE ballSpeed_X: integer := Ball_Speed_X_I;
	VARIABLE ballSpeed_Y: integer := Ball_Speed_Y_I;
	
	BEGIN
		IF rising_edge(MCLK) THEN
		-- BAR MOVES
			IF UP='1' and (barLeft_Y+Bar_H) < 474  THEN
				barLeft_Y:= barLeft_Y+5 ;
			ELSIF DOWN='1' and barLeft_Y > 5 THEN
				barLeft_Y:= barLeft_Y-5;
			END IF;
			IF UPd='1' and (barRight_Y+Bard_H) < 474 THEN
				barRight_Y:= barRight_Y+5 ;
			ELSIF DOWNd='1' and barRight_Y > 5 THEN
				barRight_Y:= barRight_Y-5;
			END IF;
		-- BALL
			IF clk_ball='1' and (ball_X+Ball_W) < 634 and ballSpeed_X >0 THEN
				ball_X:=ball_X+ballSpeed_X;
			ELSIF clk_ball='1' and (ball_X+Ball_W) >= 634 and ballSpeed_X >0 THEN
				ballSpeed_X:= -ballSpeed_X;
			ELSIF clk_ball='1' and (ball_X) > 5 and ballSpeed_X < 0 THEN
				ball_X:=ball_X+ballSpeed_X;
			ELSIF clk_ball='1'and (ball_X) <= 5 and ballSpeed_X <0 THEN
				ballSpeed_X:= -ballSpeed_X;
			END IF;
			---ball_Y:=ball_Y+Ball_Speed_Y;
		-- PRINTING ON THE SCREEN
			IF (PIX_X < 5 or PIX_X >634 or PIX_Y <5 or PIX_Y > 474) THEN -- white rectangle
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= Bar_I_X and PIX_X <=(Bar_I_X+Bar_W)) and (PIX_Y >=barLeft_Y and PIX_Y <= (barLeft_Y+Bar_H)) THEN -- left bar
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= Bard_I_X and PIX_X <=(Bard_I_X+Bard_W)) and (PIX_Y >=barRight_Y and PIX_Y <= (barRight_Y+Bard_H)) THEN -- right bar
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= ball_X and PIX_X <=(ball_X+Ball_W)) and (PIX_Y >=ball_Y and PIX_Y <= (ball_Y+Ball_H)) THEN -- ball
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

END ARCH;