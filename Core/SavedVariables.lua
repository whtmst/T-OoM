-- ============================================================================
-- T-OoM - Сохранённые данные (SavedVariables)
-- ============================================================================
-- Инициализация и работа с таблицей T_OoM_Config
-- Эта таблица автоматически загружается/сохраняется WoW через SavedVariables в .toc
-- ============================================================================

-- T_OoM может ещё не существовать (загрузка раньше T-OoM.lua)
if not T_OoM then T_OoM = {} end

-- ============================================================================
-- Инициализация SavedVariables
-- ============================================================================
function T_OoM:InitializeSavedVariables()
    -- Создаём таблицу, если это первый запуск
    if not T_OoM_Config then
        T_OoM_Config = {}
    end

    -- Включён ли аддон (используем 1/0 вместо true/false — в 1.12 false теряется при reload)
    if T_OoM_Config.enabled == nil then
        T_OoM_Config.enabled = 1
    end

    -- Язык (по умолчанию русский)
    if not T_OoM_Config.language then
        T_OoM_Config.language = "ruRU"
    end

    -- Пороги маны (0-100%)
    if not T_OoM_Config.threshold1 then
        T_OoM_Config.threshold1 = 30  -- Мало маны
    end
    if not T_OoM_Config.threshold2 then
        T_OoM_Config.threshold2 = 15  -- Критически мало маны
    end
    if not T_OoM_Config.threshold3 then
        T_OoM_Config.threshold3 = 5   -- Нет маны
    end

    -- Сообщения для каждого порога
    if not T_OoM_Config.message1 then
        if T_OoM_Config.language == "ruRU" then
            T_OoM_Config.message1 = "--- МАЛО МАНЫ ---"
        else
            T_OoM_Config.message1 = "--- LOW ON MANA ---"
        end
    end
    if not T_OoM_Config.message2 then
        if T_OoM_Config.language == "ruRU" then
            T_OoM_Config.message2 = "--- КРИТИЧЕСКИ МАЛО МАНЫ ---"
        else
            T_OoM_Config.message2 = "--- CRITICAL LOW MANA ---"
        end
    end
    if not T_OoM_Config.message3 then
        if T_OoM_Config.language == "ruRU" then
            T_OoM_Config.message3 = "--- ЗАКОНЧИЛАСЬ МАНА ---"
        else
            T_OoM_Config.message3 = "--- OUT OF MANA ---"
        end
    end

    -- Канал чата (SAY, PARTY, RAID, GUILD, YELL)
    if not T_OoM_Config.chatChannel then
        T_OoM_Config.chatChannel = "SAY"
    end

    -- Режим работы: "world" (открытый мир), "instance" (подземелья/рейды), "always" (везде)
    if not T_OoM_Config.instanceMode then
        T_OoM_Config.instanceMode = "instance"  -- По умолчанию: только подземелья/рейды
    end

    -- Позиция миникарты (угол в градусах, 150 = 10 часов)
    if not T_OoM_Config.minimapAngle then
        T_OoM_Config.minimapAngle = 150
    end

    -- Режим свободного перемещения кнопки
    if T_OoM_Config.minimapFreeMode == nil then
        T_OoM_Config.minimapFreeMode = false
    end

    -- Позиция в свободном режиме
    if not T_OoM_Config.minimapFreePos then
        T_OoM_Config.minimapFreePos = {
            x = -100,
            y = -100,
        }
    end

    -- Позиция окна настроек
    if not T_OoM_Config.configWindowPos then
        T_OoM_Config.configWindowPos = {
            point = "CENTER",
            x = 0,
            y = 0,
        }
    end

    -- Режим работы: "world" (открытый мир), "instance" (подземелья/рейды), "always" (везде)
    if not T_OoM_Config.instanceMode then
        T_OoM_Config.instanceMode = "instance"  -- По умолчанию: только подземелья/рейды
    end
end

-- ============================================================================
-- Получение значения настройки
-- ============================================================================
function T_OoM:GetConfig(key)
    if T_OoM_Config and T_OoM_Config[key] ~= nil then
        return T_OoM_Config[key]
    end
    return nil
end

-- ============================================================================
-- Установка значения настройки
-- ============================================================================
function T_OoM:SetConfig(key, value)
    if T_OoM_Config then
        T_OoM_Config[key] = value
    end
end

-- ============================================================================
-- Сброс настроек до умолчательных
-- ============================================================================
function T_OoM:ResetConfig()
    if not T_OoM_Config then
        T_OoM_Config = {}
    end

    T_OoM_Config.enabled = 1
    T_OoM_Config.threshold1 = 30
    T_OoM_Config.threshold2 = 15
    T_OoM_Config.threshold3 = 5

    if T_OoM_Config.language == "ruRU" then
        T_OoM_Config.message1 = "--- МАЛО МАНЫ ---"
        T_OoM_Config.message2 = "--- КРИТИЧЕСКИ МАЛО МАНЫ ---"
        T_OoM_Config.message3 = "--- ЗАКОНЧИЛАСЬ МАНА ---"
    else
        T_OoM_Config.message1 = "--- LOW ON MANA ---"
        T_OoM_Config.message2 = "--- CRITICAL LOW MANA ---"
        T_OoM_Config.message3 = "--- OUT OF MANA ---"
    end

    T_OoM_Config.chatChannel = "SAY"
    T_OoM_Config.instanceMode = "instance"
    T_OoM_Config.minimapAngle = 150
    T_OoM_Config.minimapFreeMode = false
    T_OoM_Config.minimapFreePos = {x = -100, y = -100}

    T_OoM:Print(T_OoM.L.SETTINGS_RESET)
end
