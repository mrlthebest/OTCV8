--[[
Credits:
mrlthebest
vivodibra
]]--

local mwallId = 110;-- id da mw pra soltar

hotkey('R', "MW Cursor", function()
    local tile = getTileUnderCursor();
    if (modules.game_console:isChatEnabled() or modules.corelib.g_keyboard.isCtrlPressed()) then return; end
    if not tile then return end
    g_game.stop();
    player:stopAutoWalk();
    useWith(mwallId, tile:getTopUseThing())
end);

local activeTimers = {};

onAddThing(function(tile, thing)
    if not thing:isItem() then
        return
    end
    local timer = 0
    if thing:getId() == 2129 or thing:getId() == 2128 then -- mwall id
        timer = 20000 -- mwall time
    elseif thing:getId() == 2130 then -- wg id
        timer = 45000 -- wg time
    else
        return
    end
    local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
    if not activeTimers[pos] or activeTimers[pos] < now then
        activeTimers[pos] = now + timer
    end
    tile:setTimer(activeTimers[pos] - now)
end)

onRemoveThing(function(tile, thing)
    if not thing:isItem() then
        return
    end
    if (thing:getId() == 2129 or thing:getId() == 2130) and tile:getGround() then
        local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
        activeTimers[pos] = nil
        tile:setTimer(0)
    end
end)
