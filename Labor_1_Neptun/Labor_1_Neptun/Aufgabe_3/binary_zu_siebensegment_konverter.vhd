library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--===============================================================================
-- Entity declaration
--===============================================================================
entity binary_zu_siebensegment_konverter is
    generic (
        G_BCD_DIGITS : integer range 1 to 5 := 3;  -- Number of BCD digits
        G_INPUT_WIDTH : integer := 10              -- Width of the binary input
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
        led_out : out std_logic_vector(11 downto 0)  -- 12 LEDs, 4 for each BCD digit
    );
end entity binary_zu_siebensegment_konverter;


--===============================================================================
-- architecture declaration
--===============================================================================
architecture Behavioral of binary_zu_siebensegment_konverter is

    -- Component binary_to_bcd
    component binary_to_bcd
        generic (
            G_BCD_DIGITS : integer range 1 to 5 := 3;
            G_INPUT_WIDTH : integer := 10          -- Updated to 10 bits
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

    -- Constant signals for LTN and BLN because there aren’t enough buttons on de-10
    constant LTN_const : std_logic := '1';
    constant BLN_const : std_logic := '1';

	 
--===============================================================================
-- architecture begin
--===============================================================================
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

    -- Assign values of signals bcd_0, bcd_1, bcd_2 to LED outputs
    led_out(3 downto 0)   <= bcd_0;  -- LEDs for 1 BCD digit
    led_out(7 downto 4)   <= bcd_1;  -- LEDs for 2 BCD digit
    led_out(11 downto 8)  <= bcd_2;  -- LEDs for 3 BCD digit

end architecture Behavioral;
