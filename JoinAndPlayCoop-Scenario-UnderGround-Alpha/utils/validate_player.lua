local function validate_player(player)
  if not player then return false end
  if not player.valid then return false end
  if not player.character then return false end
  if not game.players[player.name] then return false end
  return true
end

return validate_player