storage.mwPos = {};
local mwConfig = {
  itemId = 3180, 
  effectId = 2128
}
local keyMwall = 'X';

local function checkIfMwallId(idEffect)
        if idEffect == mwConfig.effectId then
            return true;
        end
    return false;
end

local function setTextInStoragePos(text)
    for _, pos in ipairs(storage.mwPos) do
        local tile = g_map.getTile(pos);
        if tile then
            tile:setText(text);
        end
    end
end

local function samePos(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z;
end

local function findMwPosIndex(tilePos)
    for index, pos in ipairs(storage.mwPos) do
        if samePos(tilePos, pos) then
            return index;
        end
    end
    return nil;
end

local holdScript = macro(100, "Hold MW", function()
  for _, tile in ipairs(g_map.getTiles(posz())) do
      if tile:getText() == 'Aqui' and tile:canShoot() then
        useWith(mwConfig.itemId, tile:getTopUseThing());
      end
  end
end);


onAddThing(function(tile, thing)
    if holdScript.isOff() then return; end
    if checkIfMwallId(thing:getId()) then
        local tilePos = tile:getPosition();
        if not findMwPosIndex(tilePos) then
            table.insert(storage.mwPos, tilePos)
            setTextInStoragePos('Aqui')
        end
    end
end);

onKeyPress(function(key)
  if key == keyMwall then
      local tile = getTileUnderCursor();
      if tile then
          local tilePos = tile:getPosition();
          local mwIndex = nil;
          for index, pos in ipairs(storage.mwPos) do
              if samePos(tilePos, pos) then
                  mwIndex = index;
                  break
              end
          end
          if tile:getText() == 'Aqui' and mwIndex then
              table.remove(storage.mwPos, mwIndex);
              tile:setText("");
          elseif not mwIndex then
              table.insert(storage.mwPos, tilePos);
              setTextInStoragePos('Aqui');
          end
      end
  end
end);


onRemoveThing(function(tile, thing)
    if holdScript.isOff() then return; end
    if checkIfMwallId(thing:getId()) and findMwPosIndex(tile:getPosition()) then
      useWith(mwConfig.itemId, tile:getTopUseThing());
    end
end);

