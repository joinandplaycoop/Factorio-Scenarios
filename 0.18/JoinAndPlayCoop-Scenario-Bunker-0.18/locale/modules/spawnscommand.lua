
local function sbool(b)
    if b then return "true"; else return "false"; end
end
local function sname(n)
    if n then return n; else return "none"; end
end
local function doprint(msg)
    if game.player then
        game.player.print(msg);
    else
        game.write_file("log.txt", msg .. "\n" , true, 0);
    end
end

local function printSpawn(spawn)
    if spawn then
        local sharedName = "";
        if spawn.sharedKey ~= nil then
            sharedName = spawn.sharedKey;
        end
        doprint( string.format("%d: %d,%d used=%s, %s %s", spawn.seq, spawn.x, spawn.y, sbool(spawn.used), sname(spawn.createdFor), sharedName ) );
    end        
end

commands.remove_command("spawns");
commands.add_command("spawns", "info about the spawns", function(command)
    local spawn = global.allSpawns[tonumber(command.parameter)];    
    if spawn ~= nil then
        printSpawn(spawn);
    else
        for _,spawn in pairs(global.allSpawns) do
            printSpawn(spawn);
        end
    end
end)
