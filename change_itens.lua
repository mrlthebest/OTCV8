--[[Variaveis: 

SlotHead, getHead => Slot Helmet
SlotBody, getBody => Slot Armor
SlotLeg, getLeg => Slot Legs
SlotFeet, getFeet => Slot Boots
SlotLeft, getLeft => Left Hand
SlotRight, getRight => Right Hand 
SlotNeck, getNeck => Amulet Slot
SlotAmmo, getAmmo => Arrow Slot
SlotFinger, getFinger => Ring Slot

]]--

local equipC = {
    distanceChange = 1, -- distancia entre o target para mudar 
    -- id do slot, variavel do slot, id1(atual), id2(mudar)
    {varFunc = getLeft, slot = SlotLeft, id1 = 14828, id2 = 14827},
    {varFunc = getAmmo, slot = SlotAmmo, id1 = 11833, id2 = 14805}
};

macro(100, "Change", function()
    local target = g_game.getAttackingCreature();
    local playerPos = pos();
    if not g_game.isAttacking() then return; end
    local targetPos = target:getPosition();
    local targetDistance = getDistanceBetween(playerPos, targetPos);
    for _, equip in ipairs(equipC) do
        local currentItem = equip.varFunc();
        if targetDistance <= equipC.distanceChange then
            if not currentItem or currentItem:getId() ~= equip.id1 then
                moveToSlot(equip.id1, equip.slot)
            end
        else
            if not currentItem or currentItem:getId() ~= equip.id2 then
                moveToSlot(equip.id2, equip.slot)
            end
        end
    end
end);
