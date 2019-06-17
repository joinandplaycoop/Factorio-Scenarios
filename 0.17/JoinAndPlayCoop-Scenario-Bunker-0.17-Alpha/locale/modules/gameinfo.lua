
local function CreateGameInfoGui(event)
  local player = game.players[event.player_index]
  if player.admin then
        if player.gui.top.GameInfo == nil then
            player.gui.top.add{name="GameInfo", type="button", caption="Game Info"}
        end   
  end
end

local my_player_list_fixed_width_style = {
    minimal_width = 1000,
    maximal_width = 1000,
    maximal_height = 1000
}

local function ExpandGameInfoGui(player)
    local frame = player.gui.left["GameInfo-panel"]
    if (frame) then
        frame.destroy()
    else
        local frame = player.gui.left.add{type="frame",
                                            name="GameInfo-panel",
                                            caption="used:"}
        local scrollFrame = frame.add{type="scroll-pane",
                                        name="GameInfo-panel",
                                        direction = "vertical"}
        ApplyStyle(scrollFrame, my_player_list_fixed_width_style)
        scrollFrame.horizontal_scroll_policy = "auto"
        scrollFrame.vertical_scroll_policy = "always"
        
        local ix = 0
        for _,msg in pairs(scenario.config.gameInfo) do        
            local name = "game_info_lbl" .. ix
            local text=scrollFrame.add{name=name, type="label", caption=msg}
            ApplyStyle(text, my_player_list_style)
            ix = ix + 1
        end
    end
end

local function GameInfoGuiClick(event) 
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "GameInfo") then
        ExpandGameInfoGui(player)        
    end
end


Event.register(defines.events.on_gui_click, GameInfoGuiClick)
Event.register(defines.events.on_player_joined_game, CreateGameInfoGui)
