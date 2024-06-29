onCreatureHealthPercentChange(function(creature, hpPercent)
    if (not creature:isMonster()) then return; end
    creature:setText(hpPercent .. '%')
end);
