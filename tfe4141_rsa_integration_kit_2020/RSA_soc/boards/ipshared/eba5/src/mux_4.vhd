----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 19.10.2020 18:33:47
-- Design Name:
-- Module Name: mux - Behavioral
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
entity mux_4 is
	generic (
		C_block_size : integer := 256;
		Max_bits     : integer := 264

	);
	port (
		--INPUT SIGNALS
		d0     : in  std_logic_vector (Max_bits - 1 downto 0);
		d1     : in  std_logic_vector (Max_bits - 1 downto 0);
		d2     : in  std_logic_vector (Max_bits - 1 downto 0);
		d3     : in  std_logic_vector (Max_bits - 1 downto 0);
		sel    : in  std_logic_vector (1 downto 0);

		--OUTPUT SIGNAL
		output : out std_logic_vector (Max_bits - 1 downto 0)
	);
end mux_4;

architecture Behavioral of mux_4 is
begin

	mux_4_process : process (d0, d1, d2, d3, sel)
	begin
		case sel is
			when "00"   => output   <= d0;
			when "01"   => output   <= d1;
			when "10"   => output   <= d2;
			when others => output   <= d3;
		end case;
	end process mux_4_process;
end Behavioral;
