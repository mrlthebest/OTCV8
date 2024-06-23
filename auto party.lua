local config = {
    phrasePt = 'party aqui', -- mensagem de party
    playerList = { -- lista de players que se aparecer na tela vai invitar
        'mrl',
        'marl',
        'cia'
    }
};

function findPlayer(creatureName)
    for _, playerName in ipairs(config.playerList) do
        if playerName:lower() == creatureName:lower() then
            return true;
        end
    end
    return false;
end

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return end
    text = text:lower();
    local toFind = config.phrasePt:lower();
    if text:find(toFind) then
        for _, playerName in ipairs(config.playerList) do
            local possiblePlayer = getCreatureByName(playerName)
            if possiblePlayer and not possiblePlayer:isPartyMember() then
                g_game.partyInvite(possiblePlayer:getId())
            end
        end
    end
end);

onCreatureAppear(function(creature)
    if not creature:isPlayer() then return end
    if findPlayer(creature:getName()) then
        if not creature:isPartyMember() then
            g_game.partyInvite(creature:getId())
        end
    end
end);

