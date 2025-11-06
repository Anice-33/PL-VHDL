library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--===============================================================================
-- Entity declaration
--===============================================================================
entity binary_to_bcd_tb is
end binary_to_bcd_tb;


--===============================================================================
-- architecture declaration
--===============================================================================
architecture behavior of binary_to_bcd_tb is
    constant c_CLOCK_PERIOD : time := 10 ns;

    -- Signals
    signal clk_in : std_logic := '0';
    signal rst_in : std_logic := '0';
    signal binary_in : std_logic_vector(4 downto 0) := (others => '0');
    signal start_in : std_logic := '0';
    signal bcd_out : std_logic_vector(7 downto 0);
    signal busy_out : std_logic;

	 
--===============================================================================
-- architecture begin
--===============================================================================
begin
    uut: entity work.binary_to_bcd
        generic map (
            G_BCD_DIGITS => 2,
            G_INPUT_WIDTH => 5
        )
        port map (
            clk_in => clk_in,
            rst_in => rst_in,
            binary_in => binary_in,
            start_in => start_in,
            bcd_out => bcd_out,
            busy_out => busy_out
        );

    p_clk_gen: process
    begin
        clk_in <= '0';
        wait for c_CLOCK_PERIOD / 2;
        clk_in <= '1';
        wait for c_CLOCK_PERIOD / 2;
    end process p_clk_gen;

    p_stimulus: process
    begin
        rst_in <= '1';
        wait for c_CLOCK_PERIOD;
        rst_in <= '0';
        wait for c_CLOCK_PERIOD;

        -- Test 1: Convert binary 10 (00010) to BCD
        binary_in <= "01010";  -- binary 10
        start_in <= '1';
        wait for c_CLOCK_PERIOD;
        start_in <= '0';

        wait until busy_out = '0';
        
        assert (bcd_out = "00010000")
            report "Test 1 failed: BCD output mismatch"
            severity error;
        
        -- Test 2: Convert binary 17 (10001) to BCD
        binary_in <= "10001";  -- binary 17
        start_in <= '1';
        wait for c_CLOCK_PERIOD;
        start_in <= '0';

        wait until busy_out = '0';
        
        assert (bcd_out = "00010111")
            report "Test 2 failed: BCD output mismatch"
            severity error;

        wait;
    end process p_stimulus;

end behavior;
