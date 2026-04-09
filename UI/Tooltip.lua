-- ============================================================================
-- T-OoM - Кастомный тултип
-- ============================================================================
-- Умный тултип с авто-позиционированием (не выходит за границы экрана)
-- Поддерживает русский язык через шрифт ARIALN.ttf
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- Путь к кириллическому шрифту
local CYRILLIC_FONT_PATH = "Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf"

-- ============================================================================
-- Создание тултипа
-- ============================================================================
function T_OoM:CreateTooltip()
    -- Фрейм тултипа
    self.tooltip = CreateFrame("Frame", "TOoMTooltipFrame", UIParent)
    local tooltip = self.tooltip

    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetToplevel(true)
    tooltip:Hide()

    -- Запрещаем тултипу уходить за границы экрана
    tooltip:SetClampedToScreen(true)

    -- Backdrop (фон и рамка)
    tooltip:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    tooltip:SetBackdropColor(
        self.Colors.bgMain[1],
        self.Colors.bgMain[2],
        self.Colors.bgMain[3],
        0.95
    )
    tooltip:SetBackdropBorderColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    -- Текст тултипа
    tooltip.text = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.text:SetFont(CYRILLIC_FONT_PATH, 12)
    tooltip.text:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    tooltip.text:SetJustifyH("LEFT")
    tooltip.text:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 12, -6)
    tooltip.text:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", -8, 8)

    -- Глобальная ссылка
    _G["TOoMTooltipFrame"] = tooltip
end

-- ============================================================================
-- Показать тултип
-- ============================================================================
function T_OoM:ShowTooltip(object, message)
    local tooltip = self.tooltip
    local tooltipText = tooltip.text

    -- Устанавливаем текст
    tooltipText:SetText(message)

    -- Подгоняем размер по содержимому
    local textWidth = tooltipText:GetStringWidth()
    local textHeight = tooltipText:GetHeight()
    tooltip:SetWidth(textWidth + 25)
    tooltip:SetHeight(textHeight + 20)

    -- Позиционируем тултип с умной проверкой границ экрана
    tooltip:ClearAllPoints()

    -- Получаем размеры экрана
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local tooltipWidth = tooltip:GetWidth()
    local tooltipHeight = tooltip:GetHeight()

    -- Получаем координаты объекта (могут быть nil для кнопок на миникарте)
    local objectLeft = object:GetLeft()
    local objectRight = object:GetRight()
    local objectTop = object:GetTop()
    local objectBottom = object:GetBottom()

    -- Проверяем, является ли объект кнопкой на миникарте
    local parent = object:GetParent()
    local isMinimapButton = (parent and parent:GetName() == "Minimap")

    -- Если координаты nil (кнопка на миникарте), используем упрощённое позиционирование
    if not objectLeft or not objectRight or not objectTop then
        -- Для кнопок на миникарте используем BOTTOMRIGHT как fallback
        tooltip:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", 0, 0)
    else
        -- Вычисляем доступное место по сторонам от объекта
        local spaceLeft = objectLeft
        local spaceRight = screenWidth - objectRight
        local spaceTop = screenHeight - objectTop
        local spaceBottom = objectBottom

        -- Вычисляем, где больше места: слева или справа
        local moreSpaceOnLeft = (spaceLeft >= spaceRight)

        -- Приоритет позиционирования:
        -- 1. Если сверху достаточно места → показываем СВЕРХУ
        if spaceTop >= tooltipHeight + 5 then
            if moreSpaceOnLeft then
                tooltip:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", 0, 5)
            else
                tooltip:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", 0, 5)
            end
        -- 2. Если снизу достаточно места → показываем СНИЗУ
        elseif spaceBottom >= tooltipHeight + 5 then
            if moreSpaceOnLeft then
                tooltip:SetPoint("TOPRIGHT", object, "BOTTOMLEFT", 0, -5)
            else
                tooltip:SetPoint("TOPLEFT", object, "BOTTOMRIGHT", 0, -5)
            end
        -- 3. Если сверху и снизу не влезает, пробуем СЛЕВА
        elseif spaceLeft >= tooltipWidth + 5 then
            tooltip:SetPoint("TOPRIGHT", object, "TOPLEFT", -5, 0)
        -- 4. Пробуем СПРАВА
        elseif spaceRight >= tooltipWidth + 5 then
            tooltip:SetPoint("TOPLEFT", object, "TOPRIGHT", 5, 0)
        -- 5. Fallback: СВЕРХУ слева
        else
            tooltip:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", 0, 5)
        end
    end

    tooltip:Show()
end

-- ============================================================================
-- Скрыть тултип
-- ============================================================================
function T_OoM:HideTooltip()
    self.tooltip:Hide()
end
