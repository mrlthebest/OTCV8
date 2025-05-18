local defaultStyles = {
    ["Window"] = [[
Window < UIWindow
  font: verdana-11px-antialised
  size: 200 200
  opacity: 1
  color: #dfdfdf
  text-offset: 0 6
  text-align: top
  image-source: /images/ui/window
  image-border: 6
  image-border-top: 27
  padding-top: 36
  padding-left: 16
  padding-right: 16
  padding-bottom: 16

  $disabled:
    color: #dfdfdf88

  $dragging:
    opacity: 0.8

    ]],

    ["MainWindow"] = [[
MainWindow < Window
  anchors.centerIn: parent
    ]],

    ["Button"] = [[
Button < UIButton
  font: verdana-11px-antialised
  color: #dfdfdfff
  size: 106 23
  text-offset: 0 1
  image-source: /images/ui/button
  image-color: #dfdfdf
  image-clip: 0 0 22 23
  image-border: 3
  padding: 5 10 5 10
  opacity: 1.0
  change-cursor-image: true
  cursor: pointer
    ]],

    ["Label"] = [[
Label < UILabel
  font: verdana-11px-antialised
  color: #dfdfdf
    ]],

    ["TextEdit"] = [[
TextEdit < UITextEdit
  font: verdana-11px-antialised
  color: #272727
  size: 86 22
  text-offset: 0 4
  opacity: 1
  padding: 4
  image-source: /images/ui/textedit
  image-border: 1
  selection-color: #272727
  selection-background-color: #cccccc
  change-cursor-image: true
  $disabled:
    color: #27272788
    opacity: 0.5
    change-cursor-image: false
    ]],
    ["SpellEntry"] = [[

SpellEntry < Label
  background-color: alpha
  text-offset: 18 1
  focusable: true
  height: 16
  font: verdana-11px-rounded

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

  Button
    id: remove
    !text: tr('x')
    anchors.right: parent.right
    margin-right: 15
    text-offset: 1 0
    width: 15
    height: 15   

    ]],

    ['ComboBox'] = [[
ComboBox < UIComboBox
  font: verdana-11px-antialised
  color: #dfdfdf
  size: 91 23
  text-offset: 3 0
  text-align: left
  image-source: /images/ui/combobox_square
  image-border: 3
  image-border-right: 19
  image-clip: 0 0 91 23

  $hover !disabled:
    image-clip: 0 23 91 23

  $on:
    image-clip: 0 46 91 23

  $disabled:
    color: #dfdfdf88
    opacity: 0.8
  
  ]]

}
