local checkBox = {}

UI.Label('Buff: buff spell, buff orange message, cd');

if not storage.buffCDW then
    storage.buffCDW = 0;
end

addTextEdit("Buff ", storage.buffConfig or "Buff", function(widget, text)
    storage.buffConfig = text:trim():lower()
    buffSetup = storage.buffConfig:split(',');
end)

macro(100, "Buff", function()
    local buffSetup = storage.buffConfig:split(',');
    if isInPz() then return; end
    if storage.buffCDW<= os.time() and (not storage.castPZ) or (storage.castPZ and not isInPz()) then
        say(buffSetup[1])
    end
end)

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    local buffSetup = storage.buffConfig:split(',');
    local textBuff = buffSetup[2] and buffSetup[2]:trim() or buffSetup[1]:trim()
    if text:lower():trim() == textBuff then
        storage.buffCDW = os.time() + tonumber(buffSetup[3])
    end
end)

checkBox.checkPZ = setupUI([[
CheckBox
  id: checkBox
  font: cipsoftFont
  text: Not Use PZ
]])

checkBox.checkPZ.onCheckChange = function(widget, checked)
  storage.castPZ = checked
end

if storage.castPZ == nil then storage.castPZ = true end

checkBox.checkPZ:setChecked(storage.castPZ)
