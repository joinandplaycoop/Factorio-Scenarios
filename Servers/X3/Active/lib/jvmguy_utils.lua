
if global.portal == nil then
    global.portal={}
end

function distFunc( cx, cy, ix, iy)
    local distVar1 = math.floor(math.max(math.abs(cx - ix), math.abs(cy - iy)))
    local distVar2 = math.floor(math.abs(cx - ix) + math.abs(cy - iy))
    local distVar = math.max(distVar1, distVar2 * 0.707);
    return distVar
end

function rangemap( r, from1, from2, to1, to2)
    local rr = (r-from1)/(from2-from1)
    return rr*(to2-to1) + to1;
end

function PaveWithConcrete( surface, chunkArea, spawnPos, landRadius)
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
    SetTiles(surface, tiles, true);
end

local function MakeRect( x, w, y, h )
    return { left_top = { x=x, y=y }, right_bottom = { x=x+w, y=y+h } }
end

local function ChunkContains( chunk, pt )
        return pt.x >= chunk.left_top.x and pt.x < chunk.right_bottom.x and
            pt.y >= chunk.left_top.y and pt.y < chunk.right_bottom.y;
end

local function ChunkIntersects( a, b )
    if a.left_top.x > b.right_bottom.x or b.left_top.x > a.right_bottom.x or
       a.left_top.y > b.right_bottom.y or b.left_top.y > a.right_bottom.y then
        return false;
    end
    return true;
end

function SetTiles(surface, tiles, correct)
    if #tiles >0 then
        global.customChunk = true;
        surface.set_tiles(tiles, correct)
    end
end


function AddSpawnTag(surface, chunkArea, spawnPos)
    if ChunkContains(chunkArea, spawnPos) then
        local force = game.forces[MAIN_FORCE];
        force.add_chart_tag(surface, { position=spawnPos, text="Spawn ".. spawnPos.seq })
    end
end

-- Enforce a square of land, with a tree border
-- this is equivalent to the CreateCropCircle code
function CreateCropOctagon(surface, centerPos, chunkArea, landRadius, treeWidth, moatWidth)
    local config = spawnGenerator.GetConfig()

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x-1,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y-1,1 do

            local distVar = distFunc( centerPos.x, centerPos.y, i, j);

            -- Fill in all unexpected water in a circle
            if (distVar < landRadius) then
                if (surface.get_tile(i,j).collides_with("water-tile") or ENABLE_SPAWN_FORCE_GRASS) then
                    table.insert(dirtTiles, {name = "grass-1", position ={i,j}})
                end
            end

            -- Create a ring
            if ((distVar < landRadius) and 
                (distVar > landRadius-treeWidth)) then
                if math.random() < SPAWN_TREE_DENSITY then
                  surface.create_entity({name="tree-01", amount=1, position={i, j}})
                end
            end
        end
    end
    SetTiles(surface, dirtTiles, true)

    -- create the moat
    if (moatWidth>0) then
        local waterTiles = {}
        for i=chunkArea.left_top.x,chunkArea.right_bottom.x-1,1 do
            for j=chunkArea.left_top.y,chunkArea.right_bottom.y-1,1 do
    
                local distVar = distFunc( centerPos.x, centerPos.y, i, j);
    
                -- Create a water ring
                if ((distVar > landRadius) and (distVar <= landRadius+moatWidth)) then
                    table.insert(waterTiles, {name = "water", position ={i,j}})
                end
            end
        end
        SetTiles( surface, waterTiles, true);
    end
    
    local water = config.water;
    if water ~= nil then
        local waterTiles = {}   
        local shapeTiles = TilesInShape( chunkArea, {x=centerPos.x + water.x, y=centerPos.y + water.y }, water.shape, water.height, water.width );
        for _,tile in pairs(shapeTiles) do
            table.insert(waterTiles, {name = "water", position ={tile.x,tile.y}})
        end
        setTiles(surface, waterTiles, true);
    end

    -- remove resources in the immediate areas?
    for key, entity in pairs(surface.find_entities_filtered({area=chunkArea, type= "resource"})) do
        if entity and entity.valid then
            local distVar = distFunc( centerPos.x, centerPos.y, entity.position.x, entity.position.y);
            if distVar < landRadius+moatWidth then
                entity.destroy()
            end
        end
    end
    -- remove cliffs in the immediate areas?
    for key, entity in pairs(surface.find_entities_filtered({area=chunkArea, type= "cliff"})) do
        --Destroying some cliffs can cause a chain-reaction.  Validate inputs.
        if entity and entity.valid then
            local distVar = distFunc( centerPos.x, centerPos.y, entity.position.x, entity.position.y);
            if distVar < landRadius+moatWidth then
                entity.destroy()
            end
        end
    end
end

function CreateWaterStrip(surface, spawnPos, width, height)
    local waterTiles = {}
    for j=1,height do
        for i=1,width do
            table.insert(waterTiles, {name = "water", position ={spawnPos.x+i-1,spawnPos.y+j-1}});
        end
    end
    -- DebugPrint("Setting water tiles in this chunk! " .. chunkArea.left_top.x .. "," .. chunkArea.left_top.y)
    setTiles(surface, waterTiles, true);
end

function CreateTeleporter(surface, teleporterPosition, usage)
    local car = surface.create_entity{name="car", position=teleporterPosition, force=MAIN_FORCE }
    car.destructible=false;
    car.minable=false;
    for _,item in pairs(scenario.config.teleporter.startItems) do
        car.insert(item);
    end
    table.insert(global.portal, { unit_number = car.unit_number, usage = usage });
    return car.unit_number
end

function FindTeleportByID( surface, number )
    for _, entity in pairs(surface.find_entities_filtered{ name="car" }) do
        if (entity ~= nil) and (entity.unit_number == number) then
            return { x=entity.position.x - 2, y=entity.position.y, surface=surface }
        end
    end
    return nil
end

function AssignedTeleportDest( usage, playerName )
    local surface = game.surfaces[GAME_SURFACE_NAME];
    local spawnSeq = global.playerSpawns[playerName].seq;
    local spawn = global.allSpawns[spawnSeq];
    if usage == "silo" then
        return FindTeleportByID( surface, global.siloTeleportID)
    end
    if usage == "spawn" then
        return FindTeleportByID( surface, spawn.spawnTeleportID)
    end
    if usage == "bunker" then
        return FindTeleportByID( surface, spawn.bunkerTeleportID)
    end
    if usage == "bunker entrance" then
        return FindTeleportByID( surface, spawn.entranceTeleportID )
    end
    return nil;
end

function FindTeleportDest( usage, playerName )
    local dest = AssignedTeleportDest( usage, playerName );
    
    if dest ~= nil then
        local surface = dest.surface;
        return surface.find_non_colliding_position(
            "character" -- name
            , dest -- position
            , 4 -- radius
            , 1 -- precision 
            , true -- precision
            )
    end
    return nil;
end

function TeleportPlayer( player )
    local car = player.vehicle;
    if car ~= nil then
        local dest = nil
        local isPortal = false;
        for _,portal in pairs(global.portal) do
            if car.unit_number == portal.unit_number then
                isPortal = true;
                local teleportDisabled = (player.online_time < MIN_ONLINE_TIME);
                
                if teleportDisabled then
                    -- teleport from silo back to player spawn.
                    player.print("teleport warming up, time remaining " .. formattime(MIN_ONLINE_TIME-player.online_time).. ".");
                    -- dest = global.playerSpawns[player.name];
                    break
                else    
                    -- generic teleport
                    player.print("you have been teleported to the " .. portal.usage);
                    dest = FindTeleportDest( portal.usage, player.name);
                    break
                end
            end
        end
        -- TODO. transport anyone in the vicinity as well
        if isPortal then 
            player.driving=false;
            if dest ~= nil then
                player.teleport(dest);
            else
                player.print("teleport failed");
            end
        end
    end
end

function SameCoord(a, b)
    return a.x == b.x and a.y == b.y;
end

function EnableStartingResearch(force)
    local config = spawnGenerator.GetConfig()
    local researched = config.researched;
    if researched ~= nil then
        for key, tech in pairs(researched) do
            force.technologies[tech].researched=true;
        end
    end
end

function EnableStartingRecipes(force)
    local config = spawnGenerator.GetConfig()
    local recipesEnabled = config.recipesEnabled;
    if recipesEnabled ~= nil then
        for key, recipe in pairs(recipesEnabled) do
            force.recipes[recipe].enabled=true;
        end
    end
end

function AssignPlayerToStartSurface(player)
    local startSurface = game.surfaces["lobby"]
    if startSurface == nil then
        local settings = {
            terrain_segmentation = "very-low",
            water= "very-high",
            width =64,
            height = 64,
            starting_area = "low",
            peaceful_mode = true,
            seed = 1
        };
        game.create_surface("lobby", settings)
        startSurface = game.surfaces["lobby"]
    end
    player.teleport( {x=0,y=0}, startSurface)
end

function ShowSpawns(player, t)
  if t ~= nil then
    for key,spawn in pairs(t) do
      player.print("spawn " .. key .. ": " .. spawn.radius .. " sector " .. spawn.sector .. " seq ".. spawn.seq .. " " .. spawn.x .. "," .. spawn.y );
    end
  end
end

function ShowPlayerSpawns(player)
  ShowSpawns( player, global.playerSpawns );
end


-- Clear out enemies around an area with a certain distance
function ClearEnemies(surface, position, safeDist)
    local safeArea = {left_top=
        {x=position.x-safeDist,
            y=position.y-safeDist},
        right_bottom=
        {x=position.x+safeDist,
            y=position.y+safeDist}}

    for _, entity in pairs(surface.find_entities_filtered{area = safeArea, force = "enemy"}) do
        entity.destroy()
    end
end

function ClearNearbyEnemies(surface, chunkArea, spawnPos)
    -- spawnPos and safeDist are unused now.
    for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, force = "enemy"}) do
        if entity ~= nil and entity.valid then
            local dist =  DistanceFromPoint(spawnPos, entity.position);
            MaybeDestroyEnemy(entity, dist);
        end
    end
end

function ModifyEnemySpawnsNearPlayerStartingAreas(event)

    if (not event.entity or not (event.entity.force.name == "enemy") or not event.entity.position) then
        log("ModifyBiterSpawns - Unexpected use.")
        return
    end

    local enemy_pos = event.entity.position
    local surface = event.entity.surface

    local closest_spawn = GetClosestUniqueSpawn(surface, enemy_pos)

    if (closest_spawn == nil) then
        -- log("GetClosestUniqueSpawn ERROR - None found?")
        return
    end
    local dist = DistanceFromPoint(enemy_pos, closest_spawn);
    MaybeDestroyEnemy( event.entity, dist)
end

function MaybeDestroyEnemy( entity, d)
    local config = spawnGenerator.GetConfig();
    if d < config.safe_area.safe_radius then
        entity.destroy()
    elseif d < config.safe_area.danger_radius then
        local p = rangemap( d, config.safe_area.safe_radius, config.safe_area.danger_radius, config.safe_area.warn_reduction_fraction, config.safe_area.warn_reduction_fraction)
        if math.random() > p then
            entity.destroy()
        elseif d < config.safe_area.warn_radius then
            DowngradeEnemyToSmall( entity )
        elseif d < config.safe_area.danger_radius then
            DowngradeEnemyToMedium( entity )
        end
    end
end

function DowngradeEnemyToSmall( entity )
    local surface = entity.surface;
    local enemy_name = entity.name;
    local enemy_pos = entity.position;
    if ((enemy_name == "big-biter") or (enemy_name == "behemoth-biter") or (enemy_name == "medium-biter")) then
        entity.destroy()
        surface.create_entity{name = "small-biter", position = enemy_pos, force = game.forces.enemy}
        -- log("Downgraded biter close to spawn.")
    elseif ((enemy_name == "big-spitter") or (enemy_name == "behemoth-spitter") or (enemy_name == "medium-spitter")) then
        entity.destroy()
        surface.create_entity{name = "small-spitter", position = enemy_pos, force = game.forces.enemy}
        -- log("Downgraded spitter close to spawn.")
    elseif ((enemy_name == "big-worm-turret") or (enemy_name == "behemoth-worm-turret") or (enemy_name == "medium-worm-turret")) then
        entity.destroy()
        surface.create_entity{name = "small-worm-turret", position = enemy_pos, force = game.forces.enemy}
        -- log("Downgraded worm close to spawn.")
    end
end        

function DowngradeEnemyToMedium( entity )
    local surface = entity.surface;
    local enemy_name = entity.name;
    local enemy_pos = entity.position;
    if ((enemy_name == "big-biter") or (enemy_name == "behemoth-biter")) then
        entity.destroy()
        surface.create_entity{name = "medium-biter", position = enemy_pos, force = game.forces.enemy}
        -- log("Downgraded biter further from spawn.")
    elseif ((enemy_name == "big-spitter") or (enemy_name == "behemoth-spitter")) then
        entity.destroy()
        surface.create_entity{name = "medium-spitter", position = enemy_pos, force = game.forces.enemy}
        -- log("Downgraded spitter further from spawn
    elseif ((enemy_name == "big-worm-turret") or (enemy_name == "behemoth-worm-turret")) then
        entity.destroy()
        surface.create_entity{name = "medium-worm-turret", position = enemy_pos, force = game.forces.enemy}
        -- log("Downgraded worm further from spawn.")
    end
end


function EraseArea(position, chunkDist)
    local surface = game.surfaces[GAME_SURFACE_NAME];
    local eraseArea = {left_top=
                            {x=position.x-chunkDist*CHUNK_SIZE,
                             y=position.y-chunkDist*CHUNK_SIZE},
                        right_bottom=
                            {x=position.x+chunkDist*CHUNK_SIZE,
                             y=position.y+chunkDist*CHUNK_SIZE}}
    for chunk in surface.get_chunks() do
        local chunkArea = {left_top=
                            {x=chunk.x*CHUNK_SIZE,
                             y=chunk.y*CHUNK_SIZE },
                        right_bottom=
                            {x=chunk.x*CHUNK_SIZE + CHUNK_SIZE,
                             y=chunk.y*CHUNK_SIZE + CHUNK_SIZE }}
        if CheckIfInChunk(chunkArea,eraseArea) then
            surface.delete_chunk(chunk);
        end
    end
end

function SurfaceSettings(surface)
    local settings = surface.map_gen_settings;
    game.player.print("surface terrain_segmentation=" .. settings.terrain_segmentation);
    game.player.print("surface water=" .. settings.water);
    game.player.print("surface seed=" .. settings.seed);
end

function TilesInShape( chunkArea, pos, shape, height, width )
    local tiles = {}
    local ysize = height
    local xsize = width;
    if width == nil then
        xsize = height;
    end
    local xRadiusSq = (xsize/2)^2;
    local yRadiusSq = (ysize/2)^2;
    local midPointY = math.floor(ysize/2)
    local midPointX = math.floor(xsize/2)
    for y=1, ysize do
        for x=1, xsize do
            local inShape = false;
            if (shape == "ellipse") then
                if (((x-midPointX)^2/xRadiusSq + (y-midPointY)^2/yRadiusSq < 1)) then
                    inShape = true;
                end
            end
            if (shape == "rect") then
                inShape = true;
            end
            if inShape and CheckIfInChunk( pos.x+x, pos.y+y, chunkArea) then
                table.insert( tiles, { x=pos.x+x, y=pos.y+y }) 
            end
        end
    end
    return tiles
end

