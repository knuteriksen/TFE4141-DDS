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
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
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
	port (
		clk                   : in  std_logic;
		reset_n               : in  std_logic;

		ready_out             : in  std_logic;
		ready_in              : out std_logic;
		valid_in              : in  std_logic;

		mux_P_sel             : out std_logic;
		mux_X_sel             : out std_logic_vector(1 downto 0);

		enable_multiplication : out std_logic;
		multiplication_done   : in  std_logic;

		enable_squaring       : out std_logic;
		squaring_done         : in  std_logic;

		key                   : in  std_logic_vector(C_block_size - 1 downto 0);

		output_signal         : out std_logic;

		enable_reg_P          : out std_logic;
		enable_reg_X          : out std_logic;
		
		msgout_last           : out std_logic;
		msgin_last            : in std_logic
	);
end exp_controller;

architecture Behavioral of exp_controller is
	type state is (IDLE, ONE, TWO, WRITE_TWO, THREE, WRITE_THREE, FOUR);
	signal current_state, next_state : state;
	signal counter                   : unsigned(7 downto 0);
	signal update_msgout_last             : std_logic;
	signal i_counter                 : std_logic_vector(1 downto 0);
	signal prev_enable_multiplication: std_logic;

begin

	CombProc : process (valid_in, ready_out, current_state, squaring_done, multiplication_done)
	begin
			case (current_state) is

				when IDLE =>
				    mux_P_sel <= '1';
				    mux_X_sel <= "00";
				    enable_reg_P <= '0';
				    enable_reg_X <= '0';
				    enable_multiplication <= '0';
					enable_squaring       <= '0';
                    i_counter <= "00"; -- Reset counter
                    output_signal         <= '0';
                    
					if valid_in = '1' then
						next_state    <= ONE;
						ready_in      <= '0';
						update_msgout_last <= '1';    
					else
						next_state <= IDLE;
						ready_in <= '1';
						update_msgout_last <= '0';
					end if;


				when ONE =>
                            ready_in     <= '0';
                            mux_P_sel    <= '0'; -- Select message
                            mux_X_sel    <= "10"; -- Select 1
                            enable_reg_P <= '1';
                            enable_reg_X <= '1';
                            output_signal         <= '0';
                            enable_multiplication <= '0';
					        enable_squaring       <= '0';
                            i_counter <= "01"; -- Do nothing with counter
                            update_msgout_last <= '0';
                            
                            next_state   <= TWO;


				when TWO =>
				        mux_P_sel <= '0';
				        mux_X_sel     <= "10"; -- Select register X output
						enable_reg_P <= '0';
						enable_reg_X <= '0';
						output_signal         <= '0';
						enable_squaring <= '1';
						i_counter <= "01"; -- Do nothing with counter
						enable_multiplication <= '0';
						ready_in      <= '0';
						next_state      <= WRITE_TWO;
						update_msgout_last <= '0';
						
						if key(TO_INTEGER(counter)) = '1' then
							enable_multiplication <= '1';
						end if;				

				
				when WRITE_TWO =>
				        mux_P_sel             <= '1'; -- Select squaring modpro output
				        mux_X_sel             <= "00";  -- Select register X output
				        enable_reg_P          <= '0';
				        enable_reg_X          <= '0';
				        output_signal         <= '0';
				        enable_squaring       <= '1';
				        i_counter <= "01"; -- Do nothing with counter
				        ready_in      <= '0';
				        update_msgout_last <= '0';
				        
				        if (prev_enable_multiplication = '1') then
				            enable_multiplication <= '1';
				        else
				            enable_multiplication <= '0';
				        end if;
				        
						if (squaring_done = '1') then
							if (prev_enable_multiplication = '1') then
								if (multiplication_done = '1') then -- Squaring done and multiplication_enable and multiplication done
									mux_P_sel             <= '1'; -- Select squaring modpro output
									enable_reg_P          <= '1';
									mux_X_sel             <= "01";
									enable_reg_X          <= '1';
									enable_squaring       <= '0';
									enable_multiplication <= '0';
									if (to_integer(counter) < C_block_size - 2) then
										i_counter <= "11"; -- Increment counter
										next_state <= TWO;
									else
										next_state <= THREE;
									end if;

								else
									next_state <= WRITE_TWO;
								end if;

							else -- Squaring done and multiplication_enable = 0
								if (to_integer(counter) < C_block_size - 2) then
									i_counter <= "11"; -- Increment counter
									next_state <= TWO;
								else
									next_state <= THREE;
								end if;
								mux_P_sel             <= '1'; -- Select squaring modpro output
								enable_reg_P          <= '1';
								enable_squaring       <= '0';
								enable_multiplication <= '0';
							end if;
						else
							next_state <= WRITE_TWO;
						end if;                  			

				when THREE =>
				        mux_P_sel             <= '1'; -- Select squaring modpro output
				        mux_X_sel     <= "00"; -- Select register X output
						enable_reg_P <= '0';
						enable_reg_X <= '0';
						output_signal         <= '0';
						enable_squaring <= '0';
						i_counter <= "01"; -- Do nothing with counter
						ready_in      <= '0';
						update_msgout_last <= '0';

						if (key(C_block_size - 1) = '1') then
							enable_multiplication <= '1';
							next_state            <= WRITE_THREE;

						else
							enable_multiplication <= '0';
							next_state            <= FOUR;
						end if;

				when WRITE_THREE =>
				        mux_P_sel             <= '1'; -- Select squaring modpro output
				        enable_reg_P <= '0';
				        enable_reg_X <= '0';
				        output_signal         <= '0';
				        enable_squaring <= '0';
				        i_counter <= "01"; -- Do nothing with counter
				        ready_in      <= '0';
				        update_msgout_last <= '0';

						if (multiplication_done = '1') then
							enable_multiplication <= '0';
							mux_X_sel             <= "01";
							enable_reg_X          <= '1';
							next_state            <= FOUR;
						else
						    enable_multiplication <= '1';
							mux_X_sel             <= "01";
							enable_reg_X          <= '0';
							next_state            <= WRITE_THREE;
						end if;



				when FOUR =>
				        mux_P_sel             <= '1'; -- Select squaring modpro output
				        mux_X_sel     <= "00"; -- Select register X output
						enable_reg_P  <= '0';
						enable_reg_X  <= '0';
						enable_squaring <= '0';
						enable_multiplication <= '0';
						output_signal <= '1';
						i_counter <= "01"; -- Do nothing with counter		
						update_msgout_last <= '0';				

						if (ready_out = '1') then
							ready_in   <= '1';
							next_state <= IDLE;
						else
							ready_in   <= '0';
							next_state <= FOUR;
						end if;
				
				when others =>
				    mux_P_sel             <= '1'; -- Select squaring modpro output
				    mux_X_sel     <= "00"; -- Select register X output
				    enable_reg_P <= '0';
				    enable_reg_X <= '0';
				    output_signal         <= '0';
				    enable_squaring <= '0';
                    enable_multiplication <= '0';
                    i_counter <= "01"; -- Do nothing with counter
                    ready_in      <= '0';
				    update_msgout_last <= '0';
					next_state <= IDLE;
			
			end case;

	end process CombProc;

	SyncProc : process (reset_n, clk)
	begin
		if (reset_n = '0') then
			current_state <= IDLE;
		elsif rising_edge(clk) then
			current_state <= next_state;
            prev_enable_multiplication <= enable_multiplication;
            if (update_msgout_last = '1') then
                msgout_last <= msgin_last;
            end if;
            if (i_counter = "00") then
                counter <= (others => '0');
            elsif (i_counter = "11") then
                counter <= counter + 1;
            end if;
		end if;
	end process SyncProc;

end Behavioral;