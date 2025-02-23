setup = {
    spellToSay = '',
    spellScreen = 'a',
    amountLifes = 3,
    cooldownSpell = 10,
    percentScape = 40,
    countLifes = 0,
    cooldownSet = false,
}

storage.widgetPos = storage.widgetPos or {}
storage.widgetPosSaved = storage.widgetPosSaved or false

local widgetConfig = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true
]]

local testTable = {}

testTable['fugaWidget'] = setupUI(widgetConfig, g_ui.getRootWidget())

local function attachSpellWidgetCallbacks(key)
    testTable[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true
    end

    testTable[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    testTable[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX();
        storage.widgetPos[key].y = widget:getY();
        return true
    end
end

for key, value in pairs(testTable) do
    attachSpellWidgetCallbacks(key)
    testTable[key]:setPosition(
        storage.widgetPos[key] or {0, 50}
    )
end

local function formatRemainingTime(time)
    local remainingTime = (time - now) / 1000
    return string.format("%.0fs", math.max(0, remainingTime))
end




macro(100, "Danzou", function()
    local matchLifes = setup.amountLifes - setup.countLifes;
    testTable['fugaWidget']:setText('Life: ' .. hppercent()  .. '/' .. setup.percentScape  .. ' | Vidas Restantes: ' .. matchLifes .. ' | Cooldown: ' .. formatRemainingTime(setup.setTimeScreen or 0))
    if matchLifes >= 1 then
        if hppercent() <= setup.percentScape and (not setup.setTimeScreen or setup.setTimeScreen <= now) then
            say(setup.spellToSay)
        end
    end
    if setup.setTimeScreen and setup.setTimeScreen <= now then
        setup.countLifes = 0;
        setup.setTimeScreen = nil;
    end
end)

onTalk(function(name, level, mode, text, channelId, pos)
    text = text:lower()
    if name ~= player:getName() then return; end

    if text == setup.spellScreen:lower() and setup.amountLifes - setup.countLifes > 0 then
        setup.countLifes = setup.countLifes + 1;
        if not setup.setTimeScreen then
            setup.setTimeScreen = now + setup.cooldownSpell * 1000;
        end
    end
end)
