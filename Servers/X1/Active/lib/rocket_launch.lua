-- rocket_launch.lua
-- May 2019

-- This is meant to extract out any rocket launch related logic to support my oarc scenario designs.

require("lib/oarc_utils")
require("config")

--------------------------------------------------------------------------------
-- Rocket Launch Event Code
-- Controls the "win condition"
--------------------------------------------------------------------------------
local function log_message(event, msg)
    print("[JAPC-EVENT-HANDLE] " .. msg)
    -- game.write_file("server.log", msg .. "\n", true)
end


function RocketLaunchEvent(event)
    local force = event.rocket.force
    
    -- Notify players on force if rocket was launched without sat.
    if event.rocket.get_item_count("satellite") == 0 then
	log_message(event, "Team " .. event.rocket.force.name .. " has launched a rocket but without a sattelite inside !")
        for index, player in pairs(force.players) do
            player.print("You launched the rocket, but you didn't put a satellite inside.")
        end
        return
    end

    -- First ever sat launch
    if not global.satellite_sent then
        global.satellite_sent = {}
        SendBroadcastMsg("Team " .. event.rocket.force.name .. " was the first to launch a rocket!")
        ServerWriteFile("rocket_events", "Team " .. event.rocket.force.name .. " was the first to launch a rocket!" .. "\n")
        log_message(event, "Team " .. event.rocket.force.name .. " was the first to launch a rocket!")
        
		for name,player in pairs(game.players) do
            SetOarcGuiTabEnabled(player, OARC_ROCKETS_GUI_TAB_NAME, true)
        end
    end

    -- Track additional satellites launched by this force
    if global.satellite_sent[force.name] then
        global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
        SendBroadcastMsg("Team " .. event.rocket.force.name .. " launched another rocket. Total " .. global.satellite_sent[force.name])
        ServerWriteFile("rocket_events", "Team " .. event.rocket.force.name .. " launched another rocket. Total " .. global.satellite_sent[force.name] .. "\n")
        -- Lets only send server notifications every 25 rockets after first 25 launched.
        if global.satellite_sent[force.name] < 25 or global.satellite_sent[force.name] % 25 == 0 then
		    log_message(event, "Team " .. event.rocket.force.name .. " launched another rocket. Total " .. global.satellite_sent[force.name])
        end
    -- First sat launch for this force.
    else
        -- game.set_game_state{game_finished=true, player_won=true, can_continue=true}
        global.satellite_sent[force.name] = 1
        SendBroadcastMsg("Team " .. event.rocket.force.name .. " launched their first rocket!")
        ServerWriteFile("rocket_events", "Team " .. event.rocket.force.name .. " launched their first rocket!" .. "\n")
		log_message(event, "Team " .. event.rocket.force.name .. " launched their first rocket!")
        -- Unlock research
        if global.ocfg.lock_goodies_rocket_launch then
            EnableTech(force, "atomic-bomb")
            EnableTech(force, "power-armor-mk2")
            EnableTech(force, "artillery")

            if (force.technologies["speed-module-3"].researched) then
		    	AddRecipe(force, "speed-module-3")
		    end
		    if (force.technologies["productivity-module-3"].researched) then
		    	AddRecipe(force, "productivity-module-3")
		    end
        end
    end
end

function CreateRocketGuiTab(tab_container, player)
    -- local frame = tab_container.add{type="frame", name="rocket-panel", caption="Satellites Launched:", direction = "vertical"}

    AddLabel(tab_container, nil, "Satellites Launched:", my_label_header_style)

    if (global.satellite_sent == nil) then
        AddLabel(tab_container, nil, "No launches yet.", my_label_style)
    else
        for force_name,sat_count in pairs(global.satellite_sent) do
            AddLabel(tab_container,
                    "rc_"..force_name,
                    "Team " .. force_name .. ": " .. tostring(sat_count),
                    my_label_style)
        end
    end
end
