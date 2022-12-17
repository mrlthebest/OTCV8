addTextEdit("Spells", storage.fugaSPELL or "SPELL1, SPELL2, SPELL 3", function(widget, text)
    storage.fugaSPELL = text
end)
fugaSpells = strorage.fugaSPELL:split(','):lower()



addTextEdit("Hp", storage.fugaHP or "HP1, HP2, HP3", function(widget, text)
    storage.fugaHP = text
end)
fugaHP = tonumber(strorage.fugaHP:split(','))



addTextEdit("CD", storage.fugaCD or "CD1, CD2, CD3", function(widget, text)
    storage.fugaCD = text
end)
fugaCEDE = tonumber(strorage.fugaCD:split(','))




addTextEdit("Distance", storage.fugaDISTANCIA or "DIST1, DIST2, DIST3", function(widget, text)
    storage.fugaDISTANCIA = text
end)
fugaDIST = tonumber(strorage.fugaDISTANCIA:split(','))


local colorToMatch = {r = 0, g = 0, b = 0, a = 255}
spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch)

macro(100, "Fuga", function()
    for _, spec in ipairs(getSpectators()) do
        if spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) then
           attackerPos = spec:getPosition()
            if attackerPos then
                attackerDistance = getDistanceBetween(pos(), attackerPos) 
                if attackerDistance <= fugaDIST and hppercent() <= fugaHP and
                    (not fugaCD or fugaCD <= os.time()) then
                        return say(fugaSpells)
                    end
                end
            end
        end
end)



onTalk(function(name, level, mode, text)
    if name ~= player:getName() then return end
                        
    if text == fugaSpells then
         fugaCD = os.time() + fugaCEDE
    end
end)
