----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local timeToCancelAttack = 1; -- tempo que irá parar de atacar apos o target parar de atacar



local toAttack = nil; 
local lastAttackTime = os.time();
Turn = {};
Turn.maxDistance = {x = 7, y = 7};

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onMissle(function(missle)
    if not storage.attackLeader or storage.attackLeader:len() == 0 then return; end
    local src = missle:getSource()
    if src.z ~= posz() then return; end
    local from = g_map.getTile(src);
    local to = g_map.getTile(missle:getDestination())
    if not (from or to) then return; end
    local fromCreatures = from:getCreatures();
    local toCreatures = to:getCreatures();
    if #fromCreatures ~= 1 or #toCreatures ~= 1 then return; end
    local c1 = fromCreatures[1]
    if c1:getName():lower() == storage.attackLeader:lower() then
        toAttack = toCreatures[1]
        lastAttackTime = os.time();
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if not storage.filterSpell or storage.filterSpell:len() == 0 then return; end
    if name == storage.attackLeader then
        if text == storage.filterSpell then
            if isFacingTarget(player, toAttack) then
                say(storage.selfSpell)
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function isFacingTarget(player, target)
    local pos = player:getPosition();
    local targetPos = target:getPosition();
    local playerDir = player:getDirection();
    local targetDistance = {x = math.abs(pos.x - targetPos.x), y = math.abs(pos.y - targetPos.y)}
    if targetDistance.x <= Turn.maxDistance.x and targetDistance.y <= Turn.maxDistance.y then
        if targetDistance.y >= targetDistance.x then
            if targetPos.y > pos.y then
                return playerDir == 2
            else
                return playerDir == 0
            end
        else
            if targetPos.x > pos.x then
                return playerDir == 1
            else
                return playerDir == 3 
            end
        end
    end
    return false;
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function turnToTarget(player, target)
    local pos = player:getPosition();
    local targetPos = target:getPosition();
    local playerDir = player:getDirection();
    local targetDistance = {x = math.abs(pos.x - targetPos.x), y = math.abs(pos.y - targetPos.y)};
    if targetDistance.x <= Turn.maxDistance.x and targetDistance.y <= Turn.maxDistance.y then
        if targetDistance.y >= targetDistance.x then
            if targetPos.y > pos.y and playerDir ~= 2 then
                turn(2)
                return true;
            elseif targetPos.y <= pos.y and playerDir ~= 0 then
                turn(0) 
                return true;
            end
        else
            if targetPos.x > pos.x and playerDir ~= 1 then
                turn(1)
                return true;
            elseif targetPos.x <= pos.x and playerDir ~= 3 then
                turn(3) 
                return true;
            end
        end
    end
    return false;
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

macro(50, "Attack Leader + Combo UE", function()
    if os.time() - lastAttackTime > timeToCancelAttack then 
        g_game.cancelAttackAndFollow()
        toAttack = nil;
    end
    if toAttack and storage.attackLeader:len() > 0 then
        if not isFacingTarget(player, toAttack) then
            turnToTarget(player, toAttack)
        end
        if toAttack ~= g_game.getAttackingCreature() then
            g_game.attack(toAttack)
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

UI.Label('Leader Name');

addTextEdit("Leader Name", storage.attackLeader or "Leader Name", function(widget, text)
    storage.attackLeader = text;
end);

UI.Label('Filter Spell');

addTextEdit("Filter Spell", storage.filterSpell or "Filter Spell", function(widget, text)
    storage.filterSpell = text;
end);

UI.Label('Your Spell');

addTextEdit("Self Spell", storage.selfSpell or "Self Spell", function(widget, text)
    storage.selfSpell = text;
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------