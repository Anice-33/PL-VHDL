library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uhr is
    generic (
        CLOCK_FREQ : integer := 50000000 -- Значение по умолчанию: 50 МГц
    );
    Port (
        clk       : in STD_LOGIC;  -- Входной сигнал тактовой частоты
        reset     : in STD_LOGIC;  -- Сброс
        start     : in STD_LOGIC;  -- Кнопка Start
        stop      : in STD_LOGIC;  -- Кнопка Stop
        SW        : in STD_LOGIC_VECTOR(5 downto 0); -- Переключатели для настройки времени
        SW8       : in STD_LOGIC; -- Режим настройки часов
        seg_out0  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 0
        seg_out1  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 1
        seg_out2  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 2
        seg_out3  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 3
        seg_out4  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 4
        seg_out5  : out STD_LOGIC_VECTOR(6 downto 0); -- Сегменты для цифры 5
        delimiter1 : out STD_LOGIC; -- Делитель между часами и минутами
        delimiter2 : out STD_LOGIC  -- Делитель между минутами и секундами
    );
end uhr;

architecture Behavioral of uhr is

    -- Внутренние сигналы
    signal count          : integer := 0; -- Для деления частоты 50 МГц до 1 Гц
    signal seconds        : integer := 0;
    signal minutes        : integer := 0;
    signal hours          : integer := 0;
    signal binary_time    : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
    signal running        : STD_LOGIC := '0'; -- Состояние таймера ('1' - работает, '0' - остановлен)
    signal start_pressed  : STD_LOGIC := '0';
    signal stop_pressed   : STD_LOGIC := '0';
    signal setup          : STD_LOGIC := '0'; -- Режим настройки

    -- Константы
    constant MAX_SECONDS : integer := 59;
    constant MAX_MINUTES : integer := 59;
    constant MAX_HOURS   : integer := 99; -- Ограничение на 2 разряда для часов

begin

    delimiter1 <= '0';
    delimiter2 <= '0';

    -- Управление состоянием кнопок
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                start_pressed <= '0';
                stop_pressed  <= '0';
                running       <= '0';
                setup         <= '0';
            else
                -- Режим настройки
                if SW8 = '1' then
                    setup <= '1';
                    running <= '0';
                else
                    setup <= '0';
                end if;

                -- Обработка кнопки start
                if start = '1' and start_pressed = '0' then
                    start_pressed <= '1';
                    running       <= '1';
                elsif start = '0' then
                    start_pressed <= '0';
                end if;

                -- Обработка кнопки stop
                if stop = '1' and stop_pressed = '0' then
                    stop_pressed <= '1';
                    running      <= '0';
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
                count   <= 0;
                seconds <= 0;
                minutes <= 0;
                hours   <= 0;
            elsif setup = '1' then
                if count = (CLOCK_FREQ-1)/2 then
                    count <= 0;

                    if SW(0) = '1' then
                        seconds <= (seconds + 1) mod (10);
                    elsif SW(1) = '1' then
                        seconds <= (seconds + 10) mod (MAX_SECONDS + 1);
                    end if;

                    if SW(2) = '1' then
                        minutes <= (minutes + 1) mod (10);
                    elsif SW(3) = '1' then
                        minutes <= (minutes + 10) mod (MAX_MINUTES + 1);
                    end if;
						  
						  -- -- идея 1
						  -- if SW(4) = '1' then
                    --     hours <= (hours + 1) mod (10);
                    -- elsif SW(5) = '1' then
                    --     hours <= (hours + 10) mod (24);
                    -- end if;
						  
						  -- идея 2
						  
						  if SW(4) = '1' then
                        
								if (hours/10) > 1 then -- если первая цифра 2, то вторая только от 0 до 3
									hours <= (hours + 1) mod (4);
								else
									hours <= (hours + 1) mod (10); -- иначе при первой цифре 0 или 1, вторая от 0 до 9
								end if;			
									
                    elsif SW(5) = '1' then
								if (hours mod 10) > 3 then -- если вторая цифра больше 3, то перваярая только от 0 до 1
									hours <= (hours + 10) mod (20);
								else
									hours <= (hours + 10) mod (30); -- иначе при второй цифре 0-3, то первая от 0 до 2
								end if;	
						  
                    end if;
						  
						  
						  
						  -- рабочий вариант 1 sw

                    ----if SW(4) = '1' then
                    ----    hours <= (hours + 1) mod (24);
                    --elsif SW(5) = '1' then
							--	if hours > 23 then
							--		hours <= 23;
							--	else
							--		hours <= (hours + 10) mod (30);
							--	end if;
                    ----end if;

                else
                    count <= count + 1;
                end if;
            elsif running = '1' then
                if count = CLOCK_FREQ-1 then
                    count <= 0;

                    if seconds = MAX_SECONDS then
                        seconds <= 0;
                        if minutes = MAX_MINUTES then
                            minutes <= 0;
                            if hours = MAX_HOURS then
                                hours <= 0;
                            else
                                hours <= hours + 1;
                            end if;
                        else
                            minutes <= minutes + 1;
                        end if;
                    else
                        seconds <= seconds + 1;
                    end if;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    -- Конкатенация времени в одно бинарное число
    process(seconds, minutes, hours)
    begin
        binary_time <= std_logic_vector(to_unsigned(hours * 10000 + minutes * 100 + seconds, 20));
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
            binary_in => binary_time,
            start_in  => '1', -- Всегда активный
            busy_out  => open, -- Неприменяемый сигнал
            seg_out0  => seg_out0,
            seg_out1  => seg_out1,
            seg_out2  => seg_out2,
            seg_out3  => seg_out3,
            seg_out4  => seg_out4,
            seg_out5  => seg_out5
        );

end Behavioral;
