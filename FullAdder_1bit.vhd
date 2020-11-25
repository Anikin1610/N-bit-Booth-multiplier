library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder_1bit is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           sum : out  STD_LOGIC);
end FullAdder_1bit;

architecture adder_structural of FullAdder_1bit is
	
begin
	sum <= a xor b xor cin;
	cout <= (a and b) or (a and cin) or (b and cin);
end adder_structural;

