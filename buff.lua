local checkBox = {};

if not storage.buffCDW then
    storage.buffCDW = 0;
end

local textBuff = addTextEdit("Buff ", storage.buffConfig or "Buff", function(widget, text)
    storage.buffConfig = text:trim():lower()
    buffSetup = storage.buffConfig:split(',');
end);
textBuff:setTooltip('Buff Spell, Buff Orange Message, Cooldown(Segundos)');

macro(100, "Buff", function()
    local buffSetup = storage.buffConfig:split(',');
    if isInPz() then return; end
    if storage.buffCDW <= os.time() and (not storage.castPZ) or (storage.castPZ and not isInPz()) then
        say(buffSetup[1])
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    local buffSetup = storage.buffConfig:split(',');
    local textBuff = buffSetup[2] and buffSetup[2]:trim() or buffSetup[1]:trim();
    if text:lower():trim() == textBuff then
        storage.buffCDW = os.time() + tonumber(buffSetup[3]);
    end
end);

checkBox.checkPZ = setupUI([[
CheckBox
  id: checkBox
  font: cipsoftFont
  text: Not Use PZ
]]);

checkBox.checkPZ.onCheckChange = function(widget, checked)
  storage.castPZ = checked;
end

checkBox.checkPZ:setChecked(storage.castPZ or false);
