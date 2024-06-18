local pvpIcon = addIcon("pvpIcon",{text="Chase", switchable=false, moveable= true}, function()
    if g_game.isSafeFight() then
        g_game.setSafeFight()
    else
      g_game.setSafeFight(1)
    end
end);
pvpIcon:setSize({height=30,width=50});
pvpIcon.text:setFont('verdana-11px-rounded');

macro(50,function()
    if g_game.isSafeFight() then
        pvpIcon.text:setColoredText({"PVP\n","white","OFF","red"})
    else
        pvpIcon.text:setColoredText({"PVP\n","white","ON","green"})
    end
end);
