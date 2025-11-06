LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SPI_Interface_TB IS
END SPI_Interface_TB;

ARCHITECTURE behavior OF SPI_Interface_TB IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT SPI_Interface
        PORT(
            clk        : IN  std_logic;
            SCLK       : IN  std_logic;
            MOSI       : IN  std_logic;
            SS         : IN  std_logic;
            data_leds  : OUT std_logic_vector(7 downto 0);
            data_disp  : OUT std_logic_vector(6 downto 0);
            valid      : OUT std_logic
        );
    END COMPONENT;

    -- Signals to connect to UUT
    SIGNAL clk        : std_logic := '0';
    SIGNAL SCLK       : std_logic := '0';
    SIGNAL MOSI       : std_logic := '0';
    SIGNAL SS         : std_logic := '1';
    SIGNAL data_leds  : std_logic_vector(7 downto 0);
    SIGNAL data_disp  : std_logic_vector(6 downto 0);
    SIGNAL valid      : std_logic;

    -- Clock period definitions
    CONSTANT clk_period : time := 20 ns; -- 50 MHz clock
    CONSTANT sclk_period : time := 200 ns; -- SPI clock (5 MHz)

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: SPI_Interface PORT MAP (
        clk        => clk,
        SCLK       => SCLK,
        MOSI       => MOSI,
        SS         => SS,
        data_leds  => data_leds,
        data_disp  => data_disp,
        valid      => valid
    );

    -- Clock generation for clk
    clk_process :process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Clock generation for SCLK
    sclk_process :process
    begin
        while true loop
            SCLK <= '0';
            wait for sclk_period / 2;
            SCLK <= '1';
            wait for sclk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the SS signal
        SS <= '1';
        wait for 200 ns;
        SS <= '0'; -- Start SPI transaction

        -- Send 8 bits of data: "1 00 00 01 0" (example data) A "01000001"
        MOSI <= '1'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '1'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;

        SS <= '1'; -- End SPI transaction
        wait for 800 ns;

        -- Send 8 bits of data: "01 00 00 10" (example data) B "01000010"
		  --                      "11 00 00 10"                C "01000011"
        SS <= '0';
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '1'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
        MOSI <= '1'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period; --  but only 8 can be read
		  
		  MOSI <= '1'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;
		  MOSI <= '1'; wait for sclk_period;
        MOSI <= '0'; wait for sclk_period;

        SS <= '1';
        wait for 800 ns;

        -- End simulation
        wait;
    end process;

END behavior;

