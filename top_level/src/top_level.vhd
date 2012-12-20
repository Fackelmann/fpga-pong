library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
  port(
    CLOCK_50    : in     std_logic;
    PS2_CLK     : in     std_logic;
    PS2_DAT     : in     std_logic;
    KEY         : in     std_logic_vector(3 downto 0);
    SW          : in     std_logic_vector(17 downto 0);
    LEDR        : out    std_logic_vector(17 downto 0);
    LEDG        : out    std_logic_vector(8 downto 0);
    VGA_R       : out    std_logic_vector(7 downto 0);
    VGA_G       : out    std_logic_vector(7 downto 0);
    VGA_B       : out    std_logic_vector(7 downto 0);
    VGA_HS      : out    std_logic;
    VGA_VS      : out    std_logic;
    VGA_CLK     : buffer std_logic;
    VGA_BLANK_N : out    std_logic;
    VGA_SYNC_N  : out    std_logic
    );
end top_level;

architecture RTL of top_level is

  component vgaController
    generic(
      -- Lines
      VSTs  : integer := 521;
      VSTd  : integer := 480;
      VSTpw : integer := 2;
      VSTfp : integer := 10;
      VSTbp : integer := 29;
      -- Clock cycles
      HSTs  : integer := 800;
      HSTd  : integer := 640;
      HSTpw : integer := 96;
      HSTfp : integer := 16;
      HSTbp : integer := 48
      );
    port(
      clkin50 : in     std_logic;
      reset   : in     std_logic;
      clk25   : out    std_logic;
      hsync   : out    std_logic;
      vsync   : out    std_logic;
      bright  : out    std_logic;
      hcount  : buffer std_logic_vector(9 downto 0);  -- 640
      vcount  : buffer std_logic_vector(8 downto 0)   -- 480
      );
  end component;

  component pong_grapher
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
  end component;

  component pong_kb_dec
    port(
      clkIn     : in  std_logic;
      reset     : in  std_logic;
      keyCode   : in  std_logic_vector (7 downto 0);
      keyValid  : in  std_logic;
      playerOne : out std_logic_vector(1 downto 0);  -- 00 idle 01 up 10 down
      playerTwo : out std_logic_vector(1 downto 0)   -- 00 idle 01 up 10 down
      );
  end component;

  component keyboard_controller
    port(
      clkInKb  : in     std_logic;
      reset    : in     std_logic;
      dataKb   : in     std_logic;
--    parity_check : in std_logic;
      scanCode : buffer std_logic_vector(7 downto 0);
      outErr   : out    std_logic;
      valid    : out    std_logic
      );
  end component;

  signal clkin50 : std_logic := '0';
  signal reset   : std_logic;
  signal hsync   : std_logic;
  signal vsync   : std_logic;
  signal bright  : std_logic;
  signal hcount  : std_logic_vector(9 downto 0);  -- 640
  signal vcount  : std_logic_vector(8 downto 0);  -- 480

  signal playerOne : std_logic_vector(1 downto 0);
  signal playerTwo : std_logic_vector(1 downto 0);

  signal keyCode  : std_logic_vector(7 downto 0);
  signal keyValid : std_logic;

  signal err : std_logic;

begin  -- RTL

  reset <= KEY(0);


  VIDEO_CONTROLLER : vgaController
    port map(
      clkin50 => CLOCK_50,
      reset   => reset,
      clk25   => VGA_CLK,
      hsync   => VGA_HS,
      vsync   => VGA_VS,
      bright  => bright,
      hcount  => hcount,
      vcount  => vcount
      );

  VIDEO_GRAPHER : pong_grapher
    port map(
      clkIn       => VGA_CLK,
      reset       => reset,
      playerOne   => playerOne,
      playerTwo   => playerTwo,
      bright      => bright,
      hcount      => hcount,
      vcount      => vcount,
      VGA_R       => VGA_R,
      VGA_G       => VGA_G,
      VGA_B       => VGA_B,
      VGA_BLANK_N => VGA_BLANK_N,
      VGA_SYNC_N  => VGA_SYNC_N
      );

  KEYBOARD_DECODER : pong_kb_dec
    port map(
      clkIn     => CLOCK_50,
      reset     => reset,
      keyCode   => keyCode,
      keyValid  => keyValid,
      playerOne => playerOne,
      playerTwo => playerTwo
      );

  KEY_CONTROLLER : keyboard_controller
    port map(
      clkInKb  => PS2_CLK,
      reset    => reset,
      dataKb   => PS2_DAT,
      scanCode => keyCode,
      outErr   => err,
      valid    => keyValid
      );

  generator : process (CLOCK_50, reset)
  begin  -- process generator
    if reset = '0' then                 -- asynchronous reset (active low)
      -- Turn off leds
      LEDG <= (others => '0');
      LEDR <= (others => '0');
    elsif CLOCK_50'event and CLOCK_50 = '1' then
      LEDR(17 downto 16) <= playerOne;
      LEDR(3 downto 0)   <= keyCode(7 downto 4);
      LEDG(7 downto 4)   <= keyCode(3 downto 0);
    end if;
  end process generator;
end RTL;
