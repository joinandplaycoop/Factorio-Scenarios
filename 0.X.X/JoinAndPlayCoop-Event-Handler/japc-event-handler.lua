local function log_message(event, msg)
    print(event.tick .. " [JAPC-EVENT-HANDLE] " .. msg)
    -- game.write_file("server.log", msg .. "\n", true)
end

local function log_player_message(event, msg_in)
    local msg = "Player " .. game.players[event.player_index].name .. " " .. msg_in .. "."
    log_message(event, msg)
    -- game.write_file("server.log", msg .. "\n", true)
end

local function log_player_death_message(event, msg_in)
    local cs = event.cause.name
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
script.on_event(defines.events.on_rocket_launched, function(event)
        RocketLaunchEvent(event)
end)

function RocketLaunchEvent(event)
    local force = event.rocket.force
    
    -- Notify players on force if rocket was launched without sat.
    if event.rocket.get_item_count("satellite") == 0 then
        for index, player in pairs(force.players) do
            player.print("You launched the rocket, but you didn't put a satellite inside.")
        end
        return
    end

    -- First ever sat launch
    if not global.satellite_sent then
        global.satellite_sent = {}
       game.print("Team " .. event.rocket.force.name .. " was the first to launch a rocket!")
		log_message(event, "Team " .. event.rocket.force.name .. " was the first to launch a rocket!")
    end

    -- Track additional satellites launched by this force
    if global.satellite_sent[force.name] then
        global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
        game.print("Team " .. event.rocket.force.name .. " launched another rocket. Total " .. global.satellite_sent[force.name])
		log_message(event, "Team " .. event.rocket.force.name .. " launched another rocket. Total " .. global.satellite_sent[force.name])

    -- First sat launch for this force.
    else
        -- game.set_game_state{game_finished=true, player_won=true, can_continue=true}
        global.satellite_sent[force.name] = 1
        game.print("Team " .. event.rocket.force.name .. " launched their first rocket!")
		log_message(event, "Team " .. event.rocket.force.name .. " launched their first rocket!")
        end
    end

