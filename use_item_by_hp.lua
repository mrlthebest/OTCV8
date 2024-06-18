local config = {
    itemId = 11863, -- id do item
    itemCooldown = 60, -- em segundos
    hpPercent = 100, -- porcentagem de vida p usar
    itemText = 'aaahhh! bem melhor!', -- mensagem em laranja que aparece ao usar
};

macro(100, "Item HP", function()
    if hppercent() >= config.hpPercent then return; end
    if (not config.cooldownItem or config.cooldownItem <= os.time()) then
        local item_use = findItem(itemId);
        if not item_use then return; end
        g_game.use(item_use)
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end

    text = text:lower();

    if text == config.itemText:lower() then
        config.cooldownItem = os.time() + config.itemCooldown;
    end
end);
