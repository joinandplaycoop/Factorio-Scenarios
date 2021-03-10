-- control.lua
-- Nov 2016

-- Oarc's Separated Spawn Scenario
-- modified by jvmguy. where "I" is used below, that's Oarc, not jvmguy.
-- 
-- I wanted to create a scenario that allows you to spawn in separate locations
-- From there, I ended up adding a bunch of other minor/major features
-- 
-- Credit:
--  Tags - Taken from WOGs scenario 
--  Event - Taken from WOGs scenario (looks like original source was 3Ra)
--  Rocket Silo - Taken from Frontier as an idea
--
-- Feel free to re-use anything you want. It would be nice to give me credit
-- if you can.
-- 
-- Follow server info on @_Oarc_


-- To keep the scenario more manageable I have done the following:
--      1. Keep all event calls in control.lua (here)
--      2. Put all config options in config.lua
--      3. Put mods into their own files where possible (RSO has multiple)

-- Event manager
require("config")
require("lib/event")    --This is so all of the modules play nice with each other.
require("lib/scheduler");

-- redmew's map_gen_settings
require("lib/map_gen_settings")

-- My Scenario Includes
require("lib/oarc_utils")
require("lib/jvmguy_utils")

-- Include Mods
-- require("lib/longreach")    
--require("lib/autofill-jvm")   -- enable if you want my softmod version of this
require("lib/adminlog")
require("lib/decimatecommand")
require("lib/itemcommand")
require("lib/kitcommand")
require("lib/rgcommand")
require("lib/gameinfo")
require("lib/spawnscommand")
require("lib/statuscommand")
require("lib/playerlist")
require("lib/spawnlist")
require("lib/tag")

require("lib/separate_spawns")
require("lib/separate_spawns_guis")
require("lib/frontier_silo")

toxicJungle = require("lib/ToxicJungle")

spawnGenerator = require("lib/FermatSpiralSpawns");
-- spawnGenerator = require("lib/RiverworldSpawns");
-- spawnGenerator = require("lib/BunkerSpawns");

local terrainGenerator = nil;
-- terrainGenerator = require("lib/GeometricTerrain");
-- terrainGenerator = require("lib/OctoTile");

sharedSpawns = require("lib/shared_spawns");

wipespawn = require("lib/jvm-wipespawn");

global.init = ""
global.debug = {}
function global.log(msg)
    table.insert(global.debug, msg);
end

function global.dump()
    for _,val in pairs(global.debug) do
        game.print(val)
    end
end

function global.clear()
    global.debug = {}
end

jvm = {}


--------------------------------------------------------------------------------
-- Rocket Launch Event Code
-- Controls the "win condition"
--------------------------------------------------------------------------------
function RocketLaunchEvent(event)
    local force = event.rocket.force
    
    if event.rocket.get_item_count("satellite") == 0 then
        for index, player in pairs(force.players) do
            player.print("You launched the rocket, but you didn't put a satellite inside.")
        end
        return
    end

    if not global.satellite_sent then
        global.satellite_sent = {}
    end

    if global.satellite_sent[force.name] then
        global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
    else
        game.set_game_state{game_finished=true, player_won=true, can_continue=true}
        global.satellite_sent[force.name] = 1
    end
    
    for index, player in pairs(force.players) do
        if player.gui.left.rocket_score then
            player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
        else
            local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption="Score"}
            frame.add{name="rocket_count_label", type = "label", caption={"", "Satellites launched", ":"}}
            frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
        end
    end
end

----------------------------------------
-- On Init - only runs once the first 
--   time the game starts
----------------------------------------
function jvm.on_init(event)
    -- Configures the map settings for enemies
    -- This controls evolution growth factors and enemy expansion settings.
    if spawnGenerator.CreateGameSurfaces then
        spawnGenerator.CreateGameSurfaces()
    else
        CreateGameSurface(VANILLA_MODE)
    end
    
    if spawnGenerator.ConfigureGameSurface then
        spawnGenerator.ConfigureGameSurface()
    end
    
    ConfigureAlienStartingParams()

    if ENABLE_SEPARATE_SPAWNS then
        InitSpawnGlobalsAndForces()
    end
    
    -- unfortunately, the order of execution matters
    -- silo_on_init must not run until after forces have been setup
    silo_on_init(event);

    EnableStartingResearch(game.forces[MAIN_FORCE]);

    EnableStartingRecipes(game.forces[MAIN_FORCE]);
    
    if ENABLE_ALL_RESEARCH_DONE then
        game.forces[MAIN_FORCE].research_all_technologies()
    end
end

Event.register(-1, jvm.on_init)
    


----------------------------------------
-- Chunk Generation
----------------------------------------
function jvm.on_chunk_generated(event)

    global.customChunk = false;
    local shouldGenerateResources = true
    
    if scenario.config.wipespawn.enabled then
        wipespawn.onChunkGenerated(event)
    end

    if spawnGenerator.ChunkGenerated then
        spawnGenerator.ChunkGenerated(event)
    end

    if scenario.config.toxicJungle.enabled then
        toxicJungle.ChunkGenerated(event);
    end    

    if not global.customChunk then
        if terrainGenerator ~= nil then
            terrainGenerator.ChunkGenerated(event);
        end
        global.customChunk = false;
    end
end

Event.register(defines.events.on_chunk_generated, jvm.on_chunk_generated)

----------------------------------------
-- Gui Click
----------------------------------------
function jvm.on_gui_click(event)
    if ENABLE_SEPARATE_SPAWNS then
        WelcomeTextGuiClick(event)
        SpawnOptsGuiClick(event)
        SpawnCtrlGuiClick(event)
        SharedSpwnOptsGuiClick(event)
    end

end

Event.register(defines.events.on_gui_click, jvm.on_gui_click)

function jvm.on_gui_checked_state_changed(event)
        SpawnCtrlGuiCheckStateChanged(event)
end

Event.register(defines.events.on_gui_checked_state_changed, jvm.on_gui_checked_state_changed)

----------------------------------------
-- Player Events
----------------------------------------
function jvm.on_player_joined_game(event)
    PlayerJoinedMessages(event)
    GivePlayerBonuses(game.players[event.player_index])
end

Event.register(defines.events.on_player_joined_game, jvm.on_player_joined_game)

function jvm.on_player_created(event)
    if ENABLE_SPAWN_SURFACE then
        AssignPlayerToStartSurface(game.players[event.player_index])
    end

    if not ENABLE_SEPARATE_SPAWNS then
        PlayerSpawnItems(event)
    else
        SeparateSpawnsPlayerCreated(event)
    end
end

Event.register(defines.events.on_player_created, jvm.on_player_created)


function jvm.on_player_died(event)
    if ENABLE_GRAVESTONE_CHESTS then
        CreateGravestoneChestsOnDeath(event)
    end
end

Event.register(defines.events.on_player_died, jvm.on_player_died)

function jvm.on_player_respawned(event)
    if not ENABLE_SEPARATE_SPAWNS then
        PlayerRespawnItems(event)
    else 
        SeparateSpawnsPlayerRespawned(event)
    end
    GivePlayerBonuses(game.players[event.player_index])
end

Event.register(defines.events.on_player_respawned, jvm.on_player_respawned)


function jvm.on_player_left_game(event)
    if ENABLE_SEPARATE_SPAWNS then
        FindUnusedSpawns(event)
    end
end

Event.register(defines.events.on_player_left_game, jvm.on_player_left_game)


function jvm.on_built_entity(event)
    if event.created_entity.valid then
        local type = event.created_entity.type    
        if type == "entity-ghost" or type == "tile-ghost" or type == "item-request-proxy" then
            if GHOST_TIME_TO_LIVE ~= 0 then
                event.created_entity.time_to_live = GHOST_TIME_TO_LIVE
            end
        end
    end        
end

Event.register(defines.events.on_built_entity, jvm.on_built_entity)

function jvm.teleporter(event)
    local player = game.players[event.player_index];
    TeleportPlayer(player)
end

if scenario.config.teleporter.enabled then
    Event.register(defines.events.on_player_driving_changed_state, jvm.teleporter)
end

----------------------------------------
-- On Research Finished
----------------------------------------
function jvm.on_research_finished(event)
    if scenario.config.silo.disableSiloRecipe then
        RemoveRocketSiloRecipe(event)
    end
--    local config = spawnGenerator.GetConfig()
--    if config.recipesEnabled then
--        for kk,vv in pairs(config.recipesEnabled) do
--            RemoveRecipe( config.recipesEnabled[vv] )
--        end
--    end

    -- Example of how to remove a particular recipe:
    -- RemoveRecipe(event, "beacon")
end
Event.register(defines.events.on_research_finished, jvm.on_research_finished)

function jvm.on_entity_spawned(event)
    if (scenario.config.modified_enemy_spawning) then
--        ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end
-- Event.register(defines.events.on_entity_spawned, jvm.on_entity_spawned)


function jvm.on_biter_base_built(event)
    if (scenario.config.modified_enemy_spawning) then
--        ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end
-- Event.register(defines.events.on_biter_base_built, jvm.on_biter_base_built)


function jvm.on_robot_built_entity(event)
    if scenario.config.silo.restrictSiloBuild then
        BuildSiloAttempt(event)
    end
end

Event.register(defines.events.on_robot_built_entity, jvm.on_robot_built_entity)

-- debug code from Mylon to detect possible causes for desync
--Time for the debug code.  If any (not global.) globals are written to at this point, an error will be thrown.
--eg, x = 2 will throw an error because it's not global.x or local x
if true then
    setmetatable(_G, {
         __newindex = function(_, n, v)
             logInfo("", "Attempt to write to undeclared var " .. n)
             logInfo("", debug.traceback());             
             global[n] = v;
         end,
         __index = function(_, n)
             game.print("Attempt to read undeclared var " .. n)
             logInfo("", "Attempt to read undeclared var " .. n)
             logInfo("", debug.traceback());             
            return global[n];
         end
     })
end     

