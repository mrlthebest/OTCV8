setDefaultTab('Main');

local lbT = UI.Label('C O N F I G ');
lbT:setColor('orange');

local cfW = addTextEdit("ID Perto, ID Longe, Distance", storage.changeWeapon or "ID Perto, ID Longe, Distance", function(widget, text)
    storage.changeWeapon = text;
end);

local isShowing = false;
lbT.onDoubleClick = function(widget)
    isShowing = not isShowing;
    if isShowing then
        cfW:hide();
    else
        cfW:show();
    end
end



macro(100, "Change Weapon", function()
    local target, checkID = g_game.getAttackingCreature(), getLeft();
    local playerPos = pos();
    if not storage.changeWeapon or storage.changeWeapon:len() == 0 then return; end
    local config = storage.changeWeapon:split(',');
    local idPerto, idLonge, distance = tonumber(config[1]), tonumber(config[2]), tonumber(config[3]);
    if not g_game.isAttacking() then return; end
    if target then
        targetPos = target:getPosition();
        if not targetPos then return; end
        local distanceToTarget = getDistanceBetween(playerPos, targetPos);
        if distanceToTarget <= distance then
            if (not checkID or checkID:getId() ~= idPerto) then
                moveToSlot(idPerto, SlotLeft)
            end
        else
            if (not checkID or checkID:getId() ~= idLonge) then
                moveToSlot(idLonge, SlotLeft)
            end
        end
    end
end);
