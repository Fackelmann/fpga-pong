library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity vgaController is
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
    clk25   : buffer std_logic;
    hsync   : out    std_logic;
    vsync   : out    std_logic;
    bright  : out    std_logic;
    hcount  : buffer std_logic_vector(9 downto 0);  -- 640
    vcount  : buffer std_logic_vector(8 downto 0)   -- 480
    );
end vgaController;

architecture RTL of vgaController is

--  signal clk25 : std_logic;
  signal enableCounter : unsigned(0 downto 0);
  signal hCounter      : unsigned(9 downto 0);  --800
  signal vCounter      : unsigned(9 downto 0);  --521

  signal vOk : std_logic;
  signal hOk : std_logic;

begin  -- RTL


  -- Bright
  bright <= vOk and hOk;

  clk_divider : process (clkin50, reset)
  begin  -- process clk_divider
    if reset = '0' then                 -- asynchronous reset (active low)
      clk25         <= '0';
      enableCounter <= (others => '0');
    elsif clkin50'event and clkin50 = '1' then  -- rising clock edge
      enableCounter <= enableCounter+1;
      if enableCounter < 1 then
        clk25 <= '1';
      else
        clk25 <= '0';
      end if;
    end if;
  end process clk_divider;

  syncGen : process (clk25, reset)
  begin  -- process hsyncGen
    if reset = '0' then                     -- asynchronous reset (active low)
      hsync    <= '0';
      hCounter <= (others => '0');
      hcount   <= (others => '0');
      hOk      <= '0';
      vcount   <= (others => '0');
      vCounter <= (others => '0');
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
      --Counter
      if hCounter < HSTs then
        hCounter <= hCounter+1;
      else
        hCounter <= (others => '0');
        if vCounter < VSTs then
          vCounter <= vCounter+1;
        else
          vCounter <= (others => '0');
        end if;
        if vCounter < VSTpw then
          vcount <= (others => '0');
          vOk    <= '0';
          vsync  <= '0';
--     Tdisp
        elsif vCounter < (VSTpw+VSTbp+VSTd) and vCounter > (VSTpw+VSTbp-1)then
          vsync  <= '1';
          vOk    <= '1';
          vcount <= std_logic_vector(unsigned(vcount)+1);
        else
          vsync <= '1';
          vOk   <= '0';
        end if;
      end if;
      -- hsync and hcount
      if hCounter < HSTpw then
        hsync  <= '0';
        hOk    <= '0';
        hcount <= (others => '0');
--     Tdisp
      elsif hCounter < (HSTpw+HSTbp+HSTd) and hCounter > (HSTpw+HSTbp-1)then
        hsync  <= '1';
        hOk    <= '1';
        hcount <= std_logic_vector(unsigned(hcount)+1);
      else
        hsync <= '1';
        hOk   <= '0';
      end if;
    end if;
  end process syncGen;

end RTL;
