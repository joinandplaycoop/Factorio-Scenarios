commands.add_command("run", "change player speed bonus", function(command)
    local player = game.players[command.player_index];
    if player ~= nil then
        if (command.parameter ~= nil) then
            if command.parameter == "fast" then
                player.character_running_speed_modifier = 1
            elseif command.parameter == "normal" then
                player.character_running_speed_modifier = 0
            else
                player.print("run fast | slow | normal");
            end
        end
    end
end)
