RegisterNetEvent('Housing:s:CreateProperty', function (source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= Config.Job.name then return end
    if not exports[Config.ox_inventory]:CanCarryItem(source, 'property_key', 1) then
        Config.Notify(source, L('CantCarryKey'), 'error')
        Config.Notify(source, L('CreationCanceled'), 'error')
        return
    end
    local id = MySQL.insert.await('INSERT INTO `properties` (shell, enter_coords) VALUES (?, ?)', {
        data.shell, json.encode(data.enterCoords)
    })
    print(id)
    AddKey(id, source)
end)

function AddKey(propertyId, playerId)
    -- In case I don't it check before
    if not exports[Config.ox_inventory]:CanCarryItem(playerId, 'property_key', 1) then
        Config.Notify(playerId, L('CantCarryKey'), 'error')
        return false
    end
    exports[Config.ox_inventory]:AddItem(playerId, 'property_key', 1, {
        propertyId = propertyId
    })
end