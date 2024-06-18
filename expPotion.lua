-------------------------------------------------------------------------------------------------------------------------

local setup = {
    idUse = 14648, -- id da potion
    cooldownFinder = 'com skill rate', -- texto que aparece ao usar a exp pot (branco) [ um trecho apenas. ]
    cooldownTip = 'hours', -- se quiser em segundos, bote em 'segundos'
    timeUse = 4, -- tempo respectivo ao estilo em cima.
}

-- não edite nada abaixo.
-------------------------------------------------------------------------------------------------------------------------

storage.widgetPos = storage.widgetPos or {};

local widgetConfig = [[
UIWidget
  background-color: #00000040
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true

]]

local expWidget = {};

expWidget['widget'] = setupUI(widgetConfig, g_ui.getRootWidget())

local function attachSpellWidgetCallbacks(key)
    expWidget[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true
    end

    expWidget[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    expWidget[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX();
        storage.widgetPos[key].y = widget:getY();
        return true
    end
end

for key, value in pairs(expWidget) do
    attachSpellWidgetCallbacks(key)
    expWidget[key]:setPosition(
        storage.widgetPos[key] or {0, 50}
    )
end

-------------------------------------------------------------------------------------------------------------------------

if type(storage.timeExp) ~= 'table' then
    storage.timeExp = {cooldown = 0};
end

-------------------------------------------------------------------------------------------------------------------------

local function formatRemainingTime(time)
    local remainingTime = (time - now) / 1000
    if remainingTime >= 3600 then
        local hours = math.floor(remainingTime / 3600)
        local minutes = math.floor((remainingTime % 3600) / 60)
        return string.format("%02d:%02d", hours, minutes)
    else
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        return string.format("%02d:%02d", minutes, seconds)
    end
end

-------------------------------------------------------------------------------------------------------------------------

macro(100, "Exp Potion", function()
    if isInPz() then return; end
    if storage.timeExp.cooldown < now then
        expWidget['widget']:setText('Exp Time: OK')
        useWith(setup.idUse, player)
    else
        expWidget['widget']:setText('Exp Time: ' .. formatRemainingTime(storage.timeExp.cooldown))
    end
end);

-------------------------------------------------------------------------------------------------------------------------
onTextMessage(function(mode, text)
    text = text:lower();
    if text:find(setup.cooldownFinder:lower()) then
        local cooldownTime = setup.timeUse;
        if setup.cooldownTip == 'minutes' then
            storage.timeExp.cooldown = now + cooldownTime * 60 * 1000;
        elseif setup.cooldownTip == 'hours' then
            storage.timeExp.cooldown = now + cooldownTime * 3600 * 1000;
        else
            print("Tipo de cooldown invalido, suportes: minutes, hours.");
        end
    end
end);

-------------------------------------------------------------------------------------------------------------------------
