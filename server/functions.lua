function CreateProperty(data)
    local id = MySQL.insert.await('INSERT INTO `properties` (shell, enter_coords) VALUES (?, ?)', {
        data.shell, json.encode(data.enterCoords)
    })
    Properties[id] = {shell = data.shell, coords = json.encode(data.enterCoords)}
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