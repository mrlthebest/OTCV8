local reflectSpell = 'reflect' -- spell de reflect
local reflectCooldown = 2 -- em segundos

-- não altere abaixo.
--------------------------

function getFirstNumberInText(text)
    local n = nil
    if string.match(text, "%d+") then n = tonumber(string.match(text, "%d+")) end
    return n
end

local Reflect = {}
local hasReflect = true
local countDamage = 0
Reflect.macro = macro(100, "Reflect", function()
    if not hasReflect and (not Reflect.cdW or Reflect.cdW <= os.time()) then
        say(reflectSpell)
    end
end)

--00:19 You lose 4821 hitpoints due to an attack by sound shinobi.
onTextMessage(function(mode, text)
    if Reflect.macro.isOff() then 
        return
    end
    if not text:lower():find('you lose') then 
        return
    end
    countDamage = getFirstNumberInText(text)
    if countDamage > 50 and (not Reflect.timeReset or Reflect.timeReset <= os.time()) then
        hasReflect = false
        Reflect.timeReset = os.time() + 1
    end
end)

onTalk(function(name, level, mode, text, channelId, pos)
    if Reflect.macro.isOff() then return; end
    if name ~= player:getName() then return; end
    if text:lower() == reflectSpell then
        Reflect.cdW = os.time() + reflectCooldown
        hasReflect = true
    end
end)


