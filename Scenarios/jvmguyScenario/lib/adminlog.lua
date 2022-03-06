
function playerNameFromEvent(event)
    return (event.player_index and game.players[event.player_index].name) or "<unknown>"
end

function logInfo(playerName, msg)
    if msg ~= nil then
        game.write_file("infolog.txt", game.tick .. ": " .. playerName .. ": " .. msg .. "\n", true, 0);
    end
end

local function on_player_joined_game(event)
    logInfo( playerNameFromEvent(event), "+++ player joined game" );
end

Event.register(defines.events.on_player_joined_game, on_player_joined_game)

local function on_player_created(event)
    logInfo( playerNameFromEvent(event), "+++ player created" );
end

Event.register(defines.events.on_player_created, on_player_created)
    
local function on_player_died(event)
    logInfo( playerNameFromEvent(event), "+++ player died" );
end

Event.register(defines.events.on_player_died, on_player_died)
    
local function on_player_respawned(event)
    logInfo( playerNameFromEvent(event), "+++ player respawned" );
end

Event.register(defines.events.on_player_respawned, on_player_respawned)

local function on_player_left_game(event)
    logInfo( playerNameFromEvent(event), "+++ player left game" );
end

Event.register(defines.events.on_player_left_game, on_player_left_game)

local function on_console_chat(event)
    logInfo( playerNameFromEvent(event), event.message );
end

Event.register(defines.events.on_console_chat, on_console_chat)

local function on_console_command(event)
    logInfo(playerNameFromEvent(event), 'command: /' .. event.command .. ' ' .. event.parameters);
end

Event.register(defines.events.on_console_command, on_console_command)

local function on_research_finished(event)
    logInfo( playerNameFromEvent(event), "+++ research completed: " .. event.research.name );
end
Event.register(defines.events.on_research_finished, on_research_finished)

local function on_research_started(event)
    logInfo( playerNameFromEvent(event), "+++ research started: " .. event.research.name );
end
Event.register(defines.events.on_research_started, on_research_started)

