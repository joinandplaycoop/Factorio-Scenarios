-- frontier_silo.lua
-- Nov 2016

require("config")
require("oarc_utils")

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
                tiles[i] = {name = "grass-1", position = {global.siloPosition.x+dx, global.siloPosition.y+dy}}
                i=i+1
            end
        end
        surface.set_tiles(tiles, false)
        tiles = {}
        i = 1
        for dx = -20,20 do
            for dy = -20,20 do
                tiles[i] = {name = "concrete", position = {global.siloPosition.x+dx, global.siloPosition.y+dy}}
                i=i+1
            end
        end
        surface.set_tiles(tiles, true)

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

		if scenario.config.silo.addBeacons then
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
		if scenario.config.silo.addPower then
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
        
        if scenario.config.teleporter.enabled then
            CreateTeleporter(surface, scenario.config.teleporter.siloPosition, nil)
        end 
        
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
    end

    -- Create rocket silo
    CreateCropCircle(surface, global.siloPosition, chunkArea, 70)
    CreateRocketSilo(surface, chunkArea)
end

function ChartRocketSiloArea(force)
    force.chart(game.surfaces[GAME_SURFACE_NAME], {{global.siloPosition.x-(CHUNK_SIZE*2), global.siloPosition.y-(CHUNK_SIZE*2)}, {global.siloPosition.x+(CHUNK_SIZE*2), global.siloPosition.y+(CHUNK_SIZE*2)}})
end