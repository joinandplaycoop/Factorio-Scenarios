-- Code to wipe a spawn when a player abandons it.


local jvmHeap = require("jvm-chunkheap");

local M = {};

local config = {
    -- chunks touched by a player's presence last for a short while if nothing is built on it, there are no resources, and no enemies
    chunkTimeoutTicks = 60 * TICKS_PER_MINUTE,
    
    cleanupIntervalTicks = 1 * TICKS_PER_MINUTE,
    
    -- the most we will examine and try to remove in a single cleanup
    maxGarbage = 400
}

local MAXX=4096     -- max chunk coord x/y. tile coord is 32x
local MAXY=4096
local MAXY2 = 2*MAXY


global.wipespawn = {
    -- map of all chunks
    map = {},
    
    -- list of chunks in LRU order 
    lru = jvmHeap.new(nil);
    
    playerRefreshIndex = 1,
    forceRemovalTime = -1,
}

-- chunk status
local CS_NORMAL=0   
local CS_PERM=1     -- permanent chunk. will not be collected
local CS_FORCE=2    -- forced removal. will definitely be collected


local function addToLRU(mapEntry, expiry)
    if mapEntry.status == CS_FORCE then
        mapEntry.lruTime = 0;
    end
    local lru = global.wipespawn.lru;
    mapEntry.inLRU = true
    mapEntry.lruTime = math.max(mapEntry.lruTime, expiry);
    jvmHeap.insert( lru, mapEntry )
end

local function removeFromLRU(mapEntry)
    local lru = global.wipespawn.lru;
    jvmHeap.remove( lru, mapEntry )
    mapEntry.inLRU = false
end

local function zIndexFromChunkPos(chunkPos)
    return (chunkPos.x + MAXX) + (chunkPos.y + MAXY) * MAXY2
end

local function getMapEntry(chunkPos)
    local zindex = zIndexFromChunkPos(chunkPos);
    return global.wipespawn.map[zindex]
end

local function newMapEntry(chunkPos)
    local zindex = zIndexFromChunkPos(chunkPos);
    local result = {
        id = zindex,
        x=chunkPos.x,
        y=chunkPos.y,
        -- status is CS_PERM for chunks that are persistent and not in the LRU
        status=CS_NORMAL,
        inLRU = false,
        lruTime=0,
        index=0,    -- used by the heap
    }
    global.wipespawn.map[zindex] = result
    return result
end
 
local function tileToChunk(pos)
    return { x=math.floor(pos.x/32), y=math.floor(pos.y/32) }
end

local function chunkToTile(pos)
    return { x=32*pos.x, y= 32*pos.y }
end

local function markChunk( chunkPosition, expiry )
    local mapEntry = getMapEntry(chunkPosition)
    if mapEntry ~= nil then
        if mapEntry.inLRU then
            removeFromLRU(mapEntry)
        end
        if mapEntry.status ~= CS_PERM then 
            addToLRU(mapEntry, expiry)
        end
    end
end

local function markPermanent( center, chunkRadius )
    for x=-chunkRadius,chunkRadius do
        for y=-chunkRadius, chunkRadius do
            local chunkPosition = { x=center.x+x, y=center.y+y }
            local mapEntry = getMapEntry(chunkPosition);
            if mapEntry == nil then
                mapEntry = newMapEntry(chunkPosition);
            end
            mapEntry.status = CS_PERM;
            if mapEntry.inLRU then
                removeFromLRU(mapEntry);
            end
        end
    end
end

local function markForForcedCollection( center, chunkRadius )
    for x=-chunkRadius,chunkRadius do
        for y=-chunkRadius, chunkRadius do
            local chunkPosition = { x=center.x+x, y=center.y+y }
            -- game.print("mark for forced collection: " .. chunkPosition.x .. "," .. chunkPosition.y)
            local mapEntry = getMapEntry(chunkPosition);
            if mapEntry == nil then
                mapEntry = newMapEntry(chunkPosition);
            end
            if mapEntry.inLRU then
                removeFromLRU(mapEntry);
            end
            mapEntry.status = CS_FORCE;
            addToLRU(mapEntry, 0);
        end
    end
end

-- Remove all garbage chunks at same time to reduce impact to FPS/UPS
local function removeGarbageChunks()
    local time = game.tick
    local count  = 0
    local removed = 0
    local map = global.wipespawn.map
    local lru = global.wipespawn.lru
    while true do
        local mapEntry = jvmHeap.head(lru);
        if mapEntry == nil or mapEntry.lruTime > time or count > config.maxGarbage then
            break
        end
        if mapEntry.inLRU then
            removeFromLRU(mapEntry)
            if ( mapEntry.status == CS_FORCE ) then
                -- game.print("removed chunk: " .. mapEntry.x .. "," .. mapEntry.y .. " status; " .. mapEntry.status )
                game.surfaces[GAME_SURFACE_NAME].delete_chunk(mapEntry)
                removed = removed + 1
            end
        else
            -- game.print("removeGarbage: not in LRU! " .. mapEntry.x .. "," .. mapEntry.y )
            break
        end
        count = count + 1
    end
end



function M.init() 
    markPermanent( {x=0,y=0}, 10 );
end

function M.onTick()
--    -- Catch force remove flag
    if (game.tick == global.wipespawn.forceRemovalTime+60) then
        logAndBroadcast("", "Map cleanup in 10 seconds...")
    end
    if (game.tick == global.wipespawn.forceRemovalTime+660) then
        removeGarbageChunks()
        logAndBroadcast("", "Map cleanup done...")
    end
         
end

function M.collect()
    removeGarbageChunks()
end

function M.onChunkGenerated(event)
    if event.surface.name ~= GAME_SURFACE_NAME then
        return
    end 
    local pos = event.area.left_top
    local chunkPos = tileToChunk(pos);
    -- game.print("onChunkGenerated: " .. chunkPos.x .. "," .. chunkPos.y)
    local mapEntry = getMapEntry(chunkPos);
    if mapEntry == nil then
        mapEntry = newMapEntry(chunkPos);
    end
    mapEntry.status = CS_NORMAL;
end

function M.markForRemoval(pos)
    markForForcedCollection( tileToChunk(pos), 5)
    global.wipespawn.forceRemovalTime = game.tick
end

function M.forceCollectSpawn(spawnNumber)
    M.markForRemoval(global.allSpawns[spawnNumber])
end

function M.status(x,y)
    local chunkPos = tileToChunk({ x=x, y=y })
    local mapEntry = getMapEntry(chunkPos);
    if mapEntry then
        local inLRU = "n"
        if mapEntry.inLRU then inLRU = "y" end
        local timeToLive = mapEntry.lruTime - game.tick
        local lru = global.wipespawn.lru
        game.print("chunk " .. mapEntry.x .. "," .. mapEntry.y
         .. " status: " .. mapEntry.status
         .. " inLRU: " .. inLRU
         .. " ttl: " .. timeToLive
         .. " lruSize: " .. jvmHeap.size(lru)
         );
     else
        game.print("not in map")     
     end 
end

if scenario.config.wipespawn.enabled then
        Event.register(defines.events.on_tick, M.onTick)
        Event.register(-1, M.init)
end

return M;
