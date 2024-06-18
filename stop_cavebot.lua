local stopTarget = true; -- se estiver true vai parar, se não, não.
local stopCaveBot = false;-- se estiver true vai parar, se não, não.
local sameZ = false; -- se estiver false vai contar players de z diferente, se não, não.

macro(100, "Stop", function()
    local playerPos = player:getPosition();
    for _, spec in ipairs(getSpectators()) do
        if ((spec ~= player) and spec:isPlayer()) then
            local specPos = spec:getPosition();
            if (((playerPos.z == specPos.z) and sameZ) or (not sameZ)) then
                if stopTarget then
                    TargetBot.setOff();
                end
                if stopCaveBot then
                    CaveBot.setOff();
                end
                return;
            end
        end
    end
    TargetBot.setOn();
    CaveBot.setOn();
end);
