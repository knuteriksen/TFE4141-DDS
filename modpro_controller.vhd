----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2020 11:56:02
-- Design Name: 
-- Module Name: modpro_controller - Behavioral
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
-- Ports: snake_case
-- Signals: CamelCase
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

entity modpro_controller is
    generic (
            C_block_size : integer := 256;
            Max_bits     : integer := 264
        );
    Port ( 
    clk : in std_logic;
    reset_n : in std_logic;
    
    input_signal : in std_logic;
    output_signal : out std_logic;
    
    B : in std_logic_vector ( C_block_size-1 downto 0 );

    -- CSA Outputs
    csa_carry_out : in std_logic_vector (Max_bits downto 0 );
    csa_sum : in std_logic_vector (Max_bits-1 downto 0 );
    
    -- Register Outputs
    reg_C_out : in std_logic_vector(Max_bits downto 0);
    reg_S_out : in std_logic_vector(Max_bits downto 0);  
        
    -- MUX select
    mux_CS_sel : out std_logic_vector(1 downto 0);
    mux_A_sel : out std_logic_vector(1 downto 0);
    
    -- Register enable and reset
    enable_reg : out std_logic;
    reset_reg : out std_logic;
    
    
    debug_enable : out std_logic;                   -- DEBUG
    state_out : out std_logic_vector(3 downto 0);   -- DEBUG
    register_sum : out integer;                     -- DEBUG
    csa_total : out integer;                        -- DEBUG
    counter_out : out unsigned (7 downto 0)         -- DEBUG
);
   
end entity modpro_controller;

architecture Behavioral of modpro_controller is
    signal data_in_ready_i:  std_logic;
    signal data_out_valid_i: std_logic;
    
    type state is (IDLE, ONE, TWO_A, WRITE_A, TWO_B, WRITE_B, TWO_C, C_POS, C_NEG, WRITE_C, TWO_D, WRITE_D, THREE);
    signal current_state, next_state : state;
    
    signal counter : unsigned(7 downto 0);
    
begin

    -- Reset from Mod exp
    process(clk, reset_n) begin
        if(reset_n='0') then
            reset_reg <= '0';
        end if;
    end process;
     
    CombProc : process (input_signal, current_state)
    begin
       case (current_state) is
       
       when IDLE =>
           output_signal <= '0';
           if (input_signal = '0') then
               next_state <= IDLE;
           else
               next_state <= ONE;
           end if;
           state_out <= "0000"; -- DEBUG
       
       when ONE =>
           output_signal <= '0';
           if (input_signal = '0') then
               next_state <= IDLE;
           else
               reset_reg <= '0';
               counter <= (others => '0');
               next_state <= TWO_A;
           end if;
           state_out <= "0001"; -- DEBUG
       
       when TWO_A =>
           reset_reg <= '1';
           output_signal <= '0';
           if (input_signal = '0') then
               next_state <= IDLE;
           else
               mux_CS_sel <= "01";     -- Select 2C and 2S
               if(B(C_block_size - 1 - to_integer(counter)) = '1') then
                   mux_A_sel  <= "01"; -- Select A
               else
                   mux_A_sel  <= "00"; -- Select 0
               end if;
               enable_reg <= '1';
               debug_enable <= '1';                                                 -- DEBUG
               next_state <= TWO_B;
               -- next_state <= WRITE_A; - NOT IN USE
           end if; 
           state_out <= "0010";                                                     -- DEBUG
           csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));      -- DEBUG
           register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out)); -- DEBUG
           
           
       /*when WRITE_A =>
         csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));
         register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));
         enable_reg <= '0';
         debug_enable <= '0';
         next_state <= TWO_B;
         state_out <= "0011";*/
          
       
       when TWO_B =>
           output_signal <= '0';
           enable_reg <= '0';
           debug_enable <= '0';                                                     -- DEBUG
           if (input_signal = '0') then
               next_state <= IDLE;
           else
               mux_CS_sel <= "10"; -- Select register C and S
               mux_A_sel  <= "10"; -- Select -N
               next_state <= WRITE_B;

           end if;
           state_out <= "0100";                                                     -- DEBUG
           csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));      -- DEBUG
           register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out)); -- DEBUG
       
       
       when WRITE_B =>
         next_state <= TWO_C;
         csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));        -- DEBUG
         register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));   -- DEBUG
         state_out <= "0101";                                                       -- DEBUG
       
       
       when TWO_C =>
           output_signal <= '0';
           if (input_signal = '0') then
               next_state <= IDLE;
           else
               if (csa_total < 0) then
                   enable_reg <= '0';
                   debug_enable <= '0';                                             -- DEBUG
                   if to_integer(counter) < 255 then
                        counter <= counter + '1';
                        next_state <= C_NEG;
                   else
                        next_state <= THREE;
                   end if;                    
               else
                   enable_reg <= '1';
                   debug_enable <= '1';                                             -- DEBUG
                   next_state <= C_POS;
               end if;
           end if;
           state_out <= "0110";                                                     -- DEBUG
           csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));      -- DEBUG
           register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out)); -- DEBUG 
       
      
       when C_NEG =>
            next_state <= TWO_A;
            enable_reg <= '0';
            debug_enable <= '0';                                                    -- DEBUG
            state_out <= "0111";                                                    -- DEBUG                                                                                                 
            csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));     -- DEBUG
            register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));-- DEBUG
            
      
       when C_POS =>
            next_state <= WRITE_C;
            enable_reg <= '0';                          
            debug_enable <= '0';                                                    -- DEBUG
            csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));     -- DEBUG     
            register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));-- DEBUG
            state_out <= "1000";                                                    -- DEBUG                                                                                                       
                    
      
       when WRITE_C =>
            next_state <= TWO_D;
            enable_reg <= '0';
            debug_enable <= '0';                                                    -- DEBUG
            csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));     -- DEBUG
            register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));-- DEBUG
            state_out <= "1110";                                                    -- DEBUG
            
     
       when TWO_D =>
           output_signal <= '0';
           if (input_signal = '0') then
               next_state <= IDLE;
           else
               if (csa_total < 0) then
                   enable_reg <= '0';
                   debug_enable <= '0';                                             -- DEBUG
               else
                   enable_reg <= '1';
                   debug_enable <= '1';                                             -- DEBUG
               end if;
               if to_integer(counter) < 255 then
                   counter <= counter + '1';
                   -- next_state <= WRITE_D; NOT IN USE
                   next_state <= TWO_A;
                   
               else
                   next_state <= THREE;
               end if;
           end if;
           state_out <= "1001";                                                    -- DEBUG
           csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));     -- DEBUG
           register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));-- DEBUG
       
     
       /*when WRITE_D =>
            csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));
            register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out));
            next_state <= TWO_A;
            enable_reg <= '0';
            debug_enable <= '0';
            state_out <= "1010";*/
       
       when THREE =>
           output_signal <= '1';
           next_state <= IDLE;
           state_out <= "1011";                                                     -- DEBUG
           csa_total <= TO_INTEGER(signed(csa_sum) + signed(csa_carry_out));      -- DEBUG
           register_sum <= TO_INTEGER(signed(reg_S_out) + signed(reg_C_out)); -- DEBUG
           
       when others =>
           output_signal <= '0';
           next_state <= IDLE;
           state_out <= "1111"; -- DEBUG
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

counter_out <= counter;

end Behavioral;
