----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.10.2020 21:16:43
-- Design Name: 
-- Module Name: modpro_tb - Behavioral
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

entity modpro_tb is
--  Port ( );
generic (
        C_block_size : integer := 256;
        Max_bits     : integer := 264
);
end modpro_tb;

architecture Behavioral of modpro_tb is
signal clk : std_logic := '0';
signal reset_n : std_logic := '0';
signal A, B, N_dot, C_reg, S_reg : std_logic_vector( C_block_size -1 downto 0);
signal controller_enable : std_logic := '0';
signal modpro_done : std_logic;
constant CLK_PERIOD : time := 20ns;
signal data_out: std_logic_vector(C_block_size-1 downto 0);

begin

modpro : entity work.modpro
    port map(
    A => A,
    B => B,
    N_dot => N_dot,
    clk => clk,
    reset_n => reset_n,
    
    enable_modpro => controller_enable,
    modpro_done => modpro_done,
    
    --Output control
    data_out => data_out
    );
    
    reset_n <= '1';
    
    clk <= not clk after CLK_PERIOD/2;
    
stimulus: process
    begin
    reset_n <= '0';
    wait for 2*CLK_PERIOD;
    reset_n <= '1';
    wait for 10*CLK_PERIOD;
    A     <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"10001100100";  -- 1124
    B     <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"01011110110";  -- 758
    N_dot <= "1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"&"101100000001";  -- -1279
    wait for 10*CLK_PERIOD;
    controller_enable <= '1';
    wait for 10*CLK_PERIOD;

     wait until modpro_done='1';
     controller_enable <= '0';
     wait;
    end process stimulus;
end Behavioral;
