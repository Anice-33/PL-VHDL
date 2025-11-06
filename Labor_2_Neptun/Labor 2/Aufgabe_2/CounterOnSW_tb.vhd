library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CounterOnSW_tb is
    -- Testbench не имеет портов
end CounterOnSW_tb;

architecture Behavioral of CounterOnSW_tb is
    -- Компонент для тестирования
    component CounterOnSW is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            sw  : in STD_LOGIC;
            count : out INTEGER range 0 to 255
        );
    end component;

    -- Сигналы для подключения к портам компонента
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal sw  : STD_LOGIC := '0';
    signal count : INTEGER range 0 to 255;

    -- Тактовая частота (50 МГц, период 20 нс)
    constant clk_period : time := 20 ns;
begin
    -- Инстанцирование тестируемого модуля
    uut: CounterOnSW
        port map (
            clk => clk,
            rst => rst,
            sw => sw,
            count => count
        );

    -- Генератор тактового сигнала
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Тестовый процесс
    stimulus: process
    begin
        -- Сброс системы
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';

        -- Симуляция изменения сигнала sw
        wait for 3 * clk_period;
        sw <= '1'; -- Фронт 0->1
        wait for 5 * clk_period;
        sw <= '0'; -- Падение 1->0 (ничего не должно измениться)
        wait for 2 * clk_period;
        sw <= '1'; -- Ещё один фронт 0->1
        wait for clk_period;
        sw <= '0';

        -- Проверка на несколько фронтов
        wait for 5 * clk_period;
        sw <= '1';
        wait for clk_period;
        sw <= '0';
        wait for clk_period;
        sw <= '1';
        wait for clk_period;
        sw <= '0';

        -- Завершение симуляции
        wait for 10 * clk_period;
        assert false report "Simulation Finished" severity note;
        wait;
    end process;

end Behavioral;
