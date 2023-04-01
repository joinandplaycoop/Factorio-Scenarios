
-- Generation of geometric terrain, but defer to scenario terrain for spawns

local M = {};

function octoDist( cx, cy, ix, iy)
    local distVar1 = math.floor(math.max(math.abs(cx - ix), math.abs(cy - iy)))
    local distVar2 = math.floor(math.abs(cx - ix) + math.abs(cy - iy))
    local distVar = math.max(distVar1, distVar2 * 0.707);
    return distVar
end

function terrainFunc( x, y)
    local dist1 = octoDist( 16,16, x, y) 
    local dist2 = octoDist( 16+64,16, x, y) 
    local dist3 = octoDist( 16,16+64, x, y)
    local dist4 = octoDist( 16+64,16+64, x, y)
    local dist = math.min(math.min(dist1, dist2, math.min(dist3, dist4))) 
    if  dist< 24.5 then
        return nil
    end
    if math.abs( x-16 ) < 4 or math.abs(y-16) < 4 then
        return nil
    end
    if dist < 26.5 then
        return "water"
    end
    return "out-of-map"
end

function M.ChunkGenerated(event)
    local surface = event.surface

    if surface.name == GAME_SURFACE_NAME then
        local chunkArea = event.area
        local lx = math.floor(chunkArea.left_top.x/64)*64
        local ly = math.floor(chunkArea.left_top.y/64)*64
        
        local tiles = {}
        for y=chunkArea.left_top.y, chunkArea.right_bottom.y do
            for x=chunkArea.left_top.x, chunkArea.right_bottom.x do
                local tile = terrainFunc(x-lx, y-ly)
                if tile ~= nil then
                    table.insert(tiles, { name=tile, position= { x,y} })
                end                
            end
        end
        if #tiles > 0 then
            SetTiles( surface, tiles, true);
        end
    end        
end

return M;
