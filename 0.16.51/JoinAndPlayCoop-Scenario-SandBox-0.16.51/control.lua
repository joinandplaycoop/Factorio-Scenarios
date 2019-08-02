local version = 1
local mod_gui = require("mod-gui")

require "japc-event-handler"

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  local character = player.character
  player.force.research_all_technologies()
  player.surface.always_day = true
  give_items(player)
  player.cheat_mode = true
  player.print({"msg-introduction"})
  create_spawn_frame(player)
  
  
end)

script.on_init(function()
  global.version = version
  local surface = game.surfaces["nauvis"]
  local mgs = surface.map_gen_settings
  mgs.width = "2000"
  mgs.height = "2000"
  surface.map_gen_settings = mgs
  game.forces.player.chart(game.surfaces["nauvis"], {{-2000, -2000},{2000, 2000}})
local tiles = {}
for x = -100, 100 do
for y = -100, 100 do
tiles[#tiles + 1] = {name = 'concrete', position = {x, y}}
end
end
surface.set_tiles(tiles)
  --[[
  local i  = -20
  while i <= 20 do        
  wall = surface.create_entity{name = "stone-wall", position = {i, 20}, force = Default}
  wall.destructible = false
  wall.minable = false
  
  i = i + 1 

end
  local i  = -20
  while i <= 20 do        
  wall = surface.create_entity{name = "stone-wall", position = {20, i}, force = Default}
  
  i = i + 1 

end
  local i  = 20
  while i >= -20 do        
  wall = surface.create_entity{name = "stone-wall", position = {-20, i}, force = Default}
  
  i = i - 1 

end
  local i  = 20
  while i >= -20 do    
  wall = surface.create_entity{name = "stone-wall", position = {i, -20}, force = Default}
  i = i - 1 

end
test = surface.create_entity{name = "tank", position = {1, 1}, force = default}
--]]
end)


script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local gui = event.element
  if gui.name == "button-spawn_Yes" then
	  local player = game.players[event.player_index]
	  local character = player.character
      player.character = nil
      if character then
        character.destroy()
		player.print("You are now in editor mode !")
      end
    return
  end
  if gui.name == "button-spawn_No" then
		local player = game.players[event.player_index]
		local character = player.character
		if player.character == nil then 
			player.create_character()
			player.print("You are now a player again !")
		end
    return
  end
end)

function give_items(player)
  local items =
  {
    ["raw-wood"] = "100",
    ["coal"] = "100",
    ["stone"] = "100",
    ["iron-plate"] = "400",
    ["copper-plate"] = "400",
    ["steel-plate"] = "100",
    ["iron-gear-wheel"] = "200",
    ["electronic-circuit"] = "200",
    ["advanced-circuit"] = "200",
    ["offshore-pump"] = "20",
    ["pipe"] = "50",
    ["boiler"] = "50",
    ["electric-mining-drill"] = "50",
    ["steam-engine"] = "10",
    ["stone-furnace"] = "50",
    ["transport-belt"] = "200",
    ["underground-belt"] = "50",
    ["splitter"] = "20",
    ["fast-transport-belt"] = "50",
    ["express-transport-belt"] = "50",
    ["inserter"] = "50",
    ["fast-inserter"] = "50",
    ["long-handed-inserter"] = "50",
    ["filter-inserter"] = "50",
    ["small-electric-pole"] = "50",
    ["assembling-machine-1"] = "50",
    ["assembling-machine-2"] = "30",
    ["rail"] = "200",
    ["train-stop"] = "10",
    ["rail-signal"] = "50",
    ["locomotive"] = "5",
    ["cargo-wagon"] = "10"
  }
  for name, count in pairs (items) do
    if game.item_prototypes[name] then
      player.insert{name = name, count = count}
    else
      error(name.." is not a valid item") --More useful than an assert
    end
  end
end

function create_spawn_frame(player)
  local frame = mod_gui.get_frame_flow(player).add{name = "spawn_frame", type = "frame", direction = "horizontal", caption={"msg-ask-spawn"}}
  frame.add{type = "button", name = "button-spawn_Yes", caption = {"button-spawn_Yes"}}
  frame.add{type = "button", name = "button-spawn_No", caption = {"button-spawn_No"}}
end