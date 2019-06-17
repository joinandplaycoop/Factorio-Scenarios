
local function GivePlayerLongReach(event)
    local player = game.players[event.player_index]
    if player ~= nil and player.character ~= nil and player.valid then
        player.character.character_build_distance_bonus = BUILD_DIST_BONUS
        player.character.character_reach_distance_bonus = REACH_DIST_BONUS
        player.character.character_resource_reach_distance_bonus  = RESOURCE_DIST_BONUS
    end
end

Event.register(defines.events.on_player_respawned, GivePlayerLongReach)
Event.register(defines.events.on_player_joined_game, GivePlayerLongReach)