library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC;
		
		
		
		------ DEBUG ------	    
    state_out : out std_logic_vector(3 downto 0);   -- DEBUG
    counter : out unsigned(7 downto 0);             -- DEBUG
    register_sum : out integer;                     -- DEBUG
    csa_total : out integer;                        -- DEBUG
    enable_register : out std_logic                 -- DEBUG
	);
end exponentiation;


architecture expBehave of exponentiation is

    signal reg_P_out : std_logic_vector(C_block_size-1 downto 0);
    signal enable_reg_P: std_logic;
    
    signal reg_X_out : std_logic_vector(C_block_size-1 downto 0);
    signal enable_reg_X: std_logic;
   
    signal multiplication_data_out : std_logic_vector(C_block_size-1 downto 0);
    signal enable_multiplication : std_logic;
    signal multiplication_done : std_logic;
    
    signal squaring_data_out : std_logic_vector(C_block_size-1 downto 0);
    signal enable_squaring : std_logic;
    signal squaring_done : std_logic;
    
    signal mux_P_out : std_logic_vector(C_block_size-1 downto 0);
    signal mux_P_sel : std_logic;
    
    signal mux_X_out : std_logic_vector(C_block_size-1 downto 0);
    signal mux_X_sel : std_logic_vector(1 downto 0);
    
begin
    controller      : entity work.exp_controller
    port map(
    );
    
    multiplication  : entity work.modpro
    port map(
    A => reg_P_out,
    B => reg_X_out,
    N_dot => modulus, -- REMEMBER TO CHANGE
    
    enable_modpro => enable_multiplication,
    clk => clk,
    reset_n => reset_n,
    
    
    state_out => state_out,
    counter => counter,
    register_sum => register_sum,
    csa_total => csa_total,
    enable_register => enable_register,
    
    modpro_done => multiplication_done,
    data_out => multiplication_data_out
    );
    
    squaring        : entity work.modpro
    port map(
    A => reg_P_out,
    B => reg_P_out,
    N_dot => modulus, -- REMEMBER TO CHANGE
    
    enable_modpro => enable_squaring,
    clk => clk,
    reset_n => reset_n,
    
    state_out => state_out,
    counter => counter,
    register_sum => register_sum,
    csa_total => csa_total,
    enable_register => enable_register,
    
    modpro_done => squaring_done,
    data_out => squaring_data_out
    );
    
    reg_X : entity work.register_reset_n
    port map(
       clk                      => clk,
       reset_n                  => reset_n,
       enable                   => enable_reg_X,
       d                        => mux_X_out,
       q                        => reg_X_out
    
    );
 
    reg_P : entity work.register_reset_n
    port map(
       clk                      => clk,
       reset_n                  => reset_n,
       enable                   => enable_reg_P,
       d                        => mux_P_out,
       q                        => reg_P_out
    
    );
    
    mux_X : entity work.mux_3
    port map(
        d0     => reg_X_out,
        d1     => multiplication_data_out,
        d2     =>   (0 => '1',
                    others => '0'),
        sel    => mux_X_sel,
        output => mux_X_out
    );
    
    mux_P : entity work.mux_2
    port map(
        d0     => message,
        d1     => squaring_data_out,
        sel    => mux_P_sel,
        output => mux_P_out
    );
end expBehave;
