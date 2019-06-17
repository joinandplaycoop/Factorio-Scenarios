
local function HoursAndMinutes(ticks)
    local seconds = ticks/TICKS_PER_SECOND;
    local minutes = math.floor((seconds)/60);
    local hours = math.floor(minutes/60);
    minutes = minutes - 60 * hours;
    return string.format("%3d:%02d", hours, minutes);
end

local function StatusCommand_ShowStatus(player, xplayer)
    if xplayer ~= nil then
       local status = string.format("%s played %s. Location %d,%d",
              xplayer.name,
              HoursAndMinutes(xplayer.online_time),
              math.floor(xplayer.position.x),
              math.floor(xplayer.position.y));
       game.player.print(status);
    end
end

commands.remove_command("status");
commands.add_command("status", "shows your location, time in game", function(command)
    local players = {};
    for _,p in pairs(game.players) do
        if p ~= nil then
            players[_] = p;
        end
    end
    table.sort(players, 
        function(a,b)
            if a~=nil and b~=nil then
                return a.online_time < b.online_time; 
            end
            return false;
        end
    );
    
    local player = game.player;
    if player ~= nil then
        if (command.parameter ~= nil) then
            StatusCommand_ShowStatus(player, game.players[command.parameter]);
        else
            for _,xplayer in pairs(players) do
                StatusCommand_ShowStatus(player, xplayer);
            end
        end
    end
end)
