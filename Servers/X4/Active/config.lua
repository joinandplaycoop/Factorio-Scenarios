-- config.lua
-- Configuration Options


if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end

scenario.config.mapsettings = scenario.config.mapsettings or {}

--------------------------------------------------------------------------------
-- Useful constants
--------------------------------------------------------------------------------
CHUNK_SIZE = 32
MAX_FORCES = 64
TICKS_PER_SECOND = 60
TICKS_PER_MINUTE = TICKS_PER_SECOND * 60
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------
scenario.config.joinedMessages = {
    "Welcome to Join And Play Coop!.",
    "In the current game mode, a satellite must be launched from the rocket silo in the center to win!",
    "Mods Enabled: Separate Spawns, Long-Reach, Autofill",
    "",
--    "Look in the car at your spawn for fast start items.",
--    "The car is your personal transport to and from the silo.",
    "Discord chat: https://discord.joinandplaycoop.com",
}

WELCOME_MSG_TITLE = "Welcome to Jvmguy's Server"

scenario.config.welcomeMessages = {
    "This scenario is a variant of a scenario created by Oarc",
    "",
   "You start in a bunker. The car in the bunker is a teleport to and from the wild.",
   "The only way in or out of the bunker is the teleport.",
   "",
   "You might use the bunker to build a small base to help you get started,",
   "or if you're feeling adventurous, you can go on to build something in the wild.",
   "",
    "Rules: Be polite. Ask before changing other players's stuff. Have fun!",
   "This server is running a custom scenario that changes spawn locations.",
   "",
   "Lazy Bastard (slow building) is on.  Use the Assembly Machines provided in the chest.",
   "This is actually faster than hand crafting.  (Use Ctrl+clicks to load resources into machines)",
   "",
   "/w Due to the way this scenario works, it may take some time for the land",
   "/w around your new spawn area to generate...",
   "/w Please wait for 10-20 seconds when you select your first spawn.",
   "",
--    "/w Biter expansion is on, so watch out!",
    "Discord chat https://discord.joinandplaycoop.com",
    "",
    "Good Luck!",
    "Server Owner contact: admin@poli.fun | discord.joinandplaycoop.com",
    "Oarc contact: SteamID:Oarc | Twitter:@_Oarc_ | oarcinae@gmail.com",
    "jvmguy contact: SteamID:jvmguy | Discord:@jvmguy | jvmguy@gmail.com",
}

scenario.config.gameInfo = {
    "This scenario is a variant of a scenario created by Oarc",
    "",
   "You start in a bunker. The car in the bunker is a teleport to and from the wild.",
   "The only way in or out of the bunker is the teleport.",
   "",
   "You might use the bunker to build a small base to help you get started,",
   "or if you're feeling adventurous, you can go on to build something in the wild.",
   "",
   "Lazy Bastard (slow building) is on.  Use the Assembly Machines provided in the chest.",
   "This is actually faster than hand crafting.  (Use Ctrl+clicks to load resources into machines)",
   "",
    "Rules: Be polite. Ask before changing other players's stuff. Have fun!",
    "This server is running a custom scenario that changes spawn locations.",
    "",
--    "/w Biter expansion is on, so watch out!",
    "",
    "Discord chat https://discord.joinandplaycoop.com",
    "",
    "Good Luck!",
}

scenario.config.gameInfoBackup = {
    "This scenario is a variant of a scenario created by Oarc",
    "",
    "Rules: Be polite. Ask before changing other players's stuff. Have fun!",
    "This server is running a custom scenario that changes spawn locations.",
    "",
--    "/w Biter expansion is on, so watch out!",
    "Discord chat https://discord.joinandplaycoop.com",
    "",
    "Good Luck!",
}

scenario.config.wipespawn = {
    enabled=true
}

scenario.config.regrow = {
    enabled=false
}

scenario.config.bots = {
    worker_robots_storage_bonus = 0,
    worker_robots_speed_modifier = 1.0,
}

scenario.config.forceBonuses = {
    character_inventory_slots_bonus = 20,
}

scenario.config.playerBonus = {
    --   character_crafting_speed_modifier = 0,
      -- this simulates lazy-bastard
      character_crafting_speed_modifier = 1/100-1.0,
}

--------------------------------------------------------------------------------
-- Frontier Rocket Silo Options
--------------------------------------------------------------------------------

-- SILO_DISTANCE = 4 * HEXSPACING
SILO_DISTANCE = 0     -- put the silo 1 chunk east of the origin (prevents problems)
SILO_RECT_SIZE = 512
SILO_CHUNK_DISTANCE_X = math.floor(SILO_DISTANCE/CHUNK_SIZE);
SILO_DISTANCE_X = math.floor(SILO_DISTANCE/CHUNK_SIZE)* CHUNK_SIZE + CHUNK_SIZE/2
SILO_DISTANCE_Y = CHUNK_SIZE/2

scenario.config.silo = {
    frontierSilo = true,        --
    chartSiloArea = true,
    handleLaunch = true,
    randomSiloPostion = false,    
    disableSiloRecipe = false,  -- if true, don't allow silos to be manufactured
    restrictSiloBuild = true,   -- if true, only allow silos to be placed in specific areas
    prebuildSilo = false,
    prebuildBeacons = false,
    prebuildPower = false,
    -- Should be in the middle of a chunk
    position = {x = SILO_DISTANCE_X, y = SILO_DISTANCE_Y}
}

scenario.config.startKitSmall = {
        {name = "submachine-gun", count=1},
        {name = "firearm-magazine", count=100},
}

scenario.config.startKitMedium = {
        {name = "power-armor", count = 1,
            equipment = {
                  -- the order of these does matter.
                  {name = "fusion-reactor-equipment"},
                  {name = "exoskeleton-equipment"},
                  {name = "personal-roboport-mk2-equipment", count=3},
                  {name = "battery-mk2-equipment", count=3},
                  {name = "solar-panel-equipment", count = 7 },
--                  {name = "personal-roboport-equipment", count=1},
--                  {name = "battery-equipment", count=1},
            }
        },
        {name = "belt-immunity-equipment", count = 1},
        {name = "night-vision-equipment", count = 1},
        {name = "construction-robot", count = 30},
        {name = "roboport", count = 2},
        {name = "logistic-chest-storage", count = 2},
--        {name = "uranium-fuel-cell", count=50 },
--		{name = "burner-mining-drill", count = 2},
--		{name = "stone-age-furnace", count = 2},
--        {name = "steel-axe", count = 5},
		{name = "submachine-gun", count=1},
--        {name = "iron-plate", count=100},
--		{name = "car", count=1},
--		{name = "wood", count=100},
		{name = "firearm-magazine", count=100},
--		{name = "landfill", count=200}

        
--        {name = "electric-mining-drill", count = 8},
--        {name = "small-electric-pole", count = 50},
--        {name = "transport-belt", count=400},
}

scenario.config.startKitLarge = {
        {name = "power-armor-mk2", count = 1,
            equipment = {
                  -- the order of these does matter.
                  {name = "fusion-reactor-equipment", count= 2},
                  {name = "exoskeleton-equipment", count=6},
                  {name = "personal-roboport-mk2-equipment", count=3},
                  {name = "battery-mk2-equipment", count=3},
--                  {name = "solar-panel-equipment", count = 7 },
--                  {name = "personal-roboport-equipment", count=1},
--                  {name = "battery-equipment", count=1},
            }
        },
        {name = "belt-immunity-equipment", count = 1},
        {name = "night-vision-equipment", count = 1},
        {name = "construction-robot", count = 100},
        {name = "roboport", count = 2},
        {name = "logistic-chest-storage", count = 2},
--        {name = "uranium-fuel-cell", count=50 },
--      {name = "burner-mining-drill", count = 2},
--      {name = "stone-age-furnace", count = 2},
--        {name = "steel-axe", count = 5},
        {name = "submachine-gun", count=1},
--        {name = "iron-plate", count=100},
--      {name = "car", count=1},
--      {name = "wood", count=100},
        {name = "firearm-magazine", count=100},
--      {name = "landfill", count=200}

        
--        {name = "electric-mining-drill", count = 8},
--        {name = "small-electric-pole", count = 50},
--        {name = "transport-belt", count=400},
}

scenario.config.startKit = scenario.config.startKitMedium

scenario.config.teleporter = {
    enabled = false,
    -- where in the spawn to place the teleporter
	spawnPosition = { x=20, y=-47 },

    -- where in the silo chunk to place the teleporter
    -- this should not be 0,0 if there is the possibility that the default spawn will be used
    siloPosition = { x=16, y=-8 },

    -- whether there is a teleporter at the silo to take you back    
    siloTeleportEnabled = false,
    -- where in the silo chunk the teleporter takes you
    -- this should be different than the silo position
    siloTeleportPosition = { x=14, y=-8 },
    
    startItems = {
        {name= "coal", count=50},
--        {name= "stone-furnace", count=2},
--        {name= "burner-mining-drill", count=2},
        {name= "landfill", count=50},
        
--        {name = "offshore-pump", count = 1},
--        {name = "boiler", count = 1},
--        {name = "steam-engine", count = 1},
--        {name = "pipe", count=5},
--        {name = "pipe-to-ground", count=2},
--        {name = "small-electric-pole", count = 20},
--        {name = "inserter", count=20},
--        {name = "electric-mining-drill", count = 50},
--        {name = "transport-belt", count=400},
    }
}

SPAWN_MSG1 = "Current Spawn Mode: HARDCORE WILDERNESS"
SPAWN_MSG2 = "In this mode, there is no default spawn. Everyone starts in the wild!"
SPAWN_MSG3 = "Resources are spread out far apart but are quite rich."

--------------------------------------------------------------------------------
-- Module Enables
-- These enables are not fully tested! For example, disable separate spawns
-- will probably break the frontier rocket silo mode
--------------------------------------------------------------------------------

-- put players on a special surface until they've chosen
ENABLE_SPAWN_SURFACE = true

-- Separate spawns
ENABLE_SEPARATE_SPAWNS = true

ENABLE_ALL_RESEARCH_DONE = false

-- Whether to enable old blueprint string code
ENABLE_BLUEPRINT_STRING = false

-- Enable Gravestone Chests
ENABLE_GRAVESTONE_CHESTS = false

-- Enable Undecorator
ENABLE_UNDECORATOR = true

-- enable player time/position status
ENABLE_STATUS = true

-- Enable Long Reach
ENABLE_LONGREACH = true

-- Enable Autofill
ENABLE_AUTOFILL = false

--------------------------------------------------------------------------------
-- Spawn Options
--------------------------------------------------------------------------------
ENABLE_CROP_OCTAGON=true
---------------------------------------
-- Distance Options
---------------------------------------
-- Near Distance in chunks
NEAR_MIN_DIST = 25 --50
NEAR_MAX_DIST = 100 --125
                   --
-- Far Distance in chunks
FAR_MIN_DIST = 100 --50
FAR_MAX_DIST = 200 --125

scenario.config.toxicJungle = {
    enabled = false,
    tree_chance = 0.2
}    

scenario.config.noResources = {
--        { shape="rect", name="steel-chest", x=42,   y=-24, height=2, width=2, contents = { {name = "landfill", count=4800 } },  },
        { shape="rect", name="steel-chest", x=42,   y=-18, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=42,   y=-12, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=42,   y=-8,  height=1, width=1, contents = { 
            {name = "coal", count=1000 },
            {name = "stone", count=1000 },
            {name = "steel-plate", count=400 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
        { shape="rect", name="steel-chest", x=42,   y=0,  height=1, width=1, contents = { 
            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
            {name = "offshore-pump", count = 1},
            {name = "boiler", count = 10},
            {name = "steam-engine", count = 20},
            {name = "pipe", count=12},
            {name = "pipe-to-ground", count=2},
            {name = "small-electric-pole", count = 20},
            {name = "inserter", count=20},
            {name = "assembling-machine-1", count=10},
            {name = "assembling-machine-2", count=1},
            -- {name = "assembling-machine-3", count=1},

        },  },
    
}

scenario.config.vanillaResources = {
        { shape="rect", name="steel-chest", x=26,   y=-24, height=2, width=2, contents = { {name = "landfill", count=4800 } },  },
        { shape="rect", name="steel-chest", x=26,   y=-18, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=26,   y=-12, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=26,   y=-8,  height=1, width=1, contents = { 
            {name = "coal", count=1000 },
            {name = "stone", count=1000 },
            {name = "steel-plate", count=1000 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
        { shape="rect", name="steel-chest", x=26,   y=0,  height=1, width=1, contents = { 
            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
            {name = "offshore-pump", count = 1},
            {name = "boiler", count = 10},
            {name = "steam-engine", count = 20},
            {name = "pipe", count=10},
            {name = "pipe-to-ground", count=10},
            {name = "small-electric-pole", count = 20},
            -- {name = "gun-turret", count=20 },
            -- {name = "piercing-rounds-magazine", count=400 },
            {name = "inserter", count=20},
            {name = "assembling-machine-1", count=10},
            {name = "assembling-machine-2", count=1},

        },  },
    
        { shape="rect", type="coal",         x=32,  y=-41, height=14, width=30,  amount=5000,  },
        { shape="rect", type="stone",        x=32,  y=-24, height=14, width=30,  amount=5000,  },
        -- { shape="rect", type="uranium-ore",  x=27, y=-24, height=14, width=12,  amount=1800,  },
        { shape="rect", type="copper-ore",   x=32,  y=-7,  height=21, width=30,  amount=5000,  },
        { shape="rect", type="iron-ore",     x=32,  y =18, height=21, width=30, amount=5000,  },
        
        { shape="rect", type="crude-oil", x=72, y=-6, height=1, amount=1000000,  },
        { shape="rect", type="crude-oil", x=72, y= 0, height=1, amount=1000000,  },
        { shape="rect", type="crude-oil", x=72, y= 6, height=1, amount=1000000,  },
}

scenario.config.voidResources = {
}

scenario.config.angelsResources = {
        { shape="rect", name="infinity-chest", x=44,   y=-52,  height=1, width=1,
            props = { minable=false, operable=false, destructible=false, force="neutral", 
                infinity_container_filters = { 
                    {index = 1, name = "fast-miniloader", count = 50},
                    {index = 2, name = "fast-filter-miniloader", count = 50},
                    {index = 3, name = "fast-transport-belt", count = 50},
                    {index = 4, name = "fast-underground-belt", count = 50},
                    {index = 5, name = "fast-splitter", count = 50},
                    {index = 6, name = "fast-inserter", count=50},
                    {index = 7, name = "medium-electric-pole", count=50},
                    {index = 8, name = "big-electric-pole", count=50},
                    {index = 9, name = "pipe", count=50},
                    {index = 10, name = "pipe-to-ground", count=50},
                    {index = 11, name = "assembling-machine-2", count=50},
                    {index = 12, name = "electric-mining-drill", count=50},
                    {index = 13, name = "steel-furnace", count=50},
                    {index = 14, name = "construction-robot", count=50},
                    {index = 15, name = "roboport", count = 10},
                    {index = 16, name = "logistic-chest-storage", count = 50},
                    {index = 17, name = "filter-inserter", count=50 },
                    {index = 18, name = "ore-crusher", count=50 },
        }, },  },

--        { shape="rect", name="infinity-chest", x=50,   y=-52,  height=1, width=1,
--            props = { minable=false, operable=false, destructible=false, force="neutral", 
--                infinity_container_filters = { 
--                    {index = 1, name = "iron-plate", count = 50},
--                    {index = 2, name = "copper-plate", count = 50},
--                    {index = 3, name = "tin-plate", count = 50},
--                    {index = 4, name = "lead-plate", count = 50},
--        }, },  },


        { shape="rect", name="steel-chest", x=42,   y=-50, height=1, width=1, contents = { {name = "landfill", count=4800 } },  },
        { shape="rect", name="steel-chest", x=45,   y=-50, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=48,   y=-50, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=51,   y=-50,  height=1, width=1, contents = { 
            {name = "coal", count=2000 },
            {name = "stone", count=1000 },
            {name = "wood", count=1000 },
            {name = "steel-plate", count=400 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
        { shape="rect", name="steel-chest", x=36,   y=0,  height=1, width=1, contents = { 
            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
            {name = "offshore-pump", count = 1},
            {name = "boiler", count = 10},
            {name = "steam-engine", count = 20},
            {name = "pipe", count=12},
            {name = "pipe-to-ground", count=2},
            {name = "small-electric-pole", count = 50},
            {name = "inserter", count=20},
            {name = "assembling-machine-2", count=10},
            {name = "assembling-machine-3", count=1},
            {name = "electric-mining-drill", count=10},
            {name = "filter-inserter", count=4 },
        },  },
    
        { shape="rect", type="coal",            x=32,  y=-47, height=14, width=24,  amount=400000,  },
        { shape="rect", type="angels-ore5",     x=32,  y=-30, height=14, width=24,  amount=400000,  },
        { shape="rect", type="angels-ore6",     x=32,  y=-13,  height=14, width=24,  amount=400000,  },
        { shape="rect", type="angels-ore1",     x=32,  y =4, height=21, width=24,  amount=400000,  },
        { shape="rect", type="angels-ore3",     x=32,  y =28, height=21, width=24,  amount=400000,  },
--        { shape="rect", type="angels-ore2",     x=70,  y =4, height=21, width=24,  amount=40000,  },
--        { shape="rect", type="angels-ore4",     x=70,  y =28, height=21, width=24,  amount=40000,  },
        
        { shape="rect", type="angels-natural-gas", x=70, y=-6, height=1, amount=100000,  },
        { shape="rect", type="angels-natural-gas", x=70, y= 0, height=1, amount=100000,  },
        { shape="rect", type="angels-natural-gas", x=70, y= 6, height=1, amount=100000,  },
}

scenario.config.krastorioResources = {
        { shape="rect", name="steel-chest", x=42,   y=-50, height=3, width=3, contents = { {name = "landfill", count=9600 } },  },
        { shape="rect", name="steel-chest", x=45,   y=-50, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=48,   y=-50, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=51,   y=-50,  height=1, width=1, contents = { 
            {name = "coal", count=2000 },
            {name = "stone", count=1000 },
            {name = "wood", count=1000 },
            {name = "steel-plate", count=400 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
        { shape="rect", name="steel-chest", x=40,   y=-50,  height=1, width=1, contents = { 
            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
            {name = "offshore-pump", count = 1},
            {name = "boiler", count = 10},
            {name = "steam-engine", count = 20},
            {name = "pipe", count=12},
            {name = "pipe-to-ground", count=2},
            {name = "small-electric-pole", count = 50},
            {name = "inserter", count=20},
            {name = "assembling-machine-2", count=10},
--            {name = "assembling-machine-3", count=1},
            {name = "electric-mining-drill", count=10},
            {name = "dt-fuel", count=20 },
            {name = "electronic-circuit", count=100 },
        },  },
    
        { shape="rect", type="coal",         x=32,  y=-47, height=14, width=36,  amount=40000,  },
        { shape="rect", type="stone",        x=32,  y=-30, height=14, width=24,  amount=40000,  },

        { shape="rect", type="iron-ore",   x=32,  y =-13, height=14, width=36,  amount=40000,  },

        { shape="rect", type="copper-ore",   x=32,  y =4, height=14, width=36,  amount=40000,  },

        { shape="rect", type="rare-metals",     x=32,  y =30, height=12, width=12,  amount=400000,  },
        { shape="rect", type="imersite",     x=34,  y =47, height=1, width=1,  amount=400000,  },
        
        { shape="rect", type="crude-oil", x=72, y=-6, height=1, amount=500000,  },
        { shape="rect", type="crude-oil", x=72, y= 0, height=1, amount=500000,  },
        { shape="rect", type="mineral-water", x=72, y= 6, height=1, amount=500000,  },
}

scenario.config.omniResources = {
        { shape="rect", type="omnite", x=0,  y=-50, height=100, width=100,  amount=1000,  },
        { shape="rect", name="steel-chest", x=42,   y=-50, height=1, width=1, contents = { {name = "landfill", count=4800 } },  },
        { shape="rect", name="steel-chest", x=45,   y=-50, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=48,   y=-50, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=51,   y=-50,  height=1, width=1, contents = { 
            {name = "coal", count=2000 },
            {name = "stone", count=1000 },
            {name = "wood", count=1000 },
            {name = "steel-plate", count=400 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
        { shape="rect", name="steel-chest", x=36,   y=0,  height=1, width=1, contents = { 
            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
            {name = "offshore-pump", count = 1},
            {name = "boiler", count = 10},
            {name = "steam-engine", count = 20},
            {name = "pipe", count=12},
            {name = "pipe-to-ground", count=2},
            {name = "small-electric-pole", count = 50},
            {name = "inserter", count=20},
            {name = "assembling-machine-2", count=10},
            {name = "assembling-machine-3", count=1},
            {name = "electric-mining-drill", count=10},
        },  },
    
}

scenario.config.seaBlockResources = {
    { shape="rect", name="steel-chest", x=42,   y=-50, height=1, width=1, contents = {
            {name = "landfill", count=1000},
            {name = "stone", count=50},
            {name = "small-electric-pole", count=50},
            {name = "small-lamp", count=12},

            {name = "iron-plate", count=1200},
            {name = "basic-circuit-board", count=200},
            {name = "stone-pipe", count=100},
            {name = "stone-pipe-to-ground", count=50},
            {name = "stone-brick", count=500},
            {name = "pipe", count=27},
            {name = "copper-pipe", count=5},
            {name = "iron-gear-wheel", count=25},
            {name = "iron-stick", count=96},
            {name = "pipe-to-ground", count=2},
            {name = "electronic-circuit", count=10},
            {name = "wind-turbine-2", count=120}
    },  },
}

scenario.config.industrialRevolutionResources = {
    
        { shape="rect", type="coal",            x=42,  y=-47, height=14, width=24,  amount=5000,  },
        { shape="rect", type="stone",     x=42,  y=-30, height=14, width=24,  amount=5000,  },
        { shape="rect", type="tin-ore",     x=42,  y =4, height=21, width=24,  amount=5000,  },
        { shape="rect", type="copper-ore",     x=42,  y =28, height=21, width=24,  amount=5000,  },
        
        { shape="rect", type="crude-oil", x=80, y= 0, height=1, amount=300000,  },
        { shape="rect", name="steel-chest", x=51,   y=-50,  height=1, width=1, contents = { 
            {name = "stone", count=100 },
            {name = "wood", count=100 },
         }  },
}

scenario.config.industrialPlusKrastorioResources = {
        { shape="rect", name="steel-chest", x=42,   y=-50, height=1, width=1, contents = { {name = "landfill", count=1200 } },  },
        { shape="rect", name="steel-chest", x=45,   y=-50, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=48,   y=-50, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=51,   y=-50, height=2, width=2, contents = { {name = "tin-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=54,   y=-50,  height=1, width=1, contents = { 
            {name = "coal", count=2000 },
            {name = "stone", count=1000 },
            {name = "wood", count=1000 },
            {name = "steel-plate", count=400 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
--        { shape="rect", name="steel-chest", x=40,   y=-50,  height=1, width=1, contents = { 
--            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
--            {name = "offshore-pump", count = 1},
--            {name = "boiler", count = 10},
--            {name = "steam-engine", count = 20},
--            {name = "pipe", count=12},
--            {name = "pipe-to-ground", count=2},
--            {name = "small-electric-pole", count = 50},
--            {name = "inserter", count=20},
--            {name = "assembling-machine-2", count=10},
--            {name = "assembling-machine-3", count=1},
--            {name = "electric-mining-drill", count=10},
--        },  },
    
        { shape="rect", type="coal",         x=42,  y=-47, height=14, width=24,  amount=40000,  },
        
        { shape="rect", type="stone",        x=42,  y=-30, height=14, width=12,  amount=20000,  },
        { shape="rect", type="sand",         x=56,  y=-30,  height=14, width=12,  amount=20000,  },

        { shape="rect", type="tin-ore",      x=42,  y=-13, height=14, width=12,  amount=20000,  },
        { shape="rect", type="gold-ore",     x=56,  y=-13,  height=14, width=12,  amount=20000,  },

        { shape="rect", type="iron-ore",     x=42,  y =4, height=21, width=12,  amount=40000,  },
        { shape="rect", type="copper-ore",   x=56,  y =4, height=21, width=12,  amount=40000,  },

        { shape="rect", type="menarite",     x=49,  y =30, height=1, width=1,  amount=400000,  },
        { shape="rect", type="imersite",     x=60,  y =30, height=1, width=1,  amount=400000,  },
        
        { shape="rect", type="crude-oil", x=80, y=-6, height=1, amount=30000,  },
        { shape="rect", type="crude-oil", x=80, y= 0, height=1, amount=30000,  },
        { shape="rect", type="crude-oil", x=80, y= 6, height=1, amount=30000,  },
}

scenario.config.pyanodonResources = {
        { shape="rect", name="steel-chest", x=32,   y=-48, height=2, width=2, contents = { {name = "landfill", count=4800 } },  },
        { shape="rect", name="steel-chest", x=34,   y=-48, height=2, width=2, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=36,   y=-48, height=2, width=2, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=38,   y=-48,  height=1, width=1, contents = { 
            {name = "coal", count=1000 },
            {name = "stone", count=1000 },
            {name = "steel-plate", count=400 },
--            {name = "uranium-235", count=100 },
--            {name = "uranium-238", count=500 },
         }  },
        { shape="rect", name="steel-chest", x=40,   y=-48,  height=1, width=1, contents = { 
            -- we can simulate no-hand-crafting by making hand crafting really slow, and providing an asm2.
            {name = "offshore-pump", count = 1},
            {name = "boiler", count = 10},
            {name = "steam-engine", count = 20},
            {name = "pipe", count=12},
            {name = "pipe-to-ground", count=2},
            {name = "small-electric-pole", count = 20},
            {name = "inserter", count=20},
            {name = "assembling-machine-1", count=10},
            {name = "filter-inserter", count=4 },
        },  },

        -- all the basic building supplies you want    
        { shape="rect", name="infinity-chest", x=44,   y=-48,  height=1, width=1,
            props = { minable=false, operable=false, destructible=false, force="neutral", 
                infinity_container_filters = { 
                    {index = 1, name = "fast-miniloader", count = 50},
                    {index = 2, name = "fast-filter-miniloader", count = 50},
                    {index = 3, name = "fast-transport-belt", count = 50},
                    {index = 4, name = "fast-underground-belt", count = 50},
                    {index = 5, name = "fast-splitter", count = 50},
                    {index = 6, name = "fast-inserter", count=50},
                    {index = 7, name = "medium-electric-pole", count=50},
                    {index = 8, name = "big-electric-pole", count=50},
                    {index = 9, name = "pipe", count=50},
                    {index = 10, name = "pipe-to-ground", count=50},
                    {index = 11, name = "assembling-machine-2", count=50},
                    {index = 12, name = "electric-mining-drill", count=50},
                    {index = 13, name = "steel-furnace", count=50},
                    {index = 14, name = "construction-robot", count=50},
                    {index = 15, name = "roboport", count = 10},
                    {index = 16, name = "logistic-chest-storage", count = 50},
                    {index = 17 , name = "electronic-circuit", count=50},
                    {index = 18, name = "filter-inserter", count=50 },
        }, },  },

        { shape="rect", type="coal",         x=32,  y=-41, height=14, width=36,  amount=10000,  },
        { shape="rect", type="stone",        x=32,  y=-24, height=14, width=36,  amount=10000,  },
        { shape="rect", type="copper-ore",   x=32,  y=-7,  height=21, width=36,  amount=10000,  },
        { shape="rect", type="iron-ore",     x=32,  y =18, height=21, width=36, amount=10000,  },
--        
--        { shape="rect", type="crude-oil", x=72, y=-6, height=1, amount=10000000,  },
--        { shape="rect", type="crude-oil", x=72, y= 0, height=1, amount=10000000,  },
--        { shape="rect", type="crude-oil", x=72, y= 6, height=1, amount=10000000,  },
}

scenario.config.recipesEnabled = {
--        "loader",
--        "fast-loader",
--        "express-loader",
}

scenario.config.recipesDisabled = {
--    "locomotive",
--    "cargo-wagon",
--    "fluid-wagon",
--    "rail",
--    "rail-signal",
--    "rail-chain-signal",
--    "train-stop",
--    "artillery-wagon"
}

-- XXX detect angels ores and auto-configure
scenario.config.spawnResources = scenario.config.vanillaResources;
-- scenario.config.spawnResources = scenario.config.voidResources;
-- scenario.config.spawnResources = scenario.config.angelsResources;
-- scenario.config.spawnResources = scenario.config.krastorioResources;
-- scenario.config.spawnResources = scenario.config.omniResources;
--scenario.config.spawnResources = scenario.config.industrialRevolutionResources;
-- scenario.config.spawnResources = scenario.config.industrialPlusKrastorioResources;
-- scenario.config.spawnResources = scenario.config.seaBlockResources;
-- scenario.config.spawnResources = scenario.config.pyanodonResources;
-- scenario.config.spawnResources = scenario.config.noResources;


---------------------------------------
-- Resource Options
---------------------------------------
-- everyone gets a separate start area

SPAWN_TREE_DENSITY = 0.3


-- Force the land area circle at the spawn to be fully grass
ENABLE_SPAWN_FORCE_GRASS = true

---------------------------------------
-- Safe Spawn Area Options
---------------------------------------

-- These settings are deprecated, 
--     replaced by scenario.config.safe_area
--     but still appear in a few places.

-- Safe area around bunker entrance that has no aliens 
SAFE_AREA_BUNKER_ENTRANCE_TILE_DIST = CHUNK_SIZE * 2

-- Create a circle of land area for the spawn
-- deprecated
ENFORCE_LAND_AREA_TILE_DIST = 84 

---------------------------------------
-- Other Forces/Teams Options
---------------------------------------

-- I am not currently implementing other teams. It gets too complicated.
-- Enable if people can join their own teams
-- ENABLE_OTHER_TEAMS = false

-- Main force is what default players join
MAIN_FORCE = "main_force"
GAME_SURFACE_NAME = "nauvis"

-- Enable if people can spawn at the main base
ENABLE_DEFAULT_SPAWN = false

-- Enable if people can allow others to join their base
ENABLE_SHARED_SPAWNS = true
MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN = 3

---------------------------------------
-- Ghost Time to live
-- 
-- Set this to zero for infinite ghosts
---------------------------------------
GHOST_TIME_TO_LIVE = 0
-- 20 * TICKS_PER_MINUTE

---------------------------------------
-- Special Action Cooldowns
---------------------------------------
RESPAWN_COOLDOWN_IN_MINUTES = 30
RESPAWN_COOLDOWN_TICKS = TICKS_PER_MINUTE * RESPAWN_COOLDOWN_IN_MINUTES

-- Require playes to be online for at least 15 minutes
-- Else their character is removed and their spawn point is freed up for use
MIN_ONLIME_TIME_IN_MINUTES = 15
MIN_ONLINE_TIME = TICKS_PER_MINUTE * MIN_ONLIME_TIME_IN_MINUTES


-- Allow players to choose another spawn in the first 10 minutes
-- This does not allow creating a new spawn point. Only joining other players.
-- SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES = 10
-- SPAWN_GRACE_TIME = TICKS_PER_MINUTE * SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES


--------------------------------------------------------------------------------
-- Alien Options
--------------------------------------------------------------------------------

-- Enable/Disable enemy expansion
ENEMY_EXPANSION = true

-- Divide the alien factors by this number to reduce it (or multiply if < 1)
ENEMY_POLLUTION_FACTOR_DIVISOR = 5
ENEMY_DESTROY_FACTOR_DIVISOR = 5


--------------------------------------------------------------------------------
-- Long Reach Options
--------------------------------------------------------------------------------

BUILD_DIST_BONUS = 15
REACH_DIST_BONUS = BUILD_DIST_BONUS
RESOURCE_DIST_BONUS = 3

--------------------------------------------------------------------------------
-- Autofill Options
--------------------------------------------------------------------------------

AUTOFILL_TURRET_AMMO_QUANTITY = 10
AUTOFILL_FUEL_QUANTITY=50
AUTOFILL_MACHINEGUN_AMMO_QUANTITY=20
AUTOFILL_CANNON_AMMO_QUANTITY=20
AUTOFILL_FLAMETHROWER_AMMO_QUANTITY=20

-------------------------------------------------------------------------------
-- DEBUG
--------------------------------------------------------------------------------

-- DEBUG prints for me
global.oarcDebugEnabled = false
global.jvmguyDebugEnabled = false

scenario.config.modified_enemy_spawning = true;

scenario.config.safe_area =
    {
        -- Safe area has no aliens
        -- This is the radius in tiles of safe area.
        safe_radius = CHUNK_SIZE*6,

        -- Warning area has significantly reduced aliens
        -- This is the radius in tiles of warning area.
        warn_radius = CHUNK_SIZE*16,

        -- 1 : X (spawners alive : spawners destroyed) in this area
        warn_reduction_fraction = 0.05,

        -- Danger area has slightly reduce aliens
        -- This is the radius in tiles of danger area.
        danger_radius = CHUNK_SIZE*48,

        -- 1 : X (spawners alive : spawners destroyed) in this area
        danger_reduction_fraction = 0.2,
    }


scenario.config.fermatSpiralSpawnsTemplate = {
    -- this mostly inherits the separateSpawns config, but has a few minor differences
    seablock = false,    -- replace land with water except where there are resources
    crater = false,
    concrete = true,
    firstSpawnPoint = 1,
    numSpawnPoints = 20,
    extraSpawn = 55,    -- really far away, but not as far as you might think
    
    spacing = 1280,
    
    -- describe the spawn crop circle
    land = 80,
    moat = 10,   -- additional to land
    trees = 3,  -- included in the land
    size = 90,  -- should be land + moat
    craterSize = 320,  -- size of impact crater (greater than size)
    
    resources = scenario.config.spawnResources,

    -- freeze time of day
    -- you might get night vision at the start, but you have to decide whether it's worth using it.
    -- freezeTime = 0.35,   -- see https://wiki.factorio.com/Game-day
    -- 0 is day. 0.5 is night. 0.35 is twilight.
    researched = {
    -- 'coal-liquefaction',
    },
    
    startingEvolution=0.0,

    recipesEnabled = scenario.config.recipesEnabled,
    recipesDisabled = scenario.config.recipesDisabled,
    safe_area = scenario.config.safe_area, 
}

scenario.config.bunkerSpawns = {
    enabled = true,  -- added by reverend to enable teleport without silo teleport
    concrete = true,        -- pave the spawn with concrete
    -- this mostly inherits the separateSpawns config, but has a few minor differences
    firstSpawnPoint = 16,
    numSpawnPoints = 27,
    extraSpawn = 28,    -- really far away, but not as far as you might think
    
    spacing = 500,
    
    -- for the bunker zone
    bunkerSpacing = 576,
    bunkerZoneStart = 12*1024,
    bunkerZoneHeight = 4096,
    waterRadius = 100,
    bunkerRadius = 110,
    -- location within the bunker of the teleport that takes you to wilderness
    teleport = { x=24, y=-47 },
        
    -- The above ground entrance to the bunker. land + water
    bunkerEntranceLandRadius = 8,
    bunkerEntranceRadius = 32,
    
    land = 80,
    trees = 3,  -- included in the land
    moat = 10,   -- additional to land
    size = 90,  -- should be land + moat
    
    resources = scenario.config.spawnResources,

    -- freeze time of day
    -- you might get night vision at the start, but you have to decide whether it's worth using it.
    -- freezeTime = 0.35,   -- see https://wiki.factorio.com/Game-day
    -- 0 is day. 0.5 is night. 0.35 is twilight.
    researched = {
    -- 'coal-liquefaction',
    },
    
    startingEvolution=0.7,

    recipesEnabled = scenario.config.recipesEnabled,
    recipesDisabled = scenario.config.recipesDisabled,
    safe_area = scenario.config.safe_area, 
}

scenario.config.riverworld = {
    -- this mostly inherits the separateSpawns config, but has a few minor differences
    enabled = false,
    seablock = false,        -- behavior a little like the seablock mod. (well, not really)

    concrete = true,        -- pave the spawn with concrete
    stoneWalls = false,     -- if true, makes a stone wall. if false, generate a void.
    waterWalls = false,
    firstSpawnPoint = 14,
    numSpawnPoints = 27,
    extraSpawn = 28,    -- really far away, but not as far as you might think

    spacing = 736,  -- because of "no good reasons" this should be a multiple of 32 (chunk width)
    barrier = 256,  -- width of impenetrable barrier
    rail = 3*640,   -- generate a north-south railway starting here
    rail2 = -3*640-32, -- generate a north-south railway starting here
    freespace = 3*640 + 96, -- no voids after this 
    
    land = 77,
    trees = 3,  -- included in the land
    moat = 8,   -- additional to land
    size = 85,  -- should be land + moat

    -- this is a vertical moat, not the usual one around the spawn.
    moatWidth = 0,   -- additional to land

    startingEvolution=0.0,

    resources = scenario.config.spawnResources,
    -- freeze time of day
    -- you might get night vision at the start, but you have to decide whether it's worth using it.
    -- freezeTime = 0.35,   -- see https://wiki.factorio.com/Game-day
    -- 0 is day. 0.5 is night. 0.35 is twilight.
    recipesEnabled = scenario.config.recipesEnabled,
    recipesDisabled = scenario.config.recipesDisabled,
    safe_area = scenario.config.safe_area, 
}


scenario.config.fermatSpiralSpawns = {
    -- this mostly inherits the separateSpawns config, but has a few minor differences
    seablock = false,    -- replace land with water except where there are resources
    crater = false,
    concrete = true,
    firstSpawnPoint = 1,
    numSpawnPoints = 20,
    extraSpawn = 55,    -- really far away, but not as far as you might think
    
    spacing = 1280,
    
    -- describe the spawn crop circle
    land = 60,
    moat = 10,   -- additional to land
    trees = 3,  -- included in the land
    size = 70,  -- should be land + moat
    craterSize = 0,  -- size of impact crater (greater than size)
    
    resources = scenario.config.spawnResources,

    -- freeze time of day
    -- you might get night vision at the start, but you have to decide whether it's worth using it.
    -- freezeTime = 0.5,   -- see https://wiki.factorio.com/Game-day
    -- 0 is day. 0.5 is night. 0.35 is twilight.
    researched = {
    -- 'coal-liquefaction',
    },
    
    startingEvolution=0.0,

    recipesEnabled = scenario.config.recipesEnabled,
    recipesDisabled = scenario.config.recipesDisabled,
    safe_area = scenario.config.safe_area, 
}


