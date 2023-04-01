-- Nov 2016
--
-- Code that handles everything regarding giving each player a separate spawn
-- Includes the GUI stuff

--------------------------------------------------------------------------------
-- EVENT RELATED FUNCTIONS
--------------------------------------------------------------------------------

-- When a new player is created, present the spawn options
-- Assign them to the main force so they can communicate with the team
-- without shouting.
function SeparateSpawnsPlayerCreated(event)
    local player = game.players[event.player_index]
    player.force = MAIN_FORCE
    global.playerCooldowns[player.name] = {setRespawn=event.tick}
    DisplayWelcomeTextGui(player)
end


-- Check if the player has a different spawn point than the default one
-- Make sure to give the default starting items
function SeparateSpawnsPlayerRespawned(event)
    local player = game.players[event.player_index]
    SendPlayerToSpawn(player)
end

-- deprecated.
--function GenerateSpawnChunk( event, spawnPos)
--    local surface = event.surface
--    local chunkArea = event.area
--    DoGenerateSpawnChunk(surface, chunkArea, spawnPos);
--end

function DoGenerateSpawnChunk( surface, chunkArea, spawnPos)
    local config = spawnGenerator.GetConfig()
    
    local chunkAreaCenter = {x=chunkArea.left_top.x+(CHUNK_SIZE/2),
        y=chunkArea.left_top.y+(CHUNK_SIZE/2)}

    local warningArea = {left_top=
        {x=spawnPos.x-config.safe_area.warn_radius,
            y=spawnPos.y-config.safe_area.warn_radius},
        right_bottom=
        {x=spawnPos.x+config.safe_area.warn_radius,
            y=spawnPos.y+config.safe_area.warn_radius}}

    if CheckIfChunkIntersects(chunkArea,warningArea) then
        local config = spawnGenerator.GetConfig()
        local landArea = {left_top=
            {x=spawnPos.x-config.size,
                y=spawnPos.y-config.size},
            right_bottom=
            {x=spawnPos.x+config.size,
                y=spawnPos.y+config.size}}

        local safeArea = {left_top=
            {x=spawnPos.x-config.safe_area.safe_radius,
                y=spawnPos.y-config.safe_area.safe_radius},
            right_bottom=
            {x=spawnPos.x+config.safe_area.safe_radius,
                y=spawnPos.y+config.safe_area.safe_radius}}



        -- Make chunks near a spawn safe by removing enemies
        if CheckIfChunkIntersects(chunkArea,safeArea) then
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, force = "enemy"}) do
                entity.destroy()
            end

            -- Create a warning area with reduced enemies
        elseif CheckIfChunkIntersects(chunkArea,warningArea) then
            -- Remove all big and huge worms
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, name = "medium-worm-turret"}) do
                entity.destroy()
            end
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, name = "big-worm-turret"}) do
                entity.destroy()
            end

            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, name = "behemoth-worm-turret"}) do
                entity.destroy()
            end
        end

        -- Fill in any water to make sure we have guaranteed land mass at the spawn point.
        if CheckIfChunkIntersects(chunkArea,landArea) then

            -- remove trees in the immediate areas?
            for key, entity in pairs(surface.find_entities_filtered({area=chunkArea, type= "tree"})) do
                if ((spawnPos.x - entity.position.x)^2 + (spawnPos.y - entity.position.y)^2 < ENFORCE_LAND_AREA_TILE_DIST^2) then
                    entity.destroy()
                end
            end
            spawnGenerator.CreateSpawn(surface, spawnPos, chunkArea);

            GenerateStartingResources( surface, chunkArea, spawnPos);

            -- generate a teleport to the silo if enabled
            -- disabled for bunker spawns. need to refactor this, and move to spawn generator
            if scenario.config.teleporter.siloTeleportEnabled then
                local pos = { x=spawnPos.x+scenario.config.teleporter.spawnPosition.x, y=spawnPos.y+scenario.config.teleporter.spawnPosition.y }
                if CheckIfInChunk(pos.x, pos.y, chunkArea) then
                    spawnPos.spawnTeleportID = CreateTeleporter(surface, pos, "silo")
                end
            end
        end
    end
end

function DistanceFromPoint( spawnPos, p)
    local dx = spawnPos.x - p.x
    local dy = spawnPos.y - p.y
    local dist = math.sqrt( dx*dx + dy*dy)
    return dist
end

-- return the spawn from table t,  nearest position p
function NearestSpawns( t, p )
    local candidates = {}
    for key, spawnPos in pairs(t) do
        if spawnPos ~= nil then
            spawnPos.key = key;
            spawnPos.dist = DistanceFromPoint(spawnPos, p)
            table.insert( candidates, spawnPos );
        end
    end
    table.sort (candidates, function (k1, k2) return k1.dist < k2.dist end )
    return candidates
end

function NearestSpawn( t, p )
    local candidates = NearestSpawns(t,p);
    return candidates[1]
end


function GetUniqueSpawn(name)
    for _,spawn in pairs(global.allSpawns) do
        if spawn ~= nil and spawn.createdFor == name then
            return spawn
        end
    end
    return nil;
end

function RemovePlayer(player)

    -- TODO dump items into a chest.

    -- Clear out global variables for that player???
    if (global.playerSpawns[player.name] ~= nil) then
        global.playerSpawns[player.name] = nil;
    end

    local uniqueSpawn = GetUniqueSpawn(player.name);
    local sharedSpawn = sharedSpawns.findSharedSpawn(player.name);

    -- If a uniqueSpawn was created for the player, mark it as unused.
    if (uniqueSpawn ~= nil and sharedSpawn == nil) then
        if scenario.config.wipespawn.enabled then
            logAndBroadcast( player.name, player.name .. " base was reclaimed." )
            wipespawn.markForRemoval(uniqueSpawn)
            Scheduler.schedule(game.tick+700, MarkUnused, { playerName = player.name, spawn=uniqueSpawn } );
        else
            uniqueSpawn.used = false;
            uniqueSpawn.createdFor = nil;
            logAndBroadcast( player.name, player.name .. " base was freed up." )
        end
    end

    -- remove that player's cooldown setting
    if (global.playerCooldowns[player.name] ~= nil) then
        global.playerCooldowns[player.name] = nil;
    end

    sharedSpawns.removePlayer(player.name);

    -- Remove the character completely
    game.remove_offline_players({player});
end

function MarkUnused(args)
    local playerName = args.playerName
    local uniqueSpawn = args.spawn
    uniqueSpawn.used = false;
    uniqueSpawn.createdFor = nil;
    logInfo( playerName, playerName .. " spawn " .. uniqueSpawn.seq .. " marked as unused." )
end

-- Call this if a player leaves the game
-- Seems to be susceptible to causing desyncs...
function FindUnusedSpawns(event)
    local player = game.players[event.player_index]
    if (event.player_index>1 and player.online_time < MIN_ONLINE_TIME) then
        RemovePlayer(player);
    end
end


function GetNumberOfAvailableSoloSpawns()
    local count = 0

    for _,spawn in pairs(global.allSpawns) do
        if spawn ~= nil and not spawn.used then
            count = count+1
        end
    end

    return count
end

--------------------------------------------------------------------------------
-- NON-EVENT RELATED FUNCTIONS
-- These should be local functions where possible!
--------------------------------------------------------------------------------
function InitSpawnGlobalsAndForces()
    -- Contains an array of all player spawns
    -- A secondary array tracks whether the character will respawn there.
    if (global.allSpawns == nil) then
        global.allSpawns = {}
    end
    if (global.playerSpawns == nil) then
        global.playerSpawns = {}
    end

    -- InitSpawnPoint( 0, 0, 0);
    local config = spawnGenerator.GetConfig()
    for n = 1,config.numSpawnPoints do
        spawnGenerator.InitSpawnPoint( n )
        global.lastSpawn = n
    end
    -- another spawn for admin. admin gets the last spawn
    if config.extraSpawn ~= nil and config.extraSpawn >  config.numSpawnPoints then
        spawnGenerator.InitSpawnPoint( config.extraSpawn);
    end

    if (global.playerCooldowns == nil) then
        global.playerCooldowns = {}
    end

    local gameForce = game.create_force(MAIN_FORCE)

    gameForce.set_spawn_position(game.forces["player"].get_spawn_position(GAME_SURFACE_NAME), GAME_SURFACE_NAME)
    gameForce.worker_robots_storage_bonus=scenario.config.bots.worker_robots_storage_bonus;
    gameForce.worker_robots_speed_modifier=scenario.config.bots.worker_robots_speed_modifier;

    SetCeaseFireBetweenAllForces()
    AntiGriefing(gameForce)
    ApplyForceBonuses(gameForce)
    SetForceGhostTimeToLive(gameForce)
end

function AddSpawn()
    -- used as a command to expand in-game number of spawns
    -- if extraSpawn is configured, this does not work correctly
    local n = global.lastSpawn + 1;
    local config = spawnGenerator.GetConfig()
    if config.extraSpawn ~= nil and n == config.extraSpawn then
        n = n + 1
    end
    spawnGenerator.InitSpawnPoint( n )
    global.lastSpawn = n;
end

function CheckIfInChunk(x, y, chunkArea)
    if x>=chunkArea.left_top.x and x<chunkArea.right_bottom.x
        and y>=chunkArea.left_top.y and y<chunkArea.right_bottom.y then
        return true;
    end
    return false;
end

local function CreateItems( surface, tiles, itemName, contents, props )
    for _, tile in pairs(tiles) do
        local chest = surface.create_entity({name=itemName, position=tile, force=MAIN_FORCE})
        if contents~=nil then
            for _,item in pairs(contents) do
                chest.insert(item)
            end
        end
        if props~=nil then
            for name,prop in pairs(props) do
                chest[name] = prop
            end
        end
    end
end

local mixedResources = { "iron-ore", "copper-ore", "coal", "iron-ore", "copper-ore", "coal", "stone" }

local function CreateResources( surface, tiles, startAmount, resourceName, mixedOres )
    for _, tile in pairs(tiles) do
        local realResourceName = resourceName
        if mixedOres and math.random() < 0.2 then
            local r = math.random(#mixedResources);
            realResourceName = mixedResources[r];
        end
        surface.create_entity({name=realResourceName, amount=startAmount, position=tile})
    end
end

function GenerateStartingResources(surface, chunkArea, spawnPos)
    --local surface = player.surface
    local pos = { x=spawnPos.x, y=spawnPos.y }
    local config = spawnGenerator.GetConfig()
    for _, res in pairs( config.resources ) do
        -- resource may specify dx,dy or x,y relative to spawn
        if res.x ~= nil then
            pos.x = spawnPos.x + res.x
        end
        if res.y ~= nil then
            pos.y = spawnPos.y + res.y
        end
        if res.dx ~= nil then
            pos.x = pos.x + res.dx
        end
        if res.dy ~= nil then
            pos.y = pos.y + res.dy
        end
        local tiles = TilesInShape( chunkArea, pos, res.shape, res.height, res.width);
        if (res.type ~= nil) then
            CreateResources( surface, tiles, res.amount, res.type, res.mixedOres );
        elseif (res.name ~= nil) then
            CreateItems( surface, tiles, res.name, res.contents, res.props );
        end
    end
end

function DoesPlayerHaveCustomSpawn(player)
    for name,spawnPos in pairs(global.playerSpawns) do
        if (player.name == name and spawnPos ~= nil) then
            return true
        end
    end
    return false
end

function ChangePlayerSpawn(player, pos, surfaceName, seq)
    if global.playerSpawns[player.name] == nil then
        global.playerSpawns[player.name] = { x=pos.x, y=pos.y, surface=surfaceName, seq=seq }
    else
        global.playerSpawns[player.name].x = pos.x;
        global.playerSpawns[player.name].y = pos.y;
        global.playerSpawns[player.name].surface = surfaceName;
        global.playerSpawns[player.name].seq = seq;
    end
end

function TeleportPlayerWithDelay(args)
    Scheduler.schedule(game.tick+args.delay, TeleportPlayerCallback,  args)
end

function TeleportPlayerCallback(args)
    args.player.teleport(args.spawn, args.surface)
end


function SendPlayerToNewSpawnAndCreateIt(player, spawn)
    -- Send the player to that position
    if spawn == nil then
        DebugPrint("SendPlayerToNewSpawnAndCreateIt: error. spawn is nil")
        spawn = { x = 0, y = 0 }
    end
    ChartArea(player.force, spawn, 8)
    if spawn.teleport then
        ChartArea(player.force, spawn.teleport, 8)
    end

    TeleportPlayerWithDelay({ player=player, spawn=spawn, surface= game.surfaces[GAME_SURFACE_NAME], delay=5*TICKS_PER_SECOND })
end

function SendPlayerToSpawn(player)
    local surface = game.surfaces[GAME_SURFACE_NAME];
    local spawn;
    if (DoesPlayerHaveCustomSpawn(player)) then
        spawn = global.playerSpawns[player.name]
    else
        spawn = game.forces[MAIN_FORCE].get_spawn_position(GAME_SURFACE_NAME)
    end
    player.teleport(spawn, surface)
end

function GetClosestUniqueSpawn(surface, position)
    if surface.name == GAME_SURFACE_NAME then
        return NearestSpawn( global.allSpawns, position);
    end
    return nil;
end


