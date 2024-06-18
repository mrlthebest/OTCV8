local speedLyze = true; -- se estiver true vai dar speed qndo estiver na lyze, false não vai
local speedSpell = 'concentrate chakra feet';


macro(100, "Speed", function()
    if (not hasHaste() or (isParalyzed() and speedLyze)) then
        say(speedSpell)
    end
end);
