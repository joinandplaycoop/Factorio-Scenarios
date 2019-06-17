local M = {};

-- Use this for testing shared spawns...
-- local sharedSpawnExample1 = {openAccess=true,
--                             position={x=50,y=50},
--                             players={"ABC", "DEF"}}
-- local sharedSpawnExample2 = {openAccess=true,
--                             position={x=200,y=200},
--                             players={"ABC", "DEF"}}
-- local sharedSpawnExample3 = {openAccess=true,
--                             position={x=-200,y=-200},
--                             players={"A", "B", "C", "D"}}
-- global.sharedSpawns = {testName1=sharedSpawnExample1,
--                        testName2=sharedSpawnExample2,
--                        testName3=sharedSpawnExample3}

function M.init()
    if (global.sharedSpawns == nil) then
        global.sharedSpawns = {}
    end
    global.sharedSpawnCount = 0
end


function M.removePlayer(forPlayerName)
    -- Remove from shared spawn player slots (need to search all)
    for sskey,sharedSpawn in pairs(global.sharedSpawns) do
        local players = 0
        for key,playerName in pairs(sharedSpawn.players) do
            if playerName ~= nil then
                if (forPlayerName == playerName) then
                    logInfo(forPlayerName, "Removing player from shared spawn " .. sskey)
                    sharedSpawn.players[key] = nil;
                else
                    players = players + 1
                end
            end
        end
        if players == 0 then
            logInfo(forPlayerName, "Deleting shared spawn " .. sskey)
            global.sharedSpawns[sskey] = nil;
            global.allSpawns[sharedSpawn.seq].sharedKey = nil;
        end
    end
end



local function IsPlayerInSpawn(sharedSpawn, forPlayerName)
    for key,playerName in pairs(sharedSpawn.players) do
        if (forPlayerName == playerName) then
            return true
        end
    end
    return false
end

function M.addPlayerToSharedSpawn(sharedSpawn, forPlayerName)
    if not IsPlayerInSpawn(sharedSpawn, forPlayerName) then
        table.insert(sharedSpawn.players, forPlayerName);
    end
end

function M.findSharedSpawn(forPlayerName)
    for _,sharedSpawn in pairs(global.sharedSpawns) do
        if IsPlayerInSpawn(sharedSpawn, forPlayerName) then
            return sharedSpawn
        end
    end
    return nil;
end

function M.createNewSharedSpawn(player)
    local playerSpawn = global.playerSpawns[player.name];
    local sharedSpawn = M.findSharedSpawn(player.name);
    if sharedSpawn == nil then
        sharedSpawn = {openAccess=true,
                                    position={x=playerSpawn.x,y=playerSpawn.y},
                                    surfaceName=playerSpawn.surfaceName,
                                    seq=playerSpawn.seq,
                                    players={ player.name } }
        global.sharedSpawnCount = global.sharedSpawnCount + 1;
        local key = "shared spawn " .. global.sharedSpawnCount
        global.sharedSpawns[key] = sharedSpawn;
        if global.allSpawns[playerSpawn.seq] ~= nil then
            global.allSpawns[playerSpawn.seq].sharedKey = key;
        end
        logInfo("Create " .. key .. "for player " .. player.name )    
    end
    return sharedSpawn;                                   
end

function M.getOnlinePlayersAtSharedSpawn(sharedSpawn)
    if (sharedSpawn ~= nil) then
        local count = 0

        -- For each player in the shared spawn, check if online and add to count.
        for _,player in pairs(game.connected_players) do
            for _,playerName in pairs(sharedSpawn.players) do
                if (playerName == player.name) then
                    count = count + 1
                end
            end
        end
        return count
    else
        return 0
    end
end


-- Get the number of currently available shared spawns
-- This means the base owner has enabled access AND the number of online players
-- is below the threshold.
function M.getNumberOfAvailableSharedSpawns()
    local count = 0
    for _,sharedSpawn in pairs(global.sharedSpawns) do
        if (sharedSpawn.openAccess) then
            if (M.getOnlinePlayersAtSharedSpawn(sharedSpawn) < MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN) then
                count = count+1
            end
        end
    end

    return count
end

M.init();

return M;
