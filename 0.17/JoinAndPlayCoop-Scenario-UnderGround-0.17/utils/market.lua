local Event = require "utils.event"
local Global = require "utils.global"
local validate_player = require "utils.validate_player"
local funct

local items = {

  ["wood"] = { stack = 5, price = 1, tooltip = "Wood" },
  ["small-lamp"] = { stack = 10, price = 3, tooltip = "Lamp" },
  
  ["small-electric-pole"] = { stack = 1, price = 10, tooltip = "Small Electric Pole" },
  ["medium-electric-pole"] = { stack = 5, price = 10, tooltip = "Medium Electric Pole" },
  ["big-electric-pole"] = { stack = 1, price = 10, tooltip = "Big Electric Pole" },


  ["loader"] = { stack = 1, price = 10, tooltip = "Loader" },
  ["fast-loader"] = { stack = 1, price = 30, tooltip = "Fast Loader" },
  ["express-loader"] = { stack = 1, price = 50, tooltip = "Express Loader" },

  ["stone-brick"] = { stack = 10, price = 1, tooltip = "Stone Brick" },
  ["rail"] = { stack = 10, price = 2, tooltip = "Rail" },
  ["locomotive"] = { stack = 1, price = 5, tooltip = "Locomotive" },
  
  ["construction-robot"] = { stack = 1, price = 8, tooltip = "Construction Robot" },
  ["logistic-robot"] = { stack = 1, price = 8, tooltip = "Logistic Robot" },
  ["logistic-chest-storage"] = { stack = 1, price = 8, tooltip = "Logistic Container" },
  
  ["beacon"] = { stack = 1, price = 20, tooltip = "Beacon" },
  ["speed-module"] = { stack = 1, price = 5, tooltip = "Speed Module" },
  ["effectivity-module"] = { stack = 1, price = 5, tooltip = "Effectivity Module" },
  ["productivity-module"] = { stack = 1, price = 5, tooltip = "Productivity Module" },

  ["firearm-magazine"] = { stack = 10, price = 3, tooltip = "Firearm Magazine" },
  ["piercing-rounds-magazine"] = { stack = 10, price = 6, tooltip = "Piercing Rounds Magazine" },
  ["shotgun-shell"] = { stack = 10, price = 3, tooltip = "Shotgun Shell" },
  ["piercing-shotgun-shell"] = { stack = 10, price = 6, tooltip = "Piercing Shotgun Shell" },
}


local gui_market_data = {}

Global.register({gui_market_data = gui_market_data, items = items}, function(glob)
  gui_market_data  = glob.gui_market_data
  items     = glob.items
end)



local function redraw_market_items(gui, player, search_text)
  if not validate_player(player) then return end
  gui.clear()
  local inventory  = player.get_main_inventory()
  local player_item_count = inventory.get_item_count("coin")

  local items_table = gui.add({ type = "table" , column_count = 5 })

  local slider_value = math.ceil(gui_market_data[player.name].slider.slider_value)
  for name, opts in pairs(items) do 

    if not search_text then goto continue end
    if not search_text.text then goto continue end
    if not string.lower(opts.tooltip):find(search_text.text) then goto continue end
    local item_count = opts.stack * slider_value
    local item_cost  = opts.price * slider_value
    local flow = items_table.add({ type = "flow" })
    flow.style.vertical_align = "bottom"
    
    local button = flow.add({
      type = "sprite-button",
      sprite = "item/"..name,
      number = item_count,
      name   = name,
      tooltip = {"market.tooltip", opts.tooltip, item_cost, item_count},
      style  = "slot_button"
    })
    local label = flow.add({ 
      type = "label", 
      caption = string.format("%d %s", item_cost, item_cost == 1 and "coin" or "coins")
    })

    if player_item_count < item_cost then
      label.style.font_color = { 1, 0.2, 0.2 } 
      button.enabled = false
    end
    ::continue::
  end
end

local function slider_changed(event)
  local player = game.players[event.player_index]
  local element = event.element
  local slider_value = math.ceil(gui_market_data[player.name].slider.slider_value)
  gui_market_data[player.name].text_input.text = slider_value
  redraw_market_items(gui_market_data[player.name].item_frame, player, gui_market_data[player.name].search_text)
end

local function text_changed(event)
  local player = game.players[event.player_index]
  local element = event.element
  local value = tonumber(gui_market_data[player.name].text_input.text)
  if not value then return end
  gui_market_data[player.name].slider.slider_value = value
  redraw_market_items(gui_market_data[player.name].item_frame, player, gui_market_data[player.name].search_text)
end



local function open_market(player)
  if not gui_market_data[player.name] then
    gui_market_data[player.name] = {}
  end

  local data = gui_market_data[player.name]

  if data.frame then
    data.frame.destroy()
    gui_market_data[player.name] = nil
  else
    local frame = player.gui.center.add({ 
      type = "frame",
      caption = "Market",
      direction = "vertical"
    })
    
    player.opened = frame
    frame.style.minimal_width = 500
    local seach_table = frame.add({ type = "table", column_count = 2 })
    seach_table.add({ type = "label", caption = "search.. "})
    local search_text = seach_table.add({ type = "textfield" })

    local flow = frame.add({ type = "flow" })
    
    local slider_frame = frame.add({type = "table", column_count = 5, name})   
    
    local left_button = slider_frame.add({ type = "button", caption = "-1", name = "button_<"})
    local slider = slider_frame.add({ 
      type = "slider",
      minimum_value = 1,
      maximum_value = 1e3,
      value = 1
    })

    local right_button = slider_frame.add({ type = "button", caption = "+1", name = "button_>" })

    left_button.style.width = 0
    left_button.style.height = 0
    right_button.style.width = 0
    right_button.style.height = 0

    local slider_label = slider_frame.add({ 
      type = "label", 
      caption = "Qty:"
      })

    local text_input = slider_frame.add({ 
      type = "textfield", 
      text = 1
      })

      
    
    gui_market_data[player.name].search_text = search_text
    gui_market_data[player.name].text_input = text_input
    gui_market_data[player.name].slider = slider
    gui_market_data[player.name].frame = frame
    gui_market_data[player.name].item_frame = flow

    redraw_market_items(flow, player, search_text)
  end
end

local function init_market_button(event)
  local player = game.players[event.player_index]

  player.gui.top.add({ 
    type = "sprite-button", 
    sprite = "entity/market",
    name = "market_button",
    tooltip = "Market"
   })
  
end

local function gui_click(event)
  local player = game.players[event.player_index]
  if not event.element.valid then return end
  local name = event.element.name
  if not validate_player(player) then return end

  if name == "market_button" then
    open_market(player)
    return
  elseif name == "button_<" then
    local slider_value = gui_market_data[player.name].slider.slider_value
    if slider_value > 1 then
      gui_market_data[player.name].slider.slider_value = slider_value - 1
      gui_market_data[player.name].text_input.text = gui_market_data[player.name].slider.slider_value
      redraw_market_items(gui_market_data[player.name].item_frame, player, gui_market_data[player.name].search_text)
    end
    return
  elseif name == "button_>" then
    local slider_value = gui_market_data[player.name].slider.slider_value
    if slider_value <= 1e3 then
      gui_market_data[player.name].slider.slider_value = slider_value + 1
      gui_market_data[player.name].text_input.text = gui_market_data[player.name].slider.slider_value
      redraw_market_items(gui_market_data[player.name].item_frame, player, gui_market_data[player.name].search_text)
    end
    return
  end

  --assume we clicked an item
  local item = items[name]
  if not item then return end


  local inventory  = player.get_main_inventory()
  local player_item_count = inventory.get_item_count("coin")
  local slider_value = math.ceil(gui_market_data[player.name].slider.slider_value)
  local cost = (item.price * slider_value) 
  local item_count = item.stack * slider_value
  if player_item_count >= cost then
    if player.can_insert({ name = name, count = item_count }) then
      player.play_sound({path  = "entity-close/stone-furnace", volume_modifier = 0.65})
      player.remove_item({ name = "coin", count = cost })
      local inserted_count = player.insert({ name = name, count = item_count })
      if inserted_count < item_count then
        player.play_sound({path  = "utility/cannot_build", volume_modifier = 0.65})
        player.insert({ name = "coin", count = cost })
        player.remove_item({ name = name, count = inserted_count })
      end
      redraw_market_items(gui_market_data[player.name].item_frame, player, gui_market_data[player.name].search_text)
    end
  else
    
  end
end

local function gui_closed(event)
  local player = game.players[event.player_index]
  local type = event.gui_type
  
  if type == defines.gui_type.custom then
    local data = gui_market_data[player.name]
    if not data then return end
    if data["frame"] then
      data.frame.destroy()
      gui_market_data[player.name] = nil
    end
  end
end


Event.register(defines.events.on_gui_click, gui_click)
Event.register(defines.events.on_player_created, init_market_button)
Event.register(defines.events.on_gui_value_changed, slider_changed)
Event.register(defines.events.on_gui_text_changed, text_changed)
Event.register(defines.events.on_gui_closed, gui_closed)


