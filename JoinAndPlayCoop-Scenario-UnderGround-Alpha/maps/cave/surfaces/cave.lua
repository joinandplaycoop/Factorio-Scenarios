local Event = require "utils.event"
local Global = require "utils.global"
local Schedule = require "utils.schedule"

local spawn_resource_patch = require "utils.spawn_resource_patch"
local flying_text = require "utils.flying_text"
local validate_player = require "utils.validate_player"
local dist = require "utils.distance"
local sizeof = require "utils.sizeof"
local noise2d = require "utils.simplex"

local in_darkness_warned = {}

Global.register({ 
  in_darkness_warned = in_darkness_warned
}, function(global)
  in_darkness_warned = global.in_darkness_warned
end)



local seed = 1653432

local chest_items = {
  { name = "raw-fish", count = {1, 5} },
  { name = "solid-fuel", count = {5, 10} },
  { name = "rail", count = {5, 10} },
  { name = "inserter", count = {1, 2} },
  { name = "landfill", count = {25, 50} },
  { name = "coin", count = {1, 35} },
  { name = "small-electric-pole", count = {1, 63} },
  { name = "battery", count = {5, 30} },
  { name = "submachine-gun", count = {1, 1} },
  { name = "pistol", count = {1, 1} },
  { name = "firearm-magazine", count = {25, 100} },
  { name = "gun-turret", count = {1, 3} },
  { name = "heavy-armor", count = {1, 1} },
  { name = "automation-science-pack", count = {5, 30} },
  { name = "logistic-science-pack", count = {5, 30} },
  { name = "chemical-science-pack", count = {1, 3} },
  { name = "repair-pack", count = {5, 15} },
  { name = "iron-gear-wheel", count = {25, 73} },
  { name = "electronic-circuit", count = {5, 10} },
  { name = "crude-oil-barrel", count = {10, 50} },
  { name = "piercing-rounds-magazine", count = {25, 100} },
}


local rocks = {
  "rock-huge",
  "rock-big",
  "sand-rock-big"
}

local trees = {
  "tree-06-brown",
  "tree-06",
  "tree-08-brown",
  "dead-tree-desert"
}

local resources = {
  "iron-ore",
  "copper-ore",
  "coal",
}


local mined_rock_entities = {
  ["iron-ore"]    = {  10, 50 },
  ["copper-ore"]  = {  10, 50 },
  ["coal"]        = {  10, 50 },
  ["stone"]       = {  10, 50 },
  ["uranium-ore"]  = {  5, 20 },
}

local function noise_octaves(x, y, octaves, persistence)
  local value = 0
  local amplitude = 1
  local frequency = 1
  local max =  0
  for i = 0, octaves do 
    value = value + noise(x * frequency,y * frequency) * amplitude
    amplitude = amplitude * persistence;
    frequency = frequency * 2;
    max = max + amplitude
  end
  return value / max
end

local function initialize_surface(surface)
  surface.map_gen_settings = {
      autoplace_controls = {
          ["coal"]        = { frequency = "none" },
          ["copper-ore"]  = { frequency = "none" },
          ["crude-oil"]   = { frequency = "none" },
          ["enemy-base"]  = { frequency = "none" },
          ["iron-ore"]    = { frequency = "none" },
          ["stone"]       = { frequency = "none" },
          ["trees"]       = { frequency = "none" },
          ["uranium-ore"] = { frequency = "none" }
      },
      default_enable_all_autoplace_controls = false,
      autoplace_settings = {
          entity = { frequency = "none" },
          tile = { frequency = "none" },
          
      },
      water = "none",
      peaceful_mode = false,
      starting_area = "none",
      terrain_segmentation = "none",
      research_queue_from_the_start = "always",
      property_expression_names = {
          moisture = 0,
          aux = 0.5,
          temperature = 25,
          cliffiness = 0
      }
  }
  surface.peaceful_mode = false
  surface.freeze_daytime = 1
  surface.daytime = 0.5
  game.forces.player.technologies["coal-liquefaction"].researched = true
end

local function chunk_generated(event)
  local area = event.area
  local surface = event.surface

  local tiles = {}

  if surface.name ~= "cave" then return end

  for y = area.left_top.y, area.right_bottom.y do
    for x = area.left_top.x, area.right_bottom.x do

      local distance = dist({x, y}, {0, 0})

      local px = x + seed
      local py = y + seed

      local tile
      local n1 = noise2d(px / 450, py / 450)
      local n2 = noise2d(px / 300, py / 300)
      local n3 = noise2d(px / 100, py / 100)
      local n4 = noise2d(px / 25, py / 25)
      local n5 = noise2d(px / 18, py / 18)
      local noise = n1 + n2 * 0.45 + n3 * 0.1 + n4 * 0.01 + n5 * 0.001


        if noise > 0.7 then
          tile = "grass-3"
          if noise < 0.65 then 
            tile = "grass-4" 
          elseif noise < 0.98 then 
            tile = "grass-2" 
          else
            tile = "water-green" 
          end

          if math.random() > 0.95 then 
            local tree = trees[math.random(#trees)]
            surface.create_entity({name = tree, position = {x, y}})
          end

        elseif n3 < 0.8 and n4 < 0.5 and n5 < 0.3 then

          if math.random() < 0.7 and distance > 10 then
            local rock = rocks[math.random(#rocks)]
            surface.create_entity({name = rock, position = {x, y}})
          end
          
          if math.random() < 0.001 and distance > 40 then
            local spawner = math.random() > 0.1 and "biter-spawner" or "spitter-spawner"
            surface.create_entity({ name = spawner, position = { x, y } })
          end

  
          



          tile = "dirt-7"
          if n4 < -0.2 and n5 < -0.8 then
            tile = "water-green"
          end
        end




        if tile == nil then
          tile = "out-of-map"
        end

        table.insert( tiles, {name = tile, position =  {x, y}})


    end
  end

  surface.set_tiles(tiles)

  local spawners = surface.find_entities_filtered({
    area = area,
    name = {"biter-spawner", "spitter-spawner"}
  })

  for _, spawner in pairs(spawners) do
    local rocks_to_delete = surface.find_entities_filtered({
      position = spawner.position,
      radius = 5,
      name = rocks
    })
    for _, rock in pairs(rocks_to_delete) do
      rock.destroy()
    end
  end
end


local function init()
  local surface = game.create_surface("cave")
  initialize_surface(surface)
  surface.request_to_generate_chunks({0, 0}, 3)
end


local function mined_entity(event)
  local player = game.players[event.player_index]
  if not validate_player(player) then return end
  local entity = event.entity
  if not entity.valid then return end
  local surface = player.surface
  local rock_mined
  for _, rock in pairs(rocks) do
    if entity.name == rock then
      rock_mined = true
    end
  end
  if not rock_mined then return end
  event.buffer.clear()

  if math.random() < 0.025 then
    player.print({"mining_info.chest_spawn"}, {r = 0.6, b = 0.4, g = 0.5})
    local items = math.ceil(math.random(1, 5))
    local chest = surface.create_entity({name = "wooden-chest", position = entity.position, force = player.force })
    chest.minable = false
    for i = 0, items do
      local item = chest_items[math.random(#chest_items)]
      chest.insert({name = item.name, count = math.random(item.count[1], item.count[2]) })
    end
  elseif math.random() < 0.015 then
    local sizes = {6, 13, 20}
    local size = math.random(#sizes)

    if size == 1 then
      player.print({"mining_info.random_resource_small"})
    elseif size == 2 then
    player.print({"mining_info.random_resource_medium"})
  else
    player.print({"mining_info.random_resource_large"})
  end
    spawn_resource_patch(surface, entity.position, sizes[size])
  elseif math.random() < 0.05 then 
    --spawn some biters
    local count = math.ceil(math.random( 1, 5))

    for i = 0, count do
      local biter = math.random() > 0.1 and "small-biter" or "medium-biter"
      local safe_position = surface.find_non_colliding_position(biter, entity.position, 10, 1)
      if not safe_position then goto continue end
      surface.create_entity({name = biter, position = safe_position })
    end
    ::continue::
  end

  
  

  for ore, value in pairs(mined_rock_entities) do
    if ore == "uranium-ore" and math.random() > 0.3 then goto continue end
    if math.random() < 0.3 then goto continue end
    local modifier =  (player.force.mining_drill_productivity_bonus * 10) 
    modifier = modifier > 0 and modifier or 1
    local count = math.random((value[1] * modifier), (value[2] * modifier))
    local inserted = player.insert({ name = ore , count = count})
    if inserted ~= count then
      player.print({'mining_warnings.mined_bag_full'})
      surface.spill_item_stack(player.position,{ name = ore , count = count }, true)
    else
      Schedule.add(flying_text,{ {'mining_warnings.mined_inserted_success_icon', inserted, ore}, player })
    end
    ::continue::
  end
end

local function player_created(event)
  local player = game.players[event.player_index]

  player.insert({ name = "pistol" })
  player.insert({ name = "firearm-magazine", count = 10 })
  player.insert({ name = "iron-plate",       count = 10 })
  player.character_inventory_slots_bonus = 100
  player.character_mining_speed_modifier = 2

  
  
  local safe_position = game.surfaces["cave"].find_non_colliding_position("character", {0, 0}, 50, 1)
  if not safe_position then
    player.teleport({0, 0}, "cave")
  else
    player.teleport(safe_position, "cave")
  end
  player.force.chart(player.surface,{{x = -200, y = -200}, {x = 200, y = 200}})
end

local function player_respawned(event)
  local player = game.players[event.player_index]
  player.character_inventory_slots_bonus = 100
  player.character_mining_speed_modifier = 2
end

commands.add_command("spawn", "spawn", function(event) 
  local player = game.players[event.player_index]
  local safe_position = game.surfaces["cave"].find_non_colliding_position("character", {0, 0}, 50, 1)
  player.teleport(safe_position, "cave")
end)



local function check_players_in_darkness()

  
  for _, player in pairs(game.connected_players) do
    if not validate_player(player) then goto do_nothing end
    if dist(player.position, {0,0}) < 25 then goto do_nothing end
    if not in_darkness_warned[player.name] then
      player.print({"warnings.first_time_in_darkness"})
      in_darkness_warned[player.name] = true
      goto do_nothing
    end

    local surface = player.surface
    -- assume they are in darkenss?
    local darkness = true
  
    local lamps = surface.find_entities_filtered({ 
      position = player.position, 
      name = "small-lamp", 
      radius = 15
    })
  
    if #lamps == 0 then 
      darkness = true
    else
      for _, lamp in pairs(lamps) do
        if lamp.is_connected_to_electric_network() then
          darkness = false
        end
      end
    end

    -- do sonmething
    if math.random() < 0.5 and darkness then
      player.print({"warnings.player_in_dark"}, {r = 0.3, b = 0.5, g = 0.3})
      local count = math.ceil(math.random( 1, 5))
      for i = 0, count do
        local biter = math.random() > 0.1 and "small-biter" or "medium-biter"
        local pos = {
          x = player.position.x + math.random(-5, 5),
          y = player.position.y + math.random(-5, 5)
        }
        local safe_position = surface.find_non_colliding_position(biter, pos, 10, 1)
        if not safe_position then goto continue end
        surface.create_entity({name = biter, position = safe_position })
      end
      ::continue::
    end 
    ::do_nothing::
  end
end


local rocks = {
  "rock-huge",
  "rock-big",
  "sand-rock-big"
}

local function entity_died(event)

  local is_entity_rock = false
  local entity = event.entity

  for _, rock in pairs(rocks) do
    if entity.name == rock then 
      is_entity_rock = true
    end
  end

  if is_entity_rock then
    local loot = event.loot
    if loot then loot.clear() end
  end
end 

Event.on_init(init)
Event.on_nth_tick(60 * 10, check_players_in_darkness)
Event.register(defines.events.on_chunk_generated, chunk_generated)
Event.register(defines.events.on_player_mined_entity, mined_entity)
Event.register(defines.events.on_player_created, player_created)
Event.register(defines.events.on_player_respawned, player_respawned)
Event.register(defines.events.on_player_respawned, player_respawned)
Event.register(defines.events.on_entity_died, entity_died)