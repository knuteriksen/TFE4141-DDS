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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity twos_complement is
    generic (
            C_block_size : integer := 256
        );
    port (
        din : in std_logic_vector (C_block_size-1 downto 0);
        dout : out std_logic_vector (C_block_size-1 downto 0)
    );
end twos_complement;
    
architecture Behavioral of twos_complement is

begin
    dout <= std_logic_vector(signed(not(din(C_block_size-1 downto 0))) + "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");
end Behavioral;
