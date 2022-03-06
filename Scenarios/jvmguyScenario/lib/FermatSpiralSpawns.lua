-- spawns arranged in a spiral

local M = {};

function M.GetConfig()
    return scenario.config.fermatSpiralSpawns;
end

local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end

local function SpawnPoint(n)
    -- Vogel's model. see https://en.wikipedia.org/wiki/Fermat%27s_spiral
    local config = M.GetConfig()
    local n = config.firstSpawnPoint - 1 + n
    return PolarToCartesian({ r= config.spacing * math.sqrt(n), theta= (n * 137.508 * math.pi/180) })
end

  
local function CenterInChunk(a)
    return { x = a.x-math.fmod(a.x, 32)+16, y=a.y-math.fmod(a.y, 32)+16 }
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

function M.InitSpawnPoint(n)
   local a = FermatSpiralPoint(n)
   local spawn = CenterInChunk(a);
   spawn.createdFor = nil;
   spawn.used = false;
   spawn.seq = n
   table.insert(global.allSpawns, spawn)
end


local function toZCoord( area, position )
    local x = position.x
    local y = position.y
    return (x-area.left_top.x) + (y-area.left_top.y) * 65536;
end

local function fromZCoord( area, z )
    local x = z % 65536;
    local y = (z - x) / 65536;
    return { x=area.left_top.x+x, y=area.left_top.y+y }
end

-- for a seablock style terrain, but leave ore untouched
local function ReplaceLandWithWater(args)
    local config = M.GetConfig()
    local surface = args.surface
    local area = args.area
    local spawnPos = args.spawnPos
    local extraBox = 3
    local extraArea = { left_top = { x = area.left_top.x - extraBox, y = area.left_top.y - extraBox},
            right_bottom = { x = area.right_bottom.x + extraBox, y = area.right_bottom.y + extraBox} }

    

    -- don't touch chunks near the silo
    local w = SILO_RECT_SIZE;
    local siloRect = MakeRect( -w/2, w, -w/2, w);
    if ChunkIntersects( area, siloRect ) then
        return
    end

    local spacing = config.size
    local w = spacing;
    -- construct a set of tiles that we want to keep as land.
    -- We do that by using the entity bound box, expanded by an extraBox amount
        
    local land = {}
    local count = 0    
    for _, entity in pairs(surface.find_entities_filtered{area = extraArea}) do
            count = count + 1
        if entity.type == "tree" or entity.type == "fish" then
        -- ignore trees and fish
        -- entity.destroy();
        else
--            game.print(" entity " .. count .. " " .. entity.type .. ":" .. entity.name)
            local box = entity.bounding_box
            for x = math.floor(box.left_top.x-extraBox), math.ceil(box.right_bottom.x+extraBox)-1 do
                for y = math.floor(box.left_top.y-extraBox), math.ceil(box.right_bottom.y+extraBox)-1 do
                    local z = toZCoord( extraArea, { x=x, y=y } )
                    land[z] = 1
                end
            end
--             game.print("land: " .. z .. " " .. entity.position.x .. " " .. entity.position.y )
--            if count<10 then
--                game.print(" entity " .. count .. " " .. entity.type .. ":" .. entity.name)
--            end
        end
    end
    
    -- destroy trees and rocks, and replace tiles with water
    local tiles = {};
    for y=area.left_top.y, area.right_bottom.y-1 do
        for x = area.left_top.x, area.right_bottom.x-1 do
            local z = toZCoord( extraArea, { x=x, y=y })
            local dx = x - spawnPos.x;
            local dy = y - spawnPos.y;
            local dist = math.sqrt(dx*dx+dy*dy);
            if dist > spacing and land[z] ~= 1 then
                local tile = surface.get_tile(x, y);
                if (tile.name ~= "out-of-map") then
                    table.insert(tiles, {name = "water",position = {x,y}})
                end
            end
        end
    end
    SetTiles(surface, tiles, true)
    local force = game.forces[MAIN_FORCE];
    force.unchart_chunk( { x = area.left_top.x / 32, y = area.left_top.y / 32 }, surface )
    -- force.chart( surface, area );
end

local function CraterFunc(x, y, dist, spawnSize, craterSize)
--    return dist < craterSize;
    
    local f1 = (dist-spawnSize)/(craterSize-spawnSize);  -- range 0..1
    local f2 = math.fmod( 10*f1, 1);
    local c = math.cos(2*math.pi*f2); 
    return c*c > f1;
end


local function MakeSpawnCrater(chunkArea, surface, spawnPos)
    local config = M.GetConfig()
    

    -- don't touch chunks near the silo
    local w = SILO_RECT_SIZE;
    local siloRect = MakeRect( -w/2, w, -w/2, w);
    if ChunkIntersects( chunkArea, siloRect ) then
        return
    end

    local w = config.craterSize;
    local craterArea = MakeRect( spawnPos.x-w, 2*w, spawnPos.y-w, 2*w);
    if not ChunkIntersects(chunkArea, craterArea) then
        return
    end    

    -- construct a set of tiles that we want to keep as land.
    local tiles = {};
    for y=chunkArea.left_top.y, chunkArea.right_bottom.y-1 do
        for x = chunkArea.left_top.x, chunkArea.right_bottom.x-1 do
            local dx = x - spawnPos.x;
            local dy = y - spawnPos.y;
            local dist = math.sqrt(dx*dx+dy*dy);
            if (dist > config.size) and (dist < config.craterSize) and CraterFunc(x, y, dist, config.size, config.craterSize) then
                local tile = surface.get_tile(x, y);
                if (tile.name ~= "out-of-map") then
                    table.insert(tiles, {name = "deepwater",position = {x,y}})
                end
            end
        end
    end
    SetTiles(surface, tiles, true)
    
--    local force = game.forces[MAIN_FORCE];
--    force.unchart_chunk( { x = chunkArea.left_top.x / 32, y = chunkArea.left_top.y / 32 }, surface )
    -- force.chart( surface, chunkArea );
end

function M.InitSpawnPoint(n)
   local a = SpawnPoint(n)
   local spawn = CenterInChunk(a);
   spawn.surfaceName = GAME_SURFACE_NAME;
   spawn.createdFor = nil;
   spawn.used = false;
   spawn.seq = n
   global.allSpawns[n] = spawn;
end

function M.CreateSpawn(surface, spawnPos, chunkArea)
    local config = M.GetConfig()
    CreateCropOctagon(surface, spawnPos, chunkArea, config.land, config.trees, config.moat)
    if config.concrete then
        PaveWithConcrete( surface, chunkArea, spawnPos, config.land);
    end
--    local force = game.forces[MAIN_FORCE];
--    force.unchart_chunk( { x = chunkArea.left_top.x / 32, y = chunkArea.left_top.y / 32 }, surface )
--    force.chart(surface, chunkArea);
end

--function M.DoGenerateSpawnChunk(args) 
--        -- no longer called via scheduler? 
--        DoGenerateSpawnChunk(args.surface, args.area, args.spawnPos );
--end

-- This is the main function that creates the spawn area
-- Provides resources, land and a safe zone
-- 
-- Chunk generation seems to be problematic
--    We want to override the default vanilla generation for specific sections of the map.
--
--    We want to remove any enemy in the spawn area
--    Maybe generate an impact crater (replace land with water)
--    Call DoGenerateSpawnChunk (common code for all scenarios)

function M.ChunkGenerated(event)
    local config = M.GetConfig()
    local surface = event.surface
    
    if surface.name == GAME_SURFACE_NAME then
        -- Only take into account the nearest spawn when generating resources
        local chunkArea = event.area
        local midPoint = {x = (chunkArea.left_top.x + chunkArea.right_bottom.x)/2,
                            y = (chunkArea.left_top.y + chunkArea.right_bottom.y)/2 } 
        local spawnPos = NearestSpawn( global.allSpawns, midPoint)
        
        -- Common spawn generation code.
        if spawnPos ~= nil then
            -- order of arguments is not consistent
            ClearNearbyEnemies(surface, chunkArea, spawnPos);
            if config.crater then
                MakeSpawnCrater(chunkArea, surface, spawnPos);
            end
            -- careful... arguments for surface and chunkArea are swapped here.
            DoGenerateSpawnChunk(surface, chunkArea, spawnPos);
            AddSpawnTag(surface, chunkArea, spawnPos);
            
--            Scheduler.schedule(game.tick+40, M.DoGenerateSpawnChunk, { surface= surface, area = chunkArea, spawnPos=spawnPos } )
        end
        if config.seablock then
            Scheduler.schedule(game.tick+42, ReplaceLandWithWater, { surface= surface, area = chunkArea, spawnPos=spawnPos } )
        end
    end
end

function M.ConfigureGameSurface()
    local config = M.GetConfig()
    if config.freezeTime ~= nil then
        local surface = game.surfaces[GAME_SURFACE_NAME]
        surface.daytime = config.freezeTime
        surface.freeze_daytime = true
    end 
    if config.startingEvolution ~= nil then
        game.forces['enemy'].evolution_factor = config.startingEvolution;
    end 
end

return M;
