
-- From the Toxic Jungle mod. 
-- Original author /u/usernameless_user on reddit
-- Adapted from the version by  nucleargen

local M = {};

-- list of tree entities
local trees = {
  --"dead-dry-hairy-tree",
  --"dead-grey-trunk",
  --"dead-tree",
  --"dry-hairy-tree",
  --"dry-tree",
  --"green-coral",
  "tree-01",
  "tree-02",
  "tree-02-red",
  "tree-03",
  "tree-04",
  "tree-05",
  "tree-06",
  "tree-06-brown",
  "tree-07",
  "tree-08",
  "tree-08-brown",
  "tree-08-red",
  "tree-09",
  "tree-09-brown",
  "tree-09-red"
}

-- chance of a tree being spawned on a tile (density)

function M.ChunkGenerated(event)
  
local tree_chance = scenario.config.toxicJungle.tree_chance;
  local surface = event.surface
  
  -- bottom left of the chunk
  local minx = event.area.left_top.x
  local miny = event.area.left_top.y
  
  -- bottom right of the chunk
  local maxx = event.area.right_bottom.x
  local maxy = event.area.right_bottom.y

  -- iterate left to right
  for x = minx, maxx do
  
    -- iterate up to down
    for y = miny, maxy do
      
      if math.random() < tree_chance then
        -- chose random tree type
        local tree_type = trees[math.random(#trees)]
      
        -- spawn tree
        if surface.can_place_entity{name = tree_type, position = {x, y}} then
          surface.create_entity{name = tree_type, position = {x, y}}
        end
      end
    end
  end
end

return M;
