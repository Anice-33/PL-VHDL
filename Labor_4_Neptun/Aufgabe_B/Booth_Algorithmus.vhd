library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity booth_multiplier_fpga is
    port(
        SW       : in  std_logic_vector(7 downto 0);  -- 8 Switches for input (2x 4-bit numbers)
        KEY      : in  std_logic_vector(1 downto 0);  -- KEY1 for confirmation
        LEDR     : out std_logic_vector(7 downto 0)   -- LEDs for output
    );
end booth_multiplier_fpga;

architecture behavioral of booth_multiplier_fpga is
    signal A, B        : std_logic_vector(3 downto 0);  -- Input numbers
    signal Product     : std_logic_vector(7 downto 0);  -- Result
    signal state       : integer := 0;                  -- State machine for input handling
    signal A_reg, B_reg : std_logic_vector(3 downto 0) := (others => '0'); -- Registers for inputs
begin
    process(KEY)
    begin
        if rising_edge(KEY(1)) then
            case state is
                when 0 =>  -- First number entry
                    A_reg <= SW(3 downto 0);
                    state <= 1;  -- Move to next state to read second number
                when 1 =>  -- Second number entry
                    B_reg <= SW(3 downto 0);
                    state <= 2;  -- Move to next state for computation
                when others =>  -- Compute result using Booth's algorithm
                    -- Booth Algorithm implementation
                    variable Accumulator : signed(7 downto 0) := (others => '0');
                    variable M           : signed(7 downto 0) := signed('0' & A_reg & "000");
                    variable Q           : signed(4 downto 0) := signed('0' & B_reg & '0');
                    variable Q_minus1    : std_logic := '0';
                    variable count       : integer := 4;

                    while count > 0 loop
                        if (Q(0) xor Q_minus1) = '1' then
                            if Q(0) = '1' then
                                Accumulator := Accumulator - M;
                            else
                                Accumulator := Accumulator + M;
                            end if;
                        end if;
                        -- Arithmetic right shift
                        Q_minus1 := Q(0);
                        Q := signed('0' & Q(4 downto 1));
                        Accumulator := Accumulator sra 1;
                        count := count - 1;
                    end loop;
                    
                    Product <= std_logic_vector(Accumulator & Q(3 downto 0));
                    LEDR <= Product;  -- Display result on LEDs
                    state <= 0;  -- Reset to initial state
            end case;
        end if;
    end process;
end behavioral;
