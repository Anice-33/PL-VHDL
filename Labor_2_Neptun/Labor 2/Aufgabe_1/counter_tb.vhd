library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_tb is
end counter_tb;

architecture sim of counter_tb is

    -- Clock frequency and period for the testbench
    constant CLOCK_FREQ  : integer := 10; -- 10 Hz for testing
    constant CLOCKPERIOD : time := 1000 ms / CLOCK_FREQ;

    -- Testbench signals
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal start    : std_logic := '0';
    signal stop     : std_logic := '0';
    signal seconds  : std_logic_vector(19 downto 0) := (others => '0');
    signal seg_out0 : std_logic_vector(6 downto 0);
    signal seg_out1 : std_logic_vector(6 downto 0);
    signal seg_out2 : std_logic_vector(6 downto 0);
    signal seg_out3 : std_logic_vector(6 downto 0);
    signal seg_out4 : std_logic_vector(6 downto 0);
    signal seg_out5 : std_logic_vector(6 downto 0);

begin

    -- Instantiate the counter module (DUT - Device Under Test)
    i_counter : entity work.counter
        generic map(
            CLOCK_FREQ => CLOCK_FREQ
        )
        port map(
            clk      => clk,
            reset    => reset,
            seconds  => seconds,
            start    => start,
            stop     => stop,
            seg_out0 => seg_out0,
            seg_out1 => seg_out1,
            seg_out2 => seg_out2,
            seg_out3 => seg_out3,
            seg_out4 => seg_out4,
            seg_out5 => seg_out5
        );

    -- Clock generation
    clk <= not clk after CLOCKPERIOD / 2;

    -- Test process
    process
    begin
        -- Initial reset
        reset <= '1';
        wait for CLOCKPERIOD * 2; -- Hold reset for two clock cycles
        reset <= '0';
        wait for CLOCKPERIOD;

        -- Start the counter
        start <= '1';
        wait for CLOCKPERIOD * 10; -- Let the counter run for 10 clock cycles
        start <= '0';

        -- Stop the counter
        stop <= '1';
        wait for CLOCKPERIOD * 5; -- Hold the counter in a stopped state
        stop <= '0';

        -- Restart the counter
        start <= '1';
        wait for CLOCKPERIOD * 5;
        start <= '0';

        -- Assert reset again to test behavior
        reset <= '1';
        wait for CLOCKPERIOD * 2;
        reset <= '0';

        -- End simulation
        wait for CLOCKPERIOD * 10;
        assert false report "Testbench finished successfully." severity note;
        wait;
    end process;

end sim;
