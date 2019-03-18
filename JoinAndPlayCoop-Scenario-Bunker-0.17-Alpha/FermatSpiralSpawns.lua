
local M = {};
  
local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end

local function FermatSpiralPoint(n)
    -- Vogel's model. see https://en.wikipedia.org/wiki/Fermat%27s_spiral
    local n = scenario.config.separateSpawns.firstSpawnPoint + n
    local spacing = scenario.config.separateSpawns.spacing
    return PolarToCartesian({ r=spacing * math.sqrt(n), theta= (n * 137.508 * math.pi/180) })
end

  
local function CenterInChunk(a)
    return { x = a.x-math.fmod(a.x, 32)+16, y=a.y-math.fmod(a.y, 32)+16 }
end

function M.InitSpawnPoint(n)
   local a = FermatSpiralPoint(n)
   local spawn = CenterInChunk(a);
   spawn.createdFor = nil;
   spawn.used = false;
   spawn.seq = n
   table.insert(global.allSpawns, spawn)
end

return M;