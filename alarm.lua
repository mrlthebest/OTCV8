--[[
    Script de Alarm
    by mrlthebest.
    28/07/2023
]]--

local alarmBox = {}

ui = setupUI([[

Panel
  height: 80

  CheckBox
    id: playerD
    font: cipsoftFont
    text: Player Detected
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: bottom
    text-offset: 17 0

  CheckBox
    id: playerP
    font: cipsoftFont
    text: Player PK
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: bottom
    text-offset: 17 0  

  CheckBox
    id: playerH
    font: cipsoftFont
    text: Low Life/HP
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: bottom
    text-offset: 17 0  

  CheckBox
    id: playerSP
    font: cipsoftFont
    text: Self PK
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: bottom
    text-offset: 17 0  
]])

---------------------------------------------------------------
ui.playerD.onCheckChange = function(widget, checked)
    storage.playerDetected = checked
end

if storage.playerDetected == nil then storage.playerDetected = true end

ui.playerD:setChecked(storage.playerDetected)
---------------------------------------------------------------
ui.playerP.onCheckChange = function(widget, checked)
    storage.playerPK = checked
end

if storage.playerPK == nil then storage.playerPK = true end

ui.playerP:setChecked(storage.playerPK)
---------------------------------------------------------------
ui.playerH.onCheckChange = function(widget, checked)
    storage.lowLife = checked
end

if storage.lowLife == nil then storage.lowLife = true end

ui.playerH:setChecked(storage.lowLife)
---------------------------------------------------------------
ui.playerSP.onCheckChange = function(widget, checked)
    storage.selfPK = checked
end

if storage.selfPK == nil then storage.selfPK = true end

ui.playerSP:setChecked(storage.selfPK)
---------------------------------------------------------------

macro(100, "Alarm", function()
    local s = storage.alarmX:split(",");
    for _, spec in ipairs(getSpectators()) do
        if spec == player then return; end
        if spec:isPlayer() then
            if ((getDistanceBetween(pos(), spec:getPosition()) < 8 and storage.playerDetected) or
                (spec:getSkull() > 2 and spec:getEmblem() < 3 and storage.playerPK) or
                (player:getSkull() > 2 and storage.selfPK) or
                ((hppercent() < tonumber(s[1]) or manapercent() < tonumber(s[2])) and storage.lowLife)) then
                playSound("/sounds/alarm.ogg")
                delay(3500)
                break
            end
        end
    end
end)


addTextEdit("HP, MP", storage.alarmX or "HP, MP", function(widget, text)
    if text and #text:split(",") < 2 then
        return warn("por favor, inserir os valores na ordem (HP, MP)")
    end
    storage.alarmX = text;
end)
