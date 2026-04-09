--[[
T-OoM - is a simple Out of Mana announcer addon for Turtle WoW.
T-OoM - это простой аддон для объявления об окончании маны для сервера Turtle WoW.

Addon GitHub link: https://github.com/whtmst/t-oom

Author: Mikhail Palagin (Wht Mst)
Website: https://band.link/whtmst

Compatibility:
- Designed for World of Warcraft 1.12.0 (Vanilla)
- Optimized for Turtle WoW server
- Fallback logic for other 1.12.0 servers
--]]

-- ============================================================================
-- T-OoM - Главный файл-координатор
-- ============================================================================
-- Создаёт глобальную таблицу T_OoM и регистрирует обработчик событий
-- ============================================================================

-- Глобальная таблица аддона (namespace)
-- Важно: не перезаписываем, если уже создана локализацией!
if not T_OoM then T_OoM = {} end

-- ============================================================================
-- Локализация (по умолчанию ruRU, переключение через /toom lang)
-- ============================================================================
-- T_OoM.L уже заполнен файлами локализации, не трогаем

-- ============================================================================
-- Загрузка локали
-- ============================================================================
function T_OoM:LoadLocale(localeCode)
    -- Очищаем старую локаль
    T_OoM.L = {}

    -- Загружаем нужную локаль
    if localeCode == "ruRU" and T_OoM_Locale_ruRU then
        for key, value in pairs(T_OoM_Locale_ruRU) do
            T_OoM.L[key] = value
        end
    elseif localeCode == "enUS" and T_OoM_Locale_enUS then
        for key, value in pairs(T_OoM_Locale_enUS) do
            T_OoM.L[key] = value
        end
    else
        -- Fallback на ruRU
        if T_OoM_Locale_ruRU then
            for key, value in pairs(T_OoM_Locale_ruRU) do
                T_OoM.L[key] = value
            end
        end
    end
end

-- ============================================================================
-- Фрейм для обработки событий
-- ============================================================================
T_OoM.CoreFrame = CreateFrame("Frame")
T_OoM.CoreFrame:RegisterEvent("ADDON_LOADED")
T_OoM.CoreFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local minimapButtonCreated = false

T_OoM.CoreFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "T-OoM" then
        -- ====================================================================
        -- 1. Инициализация SavedVariables
        -- ====================================================================
        T_OoM:InitializeSavedVariables()

        -- ====================================================================
        -- 2. Загрузка локали
        -- ====================================================================
        T_OoM:LoadLocale(T_OoM_Config.language)

        -- ====================================================================
        -- 3. Инициализация UI компонентов
        -- ====================================================================
        T_OoM:CreateTooltip()

        -- ====================================================================
        -- 4. Инициализация модулей
        -- ====================================================================
        T_OoM:InitializeManaMonitor()
        T_OoM:InitializeUIDisplay()

        -- ====================================================================
        -- 5. Сообщение о загрузке
        -- ====================================================================
        T_OoM:Print(T_OoM.L.ADDON_LOADED)
        DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6EC[T-OoM]|r English? Type /toom lang en")

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- ====================================================================
        -- Создание кнопки миникарты при входе в мир
        -- ====================================================================
        if not minimapButtonCreated then
            T_OoM:CreateMinimapButton()
            minimapButtonCreated = true
            T_OoM.CoreFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    end
end)
