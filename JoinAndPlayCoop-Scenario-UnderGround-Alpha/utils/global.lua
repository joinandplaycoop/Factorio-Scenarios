local Global  = {}
local Event   = require "event"
global.data   = {}


function Global.register(data, callback)
  local index = #global.data + 1
  global.data[index] = data
  Event.on_load(function() callback(Global.get(index)) end)
end


function Global.get(index)
  return global.data[index]
end


return Global