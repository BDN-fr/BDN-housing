function CreateProperty(data)
    local code = math.random(0,1000)
    local id = MySQL.insert.await('INSERT INTO `properties` (shell, enter_coords, key_code) VALUES (?, ?, ?)', {
        data.shell, json.encode(data.enterCoords), code
    })
    Properties[id] = {shell = data.shell, enter_coords = data.enterCoords, key_code = code}
    exports[Config.ox_inventory]:RegisterStash('property'..id, L('Storage'), Config.Storage.slots, Config.Storage.weight)
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
        propertyId = propertyId,
        code = Properties[propertyId].key_code
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
    return exports[Config.ox_inventory]:GetItemCount(playerId, 'property_key', {propertyId = propertyId, code = Properties[propertyId].key_code}, true) > 0
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
    clearMeta = clearMeta or true
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

function ClearPropertyFurnitures(propertyId)
    local furnitures = GetPropertyFurnitures(propertyId)
    for i, v in ipairs(furnitures) do
        DeleteFurniture(propertyId, v.id)
    end
end

RegisterNetEvent('Housing:s:RingProperty', function (propertyId)
    for playerId, pId in pairs(PlayersInsideProperties) do
        if pId == propertyId then
            Config.Notify(playerId, L('Ringed'), 'inform')
        end
    end
end)

RegisterNetEvent('Housing:s:SavePropertyLayout', function (propertyId, name)
    local source = source
    if not DoesPlayerHavePropertyKey(propertyId, source) then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local identifier = xPlayer.getIdentifier()
    local shell = Properties[propertyId].shell
    local furnitures = GetPropertyFurnitures(propertyId)
    local furnitures2 = {}
    for i, v in ipairs(furnitures) do
        table.insert(furnitures2, {c = v.coords, r = v.rotation, m = v.model})
    end
    MySQL.insert.await('INSERT INTO `properties_layouts` (identifier, shell, name, furnitures) VALUES (?,?,?,?)', {
        identifier, shell, name, json.encode(furnitures2)
    })
    Config.Notify(source, L('LayoutSaved'), 'success')
end)

RegisterNetEvent('Housing:s:LoadLayout', function (propertyId, layoutId)
    local source = source
    if not DoesPlayerHavePropertyKey(propertyId, source) then return end
    local layout = MySQL.query.await('SELECT * FROM `properties_layouts` WHERE id = ? LIMIT 1', {
        layoutId
    })[1]
    if not (layout.shell == Properties[propertyId].shell) then Config.Notify(source, L('NotSameInterior'), 'error') return end
    ClearPropertyFurnitures(propertyId)
    for i, v in ipairs(json.decode(layout.furnitures)) do
        local furniture = {coords = v.c, rotation = v.r, model = v.m}
        AddPropertyFurniture(propertyId, furniture)
    end
end)

function GetPlayerLayouts(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return MySQL.query.await('SELECT id, name, shell FROM `properties_layouts` WHERE identifier = ?', {
        xPlayer.getIdentifier()
    })
end

lib.callback.register('Housing:s:GetPlayerLayouts', function (source)
    return GetPlayerLayouts(source)
end)

function DeletePlayerLayout(playerId, layoutId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local identifier = xPlayer.getIdentifier()
        MySQL.rawExecute.await('DELETE FROM `properties_layouts` WHERE id = ? AND identifier = ?', {
            layoutId, identifier
        })
    else
        MySQL.rawExecute.await('DELETE FROM `properties_layouts` WHERE id = ?', {
            layoutId
        })
    end
end

lib.callback.register('Housing:s:DeleteLayout', function (source, layoutId)
    DeletePlayerLayout(source, layoutId)
end)

RegisterNetEvent('Housing:s:PlacePropertyStorage', function (propertyId, coords)
    if not DoesPlayerHavePropertyKey(propertyId, source) then return end
    MySQL.update.await('UPDATE `properties` SET storage_coords = ? WHERE id = ?', {
        json.encode(coords), propertyId
    })
    Properties[propertyId].storage_coords = coords
    TriggerClientEvent('Housing:c:UpdateStorageCoords', -1, propertyId, coords)
end)

RegisterNetEvent('Housing:s:DeleteProperty', function (propertyId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer?.job.name == Config.Job.name then return end
    MySQL.rawExecute.await('DELETE FROM `properties` WHERE id = ?', {
        propertyId
    })
    MySQL.rawExecute('DELETE FROM `properties_furnitures` WHERE property_id = ?', {
        propertyId
    })
    Properties[propertyId] = nil
    TriggerClientEvent('Housing:c:RemoveProperty', -1, propertyId)
end)

RegisterNetEvent('Housing:s:ChangeKeyCode', function (propertyId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer?.job.name == Config.Job.name then return end
    if not exports[Config.ox_inventory]:CanCarryItem(source, 'property_key', 1) then
        Config.Notify(source, L('CantCarryKey'), 'error')
        return
    end
    local newCode = math.random(0, 1000)
    Properties[propertyId].key_code = newCode
    MySQL.update('UPDATE `properties` SET key_code = ? WHERE id = ?', {
        newCode, propertyId
    })
    AddKey(propertyId, source)
end)

function SubPlayeyAllInvKeys(playerId, state)
    local slots
    while not slots do
        slots = exports[Config.ox_inventory]:GetSlotsWithItem(playerId, 'property_key')
        Wait(1)
    end
    for i, v in ipairs(slots) do
        if v.metadata.propertyId then
            SubPlayeyToProperty(v.metadata.propertyId, playerId, state)
        end
    end
end