

commands.add_command("kit", "give a start kit", function(command)
    local player = game.players[command.player_index];
    if player ~= nil and player.admin then
        local target = player
        if (command.parameter ~= nil) then
            target = game.players[command.parameter]
        end
        if target ~= nil then
            GivePlayerStarterItems(target);
            player.print("gave a kit to " .. target.name);
            target.print("you have been given a start kit");
        else
            player.print("no player " .. command.parameter);
        end
    end
end)
