
local M = {};

local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end

local function CenterInChunk(a)
    return { x = a.x-math.fmod(a.x, 32)+16, y=a.y-math.fmod(a.y, 32)+16 }
end

local function BunkerSpawnPoint(n)
    -- degenerate spiral that just alternates on either side of the axis
    local spacing = scenario.config.bunkerSpawns.bunkerSpacing
    local bunkerPoint =  PolarToCartesian({ r=spacing * n / 2, theta= (n * math.pi + math.pi/2 ) })
    bunkerPoint.y = bunkerPoint.y + scenario.config.bunkerSpawns.bunkerZoneStart + scenario.config.bunkerSpawns.bunkerZoneHeight/2
    return bunkerPoint;
end

local function FermatSpiralPoint(n)
    -- Vogel's model. see https://en.wikipedia.org/wiki/Fermat%27s_spiral
    local n = scenario.config.bunkerSpawns.firstSpawnPoint + n
    local spacing = scenario.config.bunkerSpawns.spacing
    return PolarToCartesian({ r=spacing * math.sqrt(n), theta= (n * 137.508 * math.pi/180) })
end

  
local function MakeRect( x, w, y, h )
    return { left_top = { x=x, y=y }, right_bottom = { x=x+w, y=y+h } }
end

local function ChunkIntersects( a, b )
    if a.left_top.x > b.right_bottom.x or b.left_top.x > a.right_bottom.x or
       a.left_top.y > b.right_bottom.y or b.left_top.y > a.right_bottom.y then
        return false;
    end
    return true;
end

local function ChunkIntersection( a, b )
        return { left_top = { x=math.max(a.left_top.x, b.left_top.x), y= math.max(a.left_top.y, b.left_top.y)}, 
                 right_bottom = { x=math.min(a.right_bottom.x, b.right_bottom.x), y= math.min(a.right_bottom.y, b.right_bottom.y)} }
end

local function ChunkContains( chunk, pt )
        return pt.x >= chunk.left_top.x and pt.x < chunk.right_bottom.x and
            pt.y >= chunk.left_top.y and pt.y < chunk.right_bottom.y;
end

function M.GetConfig()
    return scenario.config.bunkerSpawns;  
end

function M.InitSpawnPoint(n)
   local a = BunkerSpawnPoint(n)
   local spawn = CenterInChunk(a)
   spawn.createdFor = nil
   spawn.used = false
   spawn.seq = n
   local teleport = FermatSpiralPoint(n)
   spawn.teleport = CenterInChunk(teleport)
   table.insert(global.allSpawns, spawn)
end

function M.ConfigureGameSurface()
    local config = scenario.config.bunkerSpawns;
    if config.freezeTime ~= nil then
        local surface = game.surfaces[GAME_SURFACE_NAME];
        surface.daytime = config.freezeTime;
        surface.freeze_daytime = true;
    end
    if config.startingEvolution ~= nil then
        game.forces['enemy'].evolution_factor = config.startingEvolution;
    end 
end



local function GenerateBunker(surface, chunkArea, spawnPos, waterRadius, bunkerRadius)
    local tiles = {};
    for y=chunkArea.left_top.y, chunkArea.right_bottom.y-1 do
        for x = chunkArea.left_top.x, chunkArea.right_bottom.x-1 do
            local dx = x - spawnPos.x
            local dy = y - spawnPos.y
            local r = math.sqrt( dx*dx + dy*dy )
            if r > bunkerRadius then
                table.insert(tiles, {name = "out-of-map",position = {x,y}})
            end
        end
    end
    surface.set_tiles(tiles)
end

local function GenerateBunkerTeleport(surface, chunkArea, spawnPos)
    -- This creates the teleport in the bunker that takes you to the bunker entrance
    local teleportOffset = scenario.config.bunkerSpawns.teleport
    local teleportPos = { x = (spawnPos.x + teleportOffset.x), y = (spawnPos.y + teleportOffset.y) }
    if ChunkContains( chunkArea, teleportPos) then
        local dest = scenario.config.teleporter.siloTeleportPosition
        CreateTeleporter(surface, teleportPos, spawnPos.teleport)
    end
end

local function PaveWithConcrete( surface, chunkArea, spawnPos, landRadius)
    local tiles = {};
    for y=chunkArea.left_top.y, chunkArea.right_bottom.y-1 do
        for x = chunkArea.left_top.x, chunkArea.right_bottom.x-1 do
            local distVar1 = math.floor(math.max(math.abs(spawnPos.x - x), math.abs(spawnPos.y - y)))
            local distVar2 = math.floor(math.abs(spawnPos.x - x) + math.abs(spawnPos.y - y))
            local distVar = math.max(distVar1, distVar2 * 0.707);
            if distVar < landRadius then
                table.insert(tiles, {name = "concrete", position = {x,y}})
            end
        end
    end
    surface.set_tiles(tiles);
end

local function GenerateEntrance(surface, chunkArea, spawnPos)
    local config = scenario.config.bunkerSpawns
    local teleportPos = spawnPos.teleport
    -- remove trees in the immediate areas?
    for key, entity in pairs(surface.find_entities_filtered({area=chunkArea, type= "tree"})) do
        if ((teleportPos.x - entity.position.x)^2 + (teleportPos.y - entity.position.y)^2 < config.bunkerEntranceRadius^2) then
            entity.destroy()
        end
    end

    local tiles = {};
    for y=chunkArea.left_top.y, chunkArea.right_bottom.y-1 do
        for x = chunkArea.left_top.x, chunkArea.right_bottom.x-1 do
            local dx = x - teleportPos.x
            local dy = y - teleportPos.y
            local r = math.sqrt( dx*dx + dy*dy )
            if r < config.bunkerEntranceLandRadius then
                table.insert(tiles, {name = "grass-1", position ={x,y}})
            elseif r<config.bunkerEntranceRadius then 
                table.insert(tiles, {name = "water",position = {x,y}})
            end
        end
    end
    surface.set_tiles(tiles)
    
    ClearEnemies(surface, teleportPos, SAFE_AREA_BUNKER_ENTRANCE_TILE_DIST)
end

local function GenerateEntranceTeleport(surface, chunkArea, spawnPos)
    -- this makes the teleport at the bunker entrance
    -- this teleport takes you to the silo area
    local teleportPos = spawnPos.teleport
    if ChunkContains( chunkArea, teleportPos) then
        local teleportPlacement = { x = teleportPos.x + 2, y=teleportPos.y }
        CreateTeleporter(surface, teleportPlacement, nil)
    end
end

-- return the spawn from table t,  nearest position p
local function NearestTeleport( t, p )
  local candidates = {}
  for key, spawnPos in pairs(t) do
    if spawnPos ~= nil then
        spawnPos.key = key;
        spawnPos.dist = DistanceFromPoint(spawnPos.teleport, p)
        table.insert( candidates, spawnPos );
    end
  end
  table.sort (candidates, function (k1, k2) return k1.dist < k2.dist end )
  return candidates[1]
end


function M.ChunkGeneratedAfterRSO(event)
    SeparateSpawnsGenerateChunk(event)
    local surface = event.surface
    if surface.name == GAME_SURFACE_NAME then
        -- generate the bunker area
        local chunkArea = event.area
        local midPoint = {x = (chunkArea.left_top.x + chunkArea.right_bottom.x)/2,
                            y = (chunkArea.left_top.y + chunkArea.right_bottom.y)/2 }
        local config = scenario.config.bunkerSpawns
        local bunkerZone = MakeRect( -20000, 40000, config.bunkerZoneStart, config.bunkerZoneHeight)

--        game.print("generate chunk3 ".. midPoint.x .. "," .. midPoint.y
--             .. " " .. bunkerZone.left_top.x .. "," .. bunkerZone.left_top.y
--             .. " " .. bunkerZone.right_bottom.x .. "," .. bunkerZone.right_bottom.y)
        if ChunkIntersects(chunkArea, bunkerZone) then
            local spawnPos = NearestSpawn( global.allSpawns, midPoint)
            GenerateBunker( surface, chunkArea, spawnPos, config.waterRadius, config.bunkerRadius)
            GenerateBunkerTeleport( surface, chunkArea, spawnPos)
            PaveWithConcrete( surface, chunkArea, spawnPos, config.land);
        end
        
        local spawnPos = NearestTeleport( global.allSpawns, midPoint)
        local entranceRect = MakeRect( spawnPos.teleport.x-64, 128, spawnPos.teleport.y-64, 128 )
        
        if ChunkIntersects(chunkArea, entranceRect) then
            GenerateEntrance( surface, chunkArea, spawnPos)
            GenerateEntranceTeleport( surface, chunkArea, spawnPos)
        end
    end
end


return M;

