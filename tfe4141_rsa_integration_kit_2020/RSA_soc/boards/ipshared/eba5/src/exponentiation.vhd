library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.modpro;
use work.exp_controller;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in    : in  std_logic; --Core
		ready_in    : out std_logic; --Core

		--input data
		message     : in  std_logic_vector (C_block_size - 1 downto 0);
		key         : in  std_logic_vector (C_block_size - 1 downto 0);
		msgin_last  : in  std_logic; -- Core

		--ouput controll
		ready_out   : in  std_logic; --Core
		valid_out   : out std_logic; --Core
		msgout_last : out std_logic; -- Core

		--output data
		result      : out std_logic_vector(C_block_size - 1 downto 0);

		--modulus
		modulus     : in  std_logic_vector(C_block_size - 1 downto 0);

		--utility
		clk         : in  std_logic;
		reset_n     : in  std_logic
	);
end exponentiation;
architecture expBehave of exponentiation is

	signal reg_P_out               : std_logic_vector(C_block_size - 1 downto 0);
	signal enable_reg_P            : std_logic;

	signal reg_X_out               : std_logic_vector(C_block_size - 1 downto 0);
	signal enable_reg_X            : std_logic;

	signal multiplication_data_out : std_logic_vector(C_block_size - 1 downto 0);
	signal enable_multiplication   : std_logic;
	signal multiplication_done     : std_logic;

	signal squaring_data_out       : std_logic_vector(C_block_size - 1 downto 0);
	signal enable_squaring         : std_logic;
	signal squaring_done           : std_logic;

	signal mux_P_out               : std_logic_vector(C_block_size - 1 downto 0);
	signal mux_P_sel               : std_logic;

	signal mux_X_out               : std_logic_vector(C_block_size - 1 downto 0);
	signal mux_X_sel               : std_logic_vector(1 downto 0);
	signal modulus_dot             : std_logic_vector(C_block_size + 1 downto 0);
	signal output_signal           : std_logic;

	signal valid_out_i             : std_logic;
	signal msg_last, msg_last_2    : std_logic;

begin

	twos_complement_modulus : entity work.twos_complement
		port map(
			din  => '0' & modulus,
			dout => modulus_dot
		);

	controller : entity work.exp_controller
		port map(
			clk                   => clk,
			reset_n               => reset_n,

			ready_out             => ready_out,
			ready_in              => ready_in,
			valid_in              => valid_in,

			mux_P_sel             => mux_P_sel,
			mux_X_sel             => mux_X_sel,

			enable_multiplication => enable_multiplication,
			multiplication_done   => multiplication_done,

			enable_squaring       => enable_squaring,
			squaring_done         => squaring_done,

			key                   => key,

			output_signal         => output_signal,

			enable_reg_P          => enable_reg_P,
			enable_reg_X          => enable_reg_X,

			msgout_last           => msgout_last,
			msgin_last            => msgin_last

		);

	multiplication : entity work.modpro
		port map(
			A             => reg_P_out,
			B             => reg_X_out,
			N_dot         => modulus_dot(C_block_size downto 0),

			enable_modpro => enable_multiplication,
			clk           => clk,
			reset_n       => reset_n,

			modpro_done   => multiplication_done,
			data_out      => multiplication_data_out
		);

	squaring : entity work.modpro
		port map(
			A             => reg_P_out,
			B             => reg_P_out,
			N_dot         => modulus_dot(C_block_size downto 0),

			enable_modpro => enable_squaring,
			clk           => clk,
			reset_n       => reset_n,

			modpro_done   => squaring_done,
			data_out      => squaring_data_out
		);

	reg_X : entity work.register_reset_n_256
		port map(
			clk     => clk,
			reset_n => reset_n,
			enable  => enable_reg_X,
			d       => mux_X_out,
			q       => reg_X_out

		);

	reg_P : entity work.register_reset_n_256
		port map(
			clk     => clk,
			reset_n => reset_n,
			enable  => enable_reg_P,
			d       => mux_P_out,
			q       => reg_P_out

		);

	mux_X : entity work.mux_3
		port map(
			d0     => reg_X_out,
			d1     => multiplication_data_out,
			d2 => (0 => '1',
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

	process (output_signal) begin
		result <= mux_X_out;
		if (output_signal = '1') then
			valid_out_i <= '1';
		else
			valid_out_i <= '0';
		end if;
	end process;
	
	valid_out <= valid_out_i;
end expBehave;
