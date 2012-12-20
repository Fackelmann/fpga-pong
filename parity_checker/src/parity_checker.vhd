library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity parity_checker is
  port(
    data   : in    std_logic_vector(7 downto 0);
    parity_bit  : out    std_logic
    );
end parity_checker;

architecture RTL of parity_checker is

begin  -- RTL

  parity_check: process (data)
  begin  -- process parity_checker
    parity_bit<= not((data(0) xor data(1)) xor (data(2) xor data(3)) xor (data(4) xor data(5)) xor (data(6) xor data(7)));
  end process parity_check;

end RTL;
