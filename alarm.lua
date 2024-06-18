local config = {
    -- [[ player alarm config ]] --
    playerScreen = false, -- se estiver true, vai apitar quando aparecer player na tela(que não for guild/party)
    playersName = '', -- se quiser só filtrar alguns players especificos, deixe false acima e adicione os players separando-os por ","

    --[[ monster alarm config ]] --
    monsterScreen = false, -- se estiver true, vai apitar quando aparecer monstro na tela
    monstersName = '', -- se quiser só filtrar alguns monstros especificos, deixe false acima e adicione os players separando-os por ","

    --[[ hp/life config ]] --
    alarmLife = false, -- se estiver true, vai apitar quando estiver X% de vida, porcentagem editavel a baixo
    lifePercent = 100,
    alarmMana = false, -- se estiver true, vai apitar quando estiver X% de vida, porcentagem editavel a baixo
    manaPercent = 100,

    --[[ others config ]] --
    enemyScreen = false, -- se estiver true, vai apitar quando aparecer enemy(blue emblem) na tela
    pkScreen = false, -- se estiver true, vai apitar quando aparecer pk na tela
    selfPk = false, -- se estiver true, vai apitar quando vc pegar pk
    playerAttack = false, -- se estiver true, vai apitar quando algum player te atacar(pode ocorrer bug dependendo da rev, se ocorrer não utilize a opção)

};

-- não edite nada abaixo
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function playAlarm()
    playSound("/sounds/alarm.ogg");
    g_window.flash();
end

if type(getCreatureByName) ~= 'function' then
    getCreatureByName = function(name)
        if not name then return nil; end
        name = name:lower();
        for i, spec in ipairs(g_map.getSpectators(player:getPosition())) do
            if spec:getName():lower() == name then
                return spec;
            end
        end
        return nil;
    end
end

local function findCreatures(creatureList)
    local toSearch = string.split(creatureList, ',');
    for _, possibleCreature in ipairs(toSearch) do
        if getCreatureByName(possibleCreature) then
            return true;
        end
    end
    return false;
end

local function hasPlayersScreen()
    for _, spec in ipairs(getSpectators()) do
        if spec ~= player and spec:isPlayer() and (spec:getEmblem() ~= 1 or not spec:isPartyMember()) then
            return true;
        end
    end
    return false;
end

local function hasMonstersScreen()
    for _, spec in ipairs(getSpectators()) do
        if spec:isMonster() then
            return true;
        end
    end
    return false;
end

local function pkScreen()
    for _, spec in ipairs(getSpectators()) do
        if spec ~= player and spec:isPlayer() and spec:getSkull() > 2 and (spec:getEmblem() ~= 1 or not spec:isPartyMember())  then
            return true;
        end
    end
    return false;
end

local colorToMatch = {r = 0, g = 0, b = 0, a = 255};
local function getAttacked()
    for _, spec in ipairs(getSpectators()) do
        if spec:isPlayer() and spec:isTimedSquareVisible() and table.equals(spec:getTimedSquareColor(), colorToMatch) then
            return true;
        end
    end
    return false;
end


macro(100, "Alarm", function()
    local alarmPlayersScreen = config.playerScreen;
    local playersList = config.playersName;
    local alarmMonstersScreen = config.monsterScreen;
    local monsterList = config.monstersName;
    local alarmPkScreen = config.pkScreen;
    local alarmSelfPk = config.selfPk;
    local alarmLife, lifePercent = config.alarmLife, config.lifePercent;
    local alarmMana, manaPercent = config.alarmMana, config.manaPercent;
    local alarmAttacked = config.playerAttack;
    local selfHealth, selfMana = hppercent(), manapercent();
    if isInPz() then return; end
    if (
        ((alarmPlayersScreen and hasPlayersScreen()) or (not alarmPlayersScreen and #playersList ~= 0 and findCreatures(playersList))) or
        ((alarmMonstersScreen and hasMonstersScreen()) or (not alarmMonstersScreen and #monsterList ~= 0 and findCreatures(monsterList))) or
        (alarmPkScreen and pkScreen()) or
        (alarmSelfPk and player:getSkull() >= 3) or
        (alarmLife and selfHealth <= lifePercent) or
        (alarmMana and selfMana <= manaPercent) or
        (alarmAttacked and getAttacked())
        ) then
        playAlarm();
        delay(6000);
    end
end);
