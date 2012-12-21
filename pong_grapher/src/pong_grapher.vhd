library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_grapher is
  generic(
    SPEED         : integer := 4;                    -- pixels moved per cycle
    PADDLE_HEIGHT : integer := 50;                   -- half height
    PADDLE_WIDTH  : integer := 20
    );
  port(
    clkIn       : in  std_logic;                     -- VGA_CLK
    reset       : in  std_logic;
    playerOne   : in  std_logic_vector(1 downto 0);  -- 00 idle 01 up 10 down
    playerTwo   : in  std_logic_vector(1 downto 0);  -- 00 idle 01 up 10 down
    bright      : in  std_logic;
    hcount      : in  std_logic_vector(9 downto 0);  -- 640
    vcount      : in  std_logic_vector(8 downto 0);  -- 480
    VGA_R       : out std_logic_vector(7 downto 0);
    VGA_G       : out std_logic_vector(7 downto 0);
    VGA_B       : out std_logic_vector(7 downto 0);
    VGA_BLANK_N : out std_logic;
    VGA_SYNC_N  : out std_logic
    );
end pong_grapher;

architecture RTL of pong_grapher is

  signal playerOnePos : std_logic_vector(8 downto 0);
  signal playerTwoPos : std_logic_vector(8 downto 0);
  signal counter      : unsigned(18 downto 0);

begin  -- RTL

  VGA_SYNC_N  <= '0';
  VGA_BLANK_N <= '1';

  graphing : process (clkIn, reset)
  begin  -- process
    if reset = '0' then                     -- asynchronous reset (active low)
      VGA_R <= (others => '0');
      VGA_G <= (others => '0');
      VGA_B <= (others => '0');
    elsif clkIn'event and clkIn = '1' then  -- rising clock edge
      if bright = '1' then
        -- Player 1
        if (unsigned(hcount) < to_unsigned(PADDLE_WIDTH, 9)) and ((unsigned(vcount) > (unsigned(playerOnePos) - to_unsigned(PADDLE_HEIGHT, 8))) and (unsigned(vcount) < (unsigned(playerOnePos) + to_unsigned(PADDLE_HEIGHT, 8)))) then
          VGA_R <= (others => '1');
          VGA_G <= (others => '1');
          VGA_B <= (others => '1');
        elsif (unsigned(hcount) > (620)) and (unsigned(hcount) < 640) and ((unsigned(vcount) > (unsigned(playerTwoPos) - to_unsigned(PADDLE_HEIGHT, 8))) and (unsigned(vcount) < (unsigned(playerTwoPos) + to_unsigned(PADDLE_HEIGHT, 8)))) then
          VGA_R <= (others => '1');
          VGA_G <= (others => '1');
          VGA_B <= (others => '1');
			elsif (unsigned(hcount) > 319) and (unsigned(hcount) < 321) then
          VGA_R <= (others => '1');
          VGA_G <= (others => '1');
          VGA_B <= (others => '1');
        else
          VGA_R <= (others => '0');
          VGA_G <= (others => '0');
          VGA_B <= (others => '0');
        end if;

      else
        VGA_R <= (others => '0');
        VGA_G <= (others => '0');
        VGA_B <= (others => '0');
      end if;
    end if;
  end process;

  update_position : process (clkIn, reset)
  begin  -- process update_position
    if reset = '0' then                     -- asynchronous reset (active low)
      playerOnePos <= std_logic_vector(to_unsigned(240, 9));
      playerTwoPos <= std_logic_vector(to_unsigned(240, 9));
      counter      <= (others => '0');
    elsif clkIn'event and clkIn = '1' then  -- rising clock edge
      if counter < 130000 then
        counter <= counter+1;
      else
        counter <= (others => '0');
        if playerOne = "01" then
          if (unsigned(playerOnePos) > PADDLE_HEIGHT) then
            playerOnePos <= std_logic_vector(unsigned(playerOnePos)-1);
          end if;
        elsif playerOne = "10" then
          if (unsigned(playerOnePos) < (480 - PADDLE_HEIGHT)) then
            playerOnePos <= std_logic_vector(unsigned(playerOnePos)+1);
          end if;
        end if;

        if playerTwo = "01" then
          if (unsigned(playerTwoPos) > PADDLE_HEIGHT) then
            playerTwoPos <= std_logic_vector(unsigned(playerTwoPos)-1);
          end if;
        elsif playerTwo = "10" then
          if (unsigned(playerTwoPos) < (480 - PADDLE_HEIGHT)) then
            playerTwoPos <= std_logic_vector(unsigned(playerTwoPos)+1);
          end if;
        end if;
      end if;
    end if;
  end process update_position;
end RTL;
