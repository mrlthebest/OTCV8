local spellKai = 'mystic kai';
local spellDefense = 'mystic defense';
mysticMacro = function()
    local selfHealth, selfMana = hppercent(), manapercent();
    local mystic = hasManaShield();
    if selfHealth <= 75 and selfMana >= 90 and not mystic then
        if tyrBot and tyrBot.storage.regenDelay then
            tyrBot.storage.regenDelay = os.time() + 1;
        end
        say(spellDefense)
    elseif selfHealth >= 80 and selfMana <= 30 and mystic then
        say(spellKai)
    end
end

mysticFull = function()
  say(spellDefense)
  delay(1000)
end

macro(100, "Mystic Defense", mysticMacro);
macro(100, "Mystic Defense Full", mysticFull);
