
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
    local configAlarm = storage.alarmX:split(",")
    local playerPos = player:getPosition();
    local selfHealth, selfMana = hppercent(), manapercent();
    local selfSkull = player:getSkull();
    for _, spec in ipairs(getSpectators()) do
        if spec:isPlayer() then
            local specPos = spec:getPosition();
            local specSkull = spec:getSkull();
            local distanceToSpec = getDistanceBetween(playerPos, specPos);
            if (
                (spec ~= player and distanceToSpec < 8 and storage.playerDetected) or
                (spec ~= player and specSkull > 2 and storage.playerPK) or
                (selfSkull > 2 and storage.selfPK) or
                ((selfHealth <= tonumber(configAlarm[1]) or selfMana <= tonumber(configAlarm[2])) and storage.lowLife)
            ) then
                if not x or x <= os.time() then
                    playSound("/sounds/alarm.ogg")
                    x = os.time() + 4;
                end
            end
        end
    end
end);

addTextEdit("HP, MP", storage.alarmX or "HP, MP", function(widget, text)
    storage.alarmX = text;
end);
