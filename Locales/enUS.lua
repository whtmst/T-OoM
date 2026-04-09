-- ============================================================================
-- T-OoM - Localization (English)
-- ============================================================================

-- Экспортируем в отдельную таблицу (не в T_OoM.L напрямую)
T_OoM_Locale_enUS = {}
local L = T_OoM_Locale_enUS

-- ============================================================================
-- Main window
-- ============================================================================
L.CONFIG_WINDOW_TITLE = "T-OoM Settings"
L.ADDON_TITLE = "T-OoM"
L.ADDON_DESCRIPTION = "Out of Mana announcer"

-- ============================================================================
-- General settings
-- ============================================================================
L.GENERAL_SECTION = "General Settings"
L.ENABLE_ADDON = "Enable T-OoM announce"
L.LANGUAGE = "Language"
L.LANGUAGE_EN = "English"
L.LANGUAGE_RU = "Russian"

-- ============================================================================
-- Message settings
-- ============================================================================
L.MESSAGE_SECTION = "Mana Messages"
L.LOW_MANA_MSG = "Low Mana Message"
L.CRITICAL_MANA_MSG = "Critical Low Mana Message"
L.OUT_OF_MANA_MSG = "Out of Mana Message"
L.MESSAGE_MAX_LENGTH = "(max 120 chars)"

-- ============================================================================
-- Threshold settings
-- ============================================================================
L.THRESHOLD_SECTION = "Mana Thresholds"
L.THRESHOLD_LOW = "Threshold: Low Mana"
L.THRESHOLD_CRITICAL = "Threshold: Critical Mana"
L.THRESHOLD_OUT = "Threshold: Out of Mana"
L.THRESHOLD_PERCENT = "%d%%"

-- ============================================================================
-- Channel settings
-- ============================================================================
L.CHANNEL_SECTION = "Announce Channel"
L.CHANNEL = "Choose Channel"
L.CHANNEL_SAY = "Say"
L.CHANNEL_PARTY = "Party"
L.CHANNEL_RAID = "Raid"

-- ============================================================================
-- Instance mode
-- ============================================================================
L.INSTANCE_MODE_SECTION = "Instance Mode"
L.INSTANCE_MODE = "Where announcer is active"
L.INSTANCE_MODE_WORLD = "Open World"
L.INSTANCE_MODE_INSTANCE = "Dungeons/Raids"
L.INSTANCE_MODE_ALWAYS = "Always"

-- ============================================================================
-- Action buttons
-- ============================================================================
L.APPLY_SETTINGS = "Apply"
L.CANCEL = "Cancel"
L.RESET_DEFAULTS = "Reset to Defaults"

-- ============================================================================
-- Slash commands
-- ============================================================================
L.CMD_HELP_TITLE = "T-OoM Commands:"
L.CMD_CONFIG = "/toom config - Open settings window"
L.CMD_LANG = "/toom lang <en/ru> - Change language"
L.CMD_LANG_CHANGED = "Language changed to: "
L.CMD_LANG_RELOAD = "Note: Type /reload to fully apply the language"
L.CMD_LANG_NOT_FOUND = "Language not found: "
L.CMD_CONFIG_OPEN = "Settings window opened"
L.CMD_UNKNOWN = "Unknown command: "
L.CMD_USE_HELP = "Type |cFF11A6EC/toom|r for help"

-- ============================================================================
-- Minimap button
-- ============================================================================
L.MINIMAP_TOOLTIP_LINE1 = "T-OoM - Out of Mana announcer"
L.MINIMAP_TOOLTIP_CLICK = "Open config window"
L.MINIMAP_TOOLTIP_MOVE = "Move (around minimap)"
L.MINIMAP_TOOLTIP_FREE = "Free move (Ctrl + LMB)"
L.MINIMAP_TOOLTIP_LMB = "LMB"
L.MINIMAP_TOOLTIP_DRAG = "Drag"
L.MINIMAP_TOOLTIP_RESET = "Reset position"
L.MINIMAP_TOOLTIP_CTRL_RMB = "Ctrl + RMB"
L.MINIMAP_VERSION = "Version:"

-- ============================================================================
-- Status messages
-- ============================================================================
L.ADDON_LOADED = "T-OoM loaded successfully!"
L.SETTINGS_APPLIED = "Settings applied and saved!"
L.SETTINGS_RESET = "Settings reset to defaults!"
L.SETTINGS_CANCELLED = "Settings cancelled"
L.MESSAGE_TRUNCATED = "Message truncated to %d symbols!"
L.MESSAGE_ERROR = "Message length must be 1-120 characters!"

-- ============================================================================
-- Instance detection
-- ============================================================================
L.INSTANCE_WORLD = "Open World"
L.INSTANCE_PARTY = "Dungeon"
L.INSTANCE_RAID = "Raid"
L.INSTANCE_PVP = "Battleground"
L.INSTANCE_ARENA = "Arena"
