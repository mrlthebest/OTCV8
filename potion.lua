addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    storage.potion = text
end)


potionSetup = tonumber(storage.potion:split(','))


macro(100, "Potion", function()
        if (hppercent() <= potionSetup[2] or manapercent() <= potionSetup[3] and
            (not potionCD or potionCD <= now) then
            return useWith(potionSetup[1], player)
        end
end)

onUseWith(function(sla, itemId)
        if potionSetup[1] == itemId then
            potionCD = now + potionSetup[4]
    end
end)

