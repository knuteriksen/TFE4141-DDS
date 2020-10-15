library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
		reset_n 	: in STD_LOGIC
		
	);
end exponentiation;


architecture expBehave of exponentiation is
    --temporary registers
    signal p_reg        : std_logic_vector(C_block_size-1 downto 0);
    signal q_reg        : std_logic_vector(C_block_size-1 downto 0);
    signal r_reg_mu     : std_logic_vector(C_block_size-1 downto 0);
    signal r_reg_sq     : std_logic_vector(C_block_size-1 downto 0);
    
    signal start_multi, start_square, end_multi, end_square : std_logic;
          
begin
	
	-- Exponentiation
	process (clk) begin
	
	   start_multi     <= '0';
	   start_square    <= '0';
	   end_multi       <= '0';
	   end_square      <= '0';
	   
	   q_reg <= (0         => '1',
	             others    => '0');
	   
	   p_reg <= message;
	   
	   for i in 0 to C_block_size-2 loop
	       end_multi <= '0';
	       end_square <= '0';
	       if (key(i)) then
	           start_multi <= '1';
	       end if;
           start_square <= '1';
	       
            	       
	       -- wait until end_multiplication and end_square is true
	       -- continue loop   	   
	   end loop;
	   
	   if (key(C_block_size-1)) then
	       start_multi <= '1';
	   end if;
	   
	end process;
	
	
	-- Multiplication
	process (clk, start_multi) begin
	   if (start_multi'event and start_multi='1') then
	       start_multi <= '0';
           r_reg_mu <= (others => '0');
           for i in C_block_size-1 downto 0 loop
               r_reg_mu <= std_logic_vector(2*unsigned(r_reg_mu) + unsigned(q_reg(i downto i))*unsigned(p_reg));
         
               if (r_reg_mu >= modulus) then
                   r_reg_mu <= std_logic_vector(unsigned(r_reg_mu) -unsigned(modulus));
               end if;
               
               if (r_reg_mu >= modulus) then
                   r_reg_mu <= std_logic_vector(unsigned(r_reg_mu) -unsigned(modulus));
               end if;
           end loop;
           end_multi <= '1';
       end if;
	end process;
	
	-- Squaring
	process (clk, start_square) begin
	   if (start_square'event and start_square='1') then
	       start_square <= '0';
           r_reg_sq <= (others => '0');
           for i in C_block_size-1 downto 0 loop
               r_reg_sq <= std_logic_vector(2*unsigned(r_reg_sq) + unsigned(p_reg(i downto i))*unsigned(p_reg));
         
               if (r_reg_sq >= modulus) then
                   r_reg_sq <= std_logic_vector(unsigned(r_reg_sq) -unsigned(modulus));
               end if;
               
               if (r_reg_sq >= modulus) then
                   r_reg_sq <= std_logic_vector(unsigned(r_reg_sq) -unsigned(modulus));
               end if;
           end loop;
           end_square <= '1';
       end if;
	end process;
	
	
   result <= q_reg;
   ready_in <= ready_out;
   valid_out <= valid_in;

end expBehave;

