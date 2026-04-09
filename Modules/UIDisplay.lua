-- ============================================================================
-- T-OoM - Модуль визуального отображения сообщений о мане
-- ============================================================================
-- Показывает большое сообщение на экране при достижении порога маны
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- Локальные переменные
local messageFrame = nil
local messageTimer = nil
local currentMessage = ""
local messageStartTime = 0
local MESSAGE_DURATION = 3  -- 3 секунды показа

-- ============================================================================
-- Инициализация
-- ============================================================================
function T_OoM:InitializeUIDisplay()
    -- Регистрируем callback от модуля мониторинга маны
    T_OoM:RegisterManaCallback(function(data)
        T_OoM:ShowManaMessage(data.message)
    end)
end

-- ============================================================================
-- Создание фрейма сообщения
-- ============================================================================
function T_OoM:CreateMessageFrame()
    if messageFrame then
        return messageFrame
    end

    -- Главный фрейм
    messageFrame = CreateFrame("Frame", "TOoMMessageFrame", UIParent)
    messageFrame:SetWidth(500)
    messageFrame:SetHeight(120)
    messageFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 350)
    messageFrame:SetFrameStrata("HIGH")

    -- Фон
    messageFrame.bg = messageFrame:CreateTexture(nil, "BACKGROUND")
    messageFrame.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    messageFrame.bg:SetAllPoints(messageFrame)
    messageFrame.bg:SetVertexColor(0, 0, 0, 0)

    -- Текст сообщения
    messageFrame.text = messageFrame:CreateFontString(nil, "OVERLAY")
    messageFrame.text:SetFont("Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf", 72, "OUTLINE")
    messageFrame.text:SetTextColor(1, 1, 1, 1)
    messageFrame.text:SetText("")
    messageFrame.text:SetPoint("CENTER", messageFrame, "CENTER", 0, 0)

    -- Скрыт по умолчанию
    messageFrame:Hide()

    return messageFrame
end

-- ============================================================================
-- Показ сообщения о мане
-- ============================================================================
function T_OoM:ShowManaMessage(message)
    if not message or message == "" then
        return
    end

    -- Создаём фрейм если нет
    T_OoM:CreateMessageFrame()

    -- Устанавливаем текст
    messageFrame.text:SetText(message)
    currentMessage = message

    -- Показываем фрейм
    messageFrame:Show()
    messageStartTime = GetTime()

    -- Создаём таймер если нет
    if not messageTimer then
        messageTimer = CreateFrame("Frame", "TOoMMessageTimer")
        messageTimer:SetScript("OnUpdate", function()
            T_OoM:UpdateMessageTimer()
        end)
    end
end

-- ============================================================================
-- Обновление таймера сообщения
-- ============================================================================
function T_OoM:UpdateMessageTimer()
    if not messageFrame or not messageFrame:IsShown() then
        return
    end

    local elapsed = GetTime() - messageStartTime

    if elapsed >= MESSAGE_DURATION then
        -- Скрываем сообщение
        messageFrame:Hide()
        currentMessage = ""
    end
end

-- ============================================================================
-- Скрытие сообщения
-- ============================================================================
function T_OoM:HideManaMessage()
    if messageFrame then
        messageFrame:Hide()
        currentMessage = ""
    end
end

-- ============================================================================
-- Тестовое сообщение
-- ============================================================================
function T_OoM:ShowTestMessage()
    T_OoM:ShowManaMessage("TEST MESSAGE")
end
