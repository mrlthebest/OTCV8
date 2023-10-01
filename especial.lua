--[[
    Script de Especial
    by mrlthebest.
    28/07/2023
]]--
--[[ CONFIGURE OS ESPECIAIS AQUI ]]--

ESPECIAL = {
    --example:     {spellToSay = 'hakai', spellScreen = 'hakai', hpTarget = 15, distanceTarget = 3, cdTotal = 60, cdAtivo = 1, key = 'F1'},
    {spellToSay = '', spellScreen = '', hpTarget = XX, distanceTarget = XX, cdTotal = XX, cdAtivo = XX, key = 'F1'},
    {spellToSay = '', spellScreen = '', hpTarget = XX, distanceTarget = XX, cdTotal = XX, cdAtivo = XX, key = 'F1'},
    {spellToSay = '', spellScreen = '', hpTarget = XX, distanceTarget = XX, cdTotal = XX, cdAtivo = XX, key = 'F1'},
}

--------------------------------------------------------------------------
------------------------------[[ FUNCTIONS ]]-----------------------------

actualTarget = function() -- by ryan
    for key, func in pairs(g_game) do
        if key:lower():find('getatt') then
            local status, result = pcall(function()
                return func():getId()
            end)
            if status then
                local creature = getCreatureById(result)
                if creature then
                    return creature
                end
            end
        end
    end
end

-------------------------[[ SCRIPT DE ESPECIAL ]]-------------------------
local isKeyPressed = modules.corelib.g_keyboard.isKeyPressed

macro(100, "Especial", function()
    local target = actualTarget()
    local targetPos = target and target:getPosition()
    if not targetPos then return; end
    local targetDistance = getDistanceBetween(pos(), targetPos)

    for index, value in ipairs(ESPECIAL) do
        if (value.activeCd and value.activeCd <= now) then return; end
        if ((target:getHealthPercent() <= value.hpTarget and targetDistance <= value.distanceTarget) or isKeyPressed(value.key)) then
            if (not value.totalCd or value.totalCd <= now) then
                say(value.spellToSay)
            end
        end
    end
end)
      
--------------------[[ CHECANDO E DEFININDO OS CDS ]]---------------------

for index, value in ipairs(ESPECIAL) do
    value.spellScreen = value.spellScreen:lower():trim()
end

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower()

    for index, value in ipairs(ESPECIAL) do
        if text == value.spellScreen then
            value.totalCd = now + (value.cdTotal * 1000) - 250
            value.activeCd = now + (value.cdAtivo * 1000) - 250
            break
        end
    end
end)
