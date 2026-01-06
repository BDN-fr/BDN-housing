--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   |      | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | Open Source - https://github.com/BDN-fr/BDN-housing

print(([[

    /\     
   /[]\    %s
  /____\   By BDN_fr - https://bdn-fr.xyz/
  |_   |   Open Source - https://github.com/BDN-fr/BDN-housing
  |_|__|   
]]):format(GetCurrentResourceName()))

-- local file = io.open(("@%s/sql.sql"):format(GetCurrentResourceName()), "r")
-- if not file then
--     error('sql.sql not found, please create a sql.sql file with the script\'s SQL', 0)
-- else
--     local fileContent = file:read("*a")
--     for v in string.gmatch(fileContent, '[^;]*;') do
--         MySQL.rawExecute.await(v)
--     end
--     print('SQL successfully executed')
--     file:close()
-- end

Properties = {}
MySQL.query('SELECT * FROM `properties`', {}, function (res)
    if not res then return end
    for i, v in ipairs(res) do
        v.enter_coords = json.decode(v.enter_coords)
        v.enter_coords = vec3(v.enter_coords.x, v.enter_coords.y, v.enter_coords.z)
        if v.storage_coords then
            v.storage_coords = json.decode(v.storage_coords)
            v.storage_coords = vec3(v.storage_coords.x, v.storage_coords.y, v.storage_coords.z)
        end
        Properties[v.id] = v
        exports[Config.ox_inventory]:RegisterStash('property'..v.id, L('Storage'), Config.Storage.slots, Config.Storage.weight)
    end
end)
PropertiesState = {}
PlayersInsideProperties = {}

local function playerHook(payload, playerId, state)
    local metadata = payload.fromSlot.metadata
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if metadata.container then
        local inv = exports[Config.ox_inventory]:GetContainerFromSlot(payload.fromInventory, exports[Config.ox_inventory]:GetSlotIdWithItem(payload.fromInventory, payload.fromSlot.name, metadata, true))
        local keys = exports[Config.ox_inventory]:GetSlotsWithItem(inv, 'property_key')
        for id, slot in pairs(keys) do
            if exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', slot.metadata, false) == 0 then
                SetPlayerKey(xPlayer.identifier, slot.metadata.propertyId, state)
                SubPlayerToProperty(slot.metadata.propertyId, playerId, state)
            end
        end
    else
        local count = state and 0 or payload.count
        if exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', metadata, false) > count then return end
        local items = exports[Config.ox_inventory]:GetInventoryItems(playerId)
        for id, slot in pairs(items) do
            if slot.metadata.container then
                local inv = exports[Config.ox_inventory]:GetInventory(slot.metadata.container)
                if exports[Config.ox_inventory]:GetItemCount(inv, 'property_key', metadata, false) > 0 then
                    return
                end
            end
        end
        SetPlayerKey(xPlayer.identifier, metadata.propertyId, state)
        SubPlayerToProperty(metadata.propertyId, playerId, state)
    end
end

exports[Config.ox_inventory]:registerHook('swapItems', function(payload)
    if not (payload.action == 'give' or payload.action == 'move') then return end
    if not (payload.fromType == 'player' or payload.toType == 'player') then return end
    if payload.fromInventory == payload.toInventory then return end
    if payload.fromType == 'container' or payload.toType == 'container' then return end
    local metadata = payload.fromSlot.metadata
    if not payload.fromSlot.name == 'property_key' and not metadata.container then return end
    if payload.fromType == 'player' and payload.toType == 'player' then
        local idFrom = payload.fromInventory
        local idTo = payload.toInventory
        playerHook(payload, idFrom, false)
        playerHook(payload, idTo, true)
        return
    end
    local playerId, state
    if payload.fromType == 'player' then
        -- Player giving a key
        playerId = payload.fromInventory
        state = false
    end
    if payload.toType == 'player' then
        -- Player reciving a key
        playerId = payload.toInventory
        state = true
    end
    playerHook(payload, playerId, state)
end)

exports[Config.ox_inventory]:registerHook('createItem', function(payload)
    if type(payload.inventoryId) ~= "number" then return end
    -- Player get a key
    local playerId = payload.inventoryId
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', payload.metadata, false) > 0 then return end
    SetPlayerKey(xPlayer.identifier, payload.metadata.propertyId, true)
    SubPlayerToProperty(payload.metadata.propertyId, playerId, true)
end, {
    itemFilter = {
        ['property_key'] = true
    }
})

RegisterNetEvent('Housing:s:HeySendMePropertiesPlease', function ()
    TriggerClientEvent('Housing:c:RegisterProperties', source, Properties)
end)

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer, isNew)
    SubPlayerAllInvKeys(playerId, true)

    if xPlayer.getMeta('insideProperty') then
        TriggerClientEvent('Housing:c:EnterProperty', playerId, xPlayer.getMeta('insideProperty'))
    end
end)

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
    SubPlayerAllInvKeys(playerId, false)
end)

RegisterCommand('givekey', function(source, args, rawCommand)
    AddKey(tonumber(args[1]), source)
end, true)

RegisterNetEvent('Housing:s:CreateProperty', function (data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= Config.Job.name then return end
    if not exports[Config.ox_inventory]:RemoveItem(xPlayer.source, Config.Items[Config.Shells[data.shell].itemType], 1) then
        Config.Notify(xPlayer.source, L('LackItem'), 'error')
        Config.Notify(xPlayer.source, L('CreationCanceled'), 'error')
        return
    end
    if not exports[Config.ox_inventory]:CanCarryItem(xPlayer.source, 'property_key', 1) then
        Config.Notify(xPlayer.source, L('CantCarryKey'), 'error')
        Config.Notify(xPlayer.source, L('CreationCanceled'), 'error')
        return
    end
    local id = CreateProperty(data)
    AddKey(id, xPlayer.source)
end)