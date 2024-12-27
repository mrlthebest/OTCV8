timeEnemy = {};
enemy_data = {spells={}};
storage._enemy = storage._enemy or {};
local dir = configDir .. "/storage";
local path = dir .. "/" .. g_game.getWorldName() .. ".json";

if not g_resources.directoryExists(dir) then
    g_resources.makeDir(dir);
end

timeEnemy.save = function()
    local status, result = pcall(json.encode, enemy_data, 4);
    if status then
        local success = g_resources.writeFileContents(path, result);
        if success then
        end
    end
end

timeEnemy.load = function()
    local data = enemy_data;
    if modules._G.g_resources.fileExists(path) then
        local content = modules._G.g_resources.readFileContents(path);
        local status, result = pcall(json.decode, content);
        if status then
            data = result;
        else
            warn("Erro ao decodificar o arquivo JSON: " .. result);
        end
    else
        timeEnemy.save();
    end
    enemy_data = data;
end

local spellEntryTimeSpell = [[
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

  Label
    id: text
    anchors.left: parent.left
    margin-left: 25
    margin-top: 5
    font: terminus-14px-bold

  $focus:
    background-color: #00000055

  Button
    id: remove
    !text: tr('X')
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 15
    margin-top: 2
    width: 15
    height: 15
    tooltip: Remove
]];

local timer_add = [[
Label
  text-auto-resize: true
  font: verdana-11px-rounded
  color: orange
  margin-bottom: 5
  text-offset: 3 1
]];

timeEnemy.buttons = setupUI([[
Panel
  height: 90
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Time Spell Enemy')

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  CheckBox
    id: target
    anchors.top: settings.bottom
    anchors.left: parent.left
    margin-top: 3
    margin-left: 5
    text: Targets
    width: 68
    tooltip: Time Spell Targets
    checked: false

  CheckBox
    id: enemy
    anchors.top: target.bottom
    anchors.left: parent.left
    margin-top: 3
    margin-left: 5
    text: Enemies
    width: 68
    tooltip: Time Spell Enemies
    checked: false

  CheckBox
    id: guild
    anchors.top: enemy.bottom
    anchors.left: parent.left
    margin-top: 3
    margin-left: 5
    text: Guilds
    width: 68
    tooltip: Time Spell Guilds
    checked: false

]]);

timeEnemy.widget = setupUI([[
UIWindow
  size: 200 300
  background-color: black
  opacity: 0.85
  border: 2 orange
  anchors.right: parent.right
  anchors.top: parent.top
  margin-right: 300
  margin-top: 150

  Label
    id: title
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center
    font: sans-bold-16px
    margin-top: 15
    color: orange
    text: Time Spell Enemy

  ScrollablePanel
    id: enemyList
    layout:
      type: verticalBox
    anchors.fill: parent
    margin-top: 35
    margin-left: 10
    margin-right: 10
    margin-bottom: 30

  ResizeBorder
    id: bottomResizeBorder
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    enabled: true

  ResizeBorder
    id: rightResizeBorder
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    enabled: true
]], g_ui.getRootWidget());

timeEnemy.interface = setupUI([[
MainWindow
  !text: tr('Time Spell Enemy Interface')
  size: 450 315

  Panel
    id: leftPanel
    image-source: /images/ui/panel_flat
    anchors.horizontalCenter: spellList.horizontalCenter
    anchors.verticalCenter: spellList.verticalCenter
    image-border: 6
    padding: 3
    size: 210 210

  TextList
    id: spellList
    anchors.left: parent.left
    anchors.top: parent.top
    padding: 1
    size: 200 200  
    margin-top: 10
    margin-left: 10
    vertical-scrollbar: spellListScrollbar

  VerticalScrollBar
    id: spellListScrollbar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  VerticalSeparator
    id: sep
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: leftPanel.top
    anchors.bottom: separator.top
    margin-bottom: 8
    margin-left: 15

  Panel
    id: rightPanel
    image-source: /images/ui/panel_flat
    anchors.verticalCenter: spellList.verticalCenter
    anchors.right: parent.right
    anchors.left: sep.right
    image-border: 6
    padding: 3
    size: 210 210
    margin-left: 7
    margin-right: 5

  Label
    id: spellNameLabel
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: parent.top
    margin-top: 15
    text: Spell Name

  TextEdit
    id: spellName
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: spellNameLabel.bottom
    margin-top: 5
    width: 100

  Label
    id: onScreenLabel
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: spellName.bottom
    margin-top: 5
    text: On Screen

  TextEdit
    id: onScreen
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: onScreenLabel.bottom
    margin-top: 5
    width: 100

  Label
    id: cooldownTotalLabel
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: onScreen.bottom
    text: Cooldown Total
    margin-top: 5

  HorizontalScrollBar
    id: cooldownTotal
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: cooldownTotalLabel.bottom
    margin-top: 5
    width: 125
    minimum: 0
    maximum: 120
    step: 1

  Label
    id: cooldownAtivoLabel
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: cooldownTotal.bottom
    text: Cooldown Ativo
    margin-top: 5

  HorizontalScrollBar
    id: cooldownAtivo
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: cooldownAtivoLabel.bottom
    margin-top: 5
    width: 125
    minimum: 0
    maximum: 360
    step: 1

  Button
    id: addButton
    anchors.horizontalCenter: rightPanel.horizontalCenter
    anchors.top: cooldownAtivo.bottom
    margin-top: 10
    text: Adicionar
    image-color: #dfdfdf

  Label
    id: warnText
    anchors.left: worldSettings.right
    anchors.bottom: parent.bottom
    margin-bottom: 10
    margin-left: 10
    color: yellow
    width: 200


  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5   
    margin-left: 5
    margin-right: 5

  ComboBox
    id: worldSettings
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    width: 150
    margin-bottom: 5
    margin-left: 5

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 50 21
    margin-bottom: 5
    margin-right: 5

]], g_ui.getRootWidget());
timeEnemy.interface:hide();

local function hide_logic()
    if not timeEnemy.interface:isVisible() then
        timeEnemy.interface:show();
    else
        timeEnemy.interface:hide();
        timeEnemy.save();
    end
end

local button_add_color = function(bool)
    local color = (bool and "green") or "red";
    timeEnemy.interface.addButton:setImageColor(color);
    schedule(2000, function()
        timeEnemy.interface.addButton:setImageColor("#dfdfdf");
    end);
end

local warning_text = function(text)
    local widget = timeEnemy.interface.warnText;
    widget:setVisible(true);
    widget:setText(text);
    schedule(2000, function()
        widget:setText("");
        widget:setVisible(false);
    end);
end

timeEnemy.interface.closeButton.onClick = hide_logic;
timeEnemy.buttons.settings.onClick = hide_logic;
timeEnemy.buttons.title.onClick = function(widget)
    enemy_data.enabled = not enemy_data.enabled;
    widget:setOn(enemy_data.enabled);
    timeEnemy.widget:setVisible(enemy_data.enabled);
    timeEnemy.save();
end

timeEnemy.clear = function()
    timeEnemy.interface.spellName:setTooltip("Mensagem laranja que sobe ao usar a spell.");
    timeEnemy.interface.onScreen:setTooltip("O que vai aparecer no time spell.");
    timeEnemy.interface.spellName:setText("");
    timeEnemy.interface.onScreen:setText("");
    timeEnemy.interface.cooldownAtivo:setText("0seg");
    timeEnemy.interface.cooldownTotal:setText("0seg");
end

timeEnemy.addOption = function()
    local worldName = g_game.getWorldName();
    timeEnemy.interface.worldSettings:addOption(worldName);
    timeEnemy.interface.worldSettings:setOption(worldName);
end

timeEnemy.checkBoxes = function()
    timeEnemy.buttons.target:setChecked(enemy_data.target or false);
    timeEnemy.buttons.enemy:setChecked(enemy_data.enemy or false);
    timeEnemy.buttons.guild:setChecked(enemy_data.guild or false);
end

timeEnemy.onLoading = function()
    timeEnemy.load();
    timeEnemy.checkBoxes();
    timeEnemy.clear();
    timeEnemy.addOption();
    timeEnemy.refreshList();
    timeEnemy.buttons.title:setOn(enemy_data.enabled or false);
    timeEnemy.widget:setVisible(enemy_data.show_panel or false);
    timeEnemy.widget:setVisible(enemy_data.enabled or false);
end

timeEnemy.refreshList = function()
    for i, child in pairs(timeEnemy.interface.spellList:getChildren()) do
        child:destroy();
    end
    for index, entry in ipairs(enemy_data.spells) do
        local label = setupUI(spellEntryTimeSpell, timeEnemy.interface.spellList);
        label.remove.onClick = function(widget)
            table.remove(enemy_data.spells, index);
            timeEnemy.save();
            timeEnemy.refreshList();
        end;
        label.enabled:setChecked(entry.enabled);
        label.enabled.onClick = function(widget)
            entry.enabled = not entry.enabled;
            label.enabled:setChecked(entry.enabled);
            timeEnemy.save();
        end;
        label.onDoubleClick = function(widget)
            timeEnemy.interface.spellName:setText(entry.spellName);
            timeEnemy.interface.onScreen:setText(entry.onScreen);
            timeEnemy.interface.cooldownAtivo:setValue(entry.cooldownActive);
            timeEnemy.interface.cooldownTotal:setValue(entry.cooldownTotal);
            table.remove(enemy_data.spells, index);
            timeEnemy.save();
            timeEnemy.refreshList();
        end;
        label.text:setText(entry.spellName);
        label:setTooltip("On Screen: " .. entry.onScreen .. " | CD Ativo: " .. entry.cooldownActive .. " | CD Total: " .. entry.cooldownTotal);
    end
end

timeEnemy.doCheckCreature = function(name)
    if (name == player:getName():lower()) then
        return false;
    end
    if (enemy_data.target and g_game.isAttacking() and (g_game.getAttackingCreature():getName() == name)) then
        return true;
    end
    if enemy_data.enemy then
        local findCreature = getCreatureByName(name);
        if not findCreature then
            return false;
        end
        if (findCreature:getEmblem() ~= 1) then
            return true;
        end
    end
    if enemy_data.guild then
        local findCreature = getCreatureByName(name);
        if not findCreature then
            return false;
        end
        if ((findCreature:getEmblem() ~= 1) or findCreature:isPartyMember()) then
            return true;
        end
    end
    return false;
end

timeEnemy.interface.cooldownAtivo.onValueChange = function(widget, value)
    widget:setText(value .. "seg");
    if (value > 60) then
        widget:setTooltip(string.format("%.1fmin", value / 60));
    else
        widget:setTooltip("");
    end
end

timeEnemy.interface.cooldownTotal.onValueChange = function(widget, value)
    widget:setText(value .. "seg");
    if (value > 60) then
        widget:setTooltip(string.format("%.1fmin", value / 60));
    else
        widget:setTooltip("");
    end
end

timeEnemy.buttons.target.onCheckChange = function(widget, checked)
    enemy_data.target = checked;
    timeEnemy.save();
end

timeEnemy.buttons.enemy.onCheckChange = function(widget, checked)
    enemy_data.enemy = checked;
    timeEnemy.save();
end

timeEnemy.buttons.guild.onCheckChange = function(widget, checked)
    enemy_data.guild = checked;
    timeEnemy.save();
end

timeEnemy.interface.addButton.onClick = function()
    local timeWidget = timeEnemy.interface;
    local spellName = timeWidget.spellName:getText():lower():trim();
    local onScreen = timeWidget.onScreen:getText();
    local cooldownAtivo = timeWidget.cooldownAtivo:getValue();
    local cooldownTotal = timeWidget.cooldownTotal:getValue();
    if (not spellName or (spellName:len() == 0)) then
        button_add_color(false);
        warning_text("Spell Name Invalida.");
        return;
    end
    if (not onScreen or (onScreen:len() == 0)) then
        button_add_color(false);
        warning_text("On Screen Invalida.");
        return;
    end
    if (not cooldownAtivo or (cooldownAtivo == 0)) then
        button_add_color(false);
        warning_text("Cooldown Ativo Invalido.");
        return;
    end
    if (not cooldownTotal or (cooldownTotal == 0)) then
        button_add_color(false);
        warning_text("Cooldown Total Invalido.");
        return;
    end
    table.insert(enemy_data.spells, {enabled=true,spellName=spellName,onScreen=onScreen,cooldownActive=cooldownAtivo,cooldownTotal=cooldownTotal});
    button_add_color(true);
    warning_text("Spell Inserida com Sucesso.");
    timeEnemy.save();
    timeEnemy.clear();
    timeEnemy.refreshList();
end

macro(100, function()
    for _, child in pairs(timeEnemy.widget.enemyList:getChildren()) do
        child:destroy();
    end
    for index = #storage._enemy, 1, -1 do
        local entry = storage._enemy[index];
        if (entry.totalCooldown <= os.time()) then
            table.remove(storage._enemy, index);
        else
            local label = setupUI(timer_add, timeEnemy.widget.enemyList);
            if (entry.activeCooldown >= os.time()) then
                label:setColoredText({entry.playerName,"white",":    ","white",(entry.onScreen),"orange","    [ CD: ","orange",(entry.activeCooldown - os.time()),"orange"," ]","orange"});
            else
                label:setColoredText({entry.playerName,"white",":    ","white",(entry.onScreen),"orange","    [ CD: ","red",(entry.totalCooldown - os.time()),"red"," ]","red"});
            end
        end
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if not timeEnemy.doCheckCreature(name) then
        return;
    end
    text = text:lower():trim();
    for _, entry in ipairs(enemy_data.spells) do
        if (entry.spellName == text) then
            local activeCooldown = os.time() + entry.cooldownActive;
            local totalCooldown = os.time() + entry.cooldownTotal;
            table.insert(storage._enemy, {playerName=name,onScreen=entry.onScreen,activeCooldown=activeCooldown,totalCooldown=totalCooldown});
        end
    end
end);

timeEnemy.onLoading();
