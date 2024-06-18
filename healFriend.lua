UI.Button("Friend List", function(newText)
    UI.MultilineEditorWindow(storage.friendList or '', {title="FriendList", description="Example: \nplayer \nplayer"}, function(text)
        storage.friendList = text;
    end)
end)

addTextEdit("Pot: Spell, delay, distance, percentage", storage.healFriend or "Pot: Spell, delay, distance, percentage", function(widget, text)
    storage.healFriend = text;
end)


macro(100, "Heal Friend",function()
    local playerPos = pos();
    local friendList = string.split(storage.friendList, '\n');
    local configHeal = storage.healFriend:split(',');
    for _, spec in ipairs(getSpectators()) do
        if (table.contains(friendList, spec:getName(), true) or (spec:getEmblem() == 1 or spec:getShield() == 3)) then
            local specPos = spec:getPosition();
            local specHealth = spec:getHealthPercent();
            if not specPos then return; end
            local distanceToSpec = getDistanceBetween(playerPos, specPos);
            if distanceToSpec <= tonumber(configHeal[3]) and specHealth <= tonumber(configHeal[4]) then
                say(configHeal[1] .. ' "' .. spec:getName())
                --useWith(tonumber(configHeal[1], spec) // para item, tire as duas "--" dessa linha e adicione na linha acima.
                delay(tonumber(configHeal[2]))
            end
        end
    end
end);
