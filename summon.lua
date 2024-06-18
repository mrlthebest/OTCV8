local summon = {
    BySpell = false, -- se estiver false o summon do pet vai ser por item, se for true vai ser por spell
    Spell = '', -- spell
    Item = 11863, -- item do summon
    Qtd = 1, -- quantidade
    Name = '', -- nome do summon
};

macro(100, 'Summon', function()
    local summonCount = 0;
    local playerPos = player:getPosition();
    for _, spec in ipairs(getSpectators()) do
        if spec:isCreature() and spec ~= player then
            local specName = spec:getName():lower();
            local petName = summon.Name:lower();
            if specName == petName then
                local summonPos = spec:getPosition();
                local specHealth = spec:getHealthPercent();
                local floorDiff = math.abs(playerPos.z - summonPos.z);
                if (floorDiff > 3 or specHealth < 30) then
                    say('kai');
                    return;
                end
                summonCount = summonCount + 1;
            end
        end
    end
    if summonCount < summon.Qtd then
        if summon.BySpell then
            say(summon.Spell);
        else
            local findPetItem = findItem(summon.Item);
            if not findPetItem then return; end
            g_game.use(findPetItem);
        end
    end
end);
