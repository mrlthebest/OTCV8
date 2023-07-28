local s = {}

macro(100, "Potion", function()
    local configSenzu = storage.potion:split(",");
    if (hppercent() <= tonumber(configSenzu[2]) or manapercent() <= tonumber(configSenzu[3])) and (not s.cdW or s.cdW <= now) then
        useWith(tonumber(configSenzu[1]), player)
    end
end)

onUseWith(function(pos, itemId, target, subType)
    local configSenzu = storage.potion:split(",");
    if itemId == tonumber(configSenzu[1]) then
        s.cdW = now + tonumber(configSenzu[4])
    end
end)

addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    if text and #text:split(",") < 4 then
        return warn("por favor, inserir os valores na ordem (ID, HP, MP, CD)")
    end
    storage.potion = text
end)
