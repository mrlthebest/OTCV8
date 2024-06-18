local configPotion = {
    idPotion = 11862,
    percentHp = 100,
    percentMana = 99, 
    cooldownPotion = 5000, -- em milisegundos
    hidePotionText = false, -- se estiver true, vai apagar a mensagem que está usando a senzu na tela, se for false, não.
    senzuName = 'senzu bean', -- nome da potion
    possibleTexts = { -- não altere
        'Aaahhh! Bem Melhor!', 
        'Aaahhh!', 
        'Bem Melhor!'
    },
}

macro(100, "Senzu", function()
    local selfHealth, selfMana = hppercent(), manapercent();
    if (selfHealth <= configPotion.percentHp or selfMana <= configPotion.percentMana) then
        if (not configPotion.cooldownUse or configPotion.cooldownUse <= now) then
            useWith(configPotion.idPotion, player)
        end
    end
end);

onTextMessage(function(mode, text)
    if not configPotion.hidePotionText then return; end
    if text:lower():find(configPotion.senzuName:lower()) then
        modules.game_textmessage.clearMessages();
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if (player:getName() ~= name) then return; end
    text = text:lower();
    for _, possibleText in ipairs(configPotion.possibleTexts) do
        filterText = possibleText:trim():lower();
        if text:find(filterText) then
            configPotion.cooldownUse = now + configPotion.cooldownPotion;
            break;
        end
    end
end);
