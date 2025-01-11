local bijuuOutfit = 23; -- id da bijuu

-- n altere abaixo
local bijuuSpells = {
    {spell = 'bijuu fuujin', cooldown = 5},
    {spell = 'bijuu yaiba', cooldown = 10}
};

macro(100, "Bijuu Attack", function()
    if player:getOutfit().type ~= bijuuOutfit then return; end
    if not g_game.isAttacking() then return; end
    for key, value in ipairs(bijuuSpells) do
        if (not value.cooldownSpells or value.cooldownSpells <= os.time()) then
            say(value.spell)
        end
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower();
    for key, value in ipairs(bijuuSpells) do
        if text == value.spell then
            value.cooldownSpells = os.time() + value.cooldown;
            break;
        end
    end
end);
