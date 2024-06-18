local animatedText = 'buff';
local buffSpell = 'Doton Boei'
local cooldownBuff = 30;

macro(100, "ASD", function()
    if (not cooldownExists or cooldownExists <= os.time()) then
        say(buffSpell)
    end
end);

local function samePos(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z;
end

onAnimatedText(function(thing, text)
    text = text:lower();
    local playerPos = pos();
    local thingPos = thing:getPosition();
    if not samePos(playerPos, thingPos) then return; end
    if (text:find(animatedText:lower())) then
        cooldownExists = os.time() + cooldownBuff;
    end
end);
