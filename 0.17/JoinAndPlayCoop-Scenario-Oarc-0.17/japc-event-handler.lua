local function log_message(event, msg)
    print("[JAPC-EVENT-HANDLE] " .. msg)
    -- game.write_file("server.log", msg .. "\n", true)
end

local function log_player_message(event, msg_in)
    local msg = "Player " .. game.players[event.player_index].name .. " " .. msg_in .. "."
    log_message(event, msg)
    -- game.write_file("server.log", msg .. "\n", true)
end

local function log_player_death_message(event, msg_in)
    local cs = ''
    if event.cause then cs = event.cause.name else cs = 'something else' end
	
    local msg = "" .. game.players[event.player_index].name .. " has been killed by " .. cs .. "!"
    log_message(event, msg)
    -- game.write_file("server.log", msg .. "\n", true)
end

local function log_research_message(event, msg_in)
    local msg = msg_in .. " \"" .. event.research.name .. "\""
    log_message(event, msg)

    --for _, player in pairs(game.players) do
    --	player.print{event.research.localised_name[1]}
    --end
    -- game.write_file("server.log", msg .. "\n", true)
end

script.on_event(defines.events.on_player_died, function(event)
    log_player_death_message(event, "")
end)
script.on_event(defines.events.on_research_started, function(event)
    log_research_message(event, "Started research of")
end)
script.on_event(defines.events.on_research_finished, function(event)
    log_research_message(event, "Research finished for")
end)

