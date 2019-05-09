local Event = require "utils.event"
local Global = require "utils.global"
local Schedule = {}

local scheduled_taks = {}

Global.register(scheduled_taks, function(glob) 
  scheduled_taks = glob
end)

function Schedule.add(func, args)
  table.insert( scheduled_taks, {func = func, args = args} )
end


function Schedule.next(func, args)
  if #scheduled_taks >= 1 then
    local task = scheduled_taks[1]
    table.remove(scheduled_taks, 1, 1)
    local func = task.func
    local args = task.args
    pcall(func, unpack(args))
  end
end

Event.on_nth_tick(5, Schedule.next)
return Schedule

