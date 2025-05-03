function WaitInput(message, keys, cb)
    lib.showTextUI(message)
    while true do
        Wait(0)
        for i, key in ipairs(keys) do
            if IsControlJustReleased(0, key) or IsDisabledControlJustReleased(0, key) then
                lib.hideTextUI()
                cb(key)
                return
            end
        end
    end
end

function DrawConfigMarker(coords)
    local m = Config.marker
    DrawMarker(
        m.type,
        coords.x, coords.y, coords.z+m.zOffset,
        m.dir.x, m.dir.y, m.dir.z,
        m.rot.x, m.rot.y, m.rot.z,
        m.scale.x, m.scale.y, m.scale.z,
        m.red,
        m.green,
        m.blue,
        m.alpha,
        m.bobUpAndDown,
        m.faceCamera,
        m.rotationOrder,
        m.rotate,
        m.textureDict,
        m.textureName,
        m.drawOnEnts
    )
end

function CreateProperty()
    local isCreatingProperty = true
    local enterCoords
    WaitInput('[E] - '..L('PlaceEnter'), {51}, function (key)
        enterCoords = GetEntityCoords(PlayerPedId())
        CreateThread(function ()
            while isCreatingProperty do
                Wait(0)
                DrawConfigMarker(enterCoords)
            end
        end)
    end)
    local shellsOptions = {}
    for k,v in pairs(Config.Shells) do
        table.insert(shellsOptions, {value = k, label = v.label})
    end
    local input = lib.inputDialog(L('CreateProperty'), {
        {type = 'select', label = L('InteriorType'), options = shellsOptions, required = true, searchable = true}
    })
    if not input then
        isCreatingProperty = false
        return
    end
    local data = {}
    data.shell = input[1]
    data.enterCoords = enterCoords
    TriggerServerEvent('Housing:s:CreateProperty', data)
    isCreatingProperty = false
end

function SpawnProp(model, coords, collisions)
    lib.requestModel(model)
    local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(obj, true)
    SetEntityCanBeDamaged(obj, false)
    SetEntityCollision(obj, collisions or true, false)
    SetEntityDynamic(obj, false)
    SetEntityHasGravity(obj, false)
    SetModelAsNoLongerNeeded(model)
    return obj
end

function SpawnFurniture(propertyCoords, v)
    local coords = json.decode(v.coords)
    coords = vec3(coords.x, coords.y, coords.z) + propertyCoords
    local obj = SpawnProp(v.model, coords)
    SetEntityCoordsNoOffset(obj, coords.x, coords.y, coords.z, false, false, false)
    local rot = json.decode(v.rotation)
    SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, false)
    CurrentPropertyFurnitures[v.id] = {model = v.model, obj = obj}
end

function SpawnFurnitures(propertyCoords, furnitures)
    for i, v in ipairs(furnitures) do
        SpawnFurniture(propertyCoords, v)
    end
end

function RemoveFurniture(id)
    DeleteObject(CurrentPropertyFurnitures[id].obj)
    CurrentPropertyFurnitures[id] = nil
end

function RemoveFurnitures(furnitures)
    for id, v in pairs(furnitures) do
        RemoveFurniture(id)
    end
end

RegisterNetEvent('Housing:c:AddProperty', function (data)
    Properties[data[1]] = data[2]
    if ESX.PlayerData.job.name == Config.Job.name then
        Properties[data[1]].jobBlip = CreateBlip(data[2].enter_coords, Config.Job.blip)
    end
end)

RegisterNetEvent('Housing:c:RemoveProperty', function (id)
    if Properties[id].blip then RemoveBlip(Properties[id].blip) end
    Properties[id] = nil
end)


-- local cam
local prop
-- local propCoords
-- function StartPreview()
--     propCoords = GetEntityCoords(PlayerPedId(), false) + vec3(0,0,150)
--     cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
--     local camCoords = propCoords + Config.previewCamOffset
--     SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
--     PointCamAtCoord(cam, propCoords.x, propCoords.y, propCoords.z)
--     RenderScriptCams(true, false, 0, false, true)
--     FreezeEntityPosition(PlayerPedId(), true)
--     CreateThread(function (threadId)
--         while cam do
--             DisableControlAction(0, 51, true)
--             Wait(0)
--         end
--     end)
-- end

function PreviewProp(model)
    if prop then
        DeleteObject(prop)
    end
    -- prop = SpawnProp(model, propCoords)
    -- local min, max = GetModelDimensions(model)
    -- local size = max-min
    -- local camCoords = propCoords + size*1.5
    -- SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
    -- PointCamAtCoord(cam, propCoords.x, propCoords.y, propCoords.z+size.z/2)
    local propCoords = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 1.5
    prop = SpawnProp(model, propCoords, false) -- Remvove this line if you bring back the cam in the sky
    local currentProp = prop
    CreateThread(function (threadId)
        while prop == currentProp do
            SetEntityHeading(currentProp, GetEntityHeading(currentProp)+1)
            Wait(1)
        end
    end)
end

function StopPreview()
    -- DestroyCam(cam, true)
    DeleteObject(prop)
    -- cam = nil
    -- prop = nil
    -- RenderScriptCams(false, false, 0, false, true)
    -- FreezeEntityPosition(PlayerPedId(), false)
end

function PlaceFurniture(model)
    local data = Config.PlaceProp(model)
    local furniture = {}
    furniture.model = model
    furniture.coords = json.encode(data.position - CurrentPropertyCoords)
    furniture.rotation = json.encode(data.rotation)
    -- Client need to wait
    lib.callback.await('Housing:s:AddPropertyFurniture', 1000, CurrentPropertyId, furniture)
    -- TriggerServerEvent('Housing:s:AddPropertyFurniture', CurrentPropertyId, furniture)
end

RegisterNetEvent('Housing:c:AddFurnitureInCurrentProperty', function (furniture)
    SpawnFurniture(CurrentPropertyCoords, furniture)
end)

function DeleteFurniture(propertyId, id)
    -- Client need to wait
    lib.callback.await('Housing:s:DeletePropertyFurniture', 1000, propertyId, id)
    -- TriggerServerEvent('Housing:s:DeletePropertyFurniture', propertyId, id)
end

RegisterNetEvent('Housing:c:RemoveFurnitureInCurrentProperty', function (id)
    RemoveFurniture(id)
end)

function SavePropertyLayout()
    local input = lib.inputDialog(L('SaveLayout'), {
        {type = 'input', label = L('LayoutName'), required = true}
    })
    if not input then return end
    TriggerServerEvent('Housing:s:SavePropertyLayout', CurrentPropertyId, input[1])
end

function LoadPropertyLayout(layoutId)
    TriggerServerEvent('Housing:s:LoadLayout', CurrentPropertyId, layoutId)
end

function OpenStorage(propertyId)
    exports[Config.ox_inventory]:openInventory('stash', 'property'..propertyId)
end

RegisterNetEvent('Housing:c:UpdateStorageCoords', function (propertyId, coords)
    Properties[propertyId].storage_coords = coords
end)

function CreateBlip(coords, params)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, params.sprite)
    SetBlipColour(blip, params.color)
    SetBlipScale(blip, params.scale)
    SetBlipDisplay(blip, params.display)
    SetBlipAlpha(blip, params.alpha)
    SetBlipAsShortRange(blip, params.showAtShortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(L('Property'))
    EndTextCommandSetBlipName(blip)
    return blip
end