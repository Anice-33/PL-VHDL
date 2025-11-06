library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is 
    generic (
        CLOCK_FREQ : integer := 50000000 -- Значение по умолчанию: 50 МГц
    );
    Port (
        clk       : in STD_LOGIC;  -- Входной сигнал тактовой частоты
        reset     : in STD_LOGIC;  -- Сброс
        seconds   : inout STD_LOGIC_VECTOR(19 downto 0); -- Выход, показывающий секунды
		  start     : in STD_LOGIC;  -- Кнопка Start
        stop      : in STD_LOGIC;  -- Кнопка Stop
        seg_out0  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 0
        seg_out1  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 1
        seg_out2  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 2
        seg_out3  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 3
        seg_out4  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 4
        seg_out5  : out STD_LOGIC_VECTOR(6 downto 0)  -- Сегменты для цифры 5
    );
end counter;

architecture Behavioral of counter is

    -- Внутренние сигналы
    signal count          : integer := 0; -- Для деления частоты 50 МГц до 1 Гц
    signal seconds_binary : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
    signal busy           : STD_LOGIC; -- Сигнал занятости
	 signal running        : STD_LOGIC := '0'; -- Состояние счетчика ('1' - работает, '0' - остановлен)
    signal start_pressed  : STD_LOGIC := '0'; -- Фиксация нажатия start
    signal stop_pressed   : STD_LOGIC := '0'; -- Фиксация нажатия stop

    -- Константа
    constant MAX_SECONDS : unsigned(19 downto 0) := to_unsigned(999999, 20);

    -- Внутренние сигналы для подключения модуля binary_zu_siebensegment_konverter
    signal seg_out_internal : STD_LOGIC_VECTOR(41 downto 0); -- 6 сегментов * 7 бит
    
begin

	-- Процесс управления состоянием кнопок
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                start_pressed <= '0';
                stop_pressed  <= '0';
                running       <= '0';
            else
                -- Обработка кнопки start
                if start = '1' and start_pressed = '0' then
                    start_pressed <= '1';
                    running       <= '1'; -- Переход в состояние запуска
                elsif start = '0' then
                    start_pressed <= '0';
                end if;

                -- Обработка кнопки stop
                if stop = '1' and stop_pressed = '0' then
                    stop_pressed <= '1';
                    running      <= '0'; -- Переход в состояние остановки
                elsif stop = '0' then
                    stop_pressed <= '0';
                end if;
            end if;
        end if;
    end process;
    -- Основной процесс
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count          <= 0;
                seconds_binary <= (others => '0');
            elsif running = '1' then
                if count = CLOCK_FREQ-1 then  -- Счетчик до 50 миллионов тактов (50 МГц)
                    count <= 0;

                    if unsigned(seconds_binary) = MAX_SECONDS then
                        seconds_binary <= (others => '0'); -- Сброс секунд в 0
                    else
                        seconds_binary <= std_logic_vector(unsigned(seconds_binary) + 1);
                    end if;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    -- Подключение модуля binary_zu_siebensegment_konverter
    binary_zu_siebensegment_konverter_inst : entity work.binary_zu_siebensegment_konverter
        generic map (
            G_BCD_DIGITS => 6,  -- Шесть разрядов
            G_INPUT_WIDTH => 20 -- Ширина бинарного входа
        )
        port map (
            clk_in    => clk,
            rst_in    => reset,
				--rst_in    => '0',
            binary_in => seconds_binary,
            start_in  => '1', -- Всегда активный
            busy_out  => busy,
            seg_out0  => seg_out0,
            seg_out1  => seg_out1,
            seg_out2  => seg_out2,
            seg_out3  => seg_out3,
            seg_out4  => seg_out4,
            seg_out5  => seg_out5
        );

end Behavioral;
