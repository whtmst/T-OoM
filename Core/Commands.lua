-- ============================================================================
-- T-OoM - Slash команды
-- ============================================================================
-- Обработка команд чата: /toom, /toom config, /toom lang
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- ============================================================================
-- Вспомогательная функция: вывод сообщений в чат
-- ============================================================================
function T_OoM:Print(msg)
    if not msg then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6EC[T-OoM]|r " .. msg)
end

-- ============================================================================
-- Обрезка пробелов по краям строки (Lua 5.0 совместимость)
-- ============================================================================
function T_OoM:Trim(s)
    if not s then return "" end
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

-- ============================================================================
-- Обработчик slash-команд
-- ============================================================================
function T_OoM:SlashCommand(msg)
    -- Приводим к нижнему регистру и убираем пробелы по краям
    local cmd = string.lower(self:Trim(msg or ""))

    -- Пустая команда - показываем справку
    if cmd == "" then
        self:PrintHelp()
        return
    end

    -- Разбираем команду и аргументы
    local args = {}
    for arg in string.gfind(cmd, "%S+") do
        table.insert(args, arg)
    end

    local command = args[1]
    local arg1 = args[2]

    -- ========================================================================
    -- Команда: /toom config (открыть окно настроек)
    -- ========================================================================
    if command == "config" then
        if T_OoM.configWindow then
            T_OoM.configWindow:Show()
        else
            T_OoM:CreateConfigWindow()
            if T_OoM.configWindow then
                T_OoM.configWindow:Show()
            end
        end
        self:Print(T_OoM.L.CMD_CONFIG_OPEN)
        return
    end

    -- ========================================================================
    -- Команда: /toom lang (смена языка)
    -- ========================================================================
    if command == "lang" then
        if not arg1 then
            self:Print(T_OoM.L.CMD_LANG)
            return
        end

        local newLang = string.lower(T_OoM:Trim(arg1))

        -- Поддерживаем ru, ruRU, en, enUS
        local localeCode
        if newLang == "ru" or newLang == "ruru" then
            localeCode = "ruRU"
        elseif newLang == "en" or newLang == "enus" then
            localeCode = "enUS"
        else
            self:Print(T_OoM.L.CMD_LANG_NOT_FOUND .. arg1)
            return
        end

        -- Переключаем локаль
        T_OoM_Config.language = localeCode
        T_OoM:LoadLocale(localeCode)

        -- Сбрасываем тексты на дефолтные для нового языка
        if localeCode == "ruRU" then
            T_OoM_Config.message1 = "--- МАЛО МАНЫ ---"
            T_OoM_Config.message2 = "--- КРИТИЧЕСКИ МАЛО МАНЫ ---"
            T_OoM_Config.message3 = "--- ЗАКОНЧИЛАСЬ МАНА ---"
        else
            T_OoM_Config.message1 = "--- LOW ON MANA ---"
            T_OoM_Config.message2 = "--- CRITICAL LOW MANA ---"
            T_OoM_Config.message3 = "--- OUT OF MANA ---"
        end

        self:Print(T_OoM.L.CMD_LANG_CHANGED .. (localeCode == "ruRU" and T_OoM.L.LANGUAGE_RU or T_OoM.L.LANGUAGE_EN))
        self:Print(T_OoM.L.CMD_LANG_RELOAD)
        return
    end

    -- ========================================================================
    -- Команда: /toom reset (сбросить позицию кнопки миникарты)
    -- ========================================================================
    if command == "reset" then
        if T_OoM_Config then
            T_OoM_Config.minimapFreeMode = false
            T_OoM_Config.minimapAngle = 150
            T_OoM_Config.minimapFreePos = nil

            if T_OoM.minimapButton then
                T_OoM.minimapButton.freeMode = false
                T_OoM.minimapButton.angle = 150
                T_OoM.minimapButton.freePos = nil
                T_OoM.minimapButton:UpdatePosition()
            end

            self:Print(T_OoM.L.MINIMAP_TOOLTIP_RESET)
        end
        return
    end

    -- ========================================================================
    -- Команда: /toom help (показать справку)
    -- ========================================================================
    if command == "help" then
        self:PrintHelp()
        return
    end

    -- ========================================================================
    -- Неизвестная команда
    -- ========================================================================
    self:Print(T_OoM.L.CMD_UNKNOWN .. command)
    self:Print(T_OoM.L.CMD_USE_HELP)
end

-- ============================================================================
-- Справка по командам
-- ============================================================================
function T_OoM:PrintHelp()
    self:Print(T_OoM.L.CMD_HELP_TITLE)
    DEFAULT_CHAT_FRAME:AddMessage("    • " .. T_OoM.L.CMD_CONFIG)
    DEFAULT_CHAT_FRAME:AddMessage("    • " .. T_OoM.L.CMD_LANG)
    DEFAULT_CHAT_FRAME:AddMessage("    • /toom reset - " .. T_OoM.L.MINIMAP_TOOLTIP_RESET)
end

-- ============================================================================
-- Регистрация slash-команды
-- ============================================================================
SLASH_TOOM1 = "/toom"

SlashCmdList["TOOM"] = function(msg)
    if T_OoM and T_OoM.SlashCommand then
        T_OoM:SlashCommand(msg)
    end
end
