local configRegen = {
    spell = '',
    percentage = 99,
    cooldown = 1000, -- em milisegundos
};

macro(100, "Regeneration", function()
    if hppercent() <= configRegen.percentage then
        if (not configRegen.cooldownSpell or configRegen.cooldownSpell <= now) then
            say(configRegen.spell)
        end
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower();

    toFind = configRegen.spell:lower();
    if text == toFind then
        configRegen.cooldownSpell = now + configRegen.cooldown;
    end
end);
