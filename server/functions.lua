RegisterNetEvent('Housing:s:CreateProperty', function (data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= Config.Job.name then return end
    if not exports[Config.ox_inventory]:CanCarryItem(xPlayer.source, 'property_key', 1) then
        Config.Notify(xPlayer.source, L('CantCarryKey'), 'error')
        Config.Notify(xPlayer.source, L('CreationCanceled'), 'error')
        return
    end
    local id = MySQL.insert.await('INSERT INTO `properties` (shell, enter_coords) VALUES (?, ?)', {
        data.shell, json.encode(data.enterCoords)
    })
    AddKey(id, xPlayer.source)
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