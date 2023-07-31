--[[
    Script de Potion
    by mrlthebest.
    28/07/2023
]]--

local s = {};

macro(100, "Potion", function()
    local configPotion = storage.potion:split(",");
    if (hppercent() <= tonumber(configPotion[2]) or manapercent() <= tonumber(configPotion[3])) and (not s.cdW or s.cdW <= now) then
        useWith(tonumber(configPotion[1]), player);
    end
end);

onUseWith(function(pos, itemId, target, subType)
    local configPotion = storage.potion:split(",");
    if itemId == tonumber(configPotion[1]) then
        s.cdW = now + tonumber(configPotion[4]);
    end
end);

addTextEdit("Config Potion", storage.potion or "ID, HP, MP, CD", function(widget, text)
    if text and #text:split(",") < 4 then
        return warn("por favor, inserir os valores na ordem (ID, HP, MP, CD)");
    end
    storage.potion = text;
end);
