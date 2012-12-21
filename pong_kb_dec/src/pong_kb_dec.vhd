library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_kb_dec is
  port(
    clkIn     : in  std_logic;
    reset     : in  std_logic;
    keyCode   : in  std_logic_vector (7 downto 0);
    keyValid  : in  std_logic;
    playerOne : out std_logic_vector(1 downto 0);  -- 00 idle 01 up 10 down
    playerTwo : out std_logic_vector(1 downto 0)   -- 00 idle 01 up 10 down
    );
end pong_kb_dec;

architecture RTL of pong_kb_dec is

  type   StateType is (IDLEONE, IDLETWO, PRSSONE, PRSSTWO, RELONE, RELTWO);
  signal StateOne, StateTwo         : StateType;
  signal NextStateOne, NextStateTwo : StateType;

  signal combPlayerOne : std_logic_vector(1 downto 0);
  signal combPlayerTwo : std_logic_vector(1 downto 0);
  signal prevValid     : std_logic;

begin  -- RTL


  STATESONE : process (StateOne, keyValid, prevValid, keyCode)
  begin  -- process STATESONE
    NextStateOne  <= StateOne;
    combPlayerOne <= "11";                      -- mantain by default
    if keyValid = '1' and prevValid = '0' then  -- We need a valid key press
      case StateOne is
        when IDLEONE =>
          NextStateOne <= PRSSONE;
          if keyCode = x"15" then
            combPlayerOne <= "01";              --up
          elsif keyCode = x"1C" then
            combPlayerOne <= "10";              --down
          else
            combPlayerOne <= "00";              --idle
            NextStateOne  <= IDLEONE;
          end if;
        when PRSSONE =>
          if keyCode = x"F0" then
            NextStateOne <= RELONE;
          end if;
        when RELONE =>
          if (keyCode = x"15") or (keyCode = x"1C") then
            combPlayerOne <= "00";              --idle
            NextStateOne  <= IDLEONE;
          else
            NextStateOne <= PRSSONE;
          end if;
        when others => null;
      end case;
    end if;
  end process STATESONE;


  STATESTWO : process (StateTwo, keyValid, prevValid, keyCode)
  begin  -- process STATESTWO
    NextStateTwo  <= StateTwo;
    combPlayerTwo <= "11";                      -- mantain by default
    if keyValid = '1' and prevValid = '0' then  -- We need a valid key press
      case StateTwo is
        when IDLETWO =>
          NextStateTwo <= PRSSTWO;
          if keyCode = x"44" then
            combPlayerTwo <= "01";              --up
          elsif keyCode = x"4B" then
            combPlayerTwo <= "10";              --down
          else
            combPlayerTwo <= "00";              --idle
            NextStateTwo  <= IDLETWO;
          end if;
        when PRSSTWO =>
          if keyCode = x"F0" then
            NextStateTwo <= RELTWO;
          end if;
        when RELTWO =>
          if (keyCode = x"44") or (keyCode = x"4B") then
            combPlayerTwo <= "00";              --idle
            NextStateTwo  <= IDLETWO;
          else
            NextStateTwo <= PRSSTWO;
          end if;
        when others => null;
      end case;
    end if;
  end process STATESTWO;

  process (clkIn, reset)
  begin  -- process
    if reset = '0' then                     -- asynchronous reset (active low)
      playerOne <= "00";
      playerTwo <= "00";
      prevValid <= '0';
      StateOne  <= IDLEONE;
      StateTwo  <= IDLETWO;
    elsif clkIn'event and clkIn = '1' then  -- rising clock edge
      prevValid <= keyValid;
      StateOne  <= NextStateOne;
      StateTwo  <= NextStateTwo;
      if combPlayerOne = "10" then
        playerOne <= "10";
      elsif combPlayerOne = "01" then
        playerOne <= "01";
      elsif combPlayerOne = "00" then
        playerOne <= "00";
      end if;
      if combPlayerTwo = "10" then
        playerTwo <= "10";
      elsif combPlayerTwo = "01" then
        playerTwo <= "01";
      elsif combPlayerTwo = "00" then
        playerTwo <= "00";
      end if;
    end if;
  end process;
end RTL;
