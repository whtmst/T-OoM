-- ============================================================================
-- T-OoM - Окно настроек
-- ============================================================================
-- Создаёт окно конфигурации с использованием виджетов из UI/Widgets.lua
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- ============================================================================
-- Создание окна настроек
-- ============================================================================
function T_OoM:CreateConfigWindow()
    -- Главное окно
    local window = CreateFrame("Frame", "TOoMConfigWindow", UIParent)
    window:SetFrameStrata("DIALOG")
    window:SetWidth(450)
    window:SetHeight(580)

    -- Восстанавливаем сохранённую позицию
    local pos = T_OoM_Config.configWindowPos
    if pos and pos.point then
        window:SetPoint(pos.point, UIParent, pos.point, pos.x or 0, pos.y or 0)
    else
        window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetClampedToScreen(true)

    -- Backdrop
    window:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    window:SetBackdropColor(
        self.Colors.bgMain[1],
        self.Colors.bgMain[2],
        self.Colors.bgMain[3],
        0.95
    )
    window:SetBackdropBorderColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    -- Перетаскивание + сохранение позиции + сброс фокуса EditBox
    window:SetScript("OnDragStart", function()
        window:StartMoving()
    end)
    window:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        -- Сохраняем позицию
        local point, _, _, x, y = window:GetPoint()
        T_OoM_Config.configWindowPos = {
            point = point or "CENTER",
            x = x or 0,
            y = y or 0,
        }
    end)

    -- Сброс фокуса EditBox при клике вне него
    window:SetScript("OnMouseDown", function()
        if arg1 ~= "LeftButton" then return end

        -- Проверяем, есть ли сейчас фокус на каком-либо EditBox внутри T_OoM
        if T_OoM._focusedEditBox and T_OoM._focusedEditBox:IsVisible() then
            -- Определяем, куда именно кликнули
            local mouseFocus = GetMouseFocus()

            -- Если кликнули по самому EditBox или его дочерним элементам - не сбрасываем
            if mouseFocus == T_OoM._focusedEditBox then return end

            -- Проверяем, не является ли родитель mouseFocus нашим EditBox
            local parent = mouseFocus:GetParent()
            while parent do
                if parent == T_OoM._focusedEditBox then return end
                parent = parent:GetParent()
            end

            -- Клик вне EditBox - сбрасываем фокус
            T_OoM._focusedEditBox:ClearFocus()
        end
    end)

    -- Скрыть по умолчанию
    window:Hide()

    -- ========================================================================
    -- Заголовок окна
    -- ========================================================================
    local version = GetAddOnMetadata("T-OoM", "Version") or "Unknown"
    local header = self:CreateHeader(window, self.L.CONFIG_WINDOW_TITLE .. " | v" .. version, 18)
    header:SetPoint("TOPLEFT", window, "TOPLEFT", 15, -10)
    header:SetPoint("TOPRIGHT", window, "TOPRIGHT", -15, -10)

    -- ========================================================================
    -- Кнопка закрытия
    -- ========================================================================
    local closeBtn = self:CreateButton(window, "X", function()
        window:Hide()
    end, 20, 20, 12)
    closeBtn:SetPoint("TOPRIGHT", window, "TOPRIGHT", -8, -8)

    -- ========================================================================
    -- Контентная область
    -- ========================================================================
    local content = CreateFrame("Frame", nil, window)
    content:SetPoint("TOPLEFT", window, "TOPLEFT", 15, -40)
    content:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -15, 50)

    -- ========================================================================
    -- 1. Общие настройки
    -- ========================================================================
    local generalHeader = self:CreateHeader(content, self.L.GENERAL_SECTION, 14)
    generalHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -10)
    generalHeader:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)

    -- Чекбокс включения аддона + Dropdown языка в один ряд
    local enabledCheckbox = self:CreateCheckbox(
        content,
        self.L.ENABLE_ADDON,
        function(checked)
            T_OoM_Config.enabled = checked and 1 or 0
        end
    )
    enabledCheckbox:SetPoint("TOPLEFT", generalHeader, "BOTTOMLEFT", 0, -15)

    -- Dropdown языка — справа от чекбокса
    local langLabel = content:CreateFontString(nil, "OVERLAY")
    langLabel:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    langLabel:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    langLabel:SetText(self.L.LANGUAGE .. ":")
    langLabel:SetPoint("LEFT", enabledCheckbox.label, "RIGHT", 65, 0)

    local langDropdown = self:CreateDropdown(
        content,
        {
            {value = "ruRU", text = self.L.LANGUAGE_RU},
            {value = "enUS", text = self.L.LANGUAGE_EN},
        },
        function(value)
            T_OoM_Config.language = value
            T_OoM:LoadLocale(value)

            -- Сбрасываем тексты на дефолтные для нового языка
            if value == "ruRU" then
                T_OoM_Config.message1 = "--- МАЛО МАНЫ ---"
                T_OoM_Config.message2 = "--- КРИТИЧЕСКИ МАЛО МАНЫ ---"
                T_OoM_Config.message3 = "--- ЗАКОНЧИЛАСЬ МАНА ---"
            else
                T_OoM_Config.message1 = "--- LOW ON MANA ---"
                T_OoM_Config.message2 = "--- CRITICAL LOW MANA ---"
                T_OoM_Config.message3 = "--- OUT OF MANA ---"
            end

            T_OoM:Print(T_OoM.L.CMD_LANG_RELOAD)
        end,
        120
    )
    langDropdown:SetPoint("LEFT", langLabel, "RIGHT", 8, 0)

    -- ========================================================================
    -- 2. Настройки сообщений
    -- ========================================================================
    local messageHeader = self:CreateHeader(content, self.L.MESSAGE_SECTION, 14)
    messageHeader:SetPoint("TOPLEFT", enabledCheckbox, "BOTTOMLEFT", 0, -25)
    messageHeader:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -25)

    -- Поле ввода: сообщение 1
    local msg1Label = content:CreateFontString(nil, "OVERLAY")
    msg1Label:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    msg1Label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    msg1Label:SetText(self.L.LOW_MANA_MSG .. " " .. self.L.MESSAGE_MAX_LENGTH)
    msg1Label:SetPoint("TOPLEFT", messageHeader, "BOTTOMLEFT", 0, -15)

    local msg1Edit = self:CreateEditBox(content, 420, 24, 120, function(editBox, text)
        if string.len(text) > 120 then
            text = string.sub(text, 1, 120)
            editBox:SetText(text)
            T_OoM:Print(string.format(self.L.MESSAGE_TRUNCATED, 120))
        end
        T_OoM_Config.message1 = text
    end)
    msg1Edit:SetPoint("TOPLEFT", msg1Label, "BOTTOMLEFT", 0, -5)

    -- Поле ввода: сообщение 2
    local msg2Label = content:CreateFontString(nil, "OVERLAY")
    msg2Label:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    msg2Label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    msg2Label:SetText(self.L.CRITICAL_MANA_MSG .. " " .. self.L.MESSAGE_MAX_LENGTH)
    msg2Label:SetPoint("TOPLEFT", msg1Edit, "BOTTOMLEFT", 0, -10)

    local msg2Edit = self:CreateEditBox(content, 420, 24, 120, function(editBox, text)
        if string.len(text) > 120 then
            text = string.sub(text, 1, 120)
            editBox:SetText(text)
            T_OoM:Print(string.format(self.L.MESSAGE_TRUNCATED, 120))
        end
        T_OoM_Config.message2 = text
    end)
    msg2Edit:SetPoint("TOPLEFT", msg2Label, "BOTTOMLEFT", 0, -5)

    -- Поле ввода: сообщение 3
    local msg3Label = content:CreateFontString(nil, "OVERLAY")
    msg3Label:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    msg3Label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    msg3Label:SetText(self.L.OUT_OF_MANA_MSG .. " " .. self.L.MESSAGE_MAX_LENGTH)
    msg3Label:SetPoint("TOPLEFT", msg2Edit, "BOTTOMLEFT", 0, -10)

    local msg3Edit = self:CreateEditBox(content, 420, 24, 120, function(editBox, text)
        if string.len(text) > 120 then
            text = string.sub(text, 1, 120)
            editBox:SetText(text)
            T_OoM:Print(string.format(self.L.MESSAGE_TRUNCATED, 120))
        end
        T_OoM_Config.message3 = text
    end)
    msg3Edit:SetPoint("TOPLEFT", msg3Label, "BOTTOMLEFT", 0, -5)

    -- ========================================================================
    -- 3. Пороги маны (левая колонка) + Канал/Режим (правая колонка)
    -- ========================================================================
    local thresholdHeader = self:CreateHeader(content, self.L.THRESHOLD_SECTION, 14)
    thresholdHeader:SetPoint("TOPLEFT", msg3Edit, "BOTTOMLEFT", 0, -20)
    thresholdHeader:SetWidth(200)

    -- Правая колонка: заголовок канала
    local channelHeader = self:CreateHeader(content, self.L.CHANNEL_SECTION, 14)
    channelHeader:SetPoint("TOPLEFT", thresholdHeader, "TOPRIGHT", 20, 0)
    channelHeader:SetWidth(200)

    -- Ползунок 1 (левая колонка)
    local thresh1Label = content:CreateFontString(nil, "OVERLAY")
    thresh1Label:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    thresh1Label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    thresh1Label:SetText(self.L.THRESHOLD_LOW .. " (|cFF11A6EC" .. string.format(self.L.THRESHOLD_PERCENT, T_OoM_Config.threshold1) .. "|r)")
    thresh1Label:SetPoint("TOPLEFT", thresholdHeader, "BOTTOMLEFT", 0, -15)

    local thresh1Slider = self:CreateSlider(content, 0, 100, 1, function(value)
        T_OoM_Config.threshold1 = value
        thresh1Label:SetText(self.L.THRESHOLD_LOW .. " (|cFF11A6EC" .. string.format(self.L.THRESHOLD_PERCENT, value) .. "|r)")
    end)
    thresh1Slider:SetPoint("TOPLEFT", thresh1Label, "BOTTOMLEFT", 0, -5)
    thresh1Slider:SetWidth(180)
    thresh1Slider:SetValue(T_OoM_Config.threshold1)

    -- Правая колонка: dropdown канала
    local channelLabel = content:CreateFontString(nil, "OVERLAY")
    channelLabel:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    channelLabel:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    channelLabel:SetText(self.L.CHANNEL .. ":")
    channelLabel:SetPoint("TOPLEFT", channelHeader, "BOTTOMLEFT", 0, -15)

    local channelDropdown = self:CreateDropdown(
        content,
        {
            {value = "SAY", text = self.L.CHANNEL_SAY},
            {value = "PARTY", text = self.L.CHANNEL_PARTY},
            {value = "RAID", text = self.L.CHANNEL_RAID},
        },
        function(value)
            T_OoM_Config.chatChannel = value
        end,
        150
    )
    channelDropdown:SetPoint("TOPLEFT", channelLabel, "BOTTOMLEFT", 0, -5)

    -- Ползунок 2 (левая колонка)
    local thresh2Label = content:CreateFontString(nil, "OVERLAY")
    thresh2Label:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    thresh2Label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    thresh2Label:SetText(self.L.THRESHOLD_CRITICAL .. " (|cFF11A6EC" .. string.format(self.L.THRESHOLD_PERCENT, T_OoM_Config.threshold2) .. "|r)")
    thresh2Label:SetPoint("TOPLEFT", thresh1Slider, "BOTTOMLEFT", 0, -10)

    local thresh2Slider = self:CreateSlider(content, 0, 100, 1, function(value)
        T_OoM_Config.threshold2 = value
        thresh2Label:SetText(self.L.THRESHOLD_CRITICAL .. " (|cFF11A6EC" .. string.format(self.L.THRESHOLD_PERCENT, value) .. "|r)")
    end)
    thresh2Slider:SetPoint("TOPLEFT", thresh2Label, "BOTTOMLEFT", 0, -5)
    thresh2Slider:SetWidth(180)
    thresh2Slider:SetValue(T_OoM_Config.threshold2)

    -- Правая колонка: заголовок режима + dropdown
    local instanceModeLabel = content:CreateFontString(nil, "OVERLAY")
    instanceModeLabel:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    instanceModeLabel:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    instanceModeLabel:SetText(self.L.INSTANCE_MODE .. ":")
    instanceModeLabel:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 0, -15)

    local instanceModeDropdown = self:CreateDropdown(
        content,
        {
            {value = "world", text = self.L.INSTANCE_MODE_WORLD},
            {value = "instance", text = self.L.INSTANCE_MODE_INSTANCE},
            {value = "always", text = self.L.INSTANCE_MODE_ALWAYS},
        },
        function(value)
            T_OoM_Config.instanceMode = value
        end,
        160
    )
    instanceModeDropdown:SetPoint("TOPLEFT", instanceModeLabel, "BOTTOMLEFT", 0, -5)

    -- Ползунок 3 (левая колонка)
    local thresh3Label = content:CreateFontString(nil, "OVERLAY")
    thresh3Label:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 12)
    thresh3Label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    thresh3Label:SetText(self.L.THRESHOLD_OUT .. " (|cFF11A6EC" .. string.format(self.L.THRESHOLD_PERCENT, T_OoM_Config.threshold3) .. "|r)")
    thresh3Label:SetPoint("TOPLEFT", thresh2Slider, "BOTTOMLEFT", 0, -10)

    local thresh3Slider = self:CreateSlider(content, 0, 100, 1, function(value)
        T_OoM_Config.threshold3 = value
        thresh3Label:SetText(self.L.THRESHOLD_OUT .. " (|cFF11A6EC" .. string.format(self.L.THRESHOLD_PERCENT, value) .. "|r)")
    end)
    thresh3Slider:SetPoint("TOPLEFT", thresh3Label, "BOTTOMLEFT", 0, -5)
    thresh3Slider:SetWidth(180)
    thresh3Slider:SetValue(T_OoM_Config.threshold3)

    -- ========================================================================
    -- 6. Кнопки действий (центрированная группа)
    -- ========================================================================
    local btnContainer = CreateFrame("Frame", nil, window)
    btnContainer:SetWidth(370)  -- 130 + 10 + 100 + 10 + 120
    btnContainer:SetHeight(28)
    btnContainer:SetPoint("BOTTOM", window, "BOTTOM", 0, 12)

    local applyBtn = self:CreateButton(btnContainer, self.L.APPLY_SETTINGS, function()
        -- Проверяем длину сообщений
        local m1 = msg1Edit:GetText()
        local m2 = msg2Edit:GetText()
        local m3 = msg3Edit:GetText()

        if string.len(m1) < 1 or string.len(m2) < 1 or string.len(m3) < 1 then
            T_OoM:Print(self.L.MESSAGE_ERROR)
            return
        end

        T_OoM:Print(self.L.SETTINGS_APPLIED)
        window:Hide()
    end, 120, 28, 13)
    applyBtn:SetPoint("RIGHT", btnContainer, "RIGHT", 0, 0)

    local cancelBtn = self:CreateButton(btnContainer, self.L.CANCEL, function()
        T_OoM:Print(self.L.SETTINGS_CANCELLED)
        window:Hide()
    end, 100, 28, 13)
    cancelBtn:SetPoint("RIGHT", applyBtn, "LEFT", -10, 0)

    local resetBtn = self:CreateButton(btnContainer, self.L.RESET_DEFAULTS, function()
        T_OoM:ResetConfig()

        -- Обновляем UI
        self:SetCheckboxState(enabledCheckbox, T_OoM_Config.enabled)
        langDropdown:SetValue(T_OoM_Config.language)
        msg1Edit:SetText(T_OoM_Config.message1 or "")
        msg2Edit:SetText(T_OoM_Config.message2 or "")
        msg3Edit:SetText(T_OoM_Config.message3 or "")
        thresh1Slider:SetValue(T_OoM_Config.threshold1)
        thresh2Slider:SetValue(T_OoM_Config.threshold2)
        thresh3Slider:SetValue(T_OoM_Config.threshold3)
        channelDropdown:SetValue(T_OoM_Config.chatChannel)
        instanceModeDropdown:SetValue(T_OoM_Config.instanceMode)
    end, 130, 28, 13)
    resetBtn:SetPoint("RIGHT", cancelBtn, "LEFT", -10, 0)

    -- ========================================================================
    -- Загрузка настроек в UI
    -- ========================================================================
    local function LoadSettingsIntoUI()
        self:SetCheckboxState(enabledCheckbox, T_OoM_Config.enabled)
        langDropdown:SetValue(T_OoM_Config.language)
        msg1Edit:SetText(T_OoM_Config.message1 or "")
        msg2Edit:SetText(T_OoM_Config.message2 or "")
        msg3Edit:SetText(T_OoM_Config.message3 or "")
        thresh1Slider:SetValue(T_OoM_Config.threshold1)
        thresh2Slider:SetValue(T_OoM_Config.threshold2)
        thresh3Slider:SetValue(T_OoM_Config.threshold3)
        channelDropdown:SetValue(T_OoM_Config.chatChannel)
        instanceModeDropdown:SetValue(T_OoM_Config.instanceMode)
    end

    LoadSettingsIntoUI()

    -- Сохраняем ссылку на окно
    self.configWindow = window
end
