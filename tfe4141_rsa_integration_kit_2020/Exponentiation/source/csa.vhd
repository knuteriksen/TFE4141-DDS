----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.10.2020 17:15:09
-- Design Name: 
-- Module Name: csa - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity csa is
	generic (
		C_block_size : integer := 256;
		Max_bits     : integer := 264
	);
	port (
		--input controll
		a      : in  std_logic_vector (Max_bits - 1 downto 0);
		b      : in  std_logic_vector (Max_bits - 1 downto 0);
		result : out std_logic_vector (Max_bits - 1 downto 0)

		-------------------- CARRY SAVE ADDER IMPLEMENTATION ----------------------
		-- carry_in	: in STD_LOGIC_VECTOR (Max_bits-1 downto 0);
		-- carry_out : out STD_LOGIC_VECTOR (Max_bits downto 0);
		---------------------------------------------------------------------------
	);
end csa;

architecture Behavioral of csa is
	signal tmp : integer;
begin
	result <= std_logic_vector(signed(a) + signed(b)); -- signed(carry_in));

	-------------------- CARRY SAVE ADDER IMPLEMENTATION ----------------------
	--sum <= ((a XOR b) XOR carry_in);
	--carry_out <= (((a AND b) OR (a AND carry_in)) OR (b AND carry_in)) & '0';
	---------------------------------------------------------------------------
end Behavioral;