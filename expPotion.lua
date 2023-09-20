--[[
    Script de EXP Potion
    by mrlthebest.
    28/07/2023
]]--

local p = {}

macro(100, "Exp Potion", function()
    local setup = storage.expSetup:split(",");
    local potId = tonumber(setup[1])
    if isInPz() then return; end
    if not p.cdW or p.cdW <= os.time() then
        if findItem(potId) then
            useWith(potId, player)
        else
            warn('Exp pot não encontrada.')
            return
        end
    end
end)

onUseWith(function(pos, itemId, target, subType)
    local setup = storage.expSetup:split(",");
    local potId = tonumber(setup[1])
    if itemId == potId then
        p.cdW = os.time() + (tonumber(setup[2]) * 60)
    end
end)


addTextEdit("ID, MINUTOS", storage.expSetup or "ID, MINUTOS", function(widget, text)
    if text and #text:split(",") < 2 then
        return warn("por favor, inserir os valores na ordem (ID, MINUTOS)")
    end
    storage.expSetup = text
end)

