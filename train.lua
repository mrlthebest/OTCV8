local config = {
    regen_mana_by_spell = false, -- se o teu regen de mana for por spell, deixe true, se n, false
    regen_mana_spell = '', -- spell p regenerar mana
    regen_mana_by_item = false, -- se o teu regen de mana for por item, deixe true, se n, false
    regen_mana_id_item = 11863, -- item p regenerar mana
    percent_train_ml = 90, -- porcentagem que irá intercalar entre regenerar e treinar, < regen > train
    spell_train = '', -- spell de treino
}

macro(100, "Train", function()
    if manapercent() <= config.percent_train_ml then
        if config.regen_mana_by_item then
            useWith(config.regen_mana_id_item, player)
        elseif config.regen_mana_by_spell then
            say(config.regen_mana_spell)
        end
    else
        say(config.spell_train)
    end
end);
