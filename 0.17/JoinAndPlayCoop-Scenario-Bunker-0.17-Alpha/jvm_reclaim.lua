
-- Code to reclaim a connected chunk of the map.
-- experimental

function ChunkCode(chunk)
    return chunk.x + chunk.y * 8192;
end

function NewSweep(surface)
    return {
        surface = surface,
        items = {},
        itemSize = 0,
        work = {},
        workSize = 0,
    }
end

function Sweep_AddToWork(sweep, chunk)
    if sweep.surface.is_chunk_generated(chunk) then
        local ix = ChunkCode(chunk);
        if sweep.items[ix] == nil then
            sweep.items[ix] = chunk;
            sweep.itemSize = sweep.itemSize + 1;
            game.player.print("Sweep_AddToWork: " .. chunk.x .. " " .. chunk.y .. " " .. sweep.itemSize);
            chunk.marked = 1;
            sweep.workSize = sweep.workSize + 1;
            sweep.work[sweep.workSize] = chunk;
        end
    end        
end

function Sweep_ProcessWork(sweep)
    local count = 0;
    while sweep.workSize > 0 do
        count = count + 1
        if count > 50000 then
            break;
        end
        local item = sweep.work[sweep.workSize];
        sweep.work[sweep.workSize] = nil;
        sweep.workSize = sweep.workSize - 1;
        if (item.marked ~= 2) then
            item.marked = 2;
            Sweep_AddToWork(sweep, {x=item.x-1, y=item.y });
            Sweep_AddToWork(sweep, {x=item.x+1, y=item.y });
            Sweep_AddToWork(sweep, {x=item.x, y=item.y-1 });
            Sweep_AddToWork(sweep, {x=item.x, y=item.y+1 });
        end
    end    
end

function sbool(b)
    if b==true then
        return "true";
    else
        return "false";
    end
end    

function MakeEraseList(surface, position)
    local sweep = NewSweep(game.player.surface);
    local p = game.player.position;
    local here = { x = math.floor(p.x / CHUNK_SIZE),
                   y = math.floor(p.y / CHUNK_SIZE) };
--    if false then
--        game.player.print("is_chunk_generated: " .. here.x .. " " .. here.y .. " " .. sbool(game.player.surface.is_chunk_generated(here)));
--    end                   
    Sweep_AddToWork(sweep, here);
    Sweep_ProcessWork(sweep);
    game.player.print("MakeEraseList: size = " .. sweep.itemSize .. " work=" .. sweep.workSize);
    return sweep.items
end

--function Test()
--    local sweep = NewSweep(game.player.surface);
--    local p = game.player.position;
--    local here = { x = math.floor(p.x / CHUNK_SIZE),
--                   y = math.floor(p.y / CHUNK_SIZE) }
--    for x=here.x,here.x+200 do                   
--        game.player.print("is_chunk_generated: " .. (x-here.x) .. " " .. x .. " " .. here.y .. " " .. sbool(game.player.surface.is_chunk_generated({x=x,y=here.y})));
--        if not game.player.surface.is_chunk_generated({x=x,y=here.y}) then
--            break;
--        end
--    end                   
--end
