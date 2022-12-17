addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    storage.potion = text
end)


potionSetup = storage.potion:split(',')


macro(100, "Potion", function()
    for _, potionConfig in ipairs(potionSetup) do
        if (hppercent() <= tonumber(potionSetup[2]) or manapercent() <= tonumber(potionSetup[3])) and
            (not potionCD or potionCD <= now) then
                return useWith(tonumber(potionSetup[1]), player)
            end
        end
end)

onUseWith(function(sla, itemId)
    for _, potionConfig in ipairs(potionSetup) do
        if tonumber(potionSetup[1]) == itemId then
            potionCD = now + tonumber(potionSetup[4])
        end
    end
end)
