addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    storage.potion = text
end)


potionSetup = storage.potion:split(',')


macro(100, "Potion", function()
    for _, potionConfig in ipairs(potionSetup) do
        if (hppercent() <= tonumber(potionConfig[2]) or manapercent() <= tonumber(potionConfig[3])) and
            (not potionCD or potionCD <= now) then
                return useWith(tonumber(potionConfig[1]), player)
            end
        end
end)

onUseWith(function(sla, itemId)
    for _, potionConfig in ipairs(potionSetup) do
        if tonumber(potionConfig[1]) == itemId then
            potionCD = now + tonumber(potionConfig[4])
        end
    end
end)
