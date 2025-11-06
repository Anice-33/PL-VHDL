library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity bcd_zu_siebensegment_konverter_tb is
end bcd_zu_siebensegment_konverter_tb;

architecture Behavioral of bcd_zu_siebensegment_konverter_tb is
    component bcd_zu_siebensegment_konverter
        Port(
            bcd_in : in STD_LOGIC_VECTOR(3 downto 0);
            LTN    : in STD_LOGIC;
            BLN    : in STD_LOGIC;
            seg_out : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
	 
    signal bcd_in : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal LTN    : STD_LOGIC := '1';
    signal BLN    : STD_LOGIC := '0';
    signal seg_out : STD_LOGIC_VECTOR(6 downto 0);

begin
    uut: bcd_zu_siebensegment_konverter Port map(
        bcd_in => bcd_in,
        LTN    => LTN,
        BLN    => BLN,
        seg_out => seg_out
    );
    stim_proc: process
    begin
        -- Test all BCD values from 0 to 9
        for i in 0 to 9 loop
            bcd_in <= STD_LOGIC_VECTOR(conv_unsigned(i, 4));
            wait for 20 ns;
        end loop;

        -- Test LTN condition: turning all segments off
        LTN <= '0';
        wait for 20 ns;
        LTN <= '1';
        
        -- Test BLN condition: turning all segments on
        BLN <= '1';
        wait for 20 ns;
        BLN <= '0';

        wait;
    end process;

end Behavioral;