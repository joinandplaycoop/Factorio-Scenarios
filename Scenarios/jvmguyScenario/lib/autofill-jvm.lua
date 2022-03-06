--------------------------------------------------------------------------------
-- Autofill Stuff
--------------------------------------------------------------------------------

-- Transfer Items Between Inventory
-- Returns the number of items that were successfully transferred.
-- Returns -1 if item not available.
-- Returns -2 if can't place item into destInv (ERROR)
local function TransferItems(result, srcInv, destEntity, itemStack)
    -- Check if item is in srcInv
    if (srcInv.get_item_count(itemStack.name) == 0) then
        return -1
    end

    -- Check if can insert into destInv
    if (not destEntity.can_insert(itemStack)) then
        return -2
    end
    
    -- Insert items
    local itemTotal = srcInv.get_item_count(itemStack.name)
    local itemsRemoved = srcInv.remove(itemStack)
    itemStack.count = itemsRemoved
    result.autofillItemRemaining = itemTotal - itemsRemoved
    result.autofillItemName = itemStack.name
    return destEntity.insert(itemStack)
end

-- Attempts to transfer at least some of one type of item from an array of items.
-- Use this to try transferring several items in order
-- It returns once it successfully inserts at least some of one type.
local function TransferItemMultipleTypes(result, srcInv, destEntity, itemNameArray, itemCount)
    local ret = 0
    for _,itemName in pairs(itemNameArray) do
        ret = TransferItems(result, srcInv, destEntity, {name=itemName, count=itemCount})
        if (ret > 0) then
            return ret
             -- Return the value succesfully transferred
        end
    end
    return ret
     -- Return the last error code
end

local vehicleFuel = {"rocket-fuel", "solid-fuel", "wood", "coal"}
local machineGunAmmo = {"uranium-rounds-magazine", "piercing-rounds-magazine","firearm-magazine"}
local tankCannonAmmo = {"explosive-uranium-cannon-shell", "uranium-cannon-shell", "explosive-cannon-shell", "cannon-shell"}
local tankFlamethrowerAmmo = {"flamethrower-ammo"}

local localizedName = {
    -- fuel
    ["rocket-fuel"] = "Rocket Fuel", 
    ["solid-fuel"] = "Solid Fuel",
    ["wood"] = "Wood",
    ["coal"] = "Coal",

    -- machine gun / turret ammo
    ["uranium-rounds-magazine"] = "Uranium Rounds Magazine", 
    ["piercing-rounds-magazine"] = "Piercing Rounds Magazine",
    ["firearm-magazine"] = "Firearm Magazine",

    -- tank gun ammo
    ["explosive-uranium-cannon-shell"] = "Explosive Uranium Cannon Shell",
    ["uranium-cannon-shell"] = "Uranium Cannon Shell",
    ["explosive-cannon-shell"] = "Explosive Cannon Shell",
    ["cannon-shell"] = "Cannon Shell",
    
    -- flamethrower ammo
    ["flamethrower-ammo"] = "Flamethrower Ammo"
}

local function ShowAutofillResult( ret, result, itemKind, position, offset)
    -- Check the result and print the right text to inform the user what happened.
    if (ret > 0) then
        -- Inserted ammo successfully
        local color = {r=255,g=255,b=255}
        local ammoName = localizedName[ result.autofillItemName ];
        if ammoName ~= nil then
            FlyingText("+" .. ret .. " " .. ammoName .. " (" .. result.autofillItemRemaining .. ")", { position.x, position.y + offset}, color)
        end
    elseif (ret == -1) then
        local color = {r=255,g=255,b=255}
        FlyingText("No " .. itemKind .. " in Main Inventory to Transfer", { position.x, position.y + offset}, color) 
    elseif (ret == -2) then
        local color = {r=255,g=255,b=255}
        FlyingText("Autofill ERROR! - Report this bug!", { position.x, position.y + offset}, color )
    end
end

-- Autofills a turret with ammo
local function AutofillTurret(player, turret)
    local mainInv = player.get_inventory(defines.inventory.character_main)
    local result = {}

    -- Attempt to transfer some ammo
    local ret = TransferItemMultipleTypes(result, mainInv, turret, machineGunAmmo, AUTOFILL_TURRET_AMMO_QUANTITY)
    ShowAutofillResult( ret, result, "Ammo", turret.position, 0 );
end

-- Autofills a vehicle with fuel, bullets and shells where applicable
local function AutoFillVehicle(player, vehicle)
    local mainInv = player.get_inventory(defines.inventory.character_main)
    local result = {}

    -- Attempt to transfer some fuel
    if ((vehicle.name == "car") or (vehicle.name == "tank") or (vehicle.name == "locomotive")) then
      local ret = TransferItemMultipleTypes(result, mainInv, vehicle, vehicleFuel, AUTOFILL_FUEL_QUANTITY)
      ShowAutofillResult( ret, result, "Fuel", vehicle.position, 0);
    end

    -- Attempt to transfer some ammo
    if ((vehicle.name == "car") or (vehicle.name == "tank")) then
      local ret = TransferItemMultipleTypes(result, mainInv, vehicle, machineGunAmmo, AUTOFILL_MACHINEGUN_AMMO_QUANTITY)
      ShowAutofillResult( ret, result, "Ammo", vehicle.position, 1 );
    end

    -- Attempt to transfer some tank shells
    if (vehicle.name == "tank") then
      local ret = TransferItemMultipleTypes(result, mainInv, vehicle, tankCannonAmmo, AUTOFILL_CANNON_AMMO_QUANTITY)
      ShowAutofillResult( ret, result, "Shells", vehicle.position, 2);
      local ret = TransferItemMultipleTypes(result, mainInv, vehicle, tankFlamethrowerAmmo, AUTOFILL_FLAMETHROWER_AMMO_QUANTITY)
      ShowAutofillResult( ret, result, "Flamethrower Ammo", vehicle.position, 3);
    end
end

-- Autofill softmod
local function Autofill(event)
    local player = game.players[event.player_index]
    local eventEntity = event.created_entity

    if (eventEntity.name == "gun-turret") then
        AutofillTurret(player, eventEntity)
    end

    if ((eventEntity.name == "car") or (eventEntity.name == "tank") or (eventEntity.name == "locomotive")) then
        AutoFillVehicle(player, eventEntity)
    end
end

Event.register(defines.events.on_built_entity, Autofill)
