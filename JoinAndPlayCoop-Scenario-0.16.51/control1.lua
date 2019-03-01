--[[

Copyright 2018 Chrisgbk
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]
-- MIT License, https://opensource.org/licenses/MIT

-- The point of this file (currently) is to support automatic permission mapping
-- If you want more granularity in permissions, let me know and I can add additional steps
-- ie: Default -> Trusted -> Moderator -> Admin -> Superadmin
-- Instead of the current Default -> Trusted -> Admin
-- WIP!
-- hotpatch-multimod compatible (see https://mods.factorio.com/mod/hotpatch-multimod for info)

local default_admin_group = 'Admin'
local default_trusted_group = 'Trusted'
-- format: [name] = group
local auto_permission_users = {}

-- helper functions
local function set_group_permissions(group, actions, treat_actions_as_blacklist)
    actions = actions or {}
    if treat_actions_as_blacklist then
        -- enable all default permissions
        for _,a in pairs(defines.input_action) do 
            group.set_allows_action(a, true)
        end
        -- disable selected actions
        for _, a in pairs(actions) do
            group.set_allows_action(a, false)
        end 
    else
        -- disable all default permissions
        for _,a in pairs(defines.input_action) do 
            group.set_allows_action(a, false)
        end
        -- enable selected actions
        for _, a in pairs(actions) do
            group.set_allows_action(a, true)
        end 
    end
end

local function permissions_init()
    -- This is for cheat/mod permissions, part of a big TODO and not used yet
    global.permissions = global.permissions or {}
    
    -- get and create permission groups
    local default = game.permissions.get_group('Default')
    local trusted = game.permissions.get_group(default_trusted_group) or game.permissions.create_group(default_trusted_group)
    local admin = game.permissions.get_group(default_admin_group) or game.permissions.create_group(default_admin_group)
    
    -- explicitly enable all actions for admins
    -- seems that create_group enables all permissions in GUI, might be same for code?
    -- so this might not be needed unless permissions want to be restricted for admins???
    set_group_permissions(admin, nil, true)
    
    --handle hotpatching
    for k, v in pairs(game.players) do 
        local group = auto_permission_users[v.name]
        if v.admin and not group then
            game.permissions.get_group(default_admin_group).add_player(v)
        else
            game.permissions.get_group(group).add_player(v)
        end
    end
    
    -- restrict trusted users from only these actions
    -- Permissions require admin powers anyhow, but hey, why not be extra-super-sure
    local trusted_actions_blacklist = {
        defines.input_action.add_permission_group,
        defines.input_action.edit_permission_group,
        defines.input_action.delete_permission_group
    }
    set_group_permissions(trusted, trusted_actions_blacklist, true)
    
    -- New joins can only use these actions
    local actions = {
        defines.input_action.add_permission_group,
        defines.input_action.edit_permission_group,
        defines.input_action.delete_permission_group,
		defines.input_action.deconstruct
    }
    
    set_group_permissions(default, actions, true)
end

script.on_init(function()
    permissions_init()
end)

script.on_configuration_changed(function(event)
    permissions_init()
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    -- this is part of a much larger TODO
    global.permissions[event.player_index] = global.permissions[event.player_index] or {}
    
    -- Handle hot-patching into active games
    local player = game.players[event.player_index]
    local group = auto_permission_users[player.name]
    if player.admin and not group then
        game.permissions.get_group(default_admin_group).add_player(player)
    else
        game.permissions.get_group(group).add_player(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    -- Handle local hosting auto-promote
    if game.players[event.player_index].admin then
        game.permissions.get_group(default_admin_group).add_player(event.player_index);
    end
end)



script.on_event(defines.events.on_player_demoted, function(event)
    --  auto-remove
    game.permissions.get_group('Default').add_player(event.player_index);
end)

script.on_event(defines.events.on_console_command, function(event)
    -- auto-remove kicked/banned players, except admins
    -- only run this if ran by admin
    -- Note: if anyone on the server can run code(and not just admins), they can raise an event and pretend to be the console and trigger this
    -- Another reason why you shouldn't give anyone but admins access to lua commands
    -- This only allows the Trusted group to remove Trusted status in any case, so its not severe.
    local caller = ((event.player_index and game.players[event.player_index]) or game.player) or _ENV
    if (caller == _ENV) or caller.admin then
        if (event.command == 'kick') or (event.command == 'ban') then
            local player = game.players[event.parameters]

            if player and not player.admin then
                game.permissions.get_group('Default').add_player(player);
            end
        end
    end
end)

commands.add_command('reloadperms', 'Reload permissions', function(event)
    -- this will rebuild permissions, if they get messed up somehow
    local caller = (event.player_index and game.players[event.player_index]) or _ENV
    if (caller == _ENV) or caller.admin then
        permissions_init()
        caller.print('Permissions reloaded.');
    else
        caller.print('You must be an admin to run this command.');
    end
end)

local function trust_player(caller, player)
    if player then
        if player.admin then
            caller.print('Player is admin.');
        else
            game.permissions.get_group(default_trusted_group).add_player(player);
            caller.print('Player now trusted.');
        end
    else
        caller.print('Player not found.');
    end
end

commands.add_command('trust', 'Trust a player', function(event)
    -- Convenience command to add a player to the trusted group without opening the permissions GUI
    local caller = (event.player_index and game.players[event.player_index]) or _ENV
    if (caller == _ENV) or caller.admin then
        local player = event.parameter and game.players[event.parameter]
        
        trust_player(caller, player)    
    else
        caller.print('You must be an admin to run this command.');
    end
end)

commands.add_command('trustid', 'Trust a player ID', function(event)
    -- Convenience command to add a playerid to the trusted group without opening the permissions GUI
    local caller = (event.player_index and game.players[event.player_index]) or _ENV
    if (caller == _ENV) or caller.admin then
        local playerid = tonumber(event.parameter)
        local player = playerid and game.players[playerid] 

        trust_player(caller, player)   
    else
        caller.print('You must be an admin to run this command.');
    end
end)

-- This is also part of a big TODO
local remote_interface = {}

remote_interface['add_group'] = function(name, actions, treat_actions_as_blacklist)
    local caller = game.player or _ENV
    if (caller == _ENV) or caller.admin then
        local group = game.permissions.get_group(name) or game.permissions.create_group(name)
        set_group_permissions(group, actions, treat_actions_as_blacklist)
    end
end

remote_interface['set_auto_permission_user_list'] = function(list)
    -- format: [name] = group
    -- TODO: optimize to eliminate redundant calls, large numbers of users will be slow in a dumb way
    local caller = game.player or _ENV
    if (caller == _ENV) or caller.admin then
        for k, v in pairs(list) do
            if not game.permissions.get_group(v) then
            --error, list contains a group that doesn't exist
            end
        end
        auto_permission_users = list
    end
end

remote.add_interface('permissions', remote_interface)