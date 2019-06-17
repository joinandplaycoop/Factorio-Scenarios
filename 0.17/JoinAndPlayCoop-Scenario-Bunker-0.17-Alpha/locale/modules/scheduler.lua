-- scheduler. Scheduler events for future execution

local jvmHeap = require("jvm-chunkheap");

Scheduler = {
    queue = jvmHeap.new(nil);
};

local function newSchedulerEntry(when, func, arg)
    local result = {
        lruTime=when;
        func = func;
        arg = arg;
    }
    return result
end

function Scheduler.onTick(event)
    local entry = jvmHeap.head(Scheduler.queue);
    if (entry ~= nil and entry.lruTime <= game.tick) then
        pcall( entry.func, entry.arg);
--        entry.func( entry.arg );
        jvmHeap.remove(Scheduler.queue, entry);
        entry = jvmHeap.head(Scheduler.queue);
    end
end

function Scheduler.schedule(when, func, arg)
    local entry = newSchedulerEntry( when, func, arg);
    jvmHeap.insert( Scheduler.queue, entry );
end

Event.register(defines.events.on_tick, Scheduler.onTick)

return Scheduler;