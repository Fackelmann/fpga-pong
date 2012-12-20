library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller_tb is
end vga_controller_tb;

architecture RTL of vga_controller_tb is

  component vgaController
    generic(
      -- Lines
      VSTs: integer:=521;
      VSTd: integer:= 480;
      VSTpw: integer:=2;
      VSTfp: integer:=10;
      VSTbp: integer:=29;
      -- Clock cycles
      HSTs: integer:=800;
      HSTd: integer:= 640;
      HSTpw: integer:=96;
      HSTfp: integer:=16;
      HSTbp: integer:=48
      );
    port(
      clkin50: in std_logic;
      reset: in std_logic;
      clk25: buffer std_logic;
      hsync: out std_logic;
      vsync: out std_logic;
      bright: out std_logic;
      hcount: buffer std_logic_vector(9 downto 0);  -- 640
      vcount: buffer std_logic_vector(8 downto 0)  -- 480
      );
  end component;

  signal clkin50:  std_logic:='0';
  signal clk25 : std_logic;
  signal    reset:  std_logic;
  signal    hsync:  std_logic;
  signal    vsync:  std_logic;
  signal    bright:  std_logic;
  signal    hcount:  std_logic_vector(9 downto 0);  -- 640
  signal    vcount:  std_logic_vector(8 downto 0);  -- 480

begin  -- RTL

  DUT: vgaController
    port map(
      clkin50=>clkin50,
      reset=>reset,
      clk25=>clk25,
      hsync=>hsync,
      vsync=>vsync,
      bright=>bright,
      hcount=>hcount,
      vcount=>vcount
      );

  -- clock
  process
  begin
    wait for 1 ns;
    clkin50<=not(clkin50);
  end process;

 process
   begin
     reset<='0';
     wait for 40 ns;
     reset<='1';
     wait;
   end process;
end RTL;
