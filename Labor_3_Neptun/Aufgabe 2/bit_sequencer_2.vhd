library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--===============================================================================
-- Entity declaration
--===============================================================================
entity bit_sequencer_2 is
    Port (
        clk   : in  STD_LOGIC;     -- Takt
        reset : in  STD_LOGIC;     -- Reset (aktiv niedrig)
        x     : in  STD_LOGIC;     -- Eingang (Schalter SW0)
        y     : out STD_LOGIC;     -- Ausgang (LEDR9)
        q     : out STD_LOGIC_VECTOR(8 downto 0) -- Flip-Flop-Ausgänge (LEDR8 bis LEDR0)
    );
end bit_sequencer_2;

--===============================================================================
-- architecture declaration
--===============================================================================
architecture Behavioral of bit_sequencer_2 is
    signal current_state : STD_LOGIC_VECTOR(8 downto 0); -- Aktueller Zustand
    signal next_state    : STD_LOGIC_VECTOR(8 downto 0); -- Nächster Zustand
	 
--===============================================================================
-- architecture begin
--===============================================================================
begin
    -- Flip-Flop-Prozess: Speicherung des aktuellen Zustands
    process(clk, reset)
    begin
        if reset = '0' then
            current_state <= "000000000"; -- Neuer Reset-Zustand A (alle Flip-Flops auf 0)
        elsif rising_edge(clk) then
            current_state <= next_state; -- Wechsel zum nächsten Zustand
        end if;
    end process;

    -- Logik für Zustandsübergänge
    process(current_state, x)
    begin
        if reset = '0' then
            next_state <= "000000001";
        else
            next_state <= (others => '0');
				next_state(0) <= '0';
				next_state(1) <= (not x) and (current_state(0) or current_state(5) or current_state(6)  or current_state(7) or current_state(8));
				next_state(2) <= (not x) and (current_state(1));
				next_state(3) <= (not x) and (current_state(2));
				next_state(4) <= (not x) and (current_state(3) or current_state(4));
				next_state(5) <= (x) and (current_state(0) or current_state(1) or current_state(2) or current_state(3)  or current_state(4));
				next_state(6) <= (x) and (current_state(5));
				next_state(7) <= (x) and (current_state(6));
				next_state(8) <= (x) and (current_state(7) or current_state(8));
        end if;
    end process;

    -- Logik für den Ausgang
    y <= '1' when (current_state = "000010001" or current_state = "100000001") else '0';

    -- Verbindung der Flip-Flop-Ausgänge mit den LEDs
    q <= current_state;

end Behavioral;