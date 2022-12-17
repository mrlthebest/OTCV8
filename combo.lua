addTextEdit("Magias", storage.comboSPELL or "MAGIA1, MAGIA2, MAGIA3", function(widget, text)
    storage.comboSPELL = text
end)
comboSpells = strorage.comboSPELL:split(','):lower()


addTextEdit("CD", storage.comboCD or "CD1, CD2, CD3", function(widget, text)
    storage.comboCD = text
end)
comboCEDE = tonumber(strorage.comboCD:split(','))


addTextEdit("Dist", storage.comboDISTANCIA or "DIST1, DIST2, DIST3", function(widget, text)
    storage.comboDISTANCIA = text
end)
comboDIST = tonumber(strorage.comboDISTANCIA:split(','))

    
macro(100, 'combo', function()
    local target = g_game.getAttackingCreature()
        if not g_game.isAttacking() then return end
          if target then   
            targetPos = target:getPosition()
            if targetPos then
                distanceToTarget = getDistanceBetween(pos(), targetPos)
                if distanteToTarget <= comboDIST and (not comboCD or comboCD < now) then
                    say(comboSpells)
                end
            end
        end
    end
end)


onTalk(function(name, level, mode, text)
    if name ~= player:getName() then return end
                        
text = text:lower()
    if text == comboSpells then
         comboCD = now + comboCEDE
    end
end)
