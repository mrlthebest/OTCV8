UI.Button("Friend List", function(newText)
    UI.MultilineEditorWindow(storage.friendList or "", {title="FriendList", description="Example: \nplayer \nplayer"}, function(text)
        storage.friendList = text;
    end)
end)

addTextEdit("Pot: id, delay, distance, percentage", storage.potConfig or "Pot: id, delay, distance, percentage", function(widget, text)
    storage.healFriend = text;
end)

function isFriend(name, friendList)
    local configList = string.split(friendList, '\n')
    return table.contains(configList, name, true)
end

macro(100, "Heal Friend", function()
    local pos = pos();
    local splitPot = storage.healFriend:split(',');
    local friendList = storage.friendList
    for _, spec in ipairs(getSpectators()) do
        if isFriend(spec:getName(), friendList) then
            if spec:getHealthPercent() <= tonumber(splitPot[4]) and
                getDistanceBetween(pos, spec:getPosition()) <= tonumber(splitPot[3]) then
                if (not cd or cd <= now) then
                    useWith(tonumber(splitPot[1]), spec)
                    cd = now + (tonumber(splitPot[2]) * 1000)
                end
            end
        end
    end
end)
