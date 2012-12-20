library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_kb_dec_tb is
end pong_kb_dec_tb;

architecture RTL of pong_kb_dec_tb is

  component pong_kb_dec
      port(
    clkIn : in     std_logic;
    reset: in std_logic;
    keyCode: in std_logic_vector (7 downto 0);
    keyValid: in std_logic;
    playerOne: out std_logic_vector(1 downto 0);  -- 00 idle 01 up 10 down
    playerTwo: out std_logic_vector(1 downto 0)  -- 00 idle 01 up 10 down
    );
  end component;

  signal clkIn : std_logic:='0';
  signal reset : std_logic;
  signal keyCode : std_logic_vector(7 downto 0);
  signal keyValid : std_logic;
  signal playerOne : std_logic_vector(1 downto 0);
  signal playerTwo : std_logic_vector(1 downto 0);

begin  -- RTL

  DUT: pong_kb_dec
    port map(
      clkIn => clkIn,
      reset => reset,
      keyCode => keyCode,
      keyValid => keyValid,
      playerOne => playerOne,
      playerTwo => playerTwo
      );

  -- clock
  process
  begin
    wait for 1 ns;
    clkIn<=not(clkIn);
  end process;

  process
  begin  -- process
    reset<='0';
    keyValid<='0';
    wait for 20 ns;
    reset<='1';
    wait for 20 ns;
    keyValid<='1';
    keyCode <= x"15";                   -- press Q
    wait for 2 ns;
    keyValid<='0';
    wait for 50 ns;
    keyValid<='1';
    keyCode <= x"F0";
    wait for 2 ns;
    keyValid<='0';
    wait for 50 ns;
    keyValid<='1';
    keyCode <= x"22";
    wait for 2 ns;
    keyValid<='0';
    wait for 50 ns;
    keyValid<='1';
    keyCode <= x"F0";
    wait for 2 ns;
    keyValid<='0';
    wait for 50 ns;
    keyValid<='1';
    keyCode <= x"15";
    wait for 2 ns;
    keyValid<='0';
    wait for 50 ns;
    keyValid<='1';
    keyCode <= x"1C";
    wait for 50 ns;
    keyValid<='1';
    keyCode <= x"F0";
    wait for 2 ns;
    keyValid<='0';
    wait for 50 ns;
    keyCode <= x"1C";
    wait;
  end process;
end RTL;
