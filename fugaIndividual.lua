--[[ CONFIGURE AS FUGAS AQUI ]]--

FUGA = {
    -- example:     {spellToSay = 'izanagi', spellScreen = 'izanagi', hpEscape = 40, cdTotal = 60, cdAtivo = 3, key = 'F1'},
    {spellToSay = '', spellScreen = '', hpEscape = XX, cdTotal = XX, cdAtivo = XX, key = 'F1'},
    {spellToSay = '', spellScreen = '', hpEscape = XX, cdTotal = XX, cdAtivo = XX, key = 'F1'},
    {spellToSay = '', spellScreen = '', hpEscape = XX, cdTotal = XX, cdAtivo = XX, key = 'F1'},
}

local ESCAPE_PZ = true -- se estiver true, quando voce estiver com a vida necessaria para dar a fuga e estiver no pz vc vai deslogar, false o contrario.
local DELAY_RECONNECT = 10 -- so mude isso se o escape pz estiver true, é o cd para reconectar ** SEGUNDOS **

--NÃO EDITE NADA ABAIXO DAQUI
--------------------------------------------------------------------------

---------------------------[[ SCRIPT DE FUGA ]]---------------------------

local isKeyPressed = modules.corelib.g_keyboard.isKeyPressed;

FUGA.Script = macro(100, "Fuga", function()
    local selfHealth = hppercent();
    for index, value in ipairs(FUGA) do
        if ESCAPE_PZ and selfHealth <= value.hpEscape and isInPz() then
            modules.game_textmessage.displayGameMessage('Se voce continuar com o hp abaixo de ' .. PERCENTAGE_HPPERCENT .. ' em ' .. DELAY_RECONNECT*100 .. ' segundos voce ira deslogar.')
            schedule(DELAY_RECONNECT*100, function()
                modules.game_interface.tryLogout(false)
                modules.client_entergame.CharacterList.doLogin()
                delay(400)
            end)
            return;
        end
        if (value.activeCd and value.activeCd >= now) then return; end
        if (selfHealth <= value.hpEscape or isKeyPressed(value.key)) and (not value.totalCd or value.totalCd <= now) then
            say(value.spellToSay)
        end
    end
end);

--------------------[[ CHECANDO E DEFININDO OS CDS ]]--------------------

for index, value in ipairs(FUGA) do
    value.spellScreen = value.spellScreen:lower():trim();
end

onTalk(function(name, level, mode, text, channelId, pos)
    if name ~= player:getName() then return; end
    text = text:lower();
    for index, value in ipairs(FUGA) do
        if text == value.spellScreen then
            value.totalCd = now + (value.cdTotal * 1000) - 250;
            value.activeCd = now + (value.cdAtivo * 1000) - 250;
            break;
        end
    end
end);
