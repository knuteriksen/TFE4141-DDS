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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux_3 is
generic (
		C_block_size : integer := 256;
		Max_bits     : integer := 264

	);
    port (
		--input controll
		d0	: in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
		d1	: in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
		d2	: in STD_LOGIC_VECTOR (C_block_size-1 downto 0);
		sel	: in STD_LOGIC_VECTOR (1 downto 0);
		
		--output control
		output : out STD_LOGIC_VECTOR (C_block_size-1 downto 0)
		
		
		
	);
end mux_3;

architecture Behavioral of mux_3 is
begin

mux_3_process : process(d0,d1,d2,sel)
begin
    case sel is
        when "00" => output <= d0;
        when "01" => output <= d1;
        when "10" => output <= d2;
        when others => output <= (others => '0');
    end case;
end process mux_3_process;
end Behavioral;