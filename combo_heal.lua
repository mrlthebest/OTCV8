local spells = {
    --[[
        spell_say: Spell para falar
        spell_screen: Spell que aparece na tela(laranja)
        hppercent: porcentagem pra usar 
        cooldown: cooldown para usar novamente em milisegundos.
        exhaust: exhaust que dá nas outras spells em milisegundos.
    ]]
    {spell_say = '', spell_screen = '', hppercent = 99, cooldown = 0, exhaust = 0},
}

for _, config in ipairs(spells) do
    config.spell_screen = config.spell_screen:lower():trim()
end

macro(100, "Combo Heal", function()
    local playerHealth = hppercent()
    for _, config in ipairs(spells) do
        if (config.spellExhaust and config.spellExhaust >= now) then
            return;
        end
        if playerHealth <= config.hppercent then
            if not config.spellCooldown or config.spellCooldown <= now then
                say(config.spell_say)
            end
        end
    end
end)


onTalk(function(name, level, mode, text, channelId, pos)
    if (name ~= player:getName()) then
        return;
    end
    text = text:lower()
    for _, config in ipairs(spells) do
        if config.spell_screen == text then
            config.spellCooldown = now + config.cooldown
            config.spellExhaust = now + config.exhaust
            break
        end
    end
end)
