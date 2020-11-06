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
	
		------ DEBUG ------    
    signal input_signal : std_logic := '0';
    
    signal multiplication_state_out : std_logic_vector(3 downto 0);   -- DEBUG
    signal squaring_state_out : std_logic_vector(3 downto 0);   -- DEBUG
    
    signal multiplication_counter : unsigned(7 downto 0);             -- DEBUG
    signal squaring_counter : unsigned(7 downto 0);             -- DEBUG
    
    signal multiplication_register_sum : integer;                     -- DEBUG
    signal squaring_register_sum : integer;                     -- DEBUG
    
    signal multiplication_csa_total : integer;                        -- DEBUG
    signal squaring_csa_total : integer;                        -- DEBUG
    
    signal exp_counter : unsigned(7 downto 0);
    signal exp_state_out : std_logic_vector(3 downto 0);	

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
			
			input_signal => input_signal,
			
			multiplication_state_out => multiplication_state_out,
			multiplication_counter => multiplication_counter,
			multiplication_register_sum => multiplication_register_sum,
			multiplication_csa_total => multiplication_csa_total,
			
			squaring_state_out => squaring_state_out,
			squaring_counter => squaring_counter,
			squaring_register_sum => squaring_register_sum,
			squaring_csa_total => squaring_csa_total,
			
			exp_counter => exp_counter,
			exp_state_out => exp_state_out
		);
		
	--reset_n <= '1';
    
    clk <= not clk after CLK_PERIOD/2;

stimulus: process
    begin
    reset_n <= '0';
    wait for 2*CLK_PERIOD;
    reset_n <= '1';
    wait for 10*CLK_PERIOD;
    message <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"10001100100";  -- 1124
    key     <= "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"01011110110";  -- 758
    modulus <= "1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"&"101100000001";  -- -1279
    wait for 10*CLK_PERIOD;
    input_signal <= '1';
     wait until valid_out='1';
     input_signal <= '0';
     wait;
    end process stimulus;
end expBehave;
