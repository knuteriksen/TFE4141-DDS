----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2020 17:42:27
-- Design Name: 
-- Module Name: core_controller - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity core_controller is
	generic (
		C_block_size : integer := 256;
		
		CORES        : integer := 10
	);
    Port (
    --input controll
		msgin_valid    : in  std_logic; --Core
		msgin_ready    : out std_logic; --Core

		--input data
		msgin_data     : in  std_logic_vector (C_block_size - 1 downto 0);
		key_e_d        : in  std_logic_vector (C_block_size - 1 downto 0);
		msgin_last     : in  std_logic; -- Core

		--ouput controll
		msgout_ready   : in  std_logic; --Core
		msgout_valid   : out std_logic; --Core
		msgout_last    : out std_logic; -- Core

		--output data
		msgout_data    : out std_logic_vector(C_block_size - 1 downto 0);

		--modulus
		key_n          : in  std_logic_vector(C_block_size - 1 downto 0);

		--utility
		clk            : in  std_logic;
		reset_n        : in  std_logic
    );
end core_controller;

architecture Behavioral of core_controller is
    signal i_msgin_data     : std_logic_vector(C_block_size-1 downto 0);
    signal i_key_e_d        : std_logic_vector(C_block_size-1 downto 0);
    
    signal i_msgin_valid    : std_logic_vector(CORES-1 downto 0);
    signal i_msgin_ready    : std_logic_vector(CORES-1 downto 0);
    signal i_msgout_ready   : std_logic_vector(CORES-1 downto 0);
    signal i_msgout_valid   : std_logic_vector(CORES-1 downto 0);
    signal prev_msgout_valid: std_logic_vector(CORES-1 downto 0);
    
    signal i_msgout_data    : std_logic_vector((((C_block_size)*(CORES))-1) downto 0);
    signal i_key_n          : std_logic_vector(C_block_size-1 downto 0);
    
    signal i_reset_n        : std_logic;
    signal i_msgin_last     : std_logic_vector(CORES-1 downto 0);
    signal i_msgout_last    : std_logic_vector(CORES-1 downto 0);
    
    --- FSM RELATED SIGNALS ---
    
    type state is (FIRST_MESSAGE_IN, INPUT, INPUT_UPDATE, OUTPUT, OUTPUT_UPDATE);
	signal a_current_state, a_next_state, o_current_state, o_next_state  : state;
	
	signal input_counter              : unsigned(CORES-1 downto 0);
	signal output_counter             : unsigned(CORES-1 downto 0);
	
	signal update_input_counter       : std_logic_vector(1 downto 0);
	signal update_output_counter      : std_logic_vector(2 downto 0);
	
begin

    EXP: for i in 0 to CORES-1 generate
        i_exponentiation : entity work.exponentiation
		generic map (
			C_block_size => C_BLOCK_SIZE
		)
		port map (
			message   => i_msgin_data  ,
			key       => i_key_e_d     ,
			valid_in  => i_msgin_valid(i) ,
			ready_in  => i_msgin_ready(i) ,
			ready_out => i_msgout_ready(i),
			valid_out => i_msgout_valid(i),
			result    => i_msgout_data((((C_block_size)*(i+1)) -1) downto (C_block_size*i))     ,
			modulus   => i_key_n         ,
			clk       => clk             ,
			reset_n   => reset_n    ,
			msgin_last=> i_msgin_last(i) ,
			msgout_last=>i_msgout_last(i)
		);
    end generate EXP;
    
    -- 00 Reset
    -- 01 Nothing
    -- 10 Update next
    -- 11 Update now
    
    AssignCombProc : process (a_current_state, msgin_valid, i_msgin_ready)
    begin
        case (a_current_state) is
            when FIRST_MESSAGE_IN =>
                a_next_state <= FIRST_MESSAGE_IN;
                update_input_counter <= "01";
                if i_msgin_ready(to_integer(input_counter)) = '1' then
                    a_next_state <= INPUT;
                end if;
            
            when INPUT  =>
                update_input_counter <= "10";
                a_next_state <= INPUT;
                
                if i_msgin_ready(to_integer(input_counter)) = '1' then
                    if (msgin_valid = '1') then
                        update_input_counter <= "01";
                        a_next_state <= INPUT_UPDATE;
                    end if;
                end if;        
            
            when INPUT_UPDATE =>
                a_next_state <= INPUT;
                
                if (to_integer(input_counter) = CORES-1) then
                    update_input_counter <= "00";
                else
                    update_input_counter <= "11";
                end if;
            
            when OTHERS =>
                a_next_state <= FIRST_MESSAGE_IN;
                update_input_counter <= "00";
            
        
        end case;       
    end process AssignCombProc;
    
    AssignSyncProc : process (reset_n, clk)
	begin
		if (reset_n = '0') then
			-- a_current_state <= INPUT;
			input_counter   <= (others => '0');
		elsif rising_edge(clk) then
			a_current_state <= a_next_state;
			
			msgin_ready <= '0';
            i_msgin_valid(to_integer(input_counter)) <= '0';
            i_msgin_data <= msgin_data;
            i_key_e_d <= key_e_d;
			i_key_n <= key_n;
			if (update_input_counter = "00") then
			     input_counter <= (others => '0');
			
			elsif (update_input_counter = "11") then
			     input_counter <= input_counter + 1;
			
			elsif (update_input_counter = "01") then
			     msgin_ready <= i_msgin_ready(to_integer(input_counter));
			     i_msgin_valid(to_integer(input_counter)) <= msgin_valid;
			     i_msgin_last(to_integer(input_counter)) <= msgin_last;	
			     		     
			 
			end if;
			
		end if;
	end process AssignSyncProc;
    
    -- 000 Reset Counter
    -- 010 Update msgout_valid and not move on
    -- 011 Nothing
    -- 101 Update msgout_valid and move on
    -- 111 Update counter
    
    UpdateCombProc : process (o_current_state, i_msgout_valid, msgout_ready)
    begin
        case (o_current_state) is
            
            when OUTPUT  =>
                update_output_counter <= "101";
                o_next_state <= OUTPUT;
                -- i_msgout_ready(to_integer(output_counter)) <= '0';
                i_msgout_ready <= (others => '0');
                msgout_valid <= i_msgout_valid(to_integer(output_counter));
                msgout_data <= i_msgout_data((((C_block_size)*(to_integer(output_counter)+1)) -1) downto (C_block_size*to_integer(output_counter)));
                msgout_last <= i_msgout_last(to_integer(output_counter));
                
                if (i_msgout_valid(to_integer(output_counter)) = '1' and msgout_ready = '1') then -- Da skal output være lest
                    o_next_state <= OUTPUT_UPDATE;
                    i_msgout_ready(to_integer(output_counter)) <= '1';
                end if;
                
                
            when OUTPUT_UPDATE =>    
                update_output_counter <= "111";
                o_next_state <= OUTPUT;
                -- i_msgout_ready(to_integer(output_counter)) <= '0';
                i_msgout_ready <= (others => '0');
                msgout_valid <= '0';
                msgout_data <= i_msgout_data((((C_block_size)*(to_integer(output_counter)+1)) -1) downto (C_block_size*to_integer(output_counter)));
                msgout_last <= i_msgout_last(to_integer(output_counter));
                
                if (to_integer(output_counter) = CORES-1) then
                    update_output_counter <= "000";
                end if;
            
            when OTHERS =>
                update_output_counter <= "000";
                o_next_state <= OUTPUT;
                -- i_msgout_ready(to_integer(output_counter)) <= '0';
                i_msgout_ready <= (others => '0');
                msgout_valid <= '0';
                msgout_data <= i_msgout_data((((C_block_size)*(to_integer(output_counter)+1)) -1) downto (C_block_size*to_integer(output_counter)));
                msgout_last <= '0';
        
        end case;       
    end process UpdateCombProc;
    
    UpdateSyncProc : process (reset_n, clk)
	begin
		if (reset_n = '0') then
			o_current_state <= OUTPUT;
			output_counter   <= (others => '0');
		
		elsif rising_edge(clk) then
			o_current_state <= o_next_state;
			
			if (update_output_counter = "000") then
			     output_counter <= (others => '0');    			     
			elsif (update_output_counter = "111") then
			     output_counter <= output_counter + 1;		
			end if;
						
		end if;
	end process UpdateSyncProc;

end Behavioral;