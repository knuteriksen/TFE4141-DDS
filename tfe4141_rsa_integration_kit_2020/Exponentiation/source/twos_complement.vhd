----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06.11.2020 16:18:46
-- Design Name:
-- Module Name: twos_complement - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity twos_complement is
	generic (
		C_block_size : integer := 256
	);
	port (
		din  : in  std_logic_vector (C_block_size downto 0);
		dout : out std_logic_vector (C_block_size + 1 downto 0)
	);
end twos_complement;

architecture Behavioral of twos_complement is

begin
	dout <= '1' & std_logic_vector(signed((not din)) + 1);
end Behavioral;
