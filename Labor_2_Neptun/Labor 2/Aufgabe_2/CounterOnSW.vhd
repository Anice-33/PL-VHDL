library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CounterOnSW is
    Port (
        clk : in STD_LOGIC;          -- Системный тактовый сигнал
        rst : in STD_LOGIC;          -- Сигнал сброса
        sw  : in STD_LOGIC;          -- Входной сигнал переключателя
        count : out INTEGER range 0 to 255  -- Выход счётчика
    );
end CounterOnSW;

architecture Behavioral of CounterOnSW is
    signal sw_prev : STD_LOGIC := '0';  -- Хранение предыдущего состояния сигнала sw
    signal counter : INTEGER range 0 to 255 := 0; -- Внутренний счётчик
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            sw_prev <= '0';
        elsif rising_edge(clk) then
            -- Проверка на фронт сигнала sw
            if sw = '1' and sw_prev = '0' then
                counter <= counter + 1;
            end if;
            sw_prev <= sw; -- Обновляем предыдущее состояние
        end if;
    end process;

    count <= counter; -- Присваиваем значение выходу
end Behavioral;
