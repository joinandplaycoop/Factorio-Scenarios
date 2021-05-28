-- oarc_utils.lua
-- Nov 2016
-- 
-- My general purpose utility functions for factorio
-- Also contains some constants and gui styles


--------------------------------------------------------------------------------
-- GUI Label Styles
--------------------------------------------------------------------------------
my_fixed_width_style = {
    minimal_width = 500,
    maximal_width = 500,
}
my_label_style = {
    minimal_width = 500,
    maximal_width = 500,
    maximal_height = 20,
    font_color = {r=1,g=1,b=1},
    top_padding = 0,
    bottom_padding = 0,
}
my_note_style = {
    minimal_width = 500,
    maximal_height = 15,
    font = "default-small-semibold",
    font_color = {r=1,g=0.5,b=0.5},
    top_padding = 0,
    bottom_padding = 0,
}
my_warning_style = {
    minimal_width = 500,
    maximal_width = 500,
    maximal_height = 20,
    font_color = {r=1,g=0.1,b=0.1},
    top_padding = 0,
    bottom_padding = 0
}
my_spacer_style = {
    minimal_width = 500,
    maximal_width = 500,
    minimal_height = 20,
    maximal_height = 20,
    font_color = {r=0,g=0,b=0},
    top_padding = 0,
    bottom_padding = 0
}
my_small_button_style = {
    font = "default-small-semibold"
}
my_player_list_fixed_width_style = {
    minimal_width = 200,
    maximal_width = 200,
    maximal_height = 200
}
my_player_list_admin_style = {
    font = "default-semibold",
    font_color = {r=1,g=0.5,b=0.5},
    minimal_width = 200,
    top_padding = 0,
    bottom_padding = 0,
    maximal_height = 25
}
my_player_list_style = {
    font = "default-semibold",
    minimal_width = 200,
    top_padding = 0,
    bottom_padding = 0,
    maximal_height = 25
}
my_player_list_style_spacer = {
    maximal_height = 20
}
my_color_red = {r=1,g=0.1,b=0.1}




--------------------------------------------------------------------------------
-- General Helper Functions
--------------------------------------------------------------------------------

-- Print debug only to me while testing.
-- Should remove this if you are hosting it yourself.
function DebugPrint(msg)
    if ((game.players["Oarc"] ~= nil) and (global.oarcDebugEnabled)) then
        game.players["Oarc"].print("DEBUG: " .. msg)
    end
end

-- Prints flying text.
-- Color is optional
function FlyingText(msg, pos, color) 
    local surface = game.surfaces[GAME_SURFACE_NAME]
    if color == nil then
        surface.create_entity({ name = "flying-text", position = pos, text = msg })
    else
        surface.create_entity({ name = "flying-text", position = pos, text = msg, color = color })
    end
end

-- Broadcast messages
function SendBroadcastMsg(msg)
    for name,player in pairs(game.connected_players) do
        player.print(msg)
    end
end

function logAndBroadcast(playerName, msg)
    SendBroadcastMsg(msg);
    logInfo(playerName, msg);
end

function formattime(ticks)
  local seconds = ticks / 60
  local minutes = math.floor((seconds)/60)
  local seconds = math.floor(seconds - 60*minutes)
  return string.format("%dm:%02ds", minutes, seconds)
end

-- Simple function to get total number of items in table
function TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Chart area for a force
function ChartArea(force, position, chunkDist)
    force.chart(game.surfaces[GAME_SURFACE_NAME],
        {{position.x-(CHUNK_SIZE*chunkDist),
        position.y-(CHUNK_SIZE*chunkDist)},
        {position.x+(CHUNK_SIZE*chunkDist),
        position.y+(CHUNK_SIZE*chunkDist)}})
end



-- Give player these default items on restart.
function GivePlayerItems(player)
end

-- Additional starter only items
function GivePlayerStarterItems(player)
    for _,item in pairs(scenario.config.startKit) do
        player.insert(item);
        if item.equipment ~= nil then
            local p_armor = player.get_inventory(5)[1].grid --defines.inventory.character_armor = 5?
            if p_armor ~= nil then
                for _,equip in pairs(item.equipment) do
                    local count = equip.count
                    if count == nil then
                        count = 1
                    end
                    for i = 1,count do
                        p_armor.put(equip);
                    end
                end
            end
        end
    end
end

-- Create area given point and radius-distance
function GetAreaFromPointAndDistance(point, dist)
    local area = {left_top=
                    {x=point.x-dist,
                     y=point.y-dist},
                  right_bottom=
                    {x=point.x+dist,
                     y=point.y+dist}}
    return area
end

-- Check if given position is in area bounding box
function CheckIfInArea(point, area)
    if ((point.x >= area.left_top.x) and (point.x < area.right_bottom.x)) then
        if ((point.y >= area.left_top.y) and (point.y < area.right_bottom.y)) then
            return true
        end
    end
    return false
end

-- Returns true if two areas intersect
function CheckIfChunkIntersects(chunkArea, area)
    if (area.left_top.x >= chunkArea.right_bottom.x) then
        return false
    end
    if (area.left_top.y >= chunkArea.right_bottom.y) then
        return false
    end
    if (chunkArea.left_top.x >= area.right_bottom.x) then
        return false
    end
    if (chunkArea.left_top.y >= area.right_bottom.y) then
        return false
    end
    return true
end

-- Ceasefire
-- All forces are always neutral
function SetCeaseFireBetweenAllForces()
    for name,team in pairs(game.forces) do
        if name ~= "neutral" and name ~= "enemy" then
            for x,y in pairs(game.forces) do
                if x ~= "neutral" and x ~= "enemy" then
                    team.set_cease_fire(x,true)
                end
            end
        end
    end
end

-- Undecorator
function RemoveDecorationsArea(surface, area)
    for _, entity in pairs(surface.find_entities_filtered{area = area, type="decorative"}) do
        entity.destroy()
    end
end

-- Remove fish
function RemoveFish(surface, area)
    for _, entity in pairs(surface.find_entities_filtered{area = area, type="fish"}) do
        entity.destroy()
    end
end

-- Apply a style option to a GUI
function ApplyStyle (guiIn, styleIn)
    for k,v in pairs(styleIn) do
        guiIn.style[k]=v
    end 
end

-- Get a random 1 or -1
function RandomNegPos()
    if (math.random(0,1) == 1) then
        return 1
    else
        return -1
    end
end

-- Create a random direction vector to look in
function GetRandomVector()
    local randVec = {x=0,y=0}   
    while ((randVec.x == 0) and (randVec.y == 0)) do
        randVec.x = math.random(-3,3)
        randVec.y = math.random(-3,3)
    end
    DebugPrint("direction: x=" .. randVec.x .. ", y=" .. randVec.y)
    return randVec
end

-- Check for ungenerated chunks around a specific chunk
-- +/- chunkDist in x and y directions
function IsChunkAreaUngenerated(chunkPos, chunkDist)
    for x=-chunkDist, chunkDist do
        for y=-chunkDist, chunkDist do
            local checkPos = {x=chunkPos.x+x,
                             y=chunkPos.y+y}
            if (game.surfaces[GAME_SURFACE_NAME].is_chunk_generated(checkPos)) then
                return false
            end
        end
    end
    return true
end

-- Function to find coordinates of ungenerated map area in a given direction
-- starting from the center of the map
function FindMapEdge(directionVec)
    local position = {x=0,y=0}
    local chunkPos = {x=0,y=0}

    -- Keep checking chunks in the direction of the vector
    while(true) do
            
        -- Set some absolute limits.
        if ((math.abs(chunkPos.x) > 1000) or (math.abs(chunkPos.y) > 1000)) then
            break
        
        -- If chunk is already generated, keep looking
        elseif (game.surfaces[GAME_SURFACE_NAME].is_chunk_generated(chunkPos)) then
            chunkPos.x = chunkPos.x + directionVec.x
            chunkPos.y = chunkPos.y + directionVec.y
        
        -- Found a possible ungenerated area
        else
            
            chunkPos.x = chunkPos.x + directionVec.x
            chunkPos.y = chunkPos.y + directionVec.y

            -- Check there are no generated chunks in a 10x10 area.
            if IsChunkAreaUngenerated(chunkPos, 5) then
                position.x = (chunkPos.x*CHUNK_SIZE) + (CHUNK_SIZE/2)
                position.y = (chunkPos.y*CHUNK_SIZE) + (CHUNK_SIZE/2)
                break
            end
        end
    end

    DebugPrint("spawn: x=" .. position.x .. ", y=" .. position.y)
    return position
end

-- Find random coordinates within a given distance away
-- maxTries is the recursion limit basically.
function FindUngeneratedCoordinates(minDistChunks, maxDistChunks)
    local position = {x=0,y=0}
    local chunkPos = {x=0,y=0}

    local maxTries = 100
    local tryCounter = 0

    local minDistSqr = minDistChunks^2
    local maxDistSqr = maxDistChunks^2

    while(true) do
        chunkPos.x = math.random(0,maxDistChunks) * RandomNegPos()
        chunkPos.y = math.random(0,maxDistChunks) * RandomNegPos()

        local distSqrd = chunkPos.x^2 + chunkPos.y^2

        -- Enforce a max number of tries
        tryCounter = tryCounter + 1
        if (tryCounter > maxTries) then
            DebugPrint("FindUngeneratedCoordinates - Max Tries Hit!")
            break
 
        -- Check that the distance is within the min,max specified
        elseif ((distSqrd < minDistSqr) or (distSqrd > maxDistSqr)) then
            -- Keep searching!
        
        -- Check there are no generated chunks in a 10x10 area.
        elseif IsChunkAreaUngenerated(chunkPos, 5) then
            position.x = (chunkPos.x*CHUNK_SIZE) + (CHUNK_SIZE/2)
            position.y = (chunkPos.y*CHUNK_SIZE) + (CHUNK_SIZE/2)
            break -- SUCCESS
        end       
    end

    DebugPrint("spawn: x=" .. position.x .. ", y=" .. position.y)
    return position
end

--------------------------------------------------------------------------------
-- Anti-griefing Stuff
--------------------------------------------------------------------------------
function AntiGriefing(force)
    force.zoom_to_world_deconstruction_planner_enabled=false
    force.friendly_fire=false
end

function ApplyForceBonuses(force)
    if (scenario.config.forceBonuses) then
        for k,v in pairs(scenario.config.forceBonuses) do
            force[k] = v;
        end
    end
end

function SetForceGhostTimeToLive(force)
    if GHOST_TIME_TO_LIVE ~= 0 then
        force.ghost_time_to_live = GHOST_TIME_TO_LIVE+1
    end
end

-- Return steel chest entity (or nil)
function DropEmptySteelChest(player)
    local pos = player.surface.find_non_colliding_position("steel-chest", player.position, 15, 1)
    if not pos then
        return nil
    end
    local grave = player.surface.create_entity{name="steel-chest", position=pos, force="neutral"}
    return grave
end

-- Gravestone soft mod. With my own modifications/improvements.
function DropGravestoneChests(player)

    local grave
    local count = 0

    -- Use "game.player.cursorstack" to get items in player's hand.

    -- Loop through a players different inventories
    -- Put it all into the chest
    -- If the chest is full, create a new chest.
    for i, id in ipairs{
    defines.inventory.character_armor,
    defines.inventory.character_main,
    defines.inventory.character_quickbar,
    defines.inventory.character_guns,
    defines.inventory.character_ammo,
    defines.inventory.character_tools,
    defines.inventory.character_trash} do
        local inv = player.get_inventory(id)
        if (not inv.is_empty()) then
            for j = 1, #inv do
                if inv[j].valid_for_read then
                    
                    -- Create a chest when counter is reset
                    if (count == 0) then
                        grave = DropEmptySteelChest(player)
                        if (grave == nil) then
                            player.print("Not able to place a chest nearby! Some items lost!")
                            return
                        end
                        grave_inv = grave.get_inventory(defines.inventory.chest)
                    end
                    count = count + 1

                    grave_inv[count].set_stack(inv[j])

                    -- Reset counter when chest is full
                    if (count == #grave_inv) then
                        count = 0
                    end
                end
            end
        end
    end

    if (grave ~= nil) then
        player.print("Successfully dropped your items into a chest! Go get them quick!")
    end
end


-- Enforce a circle of land, also adds trees in a ring around the area.
function CreateCropCircle(surface, centerPos, chunkArea, tileRadius)

    local tileRadSqr = tileRadius^2

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y,1 do

            -- This ( X^2 + Y^2 ) is used to calculate if something
            -- is inside a circle area.
            local distVar = math.floor((centerPos.x - i)^2 + (centerPos.y - j)^2)

            -- Fill in all unexpected water in a circle
            if (distVar < tileRadSqr) then
                if (surface.get_tile(i,j).collides_with("water-tile") or ENABLE_SPAWN_FORCE_GRASS) then
                    table.insert(dirtTiles, {name = "grass-1", position ={i,j}})
                end
            end

            -- Create a circle of trees around the spawn point.
            if ((distVar < tileRadSqr-200) and 
                (distVar > tileRadSqr-260)) then
                surface.create_entity({name="tree-01", amount=1, position={i, j}})
            end
        end
    end

    for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, type = "cliff"}) do
        entity.destroy()
    end

    SetTiles(surface, dirtTiles, true)
end

-- Adjust alien params
function ConfigureAlienStartingParams()
    game.map_settings.enemy_evolution.time_factor=0
    game.map_settings.enemy_evolution.destroy_factor = game.map_settings.enemy_evolution.destroy_factor / ENEMY_DESTROY_FACTOR_DIVISOR
    game.map_settings.enemy_evolution.pollution_factor = game.map_settings.enemy_evolution.pollution_factor / ENEMY_POLLUTION_FACTOR_DIVISOR
    game.map_settings.enemy_expansion.enabled = ENEMY_EXPANSION
end

function GivePlayerBonuses(player)
    if player.character ~= nil then
        if (scenario.config.playerBonus.character_crafting_speed_modifier~= nil) then    
                player.character.character_crafting_speed_modifier = scenario.config.playerBonus.character_crafting_speed_modifier;
        end
    end
end


function CreateGameSurface()
    if GAME_SURFACE_NAME ~= "nauvis" then
        local mapSettings =  game.surfaces["nauvis"].map_gen_settings
        local surface = game.create_surface(GAME_SURFACE_NAME,mapSettings)
        -- surface.set_tiles({{name = "out-of-map",position = {1,1}}})
    end
end

--------------------------------------------------------------------------------
-- EVENT SPECIFIC FUNCTIONS
--------------------------------------------------------------------------------

-- Display messages to a user everytime they join
function PlayerJoinedMessages(event)
    local player = game.players[event.player_index]
    for _,msg in pairs(scenario.config.joinedMessages) do
        player.print(msg)
    end
end

-- Create the gravestone chests for a player when they die
function CreateGravestoneChestsOnDeath(event)
    DropGravestoneChests(game.players[event.player_index])
end

-- Give player items on respawn
-- Intended to be the default behavior when not using separate spawns
function PlayerRespawnItems(event)
    GivePlayerItems(game.players[event.player_index])
end

function PlayerSpawnItems(event)
    GivePlayerStarterItems(game.players[event.player_index])
end

-- General purpose event function for removing a particular recipe
function RemoveRecipe(event, recipeName)
    local recipes = event.research.force.recipes
    if recipes[recipeName] then
        recipes[recipeName].enabled = false
    end
end

--------------------------------------------------------------------------------
-- UNUSED CODE
-- Either didn't work, or not used or not tested....
--------------------------------------------------------------------------------


-- THIS DOES NOT WORK IN SCENARIOS!
-- function DisableVanillaResouresAndEnemies()

--     local map_gen_ctrls = game.surfaces[GAME_SURFACE_NAME].map_gen_settings.autoplace_controls

--     map_gen_ctrls["coal"].size = "none"
--     map_gen_ctrls["stone"].size = "none"
--     map_gen_ctrls["iron-ore"].size = "none"
--     map_gen_ctrls["copper-ore"].size = "none"
--     map_gen_ctrls["crude-oil"].size = "none"
--     map_gen_ctrls["enemy-base"].size = "none"
-- end



-- Shared vision for other forces? UNTESTED
-- function ShareVisionForAllForces()
--     for _,f in pairs(game.forces) do
--         for _,p in pairs(game.connected_players) do
--             if (f.name ~= p.force.name) then
--                 local visionArea = {left_top=
--                             {x=p.x-(CHUNK_SIZE*3),
--                              y=p.y-(CHUNK_SIZE*3)},
--                           right_bottom=
--                             {x=p.x+(CHUNK_SIZE*3),
--                              y=p.y+(CHUNK_SIZE*3)}}
--                 f.chart(game.surfaces[GAME_SURFACE_NAME], visionArea)
--             end
--         end
--     end
-- end
