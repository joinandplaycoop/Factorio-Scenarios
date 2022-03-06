local function UndecorateOnChunkGenerate(event)
    local surface = event.surface
    local chunkArea = event.area
    RemoveDecorationsArea(surface, chunkArea)
    RemoveFish(surface, chunkArea)
end

Event.register(defines.events.on_chunk_generated, UndecorateOnChunkGenerate)