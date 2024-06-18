--[[ CONFIGURE AS FUGAS AQUI ]]--


FUGA = {
    --example:     {spellToSay = 'izanagi', spellScreen = 'izanagi', cdTotal = 90, cdAtivo = 3, key = 'F1'},
    {spellToSay = '', spellScreen = '', cdTotal = XX, cdAtivo = XX, key = 'F1'},
    {spellToSay = '', spellScreen = '', cdTotal = XX, cdAtivo = XX, key = 'F1'},
    {spellToSay = '', spellScreen = '', cdTotal = XX, cdAtivo = XX, key = 'F1'},
}

local PERCENTAGE_HPPERCENT = 40; -- porcentagem base para as fugas
local ESCAPE_PZ = true; -- se estiver true, quando voce estiver com a vida necessaria para dar a fuga e estiver no pz vc vai deslogar, false o contrario.
local DELAY_RECONNECT = 10 -- so mude isso se o escape pz estiver true, é o cd para reconectar ** SEGUNDOS **
--NÃO EDITE NADA ABAIXO DAQUI
-------------------------------------------------------------------

--------------------[[ BY RYAN & VICTOR NEOX ]]--------------------
storage.widgetPos = storage.widgetPos or {}

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

local widgetFuga = {}

widgetFuga['fugaWidget'] = setupUI(widgetConfig, g_ui.getRootWidget())

local function attachSpellWidgetCallbacks(key)
    widgetFuga[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true
    end

    widgetFuga[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    widgetFuga[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX();
        storage.widgetPos[key].y = widget:getY();
        return true
    end
end

for key, value in pairs(widgetFuga) do
    attachSpellWidgetCallbacks(key)
    widgetFuga[key]:setPosition(
        storage.widgetPos[key] or {0, 50}
    )
end

-------------------------------------------------------------------

--------------------------[[ FUNCTIONS ]]--------------------------
local colorToMatch = {r = 0, g = 0, b = 0, a = 255}

-- functino que retorna a distancia do atacante
function distanceAttacker()
    for _, spec in ipairs(getSpectators()) do
        if spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) then
            return getDistanceBetween(pos(), spec:getPosition());
        end
    end
end

-- function que retorna os players atacantes
function playersAttack()
    local playersCount = 0;
    for _, spec in ipairs(getSpectators(true)) do
        if spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) and getDistanceBetween(pos(), spec:getPosition()) <= 10 then
            playersCount = playersCount + 1
        end
    end
    return playersCount;
end

-- function que define a porcentagem pra fuga pela quantidade de players atacantes
function percentageEscape()
    return playersAttack() and PERCENTAGE_HPPERCENT + (5 * tonumber(playersAttack())) or PERCENTAGE_HPPERCENT;
end

--------------------------------------------------------------------------

---------------------------[[ SCRIPT DE FUGA ]]---------------------------

local isKeyPressed = modules.corelib.g_keyboard.isKeyPressed;


FUGA.Script = macro(100, "Fuga", function()
    local selfHealth, hpEscape = g_game.getLocalPlayer():getHealthPercent(), percentageEscape()
    for index, value in ipairs(FUGA) do
        if ESCAPE_PZ and selfHealth <= hpEscape and isInPz() then
            modules.game_textmessage.displayGameMessage('Se voce continuar com o hp abaixo de ' .. PERCENTAGE_HPPERCENT .. ' em ' .. DELAY_RECONNECT*100 .. ' segundos voce ira deslogar.')
            schedule(DELAY_RECONNECT*100, function()
                modules.game_interface.tryLogout(false)
                modules.client_entergame.CharacterList.doLogin()
                delay(400)
            end)
            return
        end
        if (value.activeCd and value.activeCd >= now) then return; end
        if (selfHealth <= hpEscape or isKeyPressed(value.key)) and (not value.totalCd or value.totalCd <= now) then
            say(value.spellToSay)
        end
    end
end)

macro(100, function()
    widgetFuga['fugaWidget']:setText('Oponentes: ' .. playersAttack() .. ' | Porcentagem: ' .. percentageEscape() .. '.');
end);


--------------------[[ CHECANDO E DEFININDO OS CDS ]]--------------------

for index, value in ipairs(FUGA) do
    value.spellScreen = value.spellScreen:lower():trim()
end

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower();
    for index, value in ipairs(FUGA) do
        if text == value.spellScreen then
            value.totalCd = now + (value.cdTotal * 1000) - 250;
            value.activeCd = now + (value.cdAtivo * 1000) - 250;
            break;
        end
    end
end);
