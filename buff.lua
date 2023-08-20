UI.Label('Buff: buff spell, buff orange message, cd');
local buffConfig = {}

addTextEdit("Buff ", storage.buffConfig or "Buff", function(widget, text)
    storage.buffConfig = text:trim():lower()
    buffSetup = storage.buffConfig:split(',');
end)

macro(100, "Buff", function()
    local buffSetup = storage.buffConfig:split(',');
    if isInPz() then return; end
    if (not buffConfig.cdW or buffConfig.cdW <= os.time()) then
        say(buffSetup[1])
    end
end)

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    local buffSetup = storage.buffConfig:split(',');
    local textBuff = buffSetup[2] and buffSetup[2]:trim() or buffSetup[1]:trim()
    if text:lower():trim() == textBuff then
        buffConfig.cdW = os.time() + tonumber(buffSetup[3])
    end
end)
