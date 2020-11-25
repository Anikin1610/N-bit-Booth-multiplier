library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlpath is
    generic (   N : integer := 4);
	port	(	clk : in STD_LOGIC;
				start : in STD_LOGIC;
				reset : in STD_LOGIC;
				P_2LSBits : in STD_LOGIC_VECTOR(1 downto 0);
				shiftP : out STD_LOGIC;
				subAssert : out STD_LOGIC;
				loadM : out STD_LOGIC;
				loadP : out STD_LOGIC;
				loadMultiplier : out STD_LOGIC;
				ready : out STD_LOGIC);
end controlpath;

architecture Behavioral of controlpath is
 constant zeros_N : unsigned(N - 1 downto 0) := (others => '0');
 type states is (loadData, checkBits, add, subtract, shiftProduct, waitState);
 signal cState, nState : states;						
 signal cnt : unsigned(N downto 0) := '1' & zeros_N;	-- N + 1 bit ring counter used for counting number of right shifts
 signal shiftP_sig : STD_LOGIC;
begin
    shiftP <= shiftP_sig;
	counter : process(clk)
	begin
		if rising_edge(clk) then
		    if reset = '1' then 
		        cnt <= '1' & zeros_N;	
			elsif shiftP_sig = '1' then
				cnt <= shift_right(cnt, 1);
			end if;
		end if;
	end process;

	STATE_MEMORY : process(clk, start)
	begin
		if rising_edge(clk) then
		    if reset = '1' then 
		      cState <= waitState;
		    elsif start = '1' then
		      cState <= loadData;
		    else
		      cState <= nState;
		    end if;
		end if;
	end process;
	
	Next_state : process(cState)
	begin
		case(cState) is
			when waitState =>
				nState <= waitState;
							
			when loadData =>
				nState <= checkBits;
			
			when checkBits =>
				if cnt(0) /= '1' then	
					if P_2LSBits = "00" or P_2LSBits = "11" then
						nState <= shiftProduct;
					elsif P_2LSBits = "01" then
						nState <= add;
					else
						nState <= subtract;
					end if;
				else 
					nState <= waitState;
				end if;	
			
			when add => 
				nState <= shiftProduct; 
			
			when subtract => 
				nState <= shiftProduct;
			
			when shiftProduct => 
				nState <= checkBits;
			
			when others =>
				nState <= waitState;
		end case;
	end process;
	
	output_process : process(cState)
	begin
		case(cState) is 
			when waitState =>
				loadMultiplier <= '0';
				shiftP_sig <= '0';
				subAssert <= '0';
				loadM <= '0';
				loadP <= '0';
				ready <= '1';
				
			when loadData =>
			    loadMultiplier <= '1';
				shiftP_sig <= '0';
				subAssert <= '0';
				loadM <= '1';
				loadP <= '1';
				ready <= '0';
				
			when checkbits =>
				loadMultiplier <= '0';
				shiftP_sig <= '0';
				subAssert <= '0';
				loadM <= '0';
				loadP <= '0';
				ready <= '0';
				
			when add =>
			    loadMultiplier <= '0';
				shiftP_sig <= '0';
				subAssert <= '0';
				loadM <= '0';
				loadP <= '1';
				ready <= '0';
			
			when subtract =>
			    loadMultiplier <= '0';
				shiftP_sig <= '0';
				subAssert <= '1';
				loadM <= '0';
				loadP <= '1';
				ready <= '0';
				
			when shiftProduct =>
			    loadMultiplier <= '0';
				shiftP_sig <= '1';
				subAssert <= '0';
				loadM <= '0';
				loadP <= '0';
				ready <= '0';
				
			when others =>
			    loadMultiplier <= '0';
				shiftP_sig <= '0';
				subAssert <= '0';
				loadM <= '0';
				loadP <= '0';
				ready <= '0';
		end case;
	end process;

end Behavioral;

