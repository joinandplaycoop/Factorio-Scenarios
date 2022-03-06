
local function CreateSpawnListGui(event)
  local player = game.players[event.player_index]
  if player.admin then
        if player.gui.top.SpawnList == nil then
            player.gui.top.add{name="SpawnList", type="button", caption="Spawn List"}
        end   
  end
end

local my_player_list_fixed_width_style = {
    minimal_width = 1000,
    maximal_width = 1000,
    maximal_height = 1000
}

local camera_style = {
    minimal_width = 500,
    maximal_width = 1000,
    minimal_height = 500,
    maximal_height = 500,
}


local function ExpandSpawnListGui(player)
    local frame = player.gui.left["SpawnList-panel"]
    if (frame) then
        frame.destroy()
    else
        local frame = player.gui.left.add{type="frame",
                                            name="SpawnList-panel",
                                            caption="used:"}
        local scrollFrame = frame.add{type="scroll-pane",
                                        name="SpawnList-panel",
                                        direction = "vertical"}
        ApplyStyle(scrollFrame, my_player_list_fixed_width_style)
        scrollFrame.horizontal_scroll_policy = "auto"
        scrollFrame.vertical_scroll_policy = "always"
        
        for _,spawn in pairs(global.allSpawns) do
            if spawn then
            -- if spawn.used or true then
                local spawnid = "spawn " .. spawn.seq
                local spawnFrame = scrollFrame.add{type="scroll-pane",
                                                name="SpawnList-panel-" .. spawn.seq,
                                                direction = "vertical"}
                local text=spawnFrame.add{type="label", caption=spawnid, name=spawnid}
                ApplyStyle(text, my_player_list_style)
                local camera = spawnFrame.add{ type="camera", position=spawn, surface_index=game.surfaces[GAME_SURFACE_NAME].index, zoom=0.2 }
                ApplyStyle(camera, camera_style)
            -- end
            end
        end
        local spacer = scrollFrame.add{type="label", caption="     ", name="plist_spacer_plist"}
        ApplyStyle(spacer, my_player_list_style_spacer)
    end
end

local function SpawnListGuiClick(event) 
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "SpawnList") then
        ExpandSpawnListGui(player)        
    end
end


Event.register(defines.events.on_gui_click, SpawnListGuiClick)
Event.register(defines.events.on_player_joined_game, CreateSpawnListGui)
