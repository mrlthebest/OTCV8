--[[
    Créditos - Victor Neox - Discord: victorneox

    Open Source Follow Attack Code.


    PS: não dou manutenção!!!

    PS2: ISSO É UM PROTOTIPO, ERROS E EXECUÇÕES IMPRECISAS IRãO OCORRER. TENHA ISSO EM MENTE.
]]



-- Edite apenas se souber o que está fazendo.
FollowAttack = {
    targetId = nil,
    -- Fila de obstaculos (escadas, jumps e portas) (filas seguem o padrao FIFO - FIRST IN FIRST OUT)
    obstaclesQueue = {},

    -- Delay até realizar o proximo walk (1sqm)
    obstacleWalkTime = 0,
    currentTargetId = nil,
    keyToClearTarget = 'Escape',

    -- Transcricao de PATH para Position Direction
    walkDirTable = {
        [0] = {'y', -1},
        [1] = {'x', 1},
        [2] = {'y', 1},
        [3] = {'x', -1},
    },

    -- Flags pro findPath
    flags = {
        ignoreNonPathable = true,
        precision = 0,
        ignoreCreatures = true
    },


    jumpSpell = {
        up = 'jump up',
        down = 'jump down'
    },

    --ID pra usar no SQM do custom ID
    defaultItem = 1111,
    --Spell para soltar no SQM do custom ID
    defaultSpell = 'skip',


    --[[
        ids custom para lugares diferenciados q sobe e desce... (buracos por ex)
        castSpell = true -> irá soltar o defaultSpell quando estiver em cima do sqm
        castSpell = false -> irá usar o defaultItem no SQM quando estiver <= 2 de distancia do SQM
    ]]
    customIds = {
        {
            id = 1948,
            castSpell = false
        },
        {
            id = 595,
            castSpell = false
        },
        {
            id = 1067,
            castSpell = false
        },
        {
            id = 1080,
            castSpell = false
        },
        {
            id = 386,
            castSpell = true
        },
    }
};


-- Retorna a distancia de uma posicao do player local
FollowAttack.distanceFromPlayer = function(position)
    local distx = math.abs(posx() - position.x);
    local disty = math.abs(posy() - position.y);

    return math.sqrt(distx * distx + disty * disty);
end

-- Anda para a direcao do primeiro indice do PATH recebido por parametro
FollowAttack.walkToPathDir = function(path)
    if (path) then
        g_game.walk(path[1], false);
    end
end

-- Faz a soma do direction ao playerPos, utilizando-a daquela tabela walkDirTable
FollowAttack.getDirection = function(playerPos, direction)
    local walkDir = FollowAttack.walkDirTable[direction];
    if (walkDir) then
        playerPos[walkDir[1]] = playerPos[walkDir[1]] + walkDir[2];
    end
    return playerPos;
end


FollowAttack.checkItemOnTile = function(tile, table)
    if (not tile) then return nil end;
    for _, item in ipairs(tile:getItems()) do
        local itemId = item:getId();
        print('item id')
        print(itemId)
        for _, itemSelected in ipairs(table) do
            if (itemId == itemSelected.id) then
                return itemSelected;
            end
        end
    end
    return nil;
end

-- 
--[[
    Função: Checa se a criatura foi até um custom ID

    scheduleTime = se vai segurar algum tempo antes de inserir as informacoes na fila de obstaculos, caso nao receba nada, assume 0

    Lógica: verifica se o piso do oldPos possui algum dos items na tabela customIds, caso sim, insere na fila de obstaculos

    Problema: Não pega se o target estiver em andar diferente do player, pois no NTO BR (Servidor testado), muitos buracos nao da pra ver quem esta em cima ou em baixo....
]]
FollowAttack.checkIfWentToCustomId = function(creature, newPos, oldPos, scheduleTime)
    local tile = g_map.getTile(oldPos);

    local customId = FollowAttack.checkItemOnTile(tile, FollowAttack.customIds);

    if (not customId) then return; end

    if (not scheduleTime) then
        scheduleTime = 0;
    end

    schedule(scheduleTime, function()
        if (oldPos.z == posz() or #FollowAttack.obstaclesQueue > 0) then
            table.insert(FollowAttack.obstaclesQueue, {
                oldPos = oldPos,
                newPos = newPos,
                tilePos = oldPos,
                customId = customId,
                tile = g_map.getTile(oldPos),
                isCustom = true
            });
        end
    end);
end
-- 
--[[
    Função: Checa se a criatura foi até uma escada

    scheduleTime = se vai segurar algum tempo antes de inserir as informacoes na fila de obstaculos, caso nao receba nada, assume 0

    Lógica: apenas insere na file de obstaculos, é mais simples, pois apenas precisa saber se a cor é 210 ou n, e isso ja é validado no onCreaturePositionChange
]]
FollowAttack.checkIfWentToStair = function(creature, newPos, oldPos, scheduleTime)

    if (g_map.getMinimapColor(oldPos) ~= 210) then return; end
    local tile = g_map.getTile(oldPos);

    if (tile:isPathable()) then return; end

    if (not scheduleTime) then
        scheduleTime = 0;
    end

    schedule(scheduleTime, function()
        if (oldPos.z == posz() or #FollowAttack.obstaclesQueue > 0) then
            table.insert(FollowAttack.obstaclesQueue, {
                oldPos = oldPos,
                newPos = newPos,
                tilePos = oldPos,
                tile = tile,
                isStair = true
            });
        end
    end);
end

--[[
    Função: Checa se a criatura foi até uma porta


    Lógica: Caso a distancia da newPos for menor que a oldPos e o eixo, entao significa que a porta esta pro lado do player, entao nao necessita entrar.
        Utiliza calculos simples para detectar onde é o SQM da porta a partir do oldPos e newPos, prevendo tambem os usos diagonais.
        Insere na fila de obstaculos caso todas as condições sejam satisfeitas.
]]

FollowAttack.checkIfWentToDoor = function(creature, newPos, oldPos)
    if (FollowAttack.obstaclesQueue[1] and FollowAttack.distanceFromPlayer(newPos) < FollowAttack.distanceFromPlayer(oldPos)) then return; end

    if (math.abs(newPos.x - oldPos.x) == 2 or math.abs(newPos.y - oldPos.y) == 2) then
            

        local doorPos = {
            z = oldPos.z
        }

        local directionX = oldPos.x - newPos.x
        local directionY = oldPos.y - newPos.y

        if math.abs(directionX) > math.abs(directionY) then

            if directionX > 0 then
                doorPos.x = newPos.x + 1
                doorPos.y = newPos.y
            else
                doorPos.x = newPos.x - 1
                doorPos.y = newPos.y
            end
        else
            if directionY > 0 then
                doorPos.x = newPos.x
                doorPos.y = newPos.y + 1
            else
                doorPos.x = newPos.x
                doorPos.y = newPos.y - 1
            end
        end

        local doorTile = g_map.getTile(doorPos);

        if (doorTile:isPathable() or doorTile:isWalkable()) then return; end

        table.insert(FollowAttack.obstaclesQueue, {
            newPos = newPos,
            tilePos = doorPos,
            tile = doorTile,
            isDoor = true,
        });
    end
end

--[[
    Função: Checa se a criatura foi até um jump


    Lógica: Caso haja uma escada próxima, então não é um jump.
        Verifica se é jump up ou jump down a partir das direcoes

        Caso newPos.z seja maior q oldPos.z então é um jump down, caso o newPos.y seja diferente de oldPos.y então é para o sul, se não, é para EAST (direita)

        Caso o newPos.z seja menor q o oldPos.z então é um jump up, caso o newPos.x seja diferente de oldPos.x entäo é para WEST (esquerda), se não, é para o NORTH

        Insere na fila de obstaculos caso todas as condições sejam satisfeitas.
]]

FollowAttack.checkifWentToJumpPos = function(creature, newPos, oldPos)
    local pos1 = { x = oldPos.x - 1, y = oldPos.y - 1 };
    local pos2 = { x = oldPos.x + 1, y = oldPos.y + 1 };

    local hasStair = nil
    for x = pos1.x, pos2.x do
        for y = pos1.y, pos2.y do
            local tilePos = { x = x, y = y, z = oldPos.z };
            if (g_map.getMinimapColor(tilePos) == 210) then
                hasStair = true;
                goto continue;
            end
        end
    end
    ::continue::

    if (hasStair) then return; end

    local spell = newPos.z > oldPos.z and FollowPlayer.jumpSpell.down or FollowPlayer.jumpSpell.up;
    local dir = creature:getDirection();

    if (newPos.z > oldPos.z) then
        spell = FollowPlayer.jumpSpell.down;
    end

    table.insert(FollowPlayer.obstaclesQueue, {
        oldPos = oldPos,
        oldTile = g_map.getTile(oldPos),
        spell = spell,
        dir = dir,
        isJump = true,
    });
end
--[[
    Lógica: caso a criatura seja a mesma que a settada no FollowAttack.currentTargetId, exista newPos e oldPos, e newPos.z e oldPos.z sejam iguals,
        então é um possivel candidato a PORTA... chama o método para validar.
]]
onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowAttack.mainMacro.isOff()) then return; end

    if creature:getId() == FollowAttack.currentTargetId and newPos and oldPos and oldPos.z == newPos.z then
        FollowAttack.checkIfWentToDoor(creature, newPos, oldPos);
    end
end);

--[[
    Lógica: caso a criatura seja a mesma que a settada no FollowAttack.currentTargetId, exista newPos e oldPos, newPos.z e oldPos.z sejam diferentes, e oldPos.z e a posicao do player local seja igual
        então é um possivel candidato a JUMP... chama o método para validar.
]]
onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowAttack.mainMacro.isOff()) then return; end

    if creature:getId() == FollowAttack.currentTargetId and newPos and oldPos and oldPos.z == posz() and oldPos.z ~= newPos.z then
        FollowAttack.checkifWentToJumpPos(creature, newPos, oldPos);
    end
end);

--[[
    Lógica: caso a criatura seja a mesma que a settada no FollowAttack.currentTargetId, exista oldPos, e a cor do oldPos seja 210
        então é um possivel candidato a ESCADA... chama o método para validar.
]]
onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowAttack.mainMacro.isOff()) then return; end

    if creature:getId() == FollowAttack.currentTargetId and oldPos and g_map.getMinimapColor(oldPos) == 210 then
        local scheduleTime = oldPos.z == posz() and 0 or 250;

        FollowAttack.checkIfWentToStair(creature, newPos, oldPos, scheduleTime);
    end
end);


--[[
    Lógica: caso a criatura seja a mesma que a settada no FollowAttack.currentTargetId, exista oldPos, a oldPos.z seja a mesma do player local e nao tenha newPos ou newPoz.z = oldPos.z
        então é um possivel candidato a CUSTOM ID... chama o método para validar.
]]
onCreaturePositionChange(function(creature, newPos, oldPos)
    if (FollowAttack.mainMacro.isOff()) then return; end
    if creature:getId() == FollowAttack.currentTargetId and oldPos and oldPos.z == posz() and (not newPos or oldPos.z ~= newPos.z) then
        FollowAttack.checkIfWentToCustomId(creature, newPos, oldPos);
    end
end);


--[[
    Lógica: Caso exista um elemento na fila de obstaculos, faz as seguintes validações:

    Se o primeiro obstaculo não é jump e a posição Z dele seja diferente do player local OU
    se o primeiro obstaculo é JUMP e a oldPos.z é diferente da posicao Z do player local

    Caso uma dessas condições seja satisfeita, então ela é retirada da fila de obstaculos, pois é impossivel executa-la
]]
macro(1, function()
    if (FollowAttack.mainMacro.isOff()) then return; end

    if (FollowAttack.obstaclesQueue[1] and ((not FollowAttack.obstaclesQueue[1].isJump and FollowAttack.obstaclesQueue[1].tilePos.z ~= posz()) or (FollowAttack.obstaclesQueue[1].isJump and FollowAttack.obstaclesQueue[1].oldPos.z ~= posz()))) then
        table.remove(FollowAttack.obstaclesQueue, 1);
    end
end);


----------------------------------------------INICIO - MACROS DE WALK----------------------------------------------------

--[[
    A partir daqui começam os macros para executar os obstaculos...

    Basicamente, vai ate o SQM setado dando USE (como se fosse um bugmap) e caso seja um jump, vira e da jump up/down

    Ao final da execução, é removido da fila de obstaculos para que o próximo seja executado.
]]
macro(100, function()
    if (FollowAttack.mainMacro.isOff()) then return; end

    if (FollowAttack.obstaclesQueue[1] and FollowAttack.obstaclesQueue[1].isStair) then
        local start = now
        local playerPos = pos();
        local walkingTile = FollowAttack.obstaclesQueue[1].tile;
        local walkingTilePos = FollowAttack.obstaclesQueue[1].tilePos;

        if (FollowAttack.distanceFromPlayer(walkingTilePos) < 2) then
            if (FollowAttack.obstacleWalkTime < now) then
                local nextFloor = g_map.getTile(walkingTilePos); -- workaround para caso o TILE descarregue, conseguir pegar os atributos ainda assim.
                if (nextFloor:isPathable()) then
                    FollowAttack.obstacleWalkTime = now + 250;
                    use(nextFloor:getTopUseThing());
                else
                    FollowAttack.obstacleWalkTime = now + 250;
                    FollowAttack.walkToPathDir(findPath(playerPos, walkingTilePos, 1, { ignoreCreatures = false, precision = 0, ignoreNonPathable = true }));
                end
                table.remove(FollowAttack.obstaclesQueue, 1);
                return 
            end
        end
        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        if (path == nil or #path <= 1) then
            if (path == nil) then
                use(walkingTile:getTopUseThing());
            end
            return
        end
        
        local tileToUse = playerPos;
        for i, value in ipairs(path) do
            if (i > 5) then break; end
            tileToUse = FollowAttack.getDirection(tileToUse, value);
        end
        tileToUse = g_map.getTile(tileToUse);
        if (tileToUse) then
            use(tileToUse:getTopUseThing());
        end
    end
end);


macro(1, function()
    if (FollowAttack.mainMacro.isOff()) then return; end

    if (FollowAttack.obstaclesQueue[1] and FollowAttack.obstaclesQueue[1].isDoor) then
        local playerPos = pos();
        local walkingTile = FollowAttack.obstaclesQueue[1].tile;
        local walkingTilePos = FollowAttack.obstaclesQueue[1].tilePos;
        if (table.compare(playerPos, FollowAttack.obstaclesQueue[1].newPos)) then
            FollowAttack.obstacleWalkTime = 0;
            table.remove(FollowAttack.obstaclesQueue, 1);
            local otherPath = findPath(playerPos, g_game.getAttackingCreature():getPosition(), 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });

            if (otherPath and #otherPath > 0) then
                g_game.walk(otherPath[1], false);
            end
            return;
        end
        
        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        if (path == nil or #path <= 1) then
            if (path == nil) then

                if (FollowAttack.obstacleWalkTime < now) then
                    g_game.use(walkingTile:getTopThing());
                    FollowAttack.obstacleWalkTime = now + 500;
                end
            end
            return
        end
    end
end);


macro(100, function()
    if (FollowAttack.mainMacro.isOff()) then return; end
    
    if (FollowAttack.obstaclesQueue[1] and FollowAttack.obstaclesQueue[1].isJump) then
        local playerPos = pos();
        local walkingTilePos = FollowAttack.obstaclesQueue[1].oldPos;
        local distance = FollowAttack.distanceFromPlayer(walkingTilePos);
        if (playerPos.z ~= walkingTilePos.z) then
            table.remove(FollowAttack.obstaclesQueue, 1);
        end

        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        
        if (distance == 0) then
            g_game.turn(FollowAttack.obstaclesQueue[1].dir);
            schedule(50, function()
                if (FollowAttack.obstaclesQueue[1]) then
                    say(FollowAttack.obstaclesQueue[1].spell);
                end
            end)
            return;
        elseif (distance < 2) then
            local nextFloor = g_map.getTile(walkingTilePos); -- workaround para caso o TILE descarregue, conseguir pegar os atributos ainda assim.
            if (FollowAttack.obstacleWalkTime < now) then
                FollowAttack.walkToPathDir(findPath(playerPos, walkingTilePos, 1, { ignoreCreatures = false, precision = 0, ignoreNonPathable = true }));
                FollowAttack.obstacleWalkTime = now + 500;
            end
            return 
        elseif (distance >= 2 and distance < 5 and path) then
            use(FollowAttack.obstaclesQueue[1].oldTile:getTopUseThing());
        elseif (path) then
            local tileToUse = playerPos;
            for i, value in ipairs(path) do
                if (i > 5) then break; end
                tileToUse = FollowAttack.getDirection(tileToUse, value);
            end
            tileToUse = g_map.getTile(tileToUse);
            if (tileToUse) then
                use(tileToUse:getTopUseThing());
            end
        end
    end
end);


macro(100, function()
    if (FollowAttack.mainMacro.isOff()) then return; end
    
    if (FollowAttack.obstaclesQueue[1] and FollowAttack.obstaclesQueue[1].isCustom) then
        local playerPos = pos();
        local walkingTile = FollowAttack.obstaclesQueue[1].tile;
        local walkingTilePos = FollowAttack.obstaclesQueue[1].tilePos;
        local distance = FollowAttack.distanceFromPlayer(walkingTilePos);
        if (playerPos.z ~= walkingTilePos.z) then
            table.remove(FollowAttack.obstaclesQueue, 1);
            return;
        end
        
        if (distance == 0) then
            if (FollowAttack.obstaclesQueue[1].customId.castSpell) then
                say(FollowAttack.defaultSpell);
                return;
            end
        elseif (distance < 2) then
            local item = findItem(FollowAttack.defaultItem)
            if (FollowAttack.obstaclesQueue[1].customId.castSpell or not item) then
                local nextFloor = g_map.getTile(walkingTilePos); -- workaround para caso o TILE descarregue, conseguir pegar os atributos ainda assim.
                if (FollowAttack.obstacleWalkTime < now) then
                    FollowAttack.walkToPathDir(findPath(playerPos, walkingTilePos, 1, { ignoreCreatures = false, precision = 0, ignoreNonPathable = true }));
                    FollowAttack.obstacleWalkTime = now + 500;
                end
            elseif (item) then
                g_game.useWith(item, walkingTile);
                table.remove(FollowAttack.obstaclesQueue, 1);
            end
            return 
        end

        local path = findPath(playerPos, walkingTilePos, 50, { ignoreNonPathable = true, precision = 0, ignoreCreatures = false });
        if (path == nil or #path <= 1) then
            if (path == nil) then
                use(walkingTile:getTopUseThing());
            end
            return
        end
        
        local tileToUse = playerPos;
        for i, value in ipairs(path) do
            if (i > 5) then break; end
            tileToUse = FollowAttack.getDirection(tileToUse, value);
        end
        tileToUse = g_map.getTile(tileToUse);
        if (tileToUse) then
            use(tileToUse:getTopUseThing());
        end
    end
end);

----------------------------------------------FIM - MACROS DE WALK----------------------------------------------------


----------------------------------------------INICIO - MACROS Principal FOLLOW----------------------------------------------------

--[[
    Basicamente corre atrás do target dando USE no caminho necessário...

    É uma alternativa ao follow do jogo que, infelizmente na maioria dos servidores tem um delay pra começar a andar

    MAS, é bem mais lento que o follow do jogo.

    eu gosto, porém não é o cenario perfeito.
]]

FollowAttack.mainMacro = macro(50, 'Follow Attack', function()
    if (not g_game.isAttacking()) then return; end

    local playerPos = pos();
    local target = g_game.getAttackingCreature();
    local targetPosition = target:getPosition();
    if (getDistanceBetween(playerPos, targetPosition) <= 1) then
        return;
    end
    local path = findPath(playerPos, targetPosition, 30, FollowAttack.flags);
    if (not path) then
        return;
    end

    g_game.setChaseMode(1)
    local tileToUse = playerPos;
    for i, value in ipairs(path) do
        if (i > 5) then break; end
        tileToUse = FollowAttack.getDirection(tileToUse, value);
    end
    tileToUse = g_map.getTile(tileToUse);
    if (tileToUse) then
        use(tileToUse:getTopUseThing());
    end
end);
----------------------------------------------FIM - MACROS Principal FOLLOW----------------------------------------------------


-- Atualização/Limpeza do target ID.
macro(1, function()
    local target = g_game.getAttackingCreature();

    if (target) then
        local targetId = target:getId();

        if (targetId ~= FollowAttack.currentTargetId) then
            FollowAttack.currentTargetId = targetId; 
        end
    end
end);

onKeyDown(function(key)
    if (key == 'Escape') then
        FollowAttack.currentTargetId = nil;
    end
end);