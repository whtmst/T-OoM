-- ============================================================================
-- T-OoM - Общие UI виджеты
-- ============================================================================
-- Библиотека переиспользуемых UI компонентов
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- Шрифт (кириллица)
local FONT_PATH = "Interface\\AddOns\\T-OoM\\fonts\\ARIALN.ttf"

-- ============================================================================
-- Цветовая схема
-- ============================================================================
T_OoM.Colors = {
    -- Фон
    bgMain = {0.098, 0.098, 0.098},           -- #191919
    bgSection = {0.145, 0.145, 0.145},        -- #252525
    bgCheckbox = {0.251, 0.251, 0.251},       -- #404040

    -- Текст
    textMain = {0.925, 0.859, 0.729},         -- #ECDBBA
    textWhite = {1, 1, 1},                    -- #FFFFFF
    textMuted = {0.612, 0.639, 0.686},        -- #9CA3AF

    -- Акценты
    accentMain = {0.067, 0.651, 0.925},       -- #11A6EC
    accentHover = {0.925, 0.859, 0.729},      -- #ECDBBA

    -- Границы
    borderMain = {0.251, 0.251, 0.251},       -- #404040
}

-- ============================================================================
-- Создание кнопки
-- ============================================================================
function T_OoM:CreateButton(parent, text, onClick, width, height, fontSize)
    local button = CreateFrame("Button", nil, parent)

    button:SetWidth(width or 100)
    button:SetHeight(height or 24)

    -- Backdrop
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    button:SetBackdropColor(
        self.Colors.bgSection[1],
        self.Colors.bgSection[2],
        self.Colors.bgSection[3],
        1
    )
    button:SetBackdropBorderColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    -- Текст
    button.text = button:CreateFontString(nil, "OVERLAY")
    button.text:SetFont(FONT_PATH, fontSize or 12)
    button.text:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    button.text:SetText(text)
    button.text:SetPoint("CENTER", button, "CENTER", 0, 1)

    -- Клик
    if onClick then
        button:SetScript("OnClick", onClick)
    end

    -- Hover
    button:SetScript("OnEnter", function()
        button:SetBackdropColor(
            self.Colors.bgMain[1],
            self.Colors.bgMain[2],
            self.Colors.bgMain[3],
            1
        )
        button:SetBackdropBorderColor(
            self.Colors.accentMain[1],
            self.Colors.accentMain[2],
            self.Colors.accentMain[3],
            1
        )
    end)

    button:SetScript("OnLeave", function()
        button:SetBackdropColor(
            self.Colors.bgSection[1],
            self.Colors.bgSection[2],
            self.Colors.bgSection[3],
            1
        )
        button:SetBackdropBorderColor(
            self.Colors.borderMain[1],
            self.Colors.borderMain[2],
            self.Colors.borderMain[3],
            1
        )
    end)

    return button
end

-- ============================================================================
-- Создание заголовка (Header)
-- ============================================================================
function T_OoM:CreateHeader(parent, text, fontSize)
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight((fontSize or 20) + 10)

    header.text = header:CreateFontString(nil, "OVERLAY")
    header.text:SetFont(FONT_PATH, fontSize or 16)
    header.text:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    header.text:SetText(text)
    header.text:SetPoint("LEFT", header, "LEFT", 0, 0)

    -- Линия снизу
    header.line = header:CreateTexture(nil, "OVERLAY")
    header.line:SetTexture("Interface\\Buttons\\WHITE8X8")
    header.line:SetHeight(1)
    header.line:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, -2)
    header.line:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, -2)
    header.line:SetVertexColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    return header
end

-- ============================================================================
-- Создание чекбокса
-- ============================================================================
function T_OoM:CreateCheckbox(parent, text, onCheck)
    local checkbox = CreateFrame("CheckButton", nil, parent)
    checkbox:SetWidth(18)
    checkbox:SetHeight(18)

    -- Убираем стандартные текстуры
    checkbox:SetNormalTexture("")
    checkbox:SetPushedTexture("")
    checkbox:SetHighlightTexture("")
    checkbox:SetDisabledTexture("")
    checkbox:SetCheckedTexture("")

    -- Фон
    checkbox.bg = checkbox:CreateTexture(nil, "BACKGROUND")
    checkbox.bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    checkbox.bg:SetWidth(18)
    checkbox.bg:SetHeight(18)
    checkbox.bg:SetPoint("CENTER", checkbox, "CENTER", 0, 0)
    checkbox.bg:SetVertexColor(
        self.Colors.bgCheckbox[1],
        self.Colors.bgCheckbox[2],
        self.Colors.bgCheckbox[3],
        1
    )

    -- Галочка
    checkbox.check = checkbox:CreateTexture(nil, "ARTWORK")
    checkbox.check:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    checkbox.check:SetWidth(10)
    checkbox.check:SetHeight(10)
    checkbox.check:SetPoint("CENTER", checkbox, "CENTER", 0, 0)
    checkbox.check:SetVertexColor(
        self.Colors.textWhite[1],
        self.Colors.textWhite[2],
        self.Colors.textWhite[3],
        0
    )

    -- Клик
    checkbox:SetScript("OnClick", function()
        local checked = checkbox:GetChecked()
        checkbox:SetChecked(checked)

        if checked then
            checkbox.check:SetVertexColor(
                self.Colors.accentMain[1],
                self.Colors.accentMain[2],
                self.Colors.accentMain[3],
                1
            )
        else
            checkbox.check:SetVertexColor(
                self.Colors.textWhite[1],
                self.Colors.textWhite[2],
                self.Colors.textWhite[3],
                0
            )
        end

        if onCheck then
            onCheck(checked)
        end
    end)

    -- Текст
    checkbox.label = checkbox:CreateFontString(nil, "OVERLAY")
    checkbox.label:SetFont(FONT_PATH, 12)
    checkbox.label:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )
    checkbox.label:SetText(text)
    checkbox.label:SetPoint("LEFT", checkbox, "RIGHT", 4, 1)

    return checkbox
end

-- ============================================================================
-- Установка состояния чекбокса
-- ============================================================================
function T_OoM:SetCheckboxState(checkbox, checked)
    if not checkbox then return end

    -- Преобразуем 1/0 в boolean для SetChecked
    local isChecked = (checked == 1 or checked == true)
    checkbox:SetChecked(isChecked)

    if isChecked then
        checkbox.check:SetVertexColor(
            self.Colors.accentMain[1],
            self.Colors.accentMain[2],
            self.Colors.accentMain[3],
            1
        )
    else
        checkbox.check:SetVertexColor(
            self.Colors.textWhite[1],
            self.Colors.textWhite[2],
            self.Colors.textWhite[3],
            0
        )
    end
end

-- ============================================================================
-- Создание слайдера
-- ============================================================================
function T_OoM:CreateSlider(parent, min, max, step, onValueChanged)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min or 0, max or 100)
    slider:SetValueStep(step or 1)
    slider:SetWidth(150)
    slider:SetHeight(16)

    -- Backdrop
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    slider:SetBackdropColor(
        self.Colors.bgSection[1],
        self.Colors.bgSection[2],
        self.Colors.bgSection[3],
        1
    )
    slider:SetBackdropBorderColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    -- Ползунок (thumb)
    slider.thumb = slider:CreateTexture(nil, "ARTWORK")
    slider.thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    slider.thumb:SetWidth(16)
    slider.thumb:SetHeight(16)
    slider:SetThumbTexture(slider.thumb)
    slider.thumb:SetVertexColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    -- Hover
    slider:SetScript("OnEnter", function()
        slider.thumb:SetVertexColor(
            self.Colors.accentMain[1],
            self.Colors.accentMain[2],
            self.Colors.accentMain[3],
            1
        )
    end)

    slider:SetScript("OnLeave", function()
        slider.thumb:SetVertexColor(
            self.Colors.borderMain[1],
            self.Colors.borderMain[2],
            self.Colors.borderMain[3],
            1
        )
    end)

    -- OnValueChanged
    slider:SetScript("OnValueChanged", function()
        if onValueChanged then
            onValueChanged(slider:GetValue())
        end
    end)

    return slider
end

-- ============================================================================
-- Создание поля ввода (EditBox)
-- ============================================================================
function T_OoM:CreateEditBox(parent, width, height, maxLetters, onTextChanged)
    local editBox = CreateFrame("EditBox", nil, parent)

    editBox:SetWidth(width or 200)
    editBox:SetHeight(height or 24)
    editBox:DisableDrawLayer("BACKGROUND")

    if maxLetters then
        editBox:SetMaxLetters(maxLetters)
    end

    editBox:SetFontObject("ChatFontNormal")
    editBox:SetFont(FONT_PATH, 12)
    editBox:SetTextColor(
        self.Colors.textMain[1],
        self.Colors.textMain[2],
        self.Colors.textMain[3],
        1
    )

    -- Backdrop
    editBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        edgeSize = 1,
        tileSize = 16,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    editBox:SetBackdropColor(
        self.Colors.bgSection[1],
        self.Colors.bgSection[2],
        self.Colors.bgSection[3],
        1
    )
    editBox:SetBackdropBorderColor(
        self.Colors.borderMain[1],
        self.Colors.borderMain[2],
        self.Colors.borderMain[3],
        1
    )

    editBox:SetTextInsets(5, 4, 2, 4)
    editBox:SetAutoFocus(false)

    -- Фокус
    editBox:SetScript("OnEditFocusGained", function()
        T_OoM._focusedEditBox = editBox
        editBox:SetBackdropBorderColor(
            self.Colors.accentMain[1],
            self.Colors.accentMain[2],
            self.Colors.accentMain[3],
            1
        )
    end)

    editBox:SetScript("OnEditFocusLost", function()
        if T_OoM._focusedEditBox == editBox then
            T_OoM._focusedEditBox = nil
        end
        editBox:SetBackdropBorderColor(
            self.Colors.borderMain[1],
            self.Colors.borderMain[2],
            self.Colors.borderMain[3],
            1
        )
    end)

    -- OnTextChanged
    editBox:SetScript("OnTextChanged", function()
        if onTextChanged then
            onTextChanged(editBox, editBox:GetText())
        end
    end)

    -- Enter
    editBox:SetScript("OnEnterPressed", function()
        editBox:ClearFocus()
    end)

    -- Escape
    editBox:SetScript("OnEscapePressed", function()
        editBox:ClearFocus()
    end)

    return editBox
end

-- ============================================================================
-- Создание Dropdown
-- ============================================================================
function T_OoM:CreateDropdown(parent, items, onSelect, width)
    local dropdown = CreateFrame("Button", nil, parent)
    dropdown:SetWidth(width or 150)
    dropdown:SetHeight(24)

    -- Локальная ссылка на цвета (self в замыканиях = dropdown, а не T_OoM)
    local colors = T_OoM.Colors

    -- Backdrop
    dropdown:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    dropdown:SetBackdropColor(
        colors.bgSection[1],
        colors.bgSection[2],
        colors.bgSection[3],
        1
    )
    dropdown:SetBackdropBorderColor(
        colors.borderMain[1],
        colors.borderMain[2],
        colors.borderMain[3],
        1
    )

    -- Текст
    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY")
    dropdown.text:SetFont(FONT_PATH, 12)
    dropdown.text:SetTextColor(
        colors.textMain[1],
        colors.textMain[2],
        colors.textMain[3],
        1
    )
    dropdown.text:SetPoint("LEFT", dropdown, "LEFT", 8, 2)
    dropdown.text:SetText("")

    -- Стрелка
    dropdown.arrow = dropdown:CreateTexture(nil, "ARTWORK")
    dropdown.arrow:SetTexture("Interface\\AddOns\\T-OoM\\textures\\dropdown_down.tga")
    dropdown.arrow:SetWidth(16)
    dropdown.arrow:SetHeight(16)
    dropdown.arrow:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
    dropdown.arrow:SetVertexColor(
        colors.textMain[1],
        colors.textMain[2],
        colors.textMain[3],
        1
    )

    -- Данные
    dropdown.items = items or {}
    dropdown.selectedValue = nil
    dropdown.onSelect = onSelect
    dropdown.menuFrame = nil
    dropdown.isMenuOpen = false

    -- Функции
    function dropdown:SetValue(value)
        self.selectedValue = value
        for _, item in ipairs(self.items) do
            if item.value == value then
                self.text:SetText(item.text)
                break
            end
        end
    end

    function dropdown:GetValue()
        return self.selectedValue
    end

    function dropdown:OpenMenu()
        if self.isMenuOpen then
            self:CloseMenu()
            return
        end

        -- Меняем стрелку
        self.arrow:SetTexture("Interface\\AddOns\\T-OoM\\textures\\dropdown_up.tga")

        -- Закрываем другие
        if T_OoM._openDropdown and T_OoM._openDropdown ~= self then
            T_OoM._openDropdown:CloseMenu()
        end
        T_OoM._openDropdown = self

        -- Создаём меню
        if not self.menuFrame then
            self.menuFrame = CreateFrame("Frame", nil, UIParent)
            self.menuFrame:SetWidth(self:GetWidth())
            self.menuFrame:SetFrameStrata("TOOLTIP")
            self.menuFrame:SetFrameLevel(10)
            self.menuFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = 1,
                insets = {left = 1, right = 1, top = 1, bottom = 1},
            })
            self.menuFrame:SetBackdropColor(
                colors.bgMain[1],
                colors.bgMain[2],
                colors.bgMain[3],
                1
            )
            self.menuFrame:SetBackdropBorderColor(
                colors.borderMain[1],
                colors.borderMain[2],
                colors.borderMain[3],
                1
            )

            self.menuFrame.buttons = {}
            for i = 1, table.getn(self.items) do
                local item = self.items[i]
                local btn = CreateFrame("Button", nil, self.menuFrame)
                btn:SetHeight(20)
                btn:SetPoint("LEFT", self.menuFrame, "LEFT", 1, 0)
                btn:SetPoint("RIGHT", self.menuFrame, "RIGHT", -1, 0)
                btn:SetPoint("TOP", self.menuFrame, "TOP", 0, -(i - 1) * 20)

                -- Фон
                btn.bg = btn:CreateTexture(nil, "BACKGROUND")
                btn.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
                btn.bg:SetAllPoints(btn)
                btn.bg:SetVertexColor(
                    colors.borderMain[1],
                    colors.borderMain[2],
                    colors.borderMain[3],
                    0
                )

                -- Текст
                btn.text = btn:CreateFontString(nil, "OVERLAY")
                btn.text:SetFont(FONT_PATH, 12)
                btn.text:SetTextColor(
                    colors.textMain[1],
                    colors.textMain[2],
                    colors.textMain[3],
                    1
                )
                btn.text:SetPoint("LEFT", btn, "LEFT", 8, 2)

                -- Hover
                btn:SetScript("OnEnter", function()
                    btn.bg:SetVertexColor(
                        colors.borderMain[1],
                        colors.borderMain[2],
                        colors.borderMain[3],
                        0.5
                    )
                end)

                btn:SetScript("OnLeave", function()
                    btn.bg:SetVertexColor(
                        colors.borderMain[1],
                        colors.borderMain[2],
                        colors.borderMain[3],
                        0
                    )
                end)

                -- Клик
                btn:SetScript("OnClick", function()
                    dropdown:SetValue(item.value)
                    if dropdown.onSelect then
                        dropdown.onSelect(item.value, item)
                    end
                    dropdown:CloseMenu()
                end)

                self.menuFrame.buttons[i] = btn
            end
        end

        -- Обновляем кнопки
        for i, btn in ipairs(self.menuFrame.buttons) do
            local item = self.items[i]
            btn.text:SetText(item.text)
        end

        -- Показываем
        self.menuFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0)
        self.menuFrame:SetHeight(table.getn(self.items) * 20)
        self.menuFrame:Show()
        self.isMenuOpen = true
    end

    function dropdown:CloseMenu()
        if self.menuFrame then
            self.menuFrame:Hide()
        end
        self.isMenuOpen = false
        self.arrow:SetTexture("Interface\\AddOns\\T-OoM\\textures\\dropdown_down.tga")
        T_OoM._openDropdown = nil
    end

    -- Клик
    dropdown:SetScript("OnClick", function()
        dropdown:OpenMenu()
    end)

    -- Hover
    dropdown:SetScript("OnEnter", function()
        dropdown:SetBackdropColor(
            colors.bgMain[1],
            colors.bgMain[2],
            colors.bgMain[3],
            1
        )
        dropdown:SetBackdropBorderColor(
            colors.accentMain[1],
            colors.accentMain[2],
            colors.accentMain[3],
            1
        )
    end)

    dropdown:SetScript("OnLeave", function()
        dropdown:SetBackdropColor(
            colors.bgSection[1],
            colors.bgSection[2],
            colors.bgSection[3],
            1
        )
        dropdown:SetBackdropBorderColor(
            colors.borderMain[1],
            colors.borderMain[2],
            colors.borderMain[3],
            1
        )
    end)

    return dropdown
end
