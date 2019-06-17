local noise = require "utils.simplex"
local dist = require "utils.distance"
local default_settings = {
    weights = {
      ['iron-ore']    = 0,
      ['copper-ore']  = 0.5,
      ['coal']        = 0.8,
      ['stone']       = 0.95,
    },
    richness = { 50, 200 }
}

local function spawn_resource_patch(surface, position, radius)

  local size = radius / 2
  local rand = math.random()
  local resource

  local mult = 1 + dist({0,0}, position) / 1000
  
  for name, frequenzy in pairs(default_settings.weights) do
    if rand >= frequenzy then
      resource = name
    end
  end



  for y = position.y - size, position.y + size do
    for x = position.x - size, position.x + size do
      local n = noise(x / 20, y / 20) + noise(x / 5, y / 5) * 0.5
      local pos = surface.find_non_colliding_position(resource, {x, y}, 3, 1)
      if not pos then goto continue end
      local d = dist(pos, position)
      local richness = (math.random(default_settings.richness[1], default_settings.richness[2]) * mult)
      if d < size - size * 0.5 then
        surface.create_entity({name = resource, position = pos, amount = richness})
      elseif d < size and n < 0 then
        surface.create_entity({name = resource, position = pos, amount = richness})
      end
      ::continue::
    end
  end

end

return spawn_resource_patch