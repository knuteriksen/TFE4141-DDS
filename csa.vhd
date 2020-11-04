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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

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
		Max_bits   : integer := 264
	);
    port (
		--input controll
		a	: in STD_LOGIC_VECTOR (Max_bits-1 downto 0);
		b	: in STD_LOGIC_VECTOR (Max_bits-1 downto 0);
		carry_in	: in STD_LOGIC_VECTOR (Max_bits-1 downto 0);
		
		--output control
		carry_out : out STD_LOGIC_VECTOR (Max_bits downto 0);
        sum : out STD_LOGIC_VECTOR (Max_bits-1 downto 0)
	);
end csa;

architecture Behavioral of csa is

begin
sum <= ((a XOR b) XOR carry_in);
carry_out <= (((a AND b) OR (a AND carry_in)) OR (b AND carry_in)) & '0';

/*twos <= std_logic_vector(signed(not(carry_in(Max_bits-1 downto 0))) + "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");
sum <= '0' & ((a XOR b) XOR twos);
carry_out <= (((a AND b) OR (a AND twos)) OR (b AND twos)) & '0';
a_int <= to_integer(signed(a));
b_int <= to_integer(signed(b));
c_int <= to_integer(signed(carry_in));
c_neg <= -c_int;
c_dot <= std_logic_vector(to_signed(c_neg, c_dot'length));
sum_int <= to_integer(signed(sum)+signed(carry_out));
sum_int <= a_int+b_int-c_int;
sum <= std_logic_vector(to_signed(sum_int, sum'length));*/

end Behavioral;
