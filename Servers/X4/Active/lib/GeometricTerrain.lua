
-- Generation of geometric terrain, but defer to scenario terrain for spawns

local M = {};

function terrainFunc( cx, cy, ix, iy)
    local distVar1 = math.floor(math.max(math.abs(cx - ix), math.abs(cy - iy)))
    local distVar2 = math.floor(math.abs(cx - ix) + math.abs(cy - iy))
    local distVar = math.max(distVar1, distVar2 * 0.707);
    return distVar>13
end

function M.ChunkGenerated(event)
    local surface = event.surface

    if surface.name == GAME_SURFACE_NAME then
        tiles = {}
        local chunkArea = event.area
        local midPoint = {x = (chunkArea.left_top.x + chunkArea.right_bottom.x)/2,
                            y = (chunkArea.left_top.y + chunkArea.right_bottom.y)/2 } 
        for y=chunkArea.left_top.y, chunkArea.right_bottom.y-1 do
            for x = chunkArea.left_top.x, chunkArea.right_bottom.x-1 do
                if terrainFunc(midPoint.x, midPoint.y, x, y) then
                    table.insert(tiles, {name = "water", position = {x,y}});
                end
            end
        end
          
        SetTiles( surface, tiles, true);
    end        
end

return M;
