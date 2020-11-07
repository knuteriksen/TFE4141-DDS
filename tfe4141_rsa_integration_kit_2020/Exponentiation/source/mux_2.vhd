----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2020 19:48:19
-- Design Name: 
-- Module Name: mux_2 - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux_2 is
generic (
		C_block_size : integer := 256;
		Max_bits     : integer := 264

	);
    port (
		--input controll
		d0	: in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
		d1	: in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
		sel	: in std_logic;
		
		--output control
		output : out STD_LOGIC_VECTOR (C_block_size-1 downto 0)
		);
end mux_2;

architecture Behavioral of mux_2 is

begin
mux_2_process : process(d0,d1,sel)
begin
    case sel is
        when '0' => output <= d0;
        when '1' => output <= d1;
        when others => output <= (others => '0');
    end case;
end process mux_2_process;
end Behavioral;
