-- ============================================================================
-- T-OoM - Модуль мониторинга маны
-- ============================================================================
-- Отслеживает уровень маны и вызывает callback при достижении порогов
-- Использует IsInInstance() для определения нахождения в подземелье/рейде
-- ============================================================================

-- T_OoM может ещё не существовать
if not T_OoM then T_OoM = {} end

-- Локальные переменные
local ManaMonitorFrame = nil
local lastManaPercent = 0
-- Флаги: сработал ли уже данный порог (независимо друг от друга)
local crossedThreshold1 = false  -- Сработал ли порог 1 (например, 30%)
local crossedThreshold2 = false  -- Сработал ли порог 2 (например, 15%)
local crossedThreshold3 = false  -- Сработал ли порог 3 (например, 5%)
local callbacks = {}

-- ============================================================================
-- Инициализация
-- ============================================================================
function T_OoM:InitializeManaMonitor()
    if ManaMonitorFrame then
        return
    end

    -- Создаём фрейм для событий
    ManaMonitorFrame = CreateFrame("Frame", "TOoMManaMonitorFrame")
    ManaMonitorFrame:RegisterEvent("UNIT_MANA")
    ManaMonitorFrame:RegisterEvent("UNIT_MAXMANA")
    ManaMonitorFrame:RegisterEvent("UNIT_DISPLAYPOWER")

    ManaMonitorFrame:SetScript("OnEvent", function()
        if arg1 == "player" then
            T_OoM:OnManaUpdate()
        end
    end)

    -- Начальная проверка
    T_OoM:OnManaUpdate()
end

-- ============================================================================
-- Обработчик обновления маны
-- ============================================================================
function T_OoM:OnManaUpdate()
    -- Проверяем, включён ли аддон (1 = вкл, 0 = выкл)
    if T_OoM_Config.enabled ~= 1 then
        return
    end

    -- Проверяем тип энергии (должна быть мана)
    local powerType = UnitPowerType("player")
    if powerType ~= 0 then  -- 0 = MANA
        return
    end

    -- Получаем текущий уровень маны
    local currentMana = UnitMana("player")
    local maxMana = UnitManaMax("player")

    if not currentMana or not maxMana or maxMana == 0 then
        return
    end

    local manaPercent = currentMana / maxMana

    -- Проверяем пороги
    T_OoM:CheckManaThresholds(manaPercent)

    lastManaPercent = manaPercent
end

-- ============================================================================
-- Проверка порогов маны
-- Каждый порог работает независимо: срабатывает при падении ниже, сбрасывается при подъёме выше
-- ============================================================================
function T_OoM:CheckManaThresholds(manaPercent)
    local threshold1 = T_OoM_Config.threshold1 / 100  -- например, 30% -> 0.30
    local threshold2 = T_OoM_Config.threshold2 / 100  -- например, 15% -> 0.15
    local threshold3 = T_OoM_Config.threshold3 / 100  -- например, 5% -> 0.05

    -- Проверяем, где мы находимся
    local inInstance, instanceType = IsInInstance()

    -- Проверяем режим работы
    local mode = T_OoM_Config.instanceMode or "instance"

    if mode == "world" then
        -- Только открытый мир
        if inInstance then
            return
        end
    elseif mode == "instance" then
        -- Только подземелья/рейды
        if not inInstance then
            return
        end
    end
    -- mode == "always" - работаем везде, проверок нет

    -- Определяем, какие пороги мы пересекли в этом кадре (были выше, стали ниже)
    local crossed1 = (lastManaPercent > threshold1) and (manaPercent <= threshold1)
    local crossed2 = (lastManaPercent > threshold2) and (manaPercent <= threshold2)
    local crossed3 = (lastManaPercent > threshold3) and (manaPercent <= threshold3)

    -- Если пересекли несколько порогов за раз (резкое падение) - срабатываем только самый критичный
    local triggerThreshold = 0
    if crossed3 then
        triggerThreshold = 3
    elseif crossed2 then
        triggerThreshold = 2
    elseif crossed1 then
        triggerThreshold = 1
    end

    -- Сброс флагов: если мана поднялась выше порога - сбрасываем его флаг
    if manaPercent > threshold1 then
        crossedThreshold1 = false
    end
    if manaPercent > threshold2 then
        crossedThreshold2 = false
    end
    if manaPercent > threshold3 then
        crossedThreshold3 = false
    end

    -- Срабатываем, если пересекли порог и его флаг ещё не стоит
    if triggerThreshold > 0 then
        local message = nil
        local alreadyTriggered = false

        if triggerThreshold == 3 then
            message = T_OoM_Config.message3
            alreadyTriggered = crossedThreshold3
        elseif triggerThreshold == 2 then
            message = T_OoM_Config.message2
            alreadyTriggered = crossedThreshold2
        else
            message = T_OoM_Config.message1
            alreadyTriggered = crossedThreshold1
        end

        if message and message ~= "" and not alreadyTriggered then
            -- Ставим флаг, что этот порог сработал
            if triggerThreshold == 3 then
                crossedThreshold3 = true
            elseif triggerThreshold == 2 then
                crossedThreshold2 = true
            else
                crossedThreshold1 = true
            end

            -- Помечаем все более низкие пороги как "пройденные" (чтобы не спамили при резком падении)
            if triggerThreshold == 1 then
                crossedThreshold2 = true
                crossedThreshold3 = true
            elseif triggerThreshold == 2 then
                crossedThreshold3 = true
            end

            -- Вызываем callback отображения
            T_OoM:OnManaThresholdReached({
                threshold = triggerThreshold,
                message = message,
                manaPercent = manaPercent,
                instanceType = instanceType or "none",
                inInstance = inInstance or false,
            })
        end
    end
end

-- ============================================================================
-- Callback при достижении порога маны
-- ============================================================================
function T_OoM:OnManaThresholdReached(data)
    -- Вызываем зарегистрированные callback'и
    for _, callback in ipairs(callbacks) do
        if type(callback) == "function" then
            callback(data)
        end
    end

    -- Отправляем сообщение в чат
    T_OoM:SendManaMessage(data)
end

-- ============================================================================
-- Отправка сообщения о мане в чат
-- ============================================================================
function T_OoM:SendManaMessage(data)
    local message = data.message
    if not message or message == "" then
        return
    end

    local channel = T_OoM_Config.chatChannel or "SAY"

    -- Проверяем, можно ли отправить в этом канале
    -- PARTY/RAID требуют нахождения в группе/рейде
    if channel == "PARTY" then
        if GetNumPartyMembers() == 0 then
            return
        end
    elseif channel == "RAID" then
        if GetNumRaidMembers() == 0 then
            return
        end
    end

    -- Отправляем сообщение
    SendChatMessage(message, channel)
end

-- ============================================================================
-- Регистрация callback'а
-- ============================================================================
function T_OoM:RegisterManaCallback(callback)
    if type(callback) == "function" then
        table.insert(callbacks, callback)
    end
end

-- ============================================================================
-- Сброс состояния
-- ============================================================================
function T_OoM:ResetManaMonitor()
    lastManaPercent = 0
    crossedThreshold1 = false
    crossedThreshold2 = false
    crossedThreshold3 = false
end
