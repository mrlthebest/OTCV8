local chaseIcon = addIcon("chaseIcon",{text="Chase",switchable=false,moveable=true}, function()
    if g_game.getChaseMode() == 1 then
        g_game.setChaseMode(0)
    else
        g_game.setChaseMode(1)
    end
end);
chaseIcon:setSize({height=30,width=50})
chaseIcon.text:setFont('verdana-11px-rounded')


macro(50,function()
    if g_game.getChaseMode() == 1 then
        chaseIcon.text:setColoredText({"Chase\n","white","On","green"})
    else
        chaseIcon.text:setColoredText({"Chase\n","white","OFF","red"})
    end
end);
