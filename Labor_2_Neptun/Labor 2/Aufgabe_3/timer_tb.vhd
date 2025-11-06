library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_timer is
-- Testbench does not have any ports.
end tb_timer;

architecture Behavioral of tb_timer is

    -- Component Declaration for the Unit Under Test (UUT)
    component timer
        generic (
            CLOCK_FREQ : integer := 50000000
        );
        Port (
            clk       : in STD_LOGIC;
            reset     : in STD_LOGIC;
            start     : in STD_LOGIC;
            stop      : in STD_LOGIC;
            seg_out0  : out STD_LOGIC_VECTOR(6 downto 0);
            seg_out1  : out STD_LOGIC_VECTOR(6 downto 0);
            seg_out2  : out STD_LOGIC_VECTOR(6 downto 0);
            seg_out3  : out STD_LOGIC_VECTOR(6 downto 0);
            seg_out4  : out STD_LOGIC_VECTOR(6 downto 0);
            seg_out5  : out STD_LOGIC_VECTOR(6 downto 0);
            delimiter1 : out STD_LOGIC;
            delimiter2 : out STD_LOGIC
        );
    end component;

    -- Signals to connect to UUT
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal start     : STD_LOGIC := '0';
    signal stop      : STD_LOGIC := '0';
    signal seg_out0  : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_out1  : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_out2  : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_out3  : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_out4  : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_out5  : STD_LOGIC_VECTOR(6 downto 0);
    signal delimiter1 : STD_LOGIC;
    signal delimiter2 : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 20 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: timer
        generic map (
            CLOCK_FREQ => 50000000
        )
        port map (
            clk       => clk,
            reset     => reset,
            start     => start,
            stop      => stop,
            seg_out0  => seg_out0,
            seg_out1  => seg_out1,
            seg_out2  => seg_out2,
            seg_out3  => seg_out3,
            seg_out4  => seg_out4,
            seg_out5  => seg_out5,
            delimiter1 => delimiter1,
            delimiter2 => delimiter2
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_process : process
    begin
        -- Initialize inputs
        reset <= '1';
        start <= '0';
        stop <= '0';
        wait for 100 ns;

        -- Deassert reset
        reset <= '0';
        wait for 100 ns;

        -- Start the timer
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for 10 ms; -- Simulate for some time

        -- Stop the timer
        stop <= '1';
        wait for clk_period;
        stop <= '0';
        wait for 100 ns;

        -- Restart the timer
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for 5 ms;

        -- Apply reset while running
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- End simulation
        wait for 10 ms;
        wait;
    end process;

end Behavioral;
