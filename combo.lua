addTextEdit("Magias", storage.ComboText or "Magias", function(widget, text) 
    storage.ComboText = text
end)


addTextEdit("Tempo", storage.ComboTempo or "Tempo", function(widget, text) 
    storage.ComboTempo = text
end)

local combo = storage.ComboText:split(',')
local tempo = tonumber(storage.ComboTempo:split(','))

onTalk(function(name, level, mode, text)
    if name ~= player:getName() then return end

    text = text:lower()
    if text == combo then
       storage.ComcoCD = os.time() + tempo
    end
end)

if (not storage.ComboCD) then
    storage.ComboCD= 0;
  end


macro(100, "Combo", function()
    if not g_game.isAttacking() then return end
        for _, spell in ipairs(combo) do
            if storage.ComboCD <= os.time() then
         say(spell)
    end
   end
end)
