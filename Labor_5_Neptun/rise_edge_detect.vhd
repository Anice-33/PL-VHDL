library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rise_edge_detect is
port(
	clk		:		in std_logic;
	input    :		in std_logic;
	output	:		out std_logic
);
end rise_edge_detect;

architecture behaviour of rise_edge_detect is

signal	z1		:	std_logic:='0';

begin
	rise_edge:process(clk)
	begin
		if rising_edge(clk) then
			z1<=input;
		end if;
	end process;
	output<=(not z1) and input;
end behaviour;