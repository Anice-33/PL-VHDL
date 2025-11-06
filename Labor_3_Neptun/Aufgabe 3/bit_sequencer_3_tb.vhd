library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bit_sequencer_3_tb is
-- Keine Ports in der Testbench, da dies nur eine Simulation ist
end bit_sequencer_3_tb;

architecture Behavioral of bit_sequencer_3_tb is
    -- Komponenten-Deklaration des zu testenden Moduls
    component bit_sequencer_3
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            x     : in  STD_LOGIC;
            y     : out STD_LOGIC;
            q     : out STD_LOGIC_VECTOR(8 downto 0)
        );
    end component;

    -- Signale zur Verbindung mit dem Modul
    signal clk   : STD_LOGIC := '0'; -- Startzustand des Taktsignals
    signal reset : STD_LOGIC := '0'; -- Startzustand des Resetsignals
    signal x     : STD_LOGIC := '0'; -- Startzustand des Eingangs
    signal y     : STD_LOGIC;        -- Ausgangssignal
    signal q     : STD_LOGIC_VECTOR(8 downto 0); -- Zustandsanzeige

    -- Taktperiode für den Simulations-Takt
    constant clk_period : time := 10 ns;
begin
    -- Instanzierung des Moduls
    uut: bit_sequencer_3
        Port map (
            clk   => clk,
            reset => reset,
            x     => x,
            y     => y,
            q     => q
        );

    -- Taktprozess: Generiert einen 50 MHz-Takt (Periode = 10 ns)
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Simulationsprozess: Steuerung der Eingänge und Überprüfung der Ausgänge
    stim_proc: process
    begin
        -- Reset aktivieren und Zustand A setzen
        reset <= '1';

        -- Testfall 1: x = 0 für 4 Takte (0000 erkennen)
        x <= '0';
        wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	assert y = '1' report "Fehler: y sollte 1 sein nach 4x1!" severity error;
	wait for clk_period; -- 4 Takte warten
	assert y = '1' report "Fehler: y sollte 1 sein nach 4x1!" severity error;
	wait for clk_period; -- 4 Takte warten
	assert y = '1' report "Fehler: y sollte 1 sein nach 4x1!" severity error;

        -- Testfall 2: x = 1 für 4 Takte (1111 erkennen)
        x <= '1';
        wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	assert y = '1' report "Fehler: y sollte 1 sein nach 4x1!" severity error;
	wait for clk_period; -- 4 Takte warten
	wait for clk_period; -- 4 Takte warten
	x <= '0';
	wait for clk_period;
	assert q = "000000010" report "Fehler: Zustand muss B sein!" severity error;
	wait for clk_period;
	wait for clk_period;
	
	
	reset <= '0';
        assert q = "000000001" report "Fehler: Zustand nach Reset nicht A!" severity error;

        wait;
    end process;
end Behavioral;
