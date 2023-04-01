commands.add_command("item", "<item-name> <count>", function(command)
    local player = game.players[command.player_index]
    if player ~= nil and player.admin then
      local p = {}
      for i in string.gmatch(command.parameter or "nil", "%S+") do
        table.insert(p, i)
      end
      if #p ~= 2 then
        player.print("Invalid Parameters")
      else
        local name = p[1]
        local count = tonumber(p[2])
        if count then
          local func,err = pcall(player.insert, {name=name, count=count})
            if func then
              local item = p[1]
              local icount = p[2]
              player.print(item .. "(" .. icount .. ")" .. " added to inventory.")
            else
              player.print("Invalid Parameters: " .. err)
            end
        else
          player.print("Invalid Parameters")
        end
      end
    else
      player.print("Unable to run command, must be an admin.")
    end
end)