function CreateProperty(data)
    local id = MySQL.insert.await('INSERT INTO `properties` (shell, enter_coords) VALUES (?, ?)', {
        data.shell, json.encode(data.enterCoords)
    })
    Properties[id] = {shell = data.shell, coords = data.enterCoords}
    TriggerClientEvent('Housing:c:AddProperty', -1, {id, Properties[id]})
    return id
end

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

function SubPlayeyToProperty(propertyId, playerId, state)
    -- print(('Subbed [%s] to property [%s]'):format(playerId, propertyId), state)
    TriggerClientEvent('Housing:c:SubToProperty', playerId, propertyId, state)
end

lib.callback.register('Housing:s:isPropertyLocked', function (source, propertyId)
    return PropertiesState[propertyId] or false
end)

RegisterNetEvent('Housing:s:TogglePropertyLock', function (propertyId)
    local source = source
    if not (exports[Config.ox_inventory]:GetItemCount(source, 'property_key', {propertyId = propertyId}, true) > 0) then
        Config.Notify(source, L('DontHaveKey'), 'error')
        return
    end
    PropertiesState[propertyId] = not PropertiesState[propertyId]
    if PropertiesState[propertyId] then
        Config.Notify(source, L('OpenedDoor'), 'success')
    else
        Config.Notify(source, L('ClosedDoor'), 'success')
    end

    local players = lib.getNearbyPlayers(Properties[propertyId].enter_coords, 3.0)
    for i, v in ipairs(players) do
        TriggerClientEvent('Housing:c:UpdateState', v.id, propertyId, PropertiesState[propertyId])
    end
end)