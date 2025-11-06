LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SPI_Interface IS
    PORT(
        clk        : IN  std_logic;       -- Systemtakt 50 MHz
        SCLK       : in  std_logic;       -- SPI-Takt
        MOSI       : IN  std_logic;
        SS         : IN  std_logic;
      
        data_leds  : OUT std_logic_vector(7 downto 0); -- Ergebnis-Ausgabe auf 8 LEDs
        data_disp  : OUT std_logic_vector(6 downto 0); -- Ergebnis-Ausgabe auf Display
        valid      : OUT std_logic;
        
        state_segments  : OUT std_logic_vector(6 downto 0)  -- Segmente zur Anzeige des Zustands
        
    );
END ENTITY;

ARCHITECTURE rtl OF SPI_Interface IS
    TYPE states IS (STATE_INIT, STATE_READ, STATE_OUT);
    SIGNAL state : states := STATE_INIT;
    
    signal bit_count       : integer := 1;  -- Bitzähler
    signal bit_ready : std_logic := '0';                 -- Bereitschaft zur Annahme des nächsten Bits
    signal data_done : std_logic := '0';                 -- Empfang von 8 Bits abgeschlossen
    
    signal SCLK_rise       : std_logic := '0';           -- Ansteigende Flanke von SCLK
    signal schieberegister : std_logic_vector(7 downto 0) := (others => '0');
    
BEGIN

-- Verwendung des Moduls rise_edge_detect zur Erkennung der SCLK-Flanke
rise_edge_detect: entity work.rise_edge_detect
    Port Map (
        clk    => clk,       -- Systemtakt
        input  => SCLK,      -- Eingangssignal SCLK
        output => SCLK_rise  -- Ansteigende Flanke
    );

state_proc: 
PROCESS (clk)

BEGIN
    IF rising_edge(clk) THEN
            CASE state IS
                
                WHEN STATE_INIT =>
                          IF SS = '0' THEN
                               -- Zurücksetzen des Zählers bei Deaktivierung von SS
                                bit_count <= 1;
                                data_done <= '0';
                                state <= STATE_READ;
                          END IF;
                     
                WHEN STATE_READ => 

                         -- Wenn SS aktiv ist, verarbeiten wir SCLK-Flanken
                          if SCLK_rise = '1' and data_done = '0' then
                                bit_count <= bit_count + 1;  -- Erhöhen des Zählers
                                bit_ready <= '1';            -- Bereitschaft, Bit zu empfangen
                                
                                -- Abschluss, wenn 8 Bits erreicht wurden
                                if bit_count = 8 then
                                     data_done <= '1';
                                else
                                     data_done <= '0';
                                end if;
                          else
                                bit_ready <= '0'; -- Nicht bereit für das nächste Bit
                          end if;

                          
                          
                          
                          if bit_ready = '1' then
                                -- Rechtsverschiebung
                               schieberegister <= MOSI & schieberegister(7 downto 1);
                          else
                                IF SS = '1' and data_done = '1' THEN
                                 -- Zurücksetzen des Zählers bei Deaktivierung von SS
                                  bit_count <= 1;         -- Rücksetzung des Zählers nach Paketabschluss
                                  data_done <= '0';
                                  state <= STATE_OUT;
                                END IF;             
                          end if;
                          
                          
                     
                     WHEN STATE_OUT =>
                          -- Wenn SS 0, dann zurück zu READ
                          IF SS = '0' THEN
                               -- Zurücksetzen des Zählers bei Deaktivierung von SS
                                bit_count <= 1;         -- Rücksetzung des Zählers nach Paketabschluss
                                 data_done <= '0';
                                 schieberegister <= "00000000";
                                 state <= STATE_READ;
                          END IF;            
                          
            END CASE;
        END IF;
END PROCESS;




out_proc: 
PROCESS (state)
BEGIN
    CASE state IS
        WHEN STATE_INIT =>
          
                state_segments <= "1111001"; -- state 1
                
                valid <= '0';
                data_leds <= (others => '0'); -- LEDs löschen
                data_disp <= (others => '0'); -- Display löschen
          
          WHEN STATE_READ =>
          
                state_segments <= "0100100"; -- state 2
                
                valid <= '0';
                data_leds <= schieberegister;

          WHEN STATE_OUT =>
          
                state_segments <= "0110000"; -- state 3
                
                valid <= '1';
                data_leds <= schieberegister;
                IF schieberegister = "01000001" THEN
                      data_disp <= "0001000"; -- A
                ELSIF schieberegister = "01000010" THEN
                      data_disp <= "0000000"; -- B
                ELSIF schieberegister = "01000011" THEN
                      data_disp <= "1000110"; -- C

                
                ELSE
                      data_disp <= (others => '0');
                END IF;
                
    END CASE;
END PROCESS;

END rtl;
