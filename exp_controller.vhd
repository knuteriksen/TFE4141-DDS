----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2020 20:33:05
-- Design Name: 
-- Module Name: exp_controller - Behavioral
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

entity exp_controller is
    generic (
            C_block_size : integer := 256;
            Max_bits     : integer := 264
        );
    Port ( 
    clk : in std_logic;
    reset_n : in std_logic;
    
    mux_P_sel : out std_logic;
    mux_X_sel : out std_logic_vector(1 downto 0);
    
    enable_multiplication : out std_logic;
    multiplication_done : in std_logic;
    
    enable_squaring : out std_logic;
    squaring_done : in std_logic;
    
    key : in std_logic_vector(C_block_size-1 downto 0);
    
    input_signal : in std_logic;
    output_signal : out std_logic;
    
    enable_reg_P: out std_logic;
    enable_reg_X: out std_logic

    );
end exp_controller;

architecture Behavioral of exp_controller is
    type state is (IDLE, ONE, TWO, WRITE_TWO, THREE, WRITE_THREE, FOUR);
    signal current_state, next_state : state;
    
    signal counter : unsigned(7 downto 0);
   
begin

CombProc : process (input_signal, current_state)
begin
    case (current_state) is
    
    when IDLE =>
        output_signal <= '0';
        enable_multiplication <= '0';
        enable_squaring <= '0';
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            next_state <= ONE;
        end if;
    
    when ONE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            counter <= (others => '0');
            
            mux_P_sel <= '0';       -- Select message
            enable_reg_P <= '1';
        
            mux_X_sel <= "10";      -- Select 1
            enable_reg_P <= '1';
            next_state <= TWO;
        end if;
            
        
    when TWO =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            enable_reg_P <= '0';
            if(key(to_integer(counter)) = '1') then
                enable_multiplication <= '1';
                mux_X_sel <= "01";      -- Select multiplication output
                enable_reg_X <= '1';
            else
                enable_multiplication <= '0';
                mux_X_sel <= "00";      -- Select register X output
                enable_reg_X <= '0';                
            end if;
            enable_squaring <= '1';
            next_state <= WRITE_TWO;
        end if;
        
        
    when WRITE_TWO =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            if (multiplication_done = '1' and squaring_done = '1') then
                enable_multiplication <= '0';
                enable_squaring <= '0';
                enable_reg_P <= '0';
                enable_reg_X <= '0';
                
                if (to_integer(counter) < C_block_size-2) then
                    counter <= counter + 1;
                    next_state <= TWO;
                else
                    next_state <= THREE;
                end if;
            else
                next_state <= WRITE_TWO;
            end if;
        end if;

    when THREE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            if(key(C_block_size-1) = '1') then
                enable_multiplication <= '1';
                mux_X_sel <= "01";      -- Select multiplication output
                enable_reg_X <= '1';
            else
                enable_multiplication <= '0';
                mux_X_sel <= "00";      -- Select register X output
                enable_reg_X <= '0';                
            end if;
            next_state <= WRITE_THREE;        
        end if;
        
    when WRITE_THREE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            if (multiplication_done = '1') then
                enable_multiplication <= '0';
                enable_reg_X <= '0';
                next_state <= FOUR;
            else
                next_state <= WRITE_THREE;
            end if;
        end if;
    
    when FOUR =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            output_signal <= '1';
            mux_X_sel <= "00";  -- Select register X output
            next_state <= IDLE;
        end if;
        next_state <= IDLE;
    
    when others =>
        next_state <= IDLE;    
    end case;

end process CombProc;

SyncProc : process (reset_n, clk)
begin
    if (reset_n = '0') then
        current_state <= IDLE;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;
end process SyncProc;      

end Behavioral;