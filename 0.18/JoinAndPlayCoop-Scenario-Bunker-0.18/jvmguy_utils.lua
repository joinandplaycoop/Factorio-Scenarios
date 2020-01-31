
if global.portal == nil then
    global.portal={}
end

-- Enforce a square of land, with a tree border
-- this is equivalent to the CreateCropCircle code
function CreateCropOctagon(surface, centerPos, chunkArea, landRadius, treeWidth, moatWidth)
    local config = spawnGenerator.GetConfig()

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x-1,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y-1,1 do

            local distVar1 = math.floor(math.max(math.abs(centerPos.x - i), math.abs(centerPos.y - j)))
            local distVar2 = math.floor(math.abs(centerPos.x - i) + math.abs(centerPos.y - j))
            local distVar = math.max(distVar1, distVar2 * 0.707);

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
    surface.set_tiles(dirtTiles)

    -- create the moat
    if (moatWidth>0) then
        local waterTiles = {}
        for i=chunkArea.left_top.x,chunkArea.right_bottom.x-1,1 do
            for j=chunkArea.left_top.y,chunkArea.right_bottom.y-1,1 do
    
                local distVar1 = math.floor(math.max(math.abs(centerPos.x - i), math.abs(centerPos.y - j)))
                local distVar2 = math.floor(math.abs(centerPos.x - i) + math.abs(centerPos.y - j))
                local distVar = math.max(distVar1, distVar2 * 0.707);
    
                -- Create a water ring
                if ((distVar > landRadius) and 
                    (distVar <= landRadius+moatWidth)) then
                    table.insert(waterTiles, {name = "water", position ={i,j}})
                end
            end
        end
	    surface.set_tiles(waterTiles)
    end
    
    local water = config.water;
    if water ~= nil then
        local waterTiles = {}   
        local shapeTiles = TilesInShape( chunkArea, {x=centerPos.x + water.x, y=centerPos.y + water.y }, water.shape, water.height, water.width );
        for _,tile in pairs(shapeTiles) do
            table.insert(waterTiles, {name = "water", position ={tile.x,tile.y}})
        end
        surface.set_tiles(waterTiles)
    end

    -- remove cliffs in the immediate areas?
    for key, entity in pairs(surface.find_entities_filtered({area=chunkArea, type= "cliff"})) do
        --Destroying some cliffs can cause a chain-reaction.  Validate inputs.
        if entity and entity.valid then
            if ((centerPos.x - entity.position.x)^2 + (centerPos.y - entity.position.y)^2 < landRadius^2) then
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
    surface.set_tiles(waterTiles)
end

function CreateTeleporter(surface, teleporterPosition, dest)
    local car = surface.create_entity{name="car", position=teleporterPosition, force=MAIN_FORCE }
    car.destructible=false;
    car.minable=false;
    for _,item in pairs(scenario.config.teleporter.startItems) do
        car.insert(item);
    end
    table.insert(global.portal, { dest=dest, unit_number = car.unit_number });
end

function TeleportPlayer( player )
    local car = player.vehicle;
    if car ~= nil then
        local dest = nil
        for _,portal in pairs(global.portal) do
            if car.unit_number == portal.unit_number then
                if portal.dest == nil then
                    -- teleport from silo back to player spawn.
                    player.print("teleport back to player spawn");
                    dest = global.playerSpawns[player.name];
                    break
                -- we could allow only the player to use the teleporter.
                -- elseif SameCoord(portal.dest, global.playerSpawns[player.name]) then
                else    
                    -- teleport player to silo
                    player.print("you have been teleported");
                    dest = portal.dest;
                    break
                end
            end
        end

        -- TODO. transport anyone in the vicinity as well 
        if dest ~= nil then
            dest = FindNonCollidingPosition(dest)
            player.driving=false;
            player.teleport(dest);
        else
            --find_non_colliding_position can return nil if no position found
            player.print("Error.  No clear place to teleport to.");
        end
    end
end

-- Utilizes find_non_colliding_position for a small "character" sized object.  Use for teleporting players.
function FindNonCollidingPosition(position)
    return game.surfaces[GAME_SURFACE_NAME].find_non_colliding_position("character",  position, 50, 0.1);
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

