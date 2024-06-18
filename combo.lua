COMBO = {
    --example:     {text = 'big explosion', cooldown = 1, targetDistance = 3, targetLife = 100, playerLvl = 50},
    {text = '', cooldown = XX, targetDistance = XX, targetLife = XX, playerLvl = XX},
    {text = '', cooldown = XX, targetDistance = XX, targetLife = XX, playerLvl = XX},
    {text = '', cooldown = XX, targetDistance = XX, targetLife = XX, playerLvl = XX},
}

for index, value in ipairs(COMBO) do
    value.text = value.text:lower():trim();
end

macro(100, "Combo", function()
    local target, playerPos = g_game.getAttackingCreature(), pos();
    if not g_game.isAttacking() then return; end
    if target then
        local targetPosition = target:getPosition();
        if not targetPosition then return; end
        targetPos = getDistanceBetween(playerPos, targetPosition);
        targetHealth = target:getHealthPercent();
        for index, value in ipairs(COMBO) do
            if targetPos <= value.targetDistance and targetHealth <= value.targetLife and player:getLevel() >= value.playerLvl then
                if (not value.cooldownSpells or value.cooldownSpells <= now) then
                    say(value.text)
                end
            end
        end
    end
end);


onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower()
    for index, value in ipairs(COMBO) do
        if text == value.text then
            value.cooldownSpells = now + (value.cooldown * 1000);
            break;
        end
    end
end);


