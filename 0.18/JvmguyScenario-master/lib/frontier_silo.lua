-- frontier_silo.lua
-- Nov 2016

require("config")
require("oarc_utils")

local M = {}

local function ChunkContains( chunk, pt )
        return pt.x >= chunk.left_top.x and pt.x < chunk.right_bottom.x and
            pt.y >= chunk.left_top.y and pt.y < chunk.right_bottom.y;
end


-- Create a rocket silo
local function CreateRocketSilo(surface, chunkArea)
    if CheckIfInArea(global.siloPosition, chunkArea) then

        -- Delete any entities beneat the silo?
        for _, entity in pairs(surface.find_entities_filtered{area = {{global.siloPosition.x-50, global.siloPosition.y-50},{global.siloPosition.x+50, global.siloPosition.y+50}}}) do
            entity.destroy()
        end

        -- Set tiles below the silo
        local tiles = {}
        local i = 1
        for dx = -20,20 do
            for dy = -20,20 do
                local position = { x=global.siloPosition.x+dx, y=global.siloPosition.y+dy }
                if ChunkContains( chunkArea, position) then
                    tiles[i] = {name = "grass-1", position = position}
                    i=i+1
                end
            end
        end
        SetTiles(surface, tiles, false);
        tiles = {}
        i = 1
        for dx = -20,20 do
            for dy = -20,20 do
                local position = { x=global.siloPosition.x+dx, y=global.siloPosition.y+dy }
                if ChunkContains( chunkArea, position) then
                    tiles[i] = {name = "concrete", position = position}
                    i=i+1
                end
            end
        end
        
        SetTiles(surface, tiles, true);

        if scenario.config.silo.prebuildSilo then
            -- Create silo and assign to main force
            local silo = surface.create_entity{name = "rocket-silo", position = {global.siloPosition.x+0.5-8, global.siloPosition.y-8}, force = MAIN_FORCE}
            silo.destructible = false
            silo.minable = false
    
            local silo = surface.create_entity{name = "rocket-silo", position = {global.siloPosition.x+0.5+8, global.siloPosition.y-8}, force = MAIN_FORCE}
            silo.destructible = false
            silo.minable = false
    
            local silo = surface.create_entity{name = "rocket-silo", position = {global.siloPosition.x+0.5-8, global.siloPosition.y+8}, force = MAIN_FORCE}
            silo.destructible = false
            silo.minable = false
    
            local silo = surface.create_entity{name = "rocket-silo", position = {global.siloPosition.x+0.5+8, global.siloPosition.y+8}, force = MAIN_FORCE}
            silo.destructible = false
            silo.minable = false
        end

		if scenario.config.silo.prebuildBeacons then
            -- Add Beacons
            -- x = right, left; y = up, down
            -- top 1 left 1
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-8, global.siloPosition.y-9}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- top 2
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-5, global.siloPosition.y-9}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- top 3
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-2, global.siloPosition.y-9}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- top 4
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+2, global.siloPosition.y-9}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- top 5
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+5, global.siloPosition.y-9}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- top 6 right 1
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+8, global.siloPosition.y-9}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- left 2
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-6, global.siloPosition.y-6}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- left 3
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-6, global.siloPosition.y-3}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- left 4
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-6, global.siloPosition.y}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- left 5
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-6, global.siloPosition.y+3}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- left 6 bottom 1
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-8, global.siloPosition.y+6}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- left 7 bottom 2
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x-5, global.siloPosition.y+6}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- right 2
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+6, global.siloPosition.y-6}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- right 3
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+6, global.siloPosition.y-3}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- right 4
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+6, global.siloPosition.y}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- right 5
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+6, global.siloPosition.y+3}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- right 6 bottom 3
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+5, global.siloPosition.y+6}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- right 7 bottom 4
            local beacon = surface.create_entity{name = "beacon", position = {global.siloPosition.x+8, global.siloPosition.y+6}, force = MAIN_FORCE}
            beacon.destructible = false
            beacon.minable = false
            -- substations
            -- top left
            local substation = surface.create_entity{name = "substation", position = {global.siloPosition.x-8, global.siloPosition.y-6}, force = MAIN_FORCE}
            substation.destructible = false
            substation.minable = false
            -- top right
            local substation = surface.create_entity{name = "substation", position = {global.siloPosition.x+9, global.siloPosition.y-6}, force = MAIN_FORCE}
            substation.destructible = false
            substation.minable = false
            -- bottom left
            local substation = surface.create_entity{name = "substation", position = {global.siloPosition.x-8, global.siloPosition.y+4}, force = MAIN_FORCE}
            substation.destructible = false
            substation.minable = false
            -- bottom right
            local substation = surface.create_entity{name = "substation", position = {global.siloPosition.x+9, global.siloPosition.y+4}, force = MAIN_FORCE}
            substation.destructible = false
            substation.minable = false

            -- end adding beacons
		end
		if scenario.config.silo.prebuildPower then
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-46, global.siloPosition.y+3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-46, global.siloPosition.y-3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-43, global.siloPosition.y-6}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-40, global.siloPosition.y-6}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-37, global.siloPosition.y-6}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-37, global.siloPosition.y-3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-37, global.siloPosition.y}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-37, global.siloPosition.y+3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-46, global.siloPosition.y-6}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-43, global.siloPosition.y+3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "solar-panel", position = {global.siloPosition.x-40, global.siloPosition.y+3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "radar", position = {global.siloPosition.x-46, global.siloPosition.y}, force = MAIN_FORCE}
            radar.destructible = false
            local substation = surface.create_entity{name = "substation", position = {global.siloPosition.x-41, global.siloPosition.y-1}, force = MAIN_FORCE}
            substation.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-43, global.siloPosition.y-1}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-43, global.siloPosition.y-3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-43, global.siloPosition.y+1}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-41, global.siloPosition.y-3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-41, global.siloPosition.y+1}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-39, global.siloPosition.y-1}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-39, global.siloPosition.y-3}, force = MAIN_FORCE}
            radar.destructible = false
            local radar = surface.create_entity{name = "accumulator", position = {global.siloPosition.x-39, global.siloPosition.y+1}, force = MAIN_FORCE}
            radar.destructible = false
		end
        
        if scenario.config.teleporter.siloTeleportEnabled then
            global.siloTeleportID = CreateTeleporter(surface, scenario.config.teleporter.siloPosition, "spawn")
        end 
    end
end

-- Validates any attempt to build a silo.
-- Should be call in on_built_entity and on_robot_built_entity
function BuildSiloAttempt(event)

    -- Validation
    if (event.created_entity == nil) then return end

    local e_name = event.created_entity.name
    if (event.created_entity.name == "entity-ghost") then
        e_name =event.created_entity.ghost_name
    end

    -- additional check for Rocket Silo Construction mod
    if (e_name ~= "rocket-silo" and e_name ~= "rsc-silo-stage1") then
        return;
    end
    
    -- Check if it's in the right area.
    local epos = event.created_entity.position

--    from Oarc's code to support multiple silos
--    for k,v in pairs(global.siloPosition) do
--        if (getDistance(epos, v) < 5) then
--            if (event.created_entity.name ~= "entity-ghost") then
--                SendBroadcastMsg("Rocket silo has been built!")
--            end
--            return -- THIS MEANS WE SUCCESFULLY BUILT THE SILO (ghost or actual building.)
--        end
--    end

    if DistanceFromPoint( epos, global.siloPosition) < 5 then
        if (event.created_entity.name ~= "entity-ghost") then
            SendBroadcastMsg("Rocket silo has been built!")
        end
        return -- THIS MEANS WE SUCCESFULLY BUILT THE SILO (ghost or actual building.)
    end

    -- If we get here, means it wasn't in a valid position. Need to remove it.
    if (event.created_entity.last_user ~= nil) then
        FlyingText("Can't build silo here! Check the map!", epos, my_color_red, event.created_entity.surface)
        if (event.created_entity.name == "entity-ghost") then
            event.created_entity.destroy()
        else
            event.created_entity.last_user.mine_entity(event.created_entity, true)
        end
    else
        log("ERROR! Rocket-silo had no valid last user?!?!")
    end
end

-- Remove rocket silo from recipes
function RemoveRocketSiloRecipe(event)
    RemoveRecipe(event, "rocket-silo")
end

-- Generates the rocket silo during chunk generation event
-- Includes a crop circle
function GenerateRocketSiloChunk(event)
    local surface = event.surface
    if surface.name ~= GAME_SURFACE_NAME then return end
    local chunkArea = event.area

    local safeArea = {left_top=
                        {x=global.siloPosition.x-150,
                         y=global.siloPosition.y-150},
                      right_bottom=
                        {x=global.siloPosition.x+150,
                         y=global.siloPosition.y+150}}
                             

    -- Clear enemies directly next to the rocket
    if CheckIfChunkIntersects(chunkArea,safeArea) then
        for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, force = "enemy"}) do
            entity.destroy()
        end

        -- Create rocket silo
        CreateCropCircle(surface, global.siloPosition, chunkArea, 70)
        
        CreateRocketSilo(surface, chunkArea)
    end
end

function ChartRocketSiloArea(force)
    if scenario.config.silo.chartSiloArea then
        force.chart(game.surfaces[GAME_SURFACE_NAME], {{global.siloPosition.x-(CHUNK_SIZE*2), global.siloPosition.y-(CHUNK_SIZE*2)}, {global.siloPosition.x+(CHUNK_SIZE*2), global.siloPosition.y+(CHUNK_SIZE*2)}})
    end
end

-- This creates a random silo position, stored to global.siloPosition
-- It uses the config setting SILO_CHUNK_DISTANCE and spawns the silo somewhere
-- on a circle edge with radius using that distance.
function SetRandomSiloPosition()
    if (global.siloPosition == nil) then
        -- Get an X,Y on a circle far away.
        distX = math.random(0,SILO_CHUNK_DISTANCE_X)
        distY = RandomNegPos() * math.floor(math.sqrt(SILO_CHUNK_DISTANCE_X^2 - distX^2))
        distX = RandomNegPos() * distX

        -- Set those values.
        local siloX = distX*CHUNK_SIZE + CHUNK_SIZE/2
        local siloY = distY*CHUNK_SIZE + CHUNK_SIZE/2
        global.siloPosition = {x = siloX, y = siloY}
    end
end

-- Sets the global.siloPosition var to the set in the config file
function SetFixedSiloPosition()
    if (global.siloPosition == nil) then
        global.siloPosition = scenario.config.silo.position
    end
end

function silo_on_init(event)
    if scenario.config.silo.randomSiloPostion then
        SetRandomSiloPosition()
    else
        SetFixedSiloPosition()
    end
    ChartRocketSiloArea(game.forces[MAIN_FORCE])
end

function silo_on_built_entity(event)
    if scenario.config.silo.restrictSiloBuild then
        BuildSiloAttempt(event)
    end
end


function silo_on_chunk_generated(event)
    if scenario.config.silo.frontierSilo then
        if event.surface.name == GAME_SURFACE_NAME then
            GenerateRocketSiloChunk(event)
        end
    end
end

function silo_on_rocket_launch(event)
    if scenario.config.silo.handleLaunch then
        RocketLaunchEvent(event)
    end
end

-- Event.register(-1, silo_on_init)
Event.register(defines.events.on_built_entity, silo_on_built_entity)
Event.register(defines.events.on_chunk_generated, silo_on_chunk_generated)
Event.register(defines.events.on_rocket_launched, silo_on_rocket_launch)

return M;
    