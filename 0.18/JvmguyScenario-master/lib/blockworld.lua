

local function TileIsInBlock(xin,yin)
  local block_width = 256;
  local block_height = 256;
  local x = math.floor(math.abs(xin)); 
  local y = math.floor(math.abs(yin));
  -- which block 
  local xx = math.floor( x / block_width);
  local yy = math.floor( y / block_height);

  -- coords within the block 
  local xm = x - xx * block_width;
  local ym = y - yy * block_height;

  return (xm < block_width-2)  and (ym < block_height-2);
end
Event.register(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    if surface.name ~= "nauvis" then return end
    local chunkArea = event.area
    local chunkAreaCenter = {x=chunkArea.left_top.x+(CHUNK_SIZE/2),
      y=chunkArea.left_top.y+(CHUNK_SIZE/2)}
    
    local inSpawn = false;
    for name,spawnPos in pairs(global.playerSpawns) do

        local landArea = {left_top=
                            {x=spawnPos.x-ENFORCE_LAND_AREA_TILE_DIST,
                             y=spawnPos.y-ENFORCE_LAND_AREA_TILE_DIST},
                          right_bottom=
                            {x=spawnPos.x+ENFORCE_LAND_AREA_TILE_DIST,
                             y=spawnPos.y+ENFORCE_LAND_AREA_TILE_DIST}}
        if CheckIfInArea(chunkAreaCenter,landArea) then
          inSpawn = true;
        end
    end

  if not inSpawn then
    local tiles = {}
    for x = event.area.left_top.x, event.area.right_bottom.x - 1 do
      for y = event.area.left_top.y, event.area.right_bottom.y - 1 do
        if not (math.abs(x) < 4 and math.abs(y) < 4) then
          if not TileIsInBlock(x, y) then
            table.insert(tiles, {name="water", position = {x,y}})
          elseif event.surface.get_tile(x,y).name:find("water") then
            table.insert(tiles, {name="grass", position = {x,y}})
          end
        end
      end
    end
    SetTiles(surface, tiles, true)
	end
end)
