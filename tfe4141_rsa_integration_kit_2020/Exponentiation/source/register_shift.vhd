----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 23.10.2020 12:18:01
-- Design Name:
-- Module Name: register_shift - Behavioral
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

entity register_shift is
	generic (
		C_block_size : integer := 256
	);

	port (
		clk     : in  std_logic;
		reset_n : in  std_logic;
		enable  : in  std_logic;
		d       : in  std_logic_vector(C_block_size - 1 downto 0);
		q       : out std_logic_vector(C_block_size - 1 downto 0)
	);
end register_shift;

architecture Behavioral of register_shift is
	signal q_i : std_logic_vector(C_block_size - 1 downto 0);
begin
	process (clk, reset_n)
	begin
		if (reset_n = '0') then
			q_i <= (others => '0');
		elsif (clk'event and clk = '1' and enable = '1') then
			q_i <= q_i(C_block_size - 2 downto 0) & d;
		end if;
	end process;
	q <= q_i;
end Behavioral;
