-- ============================================================================
-- T-OoM - Кнопка миникарты
-- ============================================================================
-- ЛКМ - открыть/закрыть окно настроек
-- ПКМ + Drag - переместить кнопку
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- Путь к иконке
local ICON_PATH = "Interface\\AddOns\\T-OoM\\textures\\miniMapIcon"

-- Локализация для производительности
local math_rad = math.rad
local math_deg = math.deg
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2

-- ============================================================================
-- Создание кнопки миникарты
-- ============================================================================
function T_OoM:CreateMinimapButton()
    -- Создаём кнопку (родитель Minimap)
    self.minimapButton = CreateFrame("Button", "TOoMMinimapButton", Minimap)
    local button = self.minimapButton

    button:SetFrameStrata("MEDIUM")
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetFrameLevel(8)
    button:RegisterForDrag("LeftButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Текстура подсветки
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local highlight = button:GetHighlightTexture()
    if highlight then
        highlight:SetWidth(32)
        highlight:SetHeight(32)
        highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
        highlight:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        highlight:SetBlendMode("ADD")
    end

    -- Overlay (рамка миникарты)
    button.overlay = button:CreateTexture(nil, "OVERLAY")
    button.overlay:SetWidth(56)
    button.overlay:SetHeight(56)
    button.overlay:SetPoint("TOPLEFT", 0, 0)
    button.overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- Иконка
    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetWidth(18)
    button.icon:SetHeight(18)
    button.icon:SetPoint("TOPLEFT", 8, -7)
    button.icon:SetTexture(ICON_PATH)
    button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Позиция из настроек
    button.angle = T_OoM_Config.minimapAngle or 150
    button.freePos = T_OoM_Config.minimapFreePos or nil
    button.freeMode = T_OoM_Config.minimapFreeMode or false

    -- Функция обновления позиции
    function button:UpdatePosition()
        button:ClearAllPoints()

        if button.freeMode and button.freePos then
            -- Свободная позиция
            button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", button.freePos.x, button.freePos.y)
        else
            -- Позиция вокруг миникарты
            local angle = math_rad(button.angle)
            local radius = 80
            local x = math_cos(angle) * radius
            local y = math_sin(angle) * radius
            button:SetPoint("CENTER", Minimap, "CENTER", x, y)
        end
    end

    -- Перетаскивание
    button:SetScript("OnDragStart", function()
        button:LockHighlight()
        button.isDragging = true
        button.freeDragging = IsControlKeyDown()
    end)

    button:SetScript("OnDragStop", function()
        button:UnlockHighlight()
        button.isDragging = false
        button.freeDragging = false
        T_OoM_Config.minimapAngle = button.angle
        T_OoM_Config.minimapFreePos = button.freePos
        T_OoM_Config.minimapFreeMode = button.freeMode
    end)

    -- OnUpdate для отслеживания перетаскивания
    button:SetScript("OnUpdate", function()
        if button.isDragging then
            local mx, my = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            mx = mx / scale
            my = my / scale

            if button.freeDragging then
                -- Свободное перемещение
                button.freeMode = true
                button.freePos = {x = mx, y = my}
            else
                -- Вращение вокруг миникарты
                button.freeMode = false
                local px, py = Minimap:GetCenter()
                local angle = math_deg(math_atan2(my - py, mx - px))
                button.angle = angle
            end
            button:UpdatePosition()
        end
    end)

    -- Клик
    button:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            -- ЛКМ - открыть/закрыть окно настроек
            if T_OoM.configWindow and T_OoM.configWindow:IsShown() then
                T_OoM.configWindow:Hide()
            else
                if not T_OoM.configWindow then
                    T_OoM:CreateConfigWindow()
                end
                if T_OoM.configWindow then
                    T_OoM.configWindow:Show()
                end
            end
        elseif arg1 == "RightButton" and IsControlKeyDown() then
            -- Сброс позиции (Ctrl + ПКМ)
            button.angle = 150
            button.freeMode = false
            button.freePos = nil
            T_OoM_Config.minimapAngle = 150
            T_OoM_Config.minimapFreeMode = false
            T_OoM_Config.minimapFreePos = nil
            button:UpdatePosition()
            T_OoM:Print(T_OoM.L.MINIMAP_TOOLTIP_RESET)
        end
    end)

    -- Тултип (наша кастомная система с поддержкой русского языка)
    button:SetScript("OnEnter", function()
        -- Получаем версию из .toc файла
        local version = GetAddOnMetadata("T-OoM", "Version") or "Unknown"

        T_OoM:ShowTooltip(button,
            T_OoM.L.MINIMAP_TOOLTIP_LINE1 .. "\n\n" ..
            T_OoM.L.MINIMAP_TOOLTIP_CLICK .. ": " .. T_OoM.L.MINIMAP_TOOLTIP_LMB .. "\n" ..
            T_OoM.L.MINIMAP_TOOLTIP_MOVE .. ": " .. T_OoM.L.MINIMAP_TOOLTIP_LMB .. " + " .. T_OoM.L.MINIMAP_TOOLTIP_DRAG .. "\n" ..
            T_OoM.L.MINIMAP_TOOLTIP_FREE .. "\n" ..
            T_OoM.L.MINIMAP_TOOLTIP_RESET .. ": " .. T_OoM.L.MINIMAP_TOOLTIP_CTRL_RMB .. "\n\n" ..
            T_OoM.L.MINIMAP_VERSION .. "|r " .. version
        )
    end)

    button:SetScript("OnLeave", function()
        T_OoM:HideTooltip()
    end)

    -- Начальная позиция
    button:UpdatePosition()

    -- Глобальная ссылка
    _G["TOoMMinimapButton"] = button
end
