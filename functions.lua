--[[ FUNCTION QUE RETORNA O NOME DO TARGET ]]--
function targetName()
    local target = g_game.getAttackingCreature()
    if target and target:isPlayer() then
        return target:getName()
    end
end

--[[ FUNCTION QUE RETORNA A DISTANCIA DO TARGET ]]--
function distTarget()
    local target = g_game.getAttackingCreature()
    if target and target:isPlayer() then
        targetPos = target:getPosition()
        if targetPos then
            return getDistanceBetween(posPos, targetPos)
        end
    end
end

--[[ FUNCTION QUE RETORNA OS PLAYERS DE GUILD NA TELA ]]--
function playersGuild(range, multifloor)
    if not range then range = 10 end
    local specs = 0;
    for _, spec in ipairs(getSpectators(multifloor)) do
        if spec ~= player and spec:isPlayer() and (spec:getShield() > 3 or spec:getEmblem() == 1) and distanceFromPlayer(spec:getPosition()) <= range then
            specs = specs + 1;
        end
    end
    return specs;
end

--[[ FUNCTION QUE RETORNA OS PLAYERS NA TELA ]]--
function getPlayers(range, multifloor)
    if not range then range = 10 end
    local specs = 0;
    for _, spec in ipairs(getSpectators(multifloor)) do
        if not spec:isLocalPlayer() and spec:isPlayer() and distanceFromPlayer(spec:getPosition()) <= range and not ((spec:getShield() ~= 1 and spec:isPartyMember()) or spec:getEmblem() == 1) then
            specs = specs + 1
        end
    end
    return specs;
end

--[[ FUNCTION QUE RETORNA A QUANTIDADE DE PLAYERS ENEMY NA TELA ]]--
function playersEnemies(range, multfloor)
    if not range then range = 10 end
    local specs = 0;
    for _, spec in ipairs(getSpectators(multifloor)) do
        if spec ~= player and spec:isPlayer() and (spec:getEmblem() == 2 or spec:getEmblem() == 3) and distanceFromPlayer(spec:getPosition()) <= range then
            specs = specs + 1;
        end
    end
    return specs;
end

-- findCreature(10, true, "player")
-- findCreature(10, false, "player):getName() =="uzumar" then
function findCreature(range, multifloor, type)
    range = range or 10
    type = type and type:lower() or "player"
    for _, spec in ipairs(getSpectators(multifloor)) do
        if (
            (type == 'player' and spec:isPlayer() and spec ~= player) or
            (type == 'npc' and spec:isNpc()) or
            (type == 'monster' and spec:isMonster())
            ) then
            if distanceFromPlayer(spec:getPosition()) <= distance then
                return spec
            end
        end
    end
end


--nearestCreature(10, true, "player") <= 3
function nearestCreature(range, multifloor, type)
    range = range or 10
    local pos, nearest = pos(), {}
    for _, spec in ipairs(getSpectators(multifloor)) do
        local specPos = spec:getPosition()
        if specPos then
            local specDistance = math.abs(pos.x - specPos.x) + math.abs(pos.y - specPos.y)
            if (
                (type == 'player' and spec:isPlayer() and spec ~= player) or
                (type == 'npc' and spec:isNpc()) or
                (type == 'monster' and spec:isMonster())
                ) then
                if not nearest.creature or nearest.distance > specDistance then
                    nearest = {
                        creature = spec,
                        distance = specDistance
                    }
                end
            end
        end
    end
    return nearest.creature
end

--[[ FUNCTION QUE RETORNA A QUANTIDADE DE PLAYERS QUE ESTÃO TE ATACANDO ]]--
local colorToMatch = {r = 0, g = 0, b = 0, a = 255}
function playersAttack(range, multifloor)
    if not range then range = 10 end
    local playersCount = 0;
    for _, spec in ipairs(getSpectators(multifloor)) do
        if (spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) and distanceFromPlayer(spec:getPosition()) <= range) then
            playersCount = playersCount + 1
        end
    end
    return playersCount;
end


--[[ FUNCTION QUE RETORNA A QUANTIDADE DE MONSTROS QUE ESTÃO TE ATACANDO ]]--
local colorToMatch = {r = 0, g = 0, b = 0, a = 255}
function monstersAttack(range, multifloor)
    if not range then range = 10 end
    local monstersCount = 0;
    for _, monster in ipairs(getSpectators(multifloor)) do
        if (monster:isMonster() and monster:isTimedSquareVisible() and table.equals(monster:getTimedSquareColor(), colorToMatch2) and distanceFromPlayer(monster:getPosition()) <= range) then
            monstersCount = monstersCount + 1;
        end
    end
    return monstersCount;
end

--[[ FUNCTION QUE RETORNA A DISTANCIA DE QUEM ESTÁ TE ATACANDO ]]--
local colorToMatch = {r = 0, g = 0, b = 0, a = 255}
function distanceAttacker()
    for _, spec in ipairs(getSpectators()) do
        if spec ~= player and spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) then
            return getDistanceBetween(pos(), spec:getPosition())
        end
    end
end

--[[ FUNCTION QUE RETORNA O NOME DE QUEM ESTÁ TE ATACANDO ]]--
local colorToMatch = {r = 0, g = 0, b = 0, a = 255}
function attackerName()
    for _, spec in ipairs(getSpectators()) do
        if spec ~= player and spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) then
            return spec:getName()
        end
    end
end

