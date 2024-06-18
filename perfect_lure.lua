local configLure = {
    singleSpells = 'asd',
    areaSpells = 'fd',
    quantityLure = 6,
};

-- function to say multiple spells
sayMultipleSpells = function(spells)
    for _, sp in ipairs(spells:split(',')) do
        say(sp)     
    end
end

-- function to get distance from player
function getDistanceFromPlayer(pos)
    local playerPos = player:getPosition();
    if not playerPos or not pos then return nil; end
    return math.max(math.abs(playerPos.x - pos.x), math.abs(playerPos.y - pos.y), math.abs(playerPos.z - pos.z));
end

--function to check monsters in range
function getMonstersInRange(area, floor)
    if not floor then floor = false; end
    if not area then area = 8; end
    local count = 0
    for _, spec in ipairs(getSpectators(floor)) do
        if spec:isMonster() and getDistanceFromPlayer(spec:getPosition()) <= area then
            count = count + 1;
        end
    end
    return count;
end

-- function to check player on screen
getPlayersInScreen = function()
    local playerPos = player:getPosition();
    for _, spec in ipairs(getSpectators(true)) do
        local specPos = spec:getPosition();
        if math.abs(specPos.z - playerPos.z) >= 3 then return false; end
        if spec ~= player and spec:isPlayer() then
            return true;
        end
    end
    return false;
end

--main macro
macro(100, "Lure", function()
    --made by mrlthebest.
    if not g_game.isAttacking() then return; end
    if (getPlayersInScreen()) then return; end
    if getMonstersInRange(6, false) >= configLure.quantityLure and player:getSkull() < 3 then
        CaveBot.setOff();
        sayMultipleSpells(configLure.areaSpells)
    elseif getMonstersInRange(1, false) <= 1 then
        CaveBot.setOn();
        sayMultipleSpells(configLure.singleSpells)
    end
end);