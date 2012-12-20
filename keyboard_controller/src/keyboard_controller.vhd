library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_controller is
  port(
    clkInKb : in     std_logic;
    reset   : in     std_logic;
    dataKb   : in std_logic;
--    parity_check : in std_logic;
    scanCode   : buffer    std_logic_vector(7 downto 0);
    outErr: out std_logic;
    valid   : out    std_logic
    );
end keyboard_controller;

architecture RTL of keyboard_controller is

  component parity_checker
    port (
      data   : in  std_logic_vector(7 downto 0);
      parity_bit : out std_logic);
  end component;

  type StateType is (IDLE,START,B0,B1,B2,B3,B4,B5,B6,B7,STOP,ERR);
  signal State : StateType;
  signal NextState : StateType;

  signal parity_check : std_logic;
  signal capture : std_logic;

begin  -- RTL

  parity_checking: parity_checker
    port map(
      data => scanCode,
      parity_bit => parity_check
      );

  FSM: process (clkInKb, reset)
  begin  -- process FSM
    if reset = '0' then                 -- asynchronous reset (active low)
      State<=IDLE;
    elsif clkInKb'event and clkInKb = '0' then  -- rising clock edge
      State<=NextState;
    end if;
  end process FSM;

  STATES: process (State,dataKb)
  begin  -- process STATES
    capture<='0';
    NextState<=State;
    valid<='0';
    outErr<='0';
    case State is
      when IDLE =>
        if dataKb='0' then
          NextState<=START;
        end if;
      when START =>
        NextState<=B0;
        capture<='1';
      when B0 =>
        NextState<=B1;
        capture<='1';
      when B1 =>
        NextState<=B2;
        capture<='1';
      when B2 =>
        NextState<=B3;
        capture<='1';
      when B3 =>
        NextState<=B4;
        capture<='1';
      when B4 =>
        NextState<=B5;
        capture<='1';
      when B5 =>
        NextState<=B6;
        capture<='1';
      when B6 =>
        NextState<=B7;
        capture<='1';
      when B7 =>
        if parity_check=dataKb then
          NextState<=STOP;
        else
          NextState<=ERR;
        end if;
      when STOP =>
        if dataKb='1' then
          valid<='1';
          NextState<=IDLE;
        else
          NextState<=ERR;
        end if;
      when ERR =>
        outErr<='1';
        NextState<=IDLE;
      when others => null;
    end case;
  end process STATES;

  capture_scanCode: process (clkInKb, reset)
  begin  -- process capture
    if reset = '0' then                 -- asynchronous reset (active low)
      scanCode<=(others=>'0');
    elsif clkInKb'event and clkInKb = '0' then  -- rising clock edge
      if capture='1' then
        scanCode(7)<=dataKb;
        scanCode(6 downto 0)<=scancode(7 downto 1);
      end if;
    end if;
  end process capture_scanCode;
end RTL;
