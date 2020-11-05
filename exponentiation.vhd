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
		
		input_signal: in std_logic;
		
			    
    multiplication_state_out : out std_logic_vector(3 downto 0);   -- DEBUG
    squaring_state_out : out std_logic_vector(3 downto 0);   -- DEBUG
    
    multiplication_counter : out unsigned(7 downto 0);             -- DEBUG
    squaring_counter : out unsigned(7 downto 0);             -- DEBUG
    
    multiplication_register_sum : out integer;                     -- DEBUG
    squaring_register_sum : out integer;                     -- DEBUG
    
    multiplication_csa_total : out integer;                        -- DEBUG
    squaring_csa_total : out integer;                        -- DEBUG
    
    exp_state_out : out std_logic_vector(3 downto 0);
    exp_counter : out unsigned(7 downto 0)
    
    --reg_P_out : out std_logic_vector(C_block_size-1 downto 0);
    --reg_X_out : out std_logic_vector(C_block_size-1 downto 0) 
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
    
    signal output_signal: std_logic;
    
begin
    controller      : entity work.exp_controller
    port map(
    clk => clk,
    reset_n => reset_n,
    
    mux_P_sel => mux_P_sel,
    mux_X_sel => mux_X_sel,
    
    enable_multiplication => enable_multiplication,
    multiplication_done => multiplication_done,
   
    enable_squaring => enable_squaring,
    squaring_done => squaring_done,
    
    key => key,
    
    input_signal => input_signal,
    output_signal => output_signal,
    
    enable_reg_P => enable_reg_P,
    enable_reg_X => enable_reg_X,
    
    valid_in => valid_in,
    ready_in => ready_in,
    
    ready_out => ready_out,
    valid_out => valid_out,
    
    state_out => exp_state_out,
    counter_out => exp_counter
    );
    
    multiplication  : entity work.modpro
    port map(
    A => reg_P_out,
    B => reg_X_out,
    N_dot => modulus, -- REMEMBER TO CHANGE
    
    enable_modpro => enable_multiplication,
    clk => clk,
    reset_n => reset_n,
    
    
    state_out => multiplication_state_out,
    counter => multiplication_counter,
    register_sum => multiplication_register_sum,
    csa_total => multiplication_csa_total,
    
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
    
    state_out => squaring_state_out,
    counter => squaring_counter,
    register_sum => squaring_register_sum,
    csa_total => squaring_csa_total,
    
    modpro_done => squaring_done,
    data_out => squaring_data_out
    );
    
    reg_X : entity work.register_reset_n_256
    port map(
       clk                      => clk,
       reset_n                  => reset_n,
       enable                   => enable_reg_X,
       d                        => mux_X_out,
       q                        => reg_X_out
    
    );
 
    reg_P : entity work.register_reset_n_256
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
    
    
    process(output_signal) begin
        if (output_signal = '1') then
            mux_X_sel <= "00";
            valid_out <= '1';
            result <= mux_X_out;
        end if;
     end process;
     
     
end expBehave;
