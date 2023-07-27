local s = {}

macro(100, "Potion", function()
    local configSenzu = tonumber(storage.potion:split(","));
    if (hppercent() <= configSenzu[2] or manapercent() <= configSenzu[3]) and (not s.cdW or s.cdW <= now) then
        useWith(configSenzu[1], player)
    end
end)

onUseWith(function(pos, itemId, target, subType)
    local configSenzu = tonumber(storage.potion:split(","));
    if itemId == configSenzu[1] then
        s.cdW = now + configSenzu[4]
    end
end)

addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    if text and #text:split(",") < 4 then
        return warn("por favor, inserir os valores na ordem (ID, HP, MP, CD)")
    end
    storage.potion = text
end)
