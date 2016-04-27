library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY VGA_ctrl IS 
	GENERIC(
	-- Screen Properties
		Screen_Top: INTEGER:=1;
		Screen_Bottom: INTEGER:=478;
		Screen_Left: INTEGER:=1;
		Screen_Right: INTEGER:=635;
	-- Bar Properties
		Bar_H:	INTEGER:=40;  	-- height of the bar
		Bar_W:	INTEGER:=15;  	-- width of the bar
		Bar_Speed:	INTEGER:=1;  	-- bar speed
		Bar_Middle_Delta: INTEGER:=5;  	-- Delta from the middle to this position where ball speed in y=0
	-- LEFT bar
		Bar_Left_X:	INTEGER:=11;  	-- x bar position : fixed
		Bar_Left_Y:	INTEGER:=218;  -- y bar postion : initial
	-- RIGHT bar
		Bar_Right_X:	INTEGER:=610;  -- x bar position : fixed
		Bar_Right_Y:	INTEGER:=218;  -- y bar postion : initial
	-- BALL
		Ball_H:	INTEGER:=10;  	-- height of the ball
		Ball_W:	INTEGER:=10;  	-- width of the ball
		Ball_Speed_X_I:	INTEGER:=5;  	-- ball speed X -> initially move to left
		Ball_Speed_Y_I:	INTEGER:=5;  	-- ball speed Y
		Ball_I_X:	INTEGER:=312;  	-- x ball position
		Ball_I_Y:	INTEGER:=233);  -- y ball postion
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
	VARIABLE barLeft_Y : integer := Bar_Left_Y;
	VARIABLE barRight_Y : integer := Bar_Right_Y;
	VARIABLE ball_X: integer := Ball_I_X;
	VARIABLE ball_Y: integer := Ball_I_Y;
	VARIABLE ballSpeed_X: integer := Ball_Speed_X_I;
	VARIABLE ballSpeed_Y: integer := 0;
	VARIABLE deltaCollision: integer :=0;
	VARIABLE collisionDetected: integer := 0;
	
	BEGIN
		IF rising_edge(MCLK) THEN
		-- BAR MOVEMENT
			IF UP='1' and (barLeft_Y+Bar_H) < Screen_Bottom  THEN -- LEFT BAR
				barLeft_Y:= barLeft_Y+5 ;
			ELSIF DOWN='1' and barLeft_Y > Screen_Top THEN
				barLeft_Y:= barLeft_Y-5;
			END IF;
			IF UPd='1' and (barRight_Y+Bar_H) < Screen_Bottom THEN -- RIGHT BAR
				barRight_Y:= barRight_Y+5 ;
			ELSIF DOWNd='1' and barRight_Y > Screen_Top THEN
				barRight_Y:= barRight_Y-5;
			END IF;
			
		-- BALL MOVEMENT
			IF clk_ball='1' and (ball_X) > Screen_Left and
			(ball_X+Ball_W) < Screen_Right THEN  -- CALCULATE THE NEXT BALL POSITION
				ball_X:=ball_X+ballSpeed_X;
				ball_Y:=ball_Y+ballSpeed_Y;
				collisionDetected:=0;
			ELSIF clk_ball='1' and ((ball_X+Ball_W) >= Screen_Right or ball_X <=Screen_Left) THEN -- GOAL ! RESET !
				ballSpeed_Y:= 0 ; -- RESET BALL SPEED Y
				ball_X:=Ball_I_X; -- RESET BALL POSITION X
				ball_Y:=Ball_I_Y; -- RESET BALL POSITION Y
				IF ballSpeed_X >= 0 THEN
					ballSpeed_X:= -Ball_Speed_X_I; -- RESET BALL SPEED X
				ELSIF ballSpeed_X <0 THEN 
					ballSpeed_X:= Ball_Speed_X_I; -- RESET BALL SPEED X
				END IF;
			END IF;
			
		-- BALL COLLISION with bar
			IF (((ball_X+Ball_W) >= (Bar_Right_X) and (ball_Y+Ball_H) >= (barRight_Y) and (ball_Y) <=(barRight_Y+Bar_H)) or ((ball_X) <= (Bar_Left_X+Bar_W) and (ball_Y+Ball_H) >= (barLeft_Y) and (ball_Y) <=(barLeft_Y+Bar_H))) and collisionDetected = 0 THEN -- RIGHT BAR
				IF (ball_X+Ball_W) >= (Bar_Right_X) THEN -- ball touch bar right
					IF (ball_Y+(Ball_H)/2) >= (barRight_Y+(Bar_H/2))+Bar_Middle_Delta THEN -- BALL UNDER CENTER OF BAR
						deltaCollision:=(ball_Y+(Ball_H/2))-(barRight_Y+(Bar_H/2));
						ballSpeed_Y := Ball_Speed_Y_I+deltaCollision/4;
					ELSIF (ball_Y+(Ball_H)/2) < (barRight_Y+(Bar_H/2))-Bar_Middle_Delta THEN -- IF the ball is above the center of the bar
						deltaCollision:=(barRight_Y+(Bar_H/2))-(ball_Y+(Ball_H/2));
						ballSpeed_Y := -Ball_Speed_Y_I-deltaCollision/4;
					ELSE -- Ball in the center
						deltaCollision:=0;
						ballSpeed_Y := 0;
					END IF ;
					ballSpeed_X:= -Ball_Speed_X_I-(deltaCollision/4);
					
				ELSIF (ball_X) <= (Bar_Left_X+Bar_W) THEN -- ball touch bar left
					IF (ball_Y+(Ball_H)/2) >= (barLeft_Y+(Bar_H/2))+Bar_Middle_Delta THEN -- BALL UNDER CENTER OF BAR
						deltaCollision:=(ball_Y+(Ball_H/2))-(barLeft_Y+(Bar_H/2));
						ballSpeed_Y := Ball_Speed_Y_I+deltaCollision/4;
					ELSIF (ball_Y+(Ball_H)/2) < (barLeft_Y+(Bar_H/2))-Bar_Middle_Delta THEN -- IF the ball is above the center of the bar
						deltaCollision:=(barLeft_Y+(Bar_H/2))-(ball_Y+(Ball_H/2));
						ballSpeed_Y := -Ball_Speed_Y_I-deltaCollision/4;
					ELSE -- ball in the center
						deltaCollision:=0;
						ballSpeed_Y := 0;
					END IF ;	
					ballSpeed_X:= Ball_Speed_X_I+(deltaCollision/4);
				END IF;
				collisionDetected:=1;
			END IF;
			
		-- BALL COLLIDE WITH TOP OR BOTTOM OF SCREEN
			IF ball_Y <= Screen_Top or (ball_Y+Ball_H) >= Screen_Bottom THEN -- TOP OF THE SCREEN
				ballSpeed_Y := - ballSpeed_Y;
			END IF;
			
		-- PRINTING ON THE SCREEN
			IF (PIX_X < Screen_Left or PIX_X >Screen_Right or PIX_Y <Screen_Top or PIX_Y > Screen_Bottom) THEN -- white rectangle
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= Bar_Left_X and PIX_X <=(Bar_Left_X+Bar_W)) and (PIX_Y >=barLeft_Y and PIX_Y <= (barLeft_Y+Bar_H)) THEN -- left bar
				VGA_R<= MALUT(1);
				VGA_B<= MALUT(1);
				VGA_G<= MALUT(1);
			ELSIF (PIX_X >= Bar_Right_X and PIX_X <=(Bar_Right_X+Bar_W)) and (PIX_Y >=barRight_Y and PIX_Y <= (barRight_Y+Bar_H)) THEN -- right bar
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