onCreatureHealthPercentChange(function(creature, hpPercent)
    if (not creature:isPlayer()) then return; end
    creature:setText(hpPercent .. '%')
end);
