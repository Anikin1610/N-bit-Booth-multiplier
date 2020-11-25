----------------------------------------------------------------------------------------
-- N - bit Ripple Carry Adder
----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder_Nbit is
    generic ( N : integer := 8 );
    Port ( ip1 : in STD_LOGIC_VECTOR (N - 1 downto 0);
           ip2 : in STD_LOGIC_VECTOR (N - 1 downto 0);
			  sub : in STD_LOGIC;
           op : out STD_LOGIC_VECTOR (N - 1 downto 0);
			  op_carry : out STD_LOGIC);
end adder_Nbit;

architecture adder_beh of adder_Nbit is
	component FullAdder_1bit is
    Port ( a : in STD_LOGIC;
           b : in STD_LOGIC;
           cin : in STD_LOGIC;
           cout : out STD_LOGIC;
           sum : out STD_LOGIC);
	end component;
	signal carry :STD_LOGIC_VECTOR(N - 1 downto 0);
	signal ip2_signed : STD_LOGIC_VECTOR(N - 1 downto 0);

begin

	xor_gen : for j in 0 to N - 1 generate
		ip2_signed(j) <= ip2(j) xor sub;
	end generate xor_gen;

	FA1: FullAdder_1bit port map(a => ip1(0), b => ip2_signed(0), cin => sub, cout => carry(0),sum => op(0));
	FA2: for i in 1 to N - 2 generate
	FA3: FullAdder_1bit port map (a => ip1(i), b => ip2_signed(i), cin => carry(i - 1), cout => carry(i), sum => op(i));
		  end generate;
	FA4: FullAdder_1bit port map(a => ip1(N - 1), b => ip2_signed(N - 1), cin => carry(N - 2), cout => op_carry, sum => op(N - 1));

end adder_beh;

