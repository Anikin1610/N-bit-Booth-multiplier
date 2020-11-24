library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.finish;

entity tb_mult is 
end entity;

architecture beh_tb of tb_mult is
    component Boothe_mult is
        generic ( N : integer := 4 );
        port (	clk : in STD_LOGIC;
			    start : in STD_LOGIC;
			    reset : in STD_LOGIC;
			    data_bus : in STD_LOGIC_VECTOR((2 * N) - 1 downto 0);
			
			    ready : out STD_LOGIC;
			    product : out STD_LOGIC_VECTOR((2 * N) - 1 downto 0));
    end component;
    
    constant clk_period : time := 1 us;
    constant num_bits : integer := 5;

    signal clk, start, ready, reset : STD_LOGIC := '0';
    signal data_bus :  STD_LOGIC_VECTOR((2 * num_bits) - 1 downto 0) := (others => '0');
    signal product : STD_LOGIC_VECTOR((2 * num_bits) - 1 downto 0) :=  (others => '0');
begin

    UUT : Boothe_mult 
          generic map ( N => num_bits)       
          port map (clk => clk,
                    start => start,
                    reset => reset,
                    data_bus => data_bus,
                    ready => ready,
                    product => product);
    clk_Proc: process
    begin
        clk <= not clk; 
        wait for clk_period / 2;
    end process clk_proc;

    tb_Proc: process
    begin
        for i in -(2 ** (num_bits - 1)) to (2 ** (num_bits - 1)) - 1 loop
            for j in -(2 ** (num_bits - 1)) to (2 ** (num_bits - 1)) - 1 loop
                reset <= '1';
                wait for 2 us;
                reset <= '0';
                wait for 2 us;
                data_bus <= STD_LOGIC_VECTOR(to_signed(i, num_bits)) & STD_LOGIC_VECTOR(to_signed(j, num_bits));
                wait for 2 us;
                start <= '1';
                wait for 2 us;
                start <= '0';
                wait until ready = '1';
                if j = (2 ** (num_bits - 1)) - 1 then
                    reset <= '1';
                    wait for 2 us;
                    reset <= '0';
                    wait for 10 us;
                end if;
            end loop;
            
            if i = (2 ** (num_bits - 1)) - 1 then 
                report "Test Bench finished!";
                finish;
            end if;
          end loop;
            
    end process tb_proc;
    
end architecture beh_tb;