----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2020 11:24:32
-- Design Name: 
-- Module Name: register - Behavioral
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

entity register_reset_n is
    generic (
		C_block_size : integer := 256;
		Max_bits     : integer := 264
	);
	
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           enable : in STD_LOGIC;
           d : in std_logic_vector(Max_bits downto 0);
           q : out std_logic_vector(Max_bits downto 0)
        );  
end register_reset_n;

architecture Behavioral of register_reset_n is
begin
    process(clk, reset_n)
    begin
        if(reset_n = '0') then
            q <= (others => '0');
        elsif(clk'event and clk='1' and enable='1') then
            q <= d;
        end if;
    end process;
end Behavioral;