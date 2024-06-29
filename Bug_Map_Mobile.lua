local bugMapMobile = {};

local cursorWidget = g_ui.getRootWidget():recursiveGetChildById('pointer');

local initialPos = { x = cursorWidget:getPosition().x / cursorWidget:getWidth(), y = cursorWidget:getPosition().y / cursorWidget:getHeight() };

local availableKeys = {
    ['Up'] = { 0, -6 },
    ['Down'] = { 0, 6 },
    ['Left'] = { -7, 0 },
    ['Right'] = { 7, 0 }
};

function bugMapMobile.logic()
    local pos = pos();
    local keypadPos = { x = cursorWidget:getPosition().x / cursorWidget:getWidth(), y = cursorWidget:getPosition().y / cursorWidget:getHeight() };
    local diffPos = { x = initialPos.x - keypadPos.x, y = initialPos.y - keypadPos.y };

    if (diffPos.y < 0.46 and diffPos.y > -0.46) then
        if (diffPos.x > 0) then
            pos.x = pos.x + availableKeys['Left'][1];
        elseif (diffPos.x < 0) then
            pos.x = pos.x + availableKeys['Right'][1];
        else return end
    elseif (diffPos.x < 0.46 and diffPos.x > -0.46) then
        if (diffPos.y > 0) then
            pos.y = pos.y + availableKeys['Up'][2];
        elseif (diffPos.y < 0) then
            pos.y = pos.y + availableKeys['Down'][2];
        else return; end
    end
    local tile = g_map.getTile(pos);
    if (not tile) then return; end

    g_game.use(tile:getTopUseThing());
end

bugMapMobile.macro = macro(1, "Bug Map", bugMapMobile.logic);