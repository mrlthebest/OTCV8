-- adicione as cidades aqui
local cities = {
  'Earth',
  'M2',
  'Tsufur',
  'Namek',
  'Zelta',
  'Vegeta',
  'Premia',
  'City 17',
  'Gardia',
  'Rygol',
  'Ruudese',
  'Kanassa',
  'Gelbo',
  'Tritek',
  'Yardratt'
}
-- adicione o nome do npc
local npcName = 'Gravity Console';


-- não edita nada abaixo disso
travelUI = setupUI([[
UIWindow
  !text: tr('Travel')
  color: #99d6ff
  font: sans-bold-16px
  size: 100 100
  background-color: black
  opacity: 0.85
  anchors.left: parent.left
  anchors.top: parent.top
  margin-left: 600
  margin-top: 150

  ComboBox
    id: travelOptions
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center
    opacity: 1.0
    color: yellow
    font: sans-bold-16px
    margin-top: 25

    @onSetup: |
      self:addOption("None")

  Button
    id: closeButton
    text: X
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: #99d6ff
    size: 15 15
    margin-bottom: 10
    margin-right: 10


    
]], g_ui.getRootWidget());
travelUI:hide();

for _, city in ipairs(cities) do
  travelUI.travelOptions:addOption(city)
end

NPC.talk = function(text)
  if g_game.getClientVersion() >= 810 then
      g_game.talkChannel(11, 0, text)
  else
      return say(text)
  end
end

macro(100, function()
  local findNpc = getCreatureByName(npcName)
  if findNpc and getDistanceBetween(pos(), findNpc:getPosition()) <= 2 then
      travelUI:show();
  else
      travelUI:hide();
  end
end)

travelUI.travelOptions.onOptionChange = function(widget, option, data)
  say('hi')
  schedule(100, function()
      NPC.talk(option)
  end)
  schedule(300, function()
      NPC.talk('yes')
  end)
end
