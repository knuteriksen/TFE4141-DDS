library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity exponentiation_tb is
	generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is

	signal clk 			: STD_LOGIC := '0';
	signal message 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal key 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal valid_in 	: STD_LOGIC;
	signal ready_in 	: STD_LOGIC;
	signal ready_out 	: STD_LOGIC;
	signal valid_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal restart 		: STD_LOGIC;
	signal reset_n 		: STD_LOGIC;
	
	constant CLK_PERIOD : time := 20ns;

    signal input_signal : std_logic := '0';
    

begin
	i_exponentiation : entity work.exponentiation
		port map (
			message   => message  ,
			key       => key      ,
			valid_in  => valid_in ,
			ready_in  => ready_in ,
			ready_out => ready_out,
			valid_out => valid_out,
			result    => result   ,
			modulus   => modulus  ,
			clk       => clk      ,
			reset_n   => reset_n,
			
			input_signal => input_signal

		);
    
    clk <= not clk after CLK_PERIOD/2;

stimulus: process
    begin
    reset_n <= '0';
    wait for 2*CLK_PERIOD;
    reset_n <= '1';
    wait for 10*CLK_PERIOD;
--    message <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"10001100100";  -- 1124
--    key     <= "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"01011110110";  -- 758
--    modulus <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"10011111111";  -- 1279
    
    message <= x"0a23232323232323232323232323232323232323232323232323232323232323";
    key     <= x"0000000000000000000000000000000000000000000000000000000000010001";
    modulus <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
    input_signal <= '1';
    valid_in <= '1';
    ready_out <= '1';
    
     wait until valid_out='1';
     message <= x"0a232020207478742e6e695f307470203a2020202020202020202020454d414e";
     key     <= x"0000000000000000000000000000000000000000000000000000000000010001";
     modulus <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
     input_signal <= '1';
     valid_in <= '1';
     ready_out <= '1';
    
     wait until valid_out='1';
     message <= x"0a2320202020202020202020203336203a2020544e554f43204547415353454d";
     key     <= x"0000000000000000000000000000000000000000000000000000000000010001";
     modulus <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
     input_signal <= '1';
     valid_in <= '1';
     ready_out <= '1';
    
     wait until valid_out='1';
     message <= x"0a2320202020202020202041307830203a464c20726f662065646f6320786548";
     key     <= x"0000000000000000000000000000000000000000000000000000000000010001";
     modulus <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
     input_signal <= '1';
     valid_in <= '1';
     ready_out <= '1';
    
     wait until valid_out='1';
     input_signal <= '0';
     input_signal <= '0';    -- Put breakpoint here. Once it's done computing the modular exponentiation it gets stored in "result" should be 683.
     wait;
    end process stimulus;
end expBehave;
