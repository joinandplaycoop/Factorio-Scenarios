
local M = {};
  
local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end


local function SpawnPoint(n)
    -- degenerate spiral that just alternates on either side of the axis
    local n = scenario.config.riverworld.firstSpawnPoint + n
    local spacing = scenario.config.riverworld.spacing
    return PolarToCartesian({ r=spacing * n / 2, theta= (n * math.pi ) })
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

local function makeIndestructibleEntity(surface, args)
    local entity = surface.create_entity(args);
    if entity ~= nil then
        entity.destructible = false;
        entity.minable = false;
    end
    return entity;
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

local function GenerateRails(surface, chunkArea, railX, rails)
    if ChunkIntersects(chunkArea, rails) then
        local rect = ChunkIntersection( chunkArea, rails );
        local tiles = {};
        for y = rect.left_top.y, rect.right_bottom.y-1 do
            for x = rect.left_top.x, rect.right_bottom.x-1 do
                table.insert(tiles, {name = "grass-1", position = {x,y}});
            end
        end
        surface.set_tiles(tiles)

        for _, entity in pairs (surface.find_entities_filtered{area = rails}) do
            if entity and entity.valid then
                entity.destroy()  
            end
        end
        

        for y = rect.left_top.y, rect.right_bottom.y-1 do
            if math.fmod(y,2)==0 then
                local pt = { x=railX+2, y=y };                 
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+10, y=y };
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+18, y=y };
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+26, y=y };
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
            end
            if (math.fmod(y,30)==0) then
                local pt = { x=railX+1, y=y+1 };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+9, y=y+1 };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+15, y=y+1 };                 
                surface.create_entity({name="big-electric-pole", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+20, y=y };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE, direction=4})
                local pt = { x=railX+28, y=y };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE, direction=4})
            end
        end
    end
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

local function GenerateMoat(surface, chunkArea, moatRect)
    moatRect = ChunkIntersection( chunkArea, moatRect);
    local tiles = {};
    for y=moatRect.left_top.y, moatRect.right_bottom.y-1 do
        for x = moatRect.left_top.x, moatRect.right_bottom.x-1 do
            table.insert(tiles, {name = "water",position = {x,y}})
        end
    end
    surface.set_tiles(tiles)
end

local function GenerateWalls(surface, wallRect, railsRect, railsRect2, wantWater)
    local tiles = {};
    for y=wallRect.left_top.y, wallRect.right_bottom.y-1 do
        for x = wallRect.left_top.x, wallRect.right_bottom.x-1 do
            if scenario.config.riverworld.waterWalls then
                if not ChunkContains(railsRect, {x=x,y=y}) and not ChunkContains(railsRect2, {x=x,y=y} )then
                        table.insert(tiles, {name = "water",position = {x,y}})
                else
                        table.insert(tiles, {name = "grass-1",position = {x,y}})
                end
			elseif scenario.config.riverworld.stoneWalls then
                table.insert(tiles, {name = "grass-1",position = {x,y}})
			elseif wantWater then
                if not ChunkContains(railsRect, {x=x,y=y}) and not ChunkContains(railsRect2, {x=x,y=y} )then
                        table.insert(tiles, {name = "water",position = {x,y}})
                end
			else
		        if not ChunkContains(railsRect, {x=x,y=y}) and not ChunkContains(railsRect2, {x=x,y=y} )then
		                table.insert(tiles, {name = "out-of-map",position = {x,y}})
		        else
		                table.insert(tiles, {name = "grass-1",position = {x,y}})
		        end
			end
        end
    end
    surface.set_tiles(tiles)

    for _, entity in pairs (surface.find_entities_filtered{area = wallRect}) do
        entity.destroy()  
    end
    
	if scenario.config.riverworld.stoneWalls then
      for y=wallRect.left_top.y, wallRect.right_bottom.y-1 do
          for x = wallRect.left_top.x, wallRect.right_bottom.x-1 do
              if not ChunkContains(railsRect, {x=x,y=y}) and not ChunkContains(railsRect2, {x=x,y=y} )then
                  makeIndestructibleEntity(surface, {name="stone-wall", position={x, y}, force=MAIN_FORCE});
              end
          end
      end
	end
end

local function ReplaceLandWithWater(args)
    local surface = args.surface
    local area = args.area
    local spawnPos = args.spawnPos
    local extraBox = 3
    local extraArea = { left_top = { x = area.left_top.x - extraBox, y = area.left_top.y - extraBox},
            right_bottom = { x = area.right_bottom.x + extraBox, y = area.right_bottom.y + extraBox} }

    local spacing = scenario.config.riverworld.spacing
    local barrier = scenario.config.riverworld.barrier
    local w = (spacing - barrier) / 2
    
    -- don't touch chunks near the spawn
    local spawnRect = MakeRect( spawnPos.x-w/2, w, spawnPos.y-w/2, w);
    if ChunkIntersects( area, spawnRect ) then
        return
    end

    -- don't touch chunks near the silo
    local siloRect = MakeRect( -w/2, w, -w/2, w);
    if ChunkIntersects( area, siloRect ) then
        return
    end

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
            if land[z] ~= 1 then
                local tile = surface.get_tile(x, y);
                if (tile.name ~= "out-of-map") then
                    table.insert(tiles, {name = "water",position = {x,y}})
                end
            end
        end
    end
    surface.set_tiles(tiles)
    local force = game.forces[MAIN_FORCE];
    force.unchart_chunk( { x = area.left_top.x / 32, y = area.left_top.y / 32 }, surface )
    -- force.chart( surface, area );
end

function M.ChunkGenerated(event)
    local surface = event.surface
    
    if surface.name == GAME_SURFACE_NAME then
        local chunkArea = event.area
        local midPoint = {x = (chunkArea.left_top.x + chunkArea.right_bottom.x)/2,
                            y = (chunkArea.left_top.y + chunkArea.right_bottom.y)/2 }
                            
		-- Don't touch any chunks outside of freespace
        if math.abs(midPoint.x) > scenario.config.riverworld.freespace then
            return
        end

        -- to do this correctly, we should really get the *two* closest spawns 
        local spawnPos = NearestSpawn( global.allSpawns, midPoint)
        local dy = math.abs(midPoint.y - spawnPos.y)
        local spacing = scenario.config.riverworld.spacing
        local barrier = scenario.config.riverworld.barrier
        local w = chunkArea.right_bottom.x - chunkArea.left_top.x
        local y = spawnPos.y - spacing/2;
        local wallRect = MakeRect( chunkArea.left_top.x, w, y, barrier/2 )
        wallRect = ChunkIntersection(chunkArea, wallRect);
        y = y + barrier/2
        local waterRect = MakeRect( chunkArea.left_top.x, w, y, 8 )
        waterRect = ChunkIntersection(chunkArea, waterRect);

        local y = spawnPos.y + spacing/2 - barrier/2 - 8
        local waterRect2 = MakeRect( chunkArea.left_top.x, w, y, 8 )
        waterRect2 = ChunkIntersection(chunkArea, waterRect2)
        y = y + 8        
        local wallRect2 = MakeRect( chunkArea.left_top.x, w, y, barrier/2 )
        wallRect2 = ChunkIntersection(chunkArea, wallRect2)
        
                
        local railsRect = MakeRect( scenario.config.riverworld.rail, 32, -20000, 40000)
        railsRect = ChunkIntersection( chunkArea, railsRect)
                
        local railsRect2 = MakeRect( scenario.config.riverworld.rail2, 32, -20000, 40000)
        railsRect2 = ChunkIntersection( chunkArea, railsRect2)
        
        if dy < spacing and scenario.config.riverworld.moat ~= nil and scenario.config.riverworld.moatWidth>0 then
            local w = scenario.config.riverworld.moatWidth
            local h = spacing - barrier
            -- left moat
            local moatRect = MakeRect( spawnPos.x-scenario.config.riverworld.moat-w, w, spawnPos.y - h/2, h)        
            GenerateMoat(surface, chunkArea, moatRect)
            -- right moat
            local moatRect2 = MakeRect( spawnPos.x+scenario.config.riverworld.moat, w, spawnPos.y - h/2, h)        
            GenerateMoat(surface, chunkArea, moatRect2)
        end
        -- quick reject
        if (dy < spacing) then
            GenerateWalls( surface, wallRect, railsRect, railsRect2, false )
            GenerateWalls( surface, waterRect, railsRect, railsRect2, true )
            GenerateWalls( surface, waterRect2, railsRect, railsRect2, true )
            GenerateWalls( surface, wallRect2, railsRect, railsRect2, false )
        end

        GenerateRails( surface, chunkArea, scenario.config.riverworld.rail, railsRect)
        GenerateRails( surface, chunkArea, scenario.config.riverworld.rail2, railsRect2)
        if scenario.config.riverworld.seablock then
            Scheduler.schedule(game.tick+4, ReplaceLandWithWater, { surface= surface, area = chunkArea, spawnPos=spawnPos } )
        end
    end
end

function M.ConfigureGameSurface()
    if scenario.config.riverworld.freezeTime ~= nil then
        local surface = game.surfaces[GAME_SURFACE_NAME]
        surface.daytime = scenario.config.riverworld.freezeTime
        surface.freeze_daytime = true
    end 
end

return M;
