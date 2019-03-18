-- separate_spawns_guis.lua
-- Nov 2016

-- I made a separate file for all the GUI related functions

require("separate_spawns")

local SPAWN_GUI_MAX_WIDTH = 1000
local SPAWN_GUI_MAX_HEIGHT = 1000
-- local SPAWN_GUI_MIN_WIDTH = 400
-- local SPAWN_GUI_MIN_HEIGHT = 400



-- A display gui message
-- Meant to be display the first time a player joins.
function DisplayWelcomeTextGui(player)
    player.gui.center.add{name = "welcome_msg",
                            type = "frame",
                            direction = "vertical",
                            caption=WELCOME_MSG_TITLE}
    local wGui = player.gui.center.welcome_msg

    wGui.style.maximal_width = SPAWN_GUI_MAX_WIDTH
    wGui.style.maximal_height = SPAWN_GUI_MAX_HEIGHT

    local ix = 0
    for _,msg in pairs(scenario.config.welcomeMessages) do
        local name = "welcome_msg_lbl" .. ix
        local style = my_label_style
        if  string.sub(msg,1,2) == "/w" then
            style = my_warning_style
            msg = string.sub(msg,4)
        end
        wGui.add{name = name, type = "label", caption=msg}
        if msg == "" then
            ApplyStyle(wGui[name], my_spacer_style)
        else
            ApplyStyle(wGui[name], style)
        end
        ix = ix + 1
    end


    wGui.add{name = "welcome_okay_btn",
                    type = "button",
                    caption="I Understand"}
end


-- Handle the gui click of the welcome msg
function WelcomeTextGuiClick(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    local buttonClicked = event.element.name

    if (buttonClicked == "welcome_okay_btn") then
        if (player.gui.center.welcome_msg ~= nil) then
            player.gui.center.welcome_msg.destroy()
        end
        DisplaySpawnOptions(player)
    end
end


-- Display the spawn options and explanation
function DisplaySpawnOptions(player)
    player.gui.center.add{name = "spawn_opts",
                            type = "frame",
                            direction = "vertical",
                            caption="Spawn Options"}
    local sGui = player.gui.center.spawn_opts
    sGui.style.maximal_width = SPAWN_GUI_MAX_WIDTH
    sGui.style.maximal_height = SPAWN_GUI_MAX_HEIGHT
--    sGui.style.maximal_width = SPAWN_GUI_MIN_WIDTH
--    sGui.style.maximal_height = SPAWN_GUI_MIN_HEIGHT


    -- Warnings and explanations...
    sGui.add{name = "warning_lbl1", type = "label",
                    caption="This is your ONLY chance to choose a spawn option. Choose carefully..."}
    sGui.add{name = "warning_spacer", type = "label",
                    caption=" "}
    ApplyStyle(sGui.warning_lbl1, my_warning_style)
    ApplyStyle(sGui.warning_spacer, my_spacer_style)

    sGui.add{name = "spawn_msg_lbl1", type = "label",
                    caption=SPAWN_MSG1}
    sGui.add{name = "spawn_msg_lbl2", type = "label",
                    caption=SPAWN_MSG2}
    sGui.add{name = "spawn_msg_lbl3", type = "label",
                    caption=SPAWN_MSG3}
    sGui.add{name = "spawn_msg_spacer", type = "label",
                    caption="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"}
    ApplyStyle(sGui.spawn_msg_lbl1, my_label_style)
    ApplyStyle(sGui.spawn_msg_lbl2, my_label_style)
    ApplyStyle(sGui.spawn_msg_lbl3, my_label_style)
    ApplyStyle(sGui.spawn_msg_spacer, my_spacer_style)


    if ENABLE_DEFAULT_SPAWN then
        sGui.add{name = "default_spawn_btn",
                        type = "button",
                        caption="Default Spawn"}
        sGui.add{name = "normal_spawn_lbl1", type = "label",
                        caption="This is the default spawn behavior of a vanilla game."}
        sGui.add{name = "normal_spawn_lbl2", type = "label",
                        caption="You join the default team in the center of the map."}
        sGui.add{name = "normal_spawn_lbl3", type = "label",
                        caption="(Back by popular request...)"}
        ApplyStyle(sGui.normal_spawn_lbl1, my_label_style)
        ApplyStyle(sGui.normal_spawn_lbl2, my_label_style)
        ApplyStyle(sGui.normal_spawn_lbl3, my_label_style)
    else
        sGui.add{name = "normal_spawn_lbl1", type = "label",
                        caption="Default spawn is disabled in this mode."}
        ApplyStyle(sGui.normal_spawn_lbl1, my_warning_style)
    end
    sGui.add{name = "normal_spawn_spacer", type = "label",
                    caption="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"}
    ApplyStyle(sGui.normal_spawn_spacer, my_spacer_style)

    if GetNumberOfAvailableSoloSpawns() > 0 then  
        -- The main spawning options. Solo near and solo far.
        sGui.add{name = "isolated_spawn_near",
                        type = "button",
                        caption="Solo Spawn (Near)"}
        sGui.add{name = "isolated_spawn_far",
                        type = "button",
                        caption="Solo Spawn (Far)"}
        sGui.add{name = "isolated_spawn_lbl1", type = "label",
                        caption="You are spawned in a new area, with some starting resources."}
        sGui.add{name = "isolated_spawn_lbl2", type = "label",
                        caption="You will still be part of the default team."}
        sGui.add{name = "isolated_spawn_spacer", type = "label",
                        caption="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"}
        ApplyStyle(sGui.isolated_spawn_lbl1, my_label_style)
        ApplyStyle(sGui.isolated_spawn_lbl2, my_label_style)
        ApplyStyle(sGui.isolated_spawn_spacer, my_spacer_style)
    else
        sGui.add{name = "isolated_spawn_lbl1", type = "label",
                        caption="There are no more solo spawns available."}
        ApplyStyle(sGui.normal_spawn_lbl1, my_warning_style)
    end


    -- Spawn options to join another player's base.
    if ENABLE_SHARED_SPAWNS then
        local numAvailSpawns = sharedSpawns.getNumberOfAvailableSharedSpawns()
        if (numAvailSpawns > 0) then
            sGui.add{name = "join_other_spawn",
                            type = "button",
                            caption="Join Someone (" .. numAvailSpawns .. " available)"}
            sGui.add{name = "join_other_spawn_lbl1", type = "label",
                            caption="You are spawned in someone else's base."}
            sGui.add{name = "join_other_spawn_lbl2", type = "label",
                            caption="This requires at least 1 person to have allowed access to their base."}
            sGui.add{name = "join_other_spawn_lbl3", type = "label",
                            caption="This choice is final and you will not be able to create your own spawn later."}
            sGui.add{name = "join_other_spawn_spacer", type = "label",
                            caption=" "}
            ApplyStyle(sGui.join_other_spawn_lbl1, my_label_style)
            ApplyStyle(sGui.join_other_spawn_lbl2, my_label_style)
            ApplyStyle(sGui.join_other_spawn_lbl3, my_label_style)
            ApplyStyle(sGui.join_other_spawn_spacer, my_spacer_style)
        else
            sGui.add{name = "join_other_spawn_lbl1", type = "label",
                            caption="There are currently no shared bases availble to spawn at."}
            sGui.add{name = "join_other_spawn_spacer", type = "label",
                            caption=" "}
            ApplyStyle(sGui.join_other_spawn_lbl1, my_warning_style)
            ApplyStyle(sGui.join_other_spawn_spacer, my_spacer_style)
            sGui.add{name = "join_other_spawn_check",
                            type = "button",
                            caption="Check Again"}
        end
    else
        sGui.add{name = "join_other_spawn_lbl1", type = "label",
                        caption="Shared spawns are disabled in this mode."}
        ApplyStyle(sGui.join_other_spawn_lbl1, my_warning_style)
    end

    -- Some final notes
    sGui.add{name = "note_spacer1", type = "label",
                    caption="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"}
    sGui.add{name = "note_spacer2", type = "label",
                    caption=" "}

    if MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN then
        sGui.add{name = "shared_spawn_note1", type = "label",
                    caption="If you create your own spawn point you can allow up to " .. MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN-1 .. " other online players to join." }
        ApplyStyle(sGui.shared_spawn_note1, my_note_style)
    end
--    sGui.add{name = "note_lbl1", type = "label",
--                    caption="Near spawn is between " .. NEAR_MIN_DIST*CHUNK_SIZE .. "-" .. NEAR_MAX_DIST*CHUNK_SIZE ..  " tiles away from the center of the map."}
--    sGui.add{name = "note_lbl2", type = "label",
--                    caption="Far spawn is between " .. FAR_MIN_DIST*CHUNK_SIZE .. "-" .. FAR_MAX_DIST*CHUNK_SIZE ..  " tiles away from the center of the map."}
    sGui.add{name = "note_lbl3", type = "label",
                    caption="Solo spawns are dangerous! Expect a fight to reach other players."}
    sGui.add{name = "note_spacer3", type = "label",
                    caption=" "}
--    ApplyStyle(sGui.note_lbl1, my_note_style)
--    ApplyStyle(sGui.note_lbl2, my_note_style)
    ApplyStyle(sGui.note_lbl3, my_note_style)
    ApplyStyle(sGui.note_spacer1, my_spacer_style)
    ApplyStyle(sGui.note_spacer2, my_spacer_style)
    ApplyStyle(sGui.note_spacer3, my_spacer_style)
end


-- Handle the gui click of the spawn options
function SpawnOptsGuiClick(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    local buttonClicked = event.element.name
    local config = spawnGenerator.GetConfig()


    -- Check if a valid button on the gui was pressed
    -- and delete the GUI
    if ((buttonClicked == "default_spawn_btn") or
        (buttonClicked == "isolated_spawn_near") or
        (buttonClicked == "isolated_spawn_far") or
        (buttonClicked == "join_other_spawn") or
        (buttonClicked == "join_other_spawn_check")) then

        if (player.gui.center.spawn_opts ~= nil) then
            player.gui.center.spawn_opts.destroy()
        end

    end

    if (buttonClicked == "default_spawn_btn") then
        CreateSpawnCtrlGui(player)
        GivePlayerStarterItems(player)
        ChangePlayerSpawn(player, player.force.get_spawn_position(GAME_SURFACE_NAME), GAME_SURFACE_NAME, 0)
        SendPlayerToSpawn(player)
        logAndBroadcast(player.name, player.name .. " joined the main force!")
        ChartArea(player.force, player.position, 4)

    elseif ((buttonClicked == "isolated_spawn_near") or (buttonClicked == "isolated_spawn_far")) then
        CreateSpawnCtrlGui(player)

        local newSpawn = nil;
        -- Create a new spawn point
        if player.index == 1 and config.extraSpawn ~= nil then
            if (config.extraSpawn < #global.allSpawns) then
                newSpawn = global.allSpawns[config.extraSpawn];
            else
                newSpawn = global.allSpawns[#global.allSpawns];
            end
        end
        if newSpawn == nil then
            newSpawn = PickRandomSpawn( global.allSpawns, buttonClicked == "isolated_spawn_far");
        end
        if newSpawn == nil then
            -- no spawn of the type requested. just pick one
            newSpawn = PickRandomSpawn( global.allSpawns, buttonClicked ~= "isolated_spawn_far");
        end
        
        
        GivePlayerStarterItems(player)
        if newSpawn == nil then
            player.print("Sorry! You have been assigned to the default spawn.")
            ChangePlayerSpawn(player, player.force.get_spawn_position(GAME_SURFACE_NAME), GAME_SURFACE_NAME, 0)
            SendPlayerToSpawn(player)
            logAndBroadcast(player.name, player.name .. " joined the default spawn!")
            ChartArea(player.force, player.position, 4)
        else
            local used = newSpawn.used;
            newSpawn.used = true;
            newSpawn.createdFor = player.name

            if used then
                ChangePlayerSpawn(player, newSpawn, GAME_SURFACE_NAME, newSpawn.seq)
                SendPlayerToSpawn(player)
                player.print("Sorry! You have been assigned to an abandoned base! This is done to keep map size small.")
                logAndBroadcast(player.name, player.name .. " joined an abandoned base!")
            else
                ChangePlayerSpawn(player, newSpawn, GAME_SURFACE_NAME, newSpawn.seq)
                SendPlayerToNewSpawnAndCreateIt(player, newSpawn)
                player.print("PLEASE WAIT WHILE YOUR SPAWN POINT IS GENERATED!")
                logAndBroadcast(player.name, player.name .. " joined a new base!")
                ChartArea(player.force, player.position, 4)
            end
        end
    elseif (buttonClicked == "join_other_spawn") then
        DisplaySharedSpawnOptions(player)
    
    -- Provide a way to refresh the gui to check if people have shared their
    -- bases.
    elseif (buttonClicked == "join_other_spawn_check") then
        DisplaySpawnOptions(player)
    end
end

function boolToString( b )
  if b then
    return "true"
  else
    return "false";
  end
end

function SpawnIsCompatible( spawnPos, far )
  local distSqr = spawnPos.x^2 + spawnPos.y^2;
  local dist = math.sqrt(distSqr);
  -- local isFar = true
  local compatible = true; -- (isFar == far);
  local player = game.players[1];
  
  -- player.print("Spawn " .. spawnPos.x .. ", " .. spawnPos.y .. " dist" .. dist .. " is far = " .. boolToString(isFar) .. " compatible=" .. boolToString(compatible) .. " req far " .. boolToString(far)  );
  return compatible;
end

function DistanceFromUsedSpawns( pick )
  local minDist = 999999
  for key, spawnPos in pairs(global.allSpawns) do
    if spawnPos.used then
        local dx = spawnPos.x - pick.x
        local dy = spawnPos.y - pick.y
        local dist = math.sqrt( dx*dx + dy*dy)
        if dist < minDist then
            minDist = dist
        end
    end
  end
  return minDist
end

function PickRandomSpawn( t, far )
  -- local player = game.players[1];
  local config = spawnGenerator.GetConfig()
  local candidates = {}
  for key, spawnPos in pairs(t) do
    if spawnPos ~= nil and (not spawnPos.used) and SpawnIsCompatible( spawnPos, far ) then
        spawnPos.key = key;
	if config.preferFar then
            spawnPos.dist = DistanceFromUsedSpawns(spawnPos)
        else
            spawnPos.dist = math.abs(spawnPos.y)
        end
        table.insert( candidates, spawnPos );
    end
  end
  if far then
    table.sort (candidates, function (k1, k2) return k1.dist > k2.dist end )
  else
    table.sort (candidates, function (k1, k2) return k1.dist < k2.dist end )
  end
  local ncandidates = TableLength(candidates)
  if ncandidates > 5 then
        ncandidates = 5; -- math.floor((ncandidates+1)/3)
  end
  -- player.print("choosing a spawn from " .. ncandidates .. " candidates");
  if ncandidates > 0 then
    local pick = math.random(1,ncandidates)
    spawnPos = candidates[pick];
    -- player.print("chose " .. spawnPos.x .. "," .. spawnPos.y .. " distance " .. spawnPos.dist);
    return spawnPos;
  end
  return nil;
end

-- Display the spawn options and explanation
function DisplaySharedSpawnOptions(player)
    player.gui.center.add{name = "shared_spawn_opts",
                            type = "frame",
                            direction = "vertical",
                            caption="Available Bases to Join:"}

    local shGuiFrame = player.gui.center.shared_spawn_opts
    local shGui = shGuiFrame.add{type="scroll-pane", name="spawns_scroll_pane", caption=""}
    ApplyStyle(shGui, my_fixed_width_style)
    shGui.style.maximal_width = 1500; -- SPAWN_GUI_MAX_WIDTH
    shGui.style.maximal_height = 700; -- SPAWN_GUI_MAX_HEIGHT
    shGui.horizontal_scroll_policy = "always";
    shGui.vertical_scroll_policy = "always";
--    shGui.style.minimal_width = SPAWN_GUI_MIN_WIDTH
--    shGui.style.minimal_height = SPAWN_GUI_MIN_HEIGHT
--    shGui.can_scroll_horizontally = false

    local camera_style = {
        minimal_width = 1000,
        maximal_width = 1000,
        minimal_height = 500,
        maximal_height = 500,
    }

    local spawnFrameStyle = {
        minimal_width = 1000,
        maximal_width = 1000,
        minimal_height = 500,
        maximal_height = 500,
    }

    local spawnIndex = 0
    for spawnName,sharedSpawn in pairs(global.sharedSpawns) do
        if sharedSpawn.openAccess then
            local spotsRemaining = MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN - sharedSpawns.getOnlinePlayersAtSharedSpawn(sharedSpawn)
            if (spotsRemaining > 0) then
                local spawnFrame = shGui.add({ type="frame", direction="vertical"});
                ApplyStyle( spawnFrame, spawnFrameStyle );

                spawnFrame.add{type="button", caption=" (" .. spotsRemaining .. " spots remaining)", name=spawnName }
                ApplyStyle(spawnFrame[spawnName], my_small_button_style)

                spawnFrame.add{name = spawnName .. "spacer_lbl", type = "label", caption=" "}
                ApplyStyle(spawnFrame[spawnName .. "spacer_lbl"], my_spacer_style)

                local playersAtSpawn = ""
                for _,playerName in pairs( sharedSpawn.players ) do
                    if playerName ~= nil then
                        playersAtSpawn = playersAtSpawn .. " " .. playerName;
                    end
                end
                local playerList = spawnFrame.add{name = spawnName .. "players", type = "label", caption= playersAtSpawn }
                ApplyStyle(playerList, my_note_style)

                spawnFrame.add{name = spawnName .. "camera", type = "camera", position=sharedSpawn.position, surface_index=game.surfaces[GAME_SURFACE_NAME].index, zoom=0.2 }
                ApplyStyle(spawnFrame[spawnName .. "camera"], camera_style)
            end
        end
    end


    shGui.add{name = "shared_spawn_cancel",
                    type = "button",
                    caption="Cancel (Return to Previous Options)"}
end

-- Handle the gui click of the shared spawn options
function SharedSpwnOptsGuiClick(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    local buttonClicked = event.element.name  

    -- Check for cancel button, return to spawn options
    if (buttonClicked == "shared_spawn_cancel") then
        DisplaySpawnOptions(player)
        if (player.gui.center.shared_spawn_opts ~= nil) then
            player.gui.center.shared_spawn_opts.destroy()
        end

    -- Else check for which spawn was selected
    -- If a spawn is removed during this time, the button will not do anything
    else
        for spawnKey,sharedSpawn in pairs(global.sharedSpawns) do
            if (buttonClicked == spawnKey) then
                CreateSpawnCtrlGui(player)
                ChangePlayerSpawn(player,sharedSpawn.position, GAME_SURFACE_NAME, sharedSpawn.seq)
                SendPlayerToSpawn(player)
                GivePlayerStarterItems(player)
                sharedSpawns.addPlayerToSharedSpawn(sharedSpawn, player.name);
                logAndBroadcast(player.name, player.name .. " joined " .. spawnKey .. " !")
                if (player.gui.center.shared_spawn_opts ~= nil) then
                    player.gui.center.shared_spawn_opts.destroy()
                end
                break
            end
        end
    end
end


function CreateSpawnCtrlGui(player)
  if player.gui.top.spwn_ctrls == nil then
      player.gui.top.add{name="spwn_ctrls", type="button", caption="Spawn Ctrl"}
  end   
end


local function IsSharedSpawnActive(player)
    local sharedSpawn = sharedSpawns.findSharedSpawn(player.name);
    return sharedSpawn ~= nil and sharedSpawn.openAccess;
end


-- This is a toggle function, it either shows or hides the spawn controls
function ExpandSpawnCtrlGui(player, tick)
    local spwnCtrlPanel = player.gui.left["spwn_ctrl_panel"]
    if (spwnCtrlPanel) then
        spwnCtrlPanel.destroy()
    else
        local spwnCtrlPanel = player.gui.left.add{type="frame",
                            name="spwn_ctrl_panel", caption="Spawn Controls:"}
        local spwnCtrls = spwnCtrlPanel.add{type="scroll-pane",
                            name="spwn_ctrl_scroll_pane", caption=""}
        ApplyStyle(spwnCtrls, my_fixed_width_style)
        spwnCtrls.style.maximal_height = SPAWN_GUI_MAX_HEIGHT
        -- spwnCtrls.can_scroll_horizontally = false;

        if ENABLE_SHARED_SPAWNS then
            if (GetUniqueSpawn(player.name) ~= nil) then
                -- This checkbox allows people to join your base when they first
                -- start the game.
                spwnCtrls.add{type="checkbox", name="accessToggle",
                                caption="Allow others to join your base.",
                                state=IsSharedSpawnActive(player)}
                spwnCtrls["accessToggle"].style.top_padding = 10
                spwnCtrls["accessToggle"].style.bottom_padding = 10
                ApplyStyle(spwnCtrls["accessToggle"], my_fixed_width_style)
            end
        end


        -- Sets the player's custom spawn point to their current location
        if ((tick - global.playerCooldowns[player.name].setRespawn) > RESPAWN_COOLDOWN_TICKS) then
            spwnCtrls.add{type="button", name="setRespawnLocation", caption="Set New Respawn Location (1 hour cooldown)"}
            spwnCtrls["setRespawnLocation"].style.font = "default-small-semibold"
            spwnCtrls.add{name = "respawn_cooldown_note2", type = "label",
                    caption="This will set your respawn point to your current location."}
            spwnCtrls.add{name = "respawn_cooldown_spacer1", type = "label",
                caption=" "}
            ApplyStyle(spwnCtrls.respawn_cooldown_note2, my_note_style)
            ApplyStyle(spwnCtrls.respawn_cooldown_spacer1, my_spacer_style)   
        else
            spwnCtrls.add{name = "respawn_cooldown_note1", type = "label",
                    caption="Set Respawn Cooldown Remaining: " .. formattime(RESPAWN_COOLDOWN_TICKS-(tick - global.playerCooldowns[player.name].setRespawn))}
             spwnCtrls.add{name = "respawn_cooldown_note2", type = "label",
                    caption="This will set your respawn point to your current location."}
            spwnCtrls.add{name = "respawn_cooldown_spacer1", type = "label",
                caption=" "}
            ApplyStyle(spwnCtrls.respawn_cooldown_note1, my_note_style)
            ApplyStyle(spwnCtrls.respawn_cooldown_note2, my_note_style)
            ApplyStyle(spwnCtrls.respawn_cooldown_spacer1, my_spacer_style)            
        end
    end
end


function SpawnCtrlGuiClick(event) 
   if not (event and event.element and event.element.valid) then return end
        
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "spwn_ctrls") then
        ExpandSpawnCtrlGui(player, event.tick)       
    end

    -- Sets a new respawn point and resets the cooldown.
    if (name == "setRespawnLocation") then
        if DoesPlayerHaveCustomSpawn(player) then
            local playerSpawn = global.playerSpawns[player.name];
            ChangePlayerSpawn(player, player.position, player.surface.name, playerSpawn.seq)
            global.playerCooldowns[player.name].setRespawn = event.tick
            ExpandSpawnCtrlGui(player, event.tick) 
            player.print("Re-spawn point updated!")
        end
    end
end

function SpawnCtrlGuiCheckStateChanged(event)
   if not (event and event.element and event.element.valid) then return end
        
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "accessToggle") then
        local spwnAccessState = event.element.state
        local sharedSpawn = sharedSpawns.findSharedSpawn(player.name)
        if spwnAccessState then
            if sharedSpawn == nil then
                sharedSpawn = sharedSpawns.createNewSharedSpawn(player)
            end
            sharedSpawn.openAccess = true
            logAndBroadcast(player.name, "New players can now join " .. player.name ..  "'s base!")
            ExpandSpawnCtrlGui(player, event.tick)
        else
            if sharedSpawn ~= nil then
                sharedSpawn.openAccess = false
            end
            logAndBroadcast(player.name, "New players can no longer join " .. player.name ..  "'s base!")
            ExpandSpawnCtrlGui(player, event.tick)
        end
    end
end
