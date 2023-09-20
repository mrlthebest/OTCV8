--[[
    Script de Combo
    by mrlthebest.
    19/08/2023
]]--

COMBO = {
    {text = '', cooldown = XX, targetDistance = XX, targetLife = XX, playerLvl = XX},
    {text = '', cooldown = XX, targetDistance = XX, targetLife = XX, playerLvl = XX},
    {text = '', cooldown = XX, targetDistance = XX, targetLife = XX, playerLvl = XX},
}

for index, value in ipairs(COMBO) do
    value.text = value.text:lower():trim()
end

            
local scriptCombo = macro(100, "Combo", function()
    local target, pos = g_game.getAttackingCreature(), pos()
    if not g_game.isAttacking() then return; end
    if target and target:getPosition() then
        targetPos = getDistanceBetween(pos, target:getPosition())
        targetHealth = target:getHealthPercent()
        for index, value in ipairs(COMBO) do
            if targetPos <= value.targetDistance and targetHealth <= value.targetLife and player:getLevel() >= value.playerLvl then
                if (not value.cooldownSpells or value.cooldownSpells <= now) then
                    say(value.text)
                end
            end
        end
    end
end)


onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower()
    for index, value in ipairs(COMBO) do
        if text == value.text then
            value.cooldownSpells = now + (value.cooldown * 1000)
            break
        end
    end
end)


