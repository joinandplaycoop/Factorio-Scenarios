-- control.lua
-- Jan 2019

-- Oarc's Separated Spawn Scenario
-- modified by jvmguy. where "I" is used below, that's Oarc, not jvmguy.
-- 
-- I wanted to create a scenario that allows you to spawn in separate locations
-- From there, I ended up adding a bunch of other minor/major features
-- 
-- Credit:
--  RSO mod to RSO author - Orzelek - I contacted him via the forum
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
require "locale/utils/event" --This is so all of the modules play nice with each other.
require("locale/modules/scheduler");

-- My Scenario Includes
require("oarc_utils")
require("jvmguy_utils")

-- Include Mods
require("locale/modules/longreach")
require("locale/modules/autofill-jvm")
require("locale/modules/adminlog")
require("locale/modules/decimatecommand")
require("locale/modules/itemcommand")
require("locale/modules/kitcommand")
require("locale/modules/rgcommand")
require("locale/modules/gameinfo")
require("locale/modules/spawnscommand")
require("locale/modules/statuscommand")
require("locale/modules/playerlist")
require("locale/modules/spawnlist")
require("locale/modules/tag")

require("rso_control")
require("separate_spawns")
require("separate_spawns_guis")
require("frontier_silo")
--require("bps")
toxicJungle = require("ToxicJungle")

-- spawnGenerator = require("FermatSpiralSpawns");
-- spawnGenerator = require("RiverworldSpawns");
spawnGenerator = require("BunkerSpawns");

sharedSpawns = require("shared_spawns");

regrow = require("locale/modules/jvm-regrowth");
wipespawn = require("locale/modules/jvm-wipespawn");

global.init = ""
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
    if ENABLE_RSO then
        CreateGameSurface(RSO_MODE)
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

    if ENABLE_RANDOM_SILO_POSITION then
        SetRandomSiloPosition()
    else
        SetFixedSiloPosition()
    end

    if FRONTIER_ROCKET_SILO_MODE then
        ChartRocketSiloArea(game.forces[MAIN_FORCE])
    end


    EnableStartingResearch(game.forces[MAIN_FORCE]);

    EnableStartingRecipes(game.forces[MAIN_FORCE]);
    
    if ENABLE_ALL_RESEARCH_DONE then
        game.forces[MAIN_FORCE].research_all_technologies()
    end
end

Event.register(-1, jvm.on_init)
    

----------------------------------------
-- Freeplay rocket launch info
-- Slightly modified for my purposes
----------------------------------------
function jvm.on_rocket_launch(event)
    if FRONTIER_ROCKET_SILO_MODE then
        RocketLaunchEvent(event)
    end
end

Event.register(defines.events.on_rocket_launched, jvm.on_rocket_launch)

----------------------------------------
-- Chunk Generation
----------------------------------------
function jvm.on_chunk_generated(event)
    local shouldGenerateResources = true
    if scenario.config.wipespawn.enabled then
        wipespawn.onChunkGenerated(event)
    elseif scenario.config.regrow.enabled then
        shouldGenerateResources = regrow.shouldGenerateResources(event);
        regrow.onChunkGenerated(event)
    end

    if spawnGenerator.ChunkGenerated then
        spawnGenerator.ChunkGenerated(event)
    end

    if scenario.config.toxicJungle.enabled then
        toxicJungle.ChunkGenerated(event);
    end    

    if ENABLE_RSO then
        if shouldGenerateResources then
            RSO_ChunkGenerated(event)
        end
    end

    if FRONTIER_ROCKET_SILO_MODE then
        GenerateRocketSiloChunk(event)
    end

    if spawnGenerator.ChunkGeneratedAfterRSO then
        spawnGenerator.ChunkGeneratedAfterRSO(event)
    else
        -- This MUST come after RSO generation!
        if ENABLE_SEPARATE_SPAWNS then
            SeparateSpawnsGenerateChunk(event)
        end
    end

    if scenario.config.regrow.enabled then
        regrow.afterResourceGeneration(event)
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
end

Event.register(defines.events.on_player_joined_game, jvm.on_player_joined_game)

function jvm.on_player_created(event)
    if ENABLE_SPAWN_SURFACE then
        AssignPlayerToStartSurface(game.players[event.player_index])
    end
--    if ENABLE_RSO then
--      RSO_PlayerCreated(event)
--  end

    GivePlayerBonuses(game.players[event.player_index])

    if not ENABLE_SEPARATE_SPAWNS then
        PlayerSpawnItems(event)
    else
        SeparateSpawnsPlayerCreated(event)
    end

    -- Not sure if this should be here or in player joined....
    if ENABLE_BLUEPRINT_STRING then
        bps_player_joined(event)
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
    local type = event.created_entity.type    
    if type == "entity-ghost" or type == "tile-ghost" or type == "item-request-proxy" then
        if GHOST_TIME_TO_LIVE ~= 0 then
            event.created_entity.time_to_live = GHOST_TIME_TO_LIVE
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
    if FRONTIER_ROCKET_SILO_MODE then
        RemoveRocketSiloRecipe(event)
    end

    if ENABLE_BLUEPRINT_STRING then
        bps_on_research_finished(event)
    end

    -- Example of how to remove a particular recipe:
    -- RemoveRecipe(event, "beacon")
end

Event.register(defines.events.on_research_finished, jvm.on_research_finished)


----------------------------------------
-- BPS Specific Event
----------------------------------------
--script.on_event(defines.events.on_robot_built_entity, function(event)
--end)

-- debug code from Mylon to detect possible causes for desync
--Time for the debug code.  If any (not global.) globals are written to at this point, an error will be thrown.
--eg, x = 2 will throw an error because it's not global.x or local x
if false then
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

