----------------------------------------------------------------------------------------
-- Author : Anirudh Srinivasan
-- N-Bit Booth Multiplier 
----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Boothe_mult is
    generic ( N : integer := 4 );
	port (	clk : in STD_LOGIC;
			start : in STD_LOGIC;
			reset : in STD_LOGIC;
			data_bus : in STD_LOGIC_VECTOR((2 * N) - 1 downto 0);
			
			ready : out STD_LOGIC;
			product : out STD_LOGIC_VECTOR((2 * N) - 1 downto 0));
end Boothe_mult;

architecture mult_beh of Boothe_mult is

	component adder_Nbit
		generic (   N : integer := 8 );  
		Port	(	ip1 : in  STD_LOGIC_VECTOR (N - 1 downto 0);
					ip2 : in  STD_LOGIC_VECTOR (N - 1 downto 0);
					sub : in STD_LOGIC;
					op_carry : out  STD_LOGIC;
					op : out  STD_LOGIC_VECTOR (N - 1 downto 0));
	end component;
	
	component controlpath 
	    generic (   N : integer := 4 );
		port	(	clk : in STD_LOGIC;
					start : in STD_LOGIC;
					reset : in STD_LOGIC;
					P_2LSBits : in STD_LOGIC_VECTOR(1 downto 0);
					shiftP : out STD_LOGIC;
					subAssert : out STD_LOGIC;
					loadM : out STD_LOGIC;
					loadP : out STD_LOGIC;
					clearRegs : out STD_LOGIC;
					loadMultiplier : out STD_LOGIC;
					ready : out STD_LOGIC);
	end component;
	
	signal M : STD_LOGIC_VECTOR (N - 1 downto 0) := (others => '0');
	signal P : STD_LOGIC_VECTOR (2 * N downto 0) := (others => '0');
	signal Sum : STD_LOGIC_VECTOR((2 * N) - 1 downto 0);
	signal MUX : STD_LOGIC_VECTOR((4 * N) - 1 downto 0);
	signal shiftP, loadM, loadP, loadMultiplier, subAssert, clearRegs : STD_LOGIC;
	
	constant zeros_N : STD_LOGIC_VECTOR(N - 1 downto 0) := (others => '0');
	constant zeros_2N : STD_LOGIC_VECTOR((2 * N) - 1 downto 0) := (others => '0'); 
	
	
begin

    MUX <= P(2 * N downto 1) & M & zeros_N when loadMultiplier = '0' else zeros_N & data_bus(N - 1 downto 0) & zeros_2N;

	product <= P(2 * N downto 1);
	adder : adder_Nbit 
	generic map (  N => 2 * N ) 
	port map (	ip1 => MUX((4 * N) - 1 downto 2 * N),
	            ip2 => MUX((2 * N) - 1 downto 0),
				sub => subAssert,
				op_carry => open,
				op => Sum);
													
	control_path : controlpath 
	               generic map (  N => N ) 
	               port map	(	clk => clk,
								start => start,
								reset => reset,
								P_2LSBits => P(1 downto 0),
								shiftP => shiftP,
								subAssert => subAssert,
								loadM => loadM,
								loadP => loadP,
								clearRegs =>  clearRegs,
								loadMultiplier => loadMultiplier,
								ready => ready);
										
	main : process(clk)
	begin
		if rising_edge(clk) then
		    if clearRegs = '1' then 
		        M <= (others => '0');
		        P <= (others => '0');
		    else
		      if loadM = '1' then
			    M <= data_bus((2 * N) - 1 downto N);
			  end if;
			
			  if loadP = '1' then
                P((2 * N) downto 1) <= Sum;
			  end if;
			
			  if shiftP = '1' then
				P <= (P((2 * N)) & P((2 * N) downto 1));
			  end if;
	   	   end if;
	   	end if;
	end process;
	
end mult_beh;

