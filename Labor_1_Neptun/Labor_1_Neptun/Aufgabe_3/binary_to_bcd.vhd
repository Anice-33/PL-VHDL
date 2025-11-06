--
-- Author: Friedrich Maximilian Sokol, 2024
--
-- Implements the shift-add-3 algorithm to convert binary input to BCD
-- Uses generics to set the number of digits for the BCD output
-- Implements a synchronous reset
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------------------------------------------------------------------------
-- entity
------------------------------------------------------------------------------

entity binary_to_bcd is
    generic ( G_BCD_DIGITS : integer range 1 to 5 := 2;                       -- number of output digits
              G_INPUT_WIDTH : integer := 5                                    -- input bit width
            );
    port    ( clk_in : in std_logic;                                          -- clock input
              rst_in : in std_logic;                                          -- reset input
              binary_in : in std_logic_vector(G_INPUT_WIDTH-1 downto 0);      -- binary input, to be converted into BCD
              start_in : in std_logic;                                        -- pull high to start conversion, control signal
              bcd_out : out std_logic_vector((G_BCD_DIGITS * 4) - 1 downto 0);    -- BCD output (for example: G_BCD_DIGITS = 2, bcd_out = (bcd_1(3), bcd_1(2), bcd_1(1), bcd_1(0), bcd_0(3), bcd_0(2), bcd_0(1), bcd_0(0)))
              busy_out : out std_logic                                        -- '1' when currently converting, '0' when not, control signal
            );
end entity binary_to_bcd;


------------------------------------------------------------------------------
-- architecture
------------------------------------------------------------------------------

architecture Behavioral of binary_to_bcd is


------------------------------------------------------------------------------
-- type definitions
------------------------------------------------------------------------------

type states is (STATE_IDLE, STATE_SHIFT, STATE_ADD_3);


------------------------------------------------------------------------------
-- signals
------------------------------------------------------------------------------

signal state : states := STATE_IDLE;

signal shift : std_logic_vector((G_BCD_DIGITS * 4) - 1 downto 0) := (others => '0');
signal count_internal : std_logic_vector(G_INPUT_WIDTH-1 downto 0) := (others => '0');
signal algorithm_loop_counter : unsigned(G_INPUT_WIDTH-1 downto 0) := (others => '0');


begin


------------------------------------------------------------------------------
-- processes
------------------------------------------------------------------------------

p_shift_add_3: process (clk_in, rst_in)
    variable digit_msb : integer := 0;
    variable digit_lsb : integer := 0;
begin

    if rising_edge(clk_in) then

        case state is

        when STATE_IDLE =>

            count_internal <= binary_in;
            algorithm_loop_counter <= (others => '0');
            busy_out <= '0';
            bcd_out <= shift;

            if (start_in = '1') then
                state <= STATE_SHIFT;
                shift <= (others => '0');
            end if;

        when STATE_SHIFT =>

            -- shift to the left
            shift((G_BCD_DIGITS * 4) - 1 downto 1) <= shift((G_BCD_DIGITS * 4) - 2 downto 0);
            shift(0) <= count_internal(G_INPUT_WIDTH-1);
            count_internal(G_INPUT_WIDTH-1 downto 1) <= count_internal(G_INPUT_WIDTH-2 downto 0);
            count_internal(0) <= '0';

            -- Set busy flag
            busy_out <= '1';

            -- check if we can stop
            if (algorithm_loop_counter = G_INPUT_WIDTH-1) then
                state <= STATE_IDLE;
                algorithm_loop_counter <= (others => '0');
            else
                state <= STATE_ADD_3;
            end if;

        when STATE_ADD_3 =>

            -- check if a three needs to be added to any digit
            for i in 0 to G_BCD_DIGITS-1 loop
                digit_msb := ((i + 1) * 4) - 1;
                digit_lsb := i * 4;
                if (unsigned(shift(digit_msb downto digit_lsb)) > to_unsigned(4, 4)) then
                    shift(digit_msb downto digit_lsb) <= std_logic_vector(unsigned(shift(digit_msb downto digit_lsb)) + to_unsigned(3, 4));
                end if;
            end loop;

            -- increase loop counter
            algorithm_loop_counter <= algorithm_loop_counter + to_unsigned(1, G_INPUT_WIDTH);
            state <= STATE_SHIFT;

        when others =>

            -- error state, we should not be here
            for i in 0 to G_BCD_DIGITS-1 loop
                -- Display E for error
                bcd_out(((i + 1) * 4) - 1 downto i * 4) <= std_logic_vector(to_unsigned(14, 4));
            end loop;

        end case;

        -- synchronous reset
        if (rst_in = '1') then
            state <= STATE_IDLE;
            algorithm_loop_counter <= (others => '0');
            count_internal <= binary_in;
            shift <= (others => '0');
            busy_out <= '0';
            bcd_out <= (others => '1');
        end if;
    end if;
end process p_shift_add_3;

end architecture Behavioral;