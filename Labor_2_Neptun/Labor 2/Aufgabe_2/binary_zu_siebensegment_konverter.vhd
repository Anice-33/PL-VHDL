library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--===============================================================================
-- Entity declaration
--===============================================================================
entity binary_zu_siebensegment_konverter is
    generic (
        G_BCD_DIGITS : integer range 1 to 6 := 6;  -- Увеличено до 6 цифр
        G_INPUT_WIDTH : integer := 20              -- Увеличено до 20 бит
    );
    port (
        clk_in : in std_logic;                     -- Clock signal
        rst_in : in std_logic;                     -- Reset signal
        binary_in : in std_logic_vector(G_INPUT_WIDTH-1 downto 0); -- Binary input
        start_in : in std_logic;                   -- Start conversion signal
        busy_out : out std_logic;                  -- Busy signal
        seg_out0 : out std_logic_vector(6 downto 0); -- Segment outputs for bcd_0
        seg_out1 : out std_logic_vector(6 downto 0); -- Segment outputs for bcd_1
        seg_out2 : out std_logic_vector(6 downto 0); -- Segment outputs for bcd_2
        seg_out3 : out std_logic_vector(6 downto 0); -- Segment outputs for bcd_3
        seg_out4 : out std_logic_vector(6 downto 0); -- Segment outputs for bcd_4
        seg_out5 : out std_logic_vector(6 downto 0) -- Segment outputs for bcd_5
        -- led_out : out std_logic_vector(23 downto 0)  -- 24 LEDs, 4 for each BCD digit
    );
end entity binary_zu_siebensegment_konverter;

--===============================================================================
-- architecture declaration
--===============================================================================
architecture Behavioral of binary_zu_siebensegment_konverter is

    -- Component binary_to_bcd
    component binary_to_bcd
        generic (
            G_BCD_DIGITS : integer range 1 to 6 := 6;
            G_INPUT_WIDTH : integer := 20          -- Увеличено до 20 бит
        );
        port (
            clk_in : in std_logic;
            rst_in : in std_logic;
            binary_in : in std_logic_vector(G_INPUT_WIDTH-1 downto 0);
            start_in : in std_logic;
            bcd_out : out std_logic_vector((G_BCD_DIGITS * 4) - 1 downto 0);
            busy_out : out std_logic
        );
    end component;

    -- Component bcd_zu_siebensegment_konverter
    component bcd_zu_siebensegment_konverter
        port (
            bcd_in : in std_logic_vector(3 downto 0);
            LTN : in std_logic;
            BLN : in std_logic;
            seg_out : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Internal signal for bcd_out
    signal bcd_out_internal : std_logic_vector((G_BCD_DIGITS * 4) - 1 downto 0);

    -- Separate signals for each BCD digit
    signal bcd_0 : std_logic_vector(3 downto 0);
    signal bcd_1 : std_logic_vector(3 downto 0);
    signal bcd_2 : std_logic_vector(3 downto 0);
    signal bcd_3 : std_logic_vector(3 downto 0);
    signal bcd_4 : std_logic_vector(3 downto 0);
    signal bcd_5 : std_logic_vector(3 downto 0);

    -- Constant signals for LTN and BLN
    constant LTN_const : std_logic := '1';
    constant BLN_const : std_logic := '1';

begin
    -- Instantiation of binary_to_bcd component
    binary_to_bcd_inst : binary_to_bcd
        generic map (
            G_BCD_DIGITS => G_BCD_DIGITS,
            G_INPUT_WIDTH => G_INPUT_WIDTH
        )
        port map (
            clk_in => clk_in,
            rst_in => rst_in,
            binary_in => binary_in,
            start_in => start_in,
            bcd_out => bcd_out_internal,
            busy_out => busy_out
        );

    -- Assign parts of bcd_out_internal to individual BCD digits
    bcd_0 <= bcd_out_internal(3 downto 0);
    bcd_1 <= bcd_out_internal(7 downto 4);
    bcd_2 <= bcd_out_internal(11 downto 8);
    bcd_3 <= bcd_out_internal(15 downto 12);
    bcd_4 <= bcd_out_internal(19 downto 16);
    bcd_5 <= bcd_out_internal(23 downto 20);

    -- Instantiation of bcd_zu_siebensegment_konverter components for each digit
    bcd_zu_siebensegment_konverter_inst0 : bcd_zu_siebensegment_konverter
        port map (
            bcd_in => bcd_0,
            LTN => LTN_const,
            BLN => BLN_const,
            seg_out => seg_out0
        );

    bcd_zu_siebensegment_konverter_inst1 : bcd_zu_siebensegment_konverter
        port map (
            bcd_in => bcd_1,
            LTN => LTN_const,
            BLN => BLN_const,
            seg_out => seg_out1
        );

    bcd_zu_siebensegment_konverter_inst2 : bcd_zu_siebensegment_konverter
        port map (
            bcd_in => bcd_2,
            LTN => LTN_const,
            BLN => BLN_const,
            seg_out => seg_out2
        );

    bcd_zu_siebensegment_konverter_inst3 : bcd_zu_siebensegment_konverter
        port map (
            bcd_in => bcd_3,
            LTN => LTN_const,
            BLN => BLN_const,
            seg_out => seg_out3
        );

    bcd_zu_siebensegment_konverter_inst4 : bcd_zu_siebensegment_konverter
        port map (
            bcd_in => bcd_4,
            LTN => LTN_const,
            BLN => BLN_const,
            seg_out => seg_out4
        );

    bcd_zu_siebensegment_konverter_inst5 : bcd_zu_siebensegment_konverter
        port map (
            bcd_in => bcd_5,
            LTN => LTN_const,
            BLN => BLN_const,
            seg_out => seg_out5
        );

    -- Assign values of signals bcd_0, bcd_1, bcd_2, ..., bcd_5 to LED outputs
    -- led_out(3 downto 0)   <= bcd_0;  -- LEDs for 1st BCD digit
    -- led_out(7 downto 4)   <= bcd_1;  -- LEDs for 2nd BCD digit
    -- led_out(11 downto 8)  <= bcd_2;  -- LEDs for 3rd BCD digit
    -- led_out(15 downto 12) <= bcd_3;  -- LEDs for 4th BCD digit
    -- led_out(19 downto 16) <= bcd_4;  -- LEDs for 5th BCD digit
    -- led_out(23 downto 20) <= bcd_5;  -- LEDs for 6th BCD digit

end architecture Behavioral;
