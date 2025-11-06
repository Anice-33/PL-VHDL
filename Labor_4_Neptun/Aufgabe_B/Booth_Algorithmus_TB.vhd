LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Booth_Algorithmus_TB IS
END Booth_Algorithmus_TB;

ARCHITECTURE behavior OF Booth_Algorithmus_TB IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Booth_Algorithmus
        PORT(
            clk       : IN  std_logic;
            cnt       : IN  std_logic;
            reset     : IN  std_logic;
            sw        : IN  std_logic_vector(3 downto 0);
            result    : OUT std_logic_vector(9 downto 0);
            segments  : OUT std_logic_vector(6 downto 0)
        );
    END COMPONENT;

    -- Signals to connect to the UUT
    SIGNAL clk       : std_logic := '0';
    SIGNAL cnt       : std_logic := '0';
    SIGNAL reset     : std_logic := '0';
    SIGNAL sw        : std_logic_vector(3 downto 0) := (others => '0');
    SIGNAL result    : std_logic_vector(9 downto 0);
    SIGNAL segments  : std_logic_vector(6 downto 0);

    -- Clock period definition
    CONSTANT clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: Booth_Algorithmus PORT MAP (
        clk       => clk,
        cnt       => cnt,
        reset     => reset,
        sw        => sw,
        result    => result,
        segments  => segments
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        cnt <= '0';
        sw <= (others => '0');
        wait for 20 ns;

        reset <= '0';
        wait for 20 ns;

        -- Set x = 3 (binary: 0011)
        sw <= "0011";
	cnt <= '1';
        wait for clk_period;
        cnt <= '0';
        wait for 20 ns;

        -- Set y = 2 (binary: 0010)
        sw <= "0010";
	cnt <= '1';
        wait for clk_period;
        cnt <= '0';
        wait for 20 ns;

        -- Observe the result (expecting x * y = 6, binary: 0000000110)
        
	cnt <= '1';
        wait for clk_period;
        cnt <= '0';
        wait for 20 ns;
	wait for 100 ns;



        -- Test another case: x = -3 (binary: 1101), y = 2 (binary: 0010)
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        
        sw <= "1101"; -- x = -3
	cnt <= '1';
        wait for clk_period;
        cnt <= '0';
        wait for 20 ns;

        
        sw <= "0010"; -- y = 2
	cnt <= '1';
        wait for clk_period;
        cnt <= '0';
        wait for 20 ns;

        -- Observe the result (expecting x * y = -6, binary: 1111111010)
        cnt <= '1';
        wait for clk_period;
        cnt <= '0';
        wait for 20 ns;
	wait for 100 ns;

        -- Stop simulation
        wait;
    end process;

END behavior;
