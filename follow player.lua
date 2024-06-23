--[[
By: VictorNeox
discord: victorneox
]]--

FollowPlayer = {
    targetId = nil,
    obstaclesQueue = {},
    obstacleWalkTime = 0,
    currentTargetId = nil,
    keyToClearTarget = 'Escape',
    walkDirTable = {
        [0] = {'y', -1},
        [1] = {'x', 1},
        [2] = {'y', 1},
        [3] = {'x', -1},
    },
    flags = {
        ignoreNonPathable = true,
        precision = 0,
        ignoreCreatures = true
    },
    jumpSpell = {
        up = 'jump up',
        down = 'jump down'
    },
    defaultItem = 1111,
    defaultSpell = 'skip',
    customIds = {
        {
            id = 1948,
            castSpell = false
        },
        {
            id = 595,
            castSpell = false
        },
        {
            id = 1067,
            castSpell = false
        },
        {
            id = 1080,
            castSpell = false
        },
        {
            id = 386,
            castSpell = true
        },
    },
    lastCancelFollow = 0,
    followDelay = 300
};


FollowPlayer.distanceFromPlayer = function(position)
    local distx = math.abs(posx() - position.x);
    local disty = math.abs(posy() - position.y);

    return math.sqrt(distx * distx + disty * disty);
end

FollowPlayer.walkToPathDir = function(path)
    if (path) then
        g_game.walk(path[1], false);
    end
end

FollowPlayer.getDirection = function(playerPos, direction)
    local walkDir = FollowPlayer.walkDirTable[direction];
    if (walkDir) then
        playerPos[walkDir[1]] = playerPos[walkDir[1]] + walkDir[2];
    end
    return playerPos;
end


FollowPlayer.checkItemOnTile = function(tile, table)
    if (not tile) then return nil end;
    for _, item in ipairs(tile:getItems()) do
        local itemId = item:getId();
        for _, itemSelected in ipairs(table) do
            if (itemId == itemSelected.id) then
                return itemSelected;
            end
        end
    end
    return nil;
end

FollowPlayer.shiftFromQueue = function()
    g_game.cancelFollow();
    lastCancelFollow = now + FollowPlayer.followDelay;
    table.remove(FollowPlayer.obstaclesQueue, 1);
end

FollowPlayer.checkIfWentToCustomId = function(creature, newPos, oldPos, scheduleTime)
    local tile = g_map.getTile(oldPos);

    local customId = FollowPlayer.checkItemOnTile(tile, FollowPlayer.customIds);

    if (not customId) then return; end

    if (not scheduleTime) then
        scheduleTime = 0;
    end

    schedule(scheduleTime, function()
        if (oldPos.z == posz() or #FollowPlayer.obstaclesQueue > 0) then
            table.insert(FollowPlayer.obstaclesQueue, {
                oldPos = oldPos,
                newPos = newPos,
                tilePos = oldPos,
                customId = customId,
                tile = g_map.getTile(oldPos),
                isCustom = true
            });
            g_game.cancelFollow();
            lastCancelFollow = now + FollowPlayer.followDelay;
        end
    end);
end


FollowPlayer.checkIfWentToStair = function(creature, newPos, oldPos, scheduleTime)

    if (g_map.getMinimapColor(oldPos) ~= 210) then return; end
    local tile = g_map.getTile(oldPos);

    if (tile:isPathable()) then return; end

    if (not scheduleTime) then
        scheduleTime = 0;
    end

    schedule(scheduleTime, function()
        if (oldPos.z == posz() or #FollowPlayer.obstaclesQueue > 0) then
            table.insert(FollowPlayer.obstaclesQueue, {
                oldPos = oldPos,
                newPos = newPos,
                tilePos = oldPos,
                tile = tile,
                isStair = true
            });
            g_game.cancelFollow();
            lastCancelFollow = now + FollowPlayer.followDelay;
        end
    end);
end


FollowPlayer.checkIfWentToDoor = function(creature, newPos, oldPos)
    if (FollowPlayer.obstaclesQueue[1] and FollowPlayer.distanceFromPlayer(newPos) < FollowPlayer.distanceFromPlayer(oldPos)) then return; end
    if (math.abs(newPos.x - oldPos.x) == 2 or math.abs(newPos.y - oldPos.y) == 2) then
            

        local doorPos = {
            z = oldPos.z
        }

        local directionX = oldPos.x - newPos.x
        local directionY = oldPos.y - newPos.y

        if math.abs(directionX) > math.abs(directionY) then

            if directionX > 0 then
                doorPos.x = newPos.x + 1
                doorPos.y = newPos.y
            else
                doorPos.x = newPos.x - 1
                doorPos.y = newPos.y
            end
        else
            if directionY > 0 then
                doorPos.x = newPos.x
                doorPos.y = newPos.y + 1
            else
                doorPos.x = newPos.x
                doorPos.y = newPos.y - 1
            end
        end

        local doorTile = g_map.getTile(doorPos);

        if (not doorTile:isPathable() or doorTile:isWalkable()) then return; end

        table.insert(FollowPlayer.obstaclesQueue, {
            newPos = newPos,
            tilePos = doorPos,
            tile = doorTile,
            isDoor = true,
        });
        g_game.cancelFollow();
        lastCancelFollow = now + FollowPlayer.followDelay;
    end
end


FollowPlayer.checkifWentToJumpPos = function(creature, newPos, oldPos)
    local pos1 = { x = oldPos.x - 1, y = oldPos.y - 1 };
    local pos2 = { x = oldPos.x + 1, y = oldPos.y + 1 };

    local hasStair = nil
    for x = pos1.x, pos2.x do
        for y = pos1.y, pos2.y do
            local tilePos = { x = x, y = y, z = oldPos.z };
            if (g_map.getMinimapColor(tilePos) == 210) then
                hasStair = true;
                goto continue;
            end
        end
    end
    ::continue::

    if (hasStair) then return; end

    local spell = newPos.z > oldPos.z and FollowPlayer.jumpSpell.down or FollowPlayer.jumpSpell.up;
    local dir = creature:getDirection();

    if (newPos.z > oldPos.z) then
        spell = FollowPlayer.jumpSpell.down;
    end

    table.insert(FollowPlayer.obstaclesQueue, {
        oldPos = oldPos,
        oldTile = g_map.getTile(oldPos),
        spell = spell,
        dir = dir,
        isJump = true,
    });
    g_game.cancelFollow();
    lastCancelFollow = now + FollowPlayer.followDelay;
end


onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowPlayer.mainMacro.isOff()) then return; end

    if creature:getId() == FollowPlayer.currentTargetId and newPos and oldPos and oldPos.z == newPos.z then
        FollowPlayer.checkIfWentToDoor(creature, newPos, oldPos);
    end
end);


onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowPlayer.mainMacro.isOff()) then return; end

    if creature:getId() == FollowPlayer.currentTargetId and newPos and oldPos and oldPos.z == posz() and oldPos.z ~= newPos.z then
        FollowPlayer.checkifWentToJumpPos(creature, newPos, oldPos);
    end
end);


onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowPlayer.mainMacro.isOff()) then return; end

    if creature:getId() == FollowPlayer.currentTargetId and oldPos and g_map.getMinimapColor(oldPos) == 210 then
        local scheduleTime = oldPos.z == posz() and 0 or 250;

        FollowPlayer.checkIfWentToStair(creature, newPos, oldPos, scheduleTime);
    end
end);



onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowPlayer.mainMacro.isOff()) then return; end
    if creature:getId() == FollowPlayer.currentTargetId and oldPos and oldPos.z == posz() and (not newPos or oldPos.z ~= newPos.z) then
        FollowPlayer.checkIfWentToCustomId(creature, newPos, oldPos);
    end
end);


macro(1, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end

    if (FollowPlayer.obstaclesQueue[1] and ((not FollowPlayer.obstaclesQueue[1].isJump and FollowPlayer.obstaclesQueue[1].tilePos.z ~= posz()) or (FollowPlayer.obstaclesQueue[1].isJump and FollowPlayer.obstaclesQueue[1].oldPos.z ~= posz()))) then
        table.remove(FollowPlayer.obstaclesQueue, 1);
    end
end);



macro(100, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end
    if (FollowPlayer.obstaclesQueue[1] and FollowPlayer.obstaclesQueue[1].isStair) then
        local start = now
        local playerPos = pos();
        local walkingTile = FollowPlayer.obstaclesQueue[1].tile;
        local walkingTilePos = FollowPlayer.obstaclesQueue[1].tilePos;

        if (FollowPlayer.distanceFromPlayer(walkingTilePos) < 2) then
            if (FollowPlayer.obstacleWalkTime < now) then
                local nextFloor = g_map.getTile(walkingTilePos); -- workaround para caso o TILE descarregue, conseguir pegar os atributos ainda assim.
                if (nextFloor:isPathable()) then
                    FollowPlayer.obstacleWalkTime = now + 250;
                    use(nextFloor:getTopUseThing());
                else
                    FollowPlayer.obstacleWalkTime = now + 250;
                    FollowPlayer.walkToPathDir(findPath(playerPos, walkingTilePos, 1, { ignoreCreatures = false, precision = 0, ignoreNonPathable = true }));
                end
                FollowPlayer.shiftFromQueue();
                return 
            end
        end
        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        if (path == nil or #path <= 1) then
            if (path == nil) then
                use(walkingTile:getTopUseThing());
            end
            return
        end
        
        local tileToUse = playerPos;
        for i, value in ipairs(path) do
            if (i > 5) then break; end
            tileToUse = FollowPlayer.getDirection(tileToUse, value);
        end
        tileToUse = g_map.getTile(tileToUse);
        if (tileToUse) then
            use(tileToUse:getTopUseThing());
        end
    end
end);


macro(1, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end

    if (FollowPlayer.obstaclesQueue[1] and FollowPlayer.obstaclesQueue[1].isDoor) then
        local playerPos = pos();
        local walkingTile = FollowPlayer.obstaclesQueue[1].tile;
        local walkingTilePos = FollowPlayer.obstaclesQueue[1].tilePos;
        if (table.compare(playerPos, FollowPlayer.obstaclesQueue[1].newPos)) then
            FollowPlayer.obstacleWalkTime = 0;
            FollowPlayer.shiftFromQueue();
        end
        
        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        if (path == nil or #path <= 1) then
            if (path == nil) then

                if (FollowPlayer.obstacleWalkTime < now) then
                    g_game.use(walkingTile:getTopThing());
                    FollowPlayer.obstacleWalkTime = now + 500;
                end
            end
            return
        end
    end
end);


macro(100, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end
    
    if (FollowPlayer.obstaclesQueue[1] and FollowPlayer.obstaclesQueue[1].isJump) then
        local playerPos = pos();
        local walkingTilePos = FollowPlayer.obstaclesQueue[1].oldPos;
        local distance = FollowPlayer.distanceFromPlayer(walkingTilePos);
        if (playerPos.z ~= walkingTilePos.z) then
            FollowPlayer.shiftFromQueue();
            return;
        end

        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        
        if (distance == 0) then
            g_game.turn(FollowPlayer.obstaclesQueue[1].dir);
            schedule(50, function()
                if (FollowPlayer.obstaclesQueue[1]) then
                    say(FollowPlayer.obstaclesQueue[1].spell);
                end
            end)
            return;
        elseif (distance < 2) then
            local nextFloor = g_map.getTile(walkingTilePos); -- workaround para caso o TILE descarregue, conseguir pegar os atributos ainda assim.
            if (FollowPlayer.obstacleWalkTime < now) then
                FollowPlayer.walkToPathDir(findPath(playerPos, walkingTilePos, 1, { ignoreCreatures = false, precision = 0, ignoreNonPathable = true }));
                FollowPlayer.obstacleWalkTime = now + 500;
            end
            return 
        elseif (distance >= 2 and distance < 5 and path) then
            use(FollowPlayer.obstaclesQueue[1].oldTile:getTopUseThing());
        elseif (path) then
            local tileToUse = playerPos;
            for i, value in ipairs(path) do
                if (i > 5) then break; end
                tileToUse = FollowPlayer.getDirection(tileToUse, value);
            end
            tileToUse = g_map.getTile(tileToUse);
            if (tileToUse) then
                use(tileToUse:getTopUseThing());
            end
        end
    end
end);


macro(100, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end
    
    if (FollowPlayer.obstaclesQueue[1] and FollowPlayer.obstaclesQueue[1].isCustom) then
        local playerPos = pos();
        local walkingTile = FollowPlayer.obstaclesQueue[1].tile;
        local walkingTilePos = FollowPlayer.obstaclesQueue[1].tilePos;
        local distance = FollowPlayer.distanceFromPlayer(walkingTilePos);
        if (playerPos.z ~= walkingTilePos.z) then
            FollowPlayer.shiftFromQueue();
            return;
        end
        
        if (distance == 0) then
            if (FollowPlayer.obstaclesQueue[1].customId.castSpell) then
                say(FollowPlayer.defaultSpell);
                return;
            end
        elseif (distance < 2) then
            local item = findItem(FollowPlayer.defaultItem)
            if (FollowPlayer.obstaclesQueue[1].customId.castSpell or not item) then
                local nextFloor = g_map.getTile(walkingTilePos); -- workaround para caso o TILE descarregue, conseguir pegar os atributos ainda assim.
                if (FollowPlayer.obstacleWalkTime < now) then
                    FollowPlayer.walkToPathDir(findPath(playerPos, walkingTilePos, 1, { ignoreCreatures = false, precision = 0, ignoreNonPathable = true }));
                    FollowPlayer.obstacleWalkTime = now + 500;
                end
            elseif (item) then
                g_game.useWith(item, walkingTile);
                FollowPlayer.shiftFromQueue();
            end
            return 
        end

        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        if (path == nil or #path <= 1) then
            if (path == nil) then
                use(walkingTile:getTopUseThing());
            end
            return
        end
        
        local tileToUse = playerPos;
        for i, value in ipairs(path) do
            if (i > 5) then break; end
            tileToUse = FollowPlayer.getDirection(tileToUse, value);
        end
        tileToUse = g_map.getTile(tileToUse);
        if (tileToUse) then
            use(tileToUse:getTopUseThing());
        end
    end
end);


addTextEdit("FollowPlayer", storage.FollowPlayerName or "Nome do player", function(widget, text)
    storage.FollowPlayerName = text;
end);

FollowPlayer.mainMacro = macro(FollowPlayer.followDelay, 'Follow Player', function()
    --discord: victorneox
    local followingPlayer = g_game.getFollowingCreature();
    local playerToFollow = getCreatureByName(storage.FollowPlayerName);
    if (not playerToFollow) then return; end
    if (not findPath(pos(), playerToFollow:getPosition(), 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = true })) then
        if (followingPlayer and followingPlayer:getId() == playerToFollow:getId()) then
            lastCancelFollow = now + FollowPlayer.followDelay;
            return g_game.cancelFollow();
        end
    elseif (not followingPlayer and playerToFollow and playerToFollow:canShoot() and FollowPlayer.lastCancelFollow < now) then
        g_game.follow(playerToFollow);
    end
end);


macro(1, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end
    local playerToFollow = getCreatureByName(storage.FollowPlayerName);

    if (playerToFollow and FollowPlayer.currentTargetId ~= playerToFollow:getId()) then
        FollowPlayer.currentTargetId = playerToFollow:getId();
    end
end);

macro(1000, function()
    if (FollowPlayer.mainMacro.isOff()) then return; end
    local target = g_game.getFollowingCreature();


    if (target) then
        local targetPos = target:getPosition();

        if (not targetPos or targetPos.z ~= posz()) then
            g_game.cancelFollow();
        end
    end
end);