
-- thin out a vertical stripe 128 tiles wide
-- eg decimate 0 thins out columns x=-128..128
-- decimate 1 things out columns 128 .. 384
-- only affects chunks that have been generated.
commands.add_command("decimate", "thin out the biters", function(command)
    local player = game.players[command.player_index];
    if player ~= nil and player.admin then
        local evo =  game.forces['enemy'].evolution_factor
        local kk = tonumber(command.parameter)
        local high = 16000; 
        local wide = 128; 
        local pos = { x=kk * 2 * wide, y=0 }  
        local area = {{pos.x - wide, pos.y - high}, {pos.x + wide, pos.y + high}}
        local things =  { "small-spitter", "medium-spitter", "big-spitter", "behemoth-spitter", "small-biter", "medium-biter", "big-biter", "behemoth-biter", "spitter-spawner", "biter-spawner", "small-worm-turret", "medium-worm-turret", "big-worm-turret" }
        local surface = player.surface 
        for _, enemyName in pairs( things ) do
            player.print(enemyName);
            player.print(surface.count_entities_filtered{area = area, name = enemyName})     
            for _, entity in pairs(surface.find_entities_filtered{area = area, name = enemyName}) do 
                entity.die() 
            end 
        end
        game.forces['enemy'].evolution_factor = evo
    end
end)
