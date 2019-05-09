local noise = require "utils.simplex"
local dist = require "utils.distance"
local default_settings = {
    weights = {
      ['iron-ore']    = 0.3,
      ['copper-ore']  = 0.4,
      ['coal']        = 0.6,
      ['stone']       = 1,
    },
    richness = {50, 200}
}

local function spawn_ore_patch(surface, position, radius)

  local size = radius / 2
  local rand = math.random()
  local resource
  game.print(rand)
  for name, frequenzy in pairs(default_settings.weights) do
    if rand <= frequenzy then
      resource = name
      break
    end
  end

 


  for y = position.y - size, position.y + size do
    for x = position.x - size, position.x + size do
      local n = noise(x / 20, y / 20) + noise(x / 5, y / 5) * 0.5
      local d = dist({x, y}, position)
      if d < size - size * 0.5 then
        surface.create_entity({name = resource, position = {x, y}, amount = math.random(default_settings.richness[1], default_settings.richness[2])})
      elseif d < size and n < 0 then
        surface.create_entity({name = resource, position = {x, y}, amount = math.random(default_settings.richness[1], default_settings.richness[2])})
      end
    end
  end

end

return spawn_ore_patch