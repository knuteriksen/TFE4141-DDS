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
    enable_reg_X: out std_logic;
    
    state_out : out std_logic_vector(3 downto 0);   -- DEBUG
    counter_out : out unsigned (7 downto 0)         -- DEBUG

    );
end exp_controller;

architecture Behavioral of exp_controller is
    type state is (IDLE, ONE, WRITE_ONE, TWO, WRITE_TWO, THREE, WRITE_THREE, FOUR);
    signal current_state, next_state : state;
    
    signal counter : unsigned(7 downto 0);
   
begin

CombProc : process (input_signal, current_state, squaring_done, multiplication_done)
begin
    if (falling_edge(squaring_done) or falling_edge(multiplication_done)) then
    NULL;
    else
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
        state_out <= "0000"; -- DEBUG
    
    when ONE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            counter <= (others => '0');
            
            mux_P_sel <= '0';       -- Select message
            enable_reg_P <= '1';
        
            mux_X_sel <= "10";      -- Select 1
            enable_reg_X <= '1';
            
            next_state <= TWO;
            
        end if;
        state_out <= "0001"; -- DEBUG

    when WRITE_ONE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            next_state <= TWO;
        end if;
        state_out <= "0001"; -- DEBUG
--    when ONE =>
--        if (input_signal = '0') then
--            next_state <= IDLE;
--        else
--            counter <= (others => '0');
            
--            enable_squaring <= '1';
--            if (squaring_done = '1') then
--                enable_squaring <= '0';
--                valid_out <= '1';
--                output_signal <= '1';
--                next_state <= IDLE;
--            else
--                next_state <= ONE;
--            end if;
--        end if;
--        state_out <= "0001"; -- DEBUG
            
        
    when TWO =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            enable_reg_P <= '0';
            enable_reg_X <= '0';
            if key(TO_INTEGER(counter)) = '1' then
                enable_multiplication <= '1';
                --mux_X_sel <= "01";      -- Select multiplication output
                --enable_reg_X <= '1';
            else
                enable_multiplication <= '0';
                --mux_X_sel <= "00";      -- Select register X output
                --enable_reg_X <= '0';                
            end if;
            enable_squaring <= '1';
            next_state <= WRITE_TWO;
        end if;
        state_out <= "0010"; -- DEBUG
        
        
    when WRITE_TWO =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            if (squaring_done = '1') then               
                if (enable_multiplication = '1') then
                    if (multiplication_done = '1') then  -- Squaring done and multiplication_enable and multiplication done
                        if (to_integer(counter) < C_block_size-2) then
                            counter <= counter + 1;
                            next_state <= TWO;
                        else
                            next_state <= THREE;
                        end if;
                        mux_P_sel <= '1';       -- Select squaring modpro output
                        enable_reg_P <= '1';
                        
                        mux_X_sel <= "01";
                        enable_reg_X <= '1';
                        
                        enable_squaring <= '0';
                        enable_multiplication <= '0';
                    
                    else
                        next_state <= WRITE_TWO;                    
                    end if;
                else -- Squaring done and multiplication_enable = 0
                    if (to_integer(counter) < C_block_size-2) then
                        counter <= counter + 1;
                        next_state <= TWO;
                    else
                        next_state <= THREE;
                    end if;
                    mux_P_sel <= '1';       -- Select squaring modpro output
                    enable_reg_P <= '1';
                    enable_squaring <= '0';
                    enable_multiplication <= '0';                
                end if;
            else
                next_state <= WRITE_TWO;
            end if;
        end if;
        state_out <= "0011"; -- DEBUG
--            if (( (enable_multiplication and multiplication_done) or ( not enable_multiplication and not multiplication_done ) )  and (squaring_done)) then --hardcoded xnor
--                enable_multiplication <= '0';
--                enable_squaring <= '0';
--                enable_reg_P <= '0';
--                enable_reg_X <= '0';
                
--                if (to_integer(counter) < C_block_size-2) then
--                    counter <= counter + 1;
--                    next_state <= TWO;
--                else
--                    next_state <= THREE;
--                end if;
--            else
--                next_state <= WRITE_TWO;
--            end if;


    when THREE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            enable_reg_P <= '0';
            enable_reg_X <= '0';
            if(key(C_block_size-1) = '1') then
                enable_multiplication <= '1';
                next_state <= WRITE_THREE;
                --mux_X_sel <= "01";      -- Select multiplication output
                --enable_reg_X <= '1';
            else
                enable_multiplication <= '0';
                next_state <= FOUR;
                --mux_X_sel <= "00";      -- Select register X output
                --enable_reg_X <= '0';                
            end if;        
        end if;
        state_out <= "0100"; -- DEBUG
        
    when WRITE_THREE =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            if (multiplication_done = '1') then
                enable_multiplication <= '0';
                mux_X_sel <= "01";
                enable_reg_X <= '1';
                next_state <= FOUR;
            else
                next_state <= WRITE_THREE;
            end if;
        end if;
        state_out <= "0101"; -- DEBUG
    
    when FOUR =>
        if (input_signal = '0') then
            next_state <= IDLE;
        else
            enable_reg_P <= '0';
            enable_reg_X <= '0';
            output_signal <= '1';
            mux_X_sel <= "00";  -- Select register X output
            next_state <= IDLE;
        end if;
        next_state <= IDLE;
        state_out <= "0110"; -- DEBUG
    
    when others =>
        next_state <= IDLE;
        state_out <= "1111"; -- DEBUG    
    end case;
    end if;

end process CombProc;

SyncProc : process (reset_n, clk)
begin
    if (reset_n = '0') then
        current_state <= IDLE;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;
end process SyncProc;      

counter_out <= counter;
end Behavioral;