storage.widgetPos = storage.widgetPos or {};

local widgetConfig = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true
  color: white
  text-align: left 

]]

local trainWidget = {};

trainWidget['widget'] = setupUI(widgetConfig, g_ui.getRootWidget());

local function attachSpellWidgetCallbacks(key)
    trainWidget[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true
    end

    trainWidget[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    trainWidget[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX();
        storage.widgetPos[key].y = widget:getY();
        return true
    end
end

for key, value in pairs(trainWidget) do
    attachSpellWidgetCallbacks(key)
    trainWidget[key]:setPosition(
        storage.widgetPos[key] or {0, 50}
    )
end

local function showSkillLevel(skill, type)
    local Types = {
        Fist = 0,
        Club = 1,
        Sword = 2,
        Axe = 3,
        Distance = 4,
        Shielding = 5,
        Fishing = 6,
        CriticalChance = 7,
        CriticalDamage = 8,
        LifeLeechChance = 9,
        LifeLeechAmount = 10,
        ManaLeechChance = 11,
        ManaLeechAmount = 12
    }
    if type == 'percent' then
        return player:getSkillLevelPercent(Types[skill])
    elseif type == 'level' then
        return player:getSkillLevel(Types[skill])
    end
end

local function calcStamina()
    local stam = stamina()
    local hours = math.floor(stam / 60)
    local minutes = stam % 60
    if minutes < 10 then
        minutes = '0' .. minutes
    end
    local percent = math.floor(100 * stam / (42 * 60))
    return hours.. ':'.. minutes, ' ('..percent..'%)'
end

macro(100, function()
    trainWidget['widget']:setText(
        '~ Level: ' .. player:getLevel() .. '/' .. player:getLevel() + 1 .. ' - ' .. player:getLevelPercent() .. '%' ..
        '\n~ Magic Level: ' .. player:getMagicLevel() .. '/' .. player:getMagicLevel() + 1 .. ' - ' .. player:getMagicLevelPercent() .. '%' ..
        '\n~ Fist: ' .. showSkillLevel('Fist', 'level') .. '/' .. showSkillLevel('Fist', 'level') + 1 .. ' - ' .. showSkillLevel('Fist', 'percent') .. '%' ..
        '\n~ Glove: ' .. showSkillLevel('Club', 'level') .. '/' .. showSkillLevel('Club', 'level') + 1 .. ' - ' .. showSkillLevel('Club', 'percent') .. '%' ..
        '\n~ Axe: ' .. showSkillLevel('Axe', 'level') .. '/' .. showSkillLevel('Axe', 'level') + 1 .. ' - ' .. showSkillLevel('Axe', 'percent') .. '%' ..
        '\n~ Sword: ' .. showSkillLevel('Sword', 'level') .. '/' .. showSkillLevel('Sword', 'level') + 1 .. ' - ' .. showSkillLevel('Sword', 'percent') .. '%' ..
        '\n~ Distance: ' .. showSkillLevel('Distance', 'level') .. '/' .. showSkillLevel('Distance', 'level') + 1 .. ' - ' .. showSkillLevel('Distance', 'percent') .. '%' ..
        '\n~ Shield: ' .. showSkillLevel('Shielding', 'level') .. '/' .. showSkillLevel('Shielding', 'level') + 1 .. ' - ' .. showSkillLevel('Shielding', 'percent') .. '%' ..
        '\n~ Stamina: ' .. calcStamina()
    )
end);





