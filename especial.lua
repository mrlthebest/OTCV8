addTextEdit("Spells", storage.espSPELL or "SPELL1, SPELL2, SPELL 3", function(widget, text)
    storage.espSPELL = text
end)
especialSpells = strorage.espSPELL:split(','):lower()

addTextEdit("Hp", storage.espHP or "HP1, HP2, HP3", function(widget, text)
    storage.espHP = text
end)
especialHP = tonumber(strorage.espHP:split(','))


addTextEdit("CD", storage.espCEDE or "CD1, CD2, CD3", function(widget, text)
    storage.espCEDE = text
end)
especialCD = tonumber(strorage.espCEDE:split(','))


addTextEdit("Distance", storage.espDISTANCIA or "DIST1, DIST2, DIST3", function(widget, text)
    storage.espDISTANCIA = text
end)
especialDIST = tonumber(strorage.espDISTANCIA:split(','))

macro(100, "Especial", function()
    local target = g_game.getAttackingCreature()
        if target and target:isPlayer() then
            targetPos = target:getPosition()
            if targetPos then
                targetDistance = getDistanceBetween(pos(), targetPos)
                if targetDistance <= especialDIST and target:getHealthPercent() <= especialHP and
                    storage.espCD <= os.time() then
                        return say(especialSpells)
                    end
              end
        end
end)

if not storage.espCD then
    espCD = 0
end


onTalk(function(name, level, mode, text)
    if name ~= player:getName() then return end

    if text == especialSpells then
         storage.espCD = os.time() + especialCD
    end
end)
