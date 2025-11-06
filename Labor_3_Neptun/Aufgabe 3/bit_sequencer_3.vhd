LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--===============================================================================
-- Entity declaration
--===============================================================================
ENTITY bit_sequencer_3 IS
    PORT (
        clk   : in  STD_LOGIC;         -- Takt
        reset : in  STD_LOGIC;         -- Reset (aktiv niedrig)
        x     : in  STD_LOGIC;         -- Eingang (Schalter SW0)
        y     : out STD_LOGIC;         -- Ausgang (LEDR9)
        q     : out STD_LOGIC_VECTOR(8 downto 0) -- Flip-Flop-Ausgänge (LEDR8 bis LEDR0)
    );
END bit_sequencer_3;

--===============================================================================
-- architecture declaration
--===============================================================================
ARCHITECTURE Behavior OF bit_sequencer_3 IS
    -- Definition des benutzerdefinierten Zustands-Typs
    TYPE State_type IS (A, B, C, D, E, F, G, H, I);
    SIGNAL z_Q, z_D : State_type; -- z_Q ist aktueller Zustand, z_D ist nächster Zustand
	 
--===============================================================================
-- architecture begin
--===============================================================================
BEGIN
    -- Zustandsübergangstabelle (State Table)
    PROCESS(x, z_Q)
    BEGIN
        CASE z_Q IS
            WHEN A =>
                IF x = '0' THEN
                    z_D <= B; -- Übergang zu Zustand B
                ELSE
                    z_D <= F; -- Übergang zu Zustand F
                END IF;

            WHEN B =>
                IF x = '0' THEN
                    z_D <= C; -- Übergang zu Zustand C
                ELSE
                    z_D <= F; -- Zurück zu Zustand A
                END IF;

            WHEN C =>
                IF x = '0' THEN
                    z_D <= D; -- Übergang zu Zustand D
                ELSE
                    z_D <= F; -- Zurück zu Zustand B
                END IF;

            WHEN D =>
                IF x = '0' THEN
                    z_D <= E; -- Übergang zu Zustand E
                ELSE
                    z_D <= F; -- Zurück zu Zustand C
                END IF;

            WHEN E =>
                IF x = '0' THEN
                    z_D <= E; -- Bleibt in Zustand E
                ELSE
                    z_D <= F; -- Übergang zu Zustand F
                END IF;

            WHEN F =>
                IF x = '1' THEN
                    z_D <= G; -- Übergang zu Zustand G
                ELSE
                    z_D <= B; -- Zurück zu Zustand E
                END IF;

            WHEN G =>
                IF x = '1' THEN
                    z_D <= H; -- Übergang zu Zustand H
                ELSE
                    z_D <= B; -- Zurück zu Zustand F
                END IF;

            WHEN H =>
                IF x = '1' THEN
                    z_D <= I; -- Übergang zu Zustand I
                ELSE
                    z_D <= B; -- Zurück zu Zustand G
                END IF;

            WHEN I =>
                IF x = '1' THEN
                    z_D <= I; -- Bleibt in Zustand I
                ELSE
                    z_D <= B; -- Zurück zu Zustand H
                END IF;

            WHEN OTHERS =>
                z_D <= A; -- Standard: Zurück zu Zustand A
        END CASE;
    END PROCESS;

    -- Zustandsspeicherung (State Flip-Flops)
    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            z_Q <= A; -- Initialzustand A
        ELSIF rising_edge(clk) THEN
            z_Q <= z_D; -- Wechsel zum nächsten Zustand
        END IF;
    END PROCESS;

    -- Zuweisungen für die LEDs und den Ausgang y
    PROCESS(z_Q)
    BEGIN
        -- Ausgangszustände der Flip-Flops (LEDs)
        CASE z_Q IS
            WHEN A => q <= "000000001";
            WHEN B => q <= "000000010";
            WHEN C => q <= "000000100";
            WHEN D => q <= "000001000";
            WHEN E => q <= "000010000";
            WHEN F => q <= "000100000";
            WHEN G => q <= "001000000";
            WHEN H => q <= "010000000";
            WHEN I => q <= "100000000";
            WHEN OTHERS => q <= "000000001"; -- Standard: Zustand A
        END CASE;

        -- Zuweisung des Ausgangs y
        IF z_Q = E OR z_Q = I THEN
            y <= '1'; -- Aktiviert in Zustand E und I
        ELSE
            y <= '0'; -- In allen anderen Zuständen deaktiviert
        END IF;
    END PROCESS;

END Behavior;
