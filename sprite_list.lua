sprite_list = setupUI([[
MainWindow
  id: qweqrwerwe
  size: 280 120
  !text: tr("Show Sprites")
    
  UICreature
    id: spriteCreature
    size: 80 80
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    margin-bottom: 27
    margin-left: -30

  SpinBox
    id: spriteId
    anchors.top: parent.top
    anchors.left: prev.right
    margin-top: 15
    margin-left: 50
    padding-left: 5
    width: 120
    minimum: 1
    maximum: 4000
    focusable: true
    editable: true

  Label
    anchors.top: parent.top
    anchors.left: prev.left
    anchors.right: prev.right
    text-align: center
    !text: tr("Sprite ID")

  Button
    id: clearButton
    !text: tr('Clear')
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    width: 60
  
  Button
    id: okButton
    !text: tr('Ok')
    anchors.bottom: parent.bottom
    anchors.right: next.left
    margin-right: 10
    width: 60

  Button
    id: cancelButton
    !text: tr('Cancel')
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 60

]], g_ui.getRootWidget());
sprite_list:hide();

function hide_logic()
    if sprite_list:isVisible() then
        sprite_list:hide();
    else
        sprite_list:show();
    end
end

function clear_logic()
    sprite_list.spriteId:setValue(0);
end

sprite_list.spriteId.onValueChange = function(widget, value)
    widget:setValue(value);
    sprite_list.spriteCreature:setOutfit({type = value});
end

sprite_list.cancelButton.onClick = function(widget)
    hide_logic();
    clear_logic();
end

sprite_list.okButton.onClick = function(widget)
    g_window.setClipboardText(sprite_list.spriteCreature:getOutfit().type)
    hide_logic();
    clear_logic();
end

sprite_list.clearButton.onClick = function(widget)
    clear_logic();
end

UI.Button("Show Outfit List", function()
    clear_logic()
    hide_logic();
end);
