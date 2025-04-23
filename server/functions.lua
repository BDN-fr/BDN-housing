function CreateProperty(data)
    local id = MySQL.insert.await('INSERT INTO `properties` (shell, enter_coords) VALUES (?, ?)', {
        data.shell, json.encode(data.enterCoords)
    })
    Properties[id] = {shell = data.shell, enter_coords = data.enterCoords}
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

RegisterNetEvent('Housing:s:giveKey', function (propertyId)
    local source = source
    if not DoesPlayerHavePropertyKey(propertyId, source) then
        Config.Notify(source, L('CantGetKey'), 'error')
        return
    end
    AddKey(propertyId, source)
end)

function SubPlayeyToProperty(propertyId, playerId, state)
    TriggerClientEvent('Housing:c:SubToProperty', playerId, propertyId, state)
end

lib.callback.register('Housing:s:IsPropertyLocked', function (source, propertyId)
    return PropertiesState[propertyId] or false
end)

function DoesPlayerHavePropertyKey(propertyId, playerId)
    return exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', {propertyId = propertyId}, true) > 0
end

lib.callback.register('Housing:s:DoesIHavePropertyKey', function (source, propertyId)
    return DoesPlayerHavePropertyKey(propertyId, source)
end)

RegisterNetEvent('Housing:s:TogglePropertyLock', function (propertyId)
    local source = source
    if not DoesPlayerHavePropertyKey(propertyId, source) then
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

lib.callback.register('Housing:s:EnterProperty', function (source, propertyId)
    SetPlayerRoutingBucket(source, propertyId)
    PlayersInsideProperties[source] = propertyId
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.setMeta('insideProperty', propertyId)
end)

lib.callback.register('Housing:s:ExitProperty', function (source, clearMeta)
    clearMeta = not clearMeta == false
    SetPlayerRoutingBucket(source, Config.defaultRoutingBucket)
    PlayersInsideProperties[source] = nil
    local xPlayer = ESX.GetPlayerFromId(source)
    if clearMeta then
        xPlayer.clearMeta('insideProperty')
    end
end)

function GetPropertyFurnitures(propertyId)
    return MySQL.query.await('SELECT * FROM `properties_furnitures` WHERE property_id = ?', {
        propertyId
    })
end

lib.callback.register('Housing:s:GetPropertyFurnitures', function (source, propertyId)
    return GetPropertyFurnitures(propertyId)
end)

function GetPropertyFurnituresAmount(propertyId)
    return MySQL.query.await('SELECT COUNT(*) FROM `properties_furnitures` WHERE property_id = ?', {
        propertyId
    })[1]["COUNT(*)"]
end

function AddPropertyFurniture(propertyId, furniture)
    local id = MySQL.insert.await('INSERT INTO `properties_furnitures` (property_id, model, coords, rotation) VALUES (?,?,?,?)', {
        propertyId, furniture.model, furniture.coords, furniture.rotation
    })
    furniture.id = id
    for playerId, pId in pairs(PlayersInsideProperties) do
        if pId == propertyId then
            TriggerClientEvent('Housing:c:AddFurnitureInCurrentProperty', playerId, furniture)
        end
    end
end

lib.callback.register('Housing:s:AddPropertyFurniture', function (source, propertyId, furniture)
    if not DoesPlayerHavePropertyKey(propertyId, source) then return end
    if not (GetPropertyFurnituresAmount(propertyId) < Config.maxFurnitures) then
        Config.Notify(source, L('FurnituresLimitReached'), 'error')
        return
    end
    AddPropertyFurniture(propertyId, furniture)
end)

function DeleteFurniture(propertyId, furnitureId)
    MySQL.rawExecute.await('DELETE FROM `properties_furnitures` WHERE id = ?', {
        furnitureId
    })
    for playerId, pId in pairs(PlayersInsideProperties) do
        if pId == propertyId then
            TriggerClientEvent('Housing:c:RemoveFurnitureInCurrentProperty', playerId, furnitureId)
        end
    end
end

RegisterNetEvent('Housing:s:DeletePropertyFurniture', function (propertyId, furnitureId)
    if not DoesPlayerHavePropertyKey(propertyId, source) then return end
    DeleteFurniture(propertyId, furnitureId)
end)

-- Making client wait for reoppening the menu
lib.callback.register('Housing:s:DeletePropertyFurniture', function (source, propertyId, furnitureId)
    if not DoesPlayerHavePropertyKey(propertyId, source) then return end
    DeleteFurniture(propertyId, furnitureId)
end)

RegisterNetEvent('Housing:s:RingProperty', function (propertyId)
    for playerId, pId in pairs(PlayersInsideProperties) do
        if pId == propertyId then
            Config.Notify(playerId, L('Ringed'), 'inform')
        end
    end
end)