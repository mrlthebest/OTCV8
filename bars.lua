--! Caso queira desativar alguma barra, deixe em false.
local config = {
  healthBar = true,
  manaBar = true,
  targetBar = true
}

--! Cores para a barra de vida.
local lifeColors = {
    { percent = 35, color = 'red' },
    { percent = 75, color = 'yellow' },
    { percent = 100, color = 'green' }
}

--! Cores para a barra de mana.
local manaColors = {
    { percent = 35, color = '#000099' },
    { percent = 75, color = '#3333CC' },
    { percent = 100, color = '#4D4DFF' }
}


--! Não mexa nada abaixo.
---------------------------------------------------------------------------------------
local widgetHealthPercent = [[
ProgressBar
  id: bar
  background-color: red
  height: 16
  width: 240
  focusable: true
  phantom: false
  draggable: true
  text-align: left
  text:
]];

local widgetManaPercent = [[
ProgressBar
  id: bar
  background-color: blue
  height: 16
  width: 240
  focusable: true
  phantom: false
  draggable: true
  text-align: left
  text:
]];

local widgetTarget = [[
UIWidget
  id: targetWidget
  background-color: alpha
  width: 240
  height: 48
  border-radius: 4
  padding: 4
  focusable: false
  phantom: false
  draggable: true

  ProgressBar
    id: progressBar
    height: 12
    width: 240
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    background-color: #880000
    text-align: left
    text-color: white

  UICreature
    id: targetSprite
    width: 64
    height: 64
    anchors.left: parent.left
    anchors.bottom: progressBar.top
    margin-left: -35

  UILabel
    id: targetName
    anchors.left: targetSprite.right
    anchors.bottom: progressBar.top
    color: white
    text: 
    text-wrap: true
    width: 250
]]

storage.widgetPos = storage.widgetPos or {}

local panel = {}

panel['healthWidget'] = setupUI(widgetHealthPercent, g_ui.getRootWidget())
panel['healthWidget']:setVisible(config.healthBar)

panel['manaWidget'] = setupUI(widgetManaPercent, g_ui.getRootWidget())
panel['manaWidget']:setVisible(config.manaBar)

panel['targetWidget'] = setupUI(widgetTarget, g_ui.getRootWidget())
panel['targetWidget']:setVisible(config.targetBar)

local isMobile = modules._G.g_app.isMobile();
g_keyboard = g_keyboard or modules.corelib.g_keyboard;

local isDragKeyPressed = function()
	return isMobile and g_keyboard.isKeyPressed("F2") or g_keyboard.isCtrlPressed();
end

local function attachSpellWidgetCallbacks(key)
    panel[key].onDragEnter = function(widget, mousePos)
        if (not isDragKeyPressed()) then 
            return; 
        end 
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true;
    end

    panel[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true;
    end

    panel[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {
            x = widget:getX(),
            y = widget:getY()
        }
        return true;
    end
end

for key, value in pairs(panel) do
    attachSpellWidgetCallbacks(key)
    panel[key]:setPosition(storage.widgetPos[key] or { 500, 500 })
end

local function getColorByPercent(percent, colorList)
    for i = 1, #colorList do
        if percent <= colorList[i].percent then
            return colorList[i].color
        end
    end
    return colorList[#colorList].color
end

local function updateWidget(widget, percent, label, colorList)
    if (not widget) then return; end
    widget:setPercent(percent)
    widget:setText(string.format("%s: %d%%", label, percent))
    widget:setBackgroundColor(getColorByPercent(percent, colorList))
end

local function updateTargetWidget(outfitType, targetNameText, percent)
    local target = panel['targetWidget']
    target.targetSprite:setOutfit(outfitType)

    if targetNameText == "Sem Target" then target.targetName:setText(targetNameText) else target.targetName:setText(string.format("%s: %d%%", targetNameText, percent)) end
    target.progressBar:setPercent(percent)
    target.progressBar:setBackgroundColor(getColorByPercent(percent, lifeColors))
end

-- Main looping
macro(100, function()

    local outfit, name, percent = {}, "Sem Target", 100

    if g_game.isAttacking() then
        local target = g_game.getAttackingCreature()
        if target then
            outfit = target:getOutfit()
            name = target:getName()
            percent = target:getHealthPercent()
        end
    end

    updateWidget(panel['manaWidget'], manapercent(), "Mana", manaColors)
    updateWidget(panel['healthWidget'], hppercent(), "Vida", lifeColors)
    updateTargetWidget(outfit, name, percent)
end)
