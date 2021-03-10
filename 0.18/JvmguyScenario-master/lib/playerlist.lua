
local function HoursAndMinutes(ticks)
    local seconds = ticks/TICKS_PER_SECOND;
    local minutes = math.floor((seconds)/60);
    local hours = math.floor(minutes/60);
    minutes = minutes - 60 * hours;
    return string.format("%3d:%02d", hours, minutes);
end

local function CreatePlayerListGui(event)
  local player = game.players[event.player_index];
  if player.gui.top.adminPlayerList == nil then
      player.gui.top.add{name="adminPlayerList", type="button", caption="Player List"};
  end   
end

local function ExpandPlayerListGui(player)
    local frame = player.gui.top["adminPlayerList-panel"];
    if (frame) then
        frame.destroy();
    else
        local frame = player.gui.top.add{type="frame",
                                            name="adminPlayerList-panel",
                                            caption="Players:"};
        local scrollFrame = frame.add{type="scroll-pane",
                                        name="adminPlayerList-panel",
                                        direction = "vertical"};
        ApplyStyle(scrollFrame, my_player_list_fixed_width_style)
        scrollFrame.horizontal_scroll_policy = "never";
        for _,player in pairs(game.players) do
            if player ~= nil then
                local onlineStatus = " " .. HoursAndMinutes(player.online_time);
                if player.connected then
                    onlineStatus = onlineStatus .. " (online)";
                end
                local text=scrollFrame.add{type="label", caption=player.name .. onlineStatus, name=player.name.."_plist"};
                if (player.admin) then
                    ApplyStyle(text, my_player_list_admin_style)
                else
                    ApplyStyle(text, my_player_list_style)
                end
            end
        end
        local spacer = scrollFrame.add{type="label", caption="     ", name="plist_spacer_plist"};
        ApplyStyle(spacer, my_player_list_style_spacer)
    end
end

local function PlayerListGuiClick(event) 
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index];
    local name = event.element.name;

    if (name == "adminPlayerList") then
        ExpandPlayerListGui(player)        
    end
end


Event.register(defines.events.on_gui_click, PlayerListGuiClick);
Event.register(defines.events.on_player_joined_game, CreatePlayerListGui);
