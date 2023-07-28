local quantHp = 70 -- quantidade de hp pra alarmar
local quantMana = 70 -- quantidade de mana p alarmar
local alarmBox = {}

local ui = setupUI([[

Panel
  height: 50

  CheckBox
    id: checkBox
    font: cipsoftFont
    text: Player Detected
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: bottom
    text-offset: 17 0

  CheckBox
    id: checkBox1
    font: cipsoftFont
    text: Player PK
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: bottom
    text-offset: 17 0  

  CheckBox
    id: checkBox2
    font: cipsoftFont
    text: Low Life/HP
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: bottom
    text-offset: 17 0  


]])

ui.checkBox.onCheckChange = function(widget, checked)
    storage.playerDetected = checked
end

if storage.playerDetected == nil then storage.playerDetected = true end

ui.checkBox:setChecked(storage.playerDetected)

ui.checkBox1.onCheckChange = function(widget, checked)
    storage.playerPK = checked
end

if storage.playerPK == nil then storage.playerPK = true end

ui.checkBox1:setChecked(storage.playerPK)

ui.checkBox2.onCheckChange = function(widget, checked)
    storage.lowLife = checked
end

if storage.lowLife == nil then storage.lowLife = true end

ui.checkBox2:setChecked(storage.lowLife)


macro(100, "Alarm", function()
    for _, spec in ipairs(getSpectators()) do
        if not (spec ~= player and spec:isPlayer()) then
            return
        end
        if (getDistanceBetween(pos(), spec:getPosition()) < 8 and storage.playerDetected) or
            (spec:getSkull() > 2 and spec:getEmblem() < 3 and storage.playerPK) or
            (player:getHealthPercent() < quantHp or player:getManaPercent() < quantMana and storage.lowLife) then
            playAlarm()
            delay(3500)
            break
        end
    end
end)
