library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--===============================================================================
-- Entity declaration
--===============================================================================
entity bcd_zu_siebensegment_konverter is
    Port (
        bcd_in : in STD_LOGIC_VECTOR(3 downto 0); -- sw3 to sw0
        LTN    : in STD_LOGIC;
        BLN    : in STD_LOGIC;
        seg_out : out STD_LOGIC_VECTOR(6 downto 0)  -- g to a
    );
end bcd_zu_siebensegment_konverter;

--===============================================================================
-- architecture declaration
--===============================================================================
architecture Behavioral of bcd_zu_siebensegment_konverter is


--===============================================================================
-- architecture begin
--===============================================================================
begin
    process(bcd_in, LTN, BLN)
    begin
        if (LTN = '0' and BLN = '0') then
            seg_out <= "1111111";  -- All segments off when LTN is 0
        elsif (LTN = '0' and BLN = '1') then
            seg_out <= "0000000";  -- All segments on when BLN is 1
        else
				seg_out(0) <= (not bcd_in(3) and not bcd_in(2) and not bcd_in(1) and bcd_in(0)) or
                          (not bcd_in(3) and bcd_in(2) and not bcd_in(1) and not bcd_in(0)); -- do not light if 1, 4
				seg_out(1) <= (not bcd_in(3) and bcd_in(2) and not bcd_in(1) and bcd_in(0)) or
                          (not bcd_in(3) and bcd_in(2) and bcd_in(1) and not bcd_in(0)); -- do not light if 5, 6
				seg_out(2) <= (not bcd_in(3) and not bcd_in(2) and bcd_in(1) and not bcd_in(0)); -- do not light if 2
				seg_out(3) <= (not bcd_in(3) and not bcd_in(2) and not bcd_in(1) and bcd_in(0)) or
                          (not bcd_in(3) and bcd_in(2) and not bcd_in(1) and not bcd_in(0)) or
								  (not bcd_in(3) and bcd_in(2) and bcd_in(1) and bcd_in(0)); -- do not light if 1, 4, 7
				seg_out(4) <= (not bcd_in(3) and not bcd_in(2) and not bcd_in(1) and bcd_in(0)) or
								  (not bcd_in(3) and not bcd_in(2) and bcd_in(1) and bcd_in(0))     or
                          (not bcd_in(3) and bcd_in(2) and not bcd_in(1) and not bcd_in(0)) or
								  (not bcd_in(3) and bcd_in(2) and not bcd_in(1) and bcd_in(0))     or
								  (not bcd_in(3) and bcd_in(2) and bcd_in(1) and bcd_in(0))         or
								  (bcd_in(3) and not bcd_in(2) and not bcd_in(1) and bcd_in(0)); -- do not light if 1, 3, 4, 5, 7, 9
				seg_out(5) <= (not bcd_in(3) and not bcd_in(2) and not bcd_in(1) and bcd_in(0)) or
								  (not bcd_in(3) and not bcd_in(2) and bcd_in(1) and not bcd_in(0)) or
								  (not bcd_in(3) and not bcd_in(2) and bcd_in(1) and bcd_in(0))     or
								  (not bcd_in(3) and bcd_in(2) and bcd_in(1) and bcd_in(0)); -- do not light if 1, 2, 3, 7
				seg_out(6) <= (not bcd_in(3) and not bcd_in(2) and not bcd_in(1) and not bcd_in(0)) or
								  (not bcd_in(3) and not bcd_in(2) and not bcd_in(1) and bcd_in(0)) or
								  (not bcd_in(3) and bcd_in(2) and bcd_in(1) and bcd_in(0)); -- do not light if 0, 1, 7
        end if;
    end process;
end Behavioral;