----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
scriptFuncs = {};
comboSpellsWidget = {};
fugaSpellsWidgets = {};

scriptFuncs.readProfile = function(filePath, callback)
    if g_resources.fileExists(filePath) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(filePath))
        end)
        if not status then
            return warn("Error: ".. result)
        end

        callback(result);
    end
end

scriptFuncs.saveProfile = function(configFile, content)
    local status, result = pcall(function()
        return json.encode(content, 2)
    end);

    if not status then
        return warn("Error:" .. result);
    end
    g_resources.writeFileContents(configFile, result);
end

storageProfiles = {
    comboSpells = {},
    fugaSpells = {},
    keySpells = {}
}

MAIN_DIRECTORY = "/bot/" .. modules.game_bot.contentsPanel.config:getCurrentOption().text .. "/storage/"
STORAGE_DIRECTORY = "" .. MAIN_DIRECTORY .. g_game.getWorldName() .. '.json';

if not g_resources.directoryExists(MAIN_DIRECTORY) then
    g_resources.makeDir(MAIN_DIRECTORY);
end

function resetCooldowns()
    if storageProfiles then
        if storageProfiles.comboSpells then
            for _, spell in ipairs(storageProfiles.comboSpells) do
                spell.cooldownSpells = nil
            end
        end
    end
end

scriptFuncs.readProfile(STORAGE_DIRECTORY, function(result)
    storageProfiles = result;
    if (type(storageProfiles.comboSpells) ~= 'table') then
        storageProfiles.comboSpells = {};
    end
    if (type(storageProfiles.fugaSpells) ~= 'table') then
        storageProfiles.fugaSpells = {};
    end
    if (type(storageProfiles.keySpells) ~= 'table') then
        storageProfiles.keySpells = {};
    end
    resetCooldowns();
end);

scriptFuncs.reindexTable = function(t)
    if not t or type(t) ~= "table" then
        return
    end

    local i = 0
    for _, e in pairs(t) do
        i = i + 1
        e.index = i
    end
end

firstLetterUpper = function(str)
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

storage['iconScripts'] = storage['iconScripts'] or {
    comboMacro = false,
    fugaMacro = false,
    showInfos = false,
    keyMacro = false
}

local isOn = storage['iconScripts'];

function removeTable(tbl, index)
    table.remove(tbl, index)
end

function canCastFuga()
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if ((value.enableLifes and value.lifes > 0 and value.activeCooldown and value.activeCooldown >= os.time()) or
            (not value.enableLifes and value.activeCooldown and value.activeCooldown >= os.time())) then
            return true;
        end
    end
    return false;
end

function getPlayersAttack(multifloor)
    multifloor = multifloor or false;
    local count = 0;
    for _, spec in ipairs(getSpectators(multifloor)) do
        if spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) then
            count = count + 1;
        end
    end
    return count;
end

function calculatePercentage(var)
    local multiplier = getPlayersAttack(false);
    return multiplier and var + (multiplier * 7) or var
end

function stopToCast()
    if not fugaIcon.title:isOn() then
        return false;
    end
    for index, value in ipairs(storageProfiles.fugaSpells) do
        if value.enabled and value.activeCooldown and value.activeCooldown >= os.time() then
            return false;
        end
        if hppercent() <= calculatePercentage(value.selfHealth) + 3 then
            if (not value.totalCooldown or value.totalCooldown <= os.time()) then
                return true;
            end
        end
    end
    return false;
end

function isAnySelectedKeyPressed()
    for index, value in ipairs(storageProfiles.keySpells) do
        if value.enabled and (modules.corelib.g_keyboard.isKeyPressed(value.keyPress)) then
            return true;
        end
    end
    return false;
end

function formatTime(seconds)
    if seconds < 60 then
        return seconds .. 's'
    else
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        return string.format("%dm %02ds", minutes, remainingSeconds)
    end
end

formatRemainingTime = function(time)
    local remainingTime = (time - now) / 1000;
    local timeText = '';
    timeText = string.format("%.0f", (time - now) / 1000) .. "s";
    return timeText;
end

formatOsTime = function(time)
    local remainingTime = (time - os.time());
    local timeText = '';
    timeText = string.format("%.0f", (time - os.time())) .. "s";
    return timeText;
end

attachSpellWidgetCallbacks = function(widget, spellId, table)
    widget.onDragEnter = function(self, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        self:breakAnchors()
        self.movingReference = {
            x = mousePos.x - self:getX(),
            y = mousePos.y - self:getY()
        }
        return true
    end

    widget.onDragMove = function(self, mousePos, moved)
        local parentRect = self:getParent():getRect()
        local newX = math.min(math.max(parentRect.x, mousePos.x - self.movingReference.x),
            parentRect.x + parentRect.width - self:getWidth())
        local newY = math.min(math.max(parentRect.y - self:getParent():getMarginTop(),
            mousePos.y - self.movingReference.y), parentRect.y + parentRect.height - self:getHeight())
        self:move(newX, newY)
        if table[spellId] then
            table[spellId].widgetPos = {
                x = newX,
                y = newY
            }
            scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
        end
        return true
    end

    widget.onDragLeave = function(self, pos)
        return true
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local spellEntry = [[
UIWidget
  background-color: alpha
  text-offset: 18 0
  focusable: true
  height: 16

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 3

  $focus:
    background-color: #00000055

  CheckBox
    id: showTimespell
    anchors.left: enabled.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 15

  $focus:
    background-color: #00000055

  Label
    id: textToSet
    anchors.left: showTimespell.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 20

  Button
    id: remove
    !text: tr('x')
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15
    tooltip: Remove Spell
]]

local widgetConfig = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true
]]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboIcon = setupUI([[
Panel
  height: 20
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Combo

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])

comboInterface = setupUI([[
MainWindow
  text: Combo Panel
  size: 540 312

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.right: sep2.left
    anchors.left: parent.left
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 310 225

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.left: sep2.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 310 225


  TextList
    id: spellList
    anchors.left: parent.left
    anchors.top: parent.top
    padding: 1
    size: 247 205
    margin-top: 11
    margin-left: 11
    vertical-scrollbar: spellListScrollBar

  VerticalScrollBar
    id: spellListScrollBar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  Button
    id: moveUp
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    margin-bottom: 40
    margin-left: 60
    text: Move Up
    size: 60 17
    font: cipsoftFont

  Button
    id: moveDown
    anchors.bottom: parent.bottom
    anchors.left: moveUp.left
    margin-bottom: 40
    margin-left: 65
    text: Move Down
    size: 60 17
    font: cipsoftFont

  VerticalSeparator
    id: sep2
    anchors.top: parent.top
    anchors.bottom: closeButton.top
    anchors.horizontalCenter: parent.horizontalCenter
    margin-left: 15
    margin-bottom: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5

  Label
    id: castSpellLabel
    anchors.left: castSpell.right
    anchors.top: parent.top
    text: Cast Spell
    margin-top: 19
    margin-left: 15

  TextEdit
    id: castSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-top: 15
    margin-left: 34
    width: 100

  Label
    id: orangeSpellLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: Orange Spell
    margin-top: 49
    margin-left: 15

  TextEdit
    id: orangeSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-top: 45
    margin-left: 34
    width: 100

  CheckBox
    id: sameSpell
    anchors.left: orangeSpellLabel.right
    anchors.top: parent.top
    margin-top: 49
    margin-left: 8
    tooltip: Same Spell

  Label
    id: onScreenLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: On Screen
    margin-top: 79
    margin-left: 15

  TextEdit
    id: onScreen
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-left: 34
    margin-top: 75
    width: 100

  Label
    id: cooldownLabel
    anchors.left: cooldown.right
    anchors.top: parent.top
    margin-top: 105
    margin-left: 5
    text: Cooldown

  HorizontalScrollBar
    id: cooldown
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 105
    width: 125
    minimum: 0
    maximum: 60000
    step: 50

  Button
    id: findCD
    anchors.left: cooldownLabel.right
    anchors.top: parent.top
    margin-top: 105
    margin-left: 8
    tooltip: Find CD
    text: !
    size: 15 15

  Label
    id: distanceLabel
    anchors.left: cooldown.right
    anchors.top: parent.top
    margin-top: 135
    margin-left: 5
    text: Distance

  HorizontalScrollBar
    id: distance
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 135
    width: 125
    minimum: 0
    maximum: 10
    step: 1

  Button
    id: insertSpell
    text: Insert Spell
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 21
    margin-bottom: 40
    margin-right: 20


  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5

]], g_ui.getRootWidget())
comboInterface:hide();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaIcon = setupUI([[
Panel
  height: 40
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Fuga

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  CheckBox
    id: showInfos
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text: Show Information
]])

fugaInterface = setupUI([[
MainWindow
  text: Fuga Panel
  size: 550 322

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.right: sep2.left
    anchors.left: parent.left
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 320 235

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.left: sep2.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 320 235


  TextList
    id: spellList
    anchors.left: parent.left
    anchors.top: parent.top
    padding: 1
    size: 240 215
    margin-top: 11
    margin-left: 11
    vertical-scrollbar: spellListScrollBar

  VerticalScrollBar
    id: spellListScrollBar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  Button
    id: moveUp
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    margin-bottom: 40
    margin-left: 50
    text: Move Up
    size: 60 17
    font: cipsoftFont

  Button
    id: moveDown
    anchors.bottom: parent.bottom
    anchors.left: moveUp.left
    margin-bottom: 40
    margin-left: 65
    text: Move Down
    size: 60 17
    font: cipsoftFont

  VerticalSeparator
    id: sep2
    anchors.top: parent.top
    anchors.bottom: closeButton.top
    anchors.horizontalCenter: parent.horizontalCenter
    margin-left: 3
    margin-bottom: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5

  Label
    id: castSpellLabel
    anchors.left: castSpell.right
    anchors.top: parent.top
    text: Cast Spell
    margin-top: 19
    margin-left: 15

  TextEdit
    id: castSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-left: 34
    margin-top: 15
    width: 100

  Label
    id: orangeSpellLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: Orange Spell
    margin-top: 49
    margin-left: 15

  TextEdit
    id: orangeSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-top: 45
    margin-left: 34
    width: 100

  CheckBox
    id: sameSpell
    anchors.left: orangeSpellLabel.right
    anchors.top: parent.top
    margin-top: 49
    margin-left: 8
    tooltip: Same Spell

  Label
    id: onScreenLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: On Screen
    margin-top: 79
    margin-left: 15

  TextEdit
    id: onScreen
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-left: 34
    margin-top: 75
    width: 100

  Label
    id: hppercentLabel
    anchors.left: hppercent.right
    anchors.top: parent.top
    margin-top: 105
    margin-left: 5
    text: Self Health

  HorizontalScrollBar
    id: hppercent
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 105
    width: 125
    minimum: 0
    maximum: 100
    step: 1

  Label
    id: cooldownTotalLabel
    anchors.left: hppercent.right
    anchors.top: parent.top
    margin-top: 135
    margin-left: 5
    text: Total Cooldown

  HorizontalScrollBar
    id: cooldownTotal
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 135
    width: 125
    minimum: 0
    maximum: 180
    step: 1

  Label
    id: cooldownActiveLabel
    anchors.left: hppercent.right
    anchors.top: parent.top
    margin-top: 165
    margin-left: 5
    text: Active Cooldown

  HorizontalScrollBar
    id: cooldownActive
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 165
    width: 125
    minimum: 0
    maximum: 180
    step: 1

  CheckBox
    id: reviveOption
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    !text: tr('Revive')
    tooltip: Revive Fuga
    width: 60
    margin-bottom: 65
    margin-left: 40

  CheckBox
    id: lifesOption
    anchors.bottom: parent.bottom
    anchors.left: reviveOption.right
    tooltip: Lifes Fuga
    width: 60
    !text: tr('Lifes')
    margin-bottom: 65
    margin-left: 10

  CheckBox
    id: multipleOption
    anchors.bottom: parent.bottom
    anchors.left: lifesOption.right
    !text: tr('Multiple')
    tooltip: Multiple Scape
    margin-bottom: 65
    width: 80
    margin-left: 5

  SpinBox
    id: lifesValue
    anchors.bottom: parent.bottom
    anchors.left: lifesOption.right
    margin-bottom: 60
    margin-left: 5
    size: 27 20
    minimum: 0
    maximum: 10
    step: 1
    editable: true
    focusable: true

  Button
    id: insertSpell
    text: Insert Spell
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 21
    margin-bottom: 40
    margin-right: 20


  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5

]], g_ui.getRootWidget())
fugaInterface:hide();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyIcon = setupUI([[
Panel
  height: 17
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Manual Keys

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])

keyInterface = setupUI([[
MainWindow
  text: Fuga Panel
  size: 300 400

  Panel
    image-source: /images/ui/panel_flat
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 320 235

  TextList
    id: spellList
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    padding: 1
    size: 240 215
    margin-top: 11
    vertical-scrollbar: spellListScrollBar

  Label
    id: castSpellLabel
    anchors.right: parent.right
    anchors.bottom: castSpell.top
    text: Spell Name
    margin-bottom: 5
    margin-right: 75

  TextEdit
    id: castSpell
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-bottom: 60
    margin-right: 14
    width: 125

  Label
    id: keyLabel
    anchors.left: parent.left
    anchors.bottom: castSpell.top
    text: Key
    margin-bottom: 5
    margin-left: 15

  TextEdit
    id: key
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    margin-bottom: 60
    margin-left: 14
    width: 70
    editable: false

  VerticalScrollBar
    id: spellListScrollBar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  Button
    id: insertKey
    text: Insert Key
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 25
    margin-right: 5
    margin-bottom: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    size: 45 25
    margin-left: 4
    margin-bottom: 5

]], g_ui.getRootWidget())
keyInterface:hide();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboIcon.title:setOn(isOn.comboMacro);
comboIcon.title.onClick = function(widget)
    isOn.comboMacro = not isOn.comboMacro;
    widget:setOn(isOn.comboMacro);
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

comboIcon.settings.onClick = function(widget)
    if not comboInterface:isVisible() then
        comboInterface:show();
        comboInterface:raise();
        comboInterface:focus();
    else
        comboInterface:hide();
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    end
end

comboInterface.closeButton.onClick = function(widget)
    comboInterface:hide();
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.cooldown:setText('0ms')
comboInterface.cooldown.onValueChange = function(widget, value)
    if value >= 1000 then
        widget:setText(value / 1000 .. 's')
    else
        widget:setText(value .. 'ms')
    end
end

comboInterface.distance:setText('0')
comboInterface.distance.onValueChange = function(widget, value)
    widget:setText(value)
end

comboInterface.sameSpell:setChecked(true);
comboInterface.orangeSpell:setEnabled(false);
comboInterface.sameSpell.onCheckChange = function(widget, checked)
    if checked then
        comboInterface.orangeSpell:setEnabled(false)
    else
        comboInterface.orangeSpell:setEnabled(true)
        comboInterface.orangeSpell:setText(comboInterface.castSpell:getText())
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function refreshComboList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy();
        end
        for _, widget in pairs(comboSpellsWidget) do
            widget:destroy()
        end
        for index, entry in ipairs(table) do
            local label = setupUI(spellEntry, list.spellList)
            local newWidget = setupUI(widgetConfig, g_ui.getRootWidget())
            newWidget:setText(firstLetterUpper(entry.spellCast))
            attachSpellWidgetCallbacks(newWidget, entry.index, storageProfiles.comboSpells)
            if not entry.widgetPos then
                entry.widgetPos = {
                    x = 0,
                    y = 50
                }
            end
            newWidget:setPosition(entry.widgetPos)
            comboSpellsWidget[entry.index] = newWidget;
            comboSpellsWidget[entry.index] = newWidget;
            label.onDoubleClick = function(widget)
                local spellTable = entry;
                list.castSpell:setText(spellTable.spellCast);
                list.orangeSpell:setText(spellTable.orangeSpell);
                list.onScreen:setText(spellTable.onScreen);
                list.cooldown:setValue(spellTable.cooldown);
                list.distance:setValue(spellTable.distance);
                for i, v in ipairs(storageProfiles.comboSpells) do
                    if v == entry then
                        removeTable(storageProfiles.comboSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.enabled:setChecked(entry.enabled);
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled;
                label.enabled:setChecked(entry.enabled);
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.showTimespell:setChecked(entry.enableTimeSpell)
            label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
            label.showTimespell.onClick = function(widget)
                entry.enableTimeSpell = not entry.enableTimeSpell;
                label.showTimespell:setChecked(entry.enableTimeSpell);
                label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
                if entry.enableTimeSpell then
                    newWidget:show();
                else
                    newWidget:hide();
                end
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            if entry.enableTimeSpell then
                newWidget:show();
            else
                newWidget:hide();
            end
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.comboSpells) do
                    if v == entry then
                        removeTable(storageProfiles.comboSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.onClick = function(widget)
                comboInterface.moveDown:show();
                comboInterface.moveUp:show();
            end
            label.textToSet:setText(firstLetterUpper(entry.spellCast));
            label:setTooltip('Orange Message: ' .. entry.orangeSpell .. ' | On Screen: ' .. entry.onScreen ..
                                 ' | Cooldown: ' .. entry.cooldown / 1000 .. 's | Distance: ' .. entry.distance)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.insertSpell.onClick = function(widget)
    local spellName = comboInterface.castSpell:getText():trim():lower();
    local orangeMsg = comboInterface.orangeSpell:getText():trim():lower();
    local onScreen = comboInterface.onScreen:getText();
    orangeMsg = (orangeMsg:len() == 0) and spellName or orangeMsg;
    local cooldown = comboInterface.cooldown:getValue();
    local distance = comboInterface.distance:getValue();
    if (not spellName or spellName:len() == 0) then
        return warn('Invalid Spell Name.');
    end
    if (not comboInterface.sameSpell:isChecked() and comboInterface.orangeSpell:getText():len() == 0) then
        return warn('Invalid Orange Spell.')
    end
    if (not onScreen or onScreen:len() == 0) then
        return warn('Invalid Text On Screen')
    end
    if (cooldown == 0) then
        return warn('Invalid Cooldown.')
    end
    if (distance == 0) then
        return warn('Invalid Distance')
    end
    local newSpell = {
        index = #storageProfiles.comboSpells + 1,
        spellCast = spellName,
        onScreen = onScreen,
        orangeSpell = orangeMsg,
        cooldown = cooldown,
        distance = distance,
        enableTimeSpell = true,
        enabled = true
    }
    table.insert(storageProfiles.comboSpells, newSpell)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
    refreshComboList(comboInterface, storageProfiles.comboSpells)
    comboInterface.castSpell:clearText();
    comboInterface.orangeSpell:clearText();
    comboInterface.onScreen:clearText();
    comboInterface.sameSpell:setChecked(true);
    comboInterface.orangeSpell:setEnabled(false);
    comboInterface.cooldown:setValue(0);
    comboInterface.distance:setValue(0);
end

refreshComboList(comboInterface, storageProfiles.comboSpells);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.moveUp.onClick = function()
    local action = comboInterface.spellList:getFocusedChild();
    if (not action) then
        return;
    end
    local index = comboInterface.spellList:getChildIndex(action);
    if (index < 2) then
        return;
    end
    comboInterface.spellList:moveChildToIndex(action, index - 1);
    comboInterface.spellList:ensureChildVisible(action);
    storageProfiles.comboSpells[index].index = index - 1;
    storageProfiles.comboSpells[index - 1].index = index;
    table.sort(storageProfiles.comboSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

comboInterface.moveDown.onClick = function()
    local action = comboInterface.spellList:getFocusedChild()
    if not action then
        return
    end
    local index = comboInterface.spellList:getChildIndex(action)
    if index >= comboInterface.spellList:getChildCount() then
        return
    end
    comboInterface.spellList:moveChildToIndex(action, index + 1);
    comboInterface.spellList:ensureChildVisible(action);
    storageProfiles.comboSpells[index].index = index + 1;
    storageProfiles.comboSpells[index + 1].index = index;
    table.sort(storageProfiles.comboSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.findCD.onClick = function(widget)
    detectOrangeSpell, testSpell = true, true;
    spellTime = {0, ''}
end

macro(10, function()
    if testSpell then
        say(comboInterface.castSpell:getText())
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if not detectOrangeSpell then
        return;
    end
    if player:getName() ~= name then
        return;
    end

    local verifying = comboInterface.orangeSpell:getText():len() > 0 and
                          comboInterface.orangeSpell:getText():lower():trim() or
                          comboInterface.castSpell:getText():lower():trim();

    if text:lower():trim() == verifying then
        if spellTime[2] == verifying then
            comboInterface.cooldown:setValue(now - spellTime[1]);
            spellTime = {now, verifying}
            detectOrangeSpell = false;
            testSpell = false;
        else
            spellTime = {now, verifying}
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

macro(10, function()
    if not (comboSpellsWidget or storageProfiles.comboSpells) then
        return;
    end
    for index, spellConfig in ipairs(storageProfiles.comboSpells) do
        local widget = comboSpellsWidget[spellConfig.index];
        if widget then
            if (not spellConfig.cooldownSpells or spellConfig.cooldownSpells < now) then
                widget:setColor('green')
                widget:setText(firstLetterUpper(spellConfig.onScreen) .. ' |  OK!')
            else
                widget:setColor('red')
                widget:setText(firstLetterUpper(spellConfig.onScreen) .. ' | ' ..
                                   formatRemainingTime(spellConfig.cooldownSpells))
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaIcon.title:setOn(isOn.fugaMacro);
fugaIcon.title.onClick = function(widget)
    isOn.fugaMacro = not isOn.fugaMacro;
    widget:setOn(isOn.fugaMacro);
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

fugaIcon.settings.onClick = function(widget)
    if not fugaInterface:isVisible() then
        fugaInterface:show();
        fugaInterface:raise();
        fugaInterface:focus();
    else
        fugaInterface:hide();
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    end
end

fugaInterface.closeButton.onClick = function(widget)
    fugaInterface:hide();
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaInterface.hppercent:setText('0%')
fugaInterface.hppercent.onValueChange = function(widget, value)
    widget:setText(value .. '%')
end

fugaInterface.cooldownTotal:setText('0s')
fugaInterface.cooldownTotal.onValueChange = function(widget, value)
    local formattedTime = formatTime(value)
    widget:setText(value .. 's')
    -- widget:setText(formattedTime)
end

fugaInterface.cooldownActive:setText('0s')
fugaInterface.cooldownActive.onValueChange = function(widget, value)
    local formattedTime = formatTime(value)
    widget:setText(value .. 's')
    -- widget:setText(formattedTime)
end

fugaIcon.showInfos:setChecked(isOn.showInfos)
fugaIcon.showInfos.onClick = function(widget)
    isOn.showInfos = not isOn.showInfos
    widget:setChecked(isOn.showInfos)
end

fugaInterface.sameSpell:setChecked(true);
fugaInterface.orangeSpell:setEnabled(false);
fugaInterface.sameSpell.onCheckChange = function(widget, checked)
    if checked then
        fugaInterface.orangeSpell:setEnabled(false)
    else
        fugaInterface.orangeSpell:setEnabled(true)
        fugaInterface.orangeSpell:setText(fugaInterface.castSpell:getText())
    end
end

fugaInterface.lifesValue:hide();
fugaInterface.lifesOption.onCheckChange = function(self, checked)
    if checked then
        fugaInterface.multipleOption:hide();
        fugaInterface.lifesValue:show();
    else
        fugaInterface.multipleOption:show();
        fugaInterface.lifesValue:hide();
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function refreshFugaList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy();
        end
        for _, widget in pairs(fugaSpellsWidgets) do
            widget:destroy();
        end
        for index, entry in ipairs(table) do
            local label = setupUI(spellEntry, list.spellList)
            local newWidget = setupUI(widgetConfig, g_ui.getRootWidget())
            newWidget:setText(firstLetterUpper(entry.spellCast))
            attachSpellWidgetCallbacks(newWidget, entry.index, storageProfiles.fugaSpells)

            if not entry.widgetPos then
                entry.widgetPos = {
                    x = 0,
                    y = 50
                }
            end
            if entry.enableTimeSpell then
                newWidget:show();
            else
                newWidget:hide();
            end
            newWidget:setPosition(entry.widgetPos)
            fugaSpellsWidgets[entry.index] = newWidget;
            label.onDoubleClick = function(widget)
                local spellTable = entry;
                list.castSpell:setText(spellTable.spellCast);
                list.orangeSpell:setText(spellTable.orangeSpell);
                list.onScreen:setText(spellTable.onScreen);
                list.hppercent:setValue(spellTable.selfHealth);
                list.cooldownTotal:setValue(spellTable.cooldownTotal);
                list.cooldownActive:setValue(spellTable.cooldownActive);
                for i, v in ipairs(storageProfiles.fugaSpells) do
                    if v == entry then
                        removeTable(storageProfiles.fugaSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.enabled:setChecked(entry.enabled);
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled;
                label.enabled:setChecked(entry.enabled);
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.showTimespell:setChecked(entry.enableTimeSpell)
            label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
            label.showTimespell.onClick = function(widget)
                entry.enableTimeSpell = not entry.enableTimeSpell;
                label.showTimespell:setChecked(entry.enableTimeSpell);
                label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
                if entry.enableTimeSpell then
                    newWidget:show();
                else
                    newWidget:hide();
                end
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.fugaSpells) do
                    if v == entry then
                        removeTable(storageProfiles.fugaSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.onClick = function(widget)
                fugaInterface.moveDown:show();
                fugaInterface.moveUp:show();
            end
            label.textToSet:setText(firstLetterUpper(entry.spellCast));
            label:setTooltip('Orange Message: ' .. entry.orangeSpell .. ' | On Screen: ' .. entry.onScreen ..
                                 ' | Total Cooldown: ' .. entry.cooldownTotal .. 's | Active Cooldown: ' ..
                                 entry.cooldownActive .. 's | Hppercent: ' .. entry.selfHealth)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaInterface.moveUp.onClick = function()
    local action = fugaInterface.spellList:getFocusedChild();
    if (not action) then
        return;
    end
    local index = fugaInterface.spellList:getChildIndex(action);
    if (index < 2) then
        return;
    end
    fugaInterface.spellList:moveChildToIndex(action, index - 1);
    fugaInterface.spellList:ensureChildVisible(action);
    storageProfiles.fugaSpells[index].index = index - 1;
    storageProfiles.fugaSpells[index - 1].index = index;
    table.sort(storageProfiles.fugaSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

fugaInterface.moveDown.onClick = function()
    local action = fugaInterface.spellList:getFocusedChild()
    if not action then
        return;
    end
    local index = fugaInterface.spellList:getChildIndex(action)
    if index >= fugaInterface.spellList:getChildCount() then
        return
    end
    fugaInterface.spellList:moveChildToIndex(action, index + 1);
    fugaInterface.spellList:ensureChildVisible(action);
    storageProfiles.fugaSpells[index].index = index + 1;
    storageProfiles.fugaSpells[index + 1].index = index;
    table.sort(storageProfiles.fugaSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaInterface.insertSpell.onClick = function(widget)
    local spellName = fugaInterface.castSpell:getText():trim():lower();
    local orangeMsg = fugaInterface.orangeSpell:getText():trim():lower();
    local onScreen = fugaInterface.onScreen:getText();
    orangeMsg = (orangeMsg:len() == 0) and spellName or orangeMsg;
    local hppercent = fugaInterface.hppercent:getValue();
    local cooldownTotal = fugaInterface.cooldownTotal:getValue();
    local cooldownActive = fugaInterface.cooldownActive:getValue();

    if spellName:len() == 0 then
        return warn('Invalid Spell Name.');
    end
    if not fugaInterface.sameSpell:isChecked() and orangeMsg:len() == 0 then
        return warn('Invalid Orange Spell.')
    end
    if onScreen:len() == 0 then
        return warn('Invalid Text On Screen')
    end
    if hppercent == 0 then
        return warn('Invalid Hppercent.')
    end
    if cooldownTotal == 0 then
        return warn('Invalid Cooldown Total.')
    end

    local spellConfig = {
        index = #storageProfiles.fugaSpells + 1,
        spellCast = spellName,
        orangeSpell = orangeMsg,
        onScreen = onScreen,
        selfHealth = hppercent,
        cooldownActive = cooldownActive,
        cooldownTotal = cooldownTotal,
        enableTimeSpell = true,
        enabled = true
    }

    if fugaInterface.lifesOption:isChecked() then
        spellConfig.lifes = 0;
        spellConfig.enableLifes = true;
        if fugaInterface.lifesValue:getValue() == 0 then
            return warn('Invalid Life Value.')
        end
        spellConfig.amountLifes = fugaInterface.lifesValue:getValue();
    end
    if fugaInterface.reviveOption:isChecked() then
        spellConfig.enableRevive = true;
        spellConfig.alreadyChecked = false;
    end
    if fugaInterface.multipleOption:isChecked() then
        spellConfig.enableMultiple = true;
        spellConfig.count = 3;
    end
    table.insert(storageProfiles.fugaSpells, spellConfig)
    refreshFugaList(fugaInterface, storageProfiles.fugaSpells)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)

    fugaInterface.castSpell:clearText()
    fugaInterface.orangeSpell:clearText()
    fugaInterface.onScreen:clearText()
    fugaInterface.cooldownTotal:setValue(0)
    fugaInterface.cooldownActive:setValue(0)
    fugaInterface.hppercent:setValue(0)
    fugaInterface.reviveOption:setChecked(false);
    fugaInterface.lifesOption:setChecked(false);
    fugaInterface.multipleOption:setChecked(false);
    fugaInterface.multipleOption:show();
    fugaInterface.lifesValue:hide();
end

refreshFugaList(fugaInterface, storageProfiles.fugaSpells);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

storage.widgetPos = storage.widgetPos or {};
informationWidget = {};

local widgetNames = {'showText'}

for i, widgetName in ipairs(widgetNames) do
    informationWidget[widgetName] = setupUI(widgetConfig, g_ui.getRootWidget())
end

local function attachSpellWidgetCallbacks(key)
    informationWidget[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = {
            x = mousePos.x - widget:getX(),
            y = mousePos.y - widget:getY()
        }
        return true
    end

    informationWidget[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x),
            parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(),
            mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    informationWidget[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX();
        storage.widgetPos[key].y = widget:getY();
        return true
    end
end

for key, value in pairs(informationWidget) do
    attachSpellWidgetCallbacks(key)
    informationWidget[key]:setPosition(storage.widgetPos[key] or {0, 50})
end

local toShow = informationWidget['showText'];

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

macro(10, function()
    if isOn.showInfos then
        for _, value in ipairs(storageProfiles.fugaSpells) do
            if value.selfHealth then
                toShow:show()
                toShow:setText('Inimigos: ' .. getPlayersAttack(false) .. ' | Porcentagem: ' ..
                                   calculatePercentage(value.selfHealth) .. ' | Vida: ' .. player:getHealthPercent())
                return;
            end
        end
    else
        toShow:hide();
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macro(10, function()
    if not (fugaSpellsWidgets and storageProfiles.fugaSpells) then
        return;
    end

    for index, spellConfig in ipairs(storageProfiles.fugaSpells) do
        local widget = fugaSpellsWidgets[spellConfig.index];
        if widget then
            local textToSet = firstLetterUpper(spellConfig.onScreen)
            local color = 'green'
            if spellConfig.activeCooldown and spellConfig.activeCooldown > os.time() then
                textToSet = textToSet .. ' | ' .. formatOsTime(spellConfig.activeCooldown)
                color = 'blue'
                if spellConfig.enableLifes and spellConfig.lifes == 0 then
                    spellConfig.activeCooldown = nil;
                end
            elseif spellConfig.totalCooldown and spellConfig.totalCooldown > os.time() then
                textToSet = textToSet .. ' | ' .. formatOsTime(spellConfig.totalCooldown)
                color = 'red'
            else
                textToSet = textToSet .. ' | OK!'
                if spellConfig.enableMultiple and spellConfig.canReset then
                    spellConfig.count = 3;
                    spellConfig.canReset = false;
                end
                if spellConfig.enableLifes then
                    spellConfig.lifes = 0;
                end
                if spellConfig.enableRevive then
                    spellConfig.alreadyChecked = false;
                end
            end
            if spellConfig.enableMultiple and spellConfig.count > 0 then
                textToSet = 'COUNT: ' .. spellConfig.count .. ' | ' .. textToSet
            end
            if spellConfig.enableLifes and spellConfig.lifes > 0 then
                textToSet = 'VIDAS: ' .. spellConfig.lifes .. ' | ' .. textToSet
            end
            widget:setText(textToSet)
            widget:setColor(color)
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyIcon.title:setOn(isOn.keyMacro);
keyIcon.title.onClick = function(widget)
    isOn.keyMacro = not isOn.keyMacro;
    widget:setOn(isOn.keyMacro);
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

keyIcon.settings.onClick = function(widget)
    if not keyInterface:isVisible() then
        keyInterface:show();
        keyInterface:raise();
        keyInterface:focus();
    else
        keyInterface:hide();
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    end
end

keyInterface.closeButton.onClick = function(widget)
    keyInterface:hide();
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyInterface.key.onHoverChange = function(widget, hovered)
    if hovered then
        x = true;
        onKeyPress(function(key)
            if not x then
                return;
            end
            widget:setText(key)
        end)
    else
        x = false;
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function refreshKeyList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy();
        end
        for index, entry in ipairs(table) do
            local label = setupUI(spellEntry, list.spellList)
            label.showTimespell:hide();
            label.onDoubleClick = function(widget)
                local spellTable = entry;
                list.key:setText(spellTable.keyPress);
                list.castSpell:setText(spellTable.spellCast);
                for i, v in ipairs(storageProfiles.keySpells) do
                    if v == entry then
                        removeTable(storageProfiles.keySpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                label:destroy();
            end
            label.enabled:setChecked(entry.enabled);
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled;
                label.enabled:setChecked(entry.enabled);
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.keySpells) do
                    if v == entry then
                        removeTable(storageProfiles.keySpells, i)
                    end
                end
                scriptFuncs.reindexTable(storageProfiles.keySpells);
                label:destroy();
            end
            label.textToSet:setText(firstLetterUpper(entry.spellCast) .. ' | Key: ' .. entry.keyPress);
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyInterface.insertKey.onClick = function(widget)
    local keyPressed = keyInterface.key:getText();
    local spellName = keyInterface.castSpell:getText():lower():trim();

    if not keyPressed or keyPressed:len() == 0 then
        return warn('Invalid Key.')
    end
    for _, config in ipairs(storageProfiles.keySpells) do
        if config.keyPress == keyPressed then
            return warn('Key Already Added.')
        end
    end
    table.insert(storageProfiles.keySpells, {
        index = #storageProfiles.keySpells + 1,
        spellCast = spellName,
        keyPress = keyPressed,
        enabled = true
    });
    refreshKeyList(keyInterface, storageProfiles.keySpells)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    keyInterface.key:clearText();
    keyInterface.castSpell:clearText();
end

refreshKeyList(keyInterface, storageProfiles.keySpells);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

os = os or modules.os;
local playerName = player:getName()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macro combo
macro(10, function()
    if (not comboIcon.title:isOn()) then
        return;
    end
    if stopToCast() then
        return;
    end
    if isAnySelectedKeyPressed() then
        return;
    end
    local playerPos = player:getPosition();
    local target = g_game.getAttackingCreature();
    if not g_game.isAttacking() then
        return;
    end
    local targetPos = target:getPosition();
    if not targetPos then
        return;
    end
    local targetDistance = getDistanceBetween(playerPos, targetPos);
    for index, value in ipairs(storageProfiles.comboSpells) do
        if value.enabled and targetDistance <= value.distance then
            if (not value.cooldownSpells or value.cooldownSpells <= now) then
                say(value.spellCast)
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macro fuga
local selfPlayer = g_game.getLocalPlayer();

macro(100, function()
    if not fugaIcon.title:isOn() then
        return;
    end
    if isInPz() then
        return;
    end
    local time = os.time();
    local selfHealth = selfPlayer:getHealthPercent();
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if value.enabled and selfHealth <= calculatePercentage(value.selfHealth) then
            if (not value.totalCooldown or value.totalCooldown <= time) and not canCastFuga() then
                say(value.spellCast)
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macro key
macro(10, function()
    if not keyIcon.title:isOn() then
        return;
    end
    if modules.game_console:isChatEnabled() then
        return;
    end
    for index, value in ipairs(storageProfiles.keySpells) do
        if value.enabled and (modules.corelib.g_keyboard.areKeysPressed(value.keyPress)) then
            say(value.spellCast)
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onTalk(function(name, level, mode, text, channelId, pos)
    text = text:lower();
    if name ~= player:getName() then
        return;
    end

    for index, value in ipairs(storageProfiles.comboSpells) do
        if text == value.orangeSpell then
            value.cooldownSpells = now + value.cooldown;
            -- warn('Combo OK.')
            break
        end
    end
    for index, value in ipairs(storageProfiles.fugaSpells) do
        if text == value.orangeSpell then
            if value.enableLifes then
                value.activeCooldown = os.time() + (value.cooldownActive);
                value.totalCooldown = os.time() + (value.cooldownTotal);
                value.lifes = value.amountLifes;
                -- warn('1 IF: ' .. value.orangeSpell)
            end
            if value.enableRevive and not value.alreadyChecked then
                value.totalCooldown = os.time() + (value.cooldownTotal);
                value.activeCooldown = os.time() + (value.cooldownActive);
                value.alreadyChecked = true;
                -- warn('2 IF: ' .. value.orangeSpell)
            end
            if value.enableMultiple then
                if value.count > 0 then
                    value.count = value.count - 1
                    value.activeCooldown = os.time() + (value.cooldownActive);
                    if value.count == 0 then
                        value.totalCooldown = os.time() + (value.cooldownTotal);
                        value.canReset = true;
                    end
                end
            end
            if not (value.enableLifes or value.enableRevive or value.enableMultiple) then
                value.activeCooldown = os.time() + (value.cooldownActive);
                value.totalCooldown = os.time() + (value.cooldownTotal);
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onTextMessage(function(mode, text)
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if value.enableLifes then
            if text:lower():find('morreu e renasceu') and value.activeCooldown and value.activeCooldown >= os.time() then
                value.lifes = value.lifes - 1;
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onPlayerPositionChange(function(newPos, oldPos)
    local izanagiPos = {
        x = 1214,
        y = 686,
        z = 6
    };
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if value.enableRevive and value.spellCast == 'izanagi' then
            if newPos.x == izanagiPos.x and newPos.y == izanagiPos.y and newPos.z == izanagiPos.z then
                value.activeCooldown = nil;
                value.alreadyChecked = true;
            end
        end
    end
end);
