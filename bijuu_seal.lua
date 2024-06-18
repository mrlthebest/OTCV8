local configSeal = {
    spellSeal = 'explosion kunai ', -- spell de selar
    cooldownSeal = 60, -- coldown da spell, em segundos
    percentSeal = 25, -- porcentagem p selar
    possibleBijuuNames = { -- nome das bijuus pré configurada pro ultimate
        'Shukaku',
        'matatabi',
        'isobu',
        'son goku',
        'kokuou',
        'saiken',
        'choumei',
        'gyuki',
        'kurama',
    },
}

macro(100, "Selar", function()
    local findBijuu;
    local actualTarget = g_game.getAttackingCreature();
    for _, bijuuName in ipairs(configSeal.possibleBijuuNames) do
        local potentialBijuu = getCreatureByName(bijuuName:lower());
        if potentialBijuu then
            findBijuu = potentialBijuu;
            break;
        end
    end
    if not findBijuu then return; end
    if (configSeal.cooldownSpell and configSeal.cooldownSpell >= os.time()) then return; end
    if (not actualTarget or actualTarget:getName() ~= findBijuu:getName()) then
        g_game.attack(findBijuu)
    elseif actualTarget and actualTarget:getHealthPercent() <= configSeal.percentSeal then
        say(configSeal.spellSeal)
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower();
    local filterSealSpell = configSeal.spellSeal:lower();
    if text == filterSealSpell then
        configSeal.cooldownSpell = os.time() + configSeal.cooldownSeal;
    end
end);
