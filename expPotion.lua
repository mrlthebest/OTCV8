local p = {}

macro(100, "Exp Potion", function()
    local setup = storage.expSetup:split(",");
    if isInPz() then return; end
    if not p.cdW or p.cdW <= os.time() then
        if findItem(setup[1]) then
            useWith(setup[1], player)
        else
            warn('Exp pot não encontrada.')
            return
        end
    end
end)

onUseWith(function(pos, itemId, target, subType)
    local setup = storage.expSetup:split(",");
    if itemId == setup[1] then
        p.cdW = os.time() + (setup[2] * 60)
    end
end)


addTextEdit("ID, MINUTOS", storage.expSetup or "ID, MINUTOS", function(widget, text)
    if text and #text:split(",") < 2 then
        return warn("por favor, inserir os valores na ordem (ID, MINUTOS)")
    end
    storage.expSetup = tonumber(text);
end)

