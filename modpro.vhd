----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.10.2020 17:15:09
-- Design Name: 
-- Module Name: modpro - Behavioral
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

entity modpro is
    generic (
        C_block_size : integer := 256;
        Max_bits     : integer := 264
    );
  Port ( 
    
    --Input control
    A : in std_logic_vector ( C_block_size-1 downto 0 );
    B : in std_logic_vector ( C_block_size-1 downto 0 );
    N_dot : in std_logic_vector ( C_block_size-1 downto 0 );
    enable_modpro : in std_logic;
    clk : in std_logic;
    reset_n : in std_logic;
    
    state_out : out std_logic_vector(3 downto 0);   -- DEBUG
    counter : out unsigned(7 downto 0);             -- DEBUG
    register_sum : out integer;                     -- DEBUG
    csa_total : out integer;                        -- DEBUG
    enable_register : out std_logic;                -- DEBUG
    
    --Output control
    modpro_done : out std_logic;
    data_out : out std_logic_vector(C_block_size-1 downto 0)
    --C_reg : out std_logic_vector ( C_block_size-1 downto 0 );
    --S_reg : out std_logic_vector ( C_block_size-1 downto 0 )
  );
end modpro;

architecture Behavioral of modpro is
    -- Mux outputs
    signal mux_C_out        : STD_LOGIC_VECTOR (Max_bits-1 downto 0);
    signal mux_S_out        : STD_LOGIC_VECTOR (Max_bits-1 downto 0);
    signal mux_A_out        : STD_LOGIC_VECTOR (Max_bits-1 downto 0);
    
    -- CSA Outputs
    signal csa_sum      : STD_LOGIC_VECTOR (Max_bits-1 downto 0);
    signal csa_carry_out    : STD_LOGIC_VECTOR (Max_bits downto 0);
    
    -- Register outputs
    signal reg_C_out        : std_logic_vector (Max_bits downto 0 );
    signal reg_S_out        : std_logic_vector (Max_bits downto 0 );
    
    
    -- Controller select/enable signals
    signal mux_CS_sel       : std_logic_vector(1 downto 0);
    signal mux_A_sel        : std_logic_vector(1 downto 0);
    signal enable_reg       : std_logic;
    signal reset_reg        : std_logic;
    signal output_signal    : std_logic;
    
begin
    controller : entity work.modpro_controller
    port map(
        clk => clk,
        reset_n => reset_n,
        input_signal => enable_modpro,
        output_signal => output_signal,
        B => B,
        
        csa_carry_out => csa_carry_out,
        csa_sum => csa_sum,
        
        reg_C_out => reg_C_out,
        reg_S_out => reg_S_out, 
            
        -- MUX select
        mux_CS_sel => mux_CS_sel,
        mux_A_sel => mux_A_sel,
        
        -- Register enable and reset
        enable_reg => enable_reg,
        reset_reg => reset_reg,
        state_out => state_out,
        debug_enable => enable_register,
        register_sum => register_sum,
        csa_total => csa_total,
        counter_out => counter    
    );

    mux_C : entity work.mux_4
    port map(
        d0 => (others => '0'),
        d1 => reg_C_out(Max_bits-2 downto 0) & '0',
        d2 => reg_C_out(Max_bits-1 downto 0),
        d3 => csa_carry_out(Max_bits-1 downto 0),
        sel => mux_CS_sel,
        output => mux_C_out
    );
    
    mux_S : entity work.mux_4
    port map(
        d0     => (others => '0'),
        d1     => reg_S_out(Max_bits-2 downto 0) & '0',
        d2     => reg_S_out(Max_bits-1 downto 0),
        d3     => csa_sum(Max_bits-1 downto 0),
        sel    => mux_CS_sel,
        output => mux_S_out
    );
    
    mux_A : entity work.mux_4
    port map(
        d0     => (others => '0'),
        d1     => "00000000" & A,
        d2     => "11111111" & N_dot,
        d3     => (others => '0'),
        sel    => mux_A_sel,
        output => mux_A_out
    );
    
    csa : entity work.csa
    port map(
        a         => mux_S_out,
        b         => mux_A_out,
        carry_in  => mux_C_out,
        sum       => csa_sum,
        carry_out => csa_carry_out
    );
    
    reg_S : entity work.register_reset_n
    port map(
       clk                      => clk,
       reset_n                  => reset_reg,
       enable                   => enable_reg,
       d                        => csa_sum(Max_bits-1) & csa_sum,
       q                        => reg_S_out
    
    );
 
    reg_C : entity work.register_reset_n
    port map(
       clk                      => clk,
       reset_n                  => reset_reg,
       enable                   => enable_reg,
       d                        => csa_carry_out,
       q                        => reg_C_out
    
    );
    
    process(output_signal) begin
        if (output_signal = '1') then
            modpro_done <= '1';
            data_out <= std_logic_vector(signed(reg_S_out(C_block_size-1 downto 0)) + signed(reg_C_out(C_block_size-1 downto 0)));
        end if;
     end process;
     
end Behavioral;



