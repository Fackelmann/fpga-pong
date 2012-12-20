library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_controller_tb is
end keyboard_controller_tb;

architecture RTL of keyboard_controller_tb is

  component keyboard_controller
  port(
    clkInKb : in     std_logic;
    reset   : in     std_logic;
    dataKb   : in std_logic;
--    parity_check : in std_logic;
    scanCode   : out    std_logic_vector(7 downto 0);
    outErr: out std_logic;
    valid   : out    std_logic
    );
  end component;

  signal clkInKb : std_logic:='0';
  signal reset : std_logic;
  signal dataKb : std_logic;
  signal parity_check : std_logic;
  signal scanCode : std_logic_vector(7 downto 0);
  signal outErr : std_logic;
  signal valid : std_logic;

  signal dataToSend : std_logic_vector(15 downto 0):=x"EE57";
  signal isActive : std_logic;

begin  -- RTL

  DUT: keyboard_controller
    port map(
      clkInKb => clkInKb,
      reset => reset,
      dataKb => dataKb,
--      parity_check => parity_check,
      scanCode => scanCode,
      outErr => outErr,
      valid => valid
      );

  -- clock
  process
  begin
    wait for 1 ns;
    clkInKb<=not(clkInKb);
  end process;

  keyboard_input: process (clkInKb, reset)
  begin  -- process keyboard_input
    if reset = '0' then                 -- asynchronous reset (active low)
      dataKb<='1';
    elsif clkInKb'event and clkInKb = '1' then  -- rising clock edge
      if isActive='1' then
        dataKb<=dataToSend(0);
        dataToSend<=std_logic_vector(unsigned(dataToSend) srl 1);
      end if;
    end if;
  end process keyboard_input;

  process
  begin  -- process
    isActive<='0';
    reset<='0';
    wait for 20 ns;
    reset<='1';
    wait for 20 ns;
    isActive<='1';
    wait;
  end process;
end RTL;
