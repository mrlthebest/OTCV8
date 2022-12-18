addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    if text and #text:split(",") < 4 then
        return warn("por favor, inserir os valores na ordem (ID, HP, MP, CD)")
    end
    storage.potion = text
end)

macro(100, "Potion", function()
    local split = storage.potion:split(",")
    local id, hp, mp = tonumber(split[1]), tonumber(split[2]), tonumber(split[3])
    if (hppercent() <= hp or manapercent() <= mp) and (not potionCD or potionCD <= now) then
         useWith(id, player)
    end
end)  

onUseWith(function(_, itemId)
    if itemId == tonumber(storage.potion:split(",")[1]) then
        potionCD = storage.potion:split(",")[4] + now
    end
end)


