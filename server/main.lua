--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   | |  | | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | For Odyssée WL - https://discord.gg/fH8bSDBFvK

print(([[

    /\     
   /[]\    %s
  /____\   By BDN_fr - https://bdn-fr.xyz/
  |_   |   For Odyssée WL - https://discord.gg/fH8bSDBFvK
  |_|__|   
]]):format(GetCurrentResourceName()))

local file = io.open(("@%s/sql.sql"):format(GetCurrentResourceName()), "r")
if not file then
    error('sql.sql not found, please create a sql.sql file with the script\'s SQL', 0)
else
    local fileContent = file:read("*a")
    for v in string.gmatch(fileContent, '[^;]*;') do
        MySQL.rawExecute.await(v)
    end
    print('SQL successfully executed')
    file:close()
end

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

exports[Config.ox_inventory]:registerHook('swapItems', function(payload)
    if not (payload.action == 'give' or payload.action == 'move') then return end
    if not (payload.fromType == 'player' or payload.toType == 'player') then return end
    local metadata = payload.fromSlot.metadata
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
    if exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', metadata, true) > payload.count then return end
    SubPlayeyToProperty(metadata.propertyId, playerId, state)
end, {
    itemFilter = {
        ['property_key'] = true
    }
})

exports[Config.ox_inventory]:registerHook('createItem', function(payload)
    if type(payload.inventoryId) ~= "number" then return end
    -- Player get a key
    local playerId = payload.inventoryId
    if exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', payload.metadata, true) > 0 then return end
    SubPlayeyToProperty(payload.metadata.propertyId, playerId, true)
end, {
    itemFilter = {
        ['property_key'] = true
    }
})

RegisterNetEvent('Housing:s:HeySendMePropertiesPlease', function ()
    TriggerClientEvent('Housing:c:RegisterProperties', source, Properties)
end)

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer, isNew)
    local slots
    while not slots do
        slots = exports[Config.ox_inventory]:GetSlotsWithItem(playerId, 'property_key')
        Wait(0)
    end
    for i, v in ipairs(slots) do
        if v.metadata.propertyId then
            SubPlayeyToProperty(v.metadata.propertyId, playerId, true)
        end
    end

    if xPlayer.getMeta('insideProperty') then
        TriggerClientEvent('Housing:c:EnterProperty', playerId, xPlayer.getMeta('insideProperty'))
    end
end)

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
    local slots = exports[Config.ox_inventory]:GetSlotsWithItem(playerId, 'property_key')
    if not slots then return end
    for i, v in ipairs(slots) do
        if v.metadata.propertyId then
            SubPlayeyToProperty(v.metadata.propertyId, playerId, false)
        end
    end
end)

RegisterCommand('givekey', function(source, args, rawCommand)
    AddKey(tonumber(args[1]), source)
end, true)

RegisterNetEvent('Housing:s:CreateProperty', function (data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= Config.Job.name then return end
    if not exports[Config.ox_inventory]:CanCarryItem(xPlayer.source, 'property_key', 1) then
        Config.Notify(xPlayer.source, L('CantCarryKey'), 'error')
        Config.Notify(xPlayer.source, L('CreationCanceled'), 'error')
        return
    end
    local id = CreateProperty(data)
    AddKey(id, xPlayer.source)
end)

RegisterCommand('getBucket', function(source, args, rawCommand)
    print(GetPlayerRoutingBucket(source))
end, true)

RegisterCommand('setBucket', function(source, args, rawCommand)
    if not args[1] then return end
    SetPlayerRoutingBucket(source, tonumber(args[1]))
end, true)